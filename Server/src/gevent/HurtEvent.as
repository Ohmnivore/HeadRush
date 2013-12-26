package gevent
{
	import flash.events.Event;
	import gevent.HurtInfo;
	
	public class HurtEvent extends Event
	{
		public static const HURT_EVENT:String = "hurt_event";
		public var hurtinfo:HurtInfo;
		
		public function HurtEvent(type:String, info:HurtInfo, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			hurtinfo = info;
		}
		
		public override function clone():Event
		{
			return new HurtEvent(type, hurtinfo, bubbles, cancelable);
		}
	}

}