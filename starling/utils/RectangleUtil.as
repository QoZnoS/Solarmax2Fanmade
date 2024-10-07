package starling.utils
{
   import flash.geom.Rectangle;
   import starling.errors.AbstractClassError;
   
   public class RectangleUtil
   {
       
      
      public function RectangleUtil()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function intersect(param1:Rectangle, param2:Rectangle, param3:Rectangle = null) : Rectangle
      {
         if(param3 == null)
         {
            param3 = new Rectangle();
         }
         var _loc5_:Number = param1.x > param2.x ? param1.x : param2.x;
         var _loc6_:Number = param1.right < param2.right ? param1.right : param2.right;
         var _loc7_:Number = param1.y > param2.y ? param1.y : param2.y;
         var _loc4_:Number = param1.bottom < param2.bottom ? param1.bottom : param2.bottom;
         if(_loc5_ > _loc6_ || _loc7_ > _loc4_)
         {
            param3.setEmpty();
         }
         else
         {
            param3.setTo(_loc5_,_loc7_,_loc6_ - _loc5_,_loc4_ - _loc7_);
         }
         return param3;
      }
      
      public static function fit(param1:Rectangle, param2:Rectangle, param3:String = "showAll", param4:Boolean = false, param5:Rectangle = null) : Rectangle
      {
         if(!ScaleMode.isValid(param3))
         {
            throw new ArgumentError("Invalid scaleMode: " + param3);
         }
         if(param5 == null)
         {
            param5 = new Rectangle();
         }
         var _loc9_:Number = param1.width;
         var _loc6_:Number = param1.height;
         var _loc7_:Number = param2.width / _loc9_;
         var _loc8_:Number = param2.height / _loc6_;
         var _loc10_:Number = 1;
         if(param3 == "showAll")
         {
            _loc10_ = _loc7_ < _loc8_ ? _loc7_ : _loc8_;
            if(param4)
            {
               _loc10_ = nextSuitableScaleFactor(_loc10_,false);
            }
         }
         else if(param3 == "noBorder")
         {
            _loc10_ = _loc7_ > _loc8_ ? _loc7_ : _loc8_;
            if(param4)
            {
               _loc10_ = nextSuitableScaleFactor(_loc10_,true);
            }
         }
         _loc9_ *= _loc10_;
         _loc6_ *= _loc10_;
         param5.setTo(param2.x + (param2.width - _loc9_) / 2,param2.y + (param2.height - _loc6_) / 2,_loc9_,_loc6_);
         return param5;
      }
      
      private static function nextSuitableScaleFactor(param1:Number, param2:Boolean) : Number
      {
         var _loc3_:Number = 1;
         if(param2)
         {
            if(param1 >= 0.5)
            {
               return Math.ceil(param1);
            }
            while(1 / (_loc3_ + 1) > param1)
            {
               _loc3_++;
            }
         }
         else
         {
            if(param1 >= 1)
            {
               return Math.floor(param1);
            }
            while(1 / _loc3_ > param1)
            {
               _loc3_++;
            }
         }
         return 1 / _loc3_;
      }
   }
}
