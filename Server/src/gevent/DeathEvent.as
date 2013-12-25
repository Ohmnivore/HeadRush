package gevent 
{
	import flash.events.Event;
	
	public class DeathEvent extends Event
	{
		public static const DEATH_EVENT:String = "death_event";
		public var deathinfo:HurtInfo;
		
		public function DeathEvent(type:String, info:HurtInfo, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			deathinfo = info;
		}
		
		public override function clone():Event
		{
			return new HurtEvent(type, deathinfo, bubbles, cancelable);
		}
	}

}