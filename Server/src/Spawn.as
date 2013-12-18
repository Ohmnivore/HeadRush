package  
{
	import org.flixel.FlxPoint;
	
	public class Spawn extends FlxPoint
	{
		public var team:uint;
		
		public function Spawn(x:Number, y:Number, Team = 0) 
		{
			super(x, y);
			team = Team;
		}
		
	}

}