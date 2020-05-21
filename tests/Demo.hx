package;

import coconut.storybook.*;
import coconut.ui.*;

class Demo {
	static function main() {
		Storybook.add(new Button(), new foo.Bar());
	}
}

@:parameter({note: 'component note'}, foo = 1)
@:parameter(bar = 2)
@:decorator(Knobs.withKnobs)
class Button extends Component {
	@:story
	function withText() '
		<button disabled=${Knobs.boolean('Disabled', false)}>${Knobs.text('Text', 'Hello Button')}</button>
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
	
	function wrap(f:()->RenderResult) '
		<div style=${{backgroundColor: 'black'}}>${f()}</div>
	';
}

@:jsRequire('@storybook/addon-knobs')
extern class Knobs {
	static function withKnobs(f:()->RenderResult):RenderResult;
	static function boolean(name:String, value:Bool):Bool;
	static function text(name:String, value:String):String;
}