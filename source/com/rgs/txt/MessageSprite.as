package com.rgs.txt
{
	import com.greensock.text.SplitTextField;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class MessageSprite extends Sprite
	{
		private var _scale						: Number;
		public var bmapHolder					: Sprite;
		private var _stf						: SplitTextField;
		
		public function MessageSprite()
		{
			scale = 1;
			bmapHolder = new Sprite();
			if (stage) { init(); } else { addEventListener(Event.ADDED_TO_STAGE, init); }
		}
		
		public function init(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addChild(bmapHolder);
			if (_stf) { addChild(_stf); }
		}

		public function get scale():Number
		{
			return _scale;
		}

		public function set scale(value:Number):void
		{
			_scale = value;
			scaleX = scaleY = value;
		}
		
		public function get stf():SplitTextField
		{
			return _stf;
		}
		
		public function set stf(value:SplitTextField):void
		{
			_stf = value;
			_stf.x = 25;
			_stf.y = 25;
			trace("stf = " + _stf);
		}

	}
}