package  
{
	import Streamy.Message;
	
	public class Msg 
	{
		public static var client:RushClient;
		
		public static var mapstring:Message;
		public static var fellowclients:Message;
		public static var newclient:Message;
		public static var clientpositions:Message;
		public static var keystatus:Message;
		public static var clientdisco:Message;
		
		public static function init():void
		{
			client = Registry.client;
			
			mapstring = new Message(10, client);
			mapstring.SetFields("compressed");
			mapstring.SetTypes("String");
			
			fellowclients = new Message(11, client);
			fellowclients.SetFields("yourid", "json");
			fellowclients.SetTypes("Int", "String");
			
			clientpositions = new Message(12, client);
			clientpositions.SetFields("json");
			clientpositions.SetTypes("String");
			
			keystatus = new Message(13, client);
			keystatus.SetFields("right", "left", "up");
			keystatus.SetTypes("Boolean", "Boolean", "Boolean");
			
			newclient = new Message(14, client);
			newclient.SetFields("id", "json");
			newclient.SetTypes("Int", "String");
			
			clientdisco = new Message(15, client);
			clientdisco.SetFields("id");
			clientdisco.SetTypes("Int");
		}
	}

}