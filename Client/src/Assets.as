package  
{
	public class Assets 
	{
		public static const maxtracks:uint = 2;
		
		[Embed(source = "art/tilemaps/snow.png")]
		public static const T_SNOW:Class;
		[Embed(source = "art/tilemaps/collision.png")]
		public static const T_COLLIDE:Class;
		[Embed(source = "art/tilemaps/supermaterial.png")]
		public static const T_MATERIAL:Class;

		[Embed(source = "art/gun.png")]
		public static const GUN:Class;
		
		[Embed(source = "art/sprites/player4.png")]
		public static const PLAYER:Class;
		
		[Embed(source = "art/platform.png")]
		public static const PLATFORM:Class;
		
		[Embed(source = "art/kongtext.regular.ttf", fontFamily = "Kongtext", embedAsCFF="false")] 	
		public static const	kongtext:String;
		
		public function Assets() 
		{
			
		}
		
	}

}