package  
{
	import org.flixel.FlxSprite;
	import Streamy.Message;
	import Streamy.ServerPeer;
	
	public class NFlxSprite extends FlxSprite
	{
		public static var initMsg:Message;
		public static var setMsg:Message;
		public static var setImg:Message;
		public static var updateMsg:Message;
		
		public static var i:uint = 0;
		
		public function NFlxSprite()
		{
			
		}
		
		public static function initMsg(net:*):void
		{
			setMsg = new Message(25, net);
			setMsg.SetFields("prop", "json");
			setMsg.SetTypes("String", "String");
			
			setImg = new Message(26, net);
			setImg.SetFields("json");
			setMsg.SetTypes("String");
		}
		
		public function setImg(img:String, anim:Boolean = false, reverse:Boolean = false, 
			width:uint = 0, height:uint = 0, localset:Boolean = true, peer:ServerPeer = null):void
		{
			if (localset) loadGraphic(Assets[img], anim, reverse, width, height);
			
			var arr:Array = [img, anim, reverse, width, height];
			setImg.msg["json"] = JSON.stringify(arr);
			
			if (peer == null) setImg.SendReliableToAll();
			else setImg.SendReliable(peer);
		}
		
		public function setProp(prop:String, value:*, localset:Boolean = true, peer:ServerPeer = null):void
		{
			if (prop.search(".") != -1)
			{
				var subprops:Array = prop.split(".", 2);
				if (localset) this[subprops[1]][subprops[2]] = value;
			}
			
			else
			{
				if (localset) this[prop] = value;
			}
			
			setMsg.msg["prop"] = prop;
			setMsg.msg["json"] = JSON.stringify(value);
			
			if (peer == null)
			{
				setMsg.SendReliableToAll();
			}
			
			else
			{
				setMsg.SendReliable(peer);
			}
		}
	}

}