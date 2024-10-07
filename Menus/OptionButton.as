// 设置界面中的文字按钮
package Menus
{
   import flash.geom.Point;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.text.TextField;

   public class OptionButton extends Sprite
   {
      public var quad:Quad;
      public var labelBG:Quad;
      public var label:TextField;
      public var down:Boolean;
      public var hitPoint:Point;
      public var buttonArray:Array;
      public var toggled:Boolean;

      public var labelArray:Array;

      public function OptionButton(_text:String, _color:uint, _buttonArray:Array)
      {
         super();
         this.buttonArray = _buttonArray;
         labelArray = [];
         label = new TextField(240, 40, _text, "Downlink12", -1, _color);
         label.hAlign = "left";
         label.vAlign = "top";
         label.touchable = false;
         addChild(label);
         labelBG = new Quad(label.textBounds.width + 12, label.textBounds.height + 12, _color);
         labelBG.x = -6;
         labelBG.y = -2;
         labelBG.alpha = 0;
         labelBG.touchable = false;
         addChild(labelBG);
         quad = new Quad(labelBG.width + 4, labelBG.height + 4, 16711680);
         quad.x = labelBG.x - 2;
         quad.y = labelBG.y - 2;
         quad.alpha = 0;
         addChild(quad);
         hitPoint = new Point(0, 0);
         toggled = false;
      }

      public function init():void
      {
         untoggle();
         quad.addEventListener("touch", on_touch);
      }

      public function deInit():void
      {
         quad.removeEventListener("touch", on_touch);
      }

      public function on_touch(_touchEvent:TouchEvent):void
      {
         var _touch:Touch = _touchEvent.getTouch(this);
         if (!_touch)
         {
            labelBG.alpha = toggled ? 0.2 : 0;
            down = false;
            return;
         }
         switch (_touch.phase)
         {
            case "hover":
               labelBG.alpha = 0.2;
               break;
            case "began":
               labelBG.alpha = 0.5;
               down = true;
               break;
            case "moved":
               if (down && !hitTest(_touch.getLocation(this, hitPoint)))
               {
                  labelBG.alpha = toggled ? 0.2 : 0;
                  down = false;
               }
               break;
            case "ended":
               if (down)
               {
                  var _shouldToggle:Boolean = buttonArray != null;
                  toggled = _shouldToggle;
                  labelBG.alpha = _shouldToggle ? 0.2 : 0;
                  if (buttonArray)
                  {
                     for each (var _button:OptionButton in buttonArray)
                     {
                        if (_button == this)
                           continue;
                        _button.untoggle();
                     }
                  }
                  down = false;
                  dispatchEventWith("clicked");
                  break;
               }
         }
      }

      public function toggle():void
      {
         toggled = true;
         labelBG.alpha = 0.2;
      }

      public function untoggle():void
      {
         toggled = false;
         labelBG.alpha = 0;
      }

      public function addLabel(_label:TextField, _x:Number, _y:Number, _hAlign:String = "left"):void
      {
         _label.hAlign = _hAlign;
         _label.vAlign = "top";
         _label.x = _x;
         _label.y = _y;
         labelArray.push(_label);
         addChildAt(_label, 0);
      }
   }
}
