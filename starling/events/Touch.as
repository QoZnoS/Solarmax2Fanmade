package starling.events
{
   import Game.Entity.Node;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import starling.core.starling_internal;
   import starling.display.DisplayObject;
   import starling.utils.MatrixUtil;
   import starling.utils.formatString;
   
   use namespace starling_internal;
   
   public class Touch
   {
      
      private static var sHelperMatrix:Matrix = new Matrix();
       
      
      private var mID:int;
      
      private var mGlobalX:Number;
      
      private var mGlobalY:Number;
      
      private var mPreviousGlobalX:Number;
      
      private var mPreviousGlobalY:Number;
      
      private var mTapCount:int;
      
      private var mPhase:String;
      
      private var mTarget:DisplayObject;
      
      private var mTimestamp:Number;
      
      private var mPressure:Number;
      
      private var mWidth:Number;
      
      private var mHeight:Number;
      
      private var mBubbleChain:Vector.<EventDispatcher>;
      
      public var hoverNode:Node;
      
      public var downNode:Node;
      
      public var downNodes:Array;
      
      public var downX:Number;
      
      public var downY:Number;
      
      public function Touch(param1:int)
      {
         super();
         mID = param1;
         mTapCount = 0;
         mPhase = "hover";
         mPressure = mWidth = mHeight = 1;
         mBubbleChain = new Vector.<EventDispatcher>(0);
      }
      
      public function getLocation(param1:DisplayObject, param2:Point = null) : Point
      {
         if(param2 == null)
         {
            param2 = new Point();
         }
         param1.base.getTransformationMatrix(param1,sHelperMatrix);
         return MatrixUtil.transformCoords(sHelperMatrix,mGlobalX,mGlobalY,param2);
      }
      
      public function getPreviousLocation(param1:DisplayObject, param2:Point = null) : Point
      {
         if(param2 == null)
         {
            param2 = new Point();
         }
         param1.base.getTransformationMatrix(param1,sHelperMatrix);
         return MatrixUtil.transformCoords(sHelperMatrix,mPreviousGlobalX,mPreviousGlobalY,param2);
      }
      
      public function getMovement(param1:DisplayObject, param2:Point = null) : Point
      {
         if(param2 == null)
         {
            param2 = new Point();
         }
         getLocation(param1,param2);
         var _loc4_:Number = param2.x;
         var _loc3_:Number = param2.y;
         getPreviousLocation(param1,param2);
         param2.setTo(_loc4_ - param2.x,_loc3_ - param2.y);
         return param2;
      }
      
      public function isTouching(param1:DisplayObject) : Boolean
      {
         return mBubbleChain.indexOf(param1) != -1;
      }
      
      public function toString() : String
      {
         return formatString("Touch {0}: globalX={1}, globalY={2}, phase={3}",mID,mGlobalX,mGlobalY,mPhase);
      }
      
      public function clone() : Touch
      {
         var _loc1_:Touch = new Touch(mID);
         _loc1_.mGlobalX = mGlobalX;
         _loc1_.mGlobalY = mGlobalY;
         _loc1_.mPreviousGlobalX = mPreviousGlobalX;
         _loc1_.mPreviousGlobalY = mPreviousGlobalY;
         _loc1_.mPhase = mPhase;
         _loc1_.mTapCount = mTapCount;
         _loc1_.mTimestamp = mTimestamp;
         _loc1_.mPressure = mPressure;
         _loc1_.mWidth = mWidth;
         _loc1_.mHeight = mHeight;
         _loc1_.target = mTarget;
         return _loc1_;
      }
      
      private function updateBubbleChain() : void
      {
         var _loc2_:int = 0;
         var _loc1_:DisplayObject = null;
         if(mTarget)
         {
            _loc2_ = 1;
            _loc1_ = mTarget;
            mBubbleChain.length = 1;
            mBubbleChain[0] = _loc1_;
            while((_loc1_ = _loc1_.parent) != null)
            {
               mBubbleChain[_loc2_++] = _loc1_;
            }
         }
         else
         {
            mBubbleChain.length = 0;
         }
      }
      
      public function get id() : int
      {
         return mID;
      }
      
      public function get previousGlobalX() : Number
      {
         return mPreviousGlobalX;
      }
      
      public function get previousGlobalY() : Number
      {
         return mPreviousGlobalY;
      }
      
      public function get globalX() : Number
      {
         return mGlobalX;
      }
      
      public function set globalX(param1:Number) : void
      {
         mPreviousGlobalX = mGlobalX != mGlobalX ? param1 : mGlobalX;
         mGlobalX = param1;
      }
      
      public function get globalY() : Number
      {
         return mGlobalY;
      }
      
      public function set globalY(param1:Number) : void
      {
         mPreviousGlobalY = mGlobalY != mGlobalY ? param1 : mGlobalY;
         mGlobalY = param1;
      }
      
      public function get tapCount() : int
      {
         return mTapCount;
      }
      
      public function set tapCount(param1:int) : void
      {
         mTapCount = param1;
      }
      
      public function get phase() : String
      {
         return mPhase;
      }
      
      public function set phase(param1:String) : void
      {
         mPhase = param1;
      }
      
      public function get target() : DisplayObject
      {
         return mTarget;
      }
      
      public function set target(param1:DisplayObject) : void
      {
         if(mTarget != param1)
         {
            mTarget = param1;
            updateBubbleChain();
         }
      }
      
      public function get timestamp() : Number
      {
         return mTimestamp;
      }
      
      public function set timestamp(param1:Number) : void
      {
         mTimestamp = param1;
      }
      
      public function get pressure() : Number
      {
         return mPressure;
      }
      
      public function set pressure(param1:Number) : void
      {
         mPressure = param1;
      }
      
      public function get width() : Number
      {
         return mWidth;
      }
      
      public function set width(param1:Number) : void
      {
         mWidth = param1;
      }
      
      public function get height() : Number
      {
         return mHeight;
      }
      
      public function set height(param1:Number) : void
      {
         mHeight = param1;
      }
      
      internal function dispatchEvent(param1:TouchEvent) : void
      {
         if(mTarget)
         {
            param1.dispatch(mBubbleChain);
         }
      }
      
      internal function get bubbleChain() : Vector.<EventDispatcher>
      {
         return mBubbleChain.concat();
      }
   }
}
