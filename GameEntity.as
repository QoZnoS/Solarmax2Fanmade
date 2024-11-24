//这个文件不需要修改，甚至不需要关注

package Game.Entity
{
   import Game.GameScene;
   
   public class GameEntity
   {
       
      
      public var game:GameScene;
      
      public var active:Boolean;
      
      public function GameEntity()//构造函数
      {
         super();
      }
      
      public function init(_GameScene:GameScene) : void
      {
         this.game = _GameScene;
         active = true;
      }
      
      public function deInit() : void
      {
      }
      
      public function update(_dt:Number) : void
      {
      }
   }
}
