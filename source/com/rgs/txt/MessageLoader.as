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
	
	public class MessageLoader extends Sprite
	{
		private static var instance						: MessageLoader;
		private static var allowInstantiation			: Boolean;
		
		public var loadedSignal 						: Signal;
		public var updateSignal							: Signal;
		private var loader 								: XMLLoader;
		private var status								: String;
		private var path								: String;
		
		
		public var progressSignal						: Signal;
		
		private var pollTimer							: Timer;
		
		
		private var theXML								: XML;
		private var xmlLength							: int = 0;
		
		private var messageArray						: Array;
		public var currentMessage						: int;
		public var lastMessage							: int;
		
		public static const NOT_LOADED_STATUS			: String = "Not Loaded";
		public static const LOADED_STATUS				: String = "Loaded";
		public static const ERROR_STATUS				: String = "Error";   
		
		private static const MAX_MESSAGES				: uint = 5000;
		private static const POLL_INTERVAL				: uint = 5;
		
		public function MessageLoader(name:String="MessageLoader")
		{
			if (!allowInstantiation) {
				throw new Error("Error: Instantiation failed: Use MessageLoader.getInstance()");
			} else {
				this.name = name;
				init();
			}
		}
		
		public static function getInstance(name:String = "MessageLoader"):MessageLoader {
			if (instance == null) {
				allowInstantiation = true;
				instance = new MessageLoader(name);
				allowInstantiation = false;
			}
			return instance;
		}
		
		private function init():void
		{
			loadedSignal = new Signal();
			updateSignal = new Signal();
			progressSignal = new Signal(Number);
			
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
			loader = new XMLLoader(path, { onComplete: loadComplete, onError: loadError, onProgress: progressHandler });
			loader.auditSize();
			pollTimer = new Timer(POLL_INTERVAL*1000);
			pollTimer.addEventListener(TimerEvent.TIMER, onPollTimer);
			pollTimer.start();
			
		}
		
		private function progressHandler(e:LoaderEvent):void
		{
			progressSignal.dispatch(e.target.progress);
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
						
			xmlLength = theXML..array.dict.length();
			
			//trace("loadComplete - xmlLength = " + xmlLength);
			
			if (xmlLength-1 < lastMessage)
			{
				//trace("things got smaller...");
				lastMessage = xmlLength-1;
				currentMessage = lastMessage;
			}
			//if (xmlLength > 0) { currentMessage = 0; }
			
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
			//trace("getNextMessage::: lastMessage: " + lastMessage + ", currentMessage: " + currentMessage);
			if (lastMessage > currentMessage)
			{
				currentMessage ++;
				return messageArray[currentMessage];
			}
			else
			{
				return null;
			}
		}
	}
}