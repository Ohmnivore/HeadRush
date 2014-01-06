package Streamy
{
	import flash.events.Event;
	import flash.net.DatagramSocket;
	import flash.events.DatagramSocketDataEvent;
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInterface;
	import flash.net.NetworkInfo;
	import flash.net.Socket;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	import org.flixel.FlxG;
	
	/**
	 * @author Ohmnivore
	 **/
	
	 /**
	  * The client. Connects to a server instance.
	  * Obviously.
	  */
	
	public class Client
	{
		public var udpsocket:DatagramSocket;
		public var tcpsocket:Socket;
		
		public var address:String;
		public var boundaddress:String;
		
		public var boundudpport:uint;
		public var boundtcpport:uint;
		
		public var udpport:uint;
		public var tcpport:uint;
		
		public var messages:Dictionary = new Dictionary();
		public var udpportdeclare:Message;
		
		//internal var elapsed:Number;
		//internal const messagespersecond:uint;
		//internal const rate:Number;
		//internal var tosendudp:Array = new Array();
		
		public function Client(Ip:String = null, Udpport:uint = 0, Tcpport:uint = 0):void
		{
			udpsocket = new DatagramSocket();
			ShowInterfaces();
			
			//elapsed = 0;
			//rate = 1.0 / messagespersecond;
			
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
			
			boundtcpport = Tcpport;
			tcpsocket = new Socket();
		}
		
		public function Connect(Ip:String, Udpport:uint, Tcpport:uint):void
		{
			address = Ip;
			udpport = Udpport;
			tcpport = Tcpport;
			udpsocket.connect(address, udpport);
			udpsocket.addEventListener(DatagramSocketDataEvent.DATA, ReceivedUDP);
			udpsocket.addEventListener("msgevent", HandleMsg);
			udpsocket.receive();
			
			tcpsocket.connect(address, tcpport);
			tcpsocket.addEventListener(ProgressEvent.SOCKET_DATA, ReceivedTCP);
			tcpsocket.addEventListener(Event.CONNECT, connectHandler);
			tcpsocket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			tcpsocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			tcpsocket.addEventListener(Event.CLOSE, closeHandler);
			
			udpportdeclare = new Message(0, this);
			udpportdeclare.SetFields("udpport");
			udpportdeclare.SetTypes("Int");
			udpportdeclare.msg["udpport"] = boundudpport;
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
						//if (tosendudp[x].id == alreadysent[y]) found = true;
					//}
					//
					//if (!found) tosendudp[x].SendReliable();
				//}
			//}
		//}
		
		public function Close():void
		{
			udpsocket.close();
			tcpsocket.close();
		}
		
		public function SendUnreliable(bytes:ByteArray):void
		{
			try 
			{
				udpsocket.send(bytes, 0, 0);
			}
			catch (e)
			{
				trace("Client: ", "UDP", e);
			}
		}
		
		private function ProcessTCP(buffer:ByteArray):Array
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
			
			var msgevent:MsgHandler = new MsgHandler(null, inputarray[0], true);
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
				
				var contents:Array = JSON.parse(buffer.readUTF()) as Array;
				
				var currentmsg:uint = 0;
				
				for (var currentmsg:uint = 0; currentmsg < contents.length; currentmsg++)
				{
					if (currentmsg == contents.length - 1)
					{
						var buffer2:ByteArray = new ByteArray();
						buffer.readBytes(buffer2, contents[currentmsg], 0);
						
						ProcessTCP(buffer2);
					}
					
					else
					{
						var buffer2:ByteArray = new ByteArray();
						buffer.readBytes(buffer2, contents[currentmsg], 
							contents[currentmsg] - contents[currentmsg + 1]);
						
						ProcessTCP(buffer2);
					}
				}
				
				//while (buffer.bytesAvailable)
					//ProcessTCP(buffer);
			}
			
			catch (e)
			{
				FlxG.log("Client: " + "TCP" + e);
			}
		}
		
		private function ParseFromBytes(d:ByteArray):void
		{
			var inputarray:Array = new Array();
			
			var x:uint = 0;
			while (d.bytesAvailable)
			{
				if (x == 0)
				{
					inputarray.push(d.readInt());
				}
				
				else
				{
					var types:Array = messages[inputarray[0]].types;
					
					if (types[x-1] == "String") inputarray.push(d.readUTF());
					if (types[x-1] == "Int") inputarray.push(d.readInt());
					if (types[x-1] == "Float") inputarray.push(d.readFloat());
					if (types[x-1] == "Boolean") inputarray.push(d.readBoolean());
				}
				x++;
			}
			var unreliableevent:UnreliableEvent = new UnreliableEvent(inputarray);
			udpsocket.dispatchEvent(unreliableevent);
			
			var msgevent:MsgHandler = new MsgHandler(null, inputarray[0], false);
			udpsocket.dispatchEvent(msgevent);
		}
		
		private function ReceivedUDP(event:DatagramSocketDataEvent):void
        {
			try
			{
				var contents:Array = JSON.parse(event.data.readUTF()) as Array;
				
				var currentmsg:uint = 0;
				
				for (var currentmsg:uint = 0; currentmsg < contents.length; currentmsg++)
				{
					if (currentmsg == contents.length - 1)
					{
						var buffer:ByteArray = new ByteArray();
						event.data.readBytes(buffer, contents[currentmsg], 0);
						
						ParseFromBytes(buffer);
					}
					
					else
					{
						var buffer:ByteArray = new ByteArray();
						event.data.readBytes(buffer, contents[currentmsg], 
							contents[currentmsg] - contents[currentmsg + 1]);
						
						ParseFromBytes(buffer);
					}
				}
			}
			
			catch(e)
			{
				FlxG.log("Client: " + "UDP" + e);
			}
        }
		
		public function HandleMsg(event:MsgHandler):void
		{
			//override this method to implement your own behaviour
			//Sample handling:
			//if (event.id == 1)
			//{
				//trace("MsgID:", messages[1].msg["xpos"]);
			//}
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
				trace("Client: ", interfacex.displayName, interfacex.active);
				for each (var interfacea:InterfaceAddress in interfacex.addresses) trace("->", interfacea.address);
			}
		}
		
		private function closeHandler(event:Event):void {
			trace("Client: ", "TCPcloseHandler: " + event);
		}

		private function connectHandler(event:Event):void {
			trace("Client: ", "TCPconnectHandler: " + event);
			udpportdeclare.SendReliable();
		}

		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("Client: ", "TCPioErrorHandler: " + event);
		}

		private function securityErrorHandler(event:SecurityErrorEvent):void {
			trace("Client: ", "TCPsecurityErrorHandler: " + event);
		}
	}
	
}