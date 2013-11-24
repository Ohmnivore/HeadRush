package  
{
	import org.flixel.*;

	/**
	 * ...
	 * @author Grey
	 */
	public class Registry 
	{
			public static var totdiggers:int = 0;		
			public static var mapray:Array;	
			public static var ddig:int = 0;
			
			public static var playstate:PlayState;
			
			public static function getRandomElementOf(array:Array):Object 
			{
				var idx:int=Math.floor(Math.random() * array.length);
				return array[idx];
			}
	}

}