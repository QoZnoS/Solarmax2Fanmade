// type 0为扩散式 1为收缩式
package Game.Entity
{
   import Game.GameScene;
   
   public class SelectFade extends GameEntity
   {
      
      public static const TYPE_GROW:int = 0;
      
      public static const TYPE_SHRINK:int = 1;
       
      
      public var x:Number;
      
      public var y:Number;
      
      public var size:Number;
      
      public var alpha:Number;
      
      public var color:uint;
      
      public var type:int;
      
      public function SelectFade()
      {
         super();
      }
      
      public function initSelectFade(_GameScene:GameScene, _x:Number, _y:Number, _size:Number, _Color:uint, _type:int) : void
      {
         super.init(_GameScene);
         this.x = _x;
         this.y = _y;
         this.color = _Color;
         this.size = _size;
         this.type = _type;
         alpha = 1;
      }
      
      override public function deInit() : void
      {
      }
      
      override public function update(_dt:Number) : void
      {
         if(type == 0)
            size += _dt * 0.2;
         else
            size -= _dt * 0.2;
         alpha -= _dt * 4;
         if(alpha <= 0)
         {
            alpha = 0;
            active = false;
         }
      }
   }
}
