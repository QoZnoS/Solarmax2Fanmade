package starling.display
{
   import starling.errors.AbstractClassError;
   
   public class BlendMode
   {
      
      private static var sBlendFactors:Array = [{
         "none":["one","zero"],
         "normal":["sourceAlpha","oneMinusSourceAlpha"],
         "add":["sourceAlpha","destinationAlpha"],
         "multiply":["destinationColor","oneMinusSourceAlpha"],
         "screen":["sourceAlpha","one"],
         "erase":["zero","oneMinusSourceAlpha"]
      },{
         "none":["one","zero"],
         "normal":["one","oneMinusSourceAlpha"],
         "add":["one","one"],
         "multiply":["destinationColor","oneMinusSourceAlpha"],
         "screen":["one","oneMinusSourceColor"],
         "erase":["zero","oneMinusSourceAlpha"]
      }];
      
      public static const AUTO:String = "auto";
      
      public static const NONE:String = "none";
      
      public static const NORMAL:String = "normal";
      
      public static const ADD:String = "add";
      
      public static const MULTIPLY:String = "multiply";
      
      public static const SCREEN:String = "screen";
      
      public static const ERASE:String = "erase";
       
      
      public function BlendMode()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function getBlendFactors(param1:String, param2:Boolean = true) : Array
      {
         var _loc3_:Object = sBlendFactors[int(param2)];
         if(param1 in _loc3_)
         {
            return _loc3_[param1];
         }
         throw new ArgumentError("Invalid blend mode");
      }
      
      public static function register(param1:String, param2:String, param3:String, param4:Boolean = true) : void
      {
         var _loc6_:Object;
         (_loc6_ = sBlendFactors[int(param4)])[param1] = [param2,param3];
         var _loc5_:Object = sBlendFactors[int(!param4)];
         if(!(param1 in _loc5_))
         {
            _loc5_[param1] = [param2,param3];
         }
      }
   }
}
