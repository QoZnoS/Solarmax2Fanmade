package starling.animation
{
   import starling.events.EventDispatcher;
   
   public class DelayedCall extends EventDispatcher implements IAnimatable
   {
       
      
      private var mCurrentTime:Number;
      
      private var mTotalTime:Number;
      
      private var mCall:Function;
      
      private var mArgs:Array;
      
      private var mRepeatCount:int;
      
      public function DelayedCall(param1:Function, param2:Number, param3:Array = null)
      {
         super();
         reset(param1,param2,param3);
      }
      
      public function reset(param1:Function, param2:Number, param3:Array = null) : DelayedCall
      {
         mCurrentTime = 0;
         mTotalTime = Math.max(param2,0.0001);
         mCall = param1;
         mArgs = param3;
         mRepeatCount = 1;
         return this;
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc2_:Number = mCurrentTime;
         mCurrentTime = Math.min(mTotalTime,mCurrentTime + param1);
         if(_loc2_ < mTotalTime && mCurrentTime >= mTotalTime)
         {
            mCall.apply(null,mArgs);
            if(mRepeatCount == 0 || mRepeatCount > 1)
            {
               if(mRepeatCount > 0)
               {
                  mRepeatCount -= 1;
               }
               mCurrentTime = 0;
               advanceTime(_loc2_ + param1 - mTotalTime);
            }
            else
            {
               dispatchEventWith("removeFromJuggler");
            }
         }
      }
      
      public function get isComplete() : Boolean
      {
         return mRepeatCount == 1 && mCurrentTime >= mTotalTime;
      }
      
      public function get totalTime() : Number
      {
         return mTotalTime;
      }
      
      public function get currentTime() : Number
      {
         return mCurrentTime;
      }
      
      public function get repeatCount() : int
      {
         return mRepeatCount;
      }
      
      public function set repeatCount(param1:int) : void
      {
         mRepeatCount = param1;
      }
   }
}
