package Streamy
{
	import flash.utils.ByteArray;
	import Streamy.MsgObject;
	import Streamy.Client;
	import Streamy.Message;
	import Streamy.ServerPeer;
	
	public class MsgDispatcher
	{
		public var peer:ServerPeer;
		public var network:Server;
		
		public var q:Array = [];
		public var tcpq:Array = [];
		
		public var udpdelay:Number = 0.033;
		public var udpelapsed:Number = 0;
		
		public var tcpdelay:Number = 0.033;
		public var tcpelapsed:Number = 0;
		
		public var header:Array = new Array;
		
		public function MsgDispatcher(Network:*, Peer:ServerPeer)
		{
			peer = Peer;
			network = Network;
		}
		
		public function check(isTCP:Boolean = false):Boolean
		{
			var queue:Array;
			
			if (isTCP)
			{
				queue = tcpq;
			}
			
			else
			{
				queue = q;
			}
			
			if (queue.length > 0)
			{
				if (network.buffer.length + queue[0].data.length < 1000)
				{
					return true;
				}
			}
			
			return false;
		}
		
		public function addto(m:MsgObject):void
		{
			header.push(network.buffer.length);
			network.buffer.writeBytes(m.data);
		}
		
		public function finalize(isTCP:Boolean = false):void
		{
			var str:String = JSON.stringify(header);
			
			var b:ByteArray = new ByteArray();
			b.writeUTF(str);
			b.writeBytes(network.buffer);
			
			if (isTCP)
			{
				peer.tcpsocket.writeBytes(b);
				peer.tcpsocket.flush();
			}
			
			else network.SendUnreliable(b, peer);
			
			network.buffer.clear();
		}
		
		public function update(e:Number):void
		{
			udpelapsed += e;
			tcpelapsed += e;
			
			if (udpelapsed > udpdelay)
			{
				var toSend:MsgObject = fetchUDP(true);
				
				if (toSend != null)
				{
					addto(toSend);
					
					while (check() && q.length > 0)
					{
						addto(fetchUDP(true));
					}
					
					finalize();
					
					udpelapsed = 0;
				}
			}
			
			if (tcpelapsed > tcpdelay)
			{
				//var toSend:MsgObject = fetchTCP(true);
				//
				//if (toSend != null)
				//{
					//var m:Message = network.messages[toSend.msgID];
					//m.sendReB(toSend.data, peer);
					//tcpelapsed = 0;
				//}
				var toSend:MsgObject = fetchTCP(true);
				
				if (toSend != null)
				{
					addto(toSend);
					
					while (check(true) && tcpq.length > 0)
					{
						addto(fetchTCP(true));
					}
					
					finalize(true);
					
					tcpelapsed = 0;
				}
			}
		}
		
		public function add(m:MsgObject):void
		{
			var replaced:Boolean = false;
			
			if (!m.isTCP)
			{
				for (var i:uint = 0; i < q.length; i++)
				{
					var m2:MsgObject = q[i];
					
					if (m2.msgID == m.msgID && !m2.isTCP)
					{
						m2.data = m.data;
						replaced = true;
					}
				}
				
				if (!replaced) q.push(m);
			}
			
			else
			{
				tcpq.push(m);
			}
		}
		
		public function fetchUDP(Splice:Boolean = false):MsgObject
		{
			var found:MsgObject = null;
			
			if (q.length > 0)
			{
				found = q[0];
				if (Splice) q.splice(0, 1);
			}
			
			return found;
		}
		
		public function fetchTCP(Splice:Boolean = false):MsgObject
		{
			var found:MsgObject = null;
			
			if (tcpq.length > 0)
			{
				found = tcpq[0];
				if (Splice) tcpq.splice(0, 1);
			}
			
			return found;
		}
	}
}