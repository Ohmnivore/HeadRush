package  
{
	import org.flixel.FlxG;
	import org.flixel.FlxText;
	import ScoreTable;
	import flash.events.MouseEvent;
	
	public class ScoreSet 
	{
		private var tables:Array = [];
		public var open:Boolean = false;
		public var jsonstr:String = "";
		public var scrolloffset:int = 0;
		public var justopened:Boolean = true;
		
		public function ScoreSet()
		{
			Registry.playstate.scores.visible = false;
		}
		
		public function exportSet():String
		{
			var json:String = "[";
			
			for (var x:uint = 0; x < tables.length - 1; x++)
			{
				json += tables[x].exportTable() + ", ";
			}
			
			if (tables.length > 0)
			{
				json += tables[tables.length - 1].exportTable();
			}
			
			json += "]";
			
			return json;
		}
		
		public function importSet(json:String):void
		{
			if (tables.length > 0)
			{
				if (tables[0].header != null)
				{
					scrolloffset = tables[0].header.y;
				}
			}
			
			justopened = false;
			
			jsonstr = json;
			
			tables = [];
			
			clear();
			
			var parenty:int = 0 + scrolloffset;
			
			var s:Array = JSON.parse(json) as Array;
			
			for each (var t:Array in s)
			{
				var scoret:ScoreTable = new ScoreTable;
				scoret.parenty = parenty;
				scoret.importTable(JSON.stringify(t));
				parenty += scoret.height + 10;
				
				tables.push(scoret);
			}
		}
		
		public function clear():void
		{
			Registry.playstate.scores.clear();
		}
		
		public function toggle():void
		{
			if (open) 
			{
				open = false;
				clear();
				Registry.playstate.scores.visible = false;
				FlxG.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseScroll);
			}
			
			else 
			{
				justopened = true;
				open = true;
				if (jsonstr.length > 0) importSet(jsonstr);
				scrolloffset = 0;
				Registry.playstate.scores.visible = true;
				FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseScroll);
			}
		}
		
		public function onMouseScroll(e:MouseEvent):void
		{
			if (e.delta < 0)
			{
				for each (var m:FlxText in Registry.playstate.scores.members)
				{
					m.y += 20;
					//scrolloffset += 20;
				}
			}
			
			if (e.delta > 0)
			{
				for each (var m:FlxText in Registry.playstate.scores.members)
				{
					m.y -= 20;
					//scrolloffset -= 20;
				}
			}
			//trace(scrolloffset);
		}
	}
}