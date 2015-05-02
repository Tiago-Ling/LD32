package;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class DimensionalDoor extends FlxSprite
{
	public function new(X:Float = 0, Y:Float = 0) 
	{
		super(X, Y);
		
		init();
	}
	
	function init() 
	{
		loadGraphic(AssetPaths.Dimensional_door__png);
		
		kill();
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		//if (shadow != null)
			//shadow.setPosition(this.x, this.x + this.height);
	}
	
}