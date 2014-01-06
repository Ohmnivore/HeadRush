package  
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import gevent.HurtEvent;
	import gevent.HurtInfo;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import org.flixel.plugin.photonstorm.BaseTypes.Bullet;
	import org.flixel.system.FlxTile;
	import flash.utils.getDefinitionByName;
	import entity.*;
	import gamemode.*;
	import plugin.BasePlugin;
	import entity.Spawn;
	import com.jmx2.delayedFunctionCall;
	import Streamy.ServerPeer;
	
	public class PlayState extends FlxState
	{
		public var map:BTNTilemap = new BTNTilemap();
		public var materialmap:FlxTilemap;
		public var lavamap:FlxTilemap;
		public var string:String;
		public var spawns:Array = new Array();
		public var players:FlxGroup = new FlxGroup();
		
		public var lasers:FlxGroup = new FlxGroup();
		public var platforms:FlxGroup = new FlxGroup();
		public var charunderlay:FlxGroup = new FlxGroup();
		public var charoverlay:FlxGroup = new FlxGroup();
		public var emitters:FlxGroup = new FlxGroup();
		public var bullets:FlxGroup = new FlxGroup();
		public var entities:FlxGroup = new FlxGroup();
		public var hud:FlxGroup = new FlxGroup();
		public var chats:FlxGroup = new FlxGroup();
		public var scores:FlxGroup = new FlxGroup();
		public static var maps:Array = new Array();
		public static var mapz:Array = new Array();
		public static var announcer:Announcer = new Announcer();
		
		public var chatbox:ChatBox;
		public var chathist:ChatHist;
		
		public var leadcount:uint = 0;
		
		override public function create():void 
		{
			super.create();
			
			Registry.playstate = this;
			Registry.spawntimer = 3000;
			Registry.devconsole = new DeveloperConsole(FlxG._game, this);
			FlxG._game.stage.addChild(Registry.devconsole);
			
			Msg.init();
			
			FlxG.bgColor = 0xff7A7A7A;
			FlxG.mouse.show();
			
			//spawns.push(new Spawn(30, 0, 0));
			
			LoadMap();
			
			chathist = new ChatHist();
			
			chatbox = new ChatBox();
			chatbox.toggle();
			chatbox.close();
			chathist.toggle();
		}
		
		public function LoadMap():void
		{
			if (Registry.maploaded)
			{
				Registry.makeSkeleton(lasers);
				Registry.makeSkeleton(platforms);
				//Registry.makeSkeleton(charunderlay);
				//Registry.makeSkeleton(charoverlay);
				Registry.makeSkeleton(emitters);
				//Registry.makeSkeleton(bullets);
				Registry.makeSkeleton(entities);
				Registry.makeSkeleton(hud);
				Registry.makeSkeleton(chats);
				Registry.makeSkeleton(scores);
			}
			
			materialmap = new FlxTilemap();
			lavamap = new FlxTilemap();
			
			var lvl = Assets.LVLS[Registry.maprotation[Registry.levelindex]];
			const PROPERTIES = 0;
			const LASERS = 1;
			const PLATFORMS = 2;
			const ENTITIES = 3;
			const MAPS = 4;
			
			var gm:Class = getDefinitionByName("gamemode.".concat(lvl[PROPERTIES]["gamemode"])) as Class;
			Registry.gm = new gm();
			
			new delayedFunctionCall(
			function () { Registry.gm.mapProperties(lvl[PROPERTIES]); }, 
			4000);
			
			for (var layer:int = 0; layer < lvl[MAPS].length; layer++)
			{
				maps[layer] = new FlxTilemap;
				mapz[layer] = new BTNTilemap;
				if (lvl[MAPS][layer][0] == 'Collide') 
				{
					map = mapz[layer].loadMap(lvl[MAPS][layer][1], Assets.T_COLLIDE, 8, 8);
					map.setTileProperties(0, FlxObject.NONE);
					map.setTileProperties(1, FlxObject.ANY);
					FlxG.worldBounds = new FlxRect(0, 0, map.width, map.height);
					map.visible = false;
					//map.setTileProperties(2, FlxObject.ANY, CeilingWalk, Player, 1);
					//map.setTileProperties(1, FlxObject.ANY, LedgeGrab, CollideShadow, 1);
					//trace("collide");
					//GenerateEdges();
					
					var pattern:RegExp = /1/g;
					var materialstring:String = lvl[4][layer][1].replace(pattern, "0");
					var pattern2:RegExp = /3/g;
					materialstring = materialstring.replace(pattern2, "0");
					pattern = /2/g;
					materialstring = materialstring.replace(pattern, "1");
					
					materialmap.loadMap(materialstring, Assets.T_MATERIAL, 8, 8);
					materialmap.setTileProperties(0, FlxObject.NONE);
					materialmap.setTileProperties(1, FlxObject.ANY, CeilingWalk, Player);
					
					pattern = /1/g;
					var lavastring:String = lvl[MAPS][layer][1].replace(pattern, "0");
					pattern2 = /2/g;
					lavastring = lavastring.replace(pattern2, "0");
					pattern = /3/g;
					lavastring = lavastring.replace(pattern, "1");
					
					lavamap.loadMap(lavastring, Assets.T_MATERIAL, 8, 8);
					lavamap.setTileProperties(0, FlxObject.NONE);
					lavamap.setTileProperties(1, FlxObject.ANY, LavaBurn, Player);
				}
				if (lvl[MAPS][layer][0] == 'Snow') 
				{
					var frontmap:FlxTilemap;
					frontmap = maps[layer].loadMap(lvl[4][layer][1], Assets.T_SNOW, 16, 16);
				}
				if (lvl[MAPS][layer][0] == 'SnowBack') 
				{
					var backmap:FlxTilemap;
					backmap = maps[layer].loadMap(lvl[4][layer][1], Assets.T_SNOW, 16, 16);
					backmap.scrollFactor.x = backmap.scrollFactor.y = 0.8;
				}
			}
			
			if (!Registry.maploaded)
			{
				//Add all layers to playstate
				add(backmap);
				add(lasers);
				add(lavamap);
				add(frontmap);
				add(materialmap);
				add(platforms);
				add(emitters);
				add(charunderlay);
				add(players);
				add(charoverlay);
				add(bullets);
				add(entities);
				add(Registry.chatrect);
				add(hud);
				add(chats);
				add(scores);
				
				add(map);
			}
			
			//Load platforms
			for (var platf:int = 0; platf < lvl[PLATFORMS].length; platf++)
			{
				var pathlength:int;
				var direc:String;
				
				trace(lvl[PLATFORMS][platf].w, ":", lvl[PLATFORMS][platf].h);
				
				if (int(lvl[PLATFORMS][platf].w) > int(lvl[PLATFORMS][platf].h)) 
				{
					direc = "x";
					pathlength = int(lvl[PLATFORMS][platf].w) - 48;
				}
				else 
				{
					direc = "y";
					pathlength = int(lvl[PLATFORMS][platf].h) - 16;
				}
				
				var reverse:Boolean = false;
				if (lvl[PLATFORMS][platf].t == "R" || lvl[2][platf].t == "B") reverse = true;
				var platform:OutPlatform = new OutPlatform(int(lvl[PLATFORMS][platf].x), int(lvl[PLATFORMS][platf].y), pathlength, 0, direc, reverse);
				platforms.add(platform);
			}
			
			//Load game entities
			for (var enem:int = 0; enem < lvl[ENTITIES].length; enem++)
			{
				var entity:Class = getDefinitionByName("entity.".concat(lvl[ENTITIES][enem][2])) as Class;
				
				if (lvl[ENTITIES][enem].hasOwnProperty(3))
				{
					new entity(lvl[ENTITIES][enem][0], lvl[ENTITIES][enem][1], lvl[ENTITIES][enem][3]);
				}
				
				else
				{
					new entity(lvl[ENTITIES][enem][0], lvl[ENTITIES][enem][1]);
				}
			}
			
			//Load lasers
			for (var laser:int = 0; laser < lvl[LASERS].length; laser++)
			{
				var laz:Laser = new Laser(new FlxPoint(int(lvl[LASERS][laser][0]), int(lvl[LASERS][laser][1])), 
				new FlxPoint(int(lvl[LASERS][laser][2]), int(lvl[LASERS][laser][3])), this);
				lasers.add(laz);
			}
			
			string = JSON.stringify(Assets.LVLS[Registry.maprotation[Registry.levelindex]]);
			
			var temp:String = new String();
			temp = LZW.compress(string);
			trace(string.length);
			trace(temp.length);
			Msg.mapstring.msg["compressed"] = temp;
			
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
			
			Registry.leadset = new ScoreSet();
			Registry.gm.createScore();
			
			Msg.mapstring.SendReliableToAll();
			
			Registry.maploaded = true;
		}
		
		override public function update():void
		{
			super.update();
			
			Registry.server.update(FlxG.elapsed);
			
			Registry.ms.update(FlxG.elapsed);
			
			Registry.gm.update(FlxG.elapsed);
			
			leadcount++;
			
			if (leadcount > 60)
			{
				Registry.gm.createScore();
				Registry.leadsetjson = Registry.leadset.exportSet();
				leadcount = 0;
			}
			
			for each (var plug:BasePlugin in ServerInfo.pl)
			{
				plug.update(FlxG.elapsed);
			}
			
			if (FlxG.keys.justReleased("ESCAPE")) Registry.cli.toggle();
			if (FlxG.keys.justReleased("Z")) Registry.devconsole.toggle();
			if (FlxG.keys.justReleased("F1")) Registry.devconsole.toggle();
			if (FlxG.keys.justReleased("T")) chatbox.toggle();
			if (FlxG.keys.justReleased("TAB")) Registry.leadset.toggle();
			
			var peerstates:Array = new Array;
			for each (var peer:Player in players.members)
			{
				//FlxG.log(peer.ID);
				var peerstate:Array = new Array();
				peerstate.push(peer.ID);
				peerstate.push(peer.x);
				peerstate.push(peer.y);
				if (!peer.dead) peerstate.push(peer.health);
				else peerstate.push( -100);
				if (peer.ceilingwalk) peerstate.push(true);
				peerstates.push(peerstate);
			}
			
			Msg.clientpositions.msg["json"] = JSON.stringify(peerstates);
			Msg.clientpositions.SendUnreliableToAll();
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
		}
		
		public function LavaBurn(tile:FlxTile, player:Player):void
		{
			var info:HurtInfo = new HurtInfo;
			info.attacker = BaseGamemode.LAVA;
			info.victim = player.ID;
			info.dmg = 2;
			info.dmgsource = tile.getMidpoint();
			info.type = BaseGamemode.ENVIRONMENT;
			
			Registry.gm.dispatchEvent(new HurtEvent(HurtEvent.HURT_EVENT, info));
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
	}
}