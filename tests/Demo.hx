package;

import coconut.storybook.*;
import coconut.ui.*;

class Demo {
	static function main() {
		Storybook.add([
			// @formatter:off
			new Button(),
			new foo.Bar(),
			// @formatter:on
		]);
	}
}

@:parameter({note: 'component note'}, foo = 1)
@:parameter(bar = 2)
@:decorator(Knobs.withKnobs)
class Button extends Component {
	// @formatter:off
	@:story
	function withText() '
		<button disabled=${Knobs.boolean('Disabled', false)}>${Knobs.text('Text', 'Hello Button')}</button>
	';
	
	@:story
	@:decorator(this.wrap)
	@:parameter({note: 'story note'}, foo = 1)
	@:parameter(bar = 2)
	function withEmoji() '
		<button>
			<span role="img" aria-label="so cool">
				😀 😎 👍 💯
			</span>
		</button>
	';
	
	@:story
	@:state(var value:Int = 0)
	function withState() '
		<button onclick=${value += 1}>
			Clicked ${value} time(s)
		</button>
	';
	
	function wrap(f:()->RenderResult) '
		<div style=${{backgroundColor: 'black'}}>${f()}</div>
	';
	// @formatter:on
}

@:jsRequire('@storybook/addon-knobs')
extern class Knobs {
	static function withKnobs(f:() -> RenderResult):RenderResult;
	static function boolean(name:String, value:Bool):Bool;
	static function text(name:String, value:String):String;
}

class Isolated extends View {
	@:attribute var children:Children;

	function render()
		'<>${...children}</>';
}
