package coconut.storybook;

import haxe.macro.Expr;
import coconut.ui.*;

class Storybook {
	public static macro function add(exprs:Array<Expr>):Expr;

	public static macro function getDefaultFramework():Expr;
}

extern class Api {
	function addDecorator(f:Decorator):Api;
	function addParameters(v:{}):Api;
	// @:overload(function(name:String, render:() -> RenderResult):Api {})
	function add(name:String, render:() -> RenderResult, ?params:{}):Api;
}
