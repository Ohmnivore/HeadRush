package  
{
	import org.flixel.FlxParticle;
	import org.flixel.FlxPoint;

	public class Head extends FlxParticle
	{
		//[Embed(source = "../assets/coin16x16.png")] private var coin16x16PNG:Class;

		public function Head()
		{
			super();

			//loadGraphic(coin16x16PNG, true, false, 16, 16);
			makeGraphic(8, 8, 0xff000000);

			//addAnimation("spin", [1, 2, 3, 4, 5, 6], 12, true);

			exists = false;
		}

		override public function onEmit():void
		{
			//elasticity = 0.8;
			elasticity = Math.random();
			drag = new FlxPoint(4, 0);

			//play("spin");
		}
	}
}