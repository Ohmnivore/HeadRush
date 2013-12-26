package  
{
	import flash.events.ServerSocketConnectEvent;
	import flash.utils.Dictionary;
	import gevent.JoinEvent;
	import gevent.LeaveEvent;
	import org.flixel.FlxPoint;
	import HUDLabel;
	import Streamy.MsgHandler;
	import Streamy.Server;
	import Player;
	import org.flixel.FlxObject;
	import org.flixel.FlxG;
	import flash.events.Event;
	import Streamy.ServerPeer;
	import flash.net.Socket;
	
	public class RushServer extends Server 
	{
		public var id:uint;
		public var clients:Dictionary = Registry.clients;
		
		public function RushServer() 
		{
			super("127.0.0.1", 5613, 5613);
			id = 0;
		}
		
		override public function onClientClose(event:Event):void 
        {
			Registry.gm.dispatchEvent(new LeaveEvent(LeaveEvent.LEAVE_EVENT, event));
			
			super.onClientClose(event);
		}
		
		override public function NewClient(event:ServerSocketConnectEvent):void
		{
			super.NewClient(event.clone() as ServerSocketConnectEvent);
			
			Registry.gm.dispatchEvent(new JoinEvent(JoinEvent.JOIN_EVENT, event.clone() as ServerSocketConnectEvent));
		}
		
		override public function HandleMsg(event:MsgHandler):void
		{
			super.HandleMsg(event);
			
			Registry.gm.dispatchEvent(event.clone() as MsgHandler);
		}
	}

}