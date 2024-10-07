package starling.animation
{
   import starling.core.starling_internal;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   
   use namespace starling_internal;
   
   public class Juggler implements IAnimatable
   {
       
      
      private var mObjects:Vector.<IAnimatable>;
      
      private var mElapsedTime:Number;
      
      public function Juggler()
      {
         super();
         mElapsedTime = 0;
         mObjects = new Vector.<IAnimatable>(0);
      }
      
      public function add(param1:IAnimatable) : void
      {
         var _loc2_:EventDispatcher = null;
         if(param1 && mObjects.indexOf(param1) == -1)
         {
            mObjects.push(param1);
            _loc2_ = param1 as EventDispatcher;
            if(_loc2_)
            {
               _loc2_.addEventListener("removeFromJuggler",onRemove);
            }
         }
      }
      
      public function contains(param1:IAnimatable) : Boolean
      {
         return mObjects.indexOf(param1) != -1;
      }
      
      public function remove(param1:IAnimatable) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc3_:EventDispatcher = param1 as EventDispatcher;
         if(_loc3_)
         {
            _loc3_.removeEventListener("removeFromJuggler",onRemove);
         }
         var _loc2_:int = mObjects.indexOf(param1);
         if(_loc2_ != -1)
         {
            mObjects[_loc2_] = null;
         }
      }
      
      public function removeTweens(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Tween = null;
         if(param1 == null)
         {
            return;
         }
         _loc3_ = mObjects.length - 1;
         while(_loc3_ >= 0)
         {
            _loc2_ = mObjects[_loc3_] as Tween;
            if(_loc2_ && _loc2_.target == param1)
            {
               _loc2_.removeEventListener("removeFromJuggler",onRemove);
               mObjects[_loc3_] = null;
            }
            _loc3_--;
         }
      }
      
      public function containsTweens(param1:Object) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Tween = null;
         if(param1 == null)
         {
            return false;
         }
         _loc3_ = mObjects.length - 1;
         while(_loc3_ >= 0)
         {
            _loc2_ = mObjects[_loc3_] as Tween;
            if(_loc2_ && _loc2_.target == param1)
            {
               return true;
            }
            _loc3_--;
         }
         return false;
      }
      
      public function purge() : void
      {
         var _loc2_:int = 0;
         var _loc1_:EventDispatcher = null;
         _loc2_ = mObjects.length - 1;
         while(_loc2_ >= 0)
         {
            _loc1_ = mObjects[_loc2_] as EventDispatcher;
            if(_loc1_)
            {
               _loc1_.removeEventListener("removeFromJuggler",onRemove);
            }
            mObjects[_loc2_] = null;
            _loc2_--;
         }
      }
      
      public function delayCall(param1:Function, param2:Number, ... rest) : DelayedCall
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc4_:DelayedCall = new DelayedCall(param1,param2,rest);
         add(_loc4_);
         return _loc4_;
      }
      
      public function tween(param1:Object, param2:Number, param3:Object) : void
      {
         var _loc5_:Object = null;
         var _loc4_:Tween = Tween.starling_internal::fromPool(param1,param2);
         for(var _loc6_ in param3)
         {
            _loc5_ = param3[_loc6_];
            if(_loc4_.hasOwnProperty(_loc6_))
            {
               _loc4_[_loc6_] = _loc5_;
            }
            else
            {
               if(!param1.hasOwnProperty(_loc6_))
               {
                  throw new ArgumentError("Invalid property: " + _loc6_);
               }
               _loc4_.animate(_loc6_,_loc5_ as Number);
            }
         }
         _loc4_.addEventListener("removeFromJuggler",onPooledTweenComplete);
         add(_loc4_);
      }
      
      private function onPooledTweenComplete(param1:Event) : void
      {
         Tween.starling_internal::toPool(param1.target as Tween);
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc5_:int = 0;
         var _loc3_:IAnimatable = null;
         var _loc4_:int = int(mObjects.length);
         var _loc2_:int = 0;
         mElapsedTime += param1;
         if(_loc4_ == 0)
         {
            return;
         }
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_ = mObjects[_loc5_];
            if(_loc3_)
            {
               if(_loc2_ != _loc5_)
               {
                  mObjects[_loc2_] = _loc3_;
                  mObjects[_loc5_] = null;
               }
               _loc3_.advanceTime(param1);
               _loc2_++;
            }
            _loc5_++;
         }
         if(_loc2_ != _loc5_)
         {
            _loc4_ = int(mObjects.length);
            while(_loc5_ < _loc4_)
            {
               mObjects[_loc2_++] = mObjects[_loc5_++];
            }
            mObjects.length = _loc2_;
         }
      }
      
      private function onRemove(param1:Event) : void
      {
         remove(param1.target as IAnimatable);
         var _loc2_:Tween = param1.target as Tween;
         if(_loc2_ && _loc2_.isComplete)
         {
            add(_loc2_.nextTween);
         }
      }
      
      public function get elapsedTime() : Number
      {
         return mElapsedTime;
      }
   }
}
