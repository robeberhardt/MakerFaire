package com.rgs.sprites
{
	import com.rgs.txt.Message;
	import com.rgs.txt.QueueManager;
	
	import flash.display.Sprite;
	
	import org.osflash.signals.Signal;
	
	public class SpriteManager extends Sprite
	{
		private static var instance						: SpriteManager;
		private static var allowInstantiation			: Boolean;
		
		private var	spriteQueue				: Array;
		private var currentSprite			: int;
		private var nextUpdateableSprite	: int;
		
		public var spriteReadySignal			: Signal;
		
		private static const MAX_SPRITES	: int = 100;
		
		public function SpriteManager(name:String="SpriteManager")
		{
			if (!allowInstantiation) {
				throw new Error("Error: Instantiation failed: Use SpriteManager.getInstance()");
			} else {
				this.name = name;
				init();
			}
		}
		
		public static function getInstance(name:String = "SpriteManager"):SpriteManager {
			if (instance == null) {
				allowInstantiation = true;
				instance = new SpriteManager(name);
				allowInstantiation = false;
			}
			return instance;
		}
		
		private function init():void
		{
			spriteQueue = new Array();
			for (var i:int=0; i<MAX_SPRITES; i++)
			{
				var newSprite:MessageSprite = new MessageSprite();
				newSprite.index = i;
				spriteQueue.push(newSprite);
			}
			currentSprite = 0;
			nextUpdateableSprite = 0;
			spriteReadySignal = new Signal(MessageSprite);
			trace("created " + MAX_SPRITES + " empty MessageSprites");
		}
		
		
		
		public function makeSprites(m:String):void
		{	
			SpriteFactory.getInstance().readySignal.addOnce(function(mSprites:Array)
			{
				// we've got the sprites, let's add them to msQueue
				trace("\n\nmSprites! " + mSprites);
				spriteReadySignal.dispatch(mSprites[0]);
			});
			SpriteFactory.getInstance().make(m);
			
		}
		
		public function getNextSprite():void
		{
			trace("getting next sprite: " + spriteQueue[currentSprite]);
			spriteReadySignal.dispatch(spriteQueue[currentSprite]);
			currentSprite ++;
			if (currentSprite == spriteQueue.length) { currentSprite = 0; }
		}
		
		public function getSpritesForUpdate(count:int):Array
		{
			trace("getting sprites for update, " + currentSprite + ", " + count);
			var nextSpriteTemp:int = nextUpdateableSprite;
			for (var i:int=0; i<count; i++)
			{
				nextUpdateableSprite ++;
				if (nextUpdateableSprite == spriteQueue.length) { nextUpdateableSprite = 0; }
			}
			return spriteQueue.slice(nextSpriteTemp, nextSpriteTemp + count);
		}
	}
}