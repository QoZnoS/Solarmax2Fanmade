//进度条相关

package utils
{
   import starling.core.Starling;
   import starling.display.Quad;
   import starling.display.Sprite;

   public class ProgressBar extends Sprite
   {

      private var mBar:Quad;

      private var mBackground:Quad;

      private var type:Boolean;//新二代增加，区分原版进度条和新版进度条

      private var xx:int;

      public function ProgressBar(param1:int, param2:int, param3:Boolean) // 方法覆写，然后传参
      {
         super();
         type = param3;
         if (param3)
         {
            init(param1, param2);
         }
         else
         {
            xx = this.x;
            Sinit(param1, param2);
         }

      }

      private function init(param1:int, param2:int):void // 参数：长512，宽3
      {
         var _loc3_:Number = Starling.contentScaleFactor;
         // 矩形1：空轴
         mBackground = new Quad(param1, param2, 15658734); // EEEEEE
         addChild(mBackground);
         // 矩形2：填充轴
         mBar = new Quad(param1, param2, 11184810); // AAAAAA
         mBar.scaleX = 0;
         addChild(mBar);
      }

      private function Sinit(param1:int, param2:int):void // 参数：长512，宽30
      {
         var _loc3_:Number = Starling.contentScaleFactor;
         // 矩形：覆盖条
         mBar = new Quad(param1, param2, 16777215);//FFFFFF
         mBar.scaleX = 1;
         mBar.alpha = 0.7;//不透明度
         addChild(mBar);
      }

      public function get ratio():Number
      {
         return mBar.scaleX;
      }

      public function set ratio(param1:Number):void//缩放
      {
         if (type)
         {
            mBar.scaleX = Math.max(0, Math.min(1, param1));
         }
         else
         {
            mBar.scaleX = Math.min(1, Math.max(0, 1 - param1));
            this.x = xx + 512 * Math.max(0, Math.min(1, param1));//覆盖条缩放后需移到对应位置
         }
      }
   }
}
