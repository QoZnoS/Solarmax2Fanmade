// 已完工

package Game.Entity
{
   import Game.GameScene;
   import starling.display.Image;

   public class BeamFX extends GameEntity
   {

      public static const STATE_GROW:int = 0;

      public static const STATE_SHRINK:int = 1;

      public var x:Number;

      public var y:Number;

      public var size:Number;

      public var angle:Number;

      public var color:uint;

      public var image:Image; // 这是射线

      public var image2:Image; // 这是攻击塔的特效

      public var foreground:Boolean;

      public var type:int;

      public var state:int;

      public function BeamFX()
      {
         super();
         image = new Image(Root.assets.getTexture("quad_16x4glow"));
         image.pivotY = image.height * 0.5;
         image.adjustVertices();
         image2 = new Image(Root.assets.getTexture("tower_shape"));
         image2.pivotX = image2.pivotY = image2.width * 0.5;
         foreground = true;
      }

      public function initBeam(_GameScene:GameScene, _x1:Number, _y1:Number, _x2:Number, _y2:Number, _Color:uint, _type:int):void
      {
         super.init(_GameScene);
         this.x = _x1;
         this.y = _y1;
         this.color = _Color;
         this.size = 0;
         var _dx:Number = _x2 - _x1;
         var _dy:Number = _y2 - _y1;
         var _Distance:Number = Math.sqrt(_dx * _dx + _dy * _dy);
         angle = Math.atan2(_dy, _dx);
         image.rotation = 0;
         image.x = x;
         image.y = y;
         image.width = _Distance;
         image.color = _Color;
         image.scaleY = 1;
         image.alpha = 0.75;
         image2.x = x;
         image2.y = y;
         image2.color = _Color;
         this.type = _type;
         state = 0;
         switch (_type) // 添加攻击塔特效贴图
         {
            case 4:
               image2.texture = Root.assets.getTexture("tower_shape");
               image2.scaleX = image2.scaleY = 0;
               image2.alpha = 1;
               break;
            case 6:
               image2.texture = Root.assets.getTexture("starbase_laser");
               image2.scaleX = image2.scaleY = 1;
               image2.alpha = 0;
               break;
            default:
               return;
         }
      }

      override public function deInit():void
      {
      }

      override public function update(_dt:Number):void
      {
         image.rotation = 0;
         if (state == 0)
         {
            size += _dt * 20;
            if (size >= 1)
            {
               size = 1;
               state = 1;
            }
         }
         else
         {
            size -= _dt * 10;
            if (size <= 0)
            {
               size = 0;
               active = false;
            }
         }
         image.alpha = image2.alpha = size;
         image.scaleY = size * 0.5;
         switch (type)
         {
            case 4:
               image2.scaleX = image2.scaleY = size;
               break;
            case 6:
               image2.alpha = size;
               break;
         }
         image.rotation = angle;
         if (image.color == 0)
         {
            if (foreground)
               game.shipsBatch2b.addImage(image);
            else
               game.shipsBatch1b.addImage(image);
         }
         else if (foreground)
         {
            game.shipsBatch2.addImage(image);
            game.shipsBatch2.addImage(image2);
         }
         else
         {
            game.shipsBatch1.addImage(image);
            game.shipsBatch1.addImage(image2);
         }
      }
   }
}
