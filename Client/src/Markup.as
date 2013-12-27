package  
{
	public class Markup 
	{
		public var size:uint = 9;
		public var color:uint = 0xffffffff;
		public var startindex:int;
		public var endindex:int;
		
		/**
		 * Object to be passed to MarkupText's constructor/Markitup function
		 * 
		 * @param	Startindex		Zero-based, specifies first included character.
		 * @param	Endindex		First character after the markup, also zero-based.
		 * @param	Size			The size. Default is the flixel default (8).
		 * @param	Color			Markup color. Duh. Default is white like Tide!
		 */
		public function Markup(Startindex:int, Endindex:int, Size:uint = 8, Color:uint = 0xffffffff) 
		{
			startindex = Startindex;
			endindex = Endindex;
			size = Size;
			color = Color;
		}
		
	}
}