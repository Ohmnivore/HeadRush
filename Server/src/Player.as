package  
{
	import entity.Spawn;
	import gevent.DeathEvent;
	import gevent.HurtInfo;
	import mx.core.FlexSprite;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import Streamy.ServerPeer;
	
	public class Player extends FlxSprite
	{
		protected static const RUN_SPEED:int = 145;
		protected static const GRAVITY:int =420;
		protected static const JUMP_SPEED:int = 420;
		public var peer:ServerPeer;
		//public var ID:int;
		public var healthBar:FlxBar;
		public var cannon:FlxWeapon;
		public var gun:FlxSprite;
		public var gun2:FlxSprite;
		public var name:String;
		public var team:uint;
		public var teamcolor:uint;
		public var state:PlayState;
		public var dead:Boolean = false;
		public var respawntimer:FlxDelay;
		public var shootimer:FlxDelay;
		
		public var wallshade:FlxSprite;
		public var wallshade2:FlxSprite;
		public var wallright:Boolean = false;
		public var walleft:Boolean = false;
		
		public var kills:uint;
		public var deaths:uint;
		public var heads:uint;
		
		public var hurtinfo:HurtInfo;
		
		public var a:Number = 1;
		public var right:Boolean = true;
		
		public var wallslide:Boolean = true;
		public var firstslide:Boolean = true;
		public var ceilingwalk:Boolean = true;
		
		public var header:MarkupText = new MarkupText(0, 0, 500, "Unnamed_player", true, true);
		
		public var scrwidth:uint = FlxG.width;
		public var scrheight:uint = FlxG.height;

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
			
			drag.x = 80;  // Drag is how quickly you slow down when you're not pushing a button. By using a multiplier, it will always scale to the run speed, even if we change it.
            acceleration.y = GRAVITY; // Always try to push helmutguy in the direction of gravity
            maxVelocity.x = RUN_SPEED;
            maxVelocity.y = JUMP_SPEED;
			
			cannon = new FlxWeapon("blaster", this, "x", "y");
			cannon.player = this;
			cannon.makePixelBullet(5, 6, 6, 0xff000000);
			cannon.setBulletSpeed(160);
			cannon.setFireRate(2000);
			cannon.setBulletOffset(10, 10);
			var b:FlxRect = Registry.playstate.map.getBounds();
			b.x -= FlxG.width;
			b.y -= FlxG.height;
			b.width += 2 * FlxG.width;
			b.height += 2 * FlxG.height;
			cannon.setBulletBounds(b);
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
			healthBar.trackParent(-6, -7);
			healthBar.createFilledBar(0xFFFF0000, 0xFF09FF00, true, 0xff000000);
			state.charoverlay.add(healthBar);
			
			name = "Ohmnivore";
			team = 0;
			teamcolor = 0xff00A8C2;
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
			
			wallshade = new FlxSprite(x - 2, y + 2);
			wallshade.width = width/2;
			wallshade.height = height -4;
			//wallshade.visible = false;
			
			wallshade2 = new FlxSprite(x + width + 2, y + 2);
			wallshade2.width = width/2;
			wallshade2.height = height -4;
			//wallshade2.visible = false;
			//wallshade.immovable = true;
			//Registry.playstate.add(wallshade);
			
			//Registry.playstate.add(wallshade);
			
			state.charoverlay.add(header);
			header.color = teamcolor;
			header.text = name;
		}

		public override function draw():void
		{
			header.y = y - header.height - 4;
			header.x = x - (header.width - width) / 2;
			super.draw();
		}

		public override function update():void
		{	
			super.update();
			
			//header.y = y - header.height - 4;
			//header.x = x - (header.width - width) / 2;
			
			wallshade.update();
			wallshade2.update();
			
			//FlxG.collide(Registry.playstate.map, wallshade);
			//FlxG.collide(Registry.playstate.platforms, wallshade);
			
			wallshade.x = x - 2;
			wallshade.y = y + 2;
			wallshade2.x = x + width / 2 + 2;
			wallshade2.y = y + 2;
			
			wallslide = false;
			//trace(wallshade.isTouching(FlxObject.RIGHT));
			//if (wallshade.isTouching(FlxObject.RIGHT) || wallshade.isTouching(FlxObject.LEFT)) trace("slide");
			//if (FlxG.collide(Registry.playstate.platforms, wallshade)) trace("lol");
			if (Registry.playstate.map.overlaps(wallshade)) 
			{
				wallslide = true;
				walleft = true;
				wallright = false;
			}
			
			if (Registry.playstate.map.overlaps(wallshade2)) 
			{
				wallslide = true;
				wallright = true;
				walleft = false;
			}
			//trace(Registry.playstate.map.overlaps(wallshade));
			
			if (wallslide)
			{
				acceleration.y = 100;
				if (firstslide) 
				{
					firstslide = false;
					if (velocity.y < 0)
						velocity.y = 0;
				}
			}
			
			else 
			{
				if (ceilingwalk == false)
					acceleration.y = 420;
				wallslide = false;
				firstslide = true;
			}
			
			if (ceilingwalk)
			{
				if (!(touching & UP)) 
				{
					acceleration.y = 420;
					ceilingwalk = false;
				}
			}
			
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
			
			if (health <= 0)
			{
				//Registry.gm.dispatchEvent(new DeathEvent(DeathEvent.DEATH_EVENT, hurtinfo));
				//respawn(Registry.spawntimer);
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
				
				respawntimer.duration = timer;
				respawntimer.start();
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
			super.destroy();
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
			wallshade.kill();
			wallshade.destroy();
			wallshade2.kill();
			wallshade2.destroy();
		}
	}
}
