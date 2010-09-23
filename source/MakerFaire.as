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

			SpriteQueue.getInstance().emptySignal.add(onEmpty);
			
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
			
			hookupTimer = new Timer(1000, 0);
			hookupTimer.addEventListener(TimerEvent.TIMER, hookup);
			
			queueTimer = new Timer(1000, 0);
			queueTimer.addEventListener(TimerEvent.TIMER, mainLoop);
			
			// and away we go!
			queueTimer.start();
			
			
			
		
		}
		
		private function mainLoop(e:TimerEvent):void
		{
			queueTimer.stop();
			SpriteQueue.getInstance().nextSpriteSignal.addOnce(gotNextSprite);
			SpriteQueue.getInstance().getNextAvailableSprite();
		}
		
		private function gotNextSprite(theSprite:MessageSprite)
		{
			theSprite.x = stage.stageWidth * .5;
			theSprite.y = stage.stageHeight * .5 + 200;
			addChild(theSprite);
			theSprite.arrive();
			currentSprite = theSprite;
			hookupTimer.start();
		}
		
		private function onEmpty():void
		{
			trace("we're empty, starting timer...");
			queueTimer.start();
		}
		
		private function hookup(e:TimerEvent):void
		{
			hookupTimer.stop();
			trace("hookup - available connectors = " + rm.availableConnectors.length);
			if (rm.availableConnectors.length == 0)
			{ 
				rm.killRandomSprite();
			}
			
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
				scale: targetRing.realScale, alpha: 1 - (targetRing.index * .1),
				motionBlur:{strength: 2, quality: 4}, ease:Cubic.easeInOut,
				onComplete:attachToTarget, onCompleteParams: [currentSprite, pick]
			});
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
		
	
		
		
	}
}