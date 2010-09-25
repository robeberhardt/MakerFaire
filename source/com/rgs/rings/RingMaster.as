package com.rgs.rings
{
	import com.rgs.sprites.MessageSprite;
	import com.rgs.utils.Logger;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class RingMaster extends Sprite
	{
		
		private var count : uint = 9;
		private var ringArray : Array;
		private var offset : Number = .1;
		private var speed : Number = .001;
		private var radius : Number = 400;
		public var availableConnectors : Array;
		public var usedConnectors : Array;
		public var doneKillingSignal : Signal;
		public var ringsVisible : Boolean;
		private var ringsMode : int;
		
		public var killSpecificSpriteSignal : Signal;
		
		public function RingMaster()
		{
			ringsVisible = false;
			ringsMode = 0;
			killSpecificSpriteSignal = new Signal(MessageSprite);
			
			if (stage) { init(); } else { addEventListener(Event.ADDED_TO_STAGE, init); }
		}
		
		private function init(e:Event=null):void
		{
			ringArray = new Array();
			for (var i:int = 0; i<count; i++)
			{
				var rSpeed:Number = speed;
				if (i % 2 != 0) { rSpeed = -rSpeed; }
				var ring:Ring = new Ring(radius - (i*30), .9 - (i*.05), rSpeed);
				ring.index = i;
				addChild(ring);
				ringArray.push(ring);
				ring.hideRing();
				ring.hideConnectors();
				trace("creating " + ring);
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
			
			trace("got random connector - " + connector);
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
		
		public function killSpecificSprite(which:MessageSprite):void
		{
			trace("parent of " + which + " is " + which.parent);
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
			trace("RINGSMODE:  " + ringsMode);
			if (ringsMode == 0) 
			{
				for (var i:int = 0; i<ringArray.length; i++)
				{
					Ring(ringArray[i]).showRing();
				}
				ringsMode = 1;
			}
			else if (ringsMode == 1)
			{
				for (i = 0; i<ringArray.length; i++)
				{
					Ring(ringArray[i]).showConnectors();
				}
				ringsMode = 2;
			}
			else if (ringsMode == 2)
			{
				for (i = 0; i<ringArray.length; i++)
				{
					Ring(ringArray[i]).hideRing();
					Ring(ringArray[i]).hideConnectors();
				}
				ringsMode = 0;
			}
		}
	}
}