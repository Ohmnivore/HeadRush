package 
{
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	
	/**
	 * Extends FlxText to allow marking up the text
	 * (changing size and/or color of parts of the text)
	 * Seems to also support multi-line/word-wrap. 
	 * If text is a one-liner, set Autowidth to true.
	 * Else, set Autowidth to FALSE!!!
	 * 
	 * @author	Ohmnivore
	 */
	public class MarkupText extends FlxText
	{
		public var autowidth:Boolean;
		public var markups:Array;
		
		/**
		 * Creates a new <code>MarkupText</code> object at the specified position.
		 * 
		 * @param	X				The X position of the text.
		 * @param	Y				The Y position of the text.
		 * @param	Width			The width of the text object (height is determined automatically).
		 * @param	Text			The actual text you would like to display initially.
		 * @param	EmbeddedFont	Whether this text field uses embedded fonts or nto
		 * @param 	Autowidth		Wether this text field has its width set automatically (FOR ONE-LINERS ONLY)
		 * @param	Markups			Array of markup objects, or an empty array if you wish.
		 */
		public function MarkupText(X:Number, Y:Number, Width:uint, Text:String=null, EmbeddedFont:Boolean=true, Autowidth:Boolean = false, Markups:Array = null)
		{
			super(X, Y, Width, Text, EmbeddedFont);
			
			autowidth = Autowidth;
			
			if (autowidth)
			{
				_textField.multiline = false;
				_textField.wordWrap = false;
			}
			
			_regen = true;
			calcFrame();
			
			markups = [];
			
			if (Markups != null)
			{
				for each (var mark in Markups)
				{
					Markitup(mark);
				}
			}
		}
		
		public function Markitup(mark:Markup):void
		{
			markups.push(mark);
			_textField.setTextFormat(new TextFormat("system", mark.size, mark.color), 
									mark.startindex, mark.endindex);
			_regen = true;
			calcFrame();
		}
		
		/**
		 * Returns a JSONed AS3 array of this instance's markups
		 */
		public function ExportMarkups():String
		{
			var arr:Array = [];
			
			for each (var m:Markup in markups)
			{
				var arrm:Array = [];
				
				arrm.push(m.startindex, m.endindex, m.size, m.color);
				
				arr.push(arrm);
			}
			
			if (arr.length > 0) return JSON.stringify(arr);
			else return "[]";
		}
		
		/**
		 * Markups the text using the passed exported string
		 */
		public function ImportMarkups(jsonedmarkups:String):void 
		{
			if (jsonedmarkups.length > 2)
			{
				var arr:Array = JSON.parse(jsonedmarkups) as Array;
				
				for each (var m:Array in arr)
				{
					Markitup(new Markup(m[0], m[1], m[2], m[3]));
				}
			}
		}
		
		/**
		 * Internal function to update the current animation frame.
		 */
		override protected function calcFrame():void
		{
			if(_regen)
			{
				//Need to generate a new buffer to store the text graphic
				var i:uint = 0;
				var nl:uint = _textField.numLines;
				//trace(_textField.numLines);
				height = 0;
				if (autowidth) width = _textField.textWidth+2;
				while(i < nl)
					height += _textField.getLineMetrics(i++).height;
				height += 4; //account for 2px gutter on top and bottom
				_pixels = new BitmapData(width,height,true,0);
				frameHeight = height;
				if (autowidth) frameWidth = width;
				_textField.height = height*1.2;
				_flashRect.x = 0;
				_flashRect.y = 0;
				_flashRect.width = width;
				_flashRect.height = height;
				_regen = false;
			}
			else	//Else just clear the old buffer before redrawing the text
				_pixels.fillRect(_flashRect,0);
			
			if((_textField != null) && (_textField.text != null) && (_textField.text.length > 0))
			{
				//Now that we've cleared a buffer, we need to actually render the text to it
				var format:TextFormat = _textField.defaultTextFormat;
				var formatAdjusted:TextFormat = format;
				_matrix.identity();
				//If it's a single, centered line of text, we center it ourselves so it doesn't blur to hell
				if((format.align == "center") && (_textField.numLines == 1))
				{
					formatAdjusted = new TextFormat(format.font,format.size,format.color,null,null,null,null,null,"left");
					if (!autowidth) _textField.setTextFormat(formatAdjusted);				
					_matrix.translate(Math.floor((width - _textField.getLineMetrics(0).width)/2),0);
				}
				//Render a single pixel shadow beneath the text
				if(_shadow > 0)
				{
					_textField.setTextFormat(new TextFormat(formatAdjusted.font,formatAdjusted.size,_shadow,null,null,null,null,null,formatAdjusted.align));				
					_matrix.translate(1,1);
					_pixels.draw(_textField,_matrix,_colorTransform);
					_matrix.translate(-1,-1);
					if (!autowidth) _textField.setTextFormat(new TextFormat(formatAdjusted.font,formatAdjusted.size,formatAdjusted.color,null,null,null,null,null,formatAdjusted.align));
				}
				//Actually draw the text onto the buffer
				_pixels.draw(_textField,_matrix,_colorTransform);
				if (!autowidth) _textField.setTextFormat(new TextFormat(format.font,format.size,format.color,null,null,null,null,null,format.align));
			}
			
			//Finally, update the visible pixels
			if((framePixels == null) || (framePixels.width != _pixels.width) || (framePixels.height != _pixels.height))
				framePixels = new BitmapData(_pixels.width,_pixels.height,true,0);
			framePixels.copyPixels(_pixels, _flashRect, _flashPointZero);
			
			//if (autowidth) width = _textField.textWidth;
		}
	}
}
