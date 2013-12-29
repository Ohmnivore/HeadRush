package plugin 
{
	import com.bit101.components.*;
	import com.bit101.utils.MinimalConfigurator;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.flixel.FlxG;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class PublicBrowser extends BasePlugin
	{
		public var servarr:Array = [];
		public var d:Array = [];
		public var found:Boolean = false;
		
		public function PublicBrowser() 
		{
			pname = "Public browser";
			version = 0;
			runtimesafe = false;
		}
		
		override public function CreateUI():void
		{
			super.CreateUI();
			
			helptext = ( [

"This plugin allows you to browse public servers registered at headrushms.appspot.com",
"If you suspect there's a problem displaying servers just visit the above-mentioned website.",
"Note that this tool will not work for LAN servers because another technique is needed for LAN server discovery.",

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
			
			refresh();
			
			savecomps = [];
			savecompsdefault = [];
			
			//LoadFromSave();
		}
		
		override public function DeleteUI():void
		{
			super.DeleteUI();
			FlxG.stage.removeChild(config.getCompById("GWind"));
		}
		
		public function join(e:MouseEvent):void
		{
			if (found)
			{
				var l:List = config.getCompById("list") as List;
				
				var index:int = l.selectedIndex;
				
				Registry.servaddr = d[index][6];
				
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
			var myTextLoader:URLLoader = new URLLoader();
			
			myTextLoader.addEventListener(Event.COMPLETE, onReceive);
			
			myTextLoader.load(new URLRequest(Registry.ms));
		}
		
		public function onReceive(e:Event):void
		{
			if (e.target.data.length > 0)
			{
				found = true;
				FlxG.log(e.target.data);
				d = JSON.parse(e.target.data) as Array;
				var l:List = config.getCompById("list") as List;
				
				var items:Array = [];
				
				for each (var serv in d)
				{
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
					
					items.push(s);
				}
				
				l.items = items;
				l.selectedIndex = 0;
			}
			
			else
			{
				found = false;
				config.getCompById("list")["items"] = ["There are no public servers at the moment."];
			}
		}
		
		public function onClose(event:Event):void
        {
            DeleteUI();
        }
	}
}