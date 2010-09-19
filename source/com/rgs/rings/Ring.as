package com.rgs.rings
{
	import com.rgs.utils.Utils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Ring extends Sprite
	{
		private var radius : Number;
		private var speed : Number;
		private var scale : Number;
		
		public var ix : uint;
		
		private var ballCount : uint = 6;
		private var ballArray : Array;
		
		private var ball : Ball;
		
		public function Ring(radius:Number, scale:Number, speed:Number)
		{
			this.radius = radius;
			this.speed = speed;
			this.scale = this.scaleX = this.scaleY = scale;
			ballArray = new Array();
			if (stage) { init(); } else { addEventListener(Event.ADDED_TO_STAGE, init); }
		}
		
		private function init(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			graphics.lineStyle(1.5, 0xffffff, .2, false);
			graphics.drawCircle(0, 0, radius);
			
			for (var i:int = 0; i < ballCount; i++)
			{
				var ball:Ball = new Ball(10, Math.random()*0xffffff);
				addChild(ball);
				ball.alpha = 1;
				ball.ix = i;
				ball.angle = i * (Math.PI*2) / ballCount;
				ballArray.push(ball);
				ball.x = Math.sin( ball.angle ) * radius;
				ball.y = Math.cos( ball.angle ) * radius;
				
			}
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function predictPosition(ball:Ball, time:Number):Point
		{
			var tempAngle:Number = ball.angle;
			var futureFrames:uint = time * stage.frameRate;
			for (var i:int = 0; i < time * stage.frameRate; i++)
			{
				tempAngle += speed * (scale + .1);
			}
			var futurePoint:Point = new Point(Math.sin(tempAngle)*radius, Math.cos(tempAngle)*radius);
			return this.localToGlobal(futurePoint);
		}
										
		private function onEnterFrame(e:Event):void
		{
			//rotation += speed * (scale + .1);
			for each (var ball:Ball in ballArray)
			{
				ball.angle += speed * (scale + .1);
				ball.x = Math.sin( ball.angle ) * radius;
				ball.y = Math.cos( ball.angle ) * radius;
			}
		}
		
		public function get realScale():Number {
			return this.scaleX * parent.scaleX;
		}
		
		public function getRandomBall():Ball
		{
			return ballArray[Math.round(Math.random()*(ballCount-1))];
		}
	}
}