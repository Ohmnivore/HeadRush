package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import org.flixel.FlxG;
	
	/**
	 * Command Line Interface
	 * @author Ian Reichert-Watts
	 * www.shadowhelm.com
	 */
public class CLI extends Sprite
{
	private var _parent:Object;
	private var _prompt:TextField = new TextField();
	private var _cmd:TextField = new TextField();
	private var _view:TextField = new TextField();
	private var _format:TextFormat = new TextFormat("sans", 12, 0xFFFFFF);
	
	private var _color:uint;
	private var _alpha:Number;
	private var _height:int;
	
	private var _commands:Dictionary = new Dictionary();
		
	public function CLI(parent:Object, color:uint = 0x000000, alpha:Number = .7, height:int = 64) {
		_parent = parent;
		_color = color;
		_alpha = alpha;
		_height = height;
		this.graphics.beginFill(color, _alpha);
		this.graphics.drawRect(0, 0, _parent.stage.stageWidth, _height);
		this.addChild(_prompt);
		_prompt.autoSize = "left";
		_prompt.y = _height - 20;
		_prompt.defaultTextFormat = _format;
		_prompt.text = ">";
		_prompt.selectable = false;
		this.addChild(_cmd);
		_cmd.height = 20;
		_cmd.width = _parent.stage.stageWidth;
		_cmd.y = _height - 20;
		_cmd.x = 10;
		_cmd.defaultTextFormat = _format;
		_cmd.type = "input";
		this.addChild(_view);
		_view.height = 20;
		_view.width = _parent.stage.stageWidth;
		_view.wordWrap = true;
		_view.autoSize = "left";
		_view.y = _height - _view.height - 20;
		_view.defaultTextFormat = _format;
		_view.selectable = false;
		_parent.addChild(this);
		this.visible = false;
		listen();
	}
	
	public function listen():void {
		_parent.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
	}
	
	public function silence():void {
		_parent.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	public function display():void {
		this.visible = true;
		_parent.stage.focus = _cmd;
		_cmd.setSelection(_cmd.text.length, _cmd.text.length);
		FlxG.keys.handling = false;
	}
	
	public function clear():void {
		if (_cmd.text.slice(_cmd.text.length - 1, _cmd.text.length) == "`") {
			_cmd.text = _cmd.text.slice(0, _cmd.text.length-1);
		}
		this.visible = false;
		FlxG.keys.handling = true;
	}
	
	public function toggle():void {
		if(!this.visible) display();
		else clear();
	}
	
	public function setCommand(command:String, functionName:String):void {
		_commands[command] = functionName;
	}
	
	public function appendText(text:String):void {
		_view.appendText("\n"+text);
		_view.y = _height - 20 - _view.height;
	}
	
	private function onKeyUp(e:KeyboardEvent):void {
		switch (e.keyCode) {
			case 27: 
				toggle();
				break;
			case 13:
				var func:Array = _cmd.text.split(" ");
				_view.appendText("\n~ "+_cmd.text);
				_view.y = _height - 20 - _view.height;
				_cmd.text = "";
				if (_commands[func[0]]) {
					var command:Function = _parent[_commands[func[0]]] as Function;
					switch (func.length) {
						case 1:
							command();
							break;
						case 2:
							command(func[1]);
							break;
						case 3:
							command(func[1],func[2]);
							break;
						case 4:
							command(func[1],func[2],func[3]);
							break;
						case 5:
							command(func[1],func[2],func[3],func[4]);
							break;
						case 6:
							command(func[1],func[2],func[3],func[4],func[5]);
							break;
						case 7:
							command(func[1],func[2],func[3],func[4],func[5],func[6]);
							break;
						case 8:
							command(func[1],func[2],func[3],func[4],func[5],func[6],func[7]);
							break;
						case 9:
							command(func[1],func[2],func[3],func[4],func[5],func[6],func[7],func[8]);
							break;
					}
						
				}
				break;
		}
	}
}
}