package  
{
	public class Markup 
	{
		public var size:uint = 9;
		public var color:uint = 0xffffffff; //White
		public var startindex:int;
		public var endindex:int;
		
		public function Markup(Startindex:int, Endindex:int, Size:uint = 9, Color:uint = 0xffffffff) 
		{
			startindex = Startindex;
			endindex = Endindex;
			size = Size;
			color = Color;
		}
		
	}
}