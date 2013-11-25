package Streamy 
{
	import flash.events.Event;
	import flash.net.DatagramSocket;
	import flash.events.DatagramSocketDataEvent;
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInterface;
	import flash.net.NetworkInfo;
	import flash.net.ServerSocket;
	import flash.events.ServerSocketConnectEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.events.IOErrorEvent;
	
	/**
	 * @author Ohmnivore
	 **/
	
	 /**
	  * The Server class. Manages peer connections.
	  * Uhm pretty much self-explanatory, I guess.
	  */
	
	public class Server 
	{
		public var udpsocket:DatagramSocket;
		public var tcpsocket:ServerSocket;
		
		public var boundaddress:String;
		public var boundudpport:uint;
		public var boundtcpport:uint;
		
		public var messages:Dictionary = new Dictionary();
		public var peers:Dictionary = new Dictionary();
		internal var portmappings:Dictionary = new Dictionary();
		
		//internal var elapsed:Number;
		//internal const messagespersecond:uint;
		//internal const rate:Number;
		//internal var tosend:Array = new Array();
		
		public function Server(Ip:String = null, Udpport:uint = 0, Tcpport:uint = 0) 
		{	
			udpsocket = new DatagramSocket();
			ShowInterfaces();
			
			if (Ip == null)
			{
				var bindadr = FindInterface();
				if (bindadr != "Nothing!") 
				{
					boundaddress = bindadr;
					boundudpport = Udpport;
					udpsocket.bind(Udpport, bindadr);
				}
			}
			
			else
			{
				boundaddress = Ip;
				boundudpport = Udpport;
				udpsocket.bind(Udpport, Ip);
			}
			
			try
			{
				boundtcpport = Tcpport;
				tcpsocket = new ServerSocket();
				tcpsocket.bind(boundtcpport, boundaddress);
				tcpsocket.listen();
				tcpsocket.addEventListener(ServerSocketConnectEvent.CONNECT, NewClient);
				tcpsocket.addEventListener(ProgressEvent.SOCKET_DATA, ReceivedTCP);
                tcpsocket.addEventListener( Event.CLOSE, onClose ); 
			}
			
			catch (e)
			{
				trace(e);
			}
			
			udpsocket.addEventListener(DatagramSocketDataEvent.DATA, ReceivedUDP);
			udpsocket.addEventListener("msgevent", HandleMsg);
			udpsocket.receive();
			
			var udpportdeclare:Message = new Message(0, this);
			udpportdeclare.SetFields("udpport");
			udpportdeclare.SetTypes("Int");
			udpportdeclare.msg["udpport"] = 0;
		}
		
		//public function flush(timeelapsed):void
		//{
			//elapsed += timeelapsed;
			//
			//if (elapsed >= messagespersecond)
			//{
				//elapsed = 0;
				//
				//var alreadysent:Array = new Array();
				//for (var x:uint; x < tosend.length; x++)
				//{
					//var found:Boolean = false;
					//for (var y:uint; y < alreadysent.length; y++)
					//{
						//if (tosend[x].id == alreadysent[y]) found = true;
					//}
					//
					//if (!found) tosend[x].SendReliable();
				//}
			//}
		//}
		
		public function NewClient(event:ServerSocketConnectEvent):void
		{
			var peer:ServerPeer = new ServerPeer(event.socket.remoteAddress, event.socket.remotePort, event.socket);
			peers[peer.id] = peer;
			event.socket.addEventListener(ProgressEvent.SOCKET_DATA, ReceivedTCP);
			event.socket.addEventListener( Event.CLOSE, onClientClose ); 
            event.socket.addEventListener( IOErrorEvent.IO_ERROR, onIOError ); 
		}
		
		private function ProcessTCP(buffer:ByteArray, peersocket:Socket):Array
		{
			var inputarray:Array = new Array();
			
			var x:uint = 0;
			var y:uint = 100;
			while (buffer.bytesAvailable && x <= y)
			{
				if (x == 0)
				{
					var k = buffer.readInt();
					inputarray.push(k);
					y = messages[k].fields.length;
					x++;
				}
				
				else
				{
					var types:Array = messages[inputarray[0]].types;
					
					if (types[x-1] == "String") inputarray.push(buffer.readUTF());
					if (types[x-1] == "Int") inputarray.push(buffer.readInt());
					if (types[x-1] == "Float") inputarray.push(buffer.readFloat());
					if (types[x - 1] == "Boolean") inputarray.push(buffer.readBoolean());
					x++;
					if (x-1 == types.length) break;
				}
			}
			
			var unreliableevent:UnreliableEvent = new UnreliableEvent(inputarray);
			udpsocket.dispatchEvent(unreliableevent);
			
			var peer:ServerPeer = peers[peersocket.remoteAddress.concat(peersocket.remotePort)];
			
			var msgevent:MsgHandler = new MsgHandler(peer, inputarray[0], true);
			udpsocket.dispatchEvent(msgevent);
			
			return inputarray;
		}
		
		private function ReceivedTCP(event:ProgressEvent):void
		{
			try
			{
				var peersocket:Socket = event.target as Socket;
				
				var buffer:ByteArray = new ByteArray();
				peersocket.readBytes(buffer, 0, peersocket.bytesAvailable);
				
				while (buffer.bytesAvailable)
					ProcessTCP(buffer, peersocket);
			}
			
			catch (e)
			{
				trace("Server: ", "TCP", e);
			}
		}
		
		public function SendUnreliable(bytes:ByteArray, peer:ServerPeer):void
		{
			try
			{
				udpsocket.send(bytes, 0, 0, peer.ip, peer.udpport);
			}
			
			catch (e)
			{
				trace("Server: ", "UDP", e);
			}
		}
		
		private function ReceivedUDP(event:DatagramSocketDataEvent):void
        {
			try
			{
				var inputarray:Array = new Array();
				
				var x:uint = 0;
				while (event.data.bytesAvailable)
				{
					if (x == 0)
					{
						inputarray.push(event.data.readInt());
					}
					
					else
					{
						var types:Array = messages[inputarray[0]].types;
						
						if (types[x-1] == "String") inputarray.push(event.data.readUTF());
						if (types[x-1] == "Int") inputarray.push(event.data.readInt());
						if (types[x-1] == "Float") inputarray.push(event.data.readFloat());
						if (types[x-1] == "Boolean") inputarray.push(event.data.readBoolean());
					}
					x++;
				}
				var unreliableevent:UnreliableEvent = new UnreliableEvent(inputarray);
				udpsocket.dispatchEvent(unreliableevent);
				
				var peer:ServerPeer = peers[event.srcAddress.concat(portmappings[event.srcPort])];
				
				var msgevent:MsgHandler = new MsgHandler(peer, inputarray[0], false);
				udpsocket.dispatchEvent(msgevent);
			}
			
			catch(e)
			{
				trace("Server: ", "UDP", e);
			}
        }
		
		public function HandleMsg(event:MsgHandler):void
		{
			//override this method to implement your own behaviour
			//BUT make sure to call super.HandleMsg
			//Sample handling:
			//if (event.id == 1)
			//{
				//trace("MsgID:", messages[1].msg["xpos"]);
			//}
			if (event.id == 0 && event.isTCP)
			{
				if (event.peer.udpport == 0)
				{
					portmappings[messages[event.id].msg["udpport"]] = event.peer.tcpport;
					peers[event.peer.id].udpport = messages[event.id].msg["udpport"];
				}
			}
		}
		
		public function add(msg:Message):void
		{
			messages[msg.ID] = msg;
		}
		
		public function FindInterface():String
		{
			var interfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			
			for each (var interfacex:NetworkInterface in interfaces)
			{
				if (interfacex.displayName.indexOf("Wireless") > 0 && interfacex.active) return interfacex.addresses[0].address;
			}
			
			return "Nothing!";
		}
		
		public function ShowInterfaces():void
		{
			var interfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			
			for each (var interfacex:NetworkInterface in interfaces)
			{
				trace("Server:", interfacex.displayName, interfacex.active);
				for each (var interfacea:InterfaceAddress in interfacex.addresses) trace("->", interfacea.address);
			}
		}
		
		public function onClientClose( event:Event ):void 
        { 
            trace( "Server:", "TCPConnection to client closed." ); 
			var sock:Socket = event.target as Socket;
			var id:String = sock.remoteAddress.concat(sock.remotePort);
			
			delete peers[id];
            //Should also remove from clientSockets array... 
        } 
 
        private function onIOError( errorEvent:IOErrorEvent ):void 
        { 
            trace( "Server:", "TCPIOError: " + errorEvent.text ); 
        } 
 
        private function onClose( event:Event ):void 
        { 
            trace( "Server:", "TCPServer socket closed by OS." ); 
        } 
	}

}