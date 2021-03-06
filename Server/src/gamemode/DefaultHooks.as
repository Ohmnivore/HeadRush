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
	import entity.Flag;
	
	public class DefaultHooks 
	{
		public static var p:PlayState = Registry.playstate;
		public static var entities:Array = [];
		
		public static function update():void 
		{			
			collideWorld();
			checkWorldBounds();
			checkLasers();
		}
		
		public static function initTemplates():void
		{
			NFlxSpritePreset.initMsg(Registry.server);
			BaseTemplates.initTemplates();
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
			
			FlxG.collide(p.entities, p.materialmap);
			FlxG.collide(p.entities, p.lavamap);
			FlxG.collide(p.entities, p.map);
			FlxG.collide(p.bullets, p.entities, explobullet);
			FlxG.collide(p.entities, p.platforms);
			FlxG.collide(p.entities, p.entities);
			FlxG.collide(p.entities, p.players);
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
		
		public static function announceSquish(killer:Player, victim:Player):void
		{
			var a:String = killer.name.concat(" squished ") + victim.name + "!";
			var kmarkup:Markup = new Markup(0, killer.name.length, 11, killer.teamcolor);
			var vmarkup:Markup = new Markup(killer.name.length + 9, a.length - 1, 11, victim.teamcolor)
			PlayState.announcer.add(new MarkupText(0, 0, 500, a, true, true, [kmarkup, vmarkup]));
		}
		
		public static function announceGibbed(killer:Player, victim:Player):void
		{
			var a:String = killer.name.concat(" gunned ") + victim.name + ".";
			var kmarkup:Markup = new Markup(0, killer.name.length, 11, killer.teamcolor);
			var vmarkup:Markup = new Markup(killer.name.length + 7, a.length - 1, 11, victim.teamcolor)
			PlayState.announcer.add(new MarkupText(0, 0, 500, a, true, true, [kmarkup, vmarkup]));
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
				bullet["nsprite"].killdelete(null, false);
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
			
			var iskill:Boolean = false;
			
			if (player.touching & FlxObject.DOWN && player.x >= player2.x && player.x <= player2.x + player2.width)
			{
				if (player.y <= player2.y + 1)
				{
					winner = player;
					loser = player2;
					iskill = true;
				}
			}
			
			if (player2.touching & FlxObject.DOWN && player2.x >= player.x && player2.x <= player.x + player.width)
			{
				if (player2.y <= player.y + 1)
				{
					winner = player2;
					loser = player;
					iskill = true;
				}
			}
			
			if (iskill)
			{
				var info:HurtInfo = new HurtInfo;
				info.attacker = winner.ID;
				info.victim = loser.ID;
				info.dmg = Math.abs(winner.velocity.y - loser.velocity.y) * 3;
				info.type = BaseGamemode.JUMPKILL;
				info.dmgsource = winner.getMidpoint();
				
				Registry.gm.dispatchEvent(new HurtEvent(HurtEvent.HURT_EVENT, info));
			}
		}
		
		public static function handleDamage(info:HurtInfo):void
		{
			var p:Player = Registry.clients[info.victim];
			if (info.victim != info.attacker) p.health -= info.dmg;
			
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
			
			if (t == BaseGamemode.BULLET)
			{
				var killer:Player = Registry.clients[info.attacker];
				var victim:Player = Registry.clients[info.victim];
				
				DefaultHooks.respawn(victim);
				announceGibbed(killer, victim);
			}
			
			if (t == BaseGamemode.JUMPKILL)
			{
				var killer:Player = Registry.clients[info.attacker];
				var victim:Player = Registry.clients[info.victim];
				
				DefaultHooks.respawn(victim);
				announceSquish(killer, victim);
			}
		}
		
		public static function handleJoin(e:JoinEvent):void
		{
			var s:RushServer = Registry.server;
			var event:ServerSocketConnectEvent = e.joininfo;
			
			FlxG.log("[Server]newplayer from: ".concat(event.socket.remoteAddress));
			
			Msg.dl.msg["dlurl"] = ServerInfo.dlurl;
			Msg.dl.msg["jsonmanifests"] = JSON.stringify(ServerInfo.dlmanifests);
			Msg.dl.SendReliable(s.peers[event.socket.remoteAddress.concat(event.socket.remotePort)]);
			
			NFlxSpritePreset.exportMsg.msg["json"] = NFlxSpritePreset.exportPresets();
			NFlxSpritePreset.exportMsg.SendReliable(s.peers[event.socket.remoteAddress.concat(event.socket.remotePort)]);
			
			Msg.mapstring.SendReliable(s.peers[event.socket.remoteAddress.concat(event.socket.remotePort)]);
			
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
		
		public static function handleClientInfo(event:MsgHandler):void
		{
			var s:RushServer = Registry.server;
			
			var p:Player = new Player(0, 0);
			
			ServerInfo.currentp = ServerInfo.currentp + 1;
			
			//new Flag(300, 0);
			for each (var spr:NFlxSprite in NFlxSpritePreset.items)
			{
				spr.declare(event.peer);
			}
			
			event.peer.identifier = s.id;
			s.clients[s.id] = p;
			p.ID = s.id;
			s.id++;
			Registry.playstate.players.add(p);
			p.peer = event.peer;
			
			var i:Array = JSON.parse(Msg.newclient.msg["json"]) as Array;
			
			p.name = i[0];
			p.header.text = p.name;
			
			switch(i[1])
			{
				case 0xff438b17:
					p.loadGraphic(Assets.PLAYER_GREEN, true, true, 24, 24);
					p.teamcolor = 0xff438b17;
					break;
				
				case 0xffe79800:
					p.loadGraphic(Assets.PLAYER_YELLOW, true, true, 24, 24);
					p.teamcolor = 0xffe79800;
					break;
				
				case 0xff9c3030:
					p.loadGraphic(Assets.PLAYER_RED, true, true, 24, 24);
					p.teamcolor = 0xff9c3030;
					break;
			}
			
			p.setTextColor(p.teamcolor);
			
			FlxG.log("[Server]"+event.peer.identifier+" was assigned info: "+Msg.newclient.msg["json"]);
			Msg.newclient.msg["id"] = p.ID;
			Msg.newclient.msg["json"] = JSON.stringify(i);
			for (var id:String in Registry.server.peers)
			{
				if (id != event.peer.id)
				{
					//trace(id, event.peer.id);
					Msg.newclient.SendReliable(Registry.server.peers[id]);
				}
			}
			
			Msg.fellowclients.msg["yourid"] = p.ID;
			var peerarray:Array = new Array();
			for each (var client:Player in Registry.playstate.players.members)
			{
				if (client.ID != event.peer.identifier)
				{
					var infoarray:Array = new Array();
					infoarray.push(client.ID);
					infoarray.push(client.name);
					infoarray.push(client.teamcolor);
					peerarray.push(infoarray);
				}
			}
			Msg.fellowclients.msg["json"] = JSON.stringify(peerarray);
			Msg.fellowclients.SendReliable(event.peer);
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
			
			delete s.peers[id];
			
			Msg.clientdisco.SendReliableToAll();
		}
		
		public static function handleKeys(event:MsgHandler):void
		{
			for each (var spr:NFlxSprite in entities)
			{
				if (spr.templ == BaseTemplates.bullet.id)
				{
					//spr.broadcastupdate();
				}
			}
			
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
				//var sp:Flag = new Flag(300, 0);
				//sp.declare();
				//for each (var spr:NFlxSprite in NFlxSpritePreset.items)
				//{
					//if (spr.templ == BaseTemplates.flag.id)
					//{
						//trace("k");
						//spr.broadcastupdate();
					//}
				//}
				//trace("shot");
			}
			
			Registry.server.clients[event.peer.identifier].right = Msg.keystatus.msg["lookright"];
			
			Registry.server.clients[event.peer.identifier].a = Msg.keystatus.msg["a"];
			//}
		}
		
		public static function handleScore(event:MsgHandler):void
		{
			Msg.score.msg["json"] = Registry.leadsetjson;
			Msg.score.SendUnreliable(event.peer);
		}
		
		public static function createScore():void
		{
			var lead:ScoreTable = new ScoreTable;
			lead.header = new MarkupText(0, 0, 500, "Leaderboard", true, true, 
				[new Markup(0, 11, 11, FlxG.RED)]);
			lead.titles = [
				new MarkupText(0, 0, 500, "|Player                      |", true, true, [new Markup(0, 14, 9, FlxG.RED)]),
				new MarkupText(0, 0, 500, "Kills |", true, true, [new Markup(0, 7, 9, FlxG.RED)]),
				new MarkupText(0, 0, 500, "Deaths", true, true, [new Markup(0, 6, 9, FlxG.RED)])
			];
			lead.content = [
				[],
				[],
				[]
			];
			
			var allp:Array = [];
			
			for each (var id:Player in Registry.clients)
			{
				allp.push(id);
			}
			
			allp.sortOn("kills");
			
			for each (var play:Player in allp)
			{
				lead.content[0].push(play.name);
				lead.content[1].push(String(play.kills));
				lead.content[2].push(String(play.deaths));
			}
			
			Registry.leadset.importSet("["+lead.exportTable()+"]");
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