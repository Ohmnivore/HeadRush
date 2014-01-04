package  
{
	import Streamy.Message;
	public class NFlxSpritePreset 
	{
		public static var templ:Array = [];
		public static var items:Object = new Object;
		public static var t:uint = 0;
		public static var i:uint = 0;
		
		public static var exportMsg:Message;
		public static var createMsg:Message;
		public static var setMsg:Message;
		public static var setImg:Message;
		public static var updateMsg:Message;
		public static var deleteMsg:Message;
		
		public static function initMsg(net:*):void
		{
			exportMsg = new Message(30, net);
			exportMsg.SetFields("json");
			exportMsg.SetTypes("String");
			
			setMsg = new Message(25, net);
			setMsg.SetFields("prop", "json");
			setMsg.SetTypes("String", "String");
			
			setImg = new Message(26, net);
			setImg.SetFields("ID", "name");
			setMsg.SetTypes("Int", "String");
			
			createMsg = new Message(27, net);
			createMsg.SetFields("json");
			createMsg.SetTypes("String");
			
			updateMsg = new Message(28, net);
			updateMsg.SetFields("json");
			updateMsg.SetTypes("String");
			
			deleteMsg = new Message(29, net);
			deleteMsg.SetFields("ID");
			deleteMsg.SetTypes("Int");
		}
		
		public static function register(template:Object):void
		{
			templ.push(template);
			//template.id = t;
			t++;
		}
		
		public static function importPresets(json:String):void
		{
			var data:Array = JSON.parse(json) as Array;
			
			for each (var template:Object in data)
			{
				register(template);
			}
		}
	}
}