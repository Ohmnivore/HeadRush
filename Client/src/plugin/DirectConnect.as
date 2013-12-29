package plugin 
{
	import com.bit101.components.*;
	import com.bit101.utils.MinimalConfigurator;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.flixel.FlxG;
	
	public class DirectConnect extends BasePlugin
	{
		public function DirectConnect() 
		{
			pname = "Direct connect";
			version = 0;
			runtimesafe = false;
		}
		
		override public function CreateUI():void
		{
			super.CreateUI();
			
			helptext = ( [

"Enter the IP of the server you want to connect to.",
"The textbox at the bottom is simply a notepad so that you can save some IP addresses there if you ever want to.",

] ).join("\n");
		
			initx = FlxG.width / 2 + 10;
			
			var xml:XML = <comps>
							<Window id="GWind" x={initx} y="0" title={pname} event="close:onClose" hasCloseButton="true" height={FlxG.height*2} width={FlxG.width*3/2 - 20}>
								<VBox x="0" y="0">
									<Label id="addrlabel" x="10" y="0" text="IP address"/>
									<InputText id="addr" x="10" y="20" event="change:setAddr"/>
									<PushButton id="joinbtn" x="10" y="40" label="Join" event="click:join"/>
									<PushButton id="helpbutton" label="Help" x="10" y="60" event="click:createHelper"/>
									<TextArea id="notes" x="10" y="80"/>
								</VBox>
							</Window>
                          </comps>;
			
			config.parseXML(xml);
			
			var t:TextArea = config.getCompById("notes") as TextArea;
			t.height = FlxG.height;
			t.width = FlxG.width * 3 / 2 - 40;
			//t.textField.multiline = true;
			//t.textField.wordWrap = true;
			t.editable = true;
			
			savecomps = ["addr", "notes"];
			savecompsdefault = ["127.0.0.1", "Paste some IPs here to save them for later."];
			
			LoadFromSave();
		}
		
		override public function DeleteUI():void
		{
			super.DeleteUI();
			Save();
			FlxG.stage.removeChild(config.getCompById("GWind"));
		}
		
		public function setAddr(e:Event):void
		{
			Registry.servaddr = config.getCompById("addr")["text"];
		}
		
		public function join(e:MouseEvent):void
		{
			Registry.setupdone = true;
		}
		
		public function onClose(event:Event):void
        {
            DeleteUI();
        }
	}
}