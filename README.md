# Storybook support for Coconut

Storybook: https://storybook.js.org/

### Usage

First, setup Storybook according to the [official guide](https://storybook.js.org/docs/guides/guide-react/).

Then...

`Main.hx`:
```haxe
import coconut.storybook.*;

static function main() {
	Storybook.add(new Button(), new AnotherComponent());
}

@:title('foo/Button') // optional title, default to full path of the class separated by a slash ("/")
class Button extends Component {
	@:story // functions tagged with @:story will be added to storybook
	function withText() '
		<button>Hello Button</button>
	';
	
	@:story('with emoji') // custom story name
	function withEmoji() '
		<button>
			<span role="img" aria-label="so cool">
				😀 😎 👍 💯
			</span>
		</button>
	';
}

class AnotherComponent extends Component {
	// ...
}
```

`.storybook/main.js`:
```js
module.exports = {
	stories: ['path/to/haxe/generated/output.js'],
	// ....
};
```