package Streamy 
{
	import flash.events.Event;
	
	public class MsgHandler extends Event
	{
		public var id:uint;
		public var isTCP:Boolean;
		public var peer:ServerPeer;
		public static const MSG_EVENT:String = "msgevent";
		
		public function MsgHandler(Peer:ServerPeer = null, ID:uint = 10, IsTCP:Boolean = false) 
		{
			peer = Peer;
			id = ID;
			isTCP = IsTCP;
			
			super("msgevent");
		}
		
		public override function clone():Event
		{
			return new MsgHandler(peer, id, isTCP);
		}
	}

}