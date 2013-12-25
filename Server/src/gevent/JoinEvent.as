package gevent 
{
	import flash.events.Event;
	import flash.events.ServerSocketConnectEvent;
	import gevent.HurtInfo;
	
	public class JoinEvent extends Event
	{
		public static const JOIN_EVENT:String = "join_event";
		public var joininfo:ServerSocketConnectEvent;
		
		public function JoinEvent(type:String, info:ServerSocketConnectEvent, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			joininfo = info;
		}
		
		public override function clone():Event
		{
			return new JoinEvent(type, joininfo, bubbles, cancelable);
		}
	}

}