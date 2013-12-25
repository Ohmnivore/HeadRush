package gamemode 
{
	import gevent.DeathEvent;
	import gevent.HurtEvent;
	import gevent.HurtInfo;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import org.flixel.plugin.photonstorm.BaseTypes.Bullet;
	
	public class DefaultHooks 
	{
		public static var p:PlayState = Registry.playstate;
		
		public static function update():void 
		{			
			collideWorld();
			checkWorldBounds();
			checkLasers();
		}
		
		public static function collideWorld():void
		{
			FlxG.collide(p.players, p.materialmap);
			FlxG.collide(p.players, p.lavamap);
			FlxG.collide(p.players, p.map);
			FlxG.collide(p.bullets, p.map, explobullet);
			FlxG.collide(p.bullets, p.platforms, explobullet);
			FlxG.collide(p.bullets, p.players, explobullet);
			FlxG.collide(p.players, p.platforms);
			FlxG.collide(p.players, p.players, jumpkill);
		}
		
		public static function checkWorldBounds():void
		{
			for each (var player:Player in p.players.members)
			{
				if (player.y > p.map.height + p.map.y + 100 && !player.dead) 
				{
					var info:HurtInfo = new HurtInfo;
					info.attacker = BaseGamemode.FALL;
					info.victim = player.ID;
					info.dmg = 100;
					info.dmgsource = player.getMidpoint();
					info.type = BaseGamemode.ENVIRONMENT;
					
					Registry.gm.dispatchEvent(new HurtEvent(HurtEvent.HURT_EVENT, info));
				}
			}
		}
		
		public static function checkLasers():void
		{
			for each (var laser:Laser in p.lasers.members)
			{
				for each (var player:Player in p.players.members)
				{
					if (FlxCollision.pixelPerfectCheck(laser, player, 255))
					{
						var info:HurtInfo = new HurtInfo;
						info.attacker = BaseGamemode.LASER;
						info.victim = player.ID;
						info.dmg = 10;
						info.dmgsource = player.getMidpoint();
						info.type = BaseGamemode.ENVIRONMENT;
						
						Registry.gm.dispatchEvent(new HurtEvent(HurtEvent.HURT_EVENT, info));
					}
				}
			}
		}
		
		public static function respawn(player:Player):void
		{
			player.respawn(Registry.spawntimer);
		}
		
		public static function announceLava(player:Player):void
		{
			var announce:String = player.name.concat(" was scorched by lava.");
			PlayState.announcer.add(announce,
						[
						[11, player.teamcolor, 0, player.name.length],
						[11, Registry.ORANGE, announce.length-6, announce.length - 1]
						]
						);
		}
		
		public static function announceFall(player:Player):void
		{
			var announce:String = player.name.concat(" fell off the map.");
			PlayState.announcer.add(announce,
						[
						[11, player.teamcolor, 0, player.name.length],
						[11, Registry.ORANGE, announce.length-4, announce.length-1]
						]
						);
		}
		
		public static function announceLaser(player:Player):void
		{
			var announce:String = player.name.concat(" was burned by a laser!");
			PlayState.announcer.add(announce,
						[
						[11, player.teamcolor, 0, player.name.length],
						[11, Registry.ORANGE, announce.length-6, announce.length-1]
						]
						);
		}
		
		public static function explobullet(bullet:Bullet, placeholder):void
		{
			for each (var player:Player in p.players.members)
			{
				var ppos:FlxPoint = new FlxPoint(player.x + player.width / 2, player.y + player.height / 2);
				var bpos:FlxPoint = new FlxPoint(bullet.x + bullet.width / 2, bullet.y + bullet.height / 2);
				
				var dist:Vector2D = new Vector2D(ppos.x - bpos.x, ppos.y - bpos.y);
				var length:Number = dist.length;
				
				if (length <= 36)
				{
					//player.velocity.x += 36*sign(dist.x) - dist.x;
					player.velocity.y += 360 * sign(dist.y) - dist.y * 10;
					//player.velocity.x += dist.x * 15 - 0.4 * Math.pow(dist.x, 2);
					if (Math.abs(dist.x) > 5)
						player.velocity.x += 180 * sign(dist.x) - dist.x * 5;
				}
				
				VMath.normalize(dist);
				
				if (length <= 36)
				{
					var info:HurtInfo = new HurtInfo;
					info.attacker = bullet.weapon.player.ID;
					info.victim = player.ID;
					info.dmg = 90 - 2.5 * length;
					info.dmgsource = bullet.getMidpoint();
					info.type = BaseGamemode.BULLET;
					
					Registry.gm.dispatchEvent(new HurtEvent(HurtEvent.HURT_EVENT, info));
				}
				
				bullet.kill();
			}
		}
		
		public static function sign(num)
		{
			 return (num > 0) ? 1 : ((num < 0) ? -1 : 0);
		}
		
		public static function jumpkill(player:Player, player2:Player):void
		{
			var winner:Player;
			var loser:Player;
			
			if (player.touching & FlxObject.DOWN)
			{
				if (player.y <= player2.y + 1)
				{
					winner = player;
					loser = player2;
				}
			}
			
			if (player2.touching & FlxObject.DOWN)
			{
				if (player2.y <= player.y + 1)
				{
					winner = player2;
					loser = player;
				}
			}
			
			var info:HurtInfo = new HurtInfo;
			info.attacker = winner.ID;
			info.victim = loser.ID;
			info.dmg = 100;
			info.type = BaseGamemode.JUMPKILL;
			info.dmgsource = winner.getMidpoint();
			
			Registry.gm.dispatchEvent(new HurtEvent(HurtEvent.HURT_EVENT, info));
		}
		
		public static function handleDamage(info:HurtInfo):void
		{
			var p:Player = Registry.clients[info.victim];
			p.health -= info.dmg;
			
			if (p.health <= 0) Registry.gm.dispatchEvent(new DeathEvent(DeathEvent.DEATH_EVENT, info));
		}
	}

}