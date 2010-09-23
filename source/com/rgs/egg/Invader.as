package com.rgs.egg
{
	import com.greensock.TweenMax;
	import com.rgs.egg.*;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Invader extends Sprite
	{
		private var theInvader : MovieClip;
		private var invaders	: Array;
		
		public function Invader()
		{
			invaders = new Array();
			invaders = [new invader1(), new invader2(), new invader3(), new invader4()];
			trace("INVADERS ARE : " + invaders);
			if (stage) { init(); } else { addEventListener(Event.ADDED_TO_STAGE, init); }
			
			
			
			
			
		}
		
		private function init(e:Event=null)
		{
			for each (var i:MovieClip in invaders)
			{
				addChild(i);
			}
		}
		
		public function invade():void
		{
			
			theInvader = invaders.shift();
			
			trace("ALL YOUR BASE ARE BELONG TO US");
			theInvader.x = -100;
			theInvader.y = 100;
			TweenMax.to(theInvader, 25, { x: stage.stageWidth + 100, y: stage.stageHeight - 300, onComplete:putback } );
		}
		
		private function putback():void
		{
			trace("putback: " );
			invaders.push(theInvader);
			trace(invaders);
		}
	}
}