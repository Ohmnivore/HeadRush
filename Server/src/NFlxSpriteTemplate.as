package  
{
	import flash.utils.Dictionary;
	import org.flixel.FlxPoint;
	
	public class NFlxSpriteTemplate 
	{
		public var img:String; //
		public var active:Boolean = true;
		public var visible:Boolean = true;
		public var exists:Boolean = true;
		public var x:Number = 0;
		public var y:Number = 0;
		public var width:uint = 0; //
		public var height:uint = 0; //
		public var immovable:Boolean = false;
		public var elasticity:Number = 0;
		public var dragx:int = 0;
		public var dragy:int = 0;
		public var scrollFactor:FlxPoint = new FlxPoint(0, 0);
		public var moves:Boolean = true;
		
		public var data:Dictionary = new Dictionary();
		
		public function exportTemplate():String 
		{
			data= new Dictionary();
			
			data[img] = img;
			data[width] = width;
			data[height] = height;
			
			checkDefault(active, true);
			checkDefault(visible, true);
			checkDefault(exists, true);
			checkDefault(x, 0);
			checkDefault(y, 0);
			checkDefault(immovable, false);
			checkDefault(elasticity, 0);
			checkDefault(moves, true);
			checkDefault(active, true);
			checkDefault(active, true);
			checkDefault(active, true);
		}
		
		public function checkDefault(variable:*, def:*):void
		{
			if (variable != def) data[variable] = variable;
		}
	}

}