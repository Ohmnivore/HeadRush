package  
{
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	
	public class ChatBox extends TextField
	{
		public var opened:Boolean = false;
		
		public function ChatBox()
		{
			super();
			type = TextFieldType.INPUT;
			FlxG.stage.addChild(this);
			multiline = false;
			background = true;
			backgroundColor = 0x4B4B4B;
			alpha = 0.85;
			border = false;
			x = 0;
			width = FlxG.width * 2;
			height = 23;
			y = FlxG.height * 2 - 23;
			sharpness = 100;
			embedFonts = true;
			//maxChars = 52;
			
			defaultTextFormat = new TextFormat("system", 16, 0xffffff);
			setTextFormat(new TextFormat("system", 16, 0xffffff));
			
			Registry.chatrect.visible = false;
		}
		
		public function toggle():void
		{
			var c:ChatHist = Registry.playstate.chathist;
			c.toggle();
			if (c.opened)
				c.alignTop();
			else
			    c.alignBot();
			
			if (opened)
			{
				close();
			}
			
			else
			{
				open();
			}
		}
		
		public function close():void
		{
			FlxG.keys.handling = true;
			visible = false;
			opened = false;
			
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			removeEventListener(TextEvent.TEXT_INPUT, onTextInput);
			
			Registry.chatrect.visible = false;
		}
		
		public function open():void
		{
			Registry.chatrect.visible = true;
			y = (FlxG.height - Registry.playstate.chathist.toty) * 2 - height;
			//var x:Rectangle = new Rectangle(0, 0, FlxG.width * 2, 10);
			//x.height = Registry.playstate.chathist.toty * 2;
			//x.y = (FlxG.height - Registry.playstate.chathist.toty) * 2;
			
			if (Registry.playstate.chathist.toty > 0)
			{
				var rect:FlxSprite = Registry.chatrect;
				rect.height = Registry.playstate.chathist.toty;
				rect.width = FlxG.width;
				rect.makeGraphic(FlxG.width, Registry.playstate.chathist.toty, 0xC8000000);
				rect.y = FlxG.height - Registry.playstate.chathist.toty;
				rect.scrollFactor.x = rect.scrollFactor.y = 0;
				rect.update();
			}
			
			else
			{
				Registry.chatrect.visible = false;
			}
			
			FlxG.stage.focus = this;
			FlxG.keys.handling = false;
			visible = true;
			opened = true;
			text = "";
			
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			addEventListener(TextEvent.TEXT_INPUT, onTextInput);
		}
		
		private function onTextInput(e:TextEvent):void
		{
			if (e.text == "`" || text == "`")
				text = text.slice(0, -1);
		}
		
		public function keyDown(e:KeyboardEvent):void
		{
			//F1
			if (textWidth >= FlxG.width * 2 - 20) text = text.slice(0, -1);
			//if (e.keyCode == 84) toggle();
			// Enter
			if (e.keyCode == 13 && text != "")
			{
				//Send message
				Registry.playstate.chathist.add(
				new String("Server: ").concat(text),
				[
				[10, FlxG.RED, 0, 6]
				]
				)
				text = "";
			}
			if (e.keyCode == 13) toggle();
			
			// Backspace
			if (e.keyCode == 8)
			{
				
			}
		}
	}

}