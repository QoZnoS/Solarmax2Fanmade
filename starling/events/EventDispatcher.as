package starling.events
{
   import flash.utils.Dictionary;
   import starling.core.starling_internal;
   import starling.display.DisplayObject;
   
   use namespace starling_internal;
   
   public class EventDispatcher
   {
      
      private static var sBubbleChains:Array = [];
       
      
      private var mEventListeners:Dictionary;
      
      public function EventDispatcher()
      {
         super();
      }
      
      public function addEventListener(param1:String, param2:Function) : void
      {
         if(mEventListeners == null)
         {
            mEventListeners = new Dictionary();
         }
         var _loc3_:Vector.<Function> = mEventListeners[param1] as Vector.<Function>;
         if(_loc3_ == null)
         {
            mEventListeners[param1] = new <Function>[param2];
         }
         else if(_loc3_.indexOf(param2) == -1)
         {
            _loc3_.push(param2);
         }
      }
      
      public function removeEventListener(param1:String, param2:Function) : void
      {
         var _loc3_:* = undefined;
         var _loc5_:int = 0;
         var _loc6_:* = undefined;
         var _loc7_:int = 0;
         var _loc4_:Function = null;
         if(mEventListeners)
         {
            _loc3_ = mEventListeners[param1] as Vector.<Function>;
            if(_loc3_)
            {
               _loc5_ = int(_loc3_.length);
               _loc6_ = new Vector.<Function>(0);
               _loc7_ = 0;
               while(_loc7_ < _loc5_)
               {
                  if((_loc4_ = _loc3_[_loc7_]) != param2)
                  {
                     _loc6_.push(_loc4_);
                  }
                  _loc7_++;
               }
               mEventListeners[param1] = _loc6_;
            }
         }
      }
      
      public function removeEventListeners(param1:String = null) : void
      {
         if(param1 && mEventListeners)
         {
            delete mEventListeners[param1];
         }
         else
         {
            mEventListeners = null;
         }
      }
      
      public function dispatchEvent(param1:Event) : void
      {
         var _loc3_:Boolean = param1.bubbles;
         if(!_loc3_ && (mEventListeners == null || !(param1.type in mEventListeners)))
         {
            return;
         }
         var _loc2_:EventDispatcher = param1.target;
         param1.setTarget(this);
         if(_loc3_ && this is DisplayObject)
         {
            bubbleEvent(param1);
         }
         else
         {
            invokeEvent(param1);
         }
         if(_loc2_)
         {
            param1.setTarget(_loc2_);
         }
      }
      
      internal function invokeEvent(param1:Event) : Boolean
      {
         var _loc6_:int = 0;
         var _loc3_:Function = null;
         var _loc5_:int = 0;
         var _loc2_:Vector.<Function> = !!mEventListeners ? mEventListeners[param1.type] as Vector.<Function> : null;
         if(int(_loc2_ == null ? 0 : _loc2_.length))
         {
            param1.setCurrentTarget(this);
            _loc6_ = 0;
            while(_loc6_ < 0)
            {
               _loc3_ = _loc2_[_loc6_] as Function;
               if((_loc5_ = _loc3_.length) == 0)
               {
                  _loc3_();
               }
               else if(_loc5_ == 1)
               {
                  _loc3_(param1);
               }
               else
               {
                  _loc3_(param1,param1.data);
               }
               if(param1.stopsImmediatePropagation)
               {
                  return true;
               }
               _loc6_++;
            }
            return param1.stopsPropagation;
         }
         return false;
      }
      
      internal function bubbleEvent(param1:Event) : void
      {
         var _loc3_:* = undefined;
         var _loc6_:int = 0;
         var _loc4_:Boolean = false;
         var _loc2_:DisplayObject = this as DisplayObject;
         var _loc5_:int = 1;
         if(sBubbleChains.length > 0)
         {
            _loc3_ = sBubbleChains.pop();
            _loc3_[0] = _loc2_;
         }
         else
         {
            _loc3_ = new <EventDispatcher>[_loc2_];
         }
         while((_loc2_ = _loc2_.parent) != null)
         {
            _loc3_[_loc5_++] = _loc2_;
         }
         _loc6_ = 0;
         while(_loc6_ < _loc5_)
         {
            if(_loc4_ = _loc3_[_loc6_].invokeEvent(param1))
            {
               break;
            }
            _loc6_++;
         }
         _loc3_.length = 0;
         sBubbleChains.push(_loc3_);
      }
      
      public function dispatchEventWith(param1:String, param2:Boolean = false, param3:Object = null) : void
      {
         var _loc4_:Event = null;
         if(param2 || hasEventListener(param1))
         {
            _loc4_ = Event.starling_internal::fromPool(param1,param2,param3);
            dispatchEvent(_loc4_);
            Event.starling_internal::toPool(_loc4_);
         }
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         var _loc2_:Vector.<Function> = !!mEventListeners ? mEventListeners[param1] as Vector.<Function> : null;
         return !!_loc2_ ? _loc2_.length != 0 : false;
      }
   }
}
