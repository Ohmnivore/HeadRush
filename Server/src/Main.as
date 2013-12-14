package 
{
	import flash.display.Stage;
    import org.flixel.*;
	import flash.events.Event;
	
	[SWF(width = "640", height = "480", backgroundColor = "#c2c2c2")]
	[Frame(factoryClass="Preloader")]

	public class Main extends org.flixel.FlxGame
	{
		//public var stage:Stage = FlxG.stage;
		
		
		public function Main()
		{
			FlxG.debug = true;
			super(320, 240, DigState, 2,60,60);
		}
		
		override protected function create(FlashEvent:Event):void
        {
            super.create(FlashEvent);
			stage.addEventListener(Event.CLOSING, onShutdown);
            stage.removeEventListener(Event.DEACTIVATE, onFocusLost);
            stage.removeEventListener(Event.ACTIVATE, onFocus);
        }
		
		public function onShutdown(e:Event):void
		{
			Registry.ms.shutdown();
		}
	}
	
}