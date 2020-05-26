# Storybook support for Coconut

Storybook: https://storybook.js.org/

### Usage

First, setup Storybook according to the [official guide](https://storybook.js.org/docs/guides/guide-react/).

Note1: For coconut.vdom support, use the npm package "storybook-coconut" instead of "@storybook/react".
Note2: Multiple coconut target is not supported, that's limitation of storybook's architecture.

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
	@:decorator(this.wrap) // decorators
	@:parameter({note: 'component note'}, foo = 1) // parameters, expressions will be forwarded to `tink.Anon.merge`
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

### Note

`@:decorator` and `@:parameter` are supported at both component (class) and story (method) level.

In all the metadata, you can use explicit `this` to reference fields of the class instance. e.g. 
```haxe
@:title('Button: ' + this.variant)
class Button {
	public final variant:String;
}
```
