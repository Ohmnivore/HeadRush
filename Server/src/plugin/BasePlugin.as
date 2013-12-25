package plugin 
{
	import com.bit101.components.*;
	import com.bit101.utils.MinimalConfigurator;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.flixel.FlxG;
	
	public class BasePlugin
	{
		public var name:String;
		public var version:uint;
		public var runtimesafe:Boolean;
		
		//GUI variables
		public var config:MinimalConfigurator;
		public var initx:int;
		public var helptext:String;
		public var helpwindow:Window;
		public var helping:Boolean;
		
		public var runtimeunsafe:Array;
		
		public var savecomps:Array;
		public var savecompsdefault:Array;
		
		public function BasePlugin() 
		{
			//name = "Setup2";
			//version = 0;
		}
		
		public function LoadFromSave():void
		{
			if (ServerInfo.tosave[name])
			{
				var save = ServerInfo.tosave[name];
				
				for (var data:String in save)
				{
					var comp:Component = config.getCompById(data) as Component;
					
					setCompValue(save[data], comp);
					
					comp.dispatchEvent(new Event(Event.CHANGE));
				}
			}
			
			else
			{
				for (var x:int; x < savecomps.length; x++)
				{
					var comp:Component = config.getCompById(savecomps[x]);
					setCompValue(savecompsdefault[x], comp);
					
					comp.dispatchEvent(new Event(Event.CHANGE));
				}
			}
		}
		
		public function setCompValue(value:*, comp:Component):void
		{
			if (comp is InputText)
			{
				comp["text"] = value;
			}
			
			if (comp is VIntSlider || comp is Slider)
			{
				comp["value"] = value;
			}
			
			if (comp is CheckBox)
			{
				comp["selected"] = value;
			}
		}
		
		public function getCompValue(comp:Component):*
		{
			if (comp is InputText)
			{
				return comp["text"];
			}
			
			if (comp is VIntSlider || comp is Slider)
			{
				return comp["value"];
			}
			
			if (comp is CheckBox)
			{
				return comp["selected"];
			}
		}
		
		public function WriteToSave():void
		{
			var data:Object = new Object();
			
			for each (var comp:String in savecomps)
			{
				data[comp] = getCompValue(config.getCompById(comp));
			}
			
			ServerInfo.tosave[name] = data;
		}
		
		public function CreateUI():void
		{
			initx = FlxG.width / 2 + 10;
			helptext = "";
			runtimeunsafe = [];
			savecomps = [];
			savecompsdefault = [];
			
			Component.initStage(FlxG.stage);
			config = new MinimalConfigurator(FlxG.stage, this);
		}
		
		public function DeleteUI():void
		{
			//config.getCompById("GWind").dispatchEvent(new Event(Event.CLOSE));
		}
		
		public function applyRuntimes(components:Array):void
		{
			if (String(FlxG.state) == String(PlayState))
			{
				for each (var comp:String in components)
				{
					config.getCompById(comp)["enabled"] = false;
				}
			}
		}
		
		public function createHelper(e:MouseEvent):void
		{
			helping = true;
			
			helpwindow = new Window(FlxG.stage, 0, 0, "Help");
			helpwindow.hasCloseButton = true;
			helpwindow.addEventListener(Event.CLOSE, helpclose);
			
			var help:TextArea = new TextArea(helpwindow, 0, 0, helptext);
			help.editable = false;
			
			helpwindow.width = help.width;
			helpwindow.height = help.height;
		}
		
		public function Save():void
		{
			WriteToSave();
			ServerInfo.save.data["json"] = JSON.stringify(ServerInfo.tosave);
			ServerInfo.save.flush();
		}
		
		public function helpclose(e:Event):void
		{
			helping = false;
			FlxG.stage.removeChild(helpwindow);
		}
	}
}