//提供滚动背景的相关类方法

package
{
   import starling.core.Starling;
   import starling.display.Image;
   import starling.display.Sprite;
   
   public class ScrollingBackground extends Sprite
   {
       
      
      public var images:Array;
      
      public function ScrollingBackground()//构造函数
      {
         var _loc2_:int = 0;
         var _loc1_:Image = null;
         super();
         images = [];
         _loc2_ = 0;
         while(_loc2_ < 4)
         {
            _loc1_ = new Image(Root.assets.getTexture("bg0" + (_loc2_ + 1).toString()));
            _loc1_.x = _loc2_ * 1024;
            _loc1_.blendMode = "none";
            if(Globals.scaleFactor == 2 || Globals.scaleFactor == 1)
            {
               _loc1_.scaleX = 1;
            }
            else
            {
               _loc1_.scaleX = 1.01;
            }
            images.push(_loc1_);
            addChild(_loc1_);
            _loc2_++;
         }
      }
      
      public function setX(param1:Number) : void
      {
         var _loc5_:int = 0;
         var _loc3_:Image = null;
         this.x = param1;
         var _loc4_:int = int(images.length);
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_ = images[_loc5_];
            _loc3_.visible = false;
            if(-param1 > _loc3_.x - 1024 && -param1 < _loc3_.x + 1024)
            {
               _loc3_.visible = true;
            }
            _loc5_++;
         }
      }
      
      public function scrollTo(param1:Number, param2:Number = 2) : void
      {
         Starling.juggler.removeTweens(this);
         Starling.juggler.tween(this,param2,{
            "x":param1,
            "transition":"easeOut",
            "onStart":scrollUpdate,
            "onUpdate":scrollUpdate,
            "onComplete":scrollUpdate
         });
      }
      
      public function scrollUpdate() : void
      {
         var _loc4_:int = 0;
         var _loc2_:Image = null;
         var _loc3_:int = int(images.length);
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = images[_loc4_];
            _loc2_.visible = false;
            if(-x > _loc2_.x - 1024 && -x < _loc2_.x + 1024)
            {
               _loc2_.visible = true;
            }
            _loc4_++;
         }
      }
      
      public function updateSaturation() : void
      {
      }
   }
}
