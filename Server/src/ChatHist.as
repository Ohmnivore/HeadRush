package  
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxG;
	import org.flixel.FlxText;
	
	public class ChatHist 
	{
		public var display:FlxGroup = new FlxGroup();
		public var msg:Array = new Array();
		public var starty:Number = FlxG.height - 80;
		public var opened:Boolean = false;
		public var inity:Number = 80;
		public var toty:Number = 0;
		
		public function ChatHist() 
		{
			Registry.playstate.add(display);
		}
		
		public function toggle():void
		{
			if (opened)
			{
				opened = false;
			}
			
			else
			{
				opened = true;
			}
		}
		
		public function add(message:String, markup:Array = null):void
		{
			var text:FlxText = new FlxText(0, FlxG.height-inity, FlxG.width, message, true, true);
			//text.size = 8;
			//text._textField
			//text.alpha = 0.85;
			//text.Markup(new Array(20, 0xff000000, 0, 3));
			if (markup != null)
			{
				for each (var x:Array in markup) text.Markup(x);
			}
			text.scrollFactor.x = text.scrollFactor.y = 0;
			//text.font = "Kongtext";
			//text.width = message.length * text.size * 1.4;
			text.x = 0;
			
			for (var i:uint = 0; i < msg.length; i++)
			{
				if (i == 0)
				{
					msg[i].y += text.height;
				}
				
				else msg[i].y += msg[i - 1].height;
			}
			msg.push(text);
			//text.width = FlxG.width * 2;
			//text.
			//for each (var test:FlxText in Registry.playstate.hud.members) test.y += 40;
			
			Registry.playstate.chats.add(text);
			
			//Msg.announce.msg["text"] = message;
			//if (markup != null) Msg.announce.msg["markup"] = JSON.stringify(markup);
			//else Msg.announce.msg["markup"] = "";
			//Msg.announce.SendReliableToAll();
			
			if (msg.length > 4)
			{
				Registry.playstate.chats.remove(msg[0], true);
				msg.splice(0, 1);
			}
			
			if (opened)
				alignTop();
			else
				alignTop();
		}
		
		public function alignBot():void
		{
			if (msg.length > 0)
			{
				var t:FlxText = msg[msg.length - 1];
				var dist:Number = t.y - (FlxG.height - t.height);
				//trace(dist);
				for each (var x in msg)
				{
					x.y -= dist;
					//inity += dist;
				}
			}
		}
		
		public function alignTop():void
		{
			if (msg.length > 0)
			{
				var t:FlxText = msg[msg.length - 1];
				toty = 0;
				for each (var k in msg)
				{
					toty += k.height;
				}
				
				var dist:Number = t.y - (FlxG.height - toty);
				//trace(dist);
				
				var z:Number = 0;
				for (var x:int = msg.length-1; x > -1; x--)
				{
					if (x < 0) x = 0;
					trace(x);
					trace(String(msg.length).concat("-> x"));
					msg[x].y = (FlxG.height - toty) + z;
					z += msg[x].height;
				}
			}
		}
	}

}