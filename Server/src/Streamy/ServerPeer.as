package Streamy 
{
	import flash.net.Socket;
	
	public class ServerPeer 
	{
		public var ip:String;
		public var tcpport:uint;
		public var udpport:uint;
		public var tcpsocket:Socket;
		public var id:String;
		public var identifier:uint;
		public var dispatcher:MsgDispatcher;
		public var net:*;
		
		public function ServerPeer(Ip:String, Port:uint, TCPSocket:Socket, Net:*) 
		{
			ip = Ip;
			tcpsocket = TCPSocket;
			tcpport = tcpsocket.remotePort;
			udpport = 0;
			net = Net;
			dispatcher = new MsgDispatcher(net, this);
			Create();
		}
		
		public function Create():void
		{
			id = ip.concat(tcpport);
		}
	}

}