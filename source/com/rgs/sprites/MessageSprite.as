package com.rgs.sprites
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	import com.greensock.text.SplitTextField;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	
	import org.osflash.signals.Signal;
	
	public class MessageSprite extends Sprite
	{
		public  var index						: int;
		private var _scale						: Number;
		public var bitmapHolder					: Sprite;
		private var _stf						: SplitTextField;
		private var glow						: GlowFilter;
		private var _busy						: Boolean;
		public var recycleSignal				: Signal;
		public var busySignal					: Signal;
		
		public function MessageSprite()
		{
			bitmapHolder = new Sprite();
			visible = false;
			alpha = 0;
			scale = 3;
			busy = false;
			recycleSignal = new Signal(MessageSprite);
			busySignal = new Signal(MessageSprite);
			if (stage) { init(); } else { addEventListener(Event.ADDED_TO_STAGE, init); }
		}
		
		public function init(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			glow = new GlowFilter(0xffffff, 1, 15, 15, 5, 5);
			filters = [glow];
			addChild(bitmapHolder);
			if (_stf) { addChild(_stf); }
//			graphics.beginFill(0x00FF00, 1);
//			graphics.drawCircle(0, 0, 10);
//			graphics.endFill();
		}
		
		override public function toString():String
		{
			return "[ MessageSprite ::: index=" + index + " ]"; 
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
		
		public function arrive():void
		{
			graphics.clear();
			graphics.lineStyle(2, 0xFF0000, 1);
			graphics.drawRect(-(bitmapHolder.width*.5), -(bitmapHolder.height*.5), bitmapHolder.width, bitmapHolder.height);
			graphics.endFill();
			trace("arriving");
			trace(x, y);
			TweenMax.to(this, 3, { autoAlpha: 1 });
			TweenMax.to(this, 3, { scale: 1, ease:Cubic.easeOut });
			TweenMax.to(this, 4, { delay: 1, glowFilter:{strength: 0, blurX: 0, blurY: 0} });
		}
		
		public function depart():void
		{
			TweenMax.to(this, .5, { alpha: 0, onComplete: recycle });
		}
		
		private function recycle():void
		{
			trace("recycling " + this);
			visible = false;
			alpha = 0;
			scale = 3;
			busy = false;
			glow.strength = 5;
			glow.quality = 5;
			glow.blurX = 15;
			glow.blurY = 15;
			recycleSignal.dispatch(this);
		}

		public function get busy():Boolean
		{
			return _busy;
		}

		public function set busy(value:Boolean):void
		{
			_busy = value;
			if (_busy)
			{
				busySignal.dispatch(this);
			}
		}


	}
}