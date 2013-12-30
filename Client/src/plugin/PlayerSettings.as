package plugin 
{
	import com.bit101.components.*;
	import com.bit101.utils.MinimalConfigurator;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.flixel.FlxG;
	
	public class PlayerSettings extends BasePlugin
	{
		public function PlayerSettings() 
		{
			pname = "Player settings";
			version = 0;
			runtimesafe = false;
		}
		
		override public function CreateUI():void
		{
			super.CreateUI();
			
			helptext = ( [

"Allows to set some parameters for the player.",

] ).join("\n");
		
			initx = FlxG.width / 2 + 10;
			var x:RadioButton = new RadioButton();
			var xml:XML = <comps>
							<Window id="GWind" x={initx} y="0" title={pname} event="close:onClose" hasCloseButton="true" height={FlxG.height*2} width={FlxG.width*3/2 - 20}>
								<VBox x="0" y="0">
									<Label id="namelabel" x="10" y="0" text="Player name"/>
									<InputText id="name" x="10" y="20" event="change:setName"/>
									<Label id="colorlabel" x="10" y="40" text="Choose your prefered color:"/>
									<RadioButton id="greenbtn" x="10" y="60" label="Green" event="change:color" groupName="CLR"/>
									<RadioButton id="bluebtn" x="10" y="80" label="Blue" event="change:color" groupName="CLR"/>
									<RadioButton id="yellowbtn" x="10" y="100" label="Yellow" event="change:color" groupName="CLR"/>
									<RadioButton id="redbtn" x="10" y="120" label="Red" event="change:color" groupName="CLR"/>
									<PushButton id="helpbutton" label="Help" x="10" y="140" event="change:createHelper"/>
								</VBox>
							</Window>
                          </comps>;
			
			config.parseXML(xml);
			
			savecomps = ["name", "greenbtn", "bluebtn", "yellowbtn", "redbtn"];
			savecompsdefault = ["Unnamed_player", false, true, false, false];
			
			LoadFromSave();
		}
		
		override public function DeleteUI():void
		{
			super.DeleteUI();
			Save();
			FlxG.stage.removeChild(config.getCompById("GWind"));
		}
		
		public function setName(e:Event):void
		{
			Registry.name = config.getCompById("name")["text"];
		}
		
		public function color(e:Event):void
		{
			if (e.target.selected) Registry.color = e.target.label;
			trace(e.target.selected);
			//case 
			//trace(e.target.y);
		}
		
		public function onClose(event:Event):void
        {
            DeleteUI();
        }
	}
}