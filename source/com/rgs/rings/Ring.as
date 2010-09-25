package com.rgs.rings
{
	import com.greensock.TweenMax;
	import com.rgs.utils.Utils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Ring extends Sprite
	{
		private var radius : Number;
		private var speed : Number;
		private var scale : Number;
		private var _position : Point;
		private var _origScale : Number;
		private var ringSprite : Sprite;
		
		private var _index : uint;
		
//		private var ballCount : uint = 6;
		
		public static const NUMBER_OF_CONNECTORS : uint = 6;
		private var connectorArray : Array;
		
//		private var connector : Connector;
		
		public function Ring(radius:Number, scale:Number, speed:Number)
		{
			trace("creating ring with " + radius + ", " + scale);
			this.radius = radius;
			this.speed = speed;
			origScale = scale;
			this.scale = this.scaleX = this.scaleY = scale;
			connectorArray = new Array();
			if (stage) { init(); } else { addEventListener(Event.ADDED_TO_STAGE, init); }
		}
		
		override public function toString():String
		{
			return "[Ring " + _index + " ]";
		}
		
		private function init(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			ringSprite = new Sprite();
			addChild(ringSprite);
			
			ringSprite.graphics.lineStyle(2, 0xffffff, .5, false);
			
			ringSprite.graphics.drawCircle(0, 0, radius);
			
			for (var i:int = 0; i < NUMBER_OF_CONNECTORS; i++)
			{
				var c:Connector = new Connector(4, 0xff0000);
				addChild(c);
				c.alpha = 1;
				c.index = i;
				c.ring = this;
				c.angle = i * (Math.PI*2) / NUMBER_OF_CONNECTORS;
				connectorArray.push(c);
				c.x = Math.sin( c.angle ) * radius;
				c.y = Math.cos( c.angle ) * radius;
				
			}
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function predictPosition(c:Connector, time:Number):Point
		{
			var tempAngle:Number = c.angle;
			var futureFrames:uint = time * stage.frameRate;
			for (var i:int = 0; i < time * stage.frameRate; i++)
			{
				//tempAngle += speed * (scale + .1);
				tempAngle += speed * (realScale + .1);
			}
			var futurePoint:Point = new Point(Math.sin(tempAngle)*radius, Math.cos(tempAngle)*radius);
			return this.localToGlobal(futurePoint);
		}
										
		private function onEnterFrame(e:Event):void
		{
			//rotation += speed * (scale + .1);
			for each (var c:Connector in connectorArray)
			{
				c.angle += speed * (scale + .1);
				c.x = Math.sin( c.angle ) * radius;
				c.y = Math.cos( c.angle ) * radius;
			}
		}
		
		public function get realScale():Number {
			return this.scaleX * parent.scaleX;
		}
		
		public function getConnectorByIndex(index:uint):Connector 
		{
			return connectorArray[index];
		}
		
		public function getRandomConnector():Connector
		{
			return connectorArray[Math.round(Math.random()*(NUMBER_OF_CONNECTORS-1))];
		}

		public function get index():uint
		{
			return _index;
		}

		public function set index(value:uint):void
		{
			_index = value;
		}
		
		public function hideRing():void
		{
			TweenMax.to(ringSprite, 1, { alpha: 0 });
			
		}
		
		public function hideConnectors():void
		{
			for each (var c:Connector in connectorArray)
			{
				c.hide();
			}
		}
		
		public function showRing():void
		{
			TweenMax.to(ringSprite, 1, { alpha: 1 });
			
		}
		
		public function showConnectors():void
		{
			for each (var c:Connector in connectorArray)
			{
				c.show();
			}
		}
		
		public function get origScale():Number
		{
			return _origScale;
		}
		
		public function set origScale(val:Number):void
		{
			_origScale = val;
			scaleX = scaleY = val;
		}
		
		public function set position(val:Point)
		{
			_position = val;
			x = _position.x;
			y = _position.y;
		}

	}
}