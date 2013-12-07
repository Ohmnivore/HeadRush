package  
{
	import flash.utils.ByteArray;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	public class PlayState extends FlxState
	{
		public var map:BTNTilemap;
		public var string:String;
		public var spawns:Array = new Array();
		public var players:FlxGroup = new FlxGroup();
		
		public var random:Boolean = false;
		public var levelindex:String = "Test";
		
		public var lasers:FlxGroup = new FlxGroup();
		public var platforms:FlxGroup = new FlxGroup();
		public var charunderlay:FlxGroup = new FlxGroup();
		public static var maps:Array = new Array();
		public static var mapz:Array = new Array();
		
		internal var elapsed:Number;
		internal var messagespersecond:uint;
		internal var rate:Number;
		
		override public function create():void 
		{
			super.create();
			
			elapsed = 0;
			rate = 1.0 / messagespersecond;
			
			Registry.playstate = this;
			Registry.server = new RushServer();
			
			Msg.init();
			
			FlxG.bgColor = 0xff7A7A7A;
			
			if (random) RandomMap();
			
			else 
			{
				spawns.push(new FlxPoint(30, 0));
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
			add(players);
			
			add(charunderlay);
			
			var spect:Spectator = new Spectator(0, 0);
			add(spect);
			
			FlxG.camera.setBounds(0, 0, map.width, map.height);
			FlxG.camera.follow(spect);
		}
		
		public function LoadMap():void
		{
			var materialmap:FlxTilemap = new FlxTilemap();
			
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
					pattern = /2/g;
					materialstring = materialstring.replace(pattern, "1");
					
					materialmap.loadMap(materialstring, Assets.T_MATERIAL, 8, 8, FlxTilemap.OFF, 0, 1, FlxObject.NONE);
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
			add(frontmap);
			add(materialmap);
			add(platforms);
			
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
			FlxG.collide(players, map);
			
			for each (var laser:Laser in lasers.members)
			{
				for each (var player in players.members)
				{
					if (FlxCollision.pixelPerfectCheck(laser, player, 255))
					{
						//player hit laser
					}
				}
			}
			
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
				Msg.clientpositions.SendReliableToAll();
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