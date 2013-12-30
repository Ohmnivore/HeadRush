package  
{
	import Streamy.Message;
	
	public class Msg 
	{
		public static var network:RushServer;
		public static const USERMSG:uint = 50;
		
		public static var mapstring:Message;
		public static var fellowclients:Message;
		public static var newclient:Message;
		public static var clientpositions:Message;
		public static var keystatus:Message;
		public static var clientdisco:Message;
		public static var announce:Message;
		public static var hud:Message;
		public static var dl:Message;
		public static var score:Message;
		public static var chat:Message;
		public static var pinfo:Message;
		
		public static function init():void
		{
			network = Registry.server;
			
			mapstring = new Message(10, network);
			mapstring.SetFields("compressed");
			mapstring.SetTypes("String");
			
			fellowclients = new Message(11, network);
			fellowclients.SetFields("yourid", "json");
			fellowclients.SetTypes("Int", "String");
			
			clientpositions = new Message(12, network);
			clientpositions.SetFields("json");
			clientpositions.SetTypes("String");
			
			keystatus = new Message(13, network);
			keystatus.SetFields("right", "left", "up", "a", "lookright", "shooting", "down");
			keystatus.SetTypes("Boolean", "Boolean", "Boolean", "Float", "Boolean", "Boolean", "Boolean");
			
			newclient = new Message(14, network);
			newclient.SetFields("id", "json");
			newclient.SetTypes("Int", "String");
			
			clientdisco = new Message(15, network);
			clientdisco.SetFields("id");
			clientdisco.SetTypes("Int");
			
			announce = new Message(16, network);
			announce.SetFields("text", "markup");
			announce.SetTypes("String", "String");
			
			hud = new Message(17, network);
			hud.SetFields("json");
			hud.SetTypes("String");
			
			dl = new Message(18, network);
			dl.SetFields("dlurl", "jsonmanifests");
			dl.SetTypes("String", "String");
			
			score = new Message(19, network);
			score.SetFields("json");
			score.SetTypes("String");
			
			chat = new Message(20, network);
			chat.SetFields("text", "markup");
			chat.SetTypes("String", "String");
		}
	}

}