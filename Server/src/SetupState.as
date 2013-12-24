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
	
	public class SetupState extends FlxState
	{	
		public var selected:int = -10;
		public var list:List;
		public var window:Window;
		
		override public function create():void 
		{
			super.create();
			
			//Load saved stuff
			ServerInfo.save = new FlxSave();
			ServerInfo.save.bind("ServerSettings");
			if (ServerInfo.save.data["json"] != null)
			{
				ServerInfo.tosave = JSON.parse(ServerInfo.save.data["json"]);
				trace("IF");
			}
			else
			{
				trace("ELSE");
				ServerInfo.tosave = new Object();
			}
			
			add(new FlxSprite(0, 0, Assets.SETUPBACK));
			
			Mouse.show();
			
			window = new Window(FlxG.stage, 0, 0, "Settings");
			window.height = FlxG.height * 2;
			window.width = FlxG.width / 2;
			window.draggable = false;
			
			new PushButton(window, 0, 0, "Launch server", go);
			
			list= new List(window, 0, 20, ServerInfo.plugins);
			list.height = FlxG.height * 2 - 40;
			list.listItemHeight = 30;
			list.selectedIndex = 0;
			
			for each (var plugin in ServerInfo.plugins)
			{
				var pl:Class = getDefinitionByName("plugin.".concat(plugin)) as Class;
				
				var plinstance = new pl();
				
				ServerInfo.pl.push(plinstance);
			}
		}
		
		override public function update():void
		{
			super.update();
			
			if (selected != list.selectedIndex)
			{
				if (selected >= 0) ServerInfo.pl[list.selectedIndex].DeleteUI();
				ServerInfo.pl[list.selectedIndex].CreateUI();
				selected = list.selectedIndex;
			}
			
			if (Registry.setupdone)
			{
				FlxG.stage.removeChild(window);
				ServerInfo.save.close();
				go("placeholder");
			}
		}
		private function go(placeholder:*):void
		{
			FlxG.stage.removeChild(window);
			ServerInfo.save.close();
			FlxG.switchState(new PlayState);
		}
	}
}