package Game
{
   import flash.geom.Point;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Touch;
   import starling.events.TouchEvent;

   public class SpeedButton extends Sprite
   {
      public var quad:Quad;
      public var image:Image;
      public var down:Boolean;
      public var hitPoint:Point;
      public var buttonArray:Array;
      public var toggled:Boolean;

      public function SpeedButton(_Texture:String, _buttonArray:Array)
      {
         super();
         this.buttonArray = _buttonArray;
         image = new Image(Root.assets.getTexture(_Texture));
         image.color = 16755370;
         image.alpha = 0.3;
         addChild(image);
         quad = new Quad(image.width + 20, image.height + 20, 16711680);
         quad.x = -10;
         quad.y = -10;
         quad.alpha = 0;
         addChild(quad);
         hitPoint = new Point(0, 0);
         toggled = false;
      }

      public function setImage(_Texture:String, _scale:Number = 1):void
      {
         image.texture = Root.assets.getTexture(_Texture);
         image.readjustSize();
         image.width = image.texture.width;
         image.height = image.texture.height;
         image.scaleX = image.scaleY = _scale;
         image.alpha = 0.3;
         quad.width = image.width + 20;
         quad.height = image.height + 20;
         quad.x = -10;
         quad.y = -10;
         quad.alpha = 0;
      }

      public function init():void
      {
         toggled = false;
         image.alpha = 0.3;
         addEventListener("touch", on_touch);
      }

      public function deInit():void
      {
         removeEventListener("touch", on_touch);
      }

      public function on_touch(_touchEvent:TouchEvent):void
      {
         var _Touch:Touch = _touchEvent.getTouch(this);
         if (!_Touch)
            return;
         switch (_Touch.phase)
         {
            case "began":
               image.alpha = 0.8;
               down = true;
               break;
            case "moved":
               if (down && !hitTest(_Touch.getLocation(this, hitPoint)))
               {
                  image.alpha = 0.3;
                  down = false;
               }
               break;
            case "ended":
               if (down)
               {
                  toggled = true;
                  image.alpha = 0.8;
                  for each (var _SpeedBtn:SpeedButton in buttonArray)
                  {
                     if (_SpeedBtn == this)
                        continue;
                     _SpeedBtn.image.alpha = 0.3;
                     _SpeedBtn.toggled = false;
                  }
                  down = false;
                  GS.playClick();
                  break;
               }
         }
      }
   }
}
