package coconut.storybook;

import haxe.macro.Expr;

class Storybook {
	public static macro function add(exprs:Array<Expr>):Expr;
	public static macro function getDefaultFramework():Expr;
}