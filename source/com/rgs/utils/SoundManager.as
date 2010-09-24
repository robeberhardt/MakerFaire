package com.rgs.utils
{
	import com.greensock.TweenMax;
	import com.rgs.sound.*;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class SoundManager extends Sprite
	{
		private static var instance						: SoundManager;
		private static var allowInstantiation			: Boolean;
		
		private static const MAX_CHANNELS				: int = 8;
		
		public static const INVADER_SOUNDS				: String = "INVADER_SOUNDS";
		public static const ARRIVAL_SOUNDS				: String = "ARRIVAL_SOUNDS";
		public static const DEPARTURE_SOUNDS			: String = "DEPARTURE_SOUNDS";
		public static const EXPLOSION_SOUNDS			: String = "EXPLOSION_SOUNDS";
		public static const HOOKUP_SOUNDS				: String = "HOOKUP_SOUNDS";
		
		private var invaderSounds						: Array;
		private var arrivalSounds						: Array;
		private var departureSounds						: Array;
		private var explosionSounds						: Array;
		private var hookupSounds						: Array;
		
		private var availableChannels					: Array;
		
		private var active								: Boolean;
		
		public function SoundManager(name:String="SoundManager")
		{
			if (!allowInstantiation) {
				throw new Error("Error: Instantiation failed: Use SoundManager.getInstance()");
			} else {
				this.name = name;
				active = true;
				if (stage) { init(); } else { addEventListener(Event.ADDED_TO_STAGE, init); }
			}
		}
		
		public static function getInstance(name:String = "SoundManager"):SoundManager {
			if (instance == null) {
				allowInstantiation = true;
				instance = new SoundManager(name);
				allowInstantiation = false;
			}
			return instance;
		}
		
		private function init(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			availableChannels = new Array();
			
			for (var i:int=0; i<MAX_CHANNELS; i++)
			{
				availableChannels.push(new SoundChannel());
			}
			
			invaderSounds = new Array();
			invaderSounds.push(new invadersound1());
			invaderSounds.push(new invadersound2());
			invaderSounds.push(new invadersound3());
			invaderSounds.push(new invadersound4());
			
			arrivalSounds = new Array();
			arrivalSounds.push(new arrival1());
			arrivalSounds.push(new arrival2());
			arrivalSounds.push(new arrival3());
			arrivalSounds.push(new arrival4());
			arrivalSounds.push(new arrival5());
			
			departureSounds = new Array();
			departureSounds.push(new depart1());
			departureSounds.push(new depart2());
			
			explosionSounds = new Array();
			explosionSounds.push(new explode1());
			
			hookupSounds = new Array();
			hookupSounds.push(new hookup1());
			hookupSounds.push(new hookup2());
			hookupSounds.push(new hookup3());
			hookupSounds.push(new hookup4());
			hookupSounds.push(new hookup5());
			
		}
		
		public function playSound(category:String, delay:Number = 0, vol:Number = 1):void
		{
			switch (category)
			{
				case INVADER_SOUNDS :
						playRandom(invaderSounds, delay, vol);
					break;
				
				case ARRIVAL_SOUNDS :
						playRandom(arrivalSounds, delay, vol);
					break;
				
				case DEPARTURE_SOUNDS :
						playRandom(departureSounds, delay, vol);
					break;
				
				case EXPLOSION_SOUNDS :
						playRandom(explosionSounds, delay, vol);
					break;
				
				case HOOKUP_SOUNDS :
						playRandom(hookupSounds, delay, vol);
					break;
			}
		}
		
		private function playRandom(soundsList:Array, delay:Number, vol:Number):void
		{
			if (active && availableChannels.length > 0)
			{
				var myChannel:SoundChannel = availableChannels.shift();
				var mySound:* = soundsList[Math.floor(Math.random()*soundsList.length)];
				var t:SoundTransform = new SoundTransform(vol);
				
				TweenMax.delayedCall(delay, function()
				{
					myChannel = mySound.play();
					myChannel.soundTransform = t;
					myChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
					
					//trace("playing... available channels: " + availableChannels.length);
				});
			}
		}
		
		private function onSoundComplete(e:Event):void
		{
			e.target.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			availableChannels.push(e.target);
			
			//trace("sound complete from " + e.target);
			//trace("available channels length: " + availableChannels.length);
		}
		
		public function toggleSound():void
		{
			active = !active;
			trace("sound active is " + active);
		}
	}
}