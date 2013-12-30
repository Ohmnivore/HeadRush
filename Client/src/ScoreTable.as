package
{
	import flash.events.MouseEvent;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxText;
	
	public class ScoreTable
	{
		public var header:MarkupText = new MarkupText(0, 0, 500, "Scores", true, true, [new Markup(0, 6, 10, FlxG.RED)]);
		public var titles:Array = [];   //Array of MarkupTexts
		public var content:Array = [];  //Array of arrays for each title, with each element being a string
										//representing a row in that title's column
		public var parenty:int = 0;
		public var starty:int = 0;
		public var jsonstr:String = "";
		
		public var height:int = 0;
		
		public function exportTable():String
		{
			var h:Array = [header.text, header.ExportMarkups()];
			
			var t:Array = [];
			
			for each (var mark:MarkupText in titles)
			{
				t.push([mark.text, mark.ExportMarkups()]);
			}
			
			return JSON.stringify([h, t, content]);
		}
		
		public function importTable(json:String):void
		{
			if (json.length > 0)
			{
				jsonstr = json;
				
				var s:Array = JSON.parse(json) as Array;
				
				starty = 0;
				
				header = new MarkupText(0, starty+parenty, 500, s[0][0], true, true, []);
				Registry.noScroll(header);
				header.ImportMarkups(s[0][1]);
				Registry.playstate.scores.add(header);
				starty += header.height;
				
				var starts:Array = [];
				var x:uint = 0;
				var start:int = 0;
				var biggestheight:int = 0;
				
				titles = [];
				
				for each (var t:Array in s[1])
				{
					var title:MarkupText = new MarkupText(start, starty + parenty, 500, t[0], true, []);
					Registry.noScroll(title);
					title.ImportMarkups(t[1]);
					Registry.playstate.scores.add(title);
					if (title.height > biggestheight) biggestheight = title.height;
					starts[x] = start;
					x++;
					start += title.width;
					titles.push(title);
				}
				
				starty += biggestheight;
				
				var xx:uint = 0;
				var biggestyy:uint = 0;
				
				content = [];
				
				for each (var col:Array in s[2])
				{
					var startyy:int = starty;
					var data:Array = [];
					
					for (var y:uint = 0; y < col.length; y++)
					{
						var row:FlxText = new FlxText(starts[xx], startyy + parenty, 12 * col[y].length, col[y]);
						Registry.noScroll(row);
						Registry.playstate.scores.add(row);
						startyy += row.height;
						if (startyy > biggestyy) biggestyy = startyy;
						data.push(row.text);
					}
					
					content.push(data);
					
					xx++;
				}
				
				height = startyy;
			}
		}
	}
}