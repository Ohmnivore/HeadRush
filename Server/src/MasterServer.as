package  
{
	import flash.errors.IOError;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import org.flixel.FlxG;
	
	public class MasterServer 
	{
		public var addr:String;
		public var request:URLRequest;
		public var loader:URLLoader = new URLLoader();
		public var variables:URLVariables = new URLVariables();
		public var justsent:String = "";
		
		public var timer:Number = 0;
		public const HEARTBEATINTERVAL:Number = 90;
		
		public function MasterServer(Address:String) 
		{
			request = new URLRequest(Address);
			request.method = URLRequestMethod.POST;
			addr = Address;
			
			variables.cmd = "";
			variables.info = "";
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(Event.COMPLETE, on_complete);
			//To send:
			//request.data = variables;
			//loader.load(request);
		}
		
		public function announce():void
		{
			variables.cmd = "+";
			justsent = "+";
			if (ServerInfo.password.length > 0)
			{
				variables.info = JSON.stringify([
				ServerInfo.name, ServerInfo.map, ServerInfo.gamemode, ServerInfo.currentp, ServerInfo.maxp, true
				]);
			}
			
			else
			{
				variables.info = JSON.stringify([
				ServerInfo.name, ServerInfo.map, ServerInfo.gamemode, ServerInfo.currentp, ServerInfo.maxp, false
				]);
			}
			
			//serverx.name, serverx.mapname, serverx.gamemode, serverx.cp, serverx.mp, serverx.passworded, serverx.address
			
			request.data = variables;
			loader.load(request);
		}
		
		public function shutdown():void
		{
			variables.cmd = "-";
			justsent = "-";
			variables.info = "";
			
			request.data = variables;
			loader.load(request);
		}
		
		public function setplayers():void
		{
			variables.cmd = "p";
			justsent = "p";
			variables.info = JSON.stringify([ServerInfo.currentp, ServerInfo.maxp]);
			
			request.data = variables;
			loader.load(request);
		}
		
		public function setmap():void
		{
			variables.cmd = "m";
			justsent = "m";
			variables.info = JSON.stringify(ServerInfo.map);
			
			request.data = variables;
			loader.load(request);
		}
		
		public function setmode():void
		{
			variables.cmd = "g";
			justsent = "g";
			variables.info = JSON.stringify(ServerInfo.gamemode);
			
			request.data = variables;
			loader.load(request);
		}
		
		public function heartbeat():void
		{
			variables.cmd = "h";
			justsent = "h";
			variables.info = "";
			
			request.data = variables;
			loader.load(request);
		}
		
		public function update(Seconds:Number):void
		{
			timer += Seconds;
			if (timer >= HEARTBEATINTERVAL)
			{
				heartbeat();
				timer = 0;
			}
		}
		
		private function errorHandler(e : IOErrorEvent):void
		{  
		   FlxG.log("[MS]IOError: ".concat(e.text));
		   trace(e.target);
		 }
		
		private function on_complete(e : Event):void
		{
			switch (justsent)
			{
				case "+":
					FlxG.log("[MS]Sent announce.");
					break;
				case "-":
					FlxG.log("[MS]Sent shutdown.");
					break;
				case "p":
					FlxG.log("[MS]Sent player stats.");
					break;
				case "m":
					FlxG.log("[MS]Sent map name.");
					break;
				case "g":
					FlxG.log("[MS]Sent gamemode name.");
					break;
				case "h":
					FlxG.log("[MS]Sent heartbeat.");
					break;
			}
			   
		}
	}

}