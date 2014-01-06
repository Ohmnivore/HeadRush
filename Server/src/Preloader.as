package 
{ 
	import org.flixel.system.FlxPreloader;
	
	public class Preloader extends FlxPreloader 
	{ 
		public function Preloader():void
	    {
	        className = "Main";
	        super();
			//trace("PATH: ", root.loaderInfo.loaderURL);
        }
    }
}
