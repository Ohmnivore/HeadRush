package  
{
	import org.flixel.*;
	
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
		public static var maps:Array = new Array();
		public static var mapz:Array = new Array();
		public var announcer:Announcer = new Announcer();
		
		internal var elapsed:Number;
		internal var messagespersecond:uint;
		internal var rate:Number;
		
		override public function create():void 
		{
			super.create();
			
			elapsed = 0;
			rate = 1.0 / messagespersecond;
			
			Registry.playstate = this;
			Registry.client = new RushClient("127.0.0.1", "127.0.0.1");
			Msg.init();
			
			add(players);
			player = new Player(70, 70);
			players.add(player);
			
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
		}
		
		public function loadmap(mapstring:String):void
		{
			var damap = JSON.parse(mapstring);
			var materialmap:FlxTilemap = new FlxTilemap();
			var lavamap:FlxTilemap = new FlxTilemap();
			
			for (var layer:int = 0; layer < damap[3].length; layer++)
			{
				maps[layer] = new FlxTilemap;
				mapz[layer] = new BTNTilemap;
				if (damap[3][layer][0] == 'Collide') 
				{
					map = mapz[layer].loadMap(damap[3][layer][1], Assets.T_COLLIDE, 8, 8);
					map.setTileProperties(0, FlxObject.NONE);
					map.setTileProperties(1, FlxObject.ANY);
					FlxG.worldBounds = new FlxRect(0, 0, map.width, map.height);
					map.visible = false;
					//map.setTileProperties(2, FlxObject.ANY, CeilingWalk, Player, 1);
					//map.setTileProperties(1, FlxObject.ANY, LedgeGrab, CollideShadow, 1);
					//trace("collide");
					//GenerateEdges();
					
					var pattern:RegExp = /1/g;
					var materialstring:String = damap[3][layer][1].replace(pattern, "0");
					var pattern2:RegExp = /3/g;
					materialstring = materialstring.replace(pattern2, "0");
					pattern = /2/g;
					materialstring = materialstring.replace(pattern, "1");
					
					materialmap.loadMap(materialstring, Assets.T_MATERIAL, 8, 8);
					materialmap.setTileProperties(0, FlxObject.NONE);
					materialmap.setTileProperties(1, FlxObject.NONE);
					
					pattern = /1/g;
					var lavastring:String = damap[3][layer][1].replace(pattern, "0");
					pattern2 = /2/g;
					lavastring = lavastring.replace(pattern2, "0");
					pattern = /3/g;
					lavastring = lavastring.replace(pattern, "1");
					
					lavamap.loadMap(lavastring, Assets.T_MATERIAL, 8, 8);
					lavamap.setTileProperties(0, FlxObject.NONE);
					lavamap.setTileProperties(1, FlxObject.NONE);
				}
				if (damap[3][layer][0] == 'Snow') 
				{
					var frontmap:FlxTilemap;
					frontmap = maps[layer].loadMap(damap[3][layer][1], Assets.T_SNOW, 16, 16);
				}
				if (damap[3][layer][0] == 'SnowBack') 
				{
					var backmap:FlxTilemap;
					backmap = maps[layer].loadMap(damap[3][layer][1], Assets.T_SNOW, 16, 16);
					backmap.scrollFactor.x = backmap.scrollFactor.y = 0.8;
				}
			}
			
			add(backmap);
			add(lasers);
			add(lavamap);
			add(frontmap);
			add(materialmap);
			add(platforms);
			add(hud);
			add(huds);
			
			//Load platforms
			for (var platf:int = 0; platf < damap[4].length; platf++)
			{
				var pathlength:int;
				var direc:String;
				
				trace(damap[4][platf].w, ":", damap[4][platf].h);
				
				if (int(damap[4][platf].w) > int(damap[4][platf].h)) 
				{
					direc = "x";
					pathlength = int(damap[4][platf].w) - 48;
				}
				else 
				{
					direc = "y";
					pathlength = int(damap[4][platf].h) - 16;
				}
				
				var reverse:Boolean = false;
				if (damap[4][platf].t == "R" || damap[4][platf].t == "B") reverse = true;
				var platform:OutPlatform = new OutPlatform(int(damap[4][platf].x), int(damap[4][platf].y), pathlength, 0, direc, reverse);
				platforms.add(platform);
			}
			
			//Load game entities
			for (var enem:int = 0; enem < damap[1].length; enem++)
			{
				switch (damap[1][enem][2])
				{
					case "Spawn":
						break;
				}		
			}
			
			//Load lasers
			for (var laser:int = 0; laser < damap[0].length; laser++)
			{
				var laz:Laser = new Laser(new FlxPoint(int(damap[0][laser][0]), int(damap[0][laser][1])), 
				new FlxPoint(int(damap[0][laser][2]), int(damap[0][laser][3])), this);
				lasers.add(laz);
			}
		}
		
		override public function update():void
		{
			super.update();
			
			//if (Registry.loadedmap)
			if (Registry.loadedmap)
			{
				FlxG.collide(players, map);
				
				var deltay:Number = (player.y + player.height / 2) - FlxG.mouse.y;
				var deltax:Number = (player.x + player.width / 2) - FlxG.mouse.x;
				
				if (deltax == 0) deltax = 0.1;
				
				Msg.keystatus.msg["a"] = deltay / deltax;
				
				if (FlxG.mouse.x > (player.x + player.width / 2)) Msg.keystatus.msg["lookright"] = true;
				else Msg.keystatus.msg["lookright"] = false;
				//FlxG.log(toString(FlxG.mouse).concat(new String("player: ").concat(toString(player.x + player.width/2))));
				
				if (FlxG.mouse.pressed()) Msg.keystatus.msg["shooting"] = true;
				else Msg.keystatus.msg["shooting"] = false;
				
				//FlxG.log(StriFlxG.mouse.pressed);
				
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