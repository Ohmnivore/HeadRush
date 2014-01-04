package  
{
	import org.flixel.FlxSprite;
	
	public class NFlxSprite extends FlxSprite
	{	
		public var upd:Array = [];
		public var init:Array = [];
		
		public function NFlxSprite(x:Number, y:Number, props:Object, id:uint, Init:Array) 
		{
			super(x, y);
			ID = id;
			
			for (var prop:String in props)
			{
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
						loadGraphic(Assets[props[prop]], false, true);
						//this.framePixels = Assets.assets["link"];
						break;
					case "update":
						upd = props[prop] as Array;
						break;
					case "init":
						init = props[prop] as Array;
						break;
					default:
						this[prop] = props[prop];
						break;
				}
			}
			
			for (var i:uint; i < init.length; i++)
			{
				//this[upd[i]] = data[i];
				setProp(init[i], Init[i]);
			}
			
			Registry.playstate.entities.add(this);
			
			NFlxSpritePreset.items[id] = this;
		}
		
		public function applyupdate(data:Array):void
		{
			for (var i:uint; i < upd.length; i++)
			{
				//this[upd[i]] = data[i];
				setProp(upd[i], data[i]);
			}
		}
		
		public function setProp(prop:String, value:*):void
		{
			if (prop.indexOf(".") > 0)
			{
				var subprops:Array = prop.split(".", 2);
				this[subprops[0]][subprops[1]] = value;
			}
			
			else
			{
				this[prop] = value;
			}
		}
	}

}