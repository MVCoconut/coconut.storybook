package foo;

import coconut.storybook.*;

class Bar extends Component {
	@:story
	function withText() '
		<button>Hello Button</button>
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