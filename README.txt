UPDATE

I have abandoned this project. I decided to move on to
Haxe and HaxeFlixel because I just hate Adobe AIR.
So here's the newer version: http://skullrush.elementfx.com/smf/


Sup. This is Head Rush. It's an online
multiplayer 2D platformer shooter.

Basically, it's a 2D port of Quake-like
gameplay built upon an open and moddable
engine, inspired by Source engine modding.

It's built using Streamy and Flixel.

Licensed under GPLv3.

By Ohmnivore at http://ohmnivore.elementfx.com/

A Google App Engine master server is active at
http://headrushms.appspot.com/

 _____________________________________________________________
|                                                             |
|Features - the ones marked with a * are still in development.|
|_____________________________________________________________|

Plugins (runtime+startup GUI support)
Custom game modes
Client-side custom file download from external server
Server-side control of client's HUD
Networked text markup for kill feed, chat, and HUD
Central master server
LAN server discovery
Auto-saved settings (client and server)
Custom entities supported for mapping
Reliable and unreliable networking channels
Networked sprites
Networked sound *
Networked particle system *
Networking flow control for optimal packet delivery (+packet aggregation and fragmentation)
Networking message priority (smart queue handling)

All in all I tried to give the server the power
to change nearly every aspect of the game without 
additional code necessary on the client's side, 
so that any mods are natively supported. In fact, the
official menus and gamemodes are being written as 
plugins and mods as well.

TODO
1)-I forgot about audio. Must think about audio. *(3)
2)-Networked particle emitters? Why not?

TOFIX
-Better knock back
-Rewrite custom HUDs classes to use MarkupText


*(1)Pretty much the same as the networked FlxSprite
protocol but for FlxSound, I guess. Also I plan to
use FkxFlod for background music (tracker music is
awesome and also takes up waaaay less space - a 
common issue in games.)
