package  
{
	import org.flixel.*;
	
	public class PlayState extends FlxState
	{
		public var map:FlxTilemap;
		public var string:String;
		public var spawns:Array = new Array();
		public var players:FlxGroup = new FlxGroup();
		
		override public function create():void 
		{
			super.create();
			
			Registry.playstate = this;
			
			FlxG.bgColor = 0xff7A7A7A;
			
			map = new FlxTilemap();
			string = convertMatrixToStr(Registry.mapray);
			map.loadMap(string, FlxTilemap.ImgAuto, 8, 8, FlxTilemap.AUTO);
			add(map);
			
			add(players);
			
			var spect:Spectator = new Spectator(0, 0);
			add(spect);
			
			FlxG.camera.setBounds(0, 0, map.width, map.height);
			FlxG.camera.follow(spect);
		}
		
		override public function update():void
		{
			super.update();
			FlxG.collide(players, map);
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
				
				if (Registry.mapray[y][x] == 1)
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