package plugin 
{
	import com.bit101.components.*;
	import com.bit101.utils.MinimalConfigurator;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.flixel.FlxG;
	import flash.net.NetworkInterface;
	import flash.net.NetworkInfo;
	import flash.net.InterfaceAddress;
	
	public class Address extends BasePlugin
	{
		public var showing:Boolean = false;
		public var showwindow:Window;
		
		public var net:Vector.<NetworkInterface>;
		//public var broadcasts:Array = [];
		
		public function Address() 
		{
			pname = "Address";
			version = 0;
			runtimesafe = false;
		}
		
		override public function CreateUI():void
		{
			super.CreateUI();
			
			helptext = ( [

"This plugin allows you to select which network interface to bind to.",
"As a general rule select your LAN to join a LAN server, and select your outgoing address to join servers outside of your LAN (a no-brainer).",

] ).join("\n");
		
			initx = FlxG.width / 2 + 10;
			
			var xml:XML = <comps>
							<Window id="GWind" x={initx} y="0" title={pname} event="close:onClose" hasCloseButton="true" height={FlxG.height*2} width={FlxG.width*3/2 - 20}>
								<VBox x="0" y="0">
									<Label id="addrlabel" x="10" y="0" text="IP address"/>
									<InputText id="addr" x="10" y="20" event="change:setAddr"/>
									<Label id="btnlabel" x="10" y="40" text="View available"/>
									<PushButton id="intbtn" label="Check interfaces" x="10" y="60" event="click:showInterfaces"/>
									<PushButton id="helpbutton" label="Help" x="10" y="80" event="click:createHelper"/>
								</VBox>
							</Window>
                          </comps>;
			
			config.parseXML(xml);
			
			savecomps = ["addr"];
			savecompsdefault = ["0.0.0.0"];
			
			LoadFromSave();
		}
		
		override public function DeleteUI():void
		{
			super.DeleteUI();
			Save();
			if (showing) showwindow.dispatchEvent(new Event(Event.CLOSE));
			FlxG.stage.removeChild(config.getCompById("GWind"));
		}
		
		public function setAddr(e:Event):void
		{
			Registry.address = config.getCompById("addr")["text"];
		}
		
		public function showInterfaces(e:MouseEvent):void
		{
			showing = true;
			
			showwindow = new Window(FlxG.stage, 0, 0, "Network interfaces");
			showwindow.hasCloseButton = true;
			showwindow.addEventListener(Event.CLOSE, showclose);
			
			var help:TextArea = new TextArea(showwindow, 0, 0, "Here's all the available addresses:");
			
			help.text += '\n';
			
			help.text += '\n';
			help.text += "0.0.0.0 will listen on all available interfaces. It's preferable to use that address.";
			help.text += '\n';
			
			net = NetworkInfo.networkInfo.findInterfaces();
			
			for each (var inter:NetworkInterface in net)
			{
				help.text += '\n';
				help.text += inter.displayName;
				for each (var intaddr:InterfaceAddress in inter.addresses) 
				{
					help.text += '\n';
					help.text += '->';
					help.text += intaddr.address;
				}
				help.text += '\n';
			}
			
			help.editable = false;
			//help.
			showwindow.width = help.width;
			showwindow.height = help.height+20;
		}
		
		public function showclose(e:Event):void
		{
			showing = false;
			FlxG.stage.removeChild(showwindow);
		}
		
		public function onClose(event:Event):void
        {
            DeleteUI();
        }
	}
}