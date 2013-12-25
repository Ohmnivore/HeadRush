package gamemode 
{
	import gevent.DeathEvent;
	import gevent.HurtEvent;
	
	public class FFA extends BaseGamemode
	{
		
		public function FFA() 
		{
			super();
		}
		
		override public function onHurt(e:HurtEvent):void
		{
			DefaultHooks.handleDamage(e.hurtinfo);
		}
		
		override public function onDeath(e:DeathEvent):void
		{
			
		}
	}

}