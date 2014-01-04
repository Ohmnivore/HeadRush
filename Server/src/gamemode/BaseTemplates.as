package gamemode 
{
	
	public class BaseTemplates 
	{
		public static var flag:NFlxSpriteTemplate = new NFlxSpriteTemplate;
		
		public static function initTemplates():void
		{
			//flag
			flag.accy = 420;
			flag.height = 24;
			flag.width = 24;
			flag.img = "FLAG";
			flag.update = ["x", "y"];
			
			//register all
			NFlxSpritePreset.register(flag);
		}
		
	}

}