package;
import flixel.FlxSprite;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class Tile extends FlxSprite
{
	public var tileHeight:Int;

	public function new(X:Float = 0, Y:Float = 0) 
	{
		super(X, Y);
		
		init();
	}
	
	function init() 
	{
		height = 0;

		loadGraphic(AssetPaths.tileset_b__png, true, 128, 96);
		animation.add('block_quarter', [0]);
		animation.add('block_half', [1]);
		animation.add('block_three_quarters', [2]);
		animation.add('block_full', [3]);

		playAnimation(0);

		#if debug
		ignoreDrawDebug = true;
		#end
	}
	
	public function playAnimation(id:Int)
	{
		switch (id) {
			case 0:
				animation.play('block_quarter');
				tileHeight = 16;
			case 1:
				animation.play('block_half');
				tileHeight = 32;
			case 2:
				animation.play('block_three_quarters');
				tileHeight = 48;
			case 3:
				animation.play('block_full');
				tileHeight = 64;
			default:
		}
	}
}