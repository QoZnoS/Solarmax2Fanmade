package Menus
{
   import starling.display.Sprite;
   import starling.text.TextField;

   public class LevelButtons extends Sprite
   {
      public var buttons:Array;

      public function LevelButtons()
      {
         super();
         buttons = [];
         var _startBtn:TextField = new TextField(100, 40, "S2", "Downlink16", -1, 16755370);
         _startBtn.pivotX = 50;
         _startBtn.pivotY = 20;
         _startBtn.alpha = 0.6;
         _startBtn.blendMode = "add";
         _startBtn.x = 0;
         addChild(_startBtn);
         buttons.push(_startBtn);
         updateLevels();
      }

      private function getLevelColor(_difficulty:int):int
      {
         if (_difficulty >= LevelData.difficulty.length)
            return 16755370;
         switch (LevelData.difficulty[_difficulty])
         {
            case 1:
               return 65280; // Green
            case 2:
               return 255; // Blue
            case 3:
               return 16776960; // Yellow
            case 4:
               return 16711680; // Red
            default:
               return 16755370; // Default color
         }
      }

      public function updateSize():void
      {
         const _FONT_SIZES:Array = ["Downlink12", "Downlink16", "Downlink20"];
         var _fontName:String = _FONT_SIZES[Globals.textSize];
         for each (var _btn:TextField in buttons)
         {
            _btn.fontName = _fontName;
            _btn.fontSize = -1;
         }
      }

      public function update(_dt:Number, _level:int):void
      {
         var _btn:TextField = null;
         for (var i:int = 0; i < buttons.length; i++)
         {
            _btn = buttons[i];
            var _distance:Number = Math.abs(this.x - 512 + _btn.x);
            _btn.alpha = (1 - Math.min(_distance / 600, 1)) * 0.8;
            if (i > Globals.levelReached + 1)
               _btn.alpha *= 0.3;
            else if (i == _level)
               _btn.alpha = 1;
         }
      }

      public function updateLevels():void
      {
         for (var i:int = buttons.length - 1; i > 0; i--)
         {
            removeChild(buttons[i]);
            buttons.pop();
         }
         for (var i:int = 1; i <= LevelData.maps.length; i++)
         {
            var _levelText:String = (i < 10) ? ("0" + i.toString()) : i.toString();
            var _buttonColor:int = getLevelColor(i);
            var _levelBtn:TextField = new TextField(100, 40, _levelText, "Downlink16", -1, _buttonColor);
            _levelBtn.pivotX = 50;
            _levelBtn.pivotY = 20;
            _levelBtn.alpha = 0.6;
            _levelBtn.blendMode = "add";
            _levelBtn.x = i * 120;
            addChild(_levelBtn);
            buttons.push(_levelBtn);
         }
         updateSize();
      }
   }
}
