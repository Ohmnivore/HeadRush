package  
{
	import org.flixel.FlxSprite;
	import Streamy.Message;
	import Streamy.MsgObject;
	import Streamy.ServerPeer;
	
	public class NFlxSprite extends FlxSprite
	{
		public var templ:uint = 0;
		public var upd:Array = [];
		public var init:Array = [];
		public var ID2:uint = 0;
		public var priority = MsgObject.STREAMY_PRT - 2;
		
		public function NFlxSprite(template:uint, x:Number = 0, y:Number = 0, localset = false, peer:ServerPeer = null)
		{
			templ = template;
			
			upd = NFlxSpritePreset.templ[templ].update;
			
			ID2 = NFlxSpritePreset.i;
			NFlxSpritePreset.items.push(this);
			NFlxSpritePreset.i++;
			
			priority = NFlxSpritePreset.templ[templ].priority;
			
			var t:NFlxSpriteTemplate = NFlxSpritePreset.templ[template] as NFlxSpriteTemplate;
			
			if (localset)
			{
				Registry.playstate.entities.add(this);
			}
			
			super(x, y, Assets[t.img]);
				
			t.exportTemplate();
			
			var props:Object = t.data;
			
			for (var prop:String in props)
			{
				trace(prop, props[prop]);
				switch (prop)
				{
					case "dragx":
						drag.x = props[prop];
						break;
					case "accy":
						acceleration.y = props[prop];
						break;
					case "scrollFactor":
						scrollFactor.x = scrollFactor.y = props[prop];
						break;
					case "img":
						if (localset) loadGraphic(Assets[props[prop]], false, true);
						break;
					case "update":
						upd = props[prop] as Array;
						break;
					case "init":
						init = props[prop] as Array;
						break;
					default:
						//trace(prop, props[prop]);
						this[prop] = props[prop];
						break;
				}
			}
		}
		
		public function declare(peer:ServerPeer = null)
		{
			var data:Array = [];
			
			for each (var prop:String in init)
			{
				data.push(getProp(prop));
			}
			trace(x, y);
			NFlxSpritePreset.createMsg.msg["json"] = JSON.stringify([[templ, ID2, x, y], data]);
			
			if (peer == null) NFlxSpritePreset.createMsg.SendReliableToAll(priority, ID2);
			else NFlxSpritePreset.createMsg.SendReliable(peer, priority, ID2);
		}
		
		public function killdelete(peer:ServerPeer = null, localset:Boolean = true)
		{
			NFlxSpritePreset.deleteMsg.msg["ID"] = ID2;
			
			if (peer == null) NFlxSpritePreset.deleteMsg.SendReliableToAll(priority, ID2);
			else NFlxSpritePreset.deleteMsg.SendReliable(peer, priority, ID2);
			
			if (localset)
			{
				Registry.playstate.entities.remove(this, true);
			}
			
			kill();
			destroy();
		}
		
		public function setImg(img:String, localset:Boolean = true, peer:ServerPeer = null):void
		{
			if (localset) loadGraphic(Assets[img]);
			
			NFlxSpritePreset.setImg.msg["name"] = img;
			
			if (peer == null) NFlxSpritePreset.setImg.SendReliableToAll(priority, ID2);
			else NFlxSpritePreset.setImg.SendReliable(peer, priority, ID2);
		}
		
		public function broadcastupdate(peer:ServerPeer = null, useTCP:Boolean = false):void
		{
			var msg:Array = [];
			msg.push(ID2);
			
			var data:Array = [];
			
			for each (var prop:String in upd)
			{
				data.push(getProp(prop));
			}
			
			msg.push(data);
			
			NFlxSpritePreset.updateMsg.msg["json"] = JSON.stringify(msg);
			
			if (useTCP)
			{
				if (peer == null) NFlxSpritePreset.updateMsg.SendReliableToAll(priority, ID2);
				else NFlxSpritePreset.updateMsg.SendReliable(peer, priority, ID2);
			}
			
			else
			{
				if (peer == null) NFlxSpritePreset.updateMsg.SendUnreliableToAll(priority, ID2);
				else NFlxSpritePreset.updateMsg.SendUnreliable(peer, priority, ID2);
			}
		}
		
		public function getProp(prop:String):*
		{
			if (prop.indexOf(".") > 0)
			{
				var subprops:Array = prop.split(".", 2);
				return this[subprops[0]][subprops[1]];
			}
			
			else
			{
				return this[prop];
			}
		}
		
		public function setProp(prop:String, value:*, localset:Boolean = true, peer:ServerPeer = null, useTCP:Boolean = false):void
		{
			if (prop.indexOf(".") > 0)
			{
				var subprops:Array = prop.split(".", 2);
				if (localset) this[subprops[0]][subprops[1]] = value;
			}
			
			else
			{
				if (localset) this[prop] = value;
			}
			
			NFlxSpritePreset.setMsg.msg["prop"] = prop;
			NFlxSpritePreset.setMsg.msg["json"] = JSON.stringify([ID2, value]);
			
			if (useTCP)
			{
				if (peer == null)
				{
					NFlxSpritePreset.setMsg.SendReliableToAll(priority, ID2);
				}
				
				else
				{
					NFlxSpritePreset.setMsg.SendReliable(peer, priority, ID2);
				}
			}
			
			else
			{
				if (peer == null)
				{
					NFlxSpritePreset.setMsg.SendUnreliableToAll(priority, ID2);
				}
				
				else
				{
					NFlxSpritePreset.setMsg.SendUnreliable(peer, priority, ID2);
				}

			}
		}
	}

}