package gamemode 
{
	import flash.display.Sprite;
	import flash.events.ServerSocketConnectEvent;
	import gevent.DeathEvent;
	import gevent.HurtEvent;
	import gevent.JoinEvent;
	import gevent.LeaveEvent;
	import plugin.BasePlugin;
	import Streamy.MsgHandler;
	
	public class BaseGamemode extends Sprite
	{
		
		public static const LAVA:int = -1;
		public static const FALL:int = -2;
		public static const LASER:int = -3;
		
		public static const DEFAULT:int = 0;
		public static const ENVIRONMENT:int = 1;
		public static const JUMPKILL:int = 2;
		public static const BULLET:int = 3;
		
		public function BaseGamemode() 
		{
			super();
			for each (var plug:BasePlugin in ServerInfo.pl)
			{
				plug.init();
			}
		}
		
		public function mapProperties(data:Object):void
		{
			ServerInfo.map = data["name"];
			ServerInfo.gamemode = data["gamemode"];
		}
		
		public function update(elapsed:Number):void
		{
			DefaultHooks.update();
		}
		
		public function shutdown():void
		{
			
		}
		
		public function onHurt(e:HurtEvent):void
		{
			
		}
		
		public function onDeath(e:DeathEvent):void
		{
			
		}
		
		public function onJoin(e:JoinEvent):void
		{
			
		}
		
		public function onLeave(e:LeaveEvent):void
		{
			
		}
		
		public function onMsg(e:MsgHandler):void
		{
			
		}
		
		public function createScore():void
		{
			
		}
	}

}