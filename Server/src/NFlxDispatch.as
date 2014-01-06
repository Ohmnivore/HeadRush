package  
{
	import NFlxMsg;
	
	public class NFlxDispatch 
	{
		public static var q:Array = [];
		
		public static function add(m:NFlxMsg):void
		{
			var replaced:Boolean = false;
			
			for (var i:uint = 0; i < q.length; i++)
			{
				var m2:NFlxMsg = q[i];
				
				if (m2.entID == m.entID && m2.msgID == m.msgID && !m2.isTCP)
				{
					m2.data = m.data;
					replaced = true;
				}
			}
			
			if (!replaced) q.push(m);
		}
		
		public static function fetchUDP():NFlxMsg
		{
			q.sortOn("priority", Array.NUMERIC || Array.DESCENDING);
			
			var found:NFlxMsg = null;
			
			for (var i:uint = 0; i < q.length; i++)
			{
				var m:NFlxMsg = q[i];
				
				m.priority++;
				
				if (found == null)
				{
					if (!m.isTCP)
					{
						found = m;
						q.splice(i, 1);
					}
				}
			}
			
			return found;
		}
		
		public static function fetchTCP():NFlxMsg
		{
			q.sortOn("priority", Array.NUMERIC || Array.DESCENDING);
			
			var found:NFlxMsg = null;
			
			for (var i:uint = 0; i < q.length, i++)
			{
				var m:NFlxMsg = q[i];
				
				m.priority++;
				
				if (found == null)
				{
					if (m.isTCP)
					{
						found = m;
						q.splice(i, 1);
					}
				}
			}
			
			return found;
		}
	}

}