package Streamy
{
	import flash.utils.ByteArray;
	
	public class MsgObject 
	{
		public var data:ByteArray
		
		public var msgID:uint;
		
		public var isTCP:Boolean;
		
		public var priority:uint;
		
		public var entity:int;
		
		public const STREAMY_ENT:int = -1;
		public const STREAMY_PRT:uint = 5;
		
		public function MsgObject(Data:ByteArray, MsgID:uint, IsTCP:Boolean = false, 
			Priority:uint = STREAMY_PRT, Entity:int = STREAMY_ENT) 
		{
			msgID = MsgID;
			isTCP = IsTCP;
			data = Data;
			priority = Priority;
			entity = Entity;
		}
	}
}