package coconut.storybook;

import haxe.macro.Context;
import haxe.macro.Expr;

using tink.MacroApi;

class Component {
	public static function build() {
		var builder = new ClassBuilder();

		if (!builder.target.meta.has(':tink'))
			builder.target.meta.add(':tink', [], Context.currentPos());

		if (!builder.target.meta.has(':storybook'))
			builder.target.meta.add(':storybook', [], Context.currentPos());

		return null;
	}

	macro function hxx(ethis, e)
		return macro @:pos(e.pos) coconut.Ui.hxx($e);

	static function unwrapState(e)
		return switch Context.getExpectedType() {
			case null:
				e;
			case Context.unify(_, Context.getType('tink.state.Observable')) => true:
				e;
			default:
				macro @:pos(e.pos) $e.value;
		}
}
