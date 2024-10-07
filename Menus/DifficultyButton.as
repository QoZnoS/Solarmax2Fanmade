// 这个类提供难度按钮母版，星星通过在TitleMenu中调用按钮的showStar显示

package Menus
{
   import flash.geom.Point;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.text.TextField;

   public class DifficultyButton extends Sprite
   {
      public var label:TextField;
      public var icon:Image;
      public var bg:Image;
      public var quad:Quad;
      public var down:Boolean;
      public var hitPoint:Point;
      public var buttonArray:Array;
      public var toggled:Boolean;
      public var starred:Boolean;

      public function DifficultyButton(_difficulty:int, _buttonArray:Array)
      {
         super();
         this.buttonArray = _buttonArray;
         bg = new Image(Root.assets.getTexture("difficulty_btn01"));
         bg.pivotX = bg.width * 0.5;
         bg.pivotY = bg.height * 0.5;
         bg.color = 16755370;
         bg.alpha = 0;
         bg.touchable = false;
         addChild(bg);
         icon = new Image(Root.assets.getTexture("star2"));
         icon.pivotX = icon.width * 0.5;
         icon.pivotY = icon.height * 0.5;
         icon.color = 16755370;
         icon.y = 10;
         icon.alpha = 0.4;
         addChild(icon);
         starred = false;
         var _btnText:Array = ["EASY", "NORMAL", "HARD"];
         label = new TextField(bg.width, 40, _btnText[_difficulty], "Downlink12", -1, 16755370);
         label.pivotX = bg.width * 0.5;
         label.pivotY = 20;
         label.y = -15;
         label.alpha = 0.6;
         addChild(label);
         quad = new Quad(bg.width + 10, bg.height + 10, 16711680);
         quad.pivotX = quad.width * 0.5;
         quad.pivotY = quad.height * 0.5;
         quad.alpha = 0;
         addChild(quad);
         this.blendMode = "add";
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
         var _touch:Touch = _touchEvent.getTouch(quad);
         if (!_touch)
         {
            bg.alpha = toggled ? 0.4 : 0;
            down = false;
            return;
         }
         switch (_touch.phase)
         {
            case "hover":
               bg.alpha = 0.4;
               break;
            case "began":
               bg.alpha = 0.7;
               down = true;
               break;
            case "moved":
               if (down && !hitTest(_touch.getLocation(quad, hitPoint)))
               {
                  bg.alpha = toggled ? 0.4 : 0;
                  down = false;
               }
               break;
            case "ended":
               if (down)
               {
                  toggled = true;
                  if (buttonArray)
                  {
                     bg.alpha = 0.4;
                     for each (var _button:DifficultyButton in buttonArray)
                     {
                        if (_button == this)
                           continue;
                        _button.untoggle();
                     }
                  }
                  else
                  {
                     toggled = false;
                     bg.alpha = 0;
                  }
                  down = false;
                  dispatchEventWith("clicked");
                  GS.playClick();
                  break;
               }
         }
      }

      public function toggle():void
      {
         toggled = true;
         bg.alpha = 0.4;
      }

      public function untoggle():void
      {
         toggled = false;
         bg.alpha = 0;
      }

      public function showStar(_get:Boolean):void
      {
         if (_get && !starred)
         {
            icon.texture = Root.assets.getTexture("star");
            starred = true;
         }
         else if (!_get && starred)
         {
            icon.texture = Root.assets.getTexture("star2");
            starred = false;
         }
      }
   }
}
