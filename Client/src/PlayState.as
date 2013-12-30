package  
{
	import org.flixel.*;
	import flash.utils.getDefinitionByName;
	
	public class PlayState extends FlxState
	{
		public var map:BTNTilemap;
		public var string:String;
		public var player:Player;
		public var players:FlxGroup = new FlxGroup();
		
		public var lasers:FlxGroup = new FlxGroup();
		public var platforms:FlxGroup = new FlxGroup();
		public var charunderlay:FlxGroup = new FlxGroup();
		public var huds:FlxGroup = new FlxGroup();
		public var hud:FlxGroup = new FlxGroup();
		public var chats:FlxGroup = new FlxGroup();
		public var bullets:FlxGroup = new FlxGroup();
		public var charoverlay:FlxGroup = new FlxGroup();
		public var scores:FlxGroup = new FlxGroup();
		public static var maps:Array = new Array();
		public static var mapz:Array = new Array();
		public var announcer:Announcer = new Announcer();
		
		internal var elapsed:Number;
		internal var messagespersecond:uint;
		internal var rate:Number;
		
		public var chatbox:ChatBox;
		public var chathist:ChatHist;
		
		public var leadcount:int = 0;
		
		override public function create():void 
		{	
			super.create();
			
			elapsed = 0;
			rate = 1.0 / messagespersecond;
			
			Registry.playstate = this;
			Registry.client = new RushClient("127.0.0.1", "127.0.0.1");
			Msg.init();
			
			Msg.newclient.msg["id"] = 0;
			Msg.newclient.msg["json"] = JSON.stringify([Registry.name, Registry.color]);
			Msg.newclient.SendReliable();
			
			player = new Player(70, 70);
			players.add(player);
			player.name = Registry.name;
			
			switch(Registry.color)
			{
				case "Green":
					player.loadGraphic(Assets.PLAYER_GREEN, true, true, 24, 24);
					player.teamcolor = 0xff438b17;
					break;
				
				case "Yellow":
					player.loadGraphic(Assets.PLAYER_YELLOW, true, true, 24, 24);
					player.teamcolor = 0xffe79800;
					break;
				
				case "Red":
					player.loadGraphic(Assets.PLAYER_RED, true, true, 24, 24);
					player.teamcolor = 0xff9c3030;
					break;
			}
			
			FlxG.bgColor = 0xff7A7A7A;
			FlxG.mouse.show();
			
			map = new BTNTilemap();
			Registry.loadedmap = false;
			//string = convertMatrixToStr(Registry.mapray);
			//map.loadMap(string, FlxTilemap.ImgAuto, 8, 8, FlxTilemap.AUTO);
			//add(map);
			
			//add(players);
			
			//var spect:Spectator = new Spectator(0, 0);
			//add(spect);
			
			//FlxG.camera.setBounds(0, 0, map.width, map.height);
			FlxG.camera.follow(player);
			
			chathist = new ChatHist();
			
			chatbox = new ChatBox();
			chatbox.toggle();
			chatbox.close();
			chathist.toggle();
			
			Registry.leadset = new ScoreSet();
		}
		
		public function loadmap(mapstring:String):void
		{
			var damap = JSON.parse(mapstring);
			var materialmap:FlxTilemap = new FlxTilemap();
			var lavamap:FlxTilemap = new FlxTilemap();
			
			const PROPERTIES = 0;
			const LASERS = 1;
			const PLATFORMS = 2;
			const ENTITIES = 3;
			const MAPS = 4;
			
			for (var layer:int = 0; layer < damap[MAPS].length; layer++)
			{
				maps[layer] = new FlxTilemap;
				mapz[layer] = new BTNTilemap;
				if (damap[MAPS][layer][0] == 'Collide') 
				{
					map = mapz[layer].loadMap(damap[MAPS][layer][1], Assets.T_COLLIDE, 8, 8);
					map.setTileProperties(0, FlxObject.NONE);
					map.setTileProperties(1, FlxObject.ANY);
					FlxG.worldBounds = new FlxRect(0, 0, map.width, map.height);
					map.visible = false;
					//map.setTileProperties(2, FlxObject.ANY, CeilingWalk, Player, 1);
					//map.setTileProperties(1, FlxObject.ANY, LedgeGrab, CollideShadow, 1);
					//trace("collide");
					//GenerateEdges();
					
					var pattern:RegExp = /1/g;
					var materialstring:String = damap[MAPS][layer][1].replace(pattern, "0");
					var pattern2:RegExp = /3/g;
					materialstring = materialstring.replace(pattern2, "0");
					pattern = /2/g;
					materialstring = materialstring.replace(pattern, "1");
					
					materialmap.loadMap(materialstring, Assets.T_MATERIAL, 8, 8);
					materialmap.setTileProperties(0, FlxObject.NONE);
					materialmap.setTileProperties(1, FlxObject.NONE);
					
					pattern = /1/g;
					var lavastring:String = damap[MAPS][layer][1].replace(pattern, "0");
					pattern2 = /2/g;
					lavastring = lavastring.replace(pattern2, "0");
					pattern = /3/g;
					lavastring = lavastring.replace(pattern, "1");
					
					lavamap.loadMap(lavastring, Assets.T_MATERIAL, 8, 8);
					lavamap.setTileProperties(0, FlxObject.NONE);
					lavamap.setTileProperties(1, FlxObject.NONE);
				}
				if (damap[MAPS][layer][0] == 'Snow') 
				{
					var frontmap:FlxTilemap;
					frontmap = maps[layer].loadMap(damap[MAPS][layer][1], Assets.T_SNOW, 16, 16);
				}
				if (damap[MAPS][layer][0] == 'SnowBack') 
				{
					var backmap:FlxTilemap;
					backmap = maps[layer].loadMap(damap[MAPS][layer][1], Assets.T_SNOW, 16, 16);
					backmap.scrollFactor.x = backmap.scrollFactor.y = 0.8;
				}
			}
			
			add(backmap);
			add(lasers);
			add(lavamap);
			add(frontmap);
			add(materialmap);
			add(platforms);
			add(players);
			add(charoverlay);
			add(bullets);
			add(Registry.chatrect);
			add(hud);
			add(huds);
			add(chats);
			add(scores);
			
			//Load platforms
			for (var platf:int = 0; platf < damap[PLATFORMS].length; platf++)
			{
				var pathlength:int;
				var direc:String;
				
				trace(damap[PLATFORMS][platf].w, ":", damap[PLATFORMS][platf].h);
				
				if (int(damap[PLATFORMS][platf].w) > int(damap[PLATFORMS][platf].h)) 
				{
					direc = "x";
					pathlength = int(damap[PLATFORMS][platf].w) - 48;
				}
				else 
				{
					direc = "y";
					pathlength = int(damap[PLATFORMS][platf].h) - 16;
				}
				
				var reverse:Boolean = false;
				if (damap[PLATFORMS][platf].t == "R" || damap[PLATFORMS][platf].t == "B") reverse = true;
				var platform:OutPlatform = new OutPlatform(int(damap[PLATFORMS][platf].x), int(damap[PLATFORMS][platf].y), pathlength, 0, direc, reverse);
				platforms.add(platform);
			}
			
			//Load game entities
			for (var enem:int = 0; enem < damap[ENTITIES].length; enem++)
			{
				try
				{
					var entity:Class = getDefinitionByName("entity.".concat(damap[ENTITIES][enem][2])) as Class;
					
					if (damap[ENTITIES][enem].hasOwnProperty(3))
					{
						new entity(damap[ENTITIES][enem][0], damap[ENTITIES][enem][1], damap[ENTITIES][enem][3]);
					}
					
					else
					{
						new entity(damap[ENTITIES][enem][0], damap[ENTITIES][enem][1]);
					}	
				}
				
				catch(error:Error)
				{
					
				}
			}
			
			//Load lasers
			for (var laser:int = 0; laser < damap[LASERS].length; laser++)
			{
				var laz:Laser = new Laser(new FlxPoint(int(damap[LASERS][laser][0]), int(damap[LASERS][laser][1])), 
				new FlxPoint(int(damap[LASERS][laser][2]), int(damap[LASERS][laser][3])), this);
				lasers.add(laz);
			}
		}
		
		override public function update():void
		{
			super.update();
			
			if (Registry.loadedmap)
			{
				if (Registry.leadset.open)
				{
					leadcount++;
					
					if (leadcount > 30)
					{
						Msg.score.msg["json"] = "";
						Msg.score.SendUnreliable();
						leadcount = 0;
					}
				}
				
				FlxG.collide(players, map);
				
				var deltay:Number = (player.y + player.height / 2) - FlxG.mouse.y;
				var deltax:Number = (player.x + player.width / 2) - FlxG.mouse.x;
				
				if (deltax == 0) deltax = 0.1;
				
				Msg.keystatus.msg["a"] = deltay / deltax;
				player.a = Msg.keystatus.msg["a"];
				
				if (FlxG.mouse.x > (player.x + player.width / 2)) 
				{
					player.right = true;
					Msg.keystatus.msg["lookright"] = true;
				}
				
				else 
				{
					player.right = false;
					Msg.keystatus.msg["lookright"] = false;
				}
				
				if (FlxG.mouse.pressed()) Msg.keystatus.msg["shooting"] = true;
				else Msg.keystatus.msg["shooting"] = false;
				
				elapsed += FlxG.elapsed;
				if (elapsed >= messagespersecond)
				{
					elapsed = 0;
					
					//The client-side update loop
					Msg.keystatus.msg["left"] = false;
					Msg.keystatus.msg["right"] = false;
					Msg.keystatus.msg["up"] = false;
					Msg.keystatus.msg["down"] = false;
					
					player.acceleration.x = 0;
					if (FlxG.keys.A)
					{
						player.acceleration.x = -player.maxVelocity.x * 4;
						Msg.keystatus.msg["left"] = true;
					}
					if (FlxG.keys.D)
					{
						player.acceleration.x = player.maxVelocity.x * 4;
						Msg.keystatus.msg["right"] = true;
					}
					if (FlxG.keys.S)
					{
						Msg.keystatus.msg["down"] = true;
					}
					if ((FlxG.keys.W || FlxG.keys.UP))
					{
						player.velocity.y = -player.maxVelocity.y / 2;
						Msg.keystatus.msg["up"] = true;
					}
					if (FlxG.keys.justReleased("TAB"))
					{
						Registry.leadset.toggle();
						Msg.score.msg["json"] = "";
						Msg.score.SendUnreliable();
					}
					
					if (FlxG.keys.justReleased("T")) chatbox.toggle();
					
					Msg.keystatus.SendUnreliable();
				}
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
	}
}