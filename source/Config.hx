package;

import flixel.util.FlxSave;

class Config
{
	public static var TILE_DEPTH:Int = 32;

	public static var section:Section = null;
	
	public static var state:Game = null;
	
	public static var playerLife:Float = 100;
	
	public static var currentLevel:Int = 0;
	public static var levelColumns:Array<Int> = [4, 6, 10, 12, 15];
	public static var levelRows:Array<Int> = [4, 6, 12, 12, 15];
	public static var levelEnemies:Array<Int> = [2, 4, 8, 16, 20];
}