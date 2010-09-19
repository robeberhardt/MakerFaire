package com.rgs.rings
{
	import com.rgs.utils.Logger;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class RingMaster extends Sprite
	{
		
		private var count : uint = 5;
		private var ringArray : Array;
		private var offset : Number = .2;
		private var speed : Number = .003;
		private var radius : Number = 300;
		private var availableConnectors : Array;
		private var usedConnectors : Array;
		
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
				ring.index = i;
				addChild(ring);
				ringArray.push(ring);
			}
			
			usedConnectors = new Array();
			availableConnectors = new Array();
			for (var r:uint=0; r < count; r++)
			{
				for (var c:uint=0; c<Ring.NUMBER_OF_CONNECTORS; c++)
				{
					availableConnectors.push([r,c]);
				}
			}
			
			Logger.log(availableConnectors);
		}
		
		public function getRandomConnector():Connector
		{
			var pickIndex:int = Math.floor(Math.random()*availableConnectors.length);
			trace("pickIndex: " + pickIndex);
			var pickValue:Array = availableConnectors.splice(pickIndex, 1)[0];
			trace("pickValue: " + pickValue);
			
			usedConnectors.push(pickValue);
		
			var connector:Connector = Ring(ringArray[pickValue[0]]).getConnectorByIndex(pickValue[1]);
			
			trace("used: " + usedConnectors);
			
			return connector;
		}
		
		public function getRingByIndex(val:uint):Ring
		{
			trace("getting ring by index: " + val);
			return ringArray[val];
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