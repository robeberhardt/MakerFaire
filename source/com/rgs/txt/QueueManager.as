package com.rgs.txt
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.XMLLoader;
	import com.rgs.utils.Logger;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osflash.signals.Signal;
	
	public class QueueManager extends Sprite
	{
		private static var instance						: QueueManager;
		private static var allowInstantiation			: Boolean;
		
		public var loadedSignal 						: Signal;
		public var updateSignal							: Signal;
		private var loader 								: XMLLoader;
		private var status								: String;
		private var path								: String;
		
		private var pollTimer							: Timer;
		
		
		private var theXML								: XML;
		
		private var messageArray						: Array;
		public var currentMessage						: int;
		public var lastMessage							: int;
		
		public static const NOT_LOADED_STATUS			: String = "Not Loaded";
		public static const LOADED_STATUS				: String = "Loaded";
		public static const ERROR_STATUS				: String = "Error";   
		
		private static const MAX_MESSAGES				: uint = 2000;
		private static const POLL_INTERVAL				: uint = 1;
		
		public function QueueManager(name:String="TxtReader")
		{
			if (!allowInstantiation) {
				throw new Error("Error: Instantiation failed: Use TxtManager.getInstance()");
			} else {
				this.name = name;
				init();
			}
		}
		
		public static function getInstance(name:String = "QueueManager"):QueueManager {
			if (instance == null) {
				allowInstantiation = true;
				instance = new QueueManager(name);
				allowInstantiation = false;
			}
			return instance;
		}
		
		private function init():void
		{
			loadedSignal = new Signal();
			updateSignal = new Signal();
			
			messageArray = new Array();
			for (var i:int = 0; i < MAX_MESSAGES; i++)
			{
				var m:Message = new Message();
				m.index = i;
				messageArray.push(m);
			}
			
			currentMessage = -1;
			lastMessage = -1;
		}
		
		public function load(path:String="contents.plist"):void
		{
			this.path = path;
			
			status = NOT_LOADED_STATUS;
			loader = new XMLLoader(path, { onComplete: loadComplete, onError: loadError });
			
			pollTimer = new Timer(POLL_INTERVAL*1000);
			pollTimer.addEventListener(TimerEvent.TIMER, onPollTimer);
			pollTimer.start();
			
		}
		
		private function onPollTimer(e:TimerEvent):void
		{
			pollTimer.stop();
			loader.load(true);
		}
		
		override public function toString():String
		{
			return "[QueueManager -- path: " + path + ", status: " + status + "]";
		}
		
		private function loadComplete(e:LoaderEvent):void
		{
			theXML = loader.getContent(path);
						
			var xmlLength:int = theXML..array.dict.length();
			if (xmlLength > 0) { currentMessage = 0; }
			
			for (var i:int=0; i<xmlLength-(lastMessage+1); i++)
			{
				var address:String = theXML..array.dict[i].children()[1];
				var text:String = theXML..array.dict[i].children()[3];
				var timestamp:String = theXML..array.dict[i].children()[7];
	
				var ix:int = xmlLength-1-i;
				
				var m:Message = messageArray[ix] as Message;
				m.address = address;
				m.text = text;
				m.timestamp = timestamp;
				
			}
			
			lastMessage = xmlLength-1;	
			
			status = LOADED_STATUS;
			loadedSignal.dispatch();
			pollTimer.start();
		}
		
		private function loadError(e:LoaderEvent):void
		{
			Logger.log("load error " + e.text);	
			status = ERROR_STATUS;
		}
		
		public function getNextMessage():Message
		{
			if (currentMessage < 0)
			{
				return null;
			}
			else
			{
				var nextMessage:Message = messageArray[currentMessage];
				if (nextMessage.active) { return null; } else
				{
					nextMessage.active = true;
					if (currentMessage < messageArray.length) { currentMessage ++; }
					return nextMessage;
				}
			}
		}
	}
}