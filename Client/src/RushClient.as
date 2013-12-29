package  
{
	import flash.utils.ByteArray;
	import org.flixel.FlxPoint;
	import org.flixel.FlxText;
	import org.flixel.FlxTilemap;
	import Streamy.Client;
	import Streamy.MsgHandler;
	import org.flixel.FlxG;
	
	public class RushClient extends Client
	{
		
		public function RushClient(address:String = null, addresstoconnect:String = null) 
		{
			super("127.0.0.1", 5600, 5600);
			Connect(Registry.servaddr, 5613, 5613);
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
					Registry.peers[peerstate[0]].velocity.x = peerstate[1] - Registry.peers[peerstate[0]].x;
					Registry.peers[peerstate[0]].velocity.y = peerstate[2] - Registry.peers[peerstate[0]].y;
					Registry.peers[peerstate[0]].x = peerstate[1];
					Registry.peers[peerstate[0]].y = peerstate[2];
				}
			}
			
			if (event.id == Msg.announce.ID)
			{
				var core:MarkupText = new MarkupText(0, 0, 500, Msg.announce.msg["text"], true, true);
				trace(Msg.announce.msg["markup"]);
				if (Msg.announce.msg["markup"].length > 0) core.ImportMarkups(Msg.announce.msg["markup"]);
				
				Registry.playstate.announcer.add(core);
			}
			
			if (event.id == Msg.hud.ID)
			{
				var msgarray:Array = JSON.parse(Msg.hud.msg["json"]) as Array;
				
				if (msgarray[0] == "i")
				{
					if (msgarray[1] == "label")
					{
						//var arr:Array = ["i", "label", id, scrollfact];
						var t:FlxText = new FlxText(0, 0, 100, "", true);
						t.scrollFactor = new FlxPoint(msgarray[3], msgarray[3]);
						Registry.huds[msgarray[2]] = t;
						Registry.playstate.huds.add(t);
					}
					
					if (msgarray[1] == "timer")
					{
						//var arr:Array = ["i", "label", id, scrollfact];
						var t:FlxText = new HUDTimer(0, 0, 100, "");
						t.scrollFactor = new FlxPoint(msgarray[3], msgarray[3]);
						Registry.huds[msgarray[2]] = t;
						Registry.playstate.huds.add(t);
					}
				}
				
				if (msgarray[0] == "s")
				{
					//var arr:Array = ["s", id, text, color, size];
					Registry.huds[msgarray[1]].text = msgarray[2];
					Registry.huds[msgarray[1]].color = msgarray[3];
					Registry.huds[msgarray[1]].size = msgarray[4];
				}
				
				if (msgarray[0] == "st")
				{
					//var arr:Array = ["st", id, seconds, descending, color, size];
					Registry.huds[msgarray[1]].seconds = msgarray[2];
					Registry.huds[msgarray[1]].descending = msgarray[3];
					Registry.huds[msgarray[1]].color = msgarray[4];
					Registry.huds[msgarray[1]].size = msgarray[5];
				}
				
				if (msgarray[0] == "start")
				{
					//var arr:Array = ["start", id, seconds, descending];
					Registry.huds[msgarray[1]].descending = msgarray[3];
					Registry.huds[msgarray[1]].seconds = msgarray[2];
					Registry.huds[msgarray[1]].running = true;
				}
				
				if (msgarray[0] == "stop")
				{
					//var arr:Array = ["stop", id, seconds, descending];
					Registry.huds[msgarray[1]].descending = msgarray[3];
					Registry.huds[msgarray[1]].seconds = msgarray[2];
					Registry.huds[msgarray[1]].update();
					Registry.huds[msgarray[1]].running = false;
				}
				
				if (msgarray[0] == "d")
				{
					//var arr:Array = ["d", id];
					Registry.playstate.huds.remove(Registry.huds[msgarray[1]], true);
					Registry.huds[msgarray[1]].kill();
					Registry.huds[msgarray[1]].destroy();
					delete Registry.huds[msgarray[1]];
				}
				
				if (msgarray[0] == "p")
				{
					//var arr:Array = ["p", id, pos.x, pos.y];
					Registry.huds[msgarray[1]].x = msgarray[2];
					Registry.huds[msgarray[1]].y = msgarray[3];
				}
			}
			
			if (event.id == Msg.dl.ID)
			{
				Downloader.dlurl = Msg.dl.msg["dlurl"];
				Downloader.dlmanifests = JSON.parse(Msg.dl.msg["jsonmanifests"]) as Array;
				//FlxG.log("");
				Downloader.Go();
			}
			
			if (event.id == Msg.score.ID)
			{
				FlxG.log("got scoreboard");
			}
			
			if (event.id == Msg.chat.ID)
			{
				//Check if it's the client's own message.
				if (Msg.chat.msg["text"].slice(0, Registry.playstate.player.name.length) != Registry.playstate.player.name)
				{
					var core:MarkupText = new MarkupText(0, 0, 500, Msg.chat.msg["text"], true, true);
					trace(Msg.chat.msg["markup"]);
					if (Msg.chat.msg["markup"].length > 0) core.ImportMarkups(Msg.chat.msg["markup"]);
					
					Registry.playstate.chathist.add(core);
				}
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