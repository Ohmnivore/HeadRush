package  
{
	import org.flixel.*;
	
	public class Player extends FlxSprite
	{
		public var name:String;
		public var a:Number;

		public function Player(_x:int, _y:int):void 
		{		
			super(_x, _y);
			makeGraphic(24,24,0xffaa1111);
			maxVelocity.x = 80;
			maxVelocity.y = 200;
			acceleration.y = 200;
			drag.x = maxVelocity.x * 4;
			
			name = "Ohmni";
		}

		public override function update():void
		{
			super.update();
			
		}
	}
}
