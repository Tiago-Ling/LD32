package;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class Player extends FlxSprite
{
	public var grabbedEnemy:Enemy;
	public var shadow:Shadow;
	
	public function new(X:Float = 0, Y:Float = 0) 
	{
		super(X, Y);
		
		init();
	}
	
	function init() 
	{
		grabbedEnemy = null;
		
		//makeGraphic(48, 72, FlxColor.YELLOW);
		loadGraphic(AssetPaths.char__png);
		
		offset.y = 64;
		this.height -= 64;
		
		maxVelocity.set(0, 300);
		
		health = Config.playerLife;
		
		//shadow = new Shadow(this.x, this.y);
	}
	
	public function jumpTo(newStack:Stack, onComplete:Void->Void)
	{
		var newX = newStack.root.x;
		//var newY = newStack.root.y + 24 - this.height;
		var newY = newStack.root.y + 24 - this.height * 2;
		
		//velocity.y = -300;
		
		FlxTween.tween(this, {x:newX, y:newY}, 0.3, { type:FlxTween.ONESHOT, ease:null, startDelay:0.1, onComplete:function (_) {
			Config.state.remove(this);
			newStack.addTemporary(this, false, true);
			onComplete();
		}});
		
		if (shadow != null) {
			FlxTween.tween(shadow, { x:newX, y:newY + 72 }, 0.3, { type:FlxTween.ONESHOT, ease:null, startDelay:0.1 } );
		}
		
		if (grabbedEnemy != null) {
			FlxTween.tween(grabbedEnemy, { x:newX, y:newY - 16 }, 0.3, { type:FlxTween.ONESHOT, ease:null, startDelay:0.1 } );
		}
	}
	
	public function grab(stack:Stack)
	{
		var oldX = this.x;
		var oldY = this.y;
		var newX = stack.root.x;
		var newY = stack.root.y + 24 - this.height;
		
		FlxTween.tween(this, { x:newX, y:newY }, 0.15, { type:FlxTween.ONESHOT, ease:FlxEase.sineOut, onComplete:function (_) {
			
			if (grabbedEnemy != null) {
				FlxTween.tween(grabbedEnemy, { x:newX, y:newY - 16 }, 0.2, { type:FlxTween.ONESHOT, ease:null, startDelay:0.1 } );
			}
			
			FlxTween.tween(this, { x:oldX, y:oldY }, 0.4, { type:FlxTween.ONESHOT, ease:FlxEase.sineIn, startDelay:0.3 } );
			FlxTween.tween(grabbedEnemy, { x:oldX, y:oldY - 16 }, 0.4, { type:FlxTween.ONESHOT, ease:FlxEase.sineIn, startDelay:0.3 } );
		}});
	}
		

	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		//if (shadow != null)
			//shadow.setPosition(this.x, this.x + this.height);
	}
	
}