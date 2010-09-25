package com.rgs.utils
{
	import com.rgs.FramesClip;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class FramesManager extends Sprite
	{
		private var frame:FramesClip;
		
		public function FramesManager()
		{
			if (stage) { init(); } else { addEventListener(Event.ADDED_TO_STAGE, init); }
		}
		
		private function init(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			frame = new FramesClip();
			addChild(frame);
		}
		
		public function nextFrame():void
		{
			if (frame.currentFrame == frame.totalFrames)
			{
				frame.gotoAndStop(1);
			}
			else
			{
				frame.nextFrame();
			}
		}
	}
}