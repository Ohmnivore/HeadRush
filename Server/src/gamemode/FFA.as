package gamemode 
{
	import gevent.DeathEvent;
	import gevent.HurtEvent;
	import gevent.JoinEvent;
	import gevent.LeaveEvent;
	import Streamy.MsgHandler;
	
	public class FFA extends BaseGamemode
	{
		
		public function FFA() 
		{
			super();
			DefaultHooks.hookEvents(this);
		}
		
		override public function onHurt(e:HurtEvent):void
		{
			DefaultHooks.handleDamage(e.hurtinfo);
		}
		
		override public function onDeath(e:DeathEvent):void
		{
			DefaultHooks.handleDeath(e.deathinfo);
		}
		
		override public function onJoin(e:JoinEvent):void
		{
			DefaultHooks.handleJoin(e);
		}
		
		override public function onLeave(e:LeaveEvent):void
		{
			DefaultHooks.handleLeave(e);
		}
		
		override public function onMsg(event:MsgHandler):void
		{
			if (event.id == Msg.keystatus.ID)
			{
				DefaultHooks.handleKeys(event);
			}
		}
	}

}