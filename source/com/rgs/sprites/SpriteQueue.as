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
		
		private var	emptySprites				: Array;
		private var readySprites				: Array;
		private var busySprites					: Array;
		
		private var currentSpriteIndex			: int;
		private var nextUpdateableSpriteIndex	: int;
		private var nextAvailableSpriteIndex	: int;
				
		private var multiPartMessageMode		: Boolean;
		
		public var spriteQueueReadySignal			: Signal;
		public var nextSpriteSignal					: Signal;
		public var emptySignal						: Signal;
		
		private static const MAX_SPRITES	: int = 10;
		
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
			emptySprites = new Array();
			readySprites = new Array();
			busySprites = new Array();
			
			// make an array of empty messagesprites
			for (var i:int=0; i<MAX_SPRITES; i++)
			{
				var newSprite:MessageSprite = new MessageSprite();
				newSprite.recycleSignal.add(onRecycleSignal);
				newSprite.busySignal.add(onBusySignal);
				newSprite.index = i;
				emptySprites.push(newSprite);
			}
			
			currentSpriteIndex = -1;
			nextUpdateableSpriteIndex = 0;
			nextAvailableSpriteIndex = -1;
			multiPartMessageMode = false;
			
			//spriteQueueReadySignal = new Signal(MessageSprite);
			nextSpriteSignal = new Signal(MessageSprite);
			emptySignal = new Signal();
		}
		
		private function onRecycleSignal(theSprite:MessageSprite):void
		{
			trace("    ---> pushing " + theSprite + " back into the empty queue.");
			emptySprites.push(theSprite);
		}
		
		private function onBusySignal(theSprite:MessageSprite):void
		{
			trace("    ---> pushing " + theSprite + " into the ready queue.");
			readySprites.push(theSprite);
			trace("pushed into readySprites - " + readySprites + "\n" + readySprites.length);
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
		
		public function getNextAvailableSprite():void
		{
			trace("\n\n-----------\nready: " + readySprites + "\nbusy: " + busySprites + "\nempty: " + emptySprites + "\n-------------\n");
			if (readySprites.length > 0)
			{
				trace("there's a ready sprite: " + readySprites[0]);
				trace(typeof(readySprites[0]));
				var candidate:MessageSprite = readySprites.shift();
				//var candidate:MessageSprite = readySprites[0];
				trace("candidate: " + candidate);
				//candidate.busy = true;
				//busySprites.push(candidate);
				
				nextSpriteSignal.dispatch(candidate);
			}
			else
			{
				// we have to make some more
				var message:Message = MessageLoader.getInstance().getNextMessage();
				if (message != null)
				{
					// ok we've got a message, let's make sprites and add them to the queue
					SpriteFactory.getInstance().preparedSignal.addOnce( function (count:int)
					{
						trace("the next message will require " + count + " sprites.");
						trace("there are " + emptySprites.length + " empty sprites.");
						if (count <= emptySprites.length)
						{
							SpriteFactory.getInstance().allSpritesCompleteSignal.addOnce( function()
							{
								trace("    ------> now we'll check again...");
								getNextAvailableSprite();
							});
							var theEmpties:Array = emptySprites.splice(0, count);
							trace("theEmpties:  "+ theEmpties);
							SpriteFactory.getInstance().makeSprites(theEmpties);
						}
					});
					SpriteFactory.getInstance().prepare(message.text);
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

			// do we have an available sprite in the queue?
			trace("trying to get next sprite - currentSpriteIndex = " + currentSpriteIndex + ", length = " + emptySprites.length);
			var nextPossible:int = currentSpriteIndex + 1;
			if (nextPossible > emptySprites.length-1) { nextPossible = 0; }
			
			var candidate:MessageSprite = emptySprites[nextPossible];
			if (candidate.busy)
			{
				trace("we've got a fresh one");
				candidate.busy = false;
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
							trace("i=" + i + ", nextUpdateableSpriteIndex =" + nextUpdateableSpriteIndex);
							tempArray.push(emptySprites[nextUpdateableSpriteIndex]);
							nextUpdateableSpriteIndex ++;
							if (nextUpdateableSpriteIndex > emptySprites.length-1)
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
		*/
		
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
				if (nextUpdateableSpriteIndex == emptySprites.length) { nextUpdateableSpriteIndex = 0; }
			}
			return emptySprites.slice(nextSpriteTemp, nextSpriteTemp + count);
		}
	}
}