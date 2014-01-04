package entity 
{
	import gamemode.BaseTemplates;
	
	public class Flag extends NFlxSprite
	{
		
		public function Flag(x:Number, y:Number) 
		{
			super(BaseTemplates.flag.id, 300, 0, true);
		}
		
	}

}