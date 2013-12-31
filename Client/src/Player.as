package  
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	public class Player extends FlxSprite
	{
		protected static const RUN_SPEED:int = 145;
		protected static const GRAVITY:int =420;
		protected static const JUMP_SPEED:int = 420;
		
		public var state:PlayState;
		
		public var healthBar:FlxBar;
		public var cannon:FlxWeapon;
		public var gun:FlxSprite;
		public var gun2:FlxSprite;
		
		public var name:String;
		public var team:uint;
		public var teamcolor:uint;
		public var dead:Boolean = false;
		
		public var kills:uint;
		public var deaths:uint;
		
		public var a:Number = 1;
		public var right:Boolean = true;
		public var ceilingwalk:Boolean = false;
		
		public var header:MarkupText = new MarkupText(0, 0, 500, "Unnamed_player", true, true);

		public function Player(_x:int, _y:int):void
		{		
			super(_x, _y);
			
			state = Registry.playstate;
			
			loadGraphic(Assets.PLAYER, true, true, 24, 24);
			
			addAnimation("walking", [0, 1, 2, 3, 4, 5], 12, true);
			addAnimation("i_walking", [5, 4, 3, 2, 1, 0], 12, true);
            addAnimation("idle", [0]);
			
			addAnimation("rwalking", [6, 7, 8, 9, 10, 11], 12, true);
			addAnimation("ri_walking", [11, 10, 9, 8, 7, 6], 12, true);
            addAnimation("ridle", [6]);
			
			addAnimation("ledgeidle", [12]);
			
			drag.x = 80;  // Drag is how quickly you slow down when you're not pushing a button. By using a multiplier, it will always scale to the run speed, even if we change it.
            acceleration.y = GRAVITY; // Always try to push helmutguy in the direction of gravity
            maxVelocity.x = RUN_SPEED;
            maxVelocity.y = JUMP_SPEED;
			
			cannon = new FlxWeapon("blaster", this, "x", "y");
			cannon.makePixelBullet(5, 6, 6, 0xff000000);
			cannon.setBulletSpeed(160);
			cannon.setFireRate(2000);
			cannon.setBulletOffset(10, 10);
			//cannon.setBulletBounds(Registry.playstate.map.getBounds());
			state.bullets.add(cannon.group);
			
			gun = new FlxSprite(0, 0, Assets.GUN);
			gun.loadRotatedGraphic(Assets.GUN, 180, -1, false, false);
			state.charoverlay.add(gun);
			
			gun2 = new FlxSprite(0, 0, Assets.GUN2);
			gun2.loadRotatedGraphic(Assets.GUN2, 180, -1, false, false);
			state.charoverlay.add(gun2);
			
			health = 100;
			healthBar = new FlxBar(8, 26, FlxBar.FILL_LEFT_TO_RIGHT, 38, 6, this, "health", 0, 100, true);
			healthBar.trackParent(-6, -7);
			healthBar.createFilledBar(0xFFFF0000, 0xFF09FF00, true, 0xff000000);
			state.charoverlay.add(healthBar);
			
			name = "Ohmnivore";
			team = 0;
			teamcolor = 0xff00A8C2;
			
			state.charoverlay.add(header);
			header.color = teamcolor;
			header.text = name;
		}

		public override function update():void
		{
			super.update();
			
			header.y = y - header.height - 4;
			header.x = x - (header.width - width) / 2;
			
			gun.x = x;
			gun.y = y + 2;
			
			gun2.x = x;
			gun2.y = y + 2;
			
			if (!dead)
			{
				if (right) 
				{
					gun2.visible = false;
					gun.visible = true;
					gun.angle = Math.atan(a) * 180 / Math.PI;
					gun.facing = RIGHT;
					facing = RIGHT;
				}
				else
				{
					gun.visible = false;
					gun2.visible = true;
					gun2.angle = (Math.atan(a) * 180 / Math.PI) - 180;
					gun2.facing = LEFT;
					facing = LEFT;
				}
			}
			//FlxG.log(velocity.x);
			if (!ceilingwalk)
			{
				if (facing == RIGHT && velocity.x > 0) { play("walking"); }
				if (facing == LEFT && velocity.x < 0) { play("walking"); }
				if (facing == RIGHT && velocity.x < 0) { play("i_walking"); }
				if (facing == LEFT && velocity.x > 0) {play("i_walking");}
				else if (!velocity.x) { play("idle"); }
			}
			
			else
			{
				if (facing == RIGHT && velocity.x > 0) { play("rwalking"); }
				if (facing == LEFT && velocity.x < 0) { play("rwalking"); }
				if (facing == RIGHT && velocity.x < 0) { play("ri_walking"); }
				if (facing == LEFT && velocity.x > 0) {play("ri_walking");}
				else if (!velocity.x) { play("ridle"); }
			}
		}
		
		public function setTextColor(col:uint):void
		{
			header.color = col;
			teamcolor = col;
		}
		
		public function respawn(timer:uint = 1000):void
		{
			if (!dead)
			{
				deaths++;
				visible = false;
				header.visible = false;
				gun.visible = false;
				gun2.visible = false;
				healthBar.visible = false;
				solid = false;
				dead = true;
				health = 100;
			}
			
			else
			{
				health = 100;
				visible = true;
				header.visible = true;
				gun.visible = true;
				gun2.visible = true;
				healthBar.visible = true;
				solid = true;
				dead = false;
				
				flicker(1);
				gun.flicker(1);
				gun2.flicker(1);
			}
		}
		
		public function shoot():void
		{
			if (right) cannon.fireFromAngle(Math.atan(a) * 180 / Math.PI);
			else cannon.fireFromAngle((Math.atan(a) * 180 / Math.PI) - 180);
		}
		
		override public function destroy():void
		{
			gun.kill();
			gun.destroy();
			gun2.kill();
			gun2.destroy();
			healthBar.kill();
			healthBar.destroy();
			cannon.group.kill();
			cannon.group.destroy();
			header.kill();
			header.destroy();
			super.destroy();
		}
	}
}
