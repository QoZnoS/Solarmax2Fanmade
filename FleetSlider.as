// 处理分兵条

package Game
{
   import flash.geom.Point;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.text.TextField;

   public class FleetSlider extends Sprite
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

      public function FleetSlider(param1:int) // 添加贴图
      {
         var _loc2_:String = null;
         super();
         switch (param1)
         {
            case 0:
            case 1:
               touchWidth = 512;
               touchHeight = 40;
               boxWidth = 50;
               boxHeight = 20;
               thickness = 2;
               _loc2_ = "Downlink12";
               break;
            case 2:
               touchWidth = 640;
               touchHeight = 60;
               boxWidth = 80;
               boxHeight = 30;
               thickness = 2;
               _loc2_ = "Downlink18";
         }
         label = new TextField(boxWidth, boxHeight * 2, "100%", _loc2_, -1, 16755370);
         label.pivotX = label.x = boxWidth * 0.5;
         label.pivotY = boxHeight;
         label.y = boxHeight * 0.5;
         label.alpha = 0.6;
         label.pivotX -= 2;
         addChild(label);
         quad1 = new Quad(touchWidth, thickness, 16755370);
         quad1.y = boxHeight * 0.5 - thickness * 0.5;
         quad1.alpha = 0.5;
         addChild(quad1);
         quad2 = new Quad(touchWidth, thickness, 16755370);
         quad2.pivotX = quad2.x = touchWidth;
         quad2.y = boxHeight * 0.5 - thickness * 0.5;
         quad2.alpha = 0.25;
         addChild(quad2);
         box = new Sprite();
         boxQuad1 = new Quad(boxWidth, thickness, 16755370);
         boxQuad1.x = -boxWidth * 0.5;
         boxQuad1.y = -boxHeight * 0.5 - thickness;
         box.addChild(boxQuad1);
         boxQuad2 = new Quad(boxWidth, thickness, 16755370);
         boxQuad2.x = -boxWidth * 0.5;
         boxQuad2.y = boxHeight * 0.5;
         box.addChild(boxQuad2);
         boxQuad3 = new Quad(thickness, boxHeight, 16755370);
         boxQuad3.x = -boxWidth * 0.5;
         boxQuad3.y = -boxHeight * 0.5;
         box.addChild(boxQuad3);
         boxQuad4 = new Quad(thickness, boxHeight, 16755370);
         boxQuad4.x = boxWidth * 0.5 - thickness;
         boxQuad4.y = -boxHeight * 0.5;
         box.addChild(boxQuad4);
         box.alpha = 0.5;
         box.x = label.x;
         box.y = label.y;
         addChild(box);
         touchQuad = new Quad(touchWidth + boxWidth, touchHeight, 16711680);
         touchQuad.x = -boxWidth * 0.5;
         touchQuad.y = -boxHeight * 0.5;
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

      public function on_touch(param1:TouchEvent):void // 点击改变分兵条
      {
         var _TouchArray:Vector.<Touch> = param1.getTouches(touchQuad);
         if (!_TouchArray)
            return;
         if (_TouchArray.length == 1) // 确保只有一个触点
         {
            var _Touch:Touch = _TouchArray[0];
            switch (_Touch.phase)
            {
               case "began":
               case "moved":
               case "ended":
                  total = (_Touch.getLocation(this).x - boxWidth * 0.5) / (touchWidth - boxWidth);
                  total = Math.max(0.0001, Math.min(total, 1));
                  break;
            }
            update();
         }
      }

      public function update():void
      {
         label.x = box.x = boxWidth * 0.5 + total * (touchWidth - boxWidth);
         label.text = int(total * 100).toString() + "%";
         quad1.setVertexPosition(1, label.x - boxWidth * 0.5, 0);
         quad1.setVertexPosition(3, label.x - boxWidth * 0.5, thickness);
         quad2.setVertexPosition(0, label.x + boxWidth * 0.5, 0);
         quad2.setVertexPosition(2, label.x + boxWidth * 0.5, thickness);
      }
   }
}
