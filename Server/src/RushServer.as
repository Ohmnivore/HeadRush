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
	import flash.net.DatagramSocket;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.system.Security;
	
	public class RushServer extends Server 
	{
		public var id:uint;
		public var clients:Dictionary = Registry.clients;
		public var sock:DatagramSocket; //Responds to LAN server discovery, nothing fancy
		
		public function RushServer() 
		{
			super(ServerInfo.address, 5613, 5613);
			id = 0;
			
			sock = new DatagramSocket();
			sock.bind(5614, ServerInfo.address);
			sock.addEventListener(DatagramSocketDataEvent.DATA, onLAN);
			sock.receive();
			
			var xml:XML = <cross-domain-policy>
							<allow-access-from domain="*" to-ports="*" />
						  </cross-domain-policy>;
						  
			Security.loadPolicyFile("src/secure.txt");
		}
		
		public function onLAN(event:DatagramSocketDataEvent):void
		{
			FlxG.log("[Server]Got LAN discovery packet.");
			
			trace(event.srcAddress, event.srcPort);
			
			var buffer:ByteArray = new ByteArray();
			
			if (ServerInfo.password.length > 0)
			{
				buffer.writeUTF(JSON.stringify(
				[ServerInfo.name, ServerInfo.map, ServerInfo.gamemode, 
				ServerInfo.currentp, ServerInfo.maxp, "Yes", ServerInfo.address]
				));
			}
			
			else
			{
				buffer.writeUTF(JSON.stringify(
				[ServerInfo.name, ServerInfo.map, ServerInfo.gamemode, 
				ServerInfo.currentp, ServerInfo.maxp, "No", ServerInfo.address]
				));
			}
			
			sock.send(buffer, 0, 0, event.srcAddress, event.srcPort);
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