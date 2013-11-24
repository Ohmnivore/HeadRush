package  
{
	import flash.events.ServerSocketConnectEvent;
	import flash.utils.Dictionary;
	import org.flixel.FlxPoint;
	import Streamy.MsgHandler;
	import Streamy.Server;
	
	public class RushServer extends Server 
	{
		public var clients:Dictionary = new Dictionary();
		
		public function RushServer() 
		{
			super(null, 5605, 5605);
		}
		
		override public function NewClient(event:ServerSocketConnectEvent):void
		{
			super.NewClient(event);
			
			var spawn:FlxPoint = Registry.getRandomElementOf(Registry.playstate.spawns);
			var newplayer:Player = new Player(spawn.x, spawn.y);
			Registry.playstate.players.add(newplayer);
			
			//Equivalent to clients[peer.id], but we don't have a reference
			//to the peer object.
			clients[event.socket.remoteAddress.concat(event.socket.remotePort)] = newplayer;   
		}
		
		override public function HandleMsg(event:MsgHandler):void
		{
			super.HandleMsg(event);
			
		}
	}

}