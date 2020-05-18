package;

import coconut.storybook.*;

class Demo {
	static function main() {
		Storybook.add(new Button(), new foo.Bar());
	}
}

class Button extends Component {
	@:story
	function withText() '
		<button>Hello Button</button>
	';
	
	@:story
	function withEmoji() '
		<button>
			<span role="img" aria-label="so cool">
				😀 😎 👍 💯
			</span>
		</button>
	';
}