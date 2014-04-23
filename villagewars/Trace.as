/*TRACE - Neamar - 2009
La classe Trace fait partie du package Utilitaires dans mes applications.
Il s'agit d'une classe statique permettant l'affichage d'informations de façon simple, depuis n'importe quelle classe.

Comment l'utiliser ? Depuis votre classe principale, initialiser la classe à l'aide de cette instruction :
Trace.initialiser(this.stage);
qui indique à Trace sur quel stage elle doit afficher les données.

Ensuite, vous pouvez appeler Trace.append() avec un nombre illimité de paramètres de type quelconques.
Exemple :
Trace.append(monTableau.length,new BlurFilter(),"Bonjour")
renverra
"Bonjour"
[object BlurFilter]
2

(les paramètres les plus anciens sont en bas.)
*/

package
{
        import flash.display.Sprite;
        import flash.display.Stage;
        import flash.text.TextField;//Champ de texte. Classe assez vaste, utilisée uniquement pour l'affichage de texte ici. Peut être du texte au format HTML.
        import flash.events.Event;
        import flash.events.MouseEvent;


        public class Trace extends Sprite
        {
                private static var _stage:Stage;
                private static var Container:Sprite = new Sprite();//Le conteneur principal
                        Container.addEventListener(MouseEvent.MOUSE_DOWN, StartDrag);
                        Container.scaleX=1;
                        Container.scaleY=1;
                        Container.alpha=1;

                private static var Texte:TextField=new TextField();
                        Texte.x = 5;
                        Texte.y = 5;
                        Texte.autoSize = "left";
                        Container.addChild(Texte);

                private static var Reduire:Sprite = new Sprite();
                        Reduire.graphics.beginFill(0xFFFFFF,1);
                        Reduire.graphics.drawRect(0,0,10,10);
                        Reduire.addEventListener(MouseEvent.MOUSE_UP, Delete);
                        Container.addChild(Reduire);

                private static var LastTrace:String="";

                public function Trace()
                {//Constructeur non utilisé.
                }

                public static function initialiser(vstage:Stage):void
                {
                        _stage=vstage;
                        _stage.addChild(Container);
                }
                public static function append(... Parametres):void
                {//La fonction principale, qui trace le texte passé en paramètre.
                        for each(var Parametre:* in Parametres)
                        {
                                if(Parametre!=null)
                                        Texte.text = Parametre.toString() + "\r" + Texte.text;//\r indique un retour à la ligne.
                                else
                                        Texte.text = "null\r" + Texte.text;//\r indique un retour à la ligne.
                        }

                        if(_stage)//Seulement si initialisé.
                                _stage.setChildIndex(Container,_stage.numChildren-1);
                        else
                                throw new Error("La classe Trace doit être initialisée avant d'appeler la méthode append");
                }

                public static function clear():void
                {//Efface le contenu du Trace.
                        Texte.text="";
                        LastTrace="";
                }

                //Les fonctions pour déplacer
                public static function set draggable(v:Boolean):void
                {
                        if(v)
                                Container.addEventListener(MouseEvent.MOUSE_DOWN, StartDrag);
                        else
                                Container.removeEventListener(MouseEvent.MOUSE_DOWN, StartDrag);
                }
                private static function StartDrag(e:Event):void
                {
                        Container.startDrag();
                        Container.addEventListener(MouseEvent.MOUSE_UP, StopDrag);
                        Container.removeEventListener(MouseEvent.MOUSE_DOWN, StartDrag);
                        Texte.selectable=false;
                }
                private static function StopDrag(e:Event):void
                {
                        Container.stopDrag();
                        Container.removeEventListener(MouseEvent.MOUSE_UP, StopDrag);
                        Container.addEventListener(MouseEvent.MOUSE_DOWN, StartDrag);
                        Texte.selectable=true;
                }

                //Et pour supprimer la boite :
                private static function Delete(e:Event):void
                {
                        Container.visible=false;
                        Reduire.removeEventListener(MouseEvent.MOUSE_UP, Delete);
                        Container.removeEventListener(MouseEvent.MOUSE_DOWN, StartDrag);
                        Container.removeEventListener(MouseEvent.MOUSE_UP, StopDrag);
                        Container=null;
                        Texte=null;
                }
        }
}