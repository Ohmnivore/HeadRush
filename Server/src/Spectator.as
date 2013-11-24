package  
{
	import org.flixel.*;
	
	public class Spectator extends FlxSprite
	{
		
		public var PLAYER_RUN_SPEED:int = 70;
		public var zone:FlxRect;
		
		public function Spectator(_x:int, _y:int):void 
		{		
			super(_x, _y);
			
			var map:FlxTilemap = Registry.playstate.map;
			
			zone = new FlxRect(FlxG.width/2, FlxG.height/2, map.width - FlxG.width - 20, map.height - FlxG.height - 20);
			
			scrollFactor = new FlxPoint(1, 1);
			
			drag.x = PLAYER_RUN_SPEED * 3;
			drag.y = PLAYER_RUN_SPEED * 3;
			
			maxVelocity.x = PLAYER_RUN_SPEED;
			maxVelocity.y = PLAYER_RUN_SPEED;
			
			solid = false;
			
			visible = false;
			
			//FlxG.camera.follow(this, 3);
		}

		public override function update():void
		{
			//super.update();
			//super.update();
			acceleration.x = 0;
			acceleration.y = 0;
			
			if (FlxG.keys.LEFT)
			{
				acceleration.x = -drag.x;
				//x--;
			}
			
			if (FlxG.keys.RIGHT)
			{
				acceleration.x = drag.x;	
				//x++;
			}
			
			if (FlxG.keys.UP)
			{
				acceleration.y = -drag.y;
				//y--;
			}
			
			if (FlxG.keys.DOWN)
			{
				acceleration.y = drag.y;
				//y++;
			}
			
			if (x < zone.x) x = zone.x;
			if (y < zone.y) y = zone.y;
			if (x > zone.x + zone.width) x = zone.x + zone.width;
			if (y > zone.y + zone.height) y = zone.y + zone.height;
			
			super.update();
			//super.update();
		}
	}
}
