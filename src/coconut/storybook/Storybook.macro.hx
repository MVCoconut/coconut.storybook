package coconut.storybook;

import haxe.macro.Expr;
import haxe.macro.Context;

using tink.MacroApi;

class Storybook {
	public static macro function add(exprs:Array<Expr>):Expr {
		var ret = [];
		
		for(expr in exprs) {
			switch Context.typeof(expr) {
				case TInst(_.get() => {pack: pack, name: cname, meta: meta, fields: _.get() => fields}, _):
					
					function subst(e:Expr)
						return switch e {
							case macro this.$field: 
								macro @:pos(e.pos) @:privateAccess inst.$field;
							case macro this: 
								macro @:pos(e.pos) @:privateAccess inst;
							default:
								e.map(subst);
						}
						
				
					var stories = [for(field in fields) {
						var fname = field.name;
						switch field.meta.extract(':story') {
							case []:
								continue;
							case [{params: []}]:
								macro api.add($v{fname}, @:privateAccess inst.$fname);
							case [{params: [name]}]:
								macro api.add(${subst(name)}, @:privateAccess inst.$fname);
							case [{pos: pos}]:
								pos.error('Expected zero or one parameter');
							case v:
								v[0].pos.error('Multiple @:story metadata is not supported');
						}
					}];
					
					var title = switch meta.extract(':title') {
						case []:
							macro $v{pack.concat([cname]).join('/')}
						case [{params: [v]}]:
							subst(v);
						case [{pos: pos}]:
							pos.error('Expected exactly one parameter');
						case v:
							v[0].pos.error('Multiple @:title metadata is not supported');
					}
					ret.push(macro {
						var inst = $expr;
						var api = storiesOf($title, untyped module);
						$b{stories}
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