package plugin 
{
	import com.bit101.components.*;
	import com.bit101.utils.MinimalConfigurator;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import org.flixel.FlxG;
	import flash.net.NetworkInterface;
	import flash.net.NetworkInfo;
	import flash.net.InterfaceAddress;
	
	public class MapRotation extends BasePlugin
	{
		public var slist:List;
		public var alist:List;
		public var link:Dictionary = new Dictionary();
		
		public function MapRotation() 
		{
			pname = "MapRotation";
			version = 0;
			runtimesafe = true;
		}
		
		override public function CreateUI():void
		{
			super.CreateUI();
			
			helptext = ( [

"This plugin allows you to select which maps should be played in a loop.",
"It's runtime-safe.",

] ).join("\n");
		
			initx = FlxG.width / 2 + 10;
			
			var xml:XML = <comps>
							<Window id="GWind" x={initx} y="0" title={pname} event="close:onClose" hasCloseButton="true" height={FlxG.height*2} width={FlxG.width*3/2 - 20}>
								<VBox x="0" y="0">
									<Label id="addrlabel" x="10" y="0" text="Available maps"/>
									<List id="alist" x="10" y="20" height="60"/>
									<PushButton id="addbtn" label="Add" x="10" y="80" event="click:add"/>
									<Label id="addrlabel" x="10" y="100" text="Current map rotation"/>
									<List id="slist" x="10" y="120" height="60"/>
									<PushButton id="rmbutton" label="Remove" x="10" y="180" event="click:remove"/>
									<PushButton id="helpbutton" label="Help" x="10" y="200" event="click:createHelper"/>
								</VBox>
							</Window>
                          </comps>;
			
			config.parseXML(xml);
			
			for (var lvl in Assets.LVLS)
			{
				var n:String;
				n += Assets.LVLS[lvl][0]["gamemode"];
				n += "_";
				n = Assets.LVLS[lvl][0]["name"];
				
				alist.items.push(n);
				link[n] = lvl;
			}
			
			savecomps = ["slist"];
			savecompsdefault = [["TestMap"]];
			
			LoadFromSave();
		}
		
		override public function DeleteUI():void
		{
			super.DeleteUI();
			Save();
			for each (var item in slist.items)
			{
				Registry.maprotation.push(link[item]);
			}
			FlxG.stage.removeChild(config.getCompById("GWind"));
		}
		
		public function add(e:MouseEvent):void
		{
			slist.items.push(alist.selectedItem);
		}
		
		public function remove(e:MouseEvent):void
		{
			
		}
		
		public function onClose(event:Event):void
        {
            DeleteUI();
        }
	}
}