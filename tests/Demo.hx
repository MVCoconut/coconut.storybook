package;

import coconut.storybook.*;
import react.ReactComponent;

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
	@:decorator(this.wrap)
	function withEmoji() '
		<button>
			<span role="img" aria-label="so cool">
				😀 😎 👍 💯
			</span>
		</button>
	';
	
	function wrap(f:()->ReactSingleFragment) '
		<div style=${{backgroundColor: 'black'}}>${f()}</div>
	';
}