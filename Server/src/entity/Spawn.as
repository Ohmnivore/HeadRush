package entity
{
	import org.flixel.FlxPoint;
	
	public class Spawn extends FlxPoint
	{
		public var team:int;
		
		public function Spawn(x:Number, y:Number, data:Object = null) 
		{
			super(x, y);
			
			if (data != null)
			{
				team = data["team"];
			}
			
			else
			{
				team = 0;
			}
			
			Registry.playstate.spawns.push(this);
		}
		
	}

}