package gamemode 
{
	import flash.net.Socket;
	import Streamy.*;
	import flash.events.Event;
	import flash.events.ServerSocketConnectEvent;
	import gevent.DeathEvent;
	import gevent.HurtEvent;
	import gevent.HurtInfo;
	import gevent.JoinEvent;
	import gevent.LeaveEvent;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import org.flixel.plugin.photonstorm.BaseTypes.Bullet;
	
	public class DefaultHooks 
	{
		public static var p:PlayState = Registry.playstate;
		
		public static function update():void 
		{			
			collideWorld();
			checkWorldBounds();
			checkLasers();
		}
		
		public static function hookEvents(gm:BaseGamemode):void
		{
			gm.addEventListener(HurtEvent.HURT_EVENT, gm.onHurt, false, 10);
			gm.addEventListener(DeathEvent.DEATH_EVENT, gm.onDeath, false, 10);
			gm.addEventListener(JoinEvent.JOIN_EVENT, gm.onJoin, false, 10);
			gm.addEventListener(LeaveEvent.LEAVE_EVENT, gm.onLeave, false, 10);
			gm.addEventListener(MsgHandler.MSG_EVENT, gm.onMsg, false, 10);
		}
		
		public static function collideWorld():void
		{
			FlxG.collide(p.players, p.materialmap);
			FlxG.collide(p.players, p.lavamap);
			FlxG.collide(p.players, p.map);
			FlxG.collide(p.bullets, p.map, explobullet);
			FlxG.collide(p.bullets, p.platforms, explobullet);
			FlxG.collide(p.bullets, p.players, explobullet);
			FlxG.collide(p.players, p.platforms);
			FlxG.collide(p.players, p.players, jumpkill);
		}
		
		public static function checkWorldBounds():void
		{
			for each (var player:Player in p.players.members)
			{
				if (player.y > p.map.height + p.map.y + 100 && !player.dead) 
				{
					var info:HurtInfo = new HurtInfo;
					info.attacker = BaseGamemode.FALL;
					info.victim = player.ID;
					info.dmg = 100;
					info.dmgsource = player.getMidpoint();
					info.type = BaseGamemode.ENVIRONMENT;
					
					Registry.gm.dispatchEvent(new HurtEvent(HurtEvent.HURT_EVENT, info));
				}
			}
		}
		
		public static function checkLasers():void
		{
			for each (var laser:Laser in p.lasers.members)
			{
				for each (var player:Player in p.players.members)
				{
					if (FlxCollision.pixelPerfectCheck(laser, player, 255))
					{
						var info:HurtInfo = new HurtInfo;
						info.attacker = BaseGamemode.LASER;
						info.victim = player.ID;
						info.dmg = 10;
						info.dmgsource = player.getMidpoint();
						info.type = BaseGamemode.ENVIRONMENT;
						
						Registry.gm.dispatchEvent(new HurtEvent(HurtEvent.HURT_EVENT, info));
					}
				}
			}
		}
		
		public static function respawn(player:Player):void
		{
			player.respawn(Registry.spawntimer);
		}
		
		public static function announceLava(player:Player):void
		{
			var announce:String = player.name.concat(" was scorched by lava.");
			var pmarkup:Markup = new Markup(0, player.name.length, 11, player.teamcolor);
			var lmarkup:Markup = new Markup(announce.length - 6, announce.length - 1, 11, Registry.ORANGE);
			PlayState.announcer.add(new MarkupText(0, 0, 500, announce, true, true, [pmarkup, lmarkup]));
		}
		
		public static function announceFall(player:Player):void
		{
			var announce:String = player.name.concat(" fell off the map.");
			var pmarkup:Markup = new Markup(0, player.name.length, 11, player.teamcolor);
			var fmarkup:Markup = new Markup(announce.length - 4, announce.length - 1, 11, Registry.ORANGE);
			PlayState.announcer.add(new MarkupText(0, 0, 500, announce, true, true, [pmarkup, fmarkup]));
		}
		
		public static function announceLaser(player:Player):void
		{
			var announce:String = player.name.concat(" was burned by a laser!");
			var pmarkup:Markup = new Markup(0, player.name.length, 11, player.teamcolor);
			var lmarkup:Markup = new Markup(announce.length - 6, announce.length - 1, 11, Registry.ORANGE);
			PlayState.announcer.add(new MarkupText(0, 0, 500, announce, true, true, [pmarkup, lmarkup]));
		}
		
		public static function explobullet(bullet:Bullet, placeholder):void
		{
			for each (var player:Player in p.players.members)
			{
				var ppos:FlxPoint = new FlxPoint(player.x + player.width / 2, player.y + player.height / 2);
				var bpos:FlxPoint = new FlxPoint(bullet.x + bullet.width / 2, bullet.y + bullet.height / 2);
				
				var dist:Vector2D = new Vector2D(ppos.x - bpos.x, ppos.y - bpos.y);
				var length:Number = dist.length;
				
				if (length <= 36)
				{
					//player.velocity.x += 36*sign(dist.x) - dist.x;
					player.velocity.y += 360 * sign(dist.y) - dist.y * 10;
					//player.velocity.x += dist.x * 15 - 0.4 * Math.pow(dist.x, 2);
					if (Math.abs(dist.x) > 5)
						player.velocity.x += 180 * sign(dist.x) - dist.x * 5;
				}
				
				VMath.normalize(dist);
				
				if (length <= 36)
				{
					var info:HurtInfo = new HurtInfo;
					info.attacker = bullet.weapon.player.ID;
					info.victim = player.ID;
					info.dmg = 90 - 2.5 * length;
					info.dmgsource = bullet.getMidpoint();
					info.type = BaseGamemode.BULLET;
					
					Registry.gm.dispatchEvent(new HurtEvent(HurtEvent.HURT_EVENT, info));
				}
				
				bullet.kill();
			}
		}
		
		public static function sign(num)
		{
			 return (num > 0) ? 1 : ((num < 0) ? -1 : 0);
		}
		
		public static function jumpkill(player:Player, player2:Player):void
		{
			var winner:Player;
			var loser:Player;
			
			if (player.touching & FlxObject.DOWN)
			{
				if (player.y <= player2.y + 1)
				{
					winner = player;
					loser = player2;
				}
			}
			
			if (player2.touching & FlxObject.DOWN)
			{
				if (player2.y <= player.y + 1)
				{
					winner = player2;
					loser = player;
				}
			}
			
			var info:HurtInfo = new HurtInfo;
			info.attacker = winner.ID;
			info.victim = loser.ID;
			info.dmg = 100;
			info.type = BaseGamemode.JUMPKILL;
			info.dmgsource = winner.getMidpoint();
			
			Registry.gm.dispatchEvent(new HurtEvent(HurtEvent.HURT_EVENT, info));
		}
		
		public static function handleDamage(info:HurtInfo):void
		{
			var p:Player = Registry.clients[info.victim];
			p.health -= info.dmg;
			
			if (!p.dead)
				if (p.health <= 0) Registry.gm.dispatchEvent(new DeathEvent(DeathEvent.DEATH_EVENT, info));
		}
		
		public static function handleDeath(info:HurtInfo):void
		{
			var t:int = info.type;
			var player:Player = Registry.clients[info.victim];
			
			if (t == BaseGamemode.ENVIRONMENT)
			{
				DefaultHooks.respawn(player);
				
				var k:int = info.attacker;
				
				if (k == BaseGamemode.LASER) DefaultHooks.announceLaser(player);
				if (k == BaseGamemode.FALL) DefaultHooks.announceFall(player);
				if (k == BaseGamemode.LAVA) DefaultHooks.announceLava(player);
			}
		}
		
		public static function handleJoin(e:JoinEvent):void
		{
			var s:RushServer = Registry.server;
			var event:ServerSocketConnectEvent = e.joininfo;
			
			ServerInfo.currentp = ServerInfo.currentp + 1;
			
			FlxG.log("[Server]newplayer from: ".concat(event.socket.remoteAddress));
			Msg.newclient.msg["id"] = id;
			Msg.newclient.msg["json"] = JSON.stringify(["Ohmnivore"]);
			for (var id:String in Registry.server.peers)
			{
				if (id != event.socket.remoteAddress.concat(event.socket.remotePort))
				{
					Msg.newclient.SendReliable(Registry.server.peers[id]);
				}
			}
			
			Msg.dl.msg["dlurl"] = ServerInfo.dlurl;
			Msg.dl.msg["jsonmanifests"] = JSON.stringify(ServerInfo.dlmanifests);
			Msg.dl.SendReliable(s.peers[event.socket.remoteAddress.concat(event.socket.remotePort)]);
			
			var newplayer:Player = new Player(0, 0);
			
			//Equivalent to clients[peer.id], but we don't have a reference
			//to the peer object.
			s.peers[event.socket.remoteAddress.concat(event.socket.remotePort)].identifier = s.id;
			s.clients[s.id] = newplayer;
			newplayer.ID = s.id;
			//trace(Msg.mapstring.msg["compressed"].length);
			Msg.mapstring.SendReliable(s.peers[event.socket.remoteAddress.concat(event.socket.remotePort)]);
			//id++;
			
			Msg.fellowclients.msg["yourid"] = s.id;
			var peerarray:Array = new Array();
			for each (var client:Player in Registry.playstate.players.members)
			{
				var infoarray:Array = new Array();
				infoarray.push(client.ID);
				infoarray.push(client.name);
				peerarray.push(infoarray);
			}
			Msg.fellowclients.msg["json"] = JSON.stringify(peerarray);
			Msg.fellowclients.SendReliable(s.peers[event.socket.remoteAddress.concat(event.socket.remotePort)]);
			s.id++;
			Registry.playstate.players.add(newplayer);
			newplayer.peer = s.peers[event.socket.remoteAddress.concat(event.socket.remotePort)];
			
			//var testhud:HUDLabel = new HUDLabel(1, 0, "TestHUD");
			//testhud.pos = new FlxPoint(100, 0);
			//testhud.Init(newplayer);
			//testhud.Set(newplayer);
			//testhud.Pos(newplayer);
			//
			//var testtimer:HUDTimer = new HUDTimer(2, 0, 500);
			//testtimer.Init(newplayer);
			//testtimer.Set(newplayer);
			//testtimer.Start(newplayer);
		}
		
		public static function handleLeave(e:LeaveEvent):void
		{
			var s:RushServer = Registry.server;
			var event:Event = e.leaveinfo;
			
			ServerInfo.currentp = ServerInfo.currentp - 1;
			
			var sock:Socket = event.target as Socket;
			var id:String = sock.remoteAddress.concat(sock.remotePort);
			var peer:ServerPeer = s.peers[id];
			
			FlxG.log("[Server]Client disconnected: ".concat(sock.remoteAddress));
			
			Msg.clientdisco.msg["id"] = peer.identifier;
			
			Registry.playstate.players.remove(s.clients[peer.identifier], true);
			s.clients[peer.identifier].kill();
			s.clients[peer.identifier].destroy();
			
			Msg.clientdisco.SendReliableToAll();
		}
		
		public static function handleKeys(event:MsgHandler):void
		{
			var p:Player = Registry.server.clients[event.peer.identifier];
			
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
				Registry.server.clients[event.peer.identifier].shoot();
				//trace("shot");
			}
			
			Registry.server.clients[event.peer.identifier].right = Msg.keystatus.msg["lookright"];
			
			Registry.server.clients[event.peer.identifier].a = Msg.keystatus.msg["a"];
		}
		
		public static function handleScore(event:MsgHandler):void
		{
			var s:ScoreSet = new ScoreSet;
			s.header = "Scores";
			s.headermarkup = [];
			s.titles = ["Player", "Kills", "Deaths"];
			s.columns = [[], [], []];
			
			var allp:Array = [];
			
			for each (var id:Player in Registry.clients)
			{
				allp.push(id);
			}
			
			allp.sortOn("kills");
			
			for each (var play:Player in allp)
			{
				s.columns[0].push(play.ID);
				s.columns[1].push(play.kills);
				s.columns[2].push(play.deaths);
			}
			
			var scoreboard:Array = [s];
			
			Msg.score.msg["json"] = JSON.stringify(scoreboard);
			Msg.score.SendReliable(event.peer);
		}
		
		public static function handleChat(event:MsgHandler):void
		{
			var p:Player = Registry.clients[event.peer.identifier];
			var thecore:MarkupText = new MarkupText(0, 0, 500, 
			p.name.concat(": ").concat(Msg.chat.msg["text"]), 
			true, true);
			var mark:Markup = new Markup(0, p.name.length, 10, p.teamcolor);
			thecore.Markitup(mark);
			Registry.playstate.chathist.add(thecore);
		}
	}

}