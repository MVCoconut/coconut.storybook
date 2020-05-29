package coconut.storybook;

@:autoBuild(coconut.storybook.Component.build())
class Component {
	public function new() {}

	macro function hxx(e);

	@:noCompletion static macro function unwrapState(e);
}
