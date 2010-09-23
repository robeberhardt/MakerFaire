package
{
	import com.freeactionscript.ParallaxField;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	import com.rgs.fonts.FontLibrary;
	import com.rgs.rings.Ball;
	import com.rgs.rings.Connector;
	import com.rgs.rings.Particle;
	import com.rgs.rings.Ring;
	import com.rgs.rings.RingMaster;
	import com.rgs.sprites.MessageSprite;
	import com.rgs.sprites.SpriteFactory;
	import com.rgs.sprites.SpriteQueue;
	import com.rgs.txt.Message;
	import com.rgs.txt.MessageLoader;
	import com.rgs.utils.Logger;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.utils.Timer;
	
	import net.hires.debug.Stats;
	
	public class MakerFaire extends MovieClip
	{
		private var rm					: RingMaster;
		
		private var starHolder			: MovieClip;
		private var pfield				: ParallaxField;
		
		private var stats				: Stats;
		private var queueTimer				: Timer;
		private var hookupTimer				: Timer;
		
		private var currentSprite		: MessageSprite;
		private var currentMessage		: Message;
		//public var timeMultiplier		: Number = 1.0;
		
		private var ball				: Ball;
		
		public function MakerFaire()
		{
			alpha = 0;
			TweenPlugin.activate([MotionBlurPlugin]);
			Logger.setMode(Logger.LOG_INTERNAL_ONLY);
			SpriteQueue.getInstance();
			MessageLoader.getInstance().loadedSignal.addOnce(init);
			MessageLoader.getInstance().load();

		}
		
		private function onLoadComplete(xml:XML):void
		{
			init();
		}
		
		private function init():void
		{
			starHolder = new MovieClip();
			addChild(starHolder);
			pfield = new ParallaxField();
			pfield.createField(starHolder, 10, 10, stage.stageWidth, stage.stageHeight, 100, 3, 1, .05);
			
			rm = new RingMaster();
			rm.scale = 1.25;
			rm.x = Math.round(stage.stageWidth * .5);
			rm.y = Math.round(stage.stageHeight * .5);
			addChild(rm);
			
			stats = new Stats();
			addChild(stats);
			
			TweenMax.to(this, 3, { alpha: 1 } );
			
			queueTimer = new Timer(1000, 0);
			queueTimer.addEventListener(TimerEvent.TIMER, mainLoop);
			queueTimer.start();
			
			hookupTimer = new Timer(1000, 0);
			hookupTimer.addEventListener(TimerEvent.TIMER, hookup);
			
		
		}
		
		private function mainLoop(e:TimerEvent):void
		{
			queueTimer.stop();
			SpriteQueue.getInstance().emptySignal.add(onEmpty);
			SpriteQueue.getInstance().nextSpriteSignal.addOnce(gotNextSprite);
			SpriteQueue.getInstance().getNextSprite();
		}
		
		private function gotNextSprite(theSprite:MessageSprite)
		{
			trace("GOT THE NEXT SPRITE! " + theSprite);
			
			if (rm.availableConnectors.length > 0)
			{
				theSprite.x = stage.stageWidth * .5;
				theSprite.y = stage.stageHeight * .5 + 200;
				addChild(theSprite);
				theSprite.arrive();
				currentSprite = theSprite;
				hookupTimer.start();
			}
			else
			{
				// kill one and try again
				rm.killRandomSprite();
				queueTimer.start();
			}
			
		}
		
		private function onEmpty():void
		{
			trace("we're empty, starting timer...");
			queueTimer.start();
		}
		
		private function hookup(e:TimerEvent):void
		{
			hookupTimer.stop();
			
			var hookupTime:Number = 2;
			
			if (currentSprite.parent != this)
			{
				var hookupPoint:Point = currentSprite.localToGlobal(new Point(currentSprite.x, currentSprite.y));
				var newScale:Number = Ring(currentSprite.parent.parent).realScale;
//				trace("newScale: " + newScale + ", from " + currentSprite.parent.parent);
//				trace("\n---> newScale: " + newScale);
				currentSprite.parent.removeChild(currentSprite);
				currentSprite.scale = newScale;
				currentSprite.x = hookupPoint.x;
				currentSprite.y = hookupPoint.y;
				addChild(currentSprite);
			}
			
			var pick:Connector = rm.getRandomConnector();
			var targetRing:Ring = rm.getRingByIndex(pick.ring.index);
			var targetPoint:Point = targetRing.predictPosition(pick, hookupTime);
			
			//pick.blink();
			
			
			TweenMax.to(currentSprite, hookupTime, { x:targetPoint.x, y:targetPoint.y,
				scale: targetRing.realScale, alpha: targetRing.scaleX+.1,
				motionBlur:{strength: 2, quality: 4}, ease:Cubic.easeInOut,
				onComplete:attachToTarget, onCompleteParams: [currentSprite, pick],
				onUpdate: showProgress
			});
		}
		
		private function showProgress():void
		{
			trace("current sprite scale: " + currentSprite.scale);
		}
		
		private function attachToTarget(what:*, where:Connector):void
		{
			where.addChild(what);
			where.passenger = what;
			what.x = what.y = 0;
			what.scale = 1;
			where.active = true;
			
			queueTimer.start();
		}
		
		/*
		private function getNextMessage():void
		{
			// get the next message from the queue manager and make a message sprite for it
			var nextMessage:Message = MessageLoader.getInstance().getNextMessage();
			if (nextMessage)
			{
				SpriteQueue.getInstance().spriteQueueReadySignal.addOnce(function(theNextSprite:MessageSprite)
				{
//					trace("theNextSprite is " + theNextSprite);
//					addChild(theNextSprite);
//					theNextSprite.x = stage.stageWidth * .5;
//					theNextSprite.y = stage.stageHeight * .5 + 200;
//					theNextSprite.arrive();
//					currentSprite = theNextSprite;
					getNextSprite();
					
				});
				SpriteQueue.getInstance().makeSprites(nextMessage.text);
			}
		}
		*/
	
		private function onSpritesReady(theSprites:Array):void
		{
			trace("Got the sprites! - there are " + theSprites.length + " of them...");
			trace(theSprites);
			currentSprite = theSprites[0];
			currentSprite.scale = 1;
			currentSprite.x = stage.stageWidth * .5;
			currentSprite.y = stage.stageHeight * .5 + 200;
			currentSprite.alpha = 0;
			addChild(currentSprite);
			TweenMax.to(currentSprite, 2, { alpha: 1 });
			//TweenMax.delayedCall(5, moveToRing, [theSprites[0]]);
			
			//timer.start();
		}
		
		
		private function onTimer(e:TimerEvent):void
		{
			if (rm.availableConnectors.length <= 0)
			{
				//destroy a random messageSprite
				TweenMax.delayedCall(5, getNextSprite);
			}
			else
			{
				getNextSprite();
			}
			
		}
		
		private function getNextSprite():void
		{
			
		}
		
		/*
		private function onTimer(e:TimerEvent=null):void
		{	
			trace("currentSprite scale is " + currentSprite.scale);
			if (currentSprite.parent != this)
			{
				var newBallPoint:Point = currentSprite.localToGlobal(new Point(currentSprite.x, currentSprite.y));
				var newScale:Number = Ring(currentSprite.parent.parent).realScale;
				trace("newScale: " + newScale + ", from " + currentSprite.parent.parent);
				trace("\n---> newScale: " + newScale);
				currentSprite.parent.removeChild(currentSprite);
				currentSprite.scale = newScale;
				currentSprite.x = newBallPoint.x;
				currentSprite.y = newBallPoint.y;
				addChild(currentSprite);
			}
			
			var pick:Connector = rm.getRandomConnector();
			var targetRing:Ring = rm.getRingByIndex(pick.ring.index);
			var targetPoint:Point = targetRing.predictPosition(pick, 2);
			
			pick.blink();
			
			
			TweenMax.to(currentSprite, 2, { x:targetPoint.x, y:targetPoint.y,
				scale: targetRing.realScale, alpha: targetRing.scaleX+.1,
				motionBlur:{strength: 2, quality: 4}, ease:Cubic.easeInOut,
				onComplete:attachToTarget, onCompleteParams: [currentSprite, pick]
			});
			
		}
		
		*/
		
		
		
	}
}