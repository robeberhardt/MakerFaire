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
	import com.rgs.sprites.SpriteManager;
	import com.rgs.txt.Message;
	import com.rgs.txt.QueueManager;
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
		private var timer				: Timer;
		
		private var currentSprite		: MessageSprite;
		//public var timeMultiplier		: Number = 1.0;
		
		private var ball				: Ball;
		
		public function MakerFaire()
		{
			alpha = 0;
			TweenPlugin.activate([MotionBlurPlugin]);
			Logger.setMode(Logger.LOG_INTERNAL_ONLY);
			QueueManager.getInstance().loadedSignal.addOnce(init);
			QueueManager.getInstance().load();
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
			
			SpriteManager.getInstance();
			
			//getNextMessage();
			
		
			timer = new Timer(7000, 0);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
	
		}
		
		private function getNextMessage():void
		{
			// get the next message from the queue manager and make a message sprite for it
			var nextMessage:Message = QueueManager.getInstance().getNextMessage();
			if (nextMessage)
			{
				SpriteManager.getInstance().spriteReadySignal.addOnce(function(theNextSprite:MessageSprite)
				{
//					trace("theNextSprite is " + theNextSprite);
//					addChild(theNextSprite);
//					theNextSprite.x = stage.stageWidth * .5;
//					theNextSprite.y = stage.stageHeight * .5 + 200;
//					theNextSprite.arrive();
//					currentSprite = theNextSprite;
					getNextSprite();
					
				});
				SpriteManager.getInstance().makeSprites(nextMessage.text);
			}
		}
	
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
		
		
		private function attachToTarget(what:*, where:Connector):void
		{
			where.addChild(what);
			what.x = what.y = 0;
			what.scale = 1;
			where.active = true;
		}
	}
}