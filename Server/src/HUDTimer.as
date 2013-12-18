package  
{
	import org.flixel.FlxPoint;
	
	public class HUDTimer extends HUDLabel
	{
		public var seconds:Number;
		public var descending:Boolean;
		
		public function HUDTimer(ID:uint, ScrollFact:Number, Secs:Number, Descending:Boolean = true, Color:uint = 0xff000000, 
								Size:uint = 10, Pos:FlxPoint = null)
		{
			super(ID, ScrollFact, "", Color, Size, Pos);
			seconds = Secs;
			descending = Descending;
		}
		
		override public function Init(player:Player):void
		{
			var arr:Array = ["i", "timer", id, scrollfact];
			Msg.hud.msg["json"] = JSON.stringify(arr);
			Msg.hud.SendReliable(player.peer);
		}
		
		override public function Set(player:Player):void
		{
			var arr:Array = ["st", id, seconds, descending, color, size];
			Msg.hud.msg["json"] = JSON.stringify(arr);
			Msg.hud.SendReliable(player.peer);
		}
		
		public function Start(player:Player):void
		{
			var arr:Array = ["start", id, seconds, descending];
			Msg.hud.msg["json"] = JSON.stringify(arr);
			Msg.hud.SendReliable(player.peer);
		}
		
		public function Stop(player:Player):void
		{
			var arr:Array = ["stop", id, seconds, descending];
			Msg.hud.msg["json"] = JSON.stringify(arr);
			Msg.hud.SendReliable(player.peer);
		}
	}

}