package
{
	import flash.display.*;
	import flash.net.URLRequest;
	import flash.events.*;
	import flash.utils.Timer;
	public class Tile extends Sprite
	{
		private static var tilesData:Array;
		private static var tilesLoad:Array;
		public static var tiles:Array;
		private var tileid:int;
		function Tile(map : DisplayObjectContainer, ox : Number, oy : Number, tid : int):void
		{
			tileid = tid;
			x = ox*48;
			y = oy*48;
			
			
			if (tid > 0)
			{
				if (tiles == null)
				{
					tiles = new Array()
				}
				if (tiles[oy] == null)
				{
					tiles[oy] = new Array();
				}
				tiles[oy][ox] = tid;
				map.addChild(this);
				if (tilesData == null)
				{
					tilesData = new Array();
				}
				if (tilesLoad == null)
				{
					tilesLoad = new Array();
				}
				if (tilesLoad[tid] != true)
				{
					var im:Loader = new Loader();
					im.contentLoaderInfo.addEventListener(Event.COMPLETE, tileChargee);
					im.load ( new URLRequest ("images/Terrain/" + tid + ".PNG") );
					tilesLoad[tid] = true;					
				}
				chargerTile();
			}
		}
		private function chargerTile():void
		{
			if (tilesData[tileid] is BitmapData)
			{
				var bmp:Bitmap = new Bitmap(tilesData[tileid]);
				addChild(bmp);
			}
			else
			{
				var objt:Timer = new Timer(100,1);
				objt.addEventListener(TimerEvent.TIMER, chargerTileTimer);
				objt.start();
			}
		
		}
		private function chargerTileTimer(e : Event):void
		{
			chargerTile();
		}
		private function tileChargee(pEvt : Event):void
		{
			try {
				if (pEvt.target.content is Bitmap)
				{
					tilesData[tileid] = pEvt.target.content.bitmapData;
				}
				else
				{
					trace("Erreur : Fichier non Bitmap");
				}
			} catch( e : Error ) {
				trace( e ); 
			}
		}
	}
}
