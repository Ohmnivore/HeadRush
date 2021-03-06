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
		
		public function add(text:MarkupText):void
		{
			text.scrollFactor.x = text.scrollFactor.y = 0;
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
			
			Registry.playstate.hud.add(text);
			
			if (msg.length > 4)
			{
				Registry.playstate.hud.remove(msg[0], true);
				msg.splice(0, 1);
			}
		}
	}

}