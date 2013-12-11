package  
{
	import flash.events.ServerSocketConnectEvent;
	import flash.utils.Dictionary;
	import org.flixel.FlxPoint;
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
		public var clients:Dictionary = new Dictionary();
		
		public function RushServer() 
		{
			super("127.0.0.1", 5613, 5613);
			id = 0;
		}
		
		override public function onClientClose( event:Event ):void 
        { 
			var sock:Socket = event.target as Socket;
			var id:String = sock.remoteAddress.concat(sock.remotePort);
			var peer:ServerPeer = peers[id];
			
			Msg.clientdisco.msg["id"] = peer.identifier;
			
			Registry.playstate.players.remove(clients[peer.identifier], true);
			clients[peer.identifier].kill();
			clients[peer.identifier].destroy();
			
			super.onClientClose(event);
			
			Msg.clientdisco.SendReliableToAll();
		}
		
		override public function NewClient(event:ServerSocketConnectEvent):void
		{
			FlxG.log("newplayer");
			Msg.newclient.msg["id"] = id;
			Msg.newclient.msg["json"] = JSON.stringify(["Ohmnivore"]);
			Msg.newclient.SendReliableToAll();
			
			super.NewClient(event);
			
			var newplayer:Player = new Player(0, 0);
			
			//Equivalent to clients[peer.id], but we don't have a reference
			//to the peer object.
			peers[event.socket.remoteAddress.concat(event.socket.remotePort)].identifier = id;
			clients[id] = newplayer;
			newplayer.ID = id;
			trace(Msg.mapstring.msg["compressed"].length);
			Msg.mapstring.SendReliable(peers[event.socket.remoteAddress.concat(event.socket.remotePort)]);
			//id++;
			
			Msg.fellowclients.msg["yourid"] = id;
			var peerarray:Array = new Array();
			for each (var client:Player in Registry.playstate.players.members)
			{
				var infoarray:Array = new Array();
				infoarray.push(client.ID);
				infoarray.push(client.name);
				peerarray.push(infoarray);
			}
			Msg.fellowclients.msg["json"] = JSON.stringify(peerarray);
			Msg.fellowclients.SendReliable(peers[event.socket.remoteAddress.concat(event.socket.remotePort)]);
			id++;
			Registry.playstate.players.add(newplayer);
		}
		
		override public function HandleMsg(event:MsgHandler):void
		{
			super.HandleMsg(event);
			
			if (event.id == Msg.keystatus.ID)
			{
				//FlxG.log(event.peer.identifier);
				if (!Msg.keystatus.msg["left"] && !Msg.keystatus.msg["right"])
				{
					clients[event.peer.identifier].acceleration.x = 0;
				}
				
				if (Msg.keystatus.msg["left"])
				{
					clients[event.peer.identifier].acceleration.x = -clients[event.peer.identifier].maxVelocity.x * 4;
				}
				
				//event.id is 11, since we checked that earlier.
				
				if (Msg.keystatus.msg["right"])
				{
					clients[event.peer.identifier].acceleration.x = clients[event.peer.identifier].maxVelocity.x * 4;
				}
				
				//See how we check if the player is actually touching the floor?
				//Although the same check is already used in the update function,
				//never trust the client.
				if (Msg.keystatus.msg["up"] && clients[event.peer.identifier].isTouching(FlxObject.ANY))
				{
					clients[event.peer.identifier].velocity.y = -clients[event.peer.identifier].maxVelocity.y / 2;
				}
				
				if (Msg.keystatus.msg["shooting"])
				{
					clients[event.peer.identifier].shoot();
					//trace("shot");
				}
				
				clients[event.peer.identifier].right = Msg.keystatus.msg["lookright"];
				
				clients[event.peer.identifier].a = Msg.keystatus.msg["a"];
			}
		}
	}

}