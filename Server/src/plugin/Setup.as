package plugin 
{
	import com.bit101.charts.*;
	import com.bit101.components.*;
	import flash.events.Event;
	import org.flixel.FlxG;
	
	public class Setup 
	{
		public var name:String;
		public var version:uint;
		
		//GUI variables
		public var initx:int;
		public var window:Window;
		public var helptext:String;
		public var helping:Boolean;
		public var helpwindow:Window;
		public var placeheight:uint;
		public var maxpp:VIntSlider;
		public var namep:InputText;
		public var passp:InputText;
		
		//GUI settables
		public var sname:String = "New Server";
		public var spass:String = "";
		public var smaxp:uint = 12;
		
		public function Setup() 
		{
			name = "Setup";
			version = 0;
			
			LoadFromSave();
		}
		
		public function LoadFromSave():void
		{
			if (ServerInfo.tosave[name])
			{
				var save = ServerInfo.tosave[name];
				sname = save["name"];
				spass = save["password"]; 
				smaxp = save["maxp"];
				
				ServerInfo.name = sname;
				ServerInfo.password = spass;
				ServerInfo.maxp = smaxp;
			}
			
			else
			{
				//FlxG.log(e);
				
				ServerInfo.name = sname;
				ServerInfo.password = spass;
				ServerInfo.maxp = smaxp;
			}
		}
		
		public function WriteToSave():void
		{
			var data:Object = new Object();
			data["name"] = ServerInfo.name;
			data["password"] = ServerInfo.password;
			data["maxp"] = ServerInfo.maxp;
			
			ServerInfo.tosave[name] = data;
			
			trace(data["maxp"]);
		}
		
		public function CreateUI():void
		{
			helptext = ( [

"This plugin allows to set usefull info for your server.",
"Leave the password field blank if you don't want one.",

] ).join("\n");

			initx = FlxG.width / 2 + 10;
			helping = false;
			placeheight = 0;
			
			window = new Window(FlxG.stage, initx, 0, name);
			window.hasCloseButton = true;
			window.draggable = false;
			window.height = FlxG.height * 2;
			window.width = FlxG.width * 2 - initx;
			
			window.addEventListener(Event.CLOSE, close);
			
			createHeader(0, placeheight, "Server name");
			namep = new InputText(window, 0, placeheight, sname, setName);
			addLH(namep);
			
			createHeader(0, placeheight, "Password");
			passp = new InputText(window, 0, placeheight, spass, setPass);
			addLH(passp);
			
			maxpp = new VIntSlider(window, 0, placeheight, "Max players", setMaxP);
			maxpp.setSliderParams(6, 32, smaxp);
			addLH(maxpp);
			
			var helpbutton = new PushButton(window, 0, placeheight, "Help", createHelper);
			addLH(helpbutton);
		}
		
		public function DeleteUI():void
		{
			window.dispatchEvent(new Event(Event.CLOSE));
		}
		
		public function addLH(component:*):void
		{
			placeheight += component.height;
		}
		
		public function createHelper(placeholder:*):void
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

		public function createHeader(x:int, y:int, text:String)
		{
			var t:Label = new Label(window, x, y, text);
			t.height = 20;
			t.width = t.textField.textWidth;
			
			addLH(t);
		}
		
		public function setName(data:String):void
		{
			ServerInfo.name = namep.text;
		}
		
		public function setPass(data:String):void
		{
			ServerInfo.password = passp.text;
		}
		
		public function setMaxP(data:int):void
		{
			ServerInfo.maxp = uint(maxpp.value);
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
		
		public function close(e:Event):void
		{
			Save();
			FlxG.stage.removeChild(window);
			
			if (helping) helpwindow.dispatchEvent(new Event(Event.CLOSE));
		}
	}
}