package com.rgs.txt
{
	import com.greensock.text.SplitTextField;
	import com.rgs.fonts.FontLibrary;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import org.osflash.signals.Signal;
	
	public class SpriteFactory extends Sprite
	{
		
		private static var instance								: SpriteFactory;
		private static var allowInstantiation					: Boolean;
		
		public var readySignal									: Signal;
		
		private var origSize 									: Number;
		private var maxWidth									: Number;
		private var format										: TextFormat;
		private var field										: TextField;
		private var wordsArray									: Array;
		private var newSize										: Number;
		private var wordMatch									: Boolean;
		private var validLineCount								: Boolean;
		private var testTimer									: Timer;
		private var lineCount									: int;
		private var stf											: SplitTextField;
		private var mFields										: Array 
		
		public function SpriteFactory(name:String="SpriteFactory")
		{
			if (!allowInstantiation) {
				throw new Error("Error: Instantiation failed: Use SpriteFactory.getInstance()");
			} else {
				this.name = name;
				init();
			}
		}
		
		public static function getInstance(name:String = "SpriteFactory"):SpriteFactory {
			if (instance == null) {
				allowInstantiation = true;
				instance = new SpriteFactory(name);
				allowInstantiation = false;
			}
			return instance;
		}
		
		private function init():void
		{
			origSize = 70;
			maxWidth = 300;
			
			format = new TextFormat();
			format.font = FontLibrary.HELVETICA_BOLD;
			format.size = origSize;
			format.letterSpacing = -0.5;
			format.leading = -10;
			format.align = TextFormatAlign.CENTER;
			format.color = 0xFFFFFF;
			
			field = new TextField();
			field.selectable = false;
			field.antiAliasType = AntiAliasType.ADVANCED;
			field.autoSize = TextFieldAutoSize.CENTER;
			field.multiline = true;
			field.wordWrap = true;
			field.width = maxWidth;
			field.embedFonts = true;
//			addChild(field);
			
			wordsArray = new Array();
			readySignal = new Signal(Array);
		}
		
		public function make(m:String):void
		{
			// first we'll remove double-spaces
			while(m.indexOf("  ") != -1)
			{
				m = m.split("  ").join(" ");
			}
			
			// new remove any trailing spaces
			while (m.substr(m.length-1, 1) == " ")
			{
				m = m.substr(0, m.length-1);
			}
		
			// and also any leading spaces
			while (m.substr(0, 1) == " ")
			{
				m = m.substr(1, m.length-1);
			}
			
			field.text = m;
			field.setTextFormat(format);
			field.width = field.textWidth+10;
			
			wordsArray = field.text.split(" ");
			
			newSize = origSize;
			testTimer = new Timer(10);
			testTimer.addEventListener(TimerEvent.TIMER, testTruncation);
			testTimer.start();
		}
		
		private function testTruncation(e:TimerEvent):void
		{
			testTimer.stop();
			stf = new SplitTextField(field, "words");
			var validCount:int = 0;
			for (var i:int=0; i<stf.textFields.length; i++)
			{
				//trace("i: " + i);
				var formattedWord:String = stf.textFields[i].text;
				for (var j:int=0; j<wordsArray.length; j++)
				{
					//trace("   j: " + j);
					var origWord:String = wordsArray[j];
					
					if (formattedWord == wordsArray[j]) 
					{
						//trace(formattedWord + " matches " + origWord + "... VALID");
						validCount ++;
					}
				}
			}
			
			stf.destroy();
			//trace("after loops, valid count " + validCount);
			
			if (validCount < wordsArray.length)
			{
				//trace("that's not enough");
				newSize --;
				format.size = newSize;
				field.setTextFormat(format);
				testTimer.start();
			}
			else
			{
				//trace("all words were valid");
				testTimer.stop();
				
				// now lets begin line count test
				newSize = origSize;
				testTimer.removeEventListener(TimerEvent.TIMER, testTruncation);
				testTimer.addEventListener(TimerEvent.TIMER, testLineCount);
				testTimer.start();
			}
		}
		
		private function testLineCount(e:TimerEvent):void
		{
			stf = new SplitTextField(field, "lines");
			var numlines:int = stf.textFields.length;
			stf.destroy();
			
			if (numlines > 9)
			{
				newSize --;
				format.size = newSize;
				field.setTextFormat(format);
				field.width = 300;
				testTimer.start();
			}
			else
			{
				testTimer.stop();
				
				stf = new SplitTextField(field, "lines");
				lineCount = stf.textFields.length;
				
				// length of array indicated number of messages
				// value of each member of array indicates line count for that message
				
				if (lineCount <= 3)
				{
					makeFieldGroups(stf.textFields, [3]);
				}
				else if (lineCount ==4)
				{
					makeFieldGroups(stf.textFields, [2, 2]);
				}
				else if (lineCount == 5) 
				{
					makeFieldGroups(stf.textFields, [3, 2]);
				}
				else if (lineCount == 6)
				{
					makeFieldGroups(stf.textFields, [3, 3]);
				}
				else if (lineCount == 7)
				{
					makeFieldGroups(stf.textFields, [2, 2, 3]);
				}
				else if (lineCount == 8)
				{
					makeFieldGroups(stf.textFields, [3, 3, 2]);
				}
				else
				{
					makeFieldGroups(stf.textFields, [3, 3, 3]);
				}
			}
		}
		
		private function makeFieldGroups(fields:Array, pattern:Array):void
		{
			trace("fields array length: " + fields.length + ", pattern: " + pattern);
			var index:int = 0;
			
			for (var i:int=0; i < pattern.length; i++)
			{
				mFields = new Array();
				mFields.push(fields.slice(index, index+pattern[i]));
				makeSprites(mFields);
				index += pattern[i];
			}
		}
		
		private function makeSprites(fields:Array):void
		{
			var spriteArray:Array = new Array();
			
			for (var i:int=0; i<fields.length; i++)
			{
				var mSprite:MessageSprite = new MessageSprite();
				mSprite.cacheAsBitmap = true;
				mSprite.graphics.beginFill(0x00FF00, 1);
				mSprite.graphics.drawCircle(0, 0, 10);
				mSprite.graphics.endFill();
				
				var bmapHolder:Sprite = new Sprite();
				
				mSprite.addChild(bmapHolder);
				
				//addChild(mSprite);
				
//				mSprite.x = 600;
//				trace("outerY: " + outerY);
//				mSprite.y = outerY;
				
				var innerYoffset:Number = 0;
				
				for (var j:int=0; j<fields[i].length; j++)
				{
					var theField:TextField = fields[i][j];
					var theFormat:TextFormat = theField.getTextFormat();
					theField.text = " " + theField.text + " \n";
					theField.setTextFormat(theFormat);
					var bData:BitmapData = new BitmapData(theField.textWidth, theField.textHeight, true, 0x00000000);
					bData.draw(theField, null, null, null, null, true);
					var bmap:Bitmap = new Bitmap(bData); 
					//bmap.blendMode = BlendMode.INVERT;
					bmap.smoothing = true;
					bmapHolder.addChild(bmap);
					bmap.y = innerYoffset;
					bmap.x = Math.round(maxWidth*.5) - Math.round(bmap.width * .5);
					innerYoffset += (theField.textHeight * .8);
				}
				
				bmapHolder.x = -Math.round(bmapHolder.width * .5);
				bmapHolder.y = -Math.round(bmapHolder.height * .5);				
				spriteArray.push(mSprite);
			}
			
			readySignal.dispatch(spriteArray);
		
		}
	}
}