package  
{
	import org.flixel.*
	/**
	 * ...
	 * @author Grey
	 */
	public class FlxDigger extends FlxSprite
	{
		
		public var Diggers:FlxGroup;
		public var mat:Array;
		public var cols:int = 0;
		public var rows:int = 0;
		public var cntdig:int = 0;
		public var stuck:Number = 0;
		public var oldx:int = 0;
		public var oldy:int = 0;
		private var szX:int;
		private var szY:int;
		
		public function FlxDigger(matrix:Array,Digga:FlxGroup,MapWidth:int,MapHeight:int,X:int,Y:int,sizeX:int=16,sizeY:int=16) 
		{
			super();
			makeGraphic(sizeX, sizeY, 0xff000000);  //let's create our digger!: a simple x*y black square.
			
			Diggers = Digga;						//add our friend to a FlxGroup we create in DigState
			
			mat = matrix;							//passing matrix data
			
			cols = MapWidth/sizeX;					//calculate number of columns and rows
			rows = MapWidth / sizeY;
			
			x = X;									//initial position
			y = Y;
			
			szX = sizeX;							//storing digger's size
			szY = sizeY;
		}
		
		override public function update():void
		{
			super.update();
			if (stuck == 0)
			{
				oldx = x;
				oldy = y;
			}
			cntdig = Registry.totdiggers - Registry.ddig;  //lets count how many diggers are alive (used just to kill some of them in case of "overpopulation"
			
			stuck += FlxG.elapsed;							//stuck counter: used to see if for some reason this digger is stuck somewhere
			
			if (x-(szX*2) <= 0)								//check if he's too near the level's border (prevents the digger from going out of the map)
			    kill();
			if (x+(szX*2)>= cols * szX - szX)
			    kill();
			if (y-(szY*2) <= 0)
			    kill();
			if (y+(szY*2)>= rows * szY-szY)
			    kill();
			if (mat[y/szY][x/szX]==1)
				mat[y / szY][x / szX] = 0;
				
			chooseDir();									//call the function that's used to choose a semi-random (it's "semi" 'cause diggers can't dig empty spaces so we have to check what is surrounding our bro)
			
			var f:Number = Math.random();					//yes: diggers can duplicate theirself. this is done by comparing a random generated number with a fixed value (in this case 0.91).
			if (f > 0.91)									//if conditions are satisfied, this digger will duplicate.
			{
				var d:FlxDigger = new FlxDigger(mat, Diggers, 640, 480, x, y, szX, szY);
				Diggers.add(d);
				Registry.totdiggers++;						//duplication is notified by incrementing this counter stored in Registry.as
			}
			
			if (Registry.totdiggers >= 300)					//reached overpopulation level? DIE!
			    kill();
				
			if (stuck >= 1)									//stuck? DIE!
			{
				if (oldx == x || oldy == y)
				{
					Registry.ddig++;						//notifies his death by incrementing this counter
				    kill();
				}
				else
				    stuck = 0;								//not stuck? oh, well... you can continue your job...
			}
		}
		private function chooseDir():void					//i don't want to explain all of this... just know that after he choose one of the available directions, 
		{													//the digger moves szX or szY steps (szX= his x size; szY= his y size)
			var f:Number = 0;
			if (mat[y/szY][(x - szX)/szX] == 0)
			{
				if (mat[y/szY][(x + szX)/szX] == 0)
				{
					if (mat[(y - szY)/szY][x/szX] == 0)
					{
						if (mat[(y + szY) / szY][x / szX] == 0)
						{
							if(cntdig>1)
								kill();
						}
						else
						    y += szY;
					}
					else
					{
						if (mat[(y + szY)/szY][x/szX] == 0)
						    y -= szY;
						else
						{
							f = Math.floor(Math.random()*2)
							if (f == 0)
							   y -= szY;
							else
							   y += szY;
						}
					}
				}
				else
				{
					if (mat[(y - szY)/szY][x/szX] == 0)
					{
						if (mat[(y + szY)/szY][x/szX] == 0)
						    x += szX;
						else
						{
							f = Math.floor(Math.random()*2);
							if (f == 0)
							   x += szX;
							else
							   y += szY;
						}
					}
					else
					{
						if (mat[(y + szY)/szY][x/szX] == 0)
						{
							f = Math.floor(Math.random()*2);
							if (f == 0)
							   x += szX;
							else
							   y -= szY;
						}
						else
						{
							f = Math.floor(Math.random() * 3);
							if (f == 0)
							    x += szX;
							if (f == 1)
							    y -= szY;
							if (f == 2)
							    y += szY;
						}
					}
				}
			}
			else
			{
				if (mat[y / szY][(x + szX) / szX]==0)
				{
					if (mat[(y - szY) / szY][x / szX] == 0)
					{
						if (mat[(y + szY) / szY][x / szX] == 0)
						   x -= szX;
						else
						{
							f = Math.floor(Math.random() * 2);
							if (f == 0)
							    x -= szX;
						    else
							    y += szY;
						}
					}
					else
					{
						if (mat[(y + szY) / szY][x / szX] == 0)
						{
							f = Math.floor(Math.random() * 2);
							if (f == 0)
							    x += szX;
						    else
							    y -= szY;
						}
						else
						{
							f = Math.floor(Math.random() * 3);
							if (f == 0)
							    x -= szX;
							if (f == 1)
							    y -= szY;
							if (f == 2)
							    y += szY;
						}
					}
				}
				else
				{
					if (mat[(y - szY) / szY][x / szX] == 0)
					{
						if (mat[(y + szY) / szY][x / szX] == 0)
						{
							f = Math.floor(Math.random() * 2);
							if (f == 0)
							    x -= szX;
						    else
							    x += szX;
						}
						else
						{
							f = Math.floor(Math.random() * 3);
							if (f == 0)
							    x -= szX;
							if (f == 1)
							    x += szX;
							if (f == 2)
							    y += szY;
						}
					}
					else
					{
						f = Math.floor(Math.random() * 4);
							if (f == 0)
							    x += szX;
							if (f == 1)
							    y -= szY;
							if (f == 2)
							    x -= szX;
							if (f == 3)
							    y += szY;
					}
				}
			}
		}
		override public function kill():void  //well.... you know what this does
		{
				if(!alive) return;
			    velocity.x = 0;
			    velocity.y = 0;
			    alive = false;
			    exists = false;	
				cntdig--;
		}
	}

}