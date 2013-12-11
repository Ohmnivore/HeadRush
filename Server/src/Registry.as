package  
{
	import org.flixel.*;
	import RushServer;

	public class Registry 
	{
			public static var totdiggers:int = 0;		
			public static var mapray:Array;	
			public static var ddig:int = 0;
			
			public static var playstate:PlayState;
			public static var server:RushServer;
			
			public static var spawntimer:uint;
			
			public static function getRandomElementOf(array:Array):* 
			{
				var idx:int=Math.floor(Math.random() * array.length);
				return array[idx];
			}
	}

}