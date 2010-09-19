package com.rgs.rings 
{
	import com.greensock.TweenMax;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import com.rgs.fonts.FontLibrary;
	
	import org.osflash.signals.Signal;
	
	import com.rgs.utils.Logger;
	
	public class Particle extends Sprite
	{
		public var index					: int;
		
		public var bg						: Sprite;
		
		private var field					: TextField;
		private var format					: TextFormat;
		private var _text					: String;
		private var _font					: String;
		private var _size					: int;
		private var _scale : Number;
		
		public var blur						: Number;
		
		public var lifespan					: int;
		public var age						: int;
		public var birthing					: Boolean = false;
		public var dying					: Boolean = false;
		
		public var changed					: Signal;
		
		public function Particle(theText:String="Hello", theFont:String="default", theScale:Number=1)
		{
			graphics.beginFill(0x0000FF, 1);
			graphics.drawCircle(0, 0, 20);
			graphics.endFill();
			
			bg = new Sprite();
			bg.graphics.beginFill(0x0000FF, .25);
			bg.graphics.drawRect(0, 0, 500, 500);
			bg.graphics.endFill();
			addChild(bg);
			
			//bg.x = bg.y = -250;
			
			scaleX = scaleY = theScale;
			
			cacheAsBitmap = true;
			alpha = 1;
			visible = true;
			
			changed = new Signal();
			
			format = new TextFormat();
			format.leading = 1;
			format.leading = -10;
			format.align = TextFormatAlign.CENTER;
			format.letterSpacing = 0;
			format.color = 0xFFFFFF;
			
			
			
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
			//field.x = -(field.width * .5);
			field.antiAliasType = AntiAliasType.ADVANCED;
			
			if (theFont == "default") { font = FontLibrary.HELVETICA_ROMAN; } else { font = theFont; }
			size = 72;	
			text = theText;
			
			field.width = field.textWidth;
			
			trace("textfield width: " + field.textWidth + ", height: " + field.textHeight);
			var upperLeftRect:Rectangle = field.getCharBoundaries(0);
			trace(field.text.length);
			var lowerRightRect:Rectangle = field.getCharBoundaries(20);
			trace(upperLeftRect + ", " + lowerRightRect);
			
			
//			blur = Math.random()*4;
//			var myBlur:BlurFilter = new BlurFilter(blur, blur, 1);
//			this.filters = [myBlur];
			
			
			if (stage) { init(); } else { addEventListener(Event.ADDED_TO_STAGE, init); }
			
		}
		
		private function init(e:Event=null):void
			
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addChild(field);
			
			var bData:BitmapData = new BitmapData(field.textWidth, field.textHeight, true, 0x00000000);
			bData.draw(field, null, null, null, null, true);
			var bmap:Bitmap = new Bitmap(bData); 
			bmap.smoothing = true;
			addChild(bmap);
//			field.visible = false;
			
			
		
//			graphics.lineStyle(1, 0xff0000, 1, false);
//			graphics.drawRect(0, 0, width, height);
			
		}
		
		override public function toString():String
		{
			return "[Particle   id: " + text + "]";
		}
		
		public function get text():String
		{
			return field.text;
		}
		
		public function set text(value:String):void
		{
			Logger.log("setting text to " + value);
			field.text = value + "\n ";
			update();
		}
		
		public function set font(value:String):void
		{
			format.font = value;
			update();
		}
		
		public function set size(value:int):void
		{
			format.size = value;
			field.setTextFormat(format);
			update();
		}
		
		public function update():void
		{
			field.setTextFormat(format);
			changed.dispatch();
		}
		
		public function get scale():Number 
		{
			return _scale;
		}
		
		public function set scale(value:Number):void
		{
			//trace("setting scale to " + value);
			_scale = scaleX = scaleY = value;
		}
	}
}