package  
{
	import entity.Life;
	import flash.utils.Dictionary;
	import gamemode.BaseGamemode;
	import gamemode.FFA;
	import org.flixel.*;
	import RushServer;

	public class Registry 
	{
		public static var setupdone:Boolean = false;
		public static var msannounced:Boolean = false;
		public static var maploaded:Boolean = false;
		
		public static var totdiggers:int = 0;		
		public static var mapray:Array;	
		public static var ddig:int = 0;
		
		public static var playstate:PlayState;
		public static var server:RushServer;
		public static var clients:Dictionary = new Dictionary();
		public static var gm:BaseGamemode;
		
		public static var spawntimer:uint;
		
		public static var devconsole:DeveloperConsole;
		public static var cli:CLI = new CLI(FlxG._game);
		
		public static const ORANGE:uint = 0xffFF9100;
		
		public static var chatrect:FlxSprite = new FlxSprite(0, 0);
		
		public static var ms:MasterServer;
		
		public static var leadset:ScoreSet;
		
		public static var leadsetjson:String;
		
		public static var maprotation:Array = ["TestMap"];
		public static var levelindex:int = 0;
		
		public static function getRandomElementOf(array:Array):* 
		{
			var idx:int=Math.floor(Math.random() * array.length);
			return array[idx];
		}
		
		public static function noScroll(s:FlxObject):void
		{
			s.scrollFactor.x = s.scrollFactor.y = 0;
		}
		
		public static function canSee(p:Player, obj:FlxObject):Boolean
		{
			var pcords:FlxPoint = p.getMidpoint();
			var scr:FlxObject = new FlxObject(pcords.x - p.scrwidth / 2, pcords.y - p.scrheight / 2, p.scrwidth, p.scrheight);
			if (obj.overlaps(scr)) return true;
			else return false;
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
		
		public static function nextmap():void
		{
			levelindex++;
			if (levelindex >= Registry.maprotation.length)
			{
				levelindex = 0;
			}
			
			Registry.playstate.LoadMap();
		}
		
		public static function changemap(index):void
		{
			levelindex = index;
			Registry.playstate.LoadMap();
		}
	}

}