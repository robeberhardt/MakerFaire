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
			loadedSignal = new Signal(XML);
			updateSignal = new Signal();
			
			messageArray = new Array();
			for (var i:int = 0; i < MAX_MESSAGES; i++)
			{
				var m:Message = new Message();
				m.index = i;
				messageArray.push(m);
			}
			
			currentMessage = 0;
			lastMessage = 0;
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
			
//			trace(theXML..array.dict.length());
//			trace(theXML..array.dict[15-1].children()); // length-1 is FIRST message, length - lastMessage = LAST message);
//			
//			trace(theXML..array.dict[theXML..array.dict.length()-lastMessage]);
			
			var xmlLength:int = theXML..array.dict.length();
			trace("xmlLength = " + xmlLength);
			
			for (var i:int = lastMessage; i<xmlLength; i++)
			{
				var address:String = theXML..array.dict[i].children()[1];
				var text:String = theXML..array.dict[i].children()[3];
				var timestamp:String = theXML..array.dict[i].children()[7];
				var m:Message = messageArray[xmlLength - i] as Message;
				m.address = address;
				m.text = text;
				m.timestamp = timestamp;
				trace(m);
			}
			
//			for (var i:int=theXML..array.dict.length()+1; i > lastMessage; i--)
//			{
//				var ix:int = lastMessage-i;
//				
//				trace("last message is now " + lastMessage);
//				var address:String = theXML..array.dict[ix].children()[1];
//				var text:String = theXML..array.dict[ix].children()[3];
//				var timestamp:String = theXML..array.dict[ix].children()[7];
//				
//				var m:Message = messageArray[lastMessage-ix] as Message;
//				m.address = address;
//				m.text = text;
//				m.timestamp = timestamp;
//				
//				
//			}
//			
//			Logger.log("lastMessage: " + lastMessage + "\n" + Message(messageArray[lastMessage]).shortMessage + "\n---------------\n");
//			status = LOADED_STATUS;
//			loadedSignal.dispatch(loader.getContent(path));
//			pollTimer.start();
		}
		
		private function loadError(e:LoaderEvent):void
		{
			//Logger.log("load error " + e.text);	
			status = ERROR_STATUS;
		}
		
		public function getNextMessage():Message
		{
			var nextMessage:Message = messageArray[currentMessage];
			if (currentMessage < messageArray.length) { currentMessage ++; }
//			currentMessage ++;
//			if (currentMessage == messageArray.length) { currentMessage = 0; }
			return nextMessage;
		}
	}
}