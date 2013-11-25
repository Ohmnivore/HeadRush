package  
{
	import flash.utils.ByteArray;
	import org.flixel.*;
	
	public class PlayState extends FlxState
	{
		public var map:FlxTilemap;
		public var string:String;
		public var spawns:Array = new Array();
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
			Registry.server = new RushServer();
			
			Msg.init();
			
			FlxG.bgColor = 0xff7A7A7A;
			
			map = new FlxTilemap();
			string = convertMatrixToStr(Registry.mapray);
			var temp:String = new String();
			temp = LZW.compress(string);
			trace(string.length);
			//temp.compress();
			trace(temp.length);
			map.loadMap(string, FlxTilemap.ImgAuto, 8, 8, FlxTilemap.AUTO);
			add(map);
			
			add(players);
			
			var spect:Spectator = new Spectator(0, 0);
			add(spect);
			
			generatespawns();
			
			FlxG.camera.setBounds(0, 0, map.width, map.height);
			FlxG.camera.follow(spect);
			
			Msg.mapstring.msg["compressed"] = temp;
		}
		
		override public function update():void
		{
			super.update();
			FlxG.collide(players, map);
			
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