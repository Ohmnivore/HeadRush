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
		[Embed(source = "art/gun2.png")]
		public static const GUN2:Class;
		
		[Embed(source = "art/sprites/player4.png")]
		public static const PLAYER:Class;
		[Embed(source = "art/sprites/playergreen.png")]
		public static const PLAYER_GREEN:Class;
		[Embed(source = "art/sprites/playeryellow.png")]
		public static const PLAYER_YELLOW:Class;
		[Embed(source = "art/sprites/playerred.png")]
		public static const PLAYER_RED:Class;
		
		[Embed(source = "art/platform.png")]
		public static const PLATFORM:Class;
		
		[Embed(source = "art/kongtext.regular.ttf", fontFamily = "Kongtext", embedAsCFF="false")] 	
		public static const	kongtext:String;
		
		[Embed(source = "art/setupback.png")]
		public static const SETUPBACK:Class;
		
		[Embed(source = "art/flag.png")]
		public static const FLAG:Class;
		
		public static const LVLS = JSON.parse(String(new embedded_text()));
		
		public function Assets() 
		{
			
		}
		
	}

}