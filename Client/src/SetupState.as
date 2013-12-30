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
			Registry.save = new FlxSave();
			Registry.save.bind("ClientSettings");
			if (Registry.save.data["json"] != null)
			{
				Registry.tosave = JSON.parse(Registry.save.data["json"]);
			}
			else
			{
				Registry.tosave = new Object();
			}
			
			add(new FlxSprite(0, 0, Assets.SETUPBACK));
			
			Mouse.show();
			
			window = new Window(FlxG.stage, 0, 0, "Menu");
			window.height = FlxG.height * 2;
			window.width = FlxG.width / 2;
			window.draggable = false;
			
			var items:Array = Registry.plugins.slice(0, Registry.plugins.length);
			
			items.unshift("Available menus:");
			
			list= new List(window, 0, 0, items);
			list.height = FlxG.height * 2 - 40;
			list.listItemHeight = 30;
			list.selectedIndex = 0;
			
			for each (var plugin in Registry.plugins)
			{
				var pl:Class = getDefinitionByName("plugin.".concat(plugin)) as Class;
				
				var plinstance:BasePlugin = new pl() as BasePlugin;
				
				Registry.pl.push(plinstance);
				
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
				Registry.pl[list.selectedIndex-1].CreateUI();
				selected = list.selectedIndex;
			}
			
			if (Registry.setupdone)
			{
				//if (currentgui != undefined) currentgui.DeleteUI();
				//FlxG.stage.removeChild(window);
				//Registry.save.close();
				go("placeholder");
			}
		}
		private function go(placeholder:*):void
		{
			if (currentgui != undefined) currentgui.DeleteUI();
			FlxG.stage.removeChild(window);
			Registry.save.close();
			Mouse.hide();
			FlxG.switchState(new PlayState);
		}
	}
}