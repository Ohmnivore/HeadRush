package  
{
	import org.flixel.FlxPoint;
	
	public class HUDLabel extends HUDBase
	{
		public var text:String;
		public var color:uint;
		public var size:uint;
		public var pos:FlxPoint;
		
		public function HUDLabel(ID:uint, ScrollFact:Number, Text:String, Color:uint = 0xff000000, 
								Size:uint = 10, Pos:FlxPoint = null) 
		{
			super(ID);
			text = Text;
			color = Color;
			scrollfact = ScrollFact;
			size = Size;
			pos = Pos;
			if (pos == null)  pos = new FlxPoint(0, 0);
		}
		
		public function Init(player:Player):void
		{
			var arr:Array = ["i", "label", id, scrollfact];
			Msg.hud.msg["json"] = JSON.stringify(arr);
			Msg.hud.SendReliable(player.peer);
		}
		
		public function Set(player:Player):void
		{
			var arr:Array = ["s", id, text, color, size];
			Msg.hud.msg["json"] = JSON.stringify(arr);
			Msg.hud.SendReliable(player.peer);
		}
		
		public function Pos(player:Player):void
		{
			var arr:Array = ["p", id, pos.x, pos.y];
			Msg.hud.msg["json"] = JSON.stringify(arr);
			Msg.hud.SendReliable(player.peer);
		}
		
		public function Del(player:Player):void
		{
			var arr:Array = ["d", id];
			Msg.hud.msg["json"] = JSON.stringify(arr);
			Msg.hud.SendReliable(player.peer);
		}
	}

}