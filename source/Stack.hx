package ;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class Stack extends FlxTypedGroup<Tile>
{
	//Height is the sum of the heights of all stacked tiles.
	public var height:Int;
	public var root:Tile;
	
	public var column:Int;
	public var row:Int;

	public var temporary:FlxTypedGroup<FlxSprite>;
	
	public var hasEnemy:Bool;
	public var hasPlayer:Bool;
	
	public var hasDoor:Bool;
	
	public function new() 
	{
		height = 0;
		
		hasEnemy = hasPlayer = hasDoor = false;
		temporary = new FlxTypedGroup<FlxSprite>();

		super();
	}
	
	override public function add(Object:Tile):Tile
	{
		//Position the new object correctly over the others

		if (members.length > 0) {
			//Root member defines X
			Object.x = members[0].x;

			//Object could be placed higher than final position and fall into place.
			Object.y = members[0].y - height;
		} else {
			root = Object;
			root.active = false;
		}

		height += Object.tileHeight;
		
		Object.ID = this.ID;

		super.add(Object);

		return Object;
	}

	public function shiftHeight(amount:Float, time:Float, delay:Float, continuous:Bool)
	{
		if (continuous) {
			FlxTween.tween(root, { y:root.y + amount }, time, { type:FlxTween.PINGPONG, startDelay:delay, ease:FlxEase.sineOut } );
			FlxTween.tween(Config.section.colliders.members[ID], { y:Config.section.colliders.members[ID].y + amount }, time, { type:FlxTween.PINGPONG, startDelay:delay, ease:FlxEase.sineOut } );
		} else {
			FlxTween.tween(root, { y:root.y + amount }, time, { type:FlxTween.ONESHOT, startDelay:delay, ease:FlxEase.sineOut } );
			FlxTween.tween(Config.section.colliders.members[ID], { y:Config.section.colliders.members[ID].y + amount }, time, { type:FlxTween.ONESHOT, startDelay:delay, ease:FlxEase.sineOut } );
		}
	}

	public function addTemporary(Object:FlxSprite, makeFall:Bool, isPlayer:Bool)
	{
		if (makeFall)
			Object.setPosition(root.x + 32, root.y - FlxG.height);
		else
			Object.setPosition(root.x + 32, root.y + 24 - Object.height);
			
		if (isPlayer) {
			hasPlayer = true;
			//temporary.add(cast(Object, Player).shadow);
		} else {
			hasEnemy = true;
			//temporary.add(cast(Object, Enemy).shadow);
		}
			
		Object.ID = ID;
		temporary.add(Object);
	}
	
	public function addDoor(door:FlxSprite)
	{
		door.setPosition(root.x, root.y - height - 12);
		door.active = false;
		door.ID = ID;
		temporary.add(door);
		
		hasDoor = true;
	}
	
	public function removeTemporary(Object:FlxSprite, isPlayer:Bool)
	{
		temporary.remove(Object);
		
		if (isPlayer) {
			hasPlayer = false;
			temporary.remove(cast(Object, Player).shadow);
		} else {
			hasEnemy = false;
			temporary.remove(cast(Object, Enemy).shadow);
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		for (object in temporary.members) {
			if (object != null && object.active) {
				if (object.y < Config.section.colliders.members[ID].y + 24 - object.height) {
					if (Config.section.colliders.members[ID].y + 24 - object.height - object.y < 5) {
						object.y = Config.section.colliders.members[ID].y + 24 - object.height;
						object.acceleration.y = 0;
						object.velocity.y = 0;
					} else {
						object.velocity.y = 300;
						//object.acceleration.y = 600;
					}
				} else if (object.y > Config.section.colliders.members[ID].y + 24 - object.height) {
					if (object.y - Config.section.colliders.members[ID].y + 24 - object.height < 5) {
						object.y = Config.section.colliders.members[ID].y + 24 - object.height;
						object.acceleration.y = 0;
						object.velocity.y = 0;
					} else {
						object.velocity.y = -300;
						//object.acceleration.y = -600;
					}
				} else {
					object.velocity.y = 0;
					//object.acceleration.y = 0;
				}
			}
		}
	}
	
	
}