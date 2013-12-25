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
			
			var p:Player = clients[event.peer.identifier];
			
			try{
			
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
			
			catch (e:Error)
			{
				trace(e);
			}
		}
	}

}