package com.rgs.utils 
{
	public class Utils
	{
		public function Utils()
		{
		}
		
		public static function deg2rad(d:Number):Number 
		{
			return d * Math.PI / 180;
		}
		
		public static function rad2deg(r:Number):Number
		{
			return r * 180 / Math.PI;
		}
	}
}