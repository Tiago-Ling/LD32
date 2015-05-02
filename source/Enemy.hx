package ;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;
import flixel.FlxG;

class Enemy extends FlxSprite
{
	public var dirX:Int;
	public var dirY:Int;
	var path:FlxPath;
	var isWalking:Bool;
	
	public var onPlayerHands:Bool;
	
	public var shadow:Shadow;

	public function new (X:Float = 0, Y:Float = 0)
	{
		super(X, Y);

		init();
	}

	function init()
	{
		loadGraphic(AssetPaths.enemy__png, false);
		
		onPlayerHands = false;
		
		offset.y = 36;
		this.height -= 36;
		
		isWalking = false;
		path = new FlxPath();
		
		maxVelocity.set(0, 300);
		
		//shadow = new Shadow(this.x, this.y);
		
		kill();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
/*		if (shadow != null)
			shadow.setPosition(this.x, this.x + this.height);*/
	}
	
	public function changePosition()
	{
		var stack = Config.section.getStackById(ID);
		
		//Check if player is nearby and chase him
		var adjacentStacks:Array<Stack> = Config.section.getAdjacentTiles(stack.column, stack.row);
		
		//First check if the player is in an adjacent stack
		for (tempStack in adjacentStacks) {
			if (tempStack != null && tempStack.hasPlayer) {
				stack.removeTemporary(this, false);
				Config.state.add(this);
				attack(tempStack);
				return;
			}
		}
		
		//Checking distance from player
		var distX:Int = Std.int(Math.abs(Config.state.currentPlayerStack.column - stack.column));
		var distY:Int = Std.int(Math.abs(Config.state.currentPlayerStack.row - stack.row));
		var distance:Int = distX + distY;
		if (distance < 5) {
			if (Config.state.currentPlayerStack.row < stack.row && adjacentStacks[0] != null && !adjacentStacks[0].hasDoor) {
				//Go up
				stack.removeTemporary(this, false);
				Config.state.add(this);
				jumpTo(adjacentStacks[0]);
			} else if (Config.state.currentPlayerStack.column > stack.column && adjacentStacks[1] != null && !adjacentStacks[1].hasDoor) {
				//Go right
				stack.removeTemporary(this, false);
				Config.state.add(this);
				jumpTo(adjacentStacks[1]);
			} else if (Config.state.currentPlayerStack.row > stack.row && adjacentStacks[2] != null && !adjacentStacks[2].hasDoor) {
				//Go down
				stack.removeTemporary(this, false);
				Config.state.add(this);
				jumpTo(adjacentStacks[2]);
			} else if (Config.state.currentPlayerStack.column < stack.column && adjacentStacks[3] != null && !adjacentStacks[3].hasDoor) {
				stack.removeTemporary(this, false);
				Config.state.add(this);
				jumpTo(adjacentStacks[3]);
			} else {
				//Don't move
				//trace('Gonna wait this turn');
			}
		} else {
			//Go random (really crappy check, but will have to do
			for (randomStack in adjacentStacks) {
				if (randomStack != null && !randomStack.hasDoor && FlxG.random.bool(25)) {
					stack.removeTemporary(this, false);
					Config.state.add(this);
					jumpTo(randomStack);
				}
			}
		}
	}
	
	public function jumpTo(newStack:Stack)
	{
		var newX = newStack.root.x;
		var newY = newStack.root.y + 24 - this.height * 2;
		var shadowY = newStack.root.y + 24;
		//this.velocity.y = -100;
		
		var delay:Float = FlxG.random.float(0, 0.3);
		//FlxTween.tween(shadow, { x:newX, y:shadowY }, 0.3, { type:FlxTween.ONESHOT, ease:null, startDelay:delay } );
		FlxTween.tween(this, {x:newX, y:newY}, 0.3, { type:FlxTween.ONESHOT, ease:null, startDelay:delay, onComplete:function (_) {
			Config.state.remove(this);
			newStack.addTemporary(this, false, false);
		}});
	}
	
	public function attack(newStack:Stack)
	{
		var newX = newStack.root.x;
		var newY = newStack.root.y + 24 - this.height * 2;
		var shadowY = newStack.root.y + 24;
		//this.velocity.y = -100;
		
		var delay:Float = FlxG.random.float(0, 0.3);
		//FlxTween.tween(shadow, { x:newX, y:shadowY }, 0.3, { type:FlxTween.ONESHOT, ease:null, startDelay:delay } );
		FlxTween.tween(this, {x:newX, y:newY}, 0.3, { type:FlxTween.ONESHOT, ease:null, startDelay:delay, onComplete:function (_) {
			
			Config.state.remove(this);
			
			//Inflict damage on player
			Config.state.player.health -= 20 + FlxG.random.int(0, 14);
			Config.state.playerHealth.text = 'Life : ${Config.state.player.health}';
			FlxG.camera.flash(FlxColor.RED, 0.2);
			
			Config.state.enemiesTotal--;
			Config.state.enemiesLeft.text = 'Enemies Left : ${Config.state.enemiesTotal}';
			
			FlxG.sound.play(AssetPaths.hit__wav, 0.5);
			
			//Destroy it
			kill();
		}});
	}
	
	public function getGrabbed()
	{
		onPlayerHands = true;
		
		flipY = true;
		active = false;
		
		FlxTween.tween(this, { y:y - 16 }, 0.3, { type:FlxTween.ONESHOT, ease:FlxEase.quintIn, startDelay:0.2 } );
	}

	function setDestination()
	{
		var destX:Float = FlxG.random.float(Config.section.bounds.x, Config.section.bounds.x + Config.section.bounds.width - this.width);
		var destY:Float = FlxG.random.float(Config.section.bounds.y + 16, Config.section.bounds.y + Config.section.bounds.height - this.height);

		var destination = FlxPoint.get(destX, destY);
		path.start(this, [destination], 80, FlxPath.FORWARD);
		path.onComplete = resetPath;

		isWalking = true;
	}

	function resetPath(path:FlxPath) 
	{
		isWalking = false;
		path.reset();
	}

}