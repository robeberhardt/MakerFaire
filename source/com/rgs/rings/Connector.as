package com.rgs.rings
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.rgs.sprites.MessageSprite;
	import com.rgs.utils.Label;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	public class Connector extends Sprite
	{	
		private var _active : Boolean;
		private var radius:Number;
		private var fillcolor:uint;
		private var _index : uint;
		private var _angle : Number;
		private var _scale : Number;
		private var _ring : Ring;
		private var _passenger : MessageSprite;
		private var dot	: Sprite;
	
		
		public function Connector(radius:Number=40, fillcolor:uint=0xff0000)
		{
			this.radius = radius;
			this.fillcolor = fillcolor;
			angle = 0;
			scale = 1;
			_active = false;
			passenger = null;
			if (stage) { init(); } else { addEventListener(Event.ADDED_TO_STAGE, init); }
			
		}
		
		public function init(e:Event=null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			dot = new Sprite();
			addChild(dot);
			
			dot.graphics.beginFill(fillcolor, 1);
			dot.graphics.drawCircle(0, 0, radius);
			dot.graphics.endFill();
			
			
		}
		
		override public function toString():String
		{
			return "[Connector " + _index + ", ring " + Ring(parent).index + ", angle: " + _angle + "]";
		}
		
		public function localCoords():Point
		{
			return parent.localToGlobal(new Point(this.x, this.y));
		}
		
		public function blink():void
		{
			TweenMax.to(this, .125, { alpha: 0, repeat:5, yoyo:true });
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
		
		public function get active():Boolean
		{
			return _active;
		}

		public function set active(value:Boolean):void
		{
			_active = value;
		}
		
		public function get ring():Ring
		{
			return _ring;
		}
		
		public function set ring(value:Ring):void
		{
			_ring = value;
		}

		public function get index():uint
		{
			return _index;
		}

		public function set index(value:uint):void
		{
			
			_index = value;
		}
		
		public function hide():void
		{
			TweenMax.to(dot, 1, { alpha: 0 });
		}
		
		public function show():void
		{
			TweenMax.to(dot, 1, { alpha: 1 });
		}

		public function get passenger():MessageSprite
		{
			return _passenger;
		}

		public function set passenger(value:MessageSprite):void
		{
			_passenger = value;
			//_passenger.killMeNowSignal.add(onKillPassenger);
		}
		
		public function onKillPassenger(which:MessageSprite):void
		{
			
		}

	}
}