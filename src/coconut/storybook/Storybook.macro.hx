package coconut.storybook;

import haxe.macro.Expr;
import haxe.macro.Context;

using tink.MacroApi;

class Storybook {
	public static macro function add(exprs:Array<Expr>):Expr {
		var ret = [];

		for (expr in exprs) {
			switch Context.typeof(expr) {
				case TInst(_.get() => {
					pack: pack,
					name: cname,
					meta: meta,
					fields: _.get() => fields
				}, _):
					function subst(e:Expr)
						return switch e {
							case macro this.$field:
								macro @:pos(e.pos) @:privateAccess inst.$field;
							case macro this:
								macro @:pos(e.pos) @:privateAccess inst;
							default:
								e.map(subst);
						}

					var stories = [];

					for (field in fields) {
						var fname = field.name;
						var name = switch field.meta.extract(':story') {
							case []:
								continue;
							case [{params: []}]:
								macro $v{fname} case [{params: [v]}]:
								subst(v);
							case [{pos: pos}]:
								pos.error('Expected zero or one parameter');
							case v:
								v[0].pos.error('Multiple @:story metadata is not supported');
						}

						var parameters = [
							for (parameter in field.meta.extract(':parameter'))
								for (e in parameter.params)
									subst(e)
						];
						
						var decorators = [
							for (decorator in field.meta.extract(':decorator'))
								for (e in decorator.params)
									subst(e)
						];
						
						var merges = parameters.copy();
						if(decorators.length > 0) merges.push(macro {decorators: $a{decorators}});
						
						var args = [name, macro @:privateAccess inst.$fname];
						if(merges.length > 0) args.push(macro tink.Anon.merge($a{merges}));
						stories.push(macro api.add($a{args}));
					}

					var title = switch meta.extract(':title') {
						case []:
							macro $v{pack.concat([cname]).join('/')} case [{params: [v]}]:
							subst(v);
						case [{pos: pos}]:
							pos.error('Expected exactly one parameter');
						case v:
							v[0].pos.error('Multiple @:title metadata is not supported');
					}

					var setup = [macro var api:Dynamic = storiesOf($title, untyped module)];

					for (decorator in meta.extract(':decorator'))
						for (e in decorator.params)
							setup.push(macro api.addDecorator(${subst(e)}));

					var parameters = [
						for (parameter in meta.extract(':parameter'))
							for (e in parameter.params)
								subst(e)
					];
					if(parameters.length > 0)
						setup.push(macro api.addParameters(tink.Anon.merge($a{parameters})));

					ret.push(macro {
						var inst = $expr;
						@:mergeBlock $b{setup};
						@:mergeBlock $b{stories};
					});
				case _:
					expr.pos.error('Type not supported');
			}
		}

		return macro {
			var storiesOf = js.Lib.require("@storybook/react").storiesOf;
			$b{ret}
		};
	}
}
