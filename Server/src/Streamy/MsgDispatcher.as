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
		
		public var msg:Array = new Array;
		
		public var seq:uint = 10;
		internal var _ack:uint;
		public var times:Array = [75, 75, 75, 75, 75, 75, 75, 75, 75, 75];
		public var ping:Number = 75.0;
		public var lostpacks:uint = 0;
		
		public function MsgDispatcher(Network:*, Peer:ServerPeer)
		{
			peer = Peer;
			network = Network;
		}
		
		public function set ack(v:uint):void
		{
			_ack = v;
			
			var diff:uint;
			diff = seq - _ack;
			
			if (diff < 10)
			{
				if (times[10 - diff] != true)
				{
					var rtt:Number;
					rtt = times[10 - diff];
					times[10 - diff] = true;
					if (rtt > ping) ping += rtt / 10;
					else ping -= rtt / 10;
				}
			}
			
			else
			{
				ping += 300 / 10;
			}
		}
		
		public function get ack():uint
		{
			return _ack;
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
				var tot:uint = 0;
				
				for each (var m:ByteArray in msg)
				{
					tot += m.length;
				}
				
				if (tot + queue[0].data.length < 900)
				{
					return true;
				}
			}
			
			return false;
		}
		
		public function addto(m:MsgObject):void
		{
			msg.push(m.data);
		}
		
		public function finalize(isTCP:Boolean = false):void
		{
			var b:ByteArray = new ByteArray();
			
			if (!isTCP)
			{
				msg.push(seq);
				seq++;
				
				if (times[0] != true)
				{
					lostpacks++;
				}
				
				else 
				{
					lostpacks--;
				}
				
				if (lostpacks < 0) 
				{
					lostpacks = 0;
				}
				
				times.splice(0, 1);
				times.push(0.0);
			}
			
			b.writeObject(msg);
			
			if (isTCP)
			{
				peer.tcpsocket.writeBytes(b);
				peer.tcpsocket.flush();
			}
			
			else network.SendUnreliable(b, peer);
			
			msg = [];
		}
		
		public function update(e:Number):void
		{
			for each (var t in times)
			{
				if (t != true) t += e * 1000;
			}
			
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
			//trace(ping);
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