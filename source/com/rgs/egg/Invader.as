package com.rgs.egg
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.rgs.egg.*;
	import com.rgs.utils.SoundManager;
	
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.osflash.signals.Signal;
	
	public class Invader extends Sprite
	{
		private var theInvader : MovieClip;
		private var invaders	: Array;
		public var invasionOverSignal : Signal;
		
		var begin:Point;
		var end:Point;
		var leftSide:Boolean;
		
		public function Invader()
		{
			invaders = new Array();
			invaders = [new invader1(), new invader2(), new invader3(), new invader4()];
			invasionOverSignal = new Signal();
			if (stage) { init(); } else { addEventListener(Event.ADDED_TO_STAGE, init); }
			
		}
		
		private function init(e:Event=null)
		{
			for each (var i:MovieClip in invaders)
			{
				addChild(i);
				i.x = -1000;
				i.gotoAndStop(1);
				i.blendMode = BlendMode.LIGHTEN;
			}
			begin = new Point();
			end = new Point();
		}
		
		public function invade():void
		{	
			
			
			if (invaders.length > 0)
			{
				
				theInvader = invaders.shift();
				SoundManager.getInstance().playSound(SoundManager.INVADER_SOUNDS, 4);
				leftSide = Boolean(Math.round(Math.random()));
				
				if (leftSide)
				{
					begin.x = -theInvader.width-10;
					begin.y = Math.random()*stage.stageHeight;
					end.x = stage.stageWidth + theInvader.width+10;
					end.y = Math.random()*stage.stageHeight;
				}
				else
				{
					begin.x = stage.stageWidth + theInvader.width+10;
					begin.y = Math.random()*stage.stageHeight;
					end.x = -theInvader.width-10;
					end.y = Math.random()*stage.stageHeight;
				}
				
				theInvader.x = begin.x;
				theInvader.y = begin.y;
				theInvader.gotoAndPlay(1);
				TweenMax.to(theInvader, Math.round(Math.random()*10)+10, { x: end.x, y: end.y, ease:Cubic.easeIn, onComplete:putback, onCompleteParams: [theInvader] } );
			}
			
		}
		
		private function putback(which:MovieClip):void
		{
			which.gotoAndStop(1);
			invaders.push(which);
			invasionOverSignal.dispatch();
		}
	}
}