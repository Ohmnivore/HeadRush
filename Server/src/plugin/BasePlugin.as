package plugin 
{
	import com.bit101.components.*;
	import com.bit101.utils.MinimalConfigurator;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.flixel.FlxG;
	import gevent.HurtEvent;
	import gevent.DeathEvent;
	import gevent.JoinEvent;
	import gevent.LeaveEvent;
	import Streamy.MsgHandler;
	import plugin.BasePlugin;
	
	public class BasePlugin extends Sprite
	{
		public var pname:String;
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
			super();
			//name = "Setup2";
			//version = 0;
		}
		
		//Here be GUI functions. Much scary.
		
		public function LoadFromSave():void
		{
			//if (ServerInfo.tosave[pname])
			if (pname in ServerInfo.tosave)
			{
				var save = ServerInfo.tosave[pname];
				
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
					
					if (comp is CheckBox || comp is RadioButton) comp.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
					else comp.dispatchEvent(new Event(Event.CHANGE));
				}
			}
		}
		
		public function setCompValue(value:*, comp:Component):void
		{
			if (comp is InputText)
			{
				comp["text"] = value;
			}
			
			if (comp is TextArea)
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
			
			if (comp is RadioButton)
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
			
			if (comp is TextArea)
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
			
			if (comp is RadioButton)
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
			
			ServerInfo.tosave[pname] = data;
		}
		
		public function CreateUI():void
		{
			SetupState.currentgui = this;
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
			SetupState.currentgui = undefined;
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
			helpwindow.height = help.height+20;
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
		
		//Here be templates for hooking onto Registry.gm events
		public function init():void
		{
			
		}
		
		public function update(elapsed:Number):void
		{
			
		}
		
		public function shutdown():void
		{
			
		}
		
		public function onHurt(e:HurtEvent):void
		{
			
		}
		
		public function onDeath(e:DeathEvent):void
		{
			
		}
		
		public function onJoin(e:JoinEvent):void
		{
			
		}
		
		public function onLeave(e:LeaveEvent):void
		{
			
		}
		
		public function onMsg(e:MsgHandler):void
		{
			
		}
	}
}