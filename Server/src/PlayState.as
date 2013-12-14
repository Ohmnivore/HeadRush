package  
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import org.flixel.plugin.photonstorm.BaseTypes.Bullet;
	import org.flixel.system.FlxTile;
	
	public class PlayState extends FlxState
	{
		public var map:BTNTilemap;
		public var materialmap:FlxTilemap;
		public var lavamap:FlxTilemap;
		public var string:String;
		public var spawns:Array = new Array();
		public var players:FlxGroup = new FlxGroup();
		
		public var random:Boolean = false;
		public var levelindex:String = "Test";
		
		public var lasers:FlxGroup = new FlxGroup();
		public var platforms:FlxGroup = new FlxGroup();
		public var charunderlay:FlxGroup = new FlxGroup();
		public var charoverlay:FlxGroup = new FlxGroup();
		public var heademitters:FlxGroup = new FlxGroup();
		public var bullets:FlxGroup = new FlxGroup();
		public var hud:FlxGroup = new FlxGroup();
		public var chats:FlxGroup = new FlxGroup();
		public static var maps:Array = new Array();
		public static var mapz:Array = new Array();
		public static var announcer:Announcer = new Announcer();
		
		internal var elapsed:Number;
		internal var messagespersecond:uint;
		internal var rate:Number;
		
		public var chatbox:ChatBox;
		public var chathist:ChatHist;
		
		override public function create():void 
		{
			super.create();
			
			elapsed = 0;
			rate = 1.0 / messagespersecond;
			
			Registry.playstate = this;
			Registry.server = new RushServer();
			Registry.spawntimer = 3000;
			Registry.devconsole = new DeveloperConsole(FlxG._game, this);
			FlxG._game.stage.addChild(Registry.devconsole);
			
			Msg.init();
			
			FlxG.bgColor = 0xff7A7A7A;
			FlxG.mouse.show();
			
			if (random) RandomMap();
			
			else 
			{
				spawns.push(new Spawn(30, 0, 0));
				map = new BTNTilemap();
				
				LoadMap();
				
				string = JSON.stringify(Assets.LVLS[levelindex]);
				
				var temp:String = new String();
				temp = LZW.compress(string);
				trace(string.length);
				trace(temp.length);
				Msg.mapstring.msg["compressed"] = temp;
			}
			
			add(map);
			add(charunderlay);
			add(players);
			add(charoverlay);
			add(bullets);
			add(heademitters);
			
			var spect:Spectator = new Spectator(0, 0);
			add(spect);
			
			FlxG.camera.setBounds(0, 0, map.width, map.height);
			FlxG.camera.follow(spect);
			
			var bounds:FlxRect;
			bounds = new FlxRect(map.x, map.y, map.width, map.height);
			bounds.x -= 100;
			bounds.y -= 100;
			bounds.width += 200;
			bounds.height += 200;
			
			FlxG.worldBounds = bounds;
			
			//var chatbox:FlxInputText = new FlxInputText(0, 200*2, 320*2, 120*2, "->");
			//chatbox.size = 20;
			//chatbox.scrollFactor = new FlxPoint(0, 0);
			//chatbox.borderVisible = false;
			//chatbox.backgroundColor = 0x55949494;
			chathist = new ChatHist();
			//chathist.toggle();
			
			chatbox = new ChatBox();
			chatbox.toggle();
			
			Registry.ms = new MasterServer(ServerInfo.ms);
			Registry.ms.announce();
		}
		
		public function LoadMap():void
		{
			materialmap = new FlxTilemap();
			lavamap = new FlxTilemap();
			
			for (var layer:int = 0; layer < Assets.LVLS[levelindex][3].length; layer++)
			{
				maps[layer] = new FlxTilemap;
				mapz[layer] = new BTNTilemap;
				if (Assets.LVLS[levelindex][3][layer][0] == 'Collide') 
				{
					map = mapz[layer].loadMap(Assets.LVLS[levelindex][3][layer][1], Assets.T_COLLIDE, 8, 8);
					map.setTileProperties(0, FlxObject.NONE);
					map.setTileProperties(1, FlxObject.ANY);
					FlxG.worldBounds = new FlxRect(0, 0, map.width, map.height);
					map.visible = false;
					//map.setTileProperties(2, FlxObject.ANY, CeilingWalk, Player, 1);
					//map.setTileProperties(1, FlxObject.ANY, LedgeGrab, CollideShadow, 1);
					//trace("collide");
					//GenerateEdges();
					
					var pattern:RegExp = /1/g;
					var materialstring:String = Assets.LVLS[levelindex][3][layer][1].replace(pattern, "0");
					var pattern2:RegExp = /3/g;
					materialstring = materialstring.replace(pattern2, "0");
					pattern = /2/g;
					materialstring = materialstring.replace(pattern, "1");
					
					materialmap.loadMap(materialstring, Assets.T_MATERIAL, 8, 8);
					materialmap.setTileProperties(0, FlxObject.NONE);
					materialmap.setTileProperties(1, FlxObject.ANY, CeilingWalk, Player);
					
					pattern = /1/g;
					var lavastring:String = Assets.LVLS[levelindex][3][layer][1].replace(pattern, "0");
					pattern2 = /2/g;
					lavastring = lavastring.replace(pattern2, "0");
					pattern = /3/g;
					lavastring = lavastring.replace(pattern, "1");
					
					lavamap.loadMap(lavastring, Assets.T_MATERIAL, 8, 8);
					lavamap.setTileProperties(0, FlxObject.NONE);
					lavamap.setTileProperties(1, FlxObject.ANY, LavaBurn, Player);
				}
				if (Assets.LVLS[levelindex][3][layer][0] == 'Snow') 
				{
					var frontmap:FlxTilemap;
					frontmap = maps[layer].loadMap(Assets.LVLS[levelindex][3][layer][1], Assets.T_SNOW, 16, 16);
				}
				if (Assets.LVLS[levelindex][3][layer][0] == 'SnowBack') 
				{
					var backmap:FlxTilemap;
					backmap = maps[layer].loadMap(Assets.LVLS[levelindex][3][layer][1], Assets.T_SNOW, 16, 16);
					backmap.scrollFactor.x = backmap.scrollFactor.y = 0.8;
				}
			}
			
			add(backmap);
			add(lasers);
			add(lavamap);
			add(frontmap);
			add(materialmap);
			add(platforms);
			add(Registry.chatrect);
			add(hud);
			add(chats);
			
			//Load platforms
			for (var platf:int = 0; platf < Assets.LVLS[levelindex][4].length; platf++)
			{
				var pathlength:int;
				var direc:String;
				
				trace(Assets.LVLS[levelindex][4][platf].w, ":", Assets.LVLS[levelindex][4][platf].h);
				
				if (int(Assets.LVLS[levelindex][4][platf].w) > int(Assets.LVLS[levelindex][4][platf].h)) 
				{
					direc = "x";
					pathlength = int(Assets.LVLS[levelindex][4][platf].w) - 48;
				}
				else 
				{
					direc = "y";
					pathlength = int(Assets.LVLS[levelindex][4][platf].h) - 16;
				}
				
				var reverse:Boolean = false;
				if (Assets.LVLS[levelindex][4][platf].t == "R" || Assets.LVLS[levelindex][4][platf].t == "B") reverse = true;
				var platform:OutPlatform = new OutPlatform(int(Assets.LVLS[levelindex][4][platf].x), int(Assets.LVLS[levelindex][4][platf].y), pathlength, 0, direc, reverse);
				platforms.add(platform);
			}
			
			//Load game entities
			for (var enem:int = 0; enem < Assets.LVLS[levelindex][1].length; enem++)
			{
				switch (Assets.LVLS[levelindex][1][enem][2])
				{
					case "Spawn":
						break;
				}		
			}
			
			//Load lasers
			for (var laser:int = 0; laser < Assets.LVLS[levelindex][0].length; laser++)
			{
				var laz:Laser = new Laser(new FlxPoint(int(Assets.LVLS[levelindex][0][laser][0]), int(Assets.LVLS[levelindex][0][laser][1])), 
				new FlxPoint(int(Assets.LVLS[levelindex][0][laser][2]), int(Assets.LVLS[levelindex][0][laser][3])), this);
				lasers.add(laz);
			}
		}
		
		public function RandomMap():void
		{
			map = new BTNTilemap();
			string = convertMatrixToStr(Registry.mapray);
			var temp:String = new String();
			temp = LZW.compress(string);
			trace(string.length);
			//temp.compress();
			trace(temp.length);
			Msg.mapstring.msg["compressed"] = temp;
			map.loadMap(string, FlxTilemap.ImgAuto, 8, 8, FlxTilemap.AUTO);
			
			generatespawns();
		}
		
		override public function update():void
		{
			super.update();
			
			Registry.ms.update(FlxG.elapsed);
			
			FlxG.collide(players, materialmap);
			FlxG.collide(players, lavamap);
			FlxG.collide(players, map);
			FlxG.collide(bullets, map, explobullet);
			FlxG.collide(bullets, platforms, explobullet);
			FlxG.collide(bullets, players, explobullet);
			FlxG.collide(players, platforms);
			//FlxG.collide(heademitters, platforms);
			FlxG.overlap(players, heademitters, collectedhead);
			FlxG.collide(players, players, jumpkill);
			
			for each (var player:Player in players.members)
			{
				if (player.y > map.height + map.y + 100 && !player.dead) 
				{
					player.respawn(Registry.spawntimer);
					
					var announce:String = player.name.concat(" fell off the map.");
					announcer.add(announce,
								[
								[11, player.teamcolor, 0, player.name.length],
								[11, Registry.ORANGE, announce.length-4, announce.length-1]
								]
								);
				}
			}
			
			for each (var laser:Laser in lasers.members)
			{
				for each (var player:Player in players.members)
				{
					if (FlxCollision.pixelPerfectCheck(laser, player, 255))
					{
						if (!player.dead)
						{
							player.health -= 10;
							if (player.health <= 0)
							{
								var announce:String = player.name.concat(" was burned by a laser!");
								announcer.add(announce,
											[
											[11, player.teamcolor, 0, player.name.length],
											[11, Registry.ORANGE, announce.length-6, announce.length-1]
											]
											);
							}
						}
					}
				}
			}
			
			if (FlxG.keys.justReleased("ESCAPE")) Registry.cli.toggle();
			if (FlxG.keys.justReleased("Z")) Registry.devconsole.toggle();
			if (FlxG.keys.justReleased("F1")) Registry.devconsole.toggle();
			if (FlxG.keys.justReleased("T")) chatbox.toggle();
			
			elapsed += FlxG.elapsed;
			if (elapsed >= messagespersecond)
			{
				elapsed = 0;
				
				var peerstates:Array = new Array;
				for each (var peer:Player in players.members)
				{
					//FlxG.log(peer.ID);
					var peerstate:Array = new Array();
					peerstate.push(peer.ID);
					peerstate.push(peer.x);
					peerstate.push(peer.y);
					peerstates.push(peerstate);
				}
				
				Msg.clientpositions.msg["json"] = JSON.stringify(peerstates);
				Msg.clientpositions.SendUnreliableToAll();
			}
		}
		
		private function explobullet(bullet:Bullet, placeholder):void
		{
			for each (var player:Player in players.members)
			{
				var ppos:FlxPoint = new FlxPoint(player.x + player.width / 2, player.y + player.height / 2);
				var bpos:FlxPoint = new FlxPoint(bullet.x + bullet.width / 2, bullet.y + bullet.height / 2);
				
				var dist:Vector2D = new Vector2D(ppos.x - bpos.x, ppos.y - bpos.y);
				var length:Number = dist.length;
				//VMath.reverse(dist);
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
					player.health -= (90 - 2.5 * length);
				}
				
				bullet.kill();
			}
		}
		
		public function sign(num) {
			  return (num > 0) ? 1 : ((num < 0) ? -1 : 0);
			}
		
		private function collectedhead(player:Player, head:Head):void
		{
			if (!player.dead)
			{
				head.kill();
				player.heads++;
			}
		}
		
		private function jumpkill(player:Player, player2:Player):void
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
			
			winner.kills++;
			loser.respawn(Registry.spawntimer);
		}
		
		public function CeilingWalk(tile:FlxTile, player:Player):void
		{
			if (player.touching & FlxObject.UP)
			{
				if ((tile.y + tile.height) <= player.y + 1)
				{
					player.ceilingwalk = true;
					player.acceleration.y = -420;
				}
			}
			
			//player.acceleration.y = -420;
			//trace("walk");
		}
		
		public function LavaBurn(tile:FlxTile, player:Player):void
		{
			player.health -= 1;
			if (player.health <= 0 && !player.dead)
			{
				player.respawn(Registry.spawntimer);
				var announce:String = player.name.concat(" was scorched by lava.");
				announcer.add(announce,
							[
							[11, player.teamcolor, 0, player.name.length],
							[11, Registry.ORANGE, announce.length-6, announce.length - 1]
							]
							);
			}
		}
		
		public function convertMatrixToStr( mat:Array ):String
		{
			var mapString:String = "";
			
			for ( var y:uint = 0; y < mat.length; y++ )
			{
				for ( var x:uint = 0; x < mat[y].length; x++ )
				{
					mapString += mat[y][x].toString() + ",";
				}
				
				mapString += "\n";
			}
			
			return mapString;
		}
		
		public static function encode(ba:ByteArray):String 
		{
			var origPos:uint = ba.position;
			var result:Array = new Array();

			for (ba.position = 0; ba.position < ba.length - 1; )
				result.push(ba.readShort());

			if (ba.position != ba.length)
				result.push(ba.readByte() << 8);

			ba.position = origPos;
			return String.fromCharCode.apply(null, result);
		}
		
		private function getspawn():FlxPoint
		{
			var ok:Boolean = false;
			var x:int;
			var y:int;
			var xb:int = 300;
			var yb:int = 300;
			while (!ok)
			{
				x = xb / 8;
				y = yb / 8;
				
				if (Registry.mapray[y][x] == 1 || xb == 300 || yb == 300)
				{
					xb = Math.floor(Math.random() * 300);
					yb = Math.floor(Math.random() * 200);
					FlxG.log(xb);
					FlxG.log(yb);
				}
				
				else
				{
				    ok = true;
					return new FlxPoint(xb, yb);
				}
			}
			return new FlxPoint(0, 0);
		}
		
		private function generatespawns():void
		{
			
			while (spawns.length < 10)
			{
				spawns.push(getspawn());
			}
		}
	}
}