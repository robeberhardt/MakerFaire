package com.rgs.sprites
{
	import com.rgs.txt.Message;
	import com.rgs.txt.MessageLoader;
	
	import flash.display.Sprite;
	
	import org.osflash.signals.Signal;
	
	public class SpriteQueue extends Sprite
	{
		private static var instance						: SpriteQueue;
		private static var allowInstantiation			: Boolean;
		
		private var	spriteQueue					: Array;
		private var currentSpriteIndex			: int;
		private var nextUpdateableSpriteIndex	: int;
		private var nextAvailableSpriteIndex	: int;
				
		private var multiPartMessageMode		: Boolean;
		
		public var spriteQueueReadySignal			: Signal;
		public var nextSpriteSignal					: Signal;
		public var emptySignal						: Signal;
		
		private static const MAX_SPRITES	: int = 100;
		
		public function SpriteQueue(name:String="SpriteManager")
		{
			if (!allowInstantiation) {
				throw new Error("Error: Instantiation failed: Use SpriteManager.getInstance()");
			} else {
				this.name = name;
				init();
			}
		}
		
		public static function getInstance(name:String = "SpriteManager"):SpriteQueue {
			if (instance == null) {
				allowInstantiation = true;
				instance = new SpriteQueue(name);
				allowInstantiation = false;
			}
			return instance;
		}
		
		private function init():void
		{
			spriteQueue = new Array();
			
			
			// make an array of empty messagesprites
			for (var i:int=0; i<MAX_SPRITES; i++)
			{
				var newSprite:MessageSprite = new MessageSprite();
				newSprite.index = i;
				spriteQueue.push(newSprite);
			}
			
			currentSpriteIndex = -1;
			nextUpdateableSpriteIndex = 0;
			nextAvailableSpriteIndex = -1;
			multiPartMessageMode = false;
			
			//spriteQueueReadySignal = new Signal(MessageSprite);
			nextSpriteSignal = new Signal(MessageSprite);
			emptySignal = new Signal();
		}
		
		/*
		
		public function makeSprites(m:String):void
		{	
			SpriteFactory.getInstance().readySignal.addOnce(function(mSprites:Array)
			{
				// we've got the sprites, let's add them to msQueue
				trace("\n\nmSprites! " + mSprites);
				spriteQueueReadySignal.dispatch(mSprites[0]);
			});
			SpriteFactory.getInstance().make(m);
			
		}
		*/
		
		public function getNextSprite():void
		{

			// do we have an available sprite in the queue?
			var nextPossible:int = currentSpriteIndex + 1;
			if (nextPossible > spriteQueue.length) { nextPossible = 0; }
			
			var candidate:MessageSprite = spriteQueue[nextPossible];
			if (candidate.fresh)
			{
				trace("we've got a fresh one");
				candidate.fresh = false;
				nextSpriteSignal.dispatch(candidate);
				
				currentSpriteIndex = nextPossible;
				
				
				
			}
			else
			{
				trace("let's make some");
				// let's make some
				var message:Message = MessageLoader.getInstance().getNextMessage();
				trace("we've got a message! " + message);
				if (message != null)
				{
					// ok we've got a message, let's make sprites and add them to the queue
					
					
					SpriteFactory.getInstance().preparedSignal.addOnce( function (count:int)
					{
						trace("the next message will require " + count + " sprites.");
						var tempArray:Array = new Array();
						
						for (var i:int=0; i<count; i++)
						{
							tempArray.push(spriteQueue[nextUpdateableSpriteIndex]);
							nextUpdateableSpriteIndex ++;
							if (nextUpdateableSpriteIndex > spriteQueue.length)
							{
								nextUpdateableSpriteIndex = 0;
							}
						}
						
						
						SpriteFactory.getInstance().allSpritesCompleteSignal.addOnce( function()
						{
							
							
							
							// now we'll check again
							getNextSprite();
							
						});
						SpriteFactory.getInstance().makeSprites(tempArray);
						
						
					});
					
					SpriteFactory.getInstance().prepare(message.text);
					
//					SpriteFactory.getInstance().allSpritesCompleteSignal.addOnce( function(newSpritesArray:Array)
//					{
//						trace("we got some new sprites! " + newSpritesArray);
//					});
					
					
			
				}
				else
				{
					// nothing more right now
					emptySignal.dispatch();
				}
			}
		}
		
		/*
		public function getNextSprite():void
		{
			trace("getting next sprite: " + spriteQueue[currentSpriteIndex]);
			spriteQueueReadySignal.dispatch(spriteQueue[currentSpriteIndex]);
			currentSpriteIndex ++;
			if (currentSpriteIndex == spriteQueue.length) { currentSpriteIndex = 0; }
		}
		*/
		
		public function getSpritesForUpdate(count:int):Array
		{
			trace("getting sprites for update, " + currentSpriteIndex + ", " + count);
			var nextSpriteTemp:int = nextUpdateableSpriteIndex;
			for (var i:int=0; i<count; i++)
			{
				nextUpdateableSpriteIndex ++;
				if (nextUpdateableSpriteIndex == spriteQueue.length) { nextUpdateableSpriteIndex = 0; }
			}
			return spriteQueue.slice(nextSpriteTemp, nextSpriteTemp + count);
		}
	}
}