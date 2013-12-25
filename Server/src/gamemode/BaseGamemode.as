package gamemode 
{
	import flash.display.Sprite;
	import gevent.DeathEvent;
	import gevent.HurtEvent;
	
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
			addEventListener(HurtEvent.HURT_EVENT, onHurt);
			addEventListener(DeathEvent.DEATH_EVENT, onDeath);
		}
		
		public function mapProperties(data:Object):void
		{
			ServerInfo.map = data["mapname"];
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
	}

}