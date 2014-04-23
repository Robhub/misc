package
{
	import flash.display.*;
    import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.events.*;
	import flash.net.URLRequest;
	
	
	public class Joueur extends Objet
	{

		private var haut:Boolean = false;
		private var bas:Boolean = false;
		private var gauche:Boolean = false;
		private var droite:Boolean = false;
		private var direction:int;
		private var bouge:Boolean = false;
		private var timer:Timer = new Timer(4,0);
		private var aniTimer:Timer = new Timer(80,0);
		private var aniCount:int;
		//private var ani:Boolean = false;
		private var nload:int = 0;
		private var images:Array = new Array();
		private var map: DisplayObjectContainer;
		private var stg:Stage;
		private var tik:Number;
		//private var tikc:Number = 0;
		function Joueur(pmap : DisplayObjectContainer, id : int,  ox : Number, oy : Number, st:Stage):void
		{
			trace("Joueur chargement...");
			map = pmap;
			stg = st;
			super(map,id,ox,oy,0);
			ow = 42;
			oh = 24;			
			Objet.objets[id] = this;
			var i:int;
			var y:int;
			for (i = 0 ; i <= 4 ; i++)
			{
				for (y = 0 ; y <= 8 ; y++)
				{
					nload++;
					images[i*10+y] = new Loader();
					images[i*10+y].contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
					images[i*10+y].load ( new URLRequest ("images/Joueur/"+i+y+".PNG") );
				}
			}
		}
		private function loadComplete(pEvt : Event):void
		{
			try {
				if (pEvt.target.content is Bitmap)
				{
					nload--;
					if (nload == 0)
					{
						loadfini();
					}
				}
				else
				{
					trace("Erreur : Fichier non Bitmap");
				}
			} catch( e : Error ) {
				trace( e ); 
			}
		}
		private function loadfini():void
		{
			var i:int;
			var y:int;
			for (i = 0 ; i <= 4 ; i++)
			{
				for (y = 0 ; y <= 8 ; y++)
				{
					images[i*10+y] = new Bitmap(images[i*10+y].content.bitmapData);
				}
			}
			var c:int = 1;
			for (i = 5 ; i <= 7 ; i++)
			{
				for (y = 0 ; y <= 8 ; y++)
				{
					if (images[(i-2*c)*10+y] is Bitmap)
					{
						images[i*10+y] = new Bitmap(images[(i-2*c)*10+y].bitmapData);
						images[i*10+y].x += images[i*10+y].width;
						images[i*10+y].scaleX *= -1;
					}
					else
					{
						trace("non bitmap : " + i + "," + c + " : " + images[(i-2*c)*10]);
					}
				}
				c++;
			}
			addChild(images[0]);

			stg.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            stg.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			timer.addEventListener(TimerEvent.TIMER, actualiser);
			tik = getTimer();
			timer.start();
			aniTimer.addEventListener(TimerEvent.TIMER, animer);
			stg.addEventListener(Event.RESIZE, resizeHandler);
checkScroll();
			trace("Joueur pret");
			trace("ZOOM : PG DN & PG UP");
			trace("MOVE : UP/DOWN/LEFT/RIGHT");
			trace("prochainement : SPACE");

			
		}
		private function resizeHandler(e:Event):void {
			checkScroll();
		}
		private function animer(e:TimerEvent):void {
			removeChild(getChildAt(0));
			addChild(images[direction*10+1+aniCount % 8]);
			aniCount++;
		}
		private function startAnimate(newDirection:int):void {
			bouge = true;
			direction = newDirection;
			removeChild(getChildAt(0));
			addChild(images[direction*10+1]);
			aniCount = 1;
			aniTimer.start();

		}
		private function stopAnimate():void {
			aniTimer.stop();
			removeChild(getChildAt(0));
			addChild(images[direction*10]);
		}
		private function actualiser(e:TimerEvent):void {
			var ecoule:Number = getTimer() - tik;
			while (ecoule > 20)
			{
			ecoule = getTimer() - tik
			tik += 20;
			//tikc++;
			//if (tikc % 10 == 0) animer();
			var i:int;
			var nx:Number = 0;
			var ny:Number = 0;
			var startBouge:Boolean = true;
			var newDirection:int;
			if (gauche && !droite && !haut && !bas) {
				nx -= 3;
				newDirection = 2;
			}
			else if (droite && !gauche && !haut && !bas) {
				nx += 3;
				newDirection = 6;
			}
			else if (haut && !gauche && !bas && !droite) {
				newDirection = 4;
				ny -= 3;
				checkUp();
			}
			else if (bas && !gauche && !haut && !droite) {
				newDirection = 0;
				ny += 3;
				checkDown();
			}
			else if (bas && gauche && !haut && !droite) {
				newDirection = 1;
				ny += 2;
				nx -= 2;
				checkDown();
			}
			else if (!bas && gauche && haut && !droite) {
				newDirection = 3;
				ny -= 2;
				nx -= 2;
				checkUp();
			}
			else if (!bas && !gauche && haut && droite) {
				newDirection = 5;
				ny -= 2;
				nx += 2;
				checkUp();
			}
			else if (bas && !gauche && !haut && droite) {
				newDirection = 7;
				ny += 2;
				nx += 2;
				checkDown();
			}
			else
			{
				if (bouge) stopAnimate();
				startBouge = false;
				bouge = false;
			}
			if (bouge)
			{
				checkScroll();
				// Pour les collisions, on avance pixel par pixel pour faciliter le travail.
				while (nx != 0 || ny != 0)
				{
					checkColl(nx,ny);
					if (nx > 0) nx--;
					if (ny > 0) ny--;
					if (nx < 0) nx++;
					if (ny < 0) ny++;
				}
				
			}
			if (startBouge && (!bouge || newDirection != direction )) startAnimate(newDirection);
			}
		}
		private function checkColl(nx:int, ny:int):void {
			// Pixel par pixel, on prend juste on compte positif ou négatif.
			if (nx > 0) nx = 1;
			if (ny > 0) ny = 1;
			if (nx < 0) nx = -1;
			if (ny < 0) ny = -1;
			// calcul des coordonées de collision
			ox = x + width/2 - ow/2;
			oy = y + height - oh;
			var mx:int = ox + nx;
			var my:int = oy;
			var cxa:int = Math.floor(mx/48);
			var cxb:int = Math.floor((mx+ow)/48);
			var cya:int = Math.floor(my/48);
			var cyb:int = Math.floor((my+oh)/48);

			if (nx > 0)
			{
				if (Tile.tiles[cya][cxb] == 1) nx = 0
				if (Tile.tiles[cyb][cxb] == 1) nx = 0;
			}
			if (nx < 0)
			{
				if (Tile.tiles[cya][cxa] == 1) nx = 0;
				if (Tile.tiles[cyb][cxa] == 1) nx = 0;
			}

			
			
			mx = ox;
			my = oy + ny;
			
			cxa = Math.floor(mx/48);
			cxb = Math.floor((mx+ow)/48);
			

			
			cya = Math.floor(my/48);
			cyb = Math.floor((my+oh)/48);
			if (ny > 0)
			{
				if (Tile.tiles[cyb][cxa] == 1) ny = 0;
				if (Tile.tiles[cyb][cxb] == 1) ny = 0;
			}
			if (ny < 0)
			{
				if (Tile.tiles[cya][cxa] == 1) ny = 0;
				if (Tile.tiles[cya][cxb] == 1) ny = 0;
			}
			//var i;
			var hit:Boolean = false;
			

			if (nx != 0)
			{
				for (var i:String in Objet.objets)
				{
					if (!hit)
					{
						if (Objet.objets[i] != this)
						{
							hit = true;
							if (ox + nx + ow <= Objet.objets[i].ox) {
								hit = false;
							}
							if (oy + oh <= Objet.objets[i].oy) {
								hit = false;
							}
							if (Objet.objets[i].ox + Objet.objets[i].ow <= ox + nx ) {
								hit = false;
							}
							if (Objet.objets[i].oy + Objet.objets[i].oh <= oy) {
								hit = false;
							}
						}
						
					}

				}
				if (hit)
				{
					nx = 0;

				}
			}
			hit = false;
			if (ny != 0)
			{
				for (i in Objet.objets)
				{

					if (!hit)
					{
						if (Objet.objets[i] != this)
						{
							hit = true;
							if (ox + ow <= Objet.objets[i].ox) {
								hit = false;
							}
							if (oy + ny + oh <= Objet.objets[i].oy) {
								hit = false;
							}
							if (Objet.objets[i].ox + Objet.objets[i].ow <= ox ) {
								hit = false;
							}
							if (Objet.objets[i].oy + Objet.objets[i].oh <= oy + ny) {
								hit = false;
							}
						}
			
						
					}

				}
				if (hit)
				{
	
					ny = 0;	

				}
			}
			
			/*for (i = 0; i < map.parent.numChildren ; i++)
			{
				var tile:DisplayObject = map.parent.getChildAt(i);
				var tile:Tile = (Tile)tdo;

				if (tile.getTileId() == 1)
				{
					
				}
			
			}*/
x += nx;
y += ny;
			
		}
		private function checkScroll():void {
		var ecart:Number = 1/6;
			while (map.parent.x + x + width*0.5 > stg.stageWidth*(0.5+ecart))
			{
				map.parent.x--;
			}
			while (map.parent.x + x + width*0.5  < stg.stageWidth*(0.5-ecart))
			{
				map.parent.x++;
			}
			while (map.parent.y + y + height*0.5  > stg.stageHeight*(0.5+ecart))
			{
				map.parent.y--;
			}
			while (map.parent.y + y + height*0.5  < stg.stageHeight*(0.5-ecart))
			{
				map.parent.y++;
			}
		}
		private function checkUp():void {
			var i:int = map.getChildIndex(this);
			if (i != 0) // On est déja en fond de liste
			{
				i--; // On va comparer avec celui juste derrière nous
				while (i >= 0 && y + height < map.getChildAt(i).y + map.getChildAt(i).height)
				{
					i--; // Si on est derrière lui alors on va voir le prochain
				}
				map.setChildIndex(this,i+1); // On prend la place de l'objet juste devant celui qui est derrière nous
			}
		}
		private function checkDown():void {
			var i:int = map.getChildIndex(this);
			if (i != map.numChildren-1) // On est déja en tête de liste
			{
				i++; // On va comparer avec celui juste devant nous
				while (i < map.numChildren && y + height > map.getChildAt(i).y + map.getChildAt(i).height)
				{
					i++; // On est devant lui alors on va voir le prochain
				}
				map.setChildIndex(this,i-1); // On prend la place de l'objet juste derrière celui qui est devant nous
			}
		}
		
		private function keyDownHandler(e:KeyboardEvent):void {
			if (e.keyCode == 37) gauche = true;
			if (e.keyCode == 38) haut = true;
			if (e.keyCode == 39) droite = true;
			if (e.keyCode == 40) bas = true;
        }

        private function keyUpHandler(e:KeyboardEvent):void {
			if (e.keyCode == 33) {
			//map.parent.x -= map.parent.width/2;
			//map.parent.y -= map.parent.height/2;
			//map.parent.width *= 2;
			//map.parent.height *= 2;
			map.parent.scaleX *= 2;
			map.parent.scaleY *= 2;
			checkScroll();
			}
			if (e.keyCode == 34) {
			//map.parent.x += map.parent.width/2;
			//map.parent.y += map.parent.height/2;
			map.parent.scaleX *= 0.5;
			map.parent.scaleY *= 0.5;
			//map.parent.width /= 2;
			//map.parent.height /= 2;
			checkScroll();

			}
			if (e.keyCode == 37) gauche = false;
			if (e.keyCode == 38) haut = false;
			if (e.keyCode == 39) droite = false;
			if (e.keyCode == 40) bas = false;
        }

	}
}
