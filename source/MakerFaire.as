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
	import com.rgs.txt.Message;
	import com.rgs.txt.MessageSprite;
	import com.rgs.txt.QueueManager;
	import com.rgs.txt.SpriteFactory;
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
			
			ball = new Ball(10, 0x777777);
			addChild(ball);
			ball.x = stage.stageWidth * .5; 
			ball.y = stage.stageHeight * .5 + 200;
			
			timer = new Timer(7000, 0);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			//timer.start();
			
			TweenMax.to(this, 3, { alpha: 1 } );
			
			SpriteFactory.getInstance().readySignal.addOnce(onSpritesReady);
			//SpriteFactory.getInstance().make("Lorem ipsum dolor sit amet, consectetur adipiscing volutpat!");
			SpriteFactory.getInstance().make("   Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut turpis lacus, lobortis eget commodo vel, gravida placerat metus.  ");
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
			
			timer.start();
		}
		
		private function moveToRing(obj:Sprite):void
		{
			var pick:Connector = rm.getRandomConnector();
			var targetRing:Ring = rm.getRingByIndex(pick.ring.index);
			var targetPoint:Point = targetRing.predictPosition(pick, 2);
			
			TweenMax.to(obj, 2, { x:targetPoint.x, y:targetPoint.y,
				scale: targetRing.realScale, alpha: targetRing.scaleX,
				onComplete:attachToTarget, onCompleteParams: [obj, pick]
			});
		}
		
		
		private function onTimer(e:TimerEvent):void
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
		
		/*
		
		private function onTimer(e:TimerEvent):void
		{	
			if (ball.parent != this)
			{
				var newBallPoint:Point = ball.localToGlobal(new Point(ball.x, ball.y));
				
				var newScale:Number = Ring(ball.parent.parent).realScale;
				trace(ball.parent);
				trace(ball.parent.parent);
				trace("\n---> newScale: " + newScale);
				ball.parent.removeChild(ball);
				ball.scale = newScale;
				ball.x = newBallPoint.x;
				ball.y = newBallPoint.y;
				addChild(ball);
			}
			
			var pick:Connector = rm.getRandomConnector();
			var targetRing:Ring = rm.getRingByIndex(pick.ring.index);
			var targetPoint:Point = targetRing.predictPosition(pick, 5);
						
			pick.blink();
			
			
			TweenMax.to(ball, 5, { x:targetPoint.x, y:targetPoint.y,
				scale: targetRing.realScale, alpha: targetRing.scaleX, ease:Cubic.easeInOut,
				onComplete:attachToTarget, onCompleteParams: [ball, pick]
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