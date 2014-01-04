package  
{
	import com.bit101.charts.LineChart;
	import com.bit101.components.List;
	import com.bit101.components.PushButton;
	import com.bit101.components.Window;
	import org.flixel.*;
	import flash.utils.getDefinitionByName;
	import flash.ui.Mouse;
	import flash.events.Event;
	import plugin.BasePlugin;
	import com.jmx2.delayedFunctionCall;
	
	public class SetupState extends FlxState
	{	
		public var selected:int = 0;
		public var list:List;
		public var window:Window;
		public static var currentgui:BasePlugin = undefined;
		
		override public function create():void 
		{
			super.create();
			
			//Load saved stuff
			ServerInfo.save = new FlxSave();
			ServerInfo.save.bind("ServerSettings");
			if (ServerInfo.save.data["json"] != null)
			{
				ServerInfo.tosave = JSON.parse(ServerInfo.save.data["json"]);
			}
			else
			{
				ServerInfo.tosave = new Object();
			}
			
			add(new FlxSprite(0, 0, Assets.SETUPBACK));
			
			Mouse.show();
			
			window = new Window(FlxG.stage, 0, 0, "Settings");
			window.height = FlxG.height * 2;
			window.width = FlxG.width / 2;
			window.draggable = false;
			
			new PushButton(window, 0, 0, "Launch server", go);
			
			var items:Array = ServerInfo.plugins.slice(0, ServerInfo.plugins.length);
			
			items.unshift("Plugins settings");
			
			list= new List(window, 0, 20, items);
			list.height = FlxG.height * 2 - 40;
			list.listItemHeight = 30;
			list.selectedIndex = 0;
			
			for each (var plugin in ServerInfo.plugins)
			{
				var pl:Class = getDefinitionByName("plugin.".concat(plugin)) as Class;
				
				var plinstance:BasePlugin = new pl() as BasePlugin;
				
				ServerInfo.pl.push(plinstance);
				
				plinstance.CreateUI();
				plinstance.DeleteUI();
			}
		}
		
		override public function update():void
		{
			super.update();
			
			if (selected != list.selectedIndex && list.selectedIndex == 0)
			{
				if (currentgui != undefined) currentgui.DeleteUI();
				selected = list.selectedIndex;
			}
			
			if (selected != list.selectedIndex && list.selectedIndex != 0)
			{
				if (currentgui != undefined) currentgui.DeleteUI();
				ServerInfo.pl[list.selectedIndex-1].CreateUI();
				selected = list.selectedIndex;
			}
			
			if (Registry.setupdone)
			{
				//if (currentgui != undefined) currentgui.DeleteUI();
				//FlxG.stage.removeChild(window);
				//ServerInfo.save.close();
				go("placeholder");
			}
		}
		private function go(placeholder:*):void
		{
			if (currentgui != undefined) currentgui.DeleteUI();
			FlxG.stage.removeChild(window);
			ServerInfo.save.close();
			Mouse.hide();
			
			Registry.ms = new MasterServer(ServerInfo.ms);
			Registry.ms.announce();
			new delayedFunctionCall(Registry.ms.announce, 2000);
			
			Registry.server = new RushServer();
			
			Registry.cli.setCommand("map", "changemap");
			
			FlxG.switchState(new PlayState);
		}
	}
}