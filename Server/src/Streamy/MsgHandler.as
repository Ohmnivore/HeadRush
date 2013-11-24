package Streamy 
{
	import flash.events.Event;
	
	public class MsgHandler extends Event
	{
		public var id:uint;
		public var isTCP:Boolean;
		public var peer:ServerPeer;
		
		public function MsgHandler(Peer:ServerPeer = null, ID:uint = 10, IsTCP:Boolean = false) 
		{
			peer = Peer;
			id = ID;
			isTCP = IsTCP;
			
			super("msgevent");
		}
		
	}

}