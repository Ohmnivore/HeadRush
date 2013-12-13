package  
{
	import flash.utils.Dictionary;
	import org.flixel.*;
	import RushClient;

	public class Registry 
	{
		public static var playstate:PlayState;
		public static var client:RushClient;
		public static var loadedmap:Boolean;
		public static var peers:Dictionary = new Dictionary;
		public static var loadedpeers:Boolean = false;
		public static var huds:Dictionary = new Dictionary;
	}

}