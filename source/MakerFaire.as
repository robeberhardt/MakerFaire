package
{
	import com.freeactionscript.ParallaxField;
	import com.greensock.TweenMax;
	import com.rgs.fonts.FontLibrary;
	import com.rgs.rings.Ball;
	import com.rgs.rings.Connector;
	import com.rgs.rings.Particle;
	import com.rgs.rings.Ring;
	import com.rgs.rings.RingMaster;
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
		
		//public var timeMultiplier		: Number = 1.0;
		
		private var ball				: Ball;
		
		public function MakerFaire()
		{
			alpha = 0;
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
			
			timer = new Timer(5000, 0);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			
			TweenMax.to(this, 3, { alpha: 1 } );
		}
		
		/*
		
		private function onTimer(e:TimerEvent):void
		{	
			//TweenMax.killTweensOf(ball);
			
			Logger.log("\n\n------>>> next message: " + QueueManager.getInstance().getNextMessage() + "\n\n");
			
			if (ball.parent != this)
			{
				var newBallPoint:Point = ball.localToGlobal(new Point(ball.x, ball.y));
				var newScale:Number = ball.parent.parent.scaleX;
				trace("\n---> newScale: " + newScale);
				ball.parent.removeChild(ball);
				ball.scale = newScale;
				ball.x = newBallPoint.x;
				ball.y = newBallPoint.y;
				addChild(ball);
			}
			
			var targetConnector:Connector = rm.getRandomConnector();
			var targetRing:Ring = rm.getRingByIndex(targetConnector.index);
			var targetPoint:Point = targetRing.predictPosition(targetConnector, 2);
			
			trace("targetConnector: " + targetConnector);
			trace("targetRing: " + targetRing);
			trace("targetPoint: " + targetPoint);
			
//			var targetRing:Ring = rm.getRandomRing();
//			var targetConnector:Connector = targetRing.getRandomConnection();
//			var targetPoint:Point = targetRing.predictPosition(targetConnector, 2);
				
			TweenMax.to(ball, 2, { x:targetPoint.x, y:targetPoint.y,
				scale: targetRing.realScale, alpha: targetRing.scaleX,
				onComplete:attachToTarget, onCompleteParams:[ball, targetConnector]
			});
			
		}
		*/
		
		private function onTimer(e:TimerEvent):void
		{	
			//TweenMax.killTweensOf(ball);
			if (ball.parent != this)
			{
				var newBallPoint:Point = ball.localToGlobal(new Point(ball.x, ball.y));
				var newScale:Number = ball.parent.parent.scaleX;
				trace("\n---> newScale: " + newScale);
				ball.parent.removeChild(ball);
				ball.scale = newScale;
				ball.x = newBallPoint.x;
				ball.y = newBallPoint.y;
				addChild(ball);
			}
			
			var pick:Connector = rm.getRandomConnector();
			var targetRing:Ring = rm.getRingByIndex(pick.ring.index);
			var targetPoint:Point = targetRing.predictPosition(pick, 2);
			
			trace("picK: " + pick);
//			trace("ring: " + targetRing);
//			trace("point: " + targetPoint);
			
			pick.blink();
			
			
			TweenMax.to(ball, 2, { x:targetPoint.x, y:targetPoint.y,
				scale: targetRing.realScale, alpha: targetRing.scaleX,
				onComplete:attachToTarget, onCompleteParams: [ball, pick]
			});
			
//			var targetRing:Ring = rm.getRandomRing();
//			var targetBall:Connector = targetRing.getConnectorByIndex(2);
//			var targetPoint:Point = targetRing.predictPosition(targetBall, 2);
			
//			
//			TweenMax.to(ball, 2, { x:targetPoint.x, y:targetPoint.y,
//				scale: targetRing.realScale, alpha: targetRing.scaleX,
//				onComplete:attachToTarget, onCompleteParams:[ball, targetBall]
//			});
			
		}

		
		private function attachToTarget(what:*, where:Connector):void
		{
			where.addChild(what);
			what.x = what.y = 0;
			what.scale = 1;
			where.active = true;
		}
	}
}