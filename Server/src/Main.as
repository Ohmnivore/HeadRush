package 
{
    import org.flixel.*;
	/**
	 * ...
	 * @author Grey
	 */
	[SWF(width = "640", height = "480", backgroundColor = "#c2c2c2")]
	[Frame(factoryClass="Preloader")]

	public class Main extends org.flixel.FlxGame
	{
		
		public function Main()
		{
			FlxG.debug = true;
			super(320, 240, DigState, 2,60,60);
		}
		
	}
	
}