package 
{
    import org.flixel.*;
	import flash.events.Event;
	
	[SWF(width = "640", height = "480", backgroundColor = "#c2c2c2")]
	[Frame(factoryClass="Preloader")]

	public class Main extends org.flixel.FlxGame
	{
		
		public function Main()
		{
			FlxG.debug = true;
			super(320, 240, SetupState, 2,60,30);
		}
		
		override protected function create(FlashEvent:Event):void
        {
            super.create(FlashEvent);
            stage.removeEventListener(Event.DEACTIVATE, onFocusLost);
            stage.removeEventListener(Event.ACTIVATE, onFocus);
			Registry.registercustoms();
        }
	}
	
}