package com.bit101.components 
{
	import flash.display.DisplayObjectContainer;
	
	public class VIntSlider extends VUISlider
	{
		public function VIntSlider(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = "", defaultHandler:Function = null)
		{
			super(parent, xpos, ypos, label, defaultHandler);
		}
		override protected function formatValueLabel():void
		{
			if(isNaN(_slider.value))
			{
				_valueLabel.text = "NaN";
				return;
			}
			var mult:Number = Math.pow(10, _precision);
			var val:String = int((Math.round(_slider.value * mult) / mult)).toString();
			var parts:Array = val.split(".");
			
			_valueLabel.text = val;
			positionLabel();
		}
	}

}