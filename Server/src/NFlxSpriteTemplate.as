package  
{
	import flash.utils.Dictionary;
	import org.flixel.FlxPoint;
	import Streamy.MsgObject;
	
	public class NFlxSpriteTemplate 
	{
		public var id:uint = 0;
		public var priority = MsgObject.STREAMY_PRT - 2;
		
		public var img:String; //
		public var active:Boolean = true;
		public var visible:Boolean = true;
		public var exists:Boolean = true;
		public var x:Number = 0.0;
		public var y:Number = 0.0;
		public var width:uint = 0; //
		public var height:uint = 0; //
		public var immovable:Boolean = false;
		public var elasticity:Number = 0;
		public var dragx:int = 0;
		public var accy:int = 0;
		public var scrollFactor:Number = 1; //same for x and y
		public var moves:Boolean = true;
		
		public var update:Array = [];
		public var init:Array = [];
		
		public var data:Object = new Object();
		
		public function exportTemplate():String 
		{
			data= new Object();
			
			data["img"] = img;
			data["width"] = width;
			data["height"] = height;
			data["update"] = update;
			data["init"] = init;
			
			checkDefault("active", true);
			checkDefault("visible", true);
			checkDefault("exists", true);
			checkDefault("x", 0.0);
			checkDefault("y", 0.0);
			checkDefault("immovable", false);
			checkDefault("elasticity", 0);
			checkDefault("moves", true);
			checkDefault("dragx", 0);
			checkDefault("accy", 0);
			checkDefault("scrollFactor", 1);
			//checkDefault("priority", MsgObject.STREAMY_PRT - 2);
			
			return JSON.stringify(data);
		}
		
		public function checkDefault(variable:String, def:*):void
		{
			if (this[variable] != def) data[variable] = this[variable];
		}
	}

}