// 已完工

package Game.Entity
{
   import Game.GameScene;
   import starling.display.Image;

   public class BarrierFX extends GameEntity
   {

      public var image:Image;

      public function BarrierFX()
      {
         super();
         image = new Image(Root.assets.getTexture("barrier_line"));
         image.pivotX = image.width * 0.5;
         image.pivotY = image.height * 0.5;
      }

      public function initBarrier(_GameScene:GameScene, _x:Number, _y:Number, _Angle:Number, _Color:uint):void
      {
         super.init(_GameScene);
         image.x = _x;
         image.y = _y;
         image.scaleY = 0.75;
         image.scaleX = 0.75;
         image.rotation = _Angle;
         image.color = _Color;
         _GameScene.fxLayer.addChild(image);
      }

      override public function deInit():void
      {
         game.fxLayer.removeChild(image);
      }
   }
}
