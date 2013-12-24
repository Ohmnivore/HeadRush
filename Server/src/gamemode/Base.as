package gamemode 
{
	
	public class Base 
	{
		
		public function Base() 
		{
			
		}
		
		public function mapproperties(data:Object):void
		{
			ServerInfo.map = data["mapname"];
			ServerInfo.gamemode = data["gamemode"];
		}
		
		public function shutdown():void
		{
			
		}
		
	}

}