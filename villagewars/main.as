package
{
	import flash.display.*;
	import fl.controls.Button;
	import fl.controls.TextInput;
	import fl.controls.DataGrid;
	
	import flash.utils.getTimer;

	import flash.errors.*;
	import flash.events.*;
	import flash.net.Socket;

	public class main extends Sprite
	{
		private var servers:DataGrid;
		private var bconnection:Button;
		private var brefresh:Button;
		private var sock:Socket;
		private var response:String;
		private var mode:int;
		private var irefresh:int;
		private var tping:int;
		
		function main():void
		{
			sock = new Socket();
sock.addEventListener( Event.CONNECT, clientConnecte ); 
sock.addEventListener( Event.CLOSE, clientDeconnecte ); 
sock.addEventListener( ProgressEvent.SOCKET_DATA, donneesRecues );
sock.addEventListener( IOErrorEvent.IO_ERROR, erreurConnexion ); 

			stage.align = StageAlign.TOP_LEFT; 
			stage.scaleMode = StageScaleMode.NO_SCALE;


			// Initialisation du Trace
			//Trace.initialiser(stage);
			//Trace.append("Village War is starting...");

			 
			servers = new DataGrid();
			addChild(servers);
			servers.move(50,50);
			servers.addColumn("Nom");
			servers.addColumn("IP");
			servers.addColumn("Port");
			servers.addColumn("Ping");
			servers.addColumn("Joueurs");
			servers.width = 500;
			servers.height = 200;
			servers.addItem({Nom:"Robi serveur perso", IP:"robiserver.ath.cx", Port:"4242"});
			servers.addItem({Nom:"serveur bidon", IP:"bipepetsrt.ath.cx", Port:"4242"});
			bconnection = new Button();
			addChild(bconnection); 
			bconnection.label="Connexion";
			bconnection.move(250,300);
			brefresh = new Button(); 
			addChild(brefresh); 
			brefresh.label="Rafraichir";
			brefresh.move(100,300);

				 bconnection.addEventListener(MouseEvent.CLICK,connection);
brefresh.addEventListener(MouseEvent.CLICK,refresh);

			
			var i:int;
			var id:int = 1;
			var plateau:Sprite = new Sprite();
			addChild(plateau);

			var tiles:Sprite = new Sprite();
			plateau.addChild(tiles);
			
			
			var tilesM:Array = new Array();
			
			// Génération du perlinNoise
			var perlin:BitmapData = new BitmapData(61, 61, false, 0x00000000);
			perlin.perlinNoise(8,8,8,1337,false,true,4)

			// Création des tiles correspondantes
			var ttype:int = 0;
			var coeff:Number = 0.5;
			/*
			for (var by:int = -10 ; by <= 10 ; by++)
			{
				tilesM[by] = new Array();
				for(var bx:int = -10 ; bx <= 10 ; bx++)
				{
					var p:uint = perlin.getPixel(bx+30,by+30);
					if (p < 33*2.55) ttype = 1;
					else if (p < 66*2.55) ttype = 2;
					else ttype = 3;
					var tile:Tile = new Tile(tiles,bx,by,ttype);
					tilesM[by][bx] = p;
				}
			}
			perlin = null;
			
			
			var map:Sprite = new Sprite();
			tiles.addChild(map);
			
			

			
			var ok:int;
			var ox:int;
			var oy:int;
			for (i = 0 ; i < 400 ; i++)
			{
				ok = 0;
				while (ok == 0)
				{
					ox = Math.floor((Math.random()-0.5)*2*20);
					oy = Math.floor((Math.random()-0.5)*2*20);
					p = tilesM[oy][ox];
					if (p > 46*2.55 && p < 54*2.55) ok = 1;
				}
				var arbre:Objet = new Objet(map,id,ox*48,oy*48-48,1);
				id++;
			}
			for (i = 0 ; i < 20 ; i++)
			{
				ok = 0;
				while (ok == 0)
				{
					ox = Math.floor((Math.random()-0.5)*2*20);
					oy = Math.floor((Math.random()-0.5)*2*20);
					p = tilesM[oy][ox];
					if (p > 75*2.55) ok = 1;
				}
				var pierre:Objet = new Objet(map,id,ox*48,oy*48,2);
				id++;
			}
			
			//Trace.append("chargement fini");
			
			var Joueurs:Array = new Array();
			for (i = 0 ; i < 1 ; i++)
			{

				Joueur[i] = new Joueur(map,id,0,-48,stage);
				id++;

				
			}
			
*/
		}
		private function connection(e:MouseEvent)
		{
			if (servers.selectedItem)
			{
				bconnection.enabled = false;
				brefresh.enabled = false;
				sock.connect(servers.selectedItem.IP,servers.selectedItem.Port);
				mode = 1;
			}
		}
		private function refresh(e:MouseEvent)
		{
			mode = 2;
			irefresh = -1;
			callRefresh();
			brefresh.enabled = false;	
		}
		private function callRefresh()
		{
			
			if (irefresh+1 < servers.rowCount)
			{
				irefresh++;
				sock.connect(servers.getItemAt(irefresh).IP,servers.getItemAt(irefresh).Port);
				
			}
			else
			{
				brefresh.enabled = true;
				servers.sortItemsOn("Ping", Array.NUMERIC | Array.DESCENDING);
				 servers.drawNow();
			}


		}



		private function clientConnecte ( pEvt:Event ):void
		{
			if (mode == 1)
			{
				//bconnection.enabled = true;
			}
			else if (mode == 2)
			{
			trace("envoi ping");
				tping = getTimer();
				sock.writeByte(0);
				sock.flush();
			}
		}
		
		private function clientDeconnecte ( pEvt:Event ):void
		{
			trace("deconnecte");
			if (mode == 1)
			{
				bconnection.enabled = true;
			}
			else if (mode == 2)
			{
				callRefresh();
			}
		}
		
		private function erreurConnexion ( pEvt:Event ):void
		{
		trace("erreur de connexion au serveur");
			if (mode == 1)
			{
				bconnection.enabled = true;
			}
			else if (mode == 2)
			{
				callRefresh();
			}
			
		}
		
		private function donneesRecues ( pEvt:ProgressEvent ):void
		{
			var cmd:int = sock.readByte();
			trace("recu commande : "+cmd+" irefresh = "+irefresh+" ping : "+(getTimer() - tping));
			if (cmd == 0)
			{
			servers.getItemAt(0).Ping = 1337;
				 servers.getItemAt(irefresh).Ping = getTimer() - tping;
				
				trace("uu: "+cmd+" irefresh = "+irefresh);
				sock.close();
				callRefresh();
			}
		}
		   
	}
}
