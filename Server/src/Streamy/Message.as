package Streamy 
{
	import flash.utils.ByteArray;
	import flash.errors.IOError;
	import org.flixel.FlxG;
	
	/**
	 * @author Ohmnivore
	 **/
	
	 /**
	  * The bulk of the public API.
	  * This object represents both
	  * ingoing and outgoing messages.
	  * Messages should be declared on both
	  * the server and the client, so 
	  * that each knows how to deal with
	  * each message.
	  */
	
	public class Message 
	{
		/**
		 * A unique identifier for this message. Must be the same on both the client and the server.
		 */
		public var ID:uint;
		
		/**
		 * A reference of the names for the message's fields.
		 * @private
		 */
		internal var fields:Array;
		
		/**
		 * A reference of the types for the message's fields.
		 * @private
		 */
		internal var types:Array;
		
		/**
		 * A reference for the values for the message's fields.
		 * Ex: to get the value of the "playerid" field,
		 * check msg["playerid"]
		 */
		public var msg:Array;
		
		/**
		 * A reference to either the client or server parent.
		 */
		public var network; //Client or Server instance
		
		/**
		 * Is true if the parent network is a client.
		 */
		public var isClient:Boolean;
		
		/**
		 * DO NOT USE. NOT IMPLEMENTED.
		 */
		public var compress:Boolean;
		
		/**
		 * A buffer used when sending.
		 * @private
		 */
		internal var _tosend:Array;
		
		/**
		 * A buffer used when sending.
		 * @private
		 */
		internal var bytedata:ByteArray;
		
		/**
		 * Creates a new message, and adds to parent network.
		 * 
		 * @param id		The message ID. Should be the same on both server and client. Must be 10 or larger. 0-9 are reserved for internal messages.
		 * @param Network	The parent network. You should pass an instance of a client or that of a server.
		 * @param Compress 	Whether to use zlib compression. Only compresses when message is sent through TCP (reliable).
		 */
		public function Message(id:uint, Network, Compress:Boolean = false) 
		{
			fields = new Array();
			msg = new Array();
			_tosend = new Array();
			bytedata = new ByteArray();
			ID = id;
			compress = Compress;
			
			network = Network;
			network.add(this);
			network.udpsocket.addEventListener(String(ID), this.Updatemsg);
			
			if (network is Client) isClient = true;
			else isClient = false;
		}
		
		public function Updatemsg(event:UnreliableEvent):void
		{
			for (var x:uint = 1; x < event.data.length; x++)
			{
				msg[fields[x-1]] = event.data[x];
			}
		}
		
		/**
		 * Sends a reliable message via TCP.
		 * 
		 * @param peer		If network parent is a server, specify a peer to whom you want to send the message. Otherwise leave it null.
		 */
		public function SendReliable(peer:ServerPeer = null):void
		{
			try
			{
				if (isClient)
				{
					_tosend.splice(0);
					_tosend.push(ID);
					bytedata.clear();
					
					for (var x:uint; x < fields.length; x++)
					{
						_tosend.push(msg[fields[x]]);
					}
					
					for (var y:uint; y < _tosend.length; y++)
					{
						if (y == 0)
						{
							bytedata.writeInt(_tosend[y]);
						}
						
						else
						{
							if (types[y-1] == "String") bytedata.writeUTF(_tosend[y]);
							if (types[y-1] == "Int") bytedata.writeInt(_tosend[y]);
							if (types[y-1] == "Float") bytedata.writeFloat(_tosend[y]);
							if (types[y-1] == "Boolean") bytedata.writeBoolean(_tosend[y]);
						}
					}
					
					if (compress) bytedata.compress();
					network.tcpsocket.writeBytes(bytedata);
					network.tcpsocket.flush();
				}
				
				else
				{
					_tosend.splice(0);
					_tosend.push(ID);
					bytedata.clear();
					
					for (var x:uint; x < fields.length; x++)
					{
						_tosend.push(msg[fields[x]]);
					}
					
					for (var y:uint; y < _tosend.length; y++)
					{
						if (y == 0)
						{
							bytedata.writeInt(_tosend[y]);
						}
						
						else
						{
							if (types[y-1] == "String") bytedata.writeUTF(_tosend[y]);
							if (types[y-1] == "Int") bytedata.writeInt(_tosend[y]);
							if (types[y-1] == "Float") bytedata.writeFloat(_tosend[y]);
							if (types[y-1] == "Boolean") bytedata.writeBoolean(_tosend[y]);
						}
					}
					
					//trace(peer.tcpsocket.remotePort);
					if (compress) bytedata.compress();
					peer.tcpsocket.writeBytes(bytedata);
					peer.tcpsocket.flush();
				}
			}
			
			catch (e:IOError)
			{
				if (isClient) trace("Client: ", "TCP", e);
				else trace("Server: ", "TCP", e);
			}
		}
		
		/**
		 * Sends a reliable message via TCP to ALL connected peers.
		 */
		public function SendReliableToAll():void
		{
			for each (var peer:ServerPeer in network.peers)
			{
				SendReliable(peer);
			}
		}
		
		/**
		 * Sends an unreliable but fast message via UDP to ALL connected peers.
		 */
		public function SendUnreliableToAll():void
		{
			for each (var peer:ServerPeer in network.peers)
			{
				SendUnreliable(peer);
			}
		}
		
		/**
		 * Sends an unreliable but fast message via UDP.
		 * 
		 * @param peer		If network parent is a server, specify a peer to whom you want to send the message. Otherwise leave it null.
		 */
		public function SendUnreliable(peer:ServerPeer = null):void
		{
			bytedata.clear();
			_tosend.splice(0);
			_tosend.push(ID);
			
			for (var x:uint; x < fields.length; x++)
			{
				_tosend.push(msg[fields[x]]);
			}
			
			for (var y:uint; y < _tosend.length; y++)
			{
				if (y == 0)
				{
					bytedata.writeInt(_tosend[y]);
				}
				
				else
				{
					if (types[y-1] == "String") bytedata.writeUTF(_tosend[y]);
					if (types[y-1] == "Int") bytedata.writeInt(_tosend[y]);
					if (types[y-1] == "Float") bytedata.writeFloat(_tosend[y]);
					if (types[y-1] == "Boolean") bytedata.writeBoolean(_tosend[y]);
				}
			}
			
			if (isClient) network.SendUnreliable(bytedata);
			else network.SendUnreliable(bytedata, peer);
		}
		
		/**
		 * Sets fields for this message. Call this method right after creation of the message instance.
		 * 
		 * @param fieldarray	Ex: SetFields("id", "xpos", "ypos") will create those 3 fields.
		 */
		public function SetFields(... fieldarray):void
		{
			fields = fieldarray;
			for (var x:uint; x < fields.length; x++)
			{
				msg[fields[x]] = null;
			}
		}
		
		/**
		 * Sets types for every field. Ex: SetFields("name", "xpos", "ypos", "isJumping")
		 * SetTypes("String", "Int", "Int", "Boolean") will attribute the proper types to the
		 * fields declared earlier. Call this method right after calling SetFields.
		 * Accepted types are "String", "Int", "Float", and "Boolean"
		 * Should you need to pass an array, use for example JSON and send it as a string.
		 * 
		 * @param fieldarray	Ex: SetTypes("String", "Int", "Int", "Boolean").
		 */
		public function SetTypes(... fieldarray):void
		{
			types = fieldarray;
		}
	}

}