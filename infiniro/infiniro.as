package
{
	import flash.display.*;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	import flash.media.Sound;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import com.adobe.crypto.MD5;

	public class infiniro extends Sprite
	{
		private var backblur:Array = new Array();

		/*
		private var sendscore:int;
		private var sendcombo:int;
		private var sendspeed:int;
		*/
		private var highscores:Sprite = new Sprite();
		private var highscoresshown:Boolean = false;
		private var sendscoreshown:Boolean = false;
		private var dejajoue:Boolean = false;
		
		private var back:Bitmap;
		private var backk:Bitmap;
		
		private var editnick:TextField = new TextField();
		private var sendbutton:SimpleButton = new SimpleButton();
		private var txtnick:TextField = new TextField();
		private var txtsend:TextField = new TextField();
		private var txthighscore:TextField = new TextField();
		private var lance:Boolean = false;
		private var dogameover:Boolean = false;
		private var parcouru:Number = 0;
		private var haut:Boolean;
		private var bas:Boolean;
		private var espace:Boolean = false;
		private var seed:int = 1337;
		private var nload:int = 0;
		private var bitmaps:Array = new Array();
		private var txtlance:TextField = new TextField();
		private var txt:TextField = new TextField();
		private var txtcombo:TextField = new TextField();
		private var txtcomboformat:TextFormat = new TextFormat();
		private var combo:int = 0;
		private var comboscore:int = 0;
		private var tik:int;
		private var timeStart:int;
		private var timeEnd:int;
		private var joueurX:Number = 0;
		private var joueurY:Number = 200;
		private var high:int = 0;
		private var maxcombo:int;
		private var maxspeed:int;
		private var joueurAX:Number = 0;
		private var joueurVX:Number = 10;
		private var joueurVY:Number = 0;
		private var terrain:Sprite = new Sprite();
		private var speeds:Sprite = new Sprite();
		private var mines:Sprite = new Sprite();
		private var sndboom:Sound = new Sound();
		private var sndspeed:Sound = new Sound();
		private var speedx:Number = 0;
		private var speedy:Number = 200;
		private var sourisY:Number = 200;
		private var joueur:Bitmap;
		private var timer:Timer;
		function infiniro():void {
			stage.align = StageAlign.TOP; 
			stage.scaleMode = StageScaleMode.NO_SCALE;
			sndboom.load(new URLRequest ("boom.mp3"));
            sndspeed.load(new URLRequest ("speed.mp3"));
			/*var back:Shape = new Shape();
			back.graphics.beginFill(0xFFFFFF);
			back.graphics.drawRect(0,0,800,400);
			addChild(back);*/

			
			var loads:Array = new Array();
			loads.push("infiniro.png");
			loads.push("speed.png");
			loads.push("mine.png");
			loads.push("fond.jpg");
			
			var i:int;
			for (i = 0; i < loads.length; i++)
			{
				var im:Loader = new Loader();
				im.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
				im.load ( new URLRequest (loads[i]) );
				nload++;
			}
			loads = null;
			
		}
		private function loadComplete(e:Event):void
		{
			if (e.target.content is Bitmap)
			{
				var bleh:String = e.target.url;
			//	txt.appendText(bleh.substr(bleh.lastIndexOf("/")+1) + "\n");
				var obj:Object = new Object();
				obj.nom = bleh.substr(bleh.lastIndexOf("/")+1);
				obj.bmp = e.target.content.bitmapData;
				
				bitmaps.push(obj);
			}
			nload--;
			if (nload == 0) commencer();
		}
		private function commencer():void
		{
			//txt.appendText("go!\n");
			joueur = new Bitmap(getBmp("infiniro.png"));
			
			var rect:Rectangle = new Rectangle(0, 0, 800, 400);
			var pt:Point = new Point(0, 0);
			var filter:BlurFilter = new BlurFilter(6,0);
			
			backblur[0] = getBmp("fond.jpg");
			var i:int;
			for (i = 1; i <= 25; i++)
			{
				backblur[i] = backblur[i-1].clone();
				backblur[i].applyFilter(backblur[i], rect, pt, filter);
			}
			back = new Bitmap(backblur[0]);
			backk = new Bitmap(backblur[0]);
			
			backk.x = 800;
			addChild(back);
			addChild(backk);

			
			addChild(terrain);
			var front:Shape = new Shape();
			front.graphics.beginFill(0x000000);
			front.graphics.drawRect(-800,0,800,400);
			front.graphics.drawRect(800,0,800,400);
			
			addChild(front);
			
			var txtformat:TextFormat = new TextFormat();
			txtformat.size = 18;
			txtformat.color = 0xFFFFFF;
			txt.defaultTextFormat = txtformat;
			txt.selectable = false;
			txt.autoSize = TextFieldAutoSize.LEFT;
			txtcombo.selectable = false;
			txtcombo.autoSize = TextFieldAutoSize.LEFT;
			addChild(txt);
			addChild(txtcombo);
			txt.height = 400;
			terrain.addChild(speeds);
			terrain.addChild(mines);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			timer = new Timer(1,1);
			timer.addEventListener(TimerEvent.TIMER, actualiser);

			avantlance();
		}
        private function mouseMoveHandler(event:MouseEvent):void {
			sourisY = event.stageY;
        }    
		private function actualiser(e:TimerEvent):void
		{
			while (getTimer() - tik >= 20) // 50 FPS
			{
				tik += 20;
				var i:int;
				var hit:Boolean;
				/*
				if (bas)
				{
					if (joueurVY > 6) joueurVY = 6;
					else joueurVY += 1;
				}
				else if (haut)
				{
					if (joueurVY < -6) joueurVY = -6;
					else joueurVY -= 1;
				}
				else
				{
					if (joueurVY > 0)
					{
						if (joueurVY < 0.5) joueurVY = 0;
						else joueurVY -= 0.5;
					}
					else
					{
						if (joueurVY > -0.5) joueurVY = 0;
						else joueurVY += 0.5;
					}
				}
				*/
				joueurY = joueurY - (joueurY - sourisY)/2;
				if (joueurY > 400-joueur.height) joueurY = 400-joueur.height;
				if (speedx - 800 < parcouru + joueurX)
				{
					
					speedy += (bruit()*2-1)*200;
					
					
					if (speedy < 0) speedy = -speedy;
					if (speedy > 380) speedy = -speedy +380*2;
					speedx += 80;
					if (parcouru > 0 && bruit() < 0.4)
					{
						var miney:Number = (bruit())*380;
						while (Math.abs(miney - speedy) < 100)
						{
							miney = (bruit())*380;
						}
						if (miney < 0) miney = -miney;
						if (miney > 380) miney = -miney +380*2;
						var m:Bitmap = new Bitmap(getBmp("mine.png"))
						m.x = speedx+(bruit()*2-1)*10-parcouru;
						m.y = miney;
						mines.addChild(m);
					}
					var s:Bitmap = new Bitmap(getBmp("speed.png"))
					s.y = speedy;
					s.x = speedx+(bruit()*2-1)*10-parcouru;
					speeds.addChild(s);
				}
				
				hit = false;
				i = 0;
				while (hit == false && i < speeds.numChildren)
				{
					hit = true;
					var d:DisplayObject = speeds.getChildAt(i);
					if (joueurX + joueur.width <= d.x) {
						hit = false;
					}
					else if (joueurY + joueur.height <= d.y) {
						hit = false;
					}
					else if (d.x + d.width <= joueurX) {
						hit = false;
					}
					else if (d.y + d.height <= joueurY) {
						hit = false;
					}
					else
					{
						speeds.removeChildAt(i);
						sndspeed.play();
						if (joueurVX > 0)
						{
							combo++;
							if (combo > 4)
							{
								txtcomboformat.size = 20 + int(combo/2);
								txtcomboformat.color = 0xFFFF00;
								txtcombo.defaultTextFormat = txtcomboformat;
								txtcombo.text = "Combo : " + combo;
								txtcombo.x = 400-txtcombo.width/2;
							}
							
						}
						else
						{
							if (combo > maxcombo) maxcombo = combo;
							comboscore += int(Math.pow(combo,1.5)/2);
							combo = 0;
							txtcombo.text = "";
						}
						if (joueurVX < 0) joueurVX = 0;
						if (joueurVX <= 20) joueurAX = 2.4-joueurVX/10;
						else joueurAX = 0.4;
						
						
					}
					if (d.x < 0) speeds.removeChildAt(i);
					i++;
				}
				i = 0;
				hit = false;
				while (hit == false && i < mines.numChildren)
				{
					hit = true;
					d = mines.getChildAt(i);
					if (joueurX + joueur.width <= d.x) {
						hit = false;
					}
					else if (joueurY + joueur.height <= d.y) {
						hit = false;
					}
					else if (d.x + d.width <= joueurX) {
						hit = false;
					}
					else if (d.y + d.height <= joueurY) {
						hit = false;
					}
					else
					{
						dogameover = true;
					}
					if (d.x < 0) mines.removeChildAt(i);
					i++;
				}
				//joueurVX -= 0.2;
				
				joueurAX -= 0.2;
				if (joueurAX < -0.2) joueurAX = -0.2;
				joueurVX += joueurAX;
				joueurY += joueurVY;
				joueurX += joueurVX;
				var inc:int = 0;
				while (joueurX > 400)
				{
					for (i = 0; i < speeds.numChildren ; i++)
					{
						speeds.getChildAt(i).x -= 1;
					}
					for (i = 0; i < mines.numChildren ; i++)
					{
						mines.getChildAt(i).x -= 1;
					}
					joueurX -= 1;
					parcouru += 1;
					back.x -= 1;
					backk.x -= 1;
					if (backk.x < 0)
					{
						back.x += 800;
						backk.x += 800;
					}
					inc++;
				}
				//var ox:int = back.x;
				//inc = int(inc/2);
				if (inc <= 25)
				{
					back.bitmapData = backblur[inc];
					backk.bitmapData = backblur[inc];
				}
				else
				{
					back.bitmapData = backblur[25];
					backk.bitmapData = backblur[25];
				}
				//back.x = ox;
				//backk.x = ox+800;
				var score:int = int((parcouru + joueurX)/100 + comboscore);
				if (score > high) high = score;
				
				if (joueurVX > maxspeed) maxspeed = int(joueurVX);
				var avgspeed:int = int((parcouru + joueurX)/((getTimer()-timeStart)/200));
				
				
				
				if (joueurX < 0) dogameover = true;
				
			}
			timer.reset();
			timer.delay = tik + 20 - getTimer();
			timer.start();
			txt.text = "";
			txt.appendText("High Score : " + high);
			txt.appendText("\n");
			txt.appendText("Score : " + score);
			txt.appendText("\n");
			txt.appendText("Max Combo : " + maxcombo);
			txt.appendText("\n");
			txt.appendText("Avg Speed : " + avgspeed);
			joueur.y = int(joueurY);
			joueur.x = int(joueurX);
			if (dogameover)
			{
				dogameover = false;
				gameover();
			}
			e.updateAfterEvent();
		}
		private function gameover():void
		{
			timer.stop();
			sndboom.play();
			removeChild(joueur);
			timeEnd = getTimer();
			sendscoreshown = true;
			var txtformat:TextFormat = new TextFormat();
			txtformat.color = 0xFFFFFF;
			txtnick.defaultTextFormat = txtformat;
			txtnick.text = "Nick :";
			txtnick.selectable = false;
			txtnick.x = 200;
			txtnick.y = 50;
			txtnick.height = 24;
			
			txtsend.defaultTextFormat = txtformat;
			txtsend.text = "Send Score :";
			txtsend.selectable = false;
			txtsend.x = 440;
			txtsend.y = 50;
			txtsend.height = 24;
			
			editnick.type = TextFieldType.INPUT;
			editnick.restrict = "a-zA-Z0-9"
			editnick.maxChars = 12;
			editnick.width = 200;
			editnick.height = 32;
			editnick.x = 200;
			editnick.y = 80;
			editnick.background = true;
			editnick.backgroundColor = 0xFFFFFF;
			var btn:Shape = new Shape();
			btn.graphics.beginFill(0x808080);
			btn.graphics.drawRect(0,0,80,40);
			btn.graphics.endFill();
			sendbutton.downState = btn;
			sendbutton.overState = btn;
			sendbutton.upState = btn;
			sendbutton.hitTestState = btn;
			sendbutton.useHandCursor = true;
			sendbutton.enabled = true;
			sendbutton.x = 440;
			sendbutton.y = 80;
			
			addChild(editnick);
			addChild(txtnick);
			addChild(txtsend);
			addChild(sendbutton);
			
			
			sendbutton.addEventListener(MouseEvent.CLICK, sendscore);
			
			
			combo = 0;
			lance = false;
			txtcombo.text = "";
			
			while (speeds.numChildren > 0)
			{
				speeds.removeChildAt(0);
			}
			while (mines.numChildren > 0)
			{
				mines.removeChildAt(0);
			}
			
			
			avantlance();
			
		
		}
		private function sendscore(e:MouseEvent):void
		{
			if (sendbutton.enabled)
			{
				sendbutton.enabled = false;
				var req:URLRequest = new URLRequest("sendscore.php");
				req.method = URLRequestMethod.POST;
				var reqvars:URLVariables = new URLVariables();
				reqvars.nick = editnick.text;
				reqvars.score = int((parcouru + joueurX)/100 + comboscore);
				reqvars.speed = int((parcouru + joueurX)/((timeEnd-timeStart)/200));
				reqvars.combo = maxcombo;
				reqvars.k = MD5.hash("Don't cheat please" + reqvars.nick + reqvars.score + reqvars.speed + reqvars.combo);
				req.data = reqvars;
			
				var loader:URLLoader = new URLLoader();
				loader.load(req);
			}
		}
		private function removesendscore():void
		{
			if (sendscoreshown)
			{
				sendscoreshown = false;
				removeChild(editnick);
				removeChild(sendbutton);
				removeChild(txtnick);
				removeChild(txtsend);
			}
		}
		private function viewscore(e:MouseEvent):void
		{
			txtlance.y = 400-txtlance.height;
			var loader:URLLoader = new URLLoader();
			loader.load(new URLRequest("showscore.php?flash=yes"));
			//loader.load(new URLRequest("test.txt"));
			loader.addEventListener(Event.COMPLETE, scoreloaded);
		}
		private function scoreloaded(e:Event):void
		{
			var loader:URLLoader = URLLoader(e.target);
			highscoresshown = true;
			removesendscore();
			addChild(highscores);
			while (highscores.numChildren > 0)
			{
				highscores.removeChildAt(0);
			}
			
			
			var txtformat:TextFormat = new TextFormat();
			txtformat.size = 18;
			
			var header:Array = new Array("Nick","Score","Avg Speed","Max Combo");
			var l:int = -1;
			var c:int = 0;
			var lignes:Array = loader.data.split(";");
			var hs:TextField;
			while (l < lignes.length)
			{
				c = 0;
				if (l == -1)
				{
					txtformat.color = 0x0000FF;
					while (c < header.length)
					{
						hs = new TextField();
						hs.defaultTextFormat = txtformat;
						hs.selectable = false;
						hs.autoSize = TextFieldAutoSize.LEFT;
						hs.text = header[c];
						hs.y = 20+20*l;
						hs.x = 200+120*c;
						highscores.addChild(hs);
						c++;
					}
				}
				else
				{
					txtformat.color = 0xFFFFFF;
					var champs:Array = lignes[l].split(",");
					while (c < champs.length)
					{
						hs = new TextField();
						hs.defaultTextFormat = txtformat;
						hs.selectable = false;
						hs.autoSize = TextFieldAutoSize.LEFT;
						hs.text = champs[c];
						hs.y = 20+20*l;
						hs.x = 200+120*c;
						highscores.addChild(hs);
						c++;
					}
				}
				
				l++;
			}
			
		
		}
		private function avantlance():void
		{
			addChild(txtlance);
			
			txtlance.y = 180;
			var txtformat:TextFormat = new TextFormat();
			txtformat.size = 24;
			txtformat.color = 0xFFFFFF;
			txtlance.defaultTextFormat = txtformat;
			txtlance.text = "Press the SPACE key to start";
			txtlance.selectable = false;
			txtlance.autoSize = TextFieldAutoSize.LEFT;
			txtlance.x = 400-int(txtlance.width/2);
			
			txthighscore.text = "High Scores";
			txthighscore.selectable = false;
			txthighscore.autoSize = TextFieldAutoSize.LEFT;
			txtformat.color = 0x0000FF;
			txthighscore.defaultTextFormat = txtformat;
			txthighscore.y = 400-txthighscore.height;
			txthighscore.addEventListener(MouseEvent.CLICK, viewscore);
			addChild(txthighscore);
			
			
			Mouse.show();
			
		}
		private function lancer():void
		{
			removesendscore();
			if (highscoresshown)
			{
				highscoresshown = false;
				removeChild(highscores);
			}
			removeChild(txthighscore);
			dejajoue = true;
			removeChild(txtlance);
			comboscore = 0;
			parcouru = 0;
			maxcombo = 0;
			maxspeed = 0;
			lance = true;
			joueurX = 0;
			joueurX = 0;
			joueurY = 200;
			joueurVX = 0;
			joueurAX = 2.4;
			joueurVY = 0;
			speedx = 0;
			speedy = 200;
			seed = int(Math.random()*100000)+100;
			tik = getTimer()-20;
			timeStart = getTimer();
			Mouse.hide();
			addChild(joueur);
			
			timer.start();
		}
		private function getBmp(nom:String):BitmapData
		{
			var i:int = 0;
			while (i < bitmaps.length && bitmaps[i].nom != nom)
			{
				i++;
			}
			if (i < bitmaps.length) return bitmaps[i].bmp;
			else return null;
		}
		private function bruit():Number
		{
			seed++;
			return ((seed*(seed*seed*15731+789221)+1376312589)&0x7fffffff)/0x7fffffff; // retourne un nombre pseudo-aléatoire entre 0 et 1
		}
		private function keyDownHandler(e:KeyboardEvent):void
		{
			if (e.keyCode == 32) 
			{
				if (!espace && !lance) lancer();
				espace = true;
			}
			if (e.keyCode == 38) haut = true;
			if (e.keyCode == 40) bas = true;

		}
		private function keyUpHandler(e:KeyboardEvent):void
		{
			if (e.keyCode == 32) espace = false;
			if (e.keyCode == 38) haut = false;
			if (e.keyCode == 40) bas = false;
		}
	}
}