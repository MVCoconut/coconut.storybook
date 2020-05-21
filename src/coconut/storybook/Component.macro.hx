package coconut.storybook;

import haxe.macro.Context;

using tink.MacroApi;

class Component {
	public static function build() {
		var builder = new ClassBuilder();
		if (!builder.target.meta.has(':tink'))
			builder.target.meta.add(':tink', [], Context.currentPos());
		return null;
	}

	macro function hxx(ethis, e)
		return macro coconut.Ui.hxx($e);
}
