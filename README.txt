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

TODO
1)-Networked scoreboard *(4)
4)-Custom networked objects protocol *(2)
5)-Add flow control to Streamy *(5)
6)-I forgot about audio. Must think about audio.

TOFIX
-Better knock back

*(2)This will be heavy-duty. Really. In short, it will
allow the remote creation+handling of FlxSprites on
a target client while keeping bandwidth usage to a minimum.
Similar concept to Source engine entities, I guess,
but I don't know how these work under the hood.

*(4)I'm thinking of a protocol that will handle
creation of sets, consisting of tables for flexible
scoreboards (yes, I know, things are getting very
custom, but I like it that way. Modding will be more
flexible.)

*(5)As of now, there is no flow control and that's very bad.
I'll implement a basic ACK system for UDP to monitor not only
RTT, but also lost packets to better manage the
reliable and unreliable queues.