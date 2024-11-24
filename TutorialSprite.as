package Game
{
   import starling.animation.DelayedCall;
   import starling.core.Starling;
   import starling.display.Image;
   import starling.display.Sprite;
   
   public class TutorialSprite extends Sprite
   {
      public var game:GameScene;
      public var arrow:Image;
      public var loop:DelayedCall;
      
      public function TutorialSprite()
      {
         super();
         arrow = new Image(Root.assets.getTexture("tutorial_arrow"));
         arrow.pivotX = arrow.width;
         arrow.pivotY = arrow.height * 0.5;
         arrow.visible = false;
         arrow.alpha = 0;
         arrow.blendMode = "add";
         arrow.scaleY = 0.8;
         arrow.scaleX = 0.8;
         arrow.color = 16755370;
      }
      
      public function init(_game:GameScene) : void
      {
         this.game = _game;
         arrow.visible = true;
         arrow.alpha = 0;
         _game.uiLayer.addChild(arrow);
         show();
      }
      
      public function deInit() : void
      {
         if(!game)
            return;
         game.uiLayer.removeChild(arrow);
         Starling.juggler.removeTweens(arrow);
         if(loop)
            Starling.juggler.remove(loop);
         loop = null;
         arrow.visible = false;
         arrow.alpha = 0;
      }
      
      public function show() : void
      {
         var _x:Number = NaN;
         var _y:Number = NaN;
         var _NodeArray:Array = game.nodes.active;
         if(game.triggers[0])
            return;
         if(!Globals.touchControls)
            return;
         switch(Globals.level)
         {
            case 0:
               arrow.rotation = -1.5707963267948966;
               arrow.x = _NodeArray[0].x;
               arrow.y = _NodeArray[0].y + 60;
               Starling.juggler.tween(arrow,1,{
                  "alpha":0.8,
                  "y":_NodeArray[0].y + 30,
                  "delay":1,
                  "transition":"easeOut"
               });
               Starling.juggler.tween(arrow,2,{
                  "x":_NodeArray[1].x,
                  "y":_NodeArray[1].y + 10,
                  "delay":2,
                  "transition":"easeInOut"
               });
               Starling.juggler.tween(arrow,1,{
                  "y":_NodeArray[1].y + 40,
                  "alpha":0,
                  "delay":4,
                  "transition":"easeIn"
               });
               loop = Starling.juggler.delayCall(show,6);
               break;
            case 1:
               _x = 512 + game.ui.fleetSlider.touchWidth * 0.5 - game.ui.fleetSlider.boxWidth * 0.5;
               _y = game.ui.fleetSlider.y - 10;
               arrow.rotation = 1.5707963267948966;
               arrow.x = _x;
               arrow.y = _y - 20;
               Starling.juggler.tween(arrow,1,{
                  "alpha":0.8,
                  "y":_y,
                  "delay":1,
                  "transition":"easeOut"
               });
               Starling.juggler.tween(arrow,2,{
                  "x":512,
                  "delay":2,
                  "transition":"easeInOut"
               });
               Starling.juggler.tween(arrow,1,{
                  "y":_y - 20,
                  "alpha":0,
                  "delay":4,
                  "transition":"easeIn"
               });
               loop = Starling.juggler.delayCall(show,6);
         }
      }
      
      public function update(_dt:Number) : void
      {
      }
   }
}
