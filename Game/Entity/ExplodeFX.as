package Game.Entity
{
   import Game.GameScene;
   import starling.display.Image;
   
   public class ExplodeFX extends GameEntity
   {
      
      public static const STATE_GROW:int = 0;
      
      public static const STATE_SHRINK:int = 1;
       
      
      public var x:Number;
      
      public var y:Number;
      
      public var size:Number;
      
      public var color:uint;
      
      public var image:Image;
      
      public var foreground:Boolean;
      
      public var state:int;
      
      public function ExplodeFX()
      {
         super();
         image = new Image(Root.assets.getTexture("ship_pulse"));
         image.pivotX = image.pivotY = image.width * 0.5;
      }
      
      public function initExplosion(_GameScene:GameScene, _x:Number, _y:Number, _Color:uint, _foreground:Boolean) : void
      {
         super.init(_GameScene);
         this.x = _x;
         this.y = _y;
         this.color = _Color;
         this.foreground = _foreground;
         this.size = 0;
         image.x = _x;
         image.y = _y;
         image.color = _Color;
         image.scaleY = 0;
         image.scaleX = 0;
         image.alpha = 0.5;
         state = 0;
      }
      
      override public function deInit() : void
      {
      }
      
      override public function update(_dt:Number) : void
      {
         if(state == 0)
         {
            size += _dt;
            image.scaleX = image.scaleY = size;
            if(size >= 0.5)
               state = 1;
         }
         else
         {
            size += _dt;
            image.scaleX = image.scaleY = size;
            image.alpha -= _dt;
            if(image.alpha <= 0)
            {
               image.alpha = 0;
               active = false;
            }
         }
         if(image.color == 0)
         {
            if(foreground)
               game.shipsBatch2b.addImage(image);
            else
               game.shipsBatch1b.addImage(image);
         }
         else if(foreground)
            game.shipsBatch2.addImage(image);
         else
            game.shipsBatch1.addImage(image);
      }
   }
}
