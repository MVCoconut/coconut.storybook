package coconut.storybook;

import haxe.macro.Context;
import haxe.macro.Expr;
import tink.SyntaxHub;

using StringTools;
using tink.MacroApi;

class Setup {
	public static function setup() {
		var debug = false;
		SyntaxHub.classLevel.after('tink.lang.Sugar', builder -> {
			if (!builder.target.meta.has(':tink'))
				return false;

			for (field in builder)
				switch [field.kind, field.metaNamed(':story'), field.metaNamed(':state')] {
					case [FFun(func), stories, v] if (stories.length > 0):
						// wrap with Isolated, so changes will trigger re-render
						function subst(e:Expr)
							return switch e {
								case macro return hxx($v{(hxx : String)}):
									hxx = '<coconut.ui.Isolated>$hxx</coconut.ui.Isolated>';
									macro return hxx($v{hxx});
								case e:
									e;
							}
						func.expr = func.expr.map(subst);

						var init = [];

						// add states
						for (states in v)
							for (state in states.params)
								switch state.expr {
									case EVars(vars):
										for (v in vars) {
											if (v.expr == null)
												state.pos.error('@:state var ${v.name} requires a initializer');
											if (v.type == null)
												state.pos.error('@:state var ${v.name} requires a type hint');

											var name = v.name;
											var alias = getAlias(name);
											var ct = v.type;

											init.push(macro var $name = new tink.state.State<$ct>(${v.expr}));
											init.push(macro var $alias = $i{name});
										}

									case _:
										state.pos.error('Only supports EVars expressions');
								}

						func.expr = (macro $b{init}).concat(func.expr);

					case _:
						// skip
				}

			return true;
		});

		SyntaxHub.exprLevel.inward.after(_ -> true, {
			appliesTo: builder -> builder.target.meta.has(':storybook'),
			apply: (e:Expr) -> {
				function transform(name:String, original:Expr, transformed:Expr) {
					return switch Context.getLocalTVars()[name] {
						case null:
							original;
						case {t: _.getID() => 'tink.state.State'}:
							transformed;
						case _:
							original;
					}
				}

				switch e.expr {
					case EConst(CIdent(name)) if (!isAlias(name)):
						transform(name, e, macro @:pos(e.pos) coconut.storybook.Component.unwrapState($i{getAlias(name)}));

					case EBinop(OpAssign, macro $i{name}, rhs) if (!isAlias(name)):
						transform(name, e, macro $i{getAlias(name)}.set($rhs));

					case EBinop(OpAssignOp(binop), macro $i{name}, rhs) if (!isAlias(name)):
						var rhs = EBinop(binop, macro $i{getAlias(name)}.value, rhs).at(e.pos);
						transform(name, e, macro $i{getAlias(name)}.set($rhs));

					case _:
						e;
				}
			}
		});
	}

	inline static function getAlias(name:String) {
		return '__alias_${name}';
	}

	inline static function isAlias(name:String) {
		return name.startsWith('__alias_');
	}
}
