package ;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class Section
{
	static inline var TILE_OFFSET_X:Int = -32;
	static inline var TILE_GFX_WIDTH:Int = 128;
	static inline var TILE_GFX_HEIGHT:Int = 96; //Full block (64h + 32d) - fraction is 48 (16h + 32d)
	static inline var TILE_DEPTH:Int = 32;
	
	// static inline var COLLIDER_OFFSET_X:Int = 16;
	static inline var COLLIDER_OFFSET_X:Int = 32;

	// static inline var COLLIDER_OFFSET_Y:Int = 64;
	// static inline var COLLIDER_OFFSET_Y:Int = 60;
	static inline var COLLIDER_OFFSET_Y:Int = 48;

	// static inline var COLLIDER_WIDTH:Int = 96;
	static inline var COLLIDER_WIDTH:Int = 64;
	// static inline var COLLIDER_HEIGHT:Int = 4;
	static inline var COLLIDER_HEIGHT:Int = 32;
	
	public var stacks:Array<Stack>;
	
	var destinationX:Float;
	var destinationY:Float;
	public var bounds:FlxObject;
	
	public var id:Int;
	public var x:Float;
	public var y:Float;
	public var width:Int;
	public var height:Int;
	
	public var rows:Int;
	public var columns:Int;
	
	public var colliders:FlxTypedGroup<FlxObject>;
	
	public function new(x:Float, y:Float, columns:Int, rows:Int)
	{
		this.x = x;
		this.y = y;
		this.columns = columns;
		this.rows = rows;
		init();
	}
	
	function init() 
	{
		id = 0;
		
		colliders = new FlxTypedGroup<FlxObject>();
		
		stacks = new Array<Stack>();
		var column:Int = columns - 1;
		for (row in 0...rows) {
			column = columns - 1;
			while (column > -1) {
				
				var stack = new Stack();
				stack.column = column;
				stack.row = row;
				
				//Tile position
				destinationX = (column * TILE_GFX_WIDTH) + (column * TILE_OFFSET_X) - TILE_OFFSET_X * row;
				destinationY = TILE_DEPTH * row;
				
				var tile = new Tile(destinationX, destinationY);
				stack.add(tile);
				
				var colRow:String = Std.string(column + 1) + Std.string(row + 1);
				//tile.ID = Std.parseInt(colRow);
				setTileAnimation(stack, 0);
				
				//FlxObject colliders
				// var collider = new FlxObject(destinationX + COLLIDER_OFFSET_X, destinationY + COLLIDER_OFFSET_Y, TILE_GFX_WIDTH / 3, COLLIDER_HEIGHT);
				var collider = new FlxObject(destinationX + COLLIDER_OFFSET_X, destinationY + COLLIDER_OFFSET_Y, COLLIDER_WIDTH, COLLIDER_HEIGHT);
				
				#if debug
				collider.debugBoundingBoxColor = FlxColor.GREEN;
				#end
				collider.immovable = true;
				colliders.add(collider);
				stacks.push(stack);
				
				stack.ID = collider.ID = tile.ID = stacks.length - 1;
				
				column--;
			}
		}
		
		//Setting Width and Height
		var topLeft = FlxPoint.get(getStack(0, 0).root.x, getStack(0, 0).root.y);
		width = Std.int(topLeft.x + ((columns - 1) * TILE_GFX_WIDTH) + ((columns - 1) * TILE_OFFSET_X) - TILE_OFFSET_X * (rows - 1) + TILE_GFX_WIDTH);
		height = Std.int(topLeft.y + TILE_DEPTH * (rows - 1) + TILE_GFX_HEIGHT);
		
		bounds = new FlxObject(topLeft.x, topLeft.y, width, height);
		#if debug
		bounds.debugBoundingBoxColor = FlxColor.YELLOW;
		#end
	}
	
	public function changeSection()
	{
		// clearSection();
		
		var stackCount:Int = 0;
		for (i in 0...rows) {
			var col = columns - 1;
			while (col > -1) {
				
				var stack = stacks[stackCount];
				// setTileAnimation(stack, 3);
				
				setTileAnimation(stack, FlxG.random.int(0, 3));
				
				colliders.members[stack.ID].y = stack.root.y - stack.height + COLLIDER_OFFSET_Y + 16;
				
				stackCount++;
				col--;
			}
		}
	}
	
	public function shiftStacks(continuous:Bool)
	{
		for (stack in stacks) {
			var amount:Float = FlxG.random.int(0, Std.int(stack.height / 16)) * 16;
			amount = FlxG.random.bool() ? amount : amount * -1;
			stack.shiftHeight(amount, FlxG.random.float(0.3, 1), FlxG.random.float(0.15, 0.3), continuous);
		}
	}

	public function clearSection()
	{
		for (stack in stacks) {
			for (member in stack.members) {
				stack.remove(member);
			}
		}
	}
	
	public function clearStack(stack:Stack) {
		for (member in stack.members) {
			stack.remove(member);
		}
	}
	
	public function addTo(group:FlxGroup)
	{
		for (i in 0...stacks.length) {
			group.add(stacks[i]);
			group.add(stacks[i].temporary);
		}
	}
	
	public function removeFrom(group:FlxGroup)
	{
		for (stack in stacks)
			group.remove(stack);
	}
	
	public function setPosition(newX:Float, newY:Float)
	{
		var stackCount:Int = 0;
		for (i in 0...rows) {
			var col = columns - 1;
			while (col > -1) {
				var stack = stacks[stackCount];
				
				destinationX = (col * TILE_GFX_WIDTH) + (col * TILE_OFFSET_X) - (TILE_OFFSET_X * i);
				destinationY = TILE_DEPTH * i;
				
				colliders.members[stackCount].setPosition(newX + destinationX + COLLIDER_OFFSET_X, newY + destinationY + COLLIDER_OFFSET_Y);
				
				for (j in 0...stack.members.length) {
					stack.members[j].setPosition(newX + destinationX, newY + destinationY);
				}
				
				stackCount++;
				col--;
			}
		}
		
		//Update bounds
		bounds.setPosition(getStack(0, 0).root.x, getStack(0, 0).root.y);
	}
	
	public function getStack(col:Int, row:Int):Stack
	{
		var invCol = (col - (columns - 1)) * -1;
		var stack = stacks[row * columns + invCol];
/*		if (stack == null)
			trace('Cannot retrieve stack - id ${row * columns + invCol} is out of bounds!');*/
			
		return stack;
	}
	
	public function getStackById(id:Int):Stack
	{
		if (stacks[id] != null) {
			return stacks[id];
		} else {
			//trace('Cannot retrieve stack - id $id is out of bounds!');
			return null;
		}
	}
	
	//Warning: Might return null
	public function getAdjacentTiles(col:Int, row:Int):Array<Stack>
	{
		var top:Stack = null;
		var right:Stack = null;
		var bottom:Stack = null;
		var left:Stack = null;
		
		//TOP
		if (row > 0) {
			var invCol = (col - (columns - 1)) * -1;
			top = stacks[(row - 1) * columns + invCol];
		}
			
		//RIGHT
		if (col < columns - 1) {
			var invCol = ((col + 1) - (columns - 1)) * -1;
			right = stacks[row * columns + invCol];
		}
		
		//BOTTOM
		if (row < rows - 1) {
			var invCol = (col - (columns - 1)) * -1;
			bottom = stacks[(row + 1) * columns + invCol];
		}
			
		//LEFT
		if (col > 0) {
			var invCol = ((col - 1) - (columns - 1)) * -1;
			left = stacks[row * columns + invCol];
		}
		
		return [top, right, bottom, left];
	}
	
	public function setTile(stack:Stack, id:Int, col:Int, row:Int, decos:Array<String>)
	{
		var invCol = (col - (columns - 1)) * -1;
		setTileAnimation(stack, id);
	}
	
	public function setTileAnimation(stack:Stack, id:Int):FlxSprite
	{
		switch (id) {
			case 0:
				stack.root.playAnimation(0);
				stack.height = 16;
			case 1:
				stack.root.playAnimation(1);
				stack.height = 32;
			case 2:
				stack.root.playAnimation(2);
				stack.height = 48;
			case 3:
				stack.root.playAnimation(3);
				stack.height = 64;
			default:
				stack.root.playAnimation(0);
				stack.height = 16;
		}
		
		return null;
	}
}