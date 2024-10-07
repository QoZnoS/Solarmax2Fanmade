package Menus
{
   import flash.geom.Point;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Touch;
   import starling.events.TouchEvent;

   public class MenuButton extends Sprite
   {
      public var quad:Quad;
      public var image:Image;
      public var down:Boolean;
      public var hitPoint:Point;

      public function MenuButton(_texture:String)
      {
         super();
         image = new Image(Root.assets.getTexture(_texture));
         image.color = 16755370;
         image.alpha = 0.3;
         addChild(image);
         quad = new Quad(image.width + 20, image.height + 20, 16711680);
         quad.x = -10;
         quad.y = -10;
         quad.alpha = 0;
         addChild(quad);
         hitPoint = new Point(0, 0);
      }

      public function setImage(_texture:String, _size:Number = 1):void
      {
         image.texture = Root.assets.getTexture(_texture);
         image.readjustSize();
         image.width = image.texture.width;
         image.height = image.texture.height;
         image.scaleX = image.scaleY = _size;
         image.alpha = 0.3;
         quad.width = image.width + 20;
         quad.height = image.height + 20;
         quad.x = -10;
         quad.y = -10;
         quad.alpha = 0;
      }

      public function init():void
      {
         image.alpha = 0.3;
         addEventListener("touch", on_touch);
      }

      public function deInit():void
      {
         removeEventListener("touch", on_touch);
      }

      public function on_touch(_touchEvent:TouchEvent):void
      {
         var _touch:Touch = _touchEvent.getTouch(this);
         if (!_touch)
         {
            image.alpha = 0.3;
            return;
         }
         switch (_touch.phase)
         {
            case "hover":
               image.alpha = down ? image.alpha : 0.5;
               break;
            case "began":
               image.alpha = 0.8;
               down = true;
               break;
            case "moved":
               if (down && !hitTest(_touch.getLocation(this, hitPoint)))
               {
                  image.alpha = 0.3;
                  down = false;
               }
               break;
            case "ended":
               if (down)
               {
                  dispatchEventWith("clicked");
                  image.alpha = 0.5;
                  down = false;
                  GS.playClick();
                  break;
               }
         }
      }
   }
}
