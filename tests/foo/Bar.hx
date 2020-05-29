package foo;

import coconut.storybook.*;

class Bar extends Component {
	@:story
	function withText() '
		<button>Hello Button</button>
	';

	@:story
	@:state(var value:Int = 0)
	function withControlled() '
		<Foo count=$value />
	';

	@:story('with emoji')
	function withEmoji() '
		<button>
			<span role="img" aria-label="so cool">
				😀 😎 👍 💯
			</span>
		</button>
	';
}

private class Foo extends coconut.ui.View {
	@:controlled var count:Int;

	function render() '
		<div>
		</div>
	';
}
