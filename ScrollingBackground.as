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
         var _bg:Image = null;
         super();
         images = [];
         for(var i:int = 0; i < 4; i++)
         {
            _bg = new Image(Root.assets.getTexture("bg0" + (i + 1).toString()));
            _bg.x = i * 1024;
            _bg.blendMode = "none";
            if(Globals.scaleFactor == 2 || Globals.scaleFactor == 1)
               _bg.scaleX = 1;
            else
               _bg.scaleX = 1.01;
            images.push(_bg);
            addChild(_bg);
         }
      }
      
      public function setX(_x:Number) : void
      {
         this.x = _x;
         for each(var _image:Image in images)
         {
            _image.visible = false;
            if(-_x > _image.x - 1024 && -_x < _image.x + 1024)
               _image.visible = true;
         }
      }
      
      public function scrollTo(_x:Number, _tweenTime:Number = 2) : void
      {
         Starling.juggler.removeTweens(this);
         Starling.juggler.tween(this,_tweenTime,{
            "x":_x,
            "transition":"easeOut",
            "onStart":scrollUpdate,
            "onUpdate":scrollUpdate,
            "onComplete":scrollUpdate
         });
      }
      
      public function scrollUpdate() : void
      {
         for each( var _image:Image in images)
         {
            _image.visible = false;
            if(-x > _image.x - 1024 && -x < _image.x + 1024)
               _image.visible = true;
         }
      }
      
      public function updateSaturation() : void
      {
      }
   }
}
