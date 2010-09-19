package com.rgs.rings
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class RingMaster extends Sprite
	{
		
		private var count : uint = 5;
		private var ringArray : Array;
		private var offset : Number = .2;
		private var speed : Number = .003;
		private var radius : Number = 300;
		
		public function RingMaster()
		{
			if (stage) { init(); } else { addEventListener(Event.ADDED_TO_STAGE, init); }
		}
		
		private function init(e:Event=null):void
		{
			ringArray = new Array();
			
			for (var i:int = 0; i<count; i++)
			{
				var rSpeed:Number = speed;
				if (i % 2 != 0) { rSpeed = -rSpeed; }
				var ring:Ring = new Ring(radius, 1 - (offset * i), rSpeed);
				ring.ix = i;
				addChild(ring);
				ringArray.push(ring);
			}
		}
		
		public function getRandomRing():Ring
		{
			return ringArray[Math.round(Math.random()*(count-1))];
		}
		
		public function set scale(val:Number):void
		{
			scaleX = scaleY = val;
		}
	}
}