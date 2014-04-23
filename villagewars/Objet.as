package
{
	import flash.display.*;
	import flash.net.URLRequest;
	import flash.events.*;
	import flash.utils.Timer;
	public class Objet extends Sprite
	{
		private static var spritesData:Array;
		private static var spritesLoad:Array;
		public static var objets:Array;
		private var objid:int;
		public var ox:int;
		public var oy:int;
		public var ow:int = 48;
		public var oh:int = 32;
		function Objet(map : DisplayObjectContainer, id : int, ix : Number, iy : Number, oid : int):void
		{
			
			objid = oid;
			x = ix;
			y = iy;
			if (objets == null)
			{
				objets = new Array();
			}
			if (oid > 0)
			{
				objets[id] = this;
				if (spritesData == null)
				{
					
					
					spritesData = new Array();
				}
				if (spritesLoad == null)
				{
					spritesLoad = new Array();
				}
				if (spritesLoad[oid] != true)
				{
					var im:Loader = new Loader();
					im.contentLoaderInfo.addEventListener(Event.COMPLETE, imageChargee);
					spritesLoad[oid] = true;
					im.load ( new URLRequest ("images/Objet/" + oid + ".PNG") ); 
				}
				chargerObjet();
			}
			// Détermination de sa profondeur dans la liste d'affichage
			var i:int = 0;
			while (i < map.numChildren && y + height > map.getChildAt(i).y + map.getChildAt(i).height)
			{
				i++;
			}
			map.addChildAt(this,i);
		}
		private function chargerObjet():void
		{
			if (spritesData[objid] is BitmapData)
			{
				var bmp:Bitmap = new Bitmap(spritesData[objid]);
				addChild(bmp);
				ox = x + width/2 - ow/2;
				oy = y + height - oh;
			}
			else
			{
				var objt:Timer = new Timer(100,1);
				objt.addEventListener(TimerEvent.TIMER, chargerObjetTimer);
				objt.start();
			}
		
		}
		private function chargerObjetTimer(e : Event):void
		{
			chargerObjet();
		}
		private function imageChargee(pEvt : Event):void
		{
			try {
				if (pEvt.target.content is Bitmap)
				{
					spritesData[objid] = pEvt.target.content.bitmapData;
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
