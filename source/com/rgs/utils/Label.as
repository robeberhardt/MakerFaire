package com.rgs.utils
{
	import com.rgs.fonts.FontLibrary;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class Label extends Sprite
	{
		private var field					: TextField;
		private var format					: TextFormat;
		private var _text					: String;
		private var _font					: String;
		private var _size					: int;
		private var _scale : Number;
		
		public function Label(value:String="hello")
		{
			trace("creating label with " + value);
			_text = value;
			if (stage) { init(); } else { addEventListener(Event.ADDED_TO_STAGE, init); }
		}
		
		private function init(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			format = new TextFormat();
			format.leading = 1;
			format.leading = -10;
			format.align = TextFormatAlign.CENTER;
			format.letterSpacing = 0;
			format.color = 0xFFFFFF;
			format.font = FontLibrary.HELVETICA_ROMAN;
			format.size = 10;
			
			field = new TextField();
			field.selectable = false;
			field.antiAliasType = AntiAliasType.ADVANCED;
			field.autoSize = TextFieldAutoSize.CENTER;
			field.multiline = true;
			field.wordWrap = true;
			field.width = 0;
			field.embedFonts = true;
			field.border = true;
			field.borderColor = 0xffffff;
			field.antiAliasType = AntiAliasType.ADVANCED;
		
			text = _text;
		}
		
		override public function toString():String
		{
			return "[Label: " + text + "]";
		}
		
		public function get text():String
		{
			return field.text;
		}
		
		public function set text(value:String):void
		{
			field.text = value + "\n ";
			update();
		}
		
		public function update():void
		{
			field.setTextFormat(format);
		}
	}
}