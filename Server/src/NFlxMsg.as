package  
{
	import flash.utils.ByteArray;
	
	public class NFlxMsg 
	{
		public var data:ByteArray
		
		public var entID:uint;
		public var msgID:uint;
		public var priority:uint;
		
		public var isTCP:Boolean;
		
		//public var acks:Array = [];
		
		public function NFlxMsg(Data:ByteArray, EntID:uint, MsgID:uint, IsTCP:Boolean = false, Priority:uint = 0) 
		{
			entID = EntID;
			msgID = MsgID;
			isTCP = IsTCP;
			priority = Priority;
			data = Data;
		}
	}
}