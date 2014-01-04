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
Networked sprites *
Networked sound *
Networked particle system *
Networking flow control for optimal packet delivery *

All in all I tried to give the server the power
to change nearly every aspect of the game without 
additional code necessary on the client's side, 
so that any mods are natively supported. In fact, the
official menus and gamemodes are being written as 
plugins and mods as well.

TODO
0)-Seamless map rotation/changing
1)-Custom networked objects protocol *(1)
2)-Add flow control to Streamy *(2)
3)-I forgot about audio. Must think about audio. *(3)
4)-Networked particle emitters? Why not?

TOFIX
-Better knock back
-Rewrite custom HUDs classes to use MarkupText

*(1)This will be heavy-duty. Really. In short, it will
allow the remote creation+handling of FlxSprites on
a target client while keeping bandwidth usage to a minimum.
Similar concept to Source engine entities, I guess,
but I don't know how these work under the hood.

*(2)As of now, there is no flow control and that's very bad.
I'll implement a basic ACK system for UDP to monitor not only
RTT, but also lost packets to better manage the
reliable and unreliable queues.

*(3)Pretty much the same as the networked FlxSprite
protocol but for FlxSound, I guess.