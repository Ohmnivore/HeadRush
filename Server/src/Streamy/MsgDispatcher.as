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
		
		//Network performance stats
		public var seq:uint = 10;
		internal var _ack:uint;
		public var times:Array = [true, true, true, true, true, true, true, true, true, true];
		public var ping:Number = 75.0;
		public var lostpacks:uint = 0; //Doesn't work yet
		
		//Network congestion handling variables
		public const UDPDOWN:uint = 2;
		public const TCPDOWN:uint = 3;
		public const UDPUP:Number = 0.005;
		public const TCPUP:Number = 0.004;
		
		public function MsgDispatcher(Network:*, Peer:ServerPeer)
		{
			peer = Peer;
			network = Network;
		}
		
		public function regulate(Congested:Boolean):void
		{
			if (Congested)
			{
				udpdelay *= UDPDOWN;
				tcpdelay *= TCPDOWN;
				if (udpdelay > 0.5) udpdelay = 0.5;
				if (tcpdelay > 0.5) tcpdelay = 0.5;
			}
			
			else
			{
				udpdelay -= UDPUP;
				tcpdelay -= TCPUP;
				if (udpdelay < 0) udpdelay = 0;
				if (tcpdelay < 0) tcpdelay = 0;
			}
		}
		
		public function set ack(v:uint):void
		{
			_ack = v;
			
			var diff:uint;
			diff = seq - _ack;
			
			if (diff < 11)
			{
				if (times[10 - diff] != -1)
				{
					var rtt:Number;
					rtt = times[10 - diff];
					times[10 - diff] = -1;
					//if (rtt > ping) ping += rtt / 10;
					//else ping -= rtt / 10;
					//ping = rtt / 2;
					ping = (0.2 * rtt / 2.0) + ((1.0 - 0.2) * ping);
					if (ping < 0.01) ping = 0.01;
				}
			}
			
			else
			{
				ping += 30;
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
				
				if (times[0] != -1)
				{
					lostpacks++;
				}
				
				else 
				{
					if (lostpacks > 0) lostpacks--;
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
				if (t != -1) t += e * 1000;
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
			
			//Flow control
			var tot:Number = 0;
			for (var x:int = 5; x < 10; x++)
			{
				tot += times[x];
			}
			
			if (tot / 5 > ping) regulate(true);
			else regulate(false);
			
			trace(ping, udpdelay);
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