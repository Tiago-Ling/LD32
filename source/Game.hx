package;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseButton;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup;

/**
 * A FlxState which can be used for the game's menu.
 */
class Game extends FlxState
{
	public var player:Player;
	public var playerHealth:FlxText;
	public var enemiesLeft:flixel.text.FlxText;
	public var enemiesTotal:Int;
	
	var sec:Section;
	var enemies:FlxTypedGroup<Enemy>;

	var overlapGroup:FlxGroup;
	
	var startPlayerTurn:Bool;
	var isPlayerTurn:Bool;
	
	var turnTimer:FlxTimer;
	var stackSelection:Array<Stack>;
	var targetSelection:Array<Stack>;
	var grabSelection:Array<Stack>;
	
	var buttons:Array<FlxButton>;
	var currentPhase:Int;
	var door:DimensionalDoor;
	var enemyTimer:FlxTimer;
	var shiftTimer:FlxTimer;
	
	var canExitLevel:Bool;
	
	public var currentPlayerStack:Stack;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		Config.currentLevel = 3;
		
		Config.state = this;

		FlxG.log.redirectTraces = false;
		//FlxG.mouse.visible = false;
		
		#if debug
		FlxG.debugger.drawDebug = true;
		#end
		
		bgColor = 0xFF391065;
		
		startPlayerTurn = true;
		currentPhase = 0;
		enemiesTotal = 0;
		canExitLevel = false;
		
		var columns:Int = Config.levelColumns[Config.currentLevel];
		var rows:Int = Config.levelRows[Config.currentLevel];
		//var rows:Int = 1;
		sec = new Section(0, 240, columns, rows);
		sec.addTo(this);
		
		add(sec.colliders);
		add(sec.bounds);
		sec.changeSection();

		Config.section = sec;
		
		FlxG.camera.setScrollBoundsRect(0, -300, sec.bounds.width * 1.25, sec.bounds.height + 300);
		
		overlapGroup = new FlxGroup();

		var stack = sec.getStack(FlxG.random.int(0, sec.columns - 1), FlxG.random.int(0, sec.rows - 1));
		player = new Player(stack.root.x, stack.root.y);
		stack.addTemporary(player, true, true);
		currentPlayerStack = stack;
		currentPlayerStack.root.color = FlxColor.BLUE;
		
		overlapGroup.add(player);

		enemies = new FlxTypedGroup<Enemy>();
		for (i in 0...20) {
			enemies.add(new Enemy());
		}

		overlapGroup.add(enemies);

		enemyTimer = new FlxTimer();
		shiftTimer = new FlxTimer();
		
		turnTimer = new FlxTimer();
		
		stackSelection = new Array<Stack>();
		targetSelection = new Array<Stack>();
		grabSelection = new Array<Stack>();
		
		FlxG.plugins.add(new FlxMouseEventManager());
		
		FlxG.camera.follow(player, FlxCameraFollowStyle.TOPDOWN, null, 0.5);
		
		buttons = new Array<FlxButton>();
		
		var button = new FlxButton(10, 10, 'Move', function ( ) { if (currentPhase != 1) endCurrentPhase(); startMovePhase(); } );
		button.ID = 0;
		buttons.push(button);
		add(button);
		
		button = new FlxButton(10, 45, 'Attack', function () { if (currentPhase != 2) endCurrentPhase(); startAttackPhase(); } );
		button.ID = 1;
		buttons.push(button);
		add(button);
		
		button = new FlxButton(10, 80, 'Grab', function () { if (currentPhase != 3) endCurrentPhase(); startGrabPhase(); } );
		button.ID = 2;
		buttons.push(button);
		add(button);
		
		button = new FlxButton(10, 115, 'End', function () { endCurrentPhase(); endPlayerTurn(); } );
		button.ID = 3;
		buttons.push(button);
		add(button);
		
		playerHealth = new FlxText(230, 10, 200, 'Life : ${player.health}', 12);
		playerHealth.scrollFactor.set(0, 0);
		add(playerHealth);
		
		var gameLevel:FlxText = new FlxText(350, 10, 200, 'Level : ${Config.currentLevel + 1}', 12);
		gameLevel.scrollFactor.set(0, 0);
		add(gameLevel);
		
		enemiesLeft = new FlxText(470, 10, 200, 'Enemies Left : $enemiesTotal', 12);
		enemiesLeft.scrollFactor.set(0, 0);
		add(enemiesLeft);
		
		//Must use even numbers
		//enemiesTotal = Config.levelEnemies[Config.currentLevel];
		spawnEnemies(Config.levelEnemies[Config.currentLevel]);
		
		door = new DimensionalDoor();
	}
	
	public function spawnEnemies(number:Int)
	{
		for (i in 0...number) {
			var enemy = enemies.recycle();
			var stack = sec.getStack(FlxG.random.int(0, sec.columns - 1), FlxG.random.int(0, sec.rows - 1));
			if (enemy != null) {
				//Try once to not spawn a new enemy over other stuff
				if (stack.hasPlayer || stack.hasDoor || stack.hasEnemy)
					stack = sec.getStack(FlxG.random.int(0, sec.columns - 1), FlxG.random.int(0, sec.rows - 1));
					
				stack.addTemporary(enemy, true, false);
				enemy.revive();
				enemiesTotal++;
				enemiesLeft.text = 'Enemies Left : $enemiesTotal';
			}
		}
	}

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
		
/*		if (FlxG.keys.justPressed.SPACE) {
			sec.changeSection();
		}
		
		if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.resetState();
		}*/
		
/*		if (FlxG.keys.justPressed.E) {
			sec.shiftStacks(false);
		}*/
		
/*		if (FlxG.keys.justPressed.Q) {
			spawnEnemies(1);
		}
		
		if (FlxG.keys.justPressed.R) {
			var doorStack = sec.getStack(0, 0);
			if (doorStack != null) {
				doorStack.addDoor(door);
				door.revive();
			}
		}*/
		
		//Duh
		if (startPlayerTurn) {
			beginPlayerTurn();
		}
		
		if (enemiesTotal <= 0 && !door.alive) {
			//Place exit door
			var doorStack = sec.getStack(FlxG.random.int(0, sec.columns - 1), FlxG.random.int(0, sec.rows - 1));
			if (doorStack != null) {
				doorStack.addDoor(door);
				door.revive();
			}
			
			//Init timer to spawn enemies every X second
			enemyTimer.start(8, function (_) { spawnEnemies(3); }, 0);
			
			canExitLevel = true;
			
			//Init timer to shift cells (just to add drama)
			//shiftTimer.start(5, function (_) { sec.shiftStacks(false); }, 0 );
			
			//Show message telling player to run to the exit
			var subTitle:FlxText = new FlxText(0, FlxG.height / 2 - 100, FlxG.width, 'More enemies are coming!\nRun to the exit before they get you!', 22);
			subTitle.alignment = FlxTextAlign.CENTER;
			subTitle.scrollFactor.set(0, 0);
			add(subTitle);
			
			shiftTimer.start(4, function (_) { subTitle.kill(); }, 0 );
			
		}
		
		if (player.health <= 0) {
			FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function () { FlxG.switchState(new GameOver()); } );
		}
	}
	
	function playEnemyTurn()
	{
		for (button in buttons) {
			button.visible = false;
		}
		
		for (i in 0...enemies.length) {
			var enemy = enemies.members[i];
			if (enemy != null && enemy.alive && !enemy.onPlayerHands) {
				enemy.changePosition();
			}
		}
		turnTimer.start(0.6, function (_) { startPlayerTurn = true; }, 1);
	}
	
	function onMouseDown(target:FlxSprite)
	{
		
	}
	
	function onMouseUp(target:FlxSprite)
	{
		//Check which tile was clicked and only finish the turn if the player has moved
		//and attacked
		
		switch (currentPhase) {
			case 1:	//Move
				currentPlayerStack.removeTemporary(player, true);
				currentPlayerStack.root.color = FlxColor.WHITE;
				add(player);
				
				var newStack = sec.getStackById(target.ID); 
				FlxG.sound.play(AssetPaths.move__wav, 0.5);
				player.jumpTo(newStack, function () {
					target.color = FlxColor.WHITE;
					
					currentPlayerStack = newStack;
					
					endCurrentPhase();
					
					if (newStack.hasDoor && canExitLevel) {
						//Update level and restart
						Config.currentLevel++;
						if (Config.currentLevel > Config.levelEnemies.length - 1) {
							FlxG.sound.play(AssetPaths.level_end__wav, 0.5);
							FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function () { FlxG.switchState(new EndGame()); } );
						}
						
						Config.playerLife = player.health;
						FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function () { FlxG.resetState(); } );
					}
					
					//Check for grab possibility
					var adjacentStacks:Array<Stack> = sec.getAdjacentTiles(currentPlayerStack.column, currentPlayerStack.row);
					buttons[2].alpha = 0.5;
					for (stack in adjacentStacks) {
						if (stack != null && stack.hasEnemy)
							buttons[2].alpha = 1;
					}
				});
			case 2:	//Attack
				if (player.grabbedEnemy != null) {
					var targetStack = sec.getStackById(target.ID);
					if (targetStack != null) {
						var enemy = player.grabbedEnemy;
						player.grabbedEnemy = null;
						currentPlayerStack.removeTemporary(enemy, false);
						add(enemy);
						FlxTween.tween(enemy, { x:targetStack.root.x, y:targetStack.root.y }, 0.2, { type:FlxTween.ONESHOT, ease:null, onComplete:function (_) {
							//Destroy weapon enemy
							enemy.kill();
							enemiesTotal--;
							enemiesLeft.text = 'Enemies Left : $enemiesTotal';
							
							//Destroy target enemy
							if (targetStack.hasEnemy) {
								targetStack.temporary.members[0].kill();
								targetStack.hasEnemy = false;
								enemiesTotal--;
								enemiesLeft.text = 'Enemies Left : $enemiesTotal';
								FlxG.camera.flash(FlxColor.YELLOW, 0.2);
								FlxG.sound.play(AssetPaths.hit__wav, 0.5);
							}
						}} );
						
						endCurrentPhase();
					}
				}
			case 3:	//Grab
				var newStack = sec.getStackById(target.ID);
				player.grab(newStack);
				
				//Attach enemy to player
				player.grabbedEnemy = cast(newStack.temporary.members[0], Enemy);
				player.grabbedEnemy.getGrabbed();
				
				newStack.removeTemporary(player.grabbedEnemy, false);
				currentPlayerStack.addTemporary(player.grabbedEnemy, false, false);
				
				FlxG.sound.play(AssetPaths.grab__wav, 0.5);
				
				endCurrentPhase();
				
				//Check for attack possibility
				if (player.grabbedEnemy == null)
					buttons[1].alpha = 0.5;
				else
					buttons[1].alpha = 1;
			
			default:
				
		}
	}
	
	function onMouseOver(target:FlxSprite)
	{
		switch (currentPhase) {
			case 1:
				target.color = FlxColor.GREEN;
			case 2:
				target.color = FlxColor.RED;
			case 3:
				target.color = FlxColor.YELLOW;
			default:
		}
	}
	
	function onMouseOut(target:FlxSprite)
	{
		switch (currentPhase) {
			case 1:
				target.color = FlxColor.LIME;
			case 2:
				target.color = 0xFFBB3333;
			case 3:
				target.color = 0xFFBBBB00;
			default:
		}
	}
	
	function beginPlayerTurn()
	{
		//trace('start player turn');
		
		//Reset buttons
		for (button in buttons) {
			button.visible = true;
			button.alpha = 1;
		}
		
		//Check for attack possibility
		if (player.grabbedEnemy == null)
			buttons[1].alpha = 0.5;
			
		//Check for grab possibility
		var adjacentStacks:Array<Stack> = sec.getAdjacentTiles(currentPlayerStack.column, currentPlayerStack.row);
		buttons[2].alpha = 0.5;
		for (stack in adjacentStacks) {
			if (stack != null && stack.hasEnemy)
				buttons[2].alpha = 1;
		}
		
		isPlayerTurn = true;
		startPlayerTurn = false;
	}
	
	function endPlayerTurn()
	{
		isPlayerTurn = false;
		
		endCurrentPhase();
		
		playEnemyTurn();
	}
	
	function startMovePhase()
	{
		if (buttons[0].alpha < 1)
			return;
		
		currentPhase = 1;
		
		var stack = sec.getStackById(player.ID);
		var adjacentStacks:Array<Stack> = sec.getAdjacentTiles(stack.column, stack.row);
		for (i in 0...adjacentStacks.length) {
			//Only moves to tiles of a certain height and without enemies
			//if (adjacentStacks[i] != null && Math.abs(stack.height - adjacentStacks[i].height) <= 32 && !adjacentStacks[i].hasEnemy) {
			if (adjacentStacks[i] != null && !adjacentStacks[i].hasEnemy) {
				stackSelection[i] = adjacentStacks[i];
			}
		}
			
		//Move tile highlighting
		for (i in 0...stackSelection.length) {
			if (stackSelection[i] != null) {
				FlxMouseEventManager.add(stackSelection[i].root, onMouseDown, onMouseUp, onMouseOver, onMouseOut, false, true, true, [FlxMouseButtonID.LEFT]);
				stackSelection[i].root.color = FlxColor.LIME;
			} else {
				//trace('stackSelection at $i is null');
			}
		}
	}
	
	function startAttackPhase()
	{
		if (buttons[1].alpha < 1)
			return;
			
		currentPhase = 2;
		
		var adjacentStacks:Array<Stack> = sec.getAdjacentTiles(currentPlayerStack.column, currentPlayerStack.row);
		//Attack tile setup
		if (player.grabbedEnemy != null) {
			var count:Int = 0;
			for (j in 0...stackSelection.length) {
				if (adjacentStacks[j] != null) {
					var tempAdjacent = sec.getAdjacentTiles(adjacentStacks[j].column, adjacentStacks[j].row);
					
					targetSelection[count] = adjacentStacks[j];
					count++;
					
					//Must exclude oposite tile from stackSelection[j] (top, right, bottom, left)
					for (k in 0...tempAdjacent.length) {
						if (tempAdjacent[k] != null) {
							
							switch (k) {
								case 0:
									if (j == 2)
										continue;
								case 1:
									if (j == 3)
										continue;
								case 2:
									if (j == 0)
										continue;
								case 3:
									if (j == 1)
										continue;
								default:
							}
							
							targetSelection[count] = tempAdjacent[k];
							count++;
						}
					}
				}
			}
		}
		
		for (i in 0...targetSelection.length) {
			FlxMouseEventManager.add(targetSelection[i].root, onMouseDown, onMouseUp, onMouseOver, onMouseOut, false, true, true, [FlxMouseButtonID.LEFT]);
			targetSelection[i].root.color = 0xFFBB0000;
		}
	}
	
	function startGrabPhase() 
	{
		if (buttons[2].alpha < 1)
			return;
			
		currentPhase = 3;
		
		var adjacentStacks:Array<Stack> = sec.getAdjacentTiles(currentPlayerStack.column, currentPlayerStack.row);
		for (l in 0...adjacentStacks.length) {
			if (adjacentStacks[l] != null ) {
				if (adjacentStacks[l].hasEnemy && Math.abs(currentPlayerStack.height - adjacentStacks[l].height) <= 32) {
					grabSelection[l] = adjacentStacks[l];
				}
			}
		}
		
		for (i in 0...grabSelection.length) {
			if (grabSelection[i] != null) {
				FlxMouseEventManager.add(grabSelection[i].root, onMouseDown, onMouseUp, onMouseOver, onMouseOut, false, true, true, [FlxMouseButtonID.LEFT]);
				grabSelection[i].root.color = 0xFFBBBB00;
			}
		}
	}
	
	function endCurrentPhase()
	{
		switch (currentPhase) {
			case 1:
				buttons[0].alpha = 0.5;
				
				for (i in 0...stackSelection.length) {
					if (stackSelection[i] != null) {
						FlxMouseEventManager.remove(stackSelection[i].root);
						stackSelection[i].root.color = FlxColor.WHITE;
						stackSelection[i] = null;
					}
				}
			case 2:
				buttons[1].alpha = 0.5;
				
				for (i in 0...targetSelection.length) {
					if (targetSelection[i] != null) {
						FlxMouseEventManager.remove(targetSelection[i].root);
						targetSelection[i].root.color = FlxColor.WHITE;
						targetSelection[i] = null;
					}
				}
			case 3:
				buttons[2].alpha = 0.5;
				
				for (i in 0...grabSelection.length) {
					if (grabSelection[i] != null) {
						FlxMouseEventManager.remove(grabSelection[i].root);
						grabSelection[i].root.color = FlxColor.WHITE;
						grabSelection[i] = null;
					}
				}
			default:
		}
		
		currentPhase = 0;
		currentPlayerStack.root.color = FlxColor.BLUE;
	}
}