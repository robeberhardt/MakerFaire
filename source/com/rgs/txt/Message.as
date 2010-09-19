package com.rgs.txt
{
	import flash.display.Sprite;
	
	public class Message extends Sprite
	{
		private var _index						: uint;
		private var _address					: String;
		private var _text						: String;
		public var shortMessage					: String;
		private var _timestamp					: String;
		private var _day						: String;
		private var _time						: String;
		private var _offset						: String;
		private var _date						: Date;
		
		public function Message()
		{
//			address = adr;
//			message = msg;
//			if (message.length <= 25) 
//			{ 
//				shortMessage = message;
//			} 
//			else
//			{
//				shortMessage = message.substr(0, 24) + "…";
//			}
//			timestamp = tms;
//			date = makeDate();
		}
		
		/*
		public function init(address:String, message:String, timestamp:String):void
		{
		address = address;
		message = message;
		timestamp = timestamp;
		date = makeDate();
		}
		*/
		
		
		
		override public function toString():String
		{
			return "[ Message " + _index + " ::: " + shortMessage + ", " + _address + ", " + _timestamp + " ]";
		}
		
		public function set address(val:String):void
		{
			_address = val;
		}
		
		public function set text(val:String):void
		{
			_text = val;
			if (_text.length <= 25) 
			{ 
				shortMessage = _text;
			} 
			else
			{
				shortMessage = _text.substr(0, 24) + "…";
			}
		}
		
		public function set timestamp(val:String):void
		{
			_timestamp = val;
		}
		
		public function get date():Date
		{
			_day = _timestamp.slice(0, _timestamp.indexOf(" "));
			_time = _timestamp.slice(_timestamp.indexOf(" ")+1, _timestamp.lastIndexOf(" "));
			_offset = _timestamp.slice(_timestamp.lastIndexOf(" ")+1);
			_day = _day.split("-").join("/");
			return new Date(_day + " " + _time + " " + _offset);
		}
		
		public function set index(val:uint):void
		{
			_index = val;
		}
	}
}