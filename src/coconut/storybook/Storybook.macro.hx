package coconut.storybook;

import haxe.macro.Expr;
import haxe.macro.Context;

using tink.MacroApi;

class Storybook {
	public static macro function add(exprs:Array<Expr>):Expr {
		var ret = [];
		
		for(expr in exprs) {
			switch Context.typeof(expr) {
				case TInst(_.get() => {pack: pack, name: cname, fields: _.get() => fields}, _):
					
					var stories = [for(field in fields) {
						if(field.meta.has(':story')) {
							var fname = field.name;
							macro api.add($v{fname}, @:privateAccess inst.$fname);
						}
					}];
					
					var path = pack.concat([cname]).join('/');
					ret.push(macro {
						var inst = $expr;
						var api = js.Lib.require('@storybook/react').storiesOf($v{path}, untyped module);
						$b{stories}
					});
				case _:
					expr.pos.error('Type not supported');
			}
		}
		
		return macro $b{ret};
	}
}