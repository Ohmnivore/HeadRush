package  
{
	import org.flixel.*;
	
	public class PlayState extends FlxState
	{
		public var map:FlxTilemap;
		public var string:String;
		public var player:Player;
		public var players:FlxGroup = new FlxGroup();
		
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
			
			map = new FlxTilemap();
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
		
		override public function update():void
		{
			super.update();
			
			if (Registry.loadedmap)
			{
				FlxG.collide(players, map);
				
				elapsed += FlxG.elapsed;
				if (elapsed >= messagespersecond)
				{
					elapsed = 0;
					
					//The client-side update loop
					Msg.keystatus.msg["left"] = false;
					Msg.keystatus.msg["right"] = false;
					Msg.keystatus.msg["up"] = false;
					
					player.acceleration.x = 0;
					if (FlxG.keys.LEFT)
					{
						player.acceleration.x = -player.maxVelocity.x * 4;
						Msg.keystatus.msg["left"] = true;
					}
					if (FlxG.keys.RIGHT)
					{
						player.acceleration.x = player.maxVelocity.x * 4;
						Msg.keystatus.msg["right"] = true;
					}
					if ((FlxG.keys.SPACE || FlxG.keys.UP) && player.isTouching(FlxObject.ANY))
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