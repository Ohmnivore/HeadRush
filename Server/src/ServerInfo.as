package  
{
	import gamemode.*;
	import entity.*;
	import org.flixel.FlxSave;
	import plugin.*;
	
	public class ServerInfo 
	{
		public static var name:String = "New Server";
		public static var _map:String = "TestMap";
		public static var _gamemode:String = "FFA";
		public static var _currentp:uint = 0;
		public static var _maxp:uint = 12;
		public static var password:String = "";
		public static var _pub:Boolean = true;
		public static var ms:String = "http://headrushms.appspot.com/server";
		public static var dlurl:String = "https://dl.dropboxusercontent.com/u/229424261/hr/";
		public static var dlmanifests = ["splash.json"];
		
		public static var address:String = "127.0.0.1";
		
		public static var plugins:Array = ["Setup", "Address", "MapRotation"];
		public static var pl:Array = [];
		
		public static var save:FlxSave;
		public static var tosave:Object;
		
		public static function registercustoms():void
		{
			//Gamemodes
			FFA
			
			//Entities
			Life
			
			//Plugins
			Setup
			Address
			MapRotation
		}
		
		public static function get currentp():uint 
		{
			return _currentp;
		}
		public static function set currentp(value:uint):void 
		{
			_currentp = value;
			if (Registry.msannounced) Registry.ms.setplayers();
		}
		
		public static function get maxp():uint 
		{
			return _maxp;
		}
		public static function set maxp(value:uint):void 
		{
			_maxp = value;
			if (Registry.msannounced) Registry.ms.setplayers();
		}
		
		public static function get pub():Boolean 
		{
			return _pub;
		}
		public static function set pub(value:Boolean):void 
		{
			_pub = value;
			
			if (_pub) 
			{
				Registry.ms = new MasterServer(ServerInfo.ms);
				Registry.ms.announce();
			}
			else Registry.ms.shutdown();
		}
		
		public static function get map():String 
		{
			return _map;
			
		}
		public static function set map(value:String):void 
		{
			_map = value;
			if (Registry.msannounced) Registry.ms.setmap();
		}
		
		public static function get gamemode():String 
		{
			return _gamemode;
			
		}
		public static function set gamemode(value:String):void 
		{
			_gamemode = value;
			if (Registry.msannounced) Registry.ms.setmode();
		}
	}

}