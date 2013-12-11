package  
{
	import flash.utils.ByteArray;
	import org.flixel.FlxTilemap;
	import Streamy.Client;
	import Streamy.MsgHandler;
	import org.flixel.FlxG;
	
	public class RushClient extends Client
	{
		
		public function RushClient(address:String = null, addresstoconnect:String = null) 
		{
			super("127.0.0.1", 5600, 5600);
			if (addresstoconnect == null) Connect("127.0.0.1", 5613, 5613);
			else Connect("127.0.0.1", 5613, 5613);
		}
		
		override public function HandleMsg(event:MsgHandler):void
		{
			//FlxG.log("received");
			if (event.id == Msg.mapstring.ID)
			{
				FlxG.log("gotmap");
				var buffer:String = new String();
				buffer = LZW.decompress(Msg.mapstring.msg["compressed"]);
				
				Registry.playstate.loadmap(buffer);
				
				//var map:FlxTilemap = Registry.playstate.map;
				//map.loadMap(buffer, FlxTilemap.ImgAuto, 0, 0, FlxTilemap.AUTO);
				//Registry.playstate.add(map);
				
				Registry.loadedmap = true;
			}
			
			if (event.id == Msg.fellowclients.ID)
			{
				FlxG.log("gotfellows");
				Registry.playstate.player.ID = Msg.fellowclients.msg["yourid"];
				Registry.peers[Msg.fellowclients.msg["yourid"]] = Registry.playstate.player;
				//trace("fellowclients");
				//FlxG.log("fellowclients");
				//FlxG.log(Msg.fellowclients.msg["yourid"]);
				
				var peerarray:Object = new Array();
				peerarray = JSON.parse(Msg.fellowclients.msg["json"]);
				
				for each (var peerdescription:Array in peerarray)
				{
					var peer:Player = new Player(0, 0);
					peer.name = peerdescription[1];
					peer.ID = peerdescription[0];
					Registry.peers[peerdescription[0]] = peer;
					Registry.playstate.players.add(peer);
				}
				Registry.loadedpeers = true;
			}
			
			if (event.id == Msg.clientdisco.ID)
			{
				FlxG.log("gotdisco");
				Registry.peers[Msg.clientdisco.msg["id"]].kill();
				Registry.peers[Msg.clientdisco.msg["id"]].destroy();
				delete Registry.peers[Msg.clientdisco.msg["id"]];
			}
			
			if (event.id == Msg.newclient.ID)
			{
				FlxG.log("gotnewclient");
				var peerinfo:Object = new Array();
				peerinfo = JSON.parse(Msg.newclient.msg["json"]);
				var id:uint = Msg.newclient.msg["id"];
				var peer:Player = new Player(0, 0);
				peer.name = peerinfo[0];
				peer.ID = id;
				Registry.peers[id] = peer;
				Registry.playstate.players.add(peer);
			}
			
			if (event.id == Msg.clientpositions.ID && Registry.loadedpeers)
			{
				//FlxG.log("posupdate");
				var peerstates:Object = new Array();
				peerstates = JSON.parse(Msg.clientpositions.msg["json"]);
				
				for each (var peerstate:Array in peerstates)
				{
					//FlxG.log(peerstate[0]);
					Registry.peers[peerstate[0]].x = peerstate[1];
					Registry.peers[peerstate[0]].y = peerstate[2];
				}
			}
			
			if (event.id == Msg.announce.ID)
			{
				Registry.playstate.announcer.add(Msg.announce.msg["msg"]);
				FlxG.log(Msg.announce.msg["msg"]);
			}
		}
		
		public static function decode(str:String):ByteArray 
		{
			var result:ByteArray = new ByteArray();
			
			for (var i:int = 0; i < str.length; ++i) 
			{
				result.writeShort(str.charCodeAt(i));
			}
			result.position = 0;
			return result;
		}
	}

}