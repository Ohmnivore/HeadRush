package gamemode 
{
	import Streamy.MsgObject;
	
	public class BaseTemplates 
	{
		public static var flag:NFlxSpriteTemplate = new NFlxSpriteTemplate;
		public static var bullet:NFlxSpriteTemplate = new NFlxSpriteTemplate;
		
		public static function initTemplates():void
		{
			//flag
			flag.accy = 420;
			flag.height = 24;
			flag.width = 24;
			flag.img = "FLAG";
			flag.update = ["x", "y"];
			
			//bullet
			bullet.accy = 0;
			bullet.height = 6;
			bullet.width = 6;
			bullet.priority = MsgObject.STREAMY_PRT;
			bullet.img = "BULLET";
			bullet.init = ["velocity.x", "velocity.y"];
			//flag.update = ["x", "y"];
			
			//register all
			NFlxSpritePreset.register(flag);
			NFlxSpritePreset.register(bullet);
		}
		
	}

}