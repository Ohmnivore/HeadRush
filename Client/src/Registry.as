package  
{
	import flash.utils.Dictionary;
	import org.flixel.*;
	import RushClient;
	import plugin.*;

	public class Registry 
	{
		public static var playstate:PlayState;
		public static var client:RushClient;
		public static var loadedmap:Boolean;
		public static var peers:Dictionary = new Dictionary;
		public static var loadedpeers:Boolean = false;
		public static var huds:Dictionary = new Dictionary;
		public static var chatrect:FlxSprite = new FlxSprite(0, 0);
		
		public static var plugins:Array = ["Address", "PublicBrowser", "LANBrowser", "DirectConnect", 
			"PlayerSettings"];
		public static var pl:Array = [];
		public static var save:FlxSave;
		public static var tosave:Object;
		
		public static var setupdone:Boolean = false;
		
		public static var ms:String = "http://headrushms.appspot.com/read";
		public static var servaddr:String = "127.0.0.1";
		
		public static var address:String = "127.0.0.1";
		
		public static var leadset:ScoreSet;
		
		public static var name:String = "Unnamed_player";
		
		public static var color:uint = 0xff00A8C2;
		
		public static function registercustoms():void
		{
			//Plugins to activate
			PublicBrowser
			LANBrowser
			DirectConnect
			Address
			PlayerSettings
		}
		
		public static function noScroll(s:FlxObject):void
		{
			s.scrollFactor.x = s.scrollFactor.y = 0;
		}
		
		public static function makeSkeleton(g:FlxGroup):void
		{
			if (g.length > 0)
			{
				g.callAll("kill", true);
				g.callAll("destroy", true);
				g.clear();
			}
		}
	}
}