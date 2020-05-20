package;

import coconut.storybook.*;
import react.ReactComponent;

class Demo {
	static function main() {
		Storybook.add(new Button(), new foo.Bar());
	}
}


@:parameter({note: 'component note'}, foo = 1)
@:parameter(bar = 2)
class Button extends Component {
	@:story
	function withText() '
		<button>Hello Button</button>
	';
	
	@:story
	@:decorator(this.wrap)
	@:parameter({note: 'story note'})
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