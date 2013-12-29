package plugin 
{
	import com.bit101.components.*;
	import com.bit101.utils.MinimalConfigurator;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.InterfaceAddress;
	import flash.net.DatagramSocket;
	import flash.events.DatagramSocketDataEvent;
	import flash.utils.ByteArray;
	import org.flixel.FlxG;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	
	public class LANBrowser extends BasePlugin
	{
		public var servarr:Array = [];
		public var found:Boolean = false;
		
		public var d:Array = [];
		
		public var net:Vector.<NetworkInterface>;
		public var broad:String = "127.0.0.1";
		
		public var udpsocket:DatagramSocket;
		
		public var tries:uint = 0;
		
		public function LANBrowser() 
		{
			pname = "LAN browser";
			version = 0;
			runtimesafe = false;
		}
		
		override public function CreateUI():void
		{
			super.CreateUI();
			
			helptext = ( [

"This plugin allows you to browse servers on your LAN.",
"It uses the address set in the 'Address' menu to find the broadcast address.",

] ).join("\n");
		
			initx = FlxG.width / 2 + 10;
			
			var xml:XML = <comps>
							<Window id="GWind" x={initx} y="0" title={pname} event="close:onClose" hasCloseButton="true" height={FlxG.height*2} width={FlxG.width*3/2 - 20}>
							<PushButton id="helpbutton" label="Help" x={FlxG.width*3/2 - 200} y="0" event="click:createHelper"/>
								<VBox x="0" y="0">
									<PushButton id="refrbtn" label="Refresh list" x="10" y="0" event="click:refreshbtn"/>
									<PushButton id="joinbtn" label="Join" x="10" y="20" event="click:join"/>
									<Label id="helplabel" x="10" y="40" text="Select a server and click 'Join'."/>
									<Label id="helplabel2" x="10" y="60" text="Name | Map | Gamemode | Current players/Max | Requires password?"/>
									<List id="list" x="10" y="80"/>
								</VBox>
							</Window>
                          </comps>;
			
			config.parseXML(xml);
			
			var l:List = config.getCompById("list") as List;
			l.height = FlxG.height * 2 - 120;
			l.width = FlxG.width * 3 / 2 - 40;
			
			savecomps = [];
			savecompsdefault = [];
			
			net = NetworkInfo.networkInfo.findInterfaces();
			
			for each (var inter:NetworkInterface in net)
			{
				for each (var addr:InterfaceAddress in inter.addresses)
				{
					if (addr.address == Registry.address) broad = addr.broadcast;
				}
			}
			
			trace(broad);
			
			udpsocket = new DatagramSocket();
			udpsocket.bind(5620, Registry.address);
			udpsocket.addEventListener(DatagramSocketDataEvent.DATA, onLAN);
			//udpsocket.connect(broad, 5614);
			udpsocket.receive();
			
			refresh();
		}
		
		override public function DeleteUI():void
		{
			super.DeleteUI();
			FlxG.stage.removeChild(config.getCompById("GWind"));
			
			udpsocket.close();
		}
		
		public function join(e:MouseEvent):void
		{
			if (found)
			{
				var l:List = config.getCompById("list") as List;
				
				var index:int = l.selectedIndex;
				
				Registry.servaddr = d[index][6];
				FlxG.log(Registry.servaddr);
				
				//DeleteUI();
				
				Registry.setupdone = true;
			}
		}
		
		public function refreshbtn(e:MouseEvent):void
		{
			refresh();
		}
		
		public function refresh():void
		{
			try
			{
				var placeholder:ByteArray = new ByteArray();
				placeholder.writeBoolean(true);
				
				udpsocket.send(placeholder, 0, 0, broad, 5614);
			}
			
			catch (e:Error) 
			{
				trace(e);
				
				while (tries < 10)
				{
					//refresh();
					tries++;
				}
			}
		}
		
		public function onLAN(event:DatagramSocketDataEvent):void
		{			
			var buffer:ByteArray = event.data;
			
			FlxG.log(buffer.toString());
			var serv:Array = JSON.parse(buffer.readUTF()) as Array;
			
			var l:List = config.getCompById("list") as List;
			
			var s:String = "";
			
			s += serv[0];
			s += " | ";
			s += serv[1];
			s += " | ";
			s += serv[2];
			s += " | ";
			s += serv[3];
			s += "/";
			s += serv[4];
			s += " | ";
			s += serv[5];
			
			FlxG.log(s);
			
			l.items.push(s);
			d.push(serv);
			
			if (!found)	
			{
				found = true;
				config.getCompById("list")["selectedIndex"] = 0;
			}
		}
		
		public function onClose(event:Event):void
        {
            DeleteUI();
        }
	}
}