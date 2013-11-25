package Streamy 
{
	import flash.events.Event;
	
	/**
	 * An internaly processed event.
	 * 
	 * @author Adam Atomic
	 * @private
	 */
	public class UnreliableEvent extends Event
	{
		public var data:Array; 
		
		public function UnreliableEvent(Data:Array) 
		{
			data = Data;
			super(String(data[0]))
		}
		
	}

}