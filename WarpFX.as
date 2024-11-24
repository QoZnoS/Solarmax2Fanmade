package Game.Entity
{
   import Game.GameScene;
   import starling.display.Image;
   
   public class WarpFX extends GameEntity
   {
      
      public static const STATE_GROW:int = 0;
      
      public static const STATE_SHRINK:int = 1;
       
      public var x:Number;
      
      public var y:Number;
      
      public var prevX:Number;
      
      public var prevY:Number;
      
      public var size:Number;
      
      public var color:uint;
      
      public var image:Image;
      
      public var foreground:Boolean;
      
      public var state:int;
      
      public function WarpFX()
      {
         super();
         image = new Image(Root.assets.getTexture("warp_glare"));
         image.pivotX = image.width * 0.5;
         image.pivotY = image.height * 0.5;
      }
      
      public function initWarp(_GameScene:GameScene, _x:Number, _y:Number, _prevX:Number, _prevY:Number, _Color:uint, _foreground:Boolean) : void
      {
         super.init(_GameScene);
         this.x = _x;
         this.y = _y;
         this.prevX = _prevX;
         this.prevY = _prevY;
         this.color = _Color;
         this.foreground = _foreground;
         this.size = 0;
         image.x = _x;
         image.y = _y;
         image.color = _Color;
         image.scaleY = 0;
         image.scaleX = 0;
         image.alpha = 1;
         state = 0;
      }
      
      override public function deInit() : void
      {
      }
      
      override public function update(_dt:Number) : void
      {
         if(state == 0)
         {
            size += _dt * 8;
            if(size >= 1)
            {
               size = 1;
               state = 1;
            }
         }
         else
         {
            size -= _dt * 3;
            if(size <= 0)
            {
               size = 0;
               active = false;
            }
         }
         image.scaleX = image.scaleY = size;
         image.alpha = 1;
         var _dx:Number = prevX - x;
         var _dy:Number = prevY - y;
         var _angle:Number = Math.atan2(_dy,_dx);
         var _Distance:Number = Math.sqrt(_dx * _dx + _dy * _dy);
         image.rotation = 0;
         image.x = x + Math.cos(_angle) * _Distance * 0.5;
         image.y = y + Math.sin(_angle) * _Distance * 0.5;
         image.width = _Distance;
         image.scaleY *= 0.5;
         image.alpha = 0.25;
         image.rotation = _angle;
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
