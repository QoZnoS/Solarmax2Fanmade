//动画系统废案，谁爱做谁做去

package Game.Entity
{
   import Game.GameScene;
   import starling.display.Image;

   public class ASE extends GameEntity
   {

      private var image:Image;
      private var image_id:String;
      private var animate_id:String;
      private var static:int;
      private var team:int;

      public function ASE()
      {
         super();
         image = new Image(Root.assets.getTexture("halo"));
      }

      public function initASE(_GameScene:GameScene,_Anid:String,_x:Number,_y:Number,_team:int):void
      {
         super.init(_GameScene);
         this.anid = _Anid;
      }

      override public function update(dt:Number):void
      {
      }

      override public function deInit():void
      {
      }
   }
}
