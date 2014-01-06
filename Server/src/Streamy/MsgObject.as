package Streamy
{
	import flash.utils.ByteArray;
	
	public class MsgObject 
	{
		public var data:ByteArray
		
		public var msgID:uint;
		
		public var isTCP:Boolean;
		
		public function MsgObject(Data:ByteArray, MsgID:uint, IsTCP:Boolean = false) 
		{
			msgID = MsgID;
			isTCP = IsTCP;
			data = Data;
		}
	}
}