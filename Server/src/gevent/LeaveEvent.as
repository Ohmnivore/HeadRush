package gevent 
{
	import flash.events.Event;
	
	public class LeaveEvent extends Event
	{
		public static const LEAVE_EVENT:String = "leave_event";
		public var leaveinfo:Event;
		
		public function LeaveEvent(type:String, info:Event, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			leaveinfo = info;
		}
		
		public override function clone():Event
		{
			return new LeaveEvent(type, leaveinfo, bubbles, cancelable);
		}
	}

}