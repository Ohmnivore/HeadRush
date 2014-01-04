package plugin 
{
	import com.bit101.components.*;
	import com.bit101.utils.MinimalConfigurator;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.flixel.FlxG;
	
	public class Setup extends BasePlugin
	{
		public function Setup() 
		{
			pname = "Setup";
			version = 0;
			runtimesafe = true;
		}
		
		override public function CreateUI():void
		{
			super.CreateUI();
			
			helptext = ( [

"This plugin allows to set usefull info for your server.",
"Leave the password field blank if you don't want one.",
"Server name is runtime-unsafe.",

] ).join("\n");
		
			initx = FlxG.width / 2 + 10;
			
			var xml:XML = <comps>
							<Window id="GWind" x={initx} y="0" title={pname} event="close:onClose" hasCloseButton="true" height={FlxG.height*2} width={FlxG.width*3/2 - 20}>
								<VBox x="0" y="0">
									<Label id="namelabel" x="10" y="0" text="Name"/>
									<InputText id="sname" x="10" y="20" event="change:setName"/>
									<Label id="passlabel" x="10" y="40" text="Password"/>
									<InputText id="pass" x="10" y="60" event="change:setPass"/>
									<VIntSlider id="maxp" x="10" y="80" label="Max players" event="change:setMaxP" minimum="6" maximum="32" value={12}/>
									<CheckBox id="pubbox" label="Public" x="10" y="120" event="click:setPub"/>
									<PushButton id="helpbutton" label="Help" x="10" y="140" event="click:createHelper"/>
								</VBox>
							</Window>
                          </comps>;
			
			config.parseXML(xml);
			
			runtimeunsafe = ["sname"];
			applyRuntimes(runtimeunsafe);
			
			savecomps = ["sname", "pass", "maxp", "pubbox"];
			savecompsdefault = ["New_Server", "", 12, true];
			
			LoadFromSave();
		}
		
		override public function DeleteUI():void
		{
			super.DeleteUI();
			Save();
			if (helping) helpwindow.dispatchEvent(new Event(Event.CLOSE));
			FlxG.stage.removeChild(config.getCompById("GWind"));
		}
		
		public function setPub(e:Event):void
		{
			ServerInfo._pub = config.getCompById("pubbox")["selected"];
		}
		
		public function setName(e:Event):void
		{
			ServerInfo.name = config.getCompById("sname")["text"];
		}
		
		public function setPass(e:Event):void
		{
			ServerInfo.password = config.getCompById("pass")["text"];
		}
		
		public function setMaxP(e:Event):void
		{
			ServerInfo.maxp = uint(config.getCompById("maxp")["value"]);
		}
		
		public function onClose(event:Event):void
        {
            DeleteUI();
        }
	}
}