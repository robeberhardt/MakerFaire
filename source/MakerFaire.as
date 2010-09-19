package
{
	import com.freeactionscript.ParallaxField;
	import com.greensock.TweenMax;
	import com.rgs.fonts.FontLibrary;
	import com.rgs.rings.Ball;
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
		
		private var ball				: *;
		
		public function MakerFaire()
		{
			
			Logger.setMode(Logger.LOG_INTERNAL_ONLY);
			
			QueueManager.getInstance().loadedSignal.add(onLoadComplete);
			QueueManager.getInstance().load("contents.plist");
			
			/*
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
			
			
//			var p:Particle = new Particle("Hello,\nMaker Faire!", FontLibrary.HELVETICA_BOLD);
//			addChild(p);
//			p.x = ball.x;
//			p.y = ball.y;
//			p.alpha = 1;
//			
			timer = new Timer(5000, 0);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
//			
//			ball = p;
			
			*/
		}
		
		private function onLoadComplete(xml:XML):void
		{
			//trace("loaded " + xml);
		}
		
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
			
			var targetRing:Ring = rm.getRandomRing();
			var targetBall:Ball = targetRing.getRandomBall();
			var targetPoint:Point = targetRing.predictPosition(targetBall, 2);
			TweenMax.to(ball, 2, { x:targetPoint.x, y:targetPoint.y,
				scale: targetRing.realScale, alpha: targetRing.scaleX,
				onComplete:attachToTarget, onCompleteParams:[ball, targetBall]
			});
			
		}
		
		private function attachToTarget(what:*, where:Ball):void
		{
			where.addChild(what);
			what.x = what.y = 0;
			what.scale = 1;
		}
	}
}