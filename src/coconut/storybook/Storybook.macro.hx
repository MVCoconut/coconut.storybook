package coconut.storybook;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;

using tink.MacroApi;

class Storybook {
	public static macro function add(exprs:Array<Expr>):Expr {
		switch exprs {
			case [{expr: EArrayDecl(values)}]:
				exprs = values;
			case _:
		}

		var ret = [];

		for (expr in exprs) {
			switch Context.typeof(expr) {
				case TInst(_.get() => cls = {
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
									macro @:pos(e.pos) (${subst(e)} : coconut.storybook.Decorator)
						];

						var merges = parameters.copy();
						if (decorators.length > 0)
							merges.push(macro {decorators: $a{decorators}});

						// storybook args: https://storybook.js.org/docs/react/writing-stories/args
						(function addArgs(type:Type) {
							switch type {
								case TFun([], _):
								case TFun(v, _):
									final argsType = v[0].t; // first argument the storybook-provided "args"
									final argsCt = argsType.toComplex();
									switch argsType.reduce() {
										case TAnonymous(_.get() => anon):
											final args = [];
											final argTypes = [];
											final argsObj = EObjectDecl(args); // type inference
											final argTypesObj = EObjectDecl(argTypes); // type inference

											for (f in anon.fields) {
												inline function addArg(e)
													args.push({field: f.name, expr: e});
												inline function addArgType(e)
													argTypes.push({field: f.name, expr: e});

												addArg(switch f.meta.extract(':default') {
													case []:
														macro null;
													case [{params: [e]}]:
														e;
													case [v]:
														v.pos.error('@:default meta should have exactly one parameter');
													case m:
														m[0].pos.error('Multiple @:default meta is not supported');
												});

												// TODO: add more argType fields: https://storybook.js.org/docs/react/api/argtypes
												switch f.meta.extract(':control') {
													case [] | [{params: []}]:
														// infer control type from haxe type
														switch f.type {
															case _.getID() => 'String':
																addArgType(macro {control: {type: 'text'}});
															case _.getID() => 'Bool':
																addArgType(macro {control: {type: 'boolean'}});
															case _.getID() => 'Int' | 'Float':
																addArgType(macro {control: {type: 'number'}});
															case TInst(_.get() => {pack: [], name: 'Array'}, [_.getID() => 'String']):
																addArgType(macro {control: {type: 'array'}});
															case _:
																addArgType(macro {control: {type: 'object'}});
														}
													case [{params: [e = {expr: EConst(CString(v))}]}]:
														// treat string literal as control type
														addArgType(macro {control: {type: $e}});
													case [{params: [e]}]:
														// anything else is passed as-is
														addArgType(macro {control: $e});
													case [v]:
														v.pos.error('@:control meta should have at most one parameter');
													case m:
														m[0].pos.error('Multiple @:control meta is not supported');
												}
											}

											if (args.length > 0 || argTypes.length > 0) {
												merges.push(macro {
													__isArgsStory: true,
													args: (${argsObj.at(field.pos)} : $argsCt), // type check to make sure correctness of default values
													argTypes: ${argTypesObj.at(field.pos)},
												});
											}
										case t:
											trace(t);
									}

								case TLazy(f):
									addArgs(f());
								case t:
									field.pos.error('@:story is only applicable to function but got (${t})');
							}
						})(field.type);

						var args = [name, macro @:privateAccess inst.$fname];
						if (merges.length > 0)
							args.push(macro(tink.Anon.merge($a{merges}) : Dynamic));
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

					var setup = [
						macro var api:coconut.storybook.Storybook.Api = storiesOf($title, untyped module)
					];

					for (decorator in getMetaRecursive(cls, ':decorator'))
						for (e in decorator.params)
							setup.push(macro api.addDecorator(${subst(e)}));

					var parameters = [
						for (parameter in getMetaRecursive(cls, ':parameter'))
							for (e in parameter.params)
								subst(e)
					];

					if (parameters.length > 0)
						setup.push(macro api.addParameters((tink.Anon.merge($a{parameters}) : Dynamic)));

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
			var storiesOf = js.Lib.require(coconut.storybook.Storybook.getDefaultFramework()).storiesOf;

			$b{ret}
		};
	}

	static function getMetaRecursive(c:ClassType, name:String) {
		var decorators = c.meta.extract(name);
		switch c.superClass {
			case null:
			case sc:
				decorators = decorators.concat(getMetaRecursive(sc.t.get(), name));
		}
		return decorators;
	}

	public static macro function getDefaultFramework():Expr {
		return if (Context.defined('coconut.vdom')) {
			macro 'storybook-coconut'; // '@storybook/coconut';
		} else if (Context.defined('coconut.react-dom')) {
			macro '@storybook/react';
		} else {
			macro $v{Context.definedValue('storybook.framework')}
		}
	}
}
