package;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class Shadow extends FlxSprite
{

	public function new(X:Float = 0, Y:Float = 0) 
	{
		super(X, Y);
		
		init();
	}
	
	function init() 
	{
		makeGraphic(48, 16, FlxColor.TRANSPARENT);
		
		FlxSpriteUtil.drawEllipse(this, 0, 0, 48, 16, 0x000000);
		
		alpha = 0.5;
		
		maxVelocity.set(0, 300);
	}
	
}