package com.rgs.utils
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import org.osflash.signals.Signal;
	
	public class KeyboardManager extends Sprite
	{
		private static var instance						: KeyboardManager;
		private static var allowInstantiation			: Boolean;
		
		public var ringSignal							: Signal;
		public var invaderSignal						: Signal;
		public var killSignal							: Signal;
		public var soundSignal							: Signal;
		public var frameSignal							: Signal;
		public var randomPositionsSignal				: Signal;
		public var originalPositionsSignal				: Signal;
		public var tweenAllSignal				: Signal;
		
		public function KeyboardManager(name:String="KeyboardManager")
		{
			if (!allowInstantiation) {
				throw new Error("Error: Instantiation failed: Use KeyboardManager.getInstance()");
			} else {
				this.name = name;
				ringSignal = new Signal();
				invaderSignal = new Signal();
				killSignal = new Signal();
				soundSignal = new Signal();
				frameSignal = new Signal();
				randomPositionsSignal = new Signal();
				originalPositionsSignal = new Signal();
				tweenAllSignal = new Signal();
				if (stage) { init(); } else { addEventListener(Event.ADDED_TO_STAGE, init); }
			}
		}
		
		public static function getInstance(name:String = "KeyboardManager"):KeyboardManager {
			if (instance == null) {
				allowInstantiation = true;
				instance = new KeyboardManager(name);
				allowInstantiation = false;
			}
			return instance;
		}
		
		private function init(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		}
		
		private function handleKeyDown(e:KeyboardEvent):void
		{
			trace("got a key! " + e.keyCode);
			switch (e.keyCode)
			{
				case 32 : // space invader
					invaderSignal.dispatch();
					break;
				
				case 82 : // r - show/hide rings
					ringSignal.dispatch();
					break;
				
				case 75 : // k - kill random sprite
					killSignal.dispatch();
					break;
				
				case 83 : // s - toggle sounds
					soundSignal.dispatch();
					break;
				
				case 70 : // f - switch frame
					frameSignal.dispatch();
					break;
				
				case 79 : // o - original positions
					originalPositionsSignal.dispatch();
					break;
				
				case 80 : // p - random positions
					randomPositionsSignal.dispatch();
					break;
				
				case 84 : // t - tweenAllRings mode toggler
					tweenAllSignal.dispatch();
					break;
				
				default :
					//
					break;
			}
			
		}
	}
}