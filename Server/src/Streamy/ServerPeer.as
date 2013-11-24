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
		
		public function ServerPeer(Ip:String, Port:uint, TCPSocket:Socket) 
		{
			ip = Ip;
			tcpsocket = TCPSocket;
			tcpport = tcpsocket.remotePort;
			udpport = 0;
			Create();
		}
		
		public function Create():void
		{
			id = ip.concat(tcpport);
		}
	}

}