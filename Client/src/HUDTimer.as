package  
{
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	
	public class HUDTimer extends FlxText
	{
		public var seconds:Number;
		public var descending:Boolean;
		public var running:Boolean;
		
		public function HUDTimer(X:Number, Y:Number, Width:uint, Text:String) 
		{
			super(X, Y, Width, Text);
			//width = 6 * (size+2);
			//font = "Kongtext";
		}
		
		override public function update():void
		{
			if (running)
			{
				if (descending)
				{
					seconds -= FlxG.elapsed;
				}
				
				else seconds += FlxG.elapsed;
			}
			
			var min:int = int(seconds / 60);
			var secs:int = int(seconds - min * 60);
			var secstring:String = new String();
			if (secs < 10) secstring = String("0").concat(String(secs));
			else secstring = String(secs);
			
			text = String(min).concat(String(":")).concat(secstring);
		}
	}

}