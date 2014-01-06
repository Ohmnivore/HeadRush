package  
{
	import Assets;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	import org.flixel.FlxG;
	import com.stimuli.loading.BulkLoader;
	import flash.events.Event;
	
	public class Downloader 
	{
		public static var dlurl:String;
		public static var dlmanifests:Array = new Array();
		
		public static var hashes:Object = new Object();
		
		public static var manifests:Array = new Array();
		
		public static var loader:BulkLoader;
		
		public static var placeholder:Object = new Object();
		
		public function Downloader() 
		{
			
		}
		
		public static function Go():void
		{
			if (dlmanifests.length > 0)
			{
				FlxG.fade(FlxG.BLACK, 1, null, true);
				
				loader = new BulkLoader("hashloader");
				
				loader.add(dlurl.concat("hashes.json"), {id:"HASH"});
				
				
				loader.get("HASH").addEventListener(Event.COMPLETE, onHashLoaded);
				
				loader.start();
			}
			
			else
			{
				FlxG.camera.stopFX();
				FlxG.flash(FlxG.BLACK, 1, null, true);
				
				Msg.newclient.msg["id"] = 0;
				Msg.newclient.msg["json"] = JSON.stringify([Registry.name, Registry.color]);
				Msg.newclient.SendReliable();
			}
		}
		
		public static function onHashLoaded(event:Event):void 
		{
			hashes = JSON.parse(loader.getText("HASH"));
			loader.removeAll();
			GetManifests();
			FlxG.log("[DL]Got hashes.");
		}
		
		public static function GetManifests():void
		{
			for each (var manifest in dlmanifests)
			{
				loader.add(dlurl.concat(manifest));
			}
			
			loader.addEventListener(BulkLoader.COMPLETE, onManifestsLoaded);
		}
		
		public static function onManifestsLoaded(event:Event):void 
		{
			var x:uint = 0;
			
			for each (var manifest in dlmanifests)
			{
				//FlxG.log(manifest);
				manifests[x] = JSON.parse(loader.getText(dlurl.concat(dlmanifests[x])));
				x++;
			}
			
			loader.removeAll();
			loader.removeEventListener(BulkLoader.COMPLETE, onManifestsLoaded);
			GetFiles();
			FlxG.log("[DL]Got manifests.");
		}
		
		public static function GetFiles():void
		{
			for each (var manifest in manifests)
			{
				for (var key in manifest)
				{
					loader.add(dlurl.concat(manifest[key]));
				}
			}
			
			loader.addEventListener(BulkLoader.COMPLETE, onFilesLoaded);
		}
		
		public static function onFilesLoaded(event:Event):void 
		{
			FlxG.camera.stopFX();
			FlxG.flash(FlxG.BLACK, 1, null, true);
			
			for each (var manifest in manifests)
			{
				for (var key in manifest)
				{
					if (manifest[key].slice(-1, -3) == "png")
						Assets[key] = loader.getBitmap(dlurl.concat(manifest[key]));
						FlxG.log(key);
				}
			}
			
			loader.removeAll();
			loader.removeEventListener(BulkLoader.COMPLETE, onFilesLoaded);
			FlxG.log("[DL]Got files.");
			
			Msg.newclient.msg["id"] = 0;
			Msg.newclient.msg["json"] = JSON.stringify([Registry.name, Registry.color]);
			Msg.newclient.SendReliable();
		}
	}
}