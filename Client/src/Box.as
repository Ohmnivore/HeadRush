package  
{
	import org.flixel.FlxGroup;
    import org.flixel.FlxSprite;

	public class Box 
	{
		internal const SIDELENGTH:uint = 8;
		
		[Embed(source = "art/b_bot_l.png")]
		internal var _b_bot_l:Class;
		
		[Embed(source = "art/b_bot_r.png")]
		internal var _b_bot_r:Class;
		
		[Embed(source = "art/b_top_l.png")]
		internal var _b_top_l:Class;
		
		[Embed(source = "art/b_top_r.png")]
		internal var _b_top_r:Class;
		
		[Embed(source = "art/b_bot.png")]
		internal var _b_bot:Class;
		
		[Embed(source = "art/b_top.png")]
		internal var _b_top:Class;
		
		[Embed(source = "art/b_middle.png")]
		internal var _b_middle:Class;
		
		[Embed(source = "art/b_r.png")]
		internal var _b_r:Class;
		
		[Embed(source = "art/b_l.png")]
		internal var _b_l:Class;
		
		public var _box:FlxGroup = new FlxGroup();
		public var _sbox:FlxSprite;
		
		public function Box(width:int = 80, height:int = 32, X:Number = 0, Y:Number = 0, scroll:Number = 0) 
		{	
			var x:int = 0;
			var y:int = 0;
			_sbox = new FlxSprite(x, y);
			_sbox.width = width;
			_sbox.height = height;
			_sbox.makeGraphic(width,height,0x00000000);
			_sbox.scrollFactor.x = _sbox.scrollFactor.y = scroll;
			_box.add(new FlxSprite(x, y, _b_top_l));
			_box.add(new FlxSprite(width - SIDELENGTH, y, _b_top_r));
			_box.add(new FlxSprite(width - SIDELENGTH, height - SIDELENGTH, _b_bot_r));
			_box.add(new FlxSprite(x, height - SIDELENGTH, _b_bot_l));
			x = SIDELENGTH;
			for (x; x < width - SIDELENGTH; x+=SIDELENGTH)
			{
				_box.add(new FlxSprite(x,y,_b_top));
			}
			x = SIDELENGTH;
			y = height - SIDELENGTH;
			for (x; x < width - SIDELENGTH; x+=SIDELENGTH)
			{
				_box.add(new FlxSprite(x,y,_b_bot));
			}
			x = 0;
			y = SIDELENGTH;
			for (y; y < height - SIDELENGTH; y+=SIDELENGTH)
			{
				_box.add(new FlxSprite(x,y,_b_l));
			}
			x = width - SIDELENGTH;
			y = SIDELENGTH;
			for (y; y < height - SIDELENGTH; y+=SIDELENGTH)
			{
				_box.add(new FlxSprite(x,y,_b_r));
			}
			x = SIDELENGTH;
			for (x; x < width - SIDELENGTH; x += SIDELENGTH)
			{
				y = SIDELENGTH;
				for (y; y < height - SIDELENGTH; y += SIDELENGTH) 
				{
					_box.add(new FlxSprite(x, y, _b_middle));
					//_sbox.stamp(new FlxSprite(0, 0, _b_middle), x, y);
				}
			}
			
			for each (var member in _box.members)
			{
				member.scrollFactor.x = member.scrollFactor.y = scroll;
				//member.x += X;
				//member.y += Y;
				_sbox.stamp(member, member.x, member.y);
			}
			
			_sbox.x += X;
			_sbox.y += Y;
		}
	}
}