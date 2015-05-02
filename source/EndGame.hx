package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class EndGame extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		bgColor = FlxColor.BLACK;
		
		var gameOver:FlxText = new FlxText(0, FlxG.height / 2 - 100, FlxG.width, 'Congratulations!', 36);
		gameOver.alignment = FlxTextAlign.CENTER;
		gameOver.scrollFactor.set(0, 0);
		add(gameOver);
		
		var subTitle:FlxText = new FlxText(0, FlxG.height / 2 + 50, FlxG.width, 'You beat the game!\nPress the left mouse button to return to menu', 20);
		subTitle.alignment = FlxTextAlign.CENTER;
		subTitle.scrollFactor.set(0, 0);
		add(subTitle);
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.mouse.justPressed) {
			FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function () { FlxG.switchState(new MainMenu()); } );
		}
	}
}
