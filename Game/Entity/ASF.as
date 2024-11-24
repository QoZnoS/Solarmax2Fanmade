package Game.Entity
{
   import Game.GameScene;
   import starling.display.Image;

   public class ASF extends GameEntity
   {

      public var image:Image;

      public function ASF()
      {
         super();
         image = new Image(Root.assets.getTexture("barrier_line"));
      }

      public function initASF(_GameScene:GameScene):void
      {
         super.init(_GameScene);
      }

      override public function update(dt:Number):void
      {
      }

      override public function deInit():void
      {
      }
   }
}
