package  
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	public class Player extends FlxSprite
	{
		protected static const RUN_SPEED:int = 130;
		protected static const GRAVITY:int =420;
		protected static const JUMP_SPEED:int = 250;
		public var healthBar:FlxBar;
		public var cannon:FlxWeapon;
		public var gun:FlxSprite;
		public var gun2:FlxSprite;
		public var name:String;
		public var team:uint;
		public var state:PlayState;
		public var dead:Boolean = false;
		public var respawntimer:FlxDelay;
		public var shootimer:FlxDelay;
		public var coinEmitter:FlxEmitter = new FlxEmitter();
		
		public var kills:uint;
		public var deaths:uint;
		public var heads:uint;
		
		public var a:Number = 1;
		public var right:Boolean = true;

		public function Player(_x:int, _y:int):void 
		{		
			super(_x, _y);
			
			state = Registry.playstate;
			
			loadGraphic(Assets.PLAYER, true, true, 24, 24);
			//addAnimation("walking", [1, 2, 0], 4, true);
			addAnimation("walking", [0, 1, 2, 3, 4, 5], 12, true);
			addAnimation("i_walking", [5, 4, 3, 2, 1, 0], 12, true);
            addAnimation("idle", [0]);
			
			addAnimation("rwalking", [6, 7, 8, 9, 10, 11], 12, true);
			addAnimation("ri_walking", [11, 10, 9, 8, 7, 6], 12, true);
            addAnimation("ridle", [6]);
			
			addAnimation("ledgeidle", [12]);
			
			drag.x = RUN_SPEED * 8;  // Drag is how quickly you slow down when you're not pushing a button. By using a multiplier, it will always scale to the run speed, even if we change it.
            acceleration.y = GRAVITY; // Always try to push helmutguy in the direction of gravity
            maxVelocity.x = RUN_SPEED;
            maxVelocity.y = JUMP_SPEED;
			
			cannon = new FlxWeapon("blaster", this, "x", "y");
			cannon.makePixelBullet(5, 6, 6, 0xff000000);
			cannon.setBulletSpeed(160);
			cannon.setFireRate(2000);
			cannon.setBulletOffset(10, 10);
			state.bullets.add(cannon.group);
			
			gun = new FlxSprite(0, 0, Assets.GUN);
			//gun.loadGraphic(Assets.GUN, false, true, 24, 12);
			gun.loadRotatedGraphic(Assets.GUN, 180, -1, false, false);
			state.charoverlay.add(gun);
			
			gun2 = new FlxSprite(0, 0, Assets.GUN2);
			//gun.loadGraphic(Assets.GUN, false, true, 24, 12);
			gun2.loadRotatedGraphic(Assets.GUN2, 180, -1, false, false);
			state.charoverlay.add(gun2);
			
			health = 100;
			healthBar = new FlxBar(8, 26, FlxBar.FILL_LEFT_TO_RIGHT, 38, 6, this, "health", 0, 100, true);
			healthBar.trackParent(-6, -10);
			healthBar.createFilledBar(0xFFFF0000, 0xFF09FF00, true, 0xff000000);
			state.charoverlay.add(healthBar);
			
			name = "Ohmnivore";
			team = 0;
			heads = 4;
			
			var found = false;
			
			while (!found)
			{
				var spawn:Spawn = Registry.getRandomElementOf(Registry.playstate.spawns);
				if (spawn.team == team)
				{
					found = true;
					x = spawn.x;
					y = spawn.y;
				}
			}
			
			respawntimer = new FlxDelay(Registry.spawntimer);
			respawntimer.callback = respawn;
			
			shootimer = new FlxDelay(2000);
			shootimer.start();
			
			Registry.playstate.heademitters.add(coinEmitter);
		}

		public override function update():void
		{
			super.update();
			
			FlxG.collide(coinEmitter, Registry.playstate.map);
			
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
			
			if (facing == RIGHT && velocity.x > 0) { play("walking"); }
			if (facing == LEFT && velocity.x < 0) { play("walking"); }
			if (facing == RIGHT && velocity.x < 0) { play("i_walking"); }
			if (facing == LEFT && velocity.x > 0) {play("i_walking");}
			else if (!velocity.x) { play("idle"); }
			
			if (health <= 0)
			{
				respawn(Registry.spawntimer);
			}
		}
		
		public function respawn(timer:uint = 1000):void
		{
			if (!dead)
			{
				deaths++;
				visible = false;
				gun.visible = false;
				gun2.visible = false;
				healthBar.visible = false;
				solid = false;
				dead = true;
				health = 100;
				
				respawntimer.duration = timer;
				respawntimer.start();
				ExplodeHeads();
			}
			
			else
			{
				visible = true;
				gun.visible = true;
				gun2.visible = true;
				healthBar.visible = true;
				solid = true;
				dead = false;
				
				flicker(1);
				
				var found = false;
			
				while (!found)
				{
					var spawn:Spawn = Registry.getRandomElementOf(Registry.playstate.spawns);
					if (spawn.team == team)
					{
						found = true;
						x = spawn.x;
						y = spawn.y;
					}
				}
			}
		}
		
		public function ExplodeHeads():void
		{
			coinEmitter = new FlxEmitter(0, 0, 50);
			coinEmitter.x = x + width/2;
			coinEmitter.y = y + height / 2;
			coinEmitter.gravity = 350;
			coinEmitter.setRotation(0, 0);
			coinEmitter.setXSpeed( -16, 16);
			coinEmitter.setYSpeed( -20, -30);
			
			var i:int = 0
			for (i; i < heads/2; i++)
			{
				coinEmitter.add(new Head);
				//trace("emit");
			}
			
			if (i == 0) coinEmitter.add(new Head);
			
			heads -= i;
			
			coinEmitter.start(true, 10, 0, 0);
		}
		
		public function shoot():void
		{
			//if (true)
			//{
				//if (right) cannon.fireAtPosition(x+10, y+10 * a);
				//else cannon.fireAtPosition(x-10, y+10 * a);
			//}
			if (right) cannon.fireFromAngle(Math.atan(a) * 180 / Math.PI);
			else cannon.fireFromAngle((Math.atan(a) * 180 / Math.PI) - 180);
		}
		
		override public function destroy():void
		{
			gun.kill();
			gun.destroy();
			healthBar.kill();
			healthBar.destroy();
			cannon.group.kill();
			cannon.group.destroy();
			super.destroy();
		}
	}
}