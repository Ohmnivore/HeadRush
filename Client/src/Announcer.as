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
		
		public function add(message:String):void
		{
			var text:FlxText = new FlxText(0, 0, 200, message, true, true);
			text.scrollFactor.x = text.scrollFactor.y = 0;
			//text.font = "Kongtext";
			//text.width = message.length * text.size * 1.4;
			text.x = 320 - text.width - 2;
			
			for (var i:uint = 0; i < msg.length; i++)
			{
				msg[i].y += 12;
			}
			msg.push(text);
			//for each (var test:FlxText in Registry.playstate.hud.members) test.y += 40;
			
			Registry.playstate.hud.add(text);
			
			if (msg.length > 4)
			{
				Registry.playstate.hud.remove(msg[0], true);
				msg.splice(0, 1);
			}
		}
	}

}