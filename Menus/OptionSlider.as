package Menus
{
   import flash.geom.Point;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.text.TextField;

   public class OptionSlider extends Sprite
   {
      public var quad1:Quad;
      public var quad2:Quad;
      public var touchQuad:Quad;
      public var label:TextField;
      public var total:Number;
      public var box:Sprite;
      public var boxQuad1:Quad;
      public var boxQuad2:Quad;
      public var boxQuad3:Quad;
      public var boxQuad4:Quad;
      public var touchWidth:Number;
      public var touchHeight:Number;
      public var boxWidth:Number;
      public var boxHeight:Number;
      public var thickness:Number;

      public function OptionSlider(_size:int)
      {
         var _texture:String = null;
         super();
         var _color:Number = 16752059;
         switch (_size)
         {
            case 0:
            case 1:
               touchWidth = 320;
               touchHeight = 24;
               boxWidth = 50;
               boxHeight = 18;
               thickness = 1;
               _texture = "Downlink12";
               break;
            case 2:
               touchWidth = 512;
               touchHeight = 40;
               boxWidth = 80;
               boxHeight = 24;
               thickness = 2;
               _texture = "Downlink18";
         }
         label = new TextField(boxWidth, boxHeight * 2, "100%", _texture, -1, _color);
         label.pivotX = label.x = boxWidth * 0.5;
         label.pivotY = boxHeight;
         label.y = boxHeight * 0.5;
         label.alpha = 0.8;
         label.pivotX -= 2;
         label.touchable = false;
         addChild(label);
         quad1 = new Quad(touchWidth, thickness, _color);
         quad1.y = boxHeight * 0.5 - thickness * 0.5;
         quad1.alpha = 0.6;
         addChild(quad1);
         quad2 = new Quad(touchWidth, thickness, _color);
         quad2.pivotX = quad2.x = touchWidth;
         quad2.y = boxHeight * 0.5 - thickness * 0.5;
         quad2.alpha = 0.3;
         addChild(quad2);
         box = new Sprite();
         boxQuad1 = new Quad(boxWidth, thickness, _color);
         boxQuad1.x = -boxWidth * 0.5;
         boxQuad1.y = -boxHeight * 0.5 - thickness;
         box.addChild(boxQuad1);
         boxQuad2 = new Quad(boxWidth, thickness, _color);
         boxQuad2.x = -boxWidth * 0.5;
         boxQuad2.y = boxHeight * 0.5;
         box.addChild(boxQuad2);
         boxQuad3 = new Quad(thickness, boxHeight, _color);
         boxQuad3.x = -boxWidth * 0.5;
         boxQuad3.y = -boxHeight * 0.5;
         box.addChild(boxQuad3);
         boxQuad4 = new Quad(thickness, boxHeight, _color);
         boxQuad4.x = boxWidth * 0.5 - thickness;
         boxQuad4.y = -boxHeight * 0.5;
         box.addChild(boxQuad4);
         box.alpha = 0.6;
         box.x = label.x;
         box.y = label.y;
         addChild(box);
         touchQuad = new Quad(touchWidth + 20, touchHeight, 16711680);
         touchQuad.x = -10;
         touchQuad.y = -boxHeight * 0.5 + 6;
         touchQuad.alpha = 0;
         addChild(touchQuad);
      }

      public function init():void
      {
         total = 1;
         touchQuad.addEventListener("touch", on_touch);
      }

      public function deInit():void
      {
         touchQuad.removeEventListener("touch", on_touch);
      }

      public function on_touch(_touchEvent:TouchEvent):void
      {
         var _touches:Vector.<Touch> = _touchEvent.getTouches(touchQuad);
         if (!_touches || _touches.length == 0)
            return;
         var _touch:Touch = _touches[0];
         if (_touch.phase == "began" || _touch.phase == "moved" || _touch.phase == "ended")
         {
            var _location:Point = _touch.getLocation(this);
            var _newTotal:Number = (_location.x - boxWidth * 0.5) / (touchWidth - boxWidth);
            total = Math.max(0, Math.min(1, _newTotal));
            update();
         }
      }

      public function update():void
      {
         label.x = box.x = boxWidth * 0.5 + total * (touchWidth - boxWidth);
         label.text = (int(total * 100)).toString() + "%";
         quad1.setVertexPosition(1, label.x - boxWidth * 0.5, 0);
         quad1.setVertexPosition(3, label.x - boxWidth * 0.5, thickness);
         quad2.setVertexPosition(0, label.x + boxWidth * 0.5, 0);
         quad2.setVertexPosition(2, label.x + boxWidth * 0.5, thickness);
      }
   }
}
