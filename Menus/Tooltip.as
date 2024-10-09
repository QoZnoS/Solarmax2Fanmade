// 鼠标悬停在操作方式上出现的文体提示框
package Menus
{
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.text.TextField;

   public class Tooltip extends Sprite
   {
      public var bg:Quad;
      public var arrow:Quad;
      public var title:TextField;
      public var content:TextField;

      public function Tooltip(_type:int)
      {
         super();
         if (_type == 0)
         {
            bg = new Quad(400, 100, 0);
            bg.alpha = 0.9;
            addChild(bg);
            title = new TextField(380, 40, "MULTI-TOUCH CONTROLS", "Downlink16", -1, 16777215);
            title.hAlign = "left";
            title.vAlign = "top";
            title.x = 10;
            title.y = 10;
            addChild(title);
            content = new TextField(380, 100, "", "Downlink10", -1, 16777215);
            content.text = "+ Hold LEFT CLICK on a planet and drag onto target\n\n+ SCROLL WHEEL to change move percentage";
         }
         else
         {
            bg = new Quad(400, 200, 0);
            bg.alpha = 0.9;
            addChild(bg);
            title = new TextField(380, 40, "TRADITIONAL CONTROLS", "Downlink16", -1, 16777215);
            title.hAlign = "left";
            title.vAlign = "top";
            title.x = 10;
            title.y = 10;
            addChild(title);
            content = new TextField(380, 200, "", "Downlink10", -1, 16777215);
            content.text = "+ LEFT CLICK on a planet to select it\n\n+ LEFT LICK and drag a box to select planets\n\n+ Hold SHIFT and LEFT CLICK to add or remove planets\n\n+ LEFT CLICK on empty space to deselect\n\n+ RIGHT CLICK on a planet to move ships\n\n+ SCROLL WHEEL to change move percentage";
         }
         content.hAlign = "left";
         content.vAlign = "top";
         content.x = 10;
         content.y = 38;
         addChild(content);
         this.pivotX = 10;
         this.pivotY = bg.height + 5;
         this.touchable = false;
      }
   }
}
