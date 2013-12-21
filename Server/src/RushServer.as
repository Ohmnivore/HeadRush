package  
{
	import flash.events.ServerSocketConnectEvent;
	import flash.utils.Dictionary;
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
			FlxG.log("[Server]newplayer from: ".concat(event.socket.remoteAddress));
			Msg.newclient.msg["id"] = id;
			Msg.newclient.msg["json"] = JSON.stringify(["Ohmnivore"]);
			Msg.newclient.SendReliableToAll();
			
			super.NewClient(event);
			
			Msg.dl.msg["dlurl"] = ServerInfo.dlurl;
			Msg.dl.msg["jsonmanifests"] = JSON.stringify(ServerInfo.dlmanifests);
			Msg.dl.SendReliable(peers[event.socket.remoteAddress.concat(event.socket.remotePort)]);
			
			var newplayer:Player = new Player(0, 0);
			
			//Equivalent to clients[peer.id], but we don't have a reference
			//to the peer object.
			peers[event.socket.remoteAddress.concat(event.socket.remotePort)].identifier = id;
			clients[id] = newplayer;
			newplayer.ID = id;
			//trace(Msg.mapstring.msg["compressed"].length);
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
			newplayer.peer = peers[event.socket.remoteAddress.concat(event.socket.remotePort)];
			
			var testhud:HUDLabel = new HUDLabel(1, 0, "TestHUD");
			testhud.pos = new FlxPoint(100, 0);
			testhud.Init(newplayer);
			testhud.Set(newplayer);
			testhud.Pos(newplayer);
			
			var testtimer:HUDTimer = new HUDTimer(2, 0, 500);
			testtimer.Init(newplayer);
			testtimer.Set(newplayer);
			testtimer.Start(newplayer);
		}
		
		override public function HandleMsg(event:MsgHandler):void
		{
			super.HandleMsg(event);
			
			var p:Player = clients[event.peer.identifier];
			
			if (event.id == Msg.keystatus.ID)
			{
				//FlxG.log(event.peer.identifier);
				if (!Msg.keystatus.msg["left"] && !Msg.keystatus.msg["right"])
				{
					//if (!p.isTouching(FlxObject.NONE)) p.acceleration.x = 0;
				}
				
				if (Msg.keystatus.msg["left"])
				{
					//clients[event.peer.identifier].acceleration.x = -clients[event.peer.identifier].maxVelocity.x * 4;
					p.velocity.x -= 5;
				}
				
				//event.id is 11, since we checked that earlier.
				
				if (Msg.keystatus.msg["right"])
				{
					//clients[event.peer.identifier].acceleration.x = clients[event.peer.identifier].maxVelocity.x * 4;
					p.velocity.x += 5;
				}
				
				if (Msg.keystatus.msg["down"])
				{
					//clients[event.peer.identifier].acceleration.y = 420;
					p.acceleration.y = 420;
				}
				
				//See how we check if the player is actually touching the floor?
				//Although the same check is already used in the update function,
				//never trust the client.
				if (Msg.keystatus.msg["up"])
				{
					//trace(
					//FlxG.collide(Registry.playstate.map, p.wallshade));
					//FlxObject.separateX(p.wallshade, Registry.playstate.map);
					//trace(p.wallslide);
					if (p.wallslide)
					{
						if (p.walleft)
						{
							p.velocity.y = -p.maxVelocity.y / 2;
							p.velocity.x = 60;
						}
						
						if (p.wallright)
						{
							p.velocity.y = -p.maxVelocity.y / 2;
							p.velocity.x = -60;
						}
					}
					
					else
					{
						if (p.isTouching(FlxObject.DOWN))
							p.velocity.y = -p.maxVelocity.y / 2;
					}
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