package com.rgs.rings {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Ball extends Sprite {
		
		private var radius:Number;
		private var fillcolor:uint;
		public var ix : uint;
		private var _angle : Number;
		private var _scale : Number;
		
		public function Ball(radius:Number=40, fillcolor:uint=0xff0000 ) {
			this.radius = radius;
			this.fillcolor = fillcolor;
			angle = 0;
			scale = 1;
			if (stage) { init(); } else { addEventListener(Event.ADDED_TO_STAGE, init); }
		}
		public function init(e:Event=null):void {
			graphics.beginFill(fillcolor);
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
		}
		
		override public function toString():String
		{
			return "[Ball " + ix + ", ring " + Ring(parent).index + ", angle: " + _angle + "]";
		}
		
		public function localCoords():Point
		{
			return parent.localToGlobal(new Point(this.x, this.y));
		}
		
		
		
		public function get angle():Number
		{
			return _angle;
		}
		
		public function set angle(value:Number):void
		{
			_angle = value;
		}
		
		public function get scale():Number 
		{
			return _scale;
		}
		
		public function set scale(value:Number):void
		{
			//trace("setting scale to " + value);
			_scale = scaleX = scaleY = value;
		}
	}
}