package com.rgs.sprites
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
		
		private var theMessageSprite							: MessageSprite;
		
		public var readySignal									: Signal;
		public var spriteCompleteSignal							: Signal;
		
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
		private var mFields										: Array;
		
		private var spriteArray									: Array;
		private var fieldGroupIndex								: int;
		private var fieldGroupCounter							: int;
		private var sourceFields								: Array;
		private var pattern										: Array;
		
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
			spriteArray = new Array();
			readySignal = new Signal(Array);
			spriteCompleteSignal = new Signal();
		}
		
		public function make(m:String):void
		{
			trace("making from " + m);
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
				
				
				// now lets begin line count test
				newSize = origSize;
				testTimer.removeEventListener(TimerEvent.TIMER, testTruncation);
				testTimer.addEventListener(TimerEvent.TIMER, testLineCount);
				testTimer.start();
			}
		}
		
		private function testLineCount(e:TimerEvent):void
		{
			testTimer.stop();
			var numlines:int = field.numLines;
			
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
				stf = new SplitTextField(field, "lines");
				
				sourceFields = stf.textFields;
				
				// length of array indicated number of messages
				// value of each member of array indicates line count for that message
				
				if (numlines <= 3)
				{
					//makeFieldGroups(stf.textFields, [3]);
					pattern = [3];
				}
				else if (numlines ==4)
				{
					//makeFieldGroups(stf.textFields, [2, 2]);
					pattern = [2, 2];
				}
				else if (numlines == 5) 
				{
					//makeFieldGroups(stf.textFields, [3, 2]);
					pattern = [3,2];
				}
				else if (numlines == 6)
				{
					//makeFieldGroups(stf.textFields, [3, 3]);
					pattern = [3,3];
				}
				else if (numlines == 7)
				{
					//makeFieldGroups(stf.textFields, [2, 2, 3]);
					pattern = [2,2,3];
				}
				else if (numlines == 8)
				{
					//makeFieldGroups(stf.textFields, [3, 3, 2]);
					pattern = [3,3,2];
				}
				else
				{
					//makeFieldGroups(stf.textFields, [3, 3, 3]);
					pattern = [3,3,3];
				}
				
				
				spriteArray = SpriteManager.getInstance().getSpritesForUpdate(pattern.length);
				fieldGroupCounter = 0;
				fieldGroupIndex = 0;
				makeNextFieldGroup();
			}
		}
		
		private function makeNextFieldGroup():void
		{
			
			if (fieldGroupCounter < spriteArray.length)
			{
				spriteCompleteSignal.addOnce(function(newSprite:MessageSprite)
				{
					trace("==> updated " + newSprite);
					fieldGroupIndex += pattern[fieldGroupCounter];
					fieldGroupCounter ++;
					makeNextFieldGroup();
				});
					
				// pass in the next sprite from the spriteArray, update it with bitmaps created from this slice of the sourcefields
				updateSprite(spriteArray[fieldGroupCounter], sourceFields.slice(fieldGroupIndex, fieldGroupIndex + pattern[fieldGroupCounter]));
			}
			else
			{
				// we're done
				trace("we're all done");
				readySignal.dispatch(spriteArray);
			}
		}
		
		private function updateSprite(theSprite:MessageSprite, fields:Array):void
		{
			
			
			while (theSprite.bitmapHolder.numChildren > 0)
			{
				theSprite.bitmapHolder.removeChildAt(0);
			}
			
			var yOffset:Number = 0;
			for (var j:int=0; j<fields.length; j++)
			{
				var theField:TextField = fields[j];
				var theFormat:TextFormat = theField.getTextFormat();
				theField.text = " " + theField.text + " \n";
				theField.setTextFormat(theFormat);
				var bData:BitmapData = new BitmapData(theField.textWidth, theField.textHeight, true, 0x00000000);
				bData.draw(theField, null, null, null, null, true);
				var bmap:Bitmap = new Bitmap(bData); 
				//bmap.blendMode = BlendMode.INVERT;
				bmap.smoothing = true;
				theSprite.bitmapHolder.addChild(bmap);
				bmap.y = yOffset;
				bmap.x = Math.round(maxWidth*.5) - Math.round(bmap.width * .5);
				yOffset += (theField.textHeight * .8);
			}
			
			theSprite.bitmapHolder.x = -Math.round(theSprite.bitmapHolder.width * .5);
			theSprite.bitmapHolder.y = -Math.round(theSprite.bitmapHolder.height * .5);		
			
			
			spriteCompleteSignal.dispatch(theSprite);
		}
		
		private function makeSprites(fields:Array):void
		{
			trace("making sprites from:");
			for (var x:int = 0; x < fields.length; x++)
			{
				trace(fields[x].text);
			}
			SpriteManager.getInstance().spriteReadySignal.addOnce(function(mSprite:MessageSprite)
			{
				trace("");
			});
		}
		
		/*
		private function makeSprites(fields:Array):void
		{
			trace("making sprites from:\n");
			for (var x:int = 0; x < fields.length; x++)
			{
				trace(fields[x].text);
			}
			var spriteArray:Array = new Array();
			
			for (var i:int=0; i<fields.length; i++)
			{	trace("\ni: " + i);
				SpriteManager.getInstance().mSpriteSignal.addOnce(function(mSprite:MessageSprite)
				{
					trace("got mSprite: " + mSprite);
					var innerYoffset:Number = 0;
					
					for (var j:int=0; j<fields[i].length; j++)
					{
						trace("i: " + i + ", j: " + j);
						var theField:TextField = fields[i][j];
						var theFormat:TextFormat = theField.getTextFormat();
						theField.text = " " + theField.text + " \n";
						theField.setTextFormat(theFormat);
						var bData:BitmapData = new BitmapData(theField.textWidth, theField.textHeight, true, 0x00000000);
						bData.draw(theField, null, null, null, null, true);
						var bmap:Bitmap = new Bitmap(bData); 
						//bmap.blendMode = BlendMode.INVERT;
						bmap.smoothing = true;
						mSprite.bitmapHolder.addChild(bmap);
						bmap.y = innerYoffset;
						bmap.x = Math.round(maxWidth*.5) - Math.round(bmap.width * .5);
						innerYoffset += (theField.textHeight * .8);
					}
					
					mSprite.bitmapHolder.x = -Math.round(mSprite.bitmapHolder.width * .5);
					mSprite.bitmapHolder.x = -Math.round(mSprite.bitmapHolder.width * .5);
					mSprite.bitmapHolder.y = -Math.round(mSprite.bitmapHolder.height * .5);		
					trace("   --> pushing " + mSprite);
					spriteArray.push(mSprite);
					
				});
				
				SpriteManager.getInstance().getNextSprite();
			}
			
		}
		*/
		
		/*
		private function testLineCount(e:TimerEvent):void
		{
			testTimer.stop();
			
			
			stf = new SplitTextField(field, "lines");
			
			var numlines:Number = stf.textFields.length;
			trace("testing line count - numlines: " + numlines);
			
			if (numlines > 9)
			{
				trace("we're over 9 lines");
				newSize --;
				format.size = newSize;
				field.setTextFormat(format);
				field.width = 300;
				
				//stf.destroy();
				testTimer.start();
			}
			else
			{
				
				trace("we're under 9 lines");
				//stf = new SplitTextField(field, "lines");
				//lineCount = stf.textFields.length;
				
				// length of array indicated number of messages
				// value of each member of array indicates line count for that message
				
				if (numlines <= 3)
				{
					makeFieldGroups(stf.textFields, [3]);
				}
				else if (numlines ==4)
				{
					makeFieldGroups(stf.textFields, [2, 2]);
				}
				else if (numlines == 5) 
				{
					makeFieldGroups(stf.textFields, [3, 2]);
				}
				else if (numlines == 6)
				{
					makeFieldGroups(stf.textFields, [3, 3]);
				}
				else if (numlines == 7)
				{
					makeFieldGroups(stf.textFields, [2, 2, 3]);
				}
				else if (numlines == 8)
				{
					makeFieldGroups(stf.textFields, [3, 3, 2]);
				}
				else
				{
					makeFieldGroups(stf.textFields, [3, 3, 3]);
				}
			}
		}
		*/
		

		
		
		
//		private function makeFieldGroups(fields:Array, pattern:Array):void
//		{
//			trace("fields array length: " + fields.length + ", pattern: " + pattern);
//			var index:int = 0;
//			
//			for (var i:int=0; i < pattern.length; i++)
//			{
//				mFields = new Array();
//				mFields.push(fields.slice(index, index+pattern[i]));
//				makeSprites(mFields);
//				index += pattern[i];
//			}
//		}
		
		
	}
}