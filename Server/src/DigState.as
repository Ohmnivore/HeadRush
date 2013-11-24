package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author Grey
	 */
	public class DigState extends FlxState
	{
		[Embed(source = "media/wt.png")]public var wT:Class;
		[Embed(source = "media/cursor.png")] private var ImgCursor:Class;

		public var diggroup:FlxGroup;
		public var splscrn:FlxSprite;
		public var matrix:Array;
		public var month:Number = 0;
		public var mindiggrs:int = 300;
		
		override public function create():void 
		{
			super.create();
			diggroup = new FlxGroup();   																//creates a group for our lil' diggers
			
			Registry.mapray = new Array();																//initialize map's array
			Registry.mapray = genInitMatrix(640 / 8, 480 / 8);
			
			Registry.totdiggers = 1;																	//var initialization
			Registry.ddig = 0;
			
			splscrn = new FlxSprite(0, 0, wT);															//let's put a pic over our workers: they don't like to be seen while they're digging...
			
			var d:FlxDigger = new FlxDigger(Registry.mapray, diggroup, 640, 480, 5 * 16, 7 * 16, 8, 8); //create just one digger and put it somewhere in the map
			
			diggroup.add(d);																			//adding stuff
			add(diggroup);
			add(splscrn);
			
			FlxG.mouse.show(ImgCursor);
		}
		
		override public function update():void
		{
			super.update();	
			if (Registry.totdiggers >= mindiggrs)														//the total number of diggers alive is greater than this value? cool, let's switch to our PlayState
			{
			    FlxG.fade(0xff000000, 1, go);
			}
			if (Registry.totdiggers < mindiggrs-50 && diggroup.countLiving() == 0)						//if diggers have died before reaching our goal of 300, we'll repeat all of this procedure
			    FlxG.switchState(new DigState);
		}
		private function go():void
		{
			FlxG.switchState(new PlayState);
		}
		
		public function genInitMatrix( rows:uint, cols:uint ,negative:Boolean=false):Array
		{
			// Build array of 1s
			var mat:Array = new Array();
			for ( var y:uint = 0; y < rows; ++y )
			{
				mat.push( new Array );
				for ( var x:uint = 0; x < cols; ++x ) 
				{
					if (!negative)
					    mat[y].push(1);
					else
					    mat[y].push(0);
				}
			}
			
			return mat;
		}
	}
}