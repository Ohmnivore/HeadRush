package  
{
	import org.flixel.FlxText;
	
	public class Announcer
	{
		public var msg:Array = new Array();
		
		public function Announcer() 
		{
			super();
		}
		
		public function add(message:String, markup:Array = null):void
		{
			var text:FlxText = new FlxText(0, 0, 200, message, true, true);
			//text.Markup(new Array(20, 0xff000000, 0, 3));
			if (markup != null)
			{
				for each (var x:Array in markup) text.Markup(x);
			}
			text.scrollFactor.x = text.scrollFactor.y = 0;
			//text.font = "Kongtext";
			//text.width = message.length * text.size * 1.4;
			text.x = 320 - text.width - 2;
			
			for (var i:uint = 0; i < msg.length; i++)
			{
				if (i == 0)
				{
					msg[i].y += text.height;
				}
				
				else msg[i].y += msg[i - 1].height;
			}
			msg.push(text);
			//for each (var test:FlxText in Registry.playstate.hud.members) test.y += 40;
			
			Registry.playstate.hud.add(text);
			
			Msg.announce.msg["text"] = message;
			if (markup != null) Msg.announce.msg["markup"] = JSON.stringify(markup);
			else Msg.announce.msg["markup"] = "";
			Msg.announce.SendReliableToAll();
			
			if (msg.length > 4)
			{
				Registry.playstate.hud.remove(msg[0], true);
				msg.splice(0, 1);
			}
		}
	}

}