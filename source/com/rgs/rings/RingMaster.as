package com.rgs.rings
{
	import com.rgs.sprites.MessageSprite;
	import com.rgs.utils.Logger;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class RingMaster extends Sprite
	{
		
		private var count : uint = 2;
		private var ringArray : Array;
		private var offset : Number = .2;
		private var speed : Number = .001;
		private var radius : Number = 300;
		public var availableConnectors : Array;
		public var usedConnectors : Array;
		public var doneKillingSignal : Signal;
		public var ringsVisible : Boolean;
		
		public function RingMaster()
		{
			ringsVisible = false;
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
				ring.hideRing();
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
			
			doneKillingSignal = new Signal();
		}
		
		public function getRandomConnector():Connector
		{
			var pickIndex:int = Math.floor(Math.random()*availableConnectors.length);
			var pickValue:Array = availableConnectors.splice(pickIndex, 1)[0];
			
			usedConnectors.push(pickValue);
		
			var connector:Connector = Ring(ringArray[pickValue[0]]).getConnectorByIndex(pickValue[1]);
			
			
			return connector;
		}
		
		public function killRandomSprite():void
		{
			trace("killing random sprite");
			
			var killPick:int = Math.floor(Math.random()*usedConnectors.length);
			
			var killPickValue:Array = usedConnectors.splice(killPick, 1)[0];
			trace("killPickValue: " + killPickValue);
			availableConnectors.push(killPickValue);
			var connector:Connector = Ring(ringArray[killPickValue[0]]).getConnectorByIndex(killPickValue[1]);
			MessageSprite(connector.passenger).depart();
			doneKillingSignal.dispatch();
		}
		
		public function getRingByIndex(val:uint):Ring
		{
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
		
		public function toggleRings():void
		{
			if (ringsVisible) 
			{
				ringsVisible = false;
				for (var i:int = 0; i<ringArray.length; i++)
				{
					Ring(ringArray[i]).hideRing();
				}
			}
			else
			{
				ringsVisible = true;
				for (i = 0; i<ringArray.length; i++)
				{
					Ring(ringArray[i]).showRing();
				}
			}
		}
	}
}