//思考

package starling.core
{
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.Stage3D;
   import flash.display3D.Context3D;
   import flash.display3D.Program3D;
   import flash.errors.IllegalOperationError;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TouchEvent;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Mouse;
   import flash.ui.Multitouch;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import starling.animation.Juggler;
   import starling.display.DisplayObject;
   import starling.display.Stage;
   import starling.events.EventDispatcher;
   import starling.events.KeyboardEvent;
   import starling.events.ResizeEvent;
   import starling.events.TouchProcessor;
   
   public class Starling extends EventDispatcher
   {
      
      public static const VERSION:String = "1.4";
      
      private static const PROGRAM_DATA_NAME:String = "Starling.programs";
      
      private static var sCurrent:Starling;
      
      private static var sHandleLostContext:Boolean;
      
      private static var sContextData:Dictionary = new Dictionary(true);
       
      
      private var mStage3D:Stage3D;
      
      private var mStage:starling.display.Stage;
      
      private var mRootClass:Class;
      
      private var mRoot:DisplayObject;
      
      private var mJuggler:Juggler;
      
      private var mSupport:RenderSupport;
      
      private var mTouchProcessor:TouchProcessor;
      
      private var mAntiAliasing:int;
      
      private var mSimulateMultitouch:Boolean;
      
      private var mEnableErrorChecking:Boolean;
      
      private var mLastFrameTimestamp:Number;
      
      private var mLeftMouseDown:Boolean;
      
      private var mStatsDisplay:StatsDisplay;
      
      private var mShareContext:Boolean;
      
      private var mProfile:String;
      
      private var mSupportHighResolutions:Boolean;
      
      private var mContext:Context3D;
      
      private var mStarted:Boolean;
      
      private var mRendering:Boolean;
      
      private var mViewPort:Rectangle;
      
      private var mPreviousViewPort:Rectangle;
      
      private var mClippedViewPort:Rectangle;
      
      private var mNativeStage:flash.display.Stage;
      
      private var mNativeOverlay:Sprite;
      
      private var mNativeStageContentScaleFactor:Number;
      
      public function Starling(param1:Class, param2:flash.display.Stage, param3:Rectangle = null, param4:Stage3D = null, param5:String = "auto", param6:String = "baselineConstrained")
      {
         var _loc8_:Function = null;
         super();
         if(param2 == null)
         {
            throw new ArgumentError("Stage must not be null");
         }
         if(param1 == null)
         {
            throw new ArgumentError("Root class must not be null");
         }
         if(param3 == null)
         {
            param3 = new Rectangle(0,0,param2.stageWidth,param2.stageHeight);
         }
         if(param4 == null)
         {
            param4 = param2.stage3Ds[0];
         }
         makeCurrent();
         mRootClass = param1;
         mViewPort = param3;
         mPreviousViewPort = new Rectangle();
         mStage3D = param4;
         mStage = new starling.display.Stage(param3.width,param3.height,param2.color);
         mNativeOverlay = new Sprite();
         mNativeStage = param2;
         mNativeStage.addChild(mNativeOverlay);
         mNativeStageContentScaleFactor = 1;
         mTouchProcessor = new TouchProcessor(mStage);
         mJuggler = new Juggler();
         mAntiAliasing = 0;
         mSimulateMultitouch = false;
         mEnableErrorChecking = false;
         mProfile = param6;
         mSupportHighResolutions = false;
         mLastFrameTimestamp = getTimer() / 1000;
         mSupport = new RenderSupport();
         sContextData[param4] = new Dictionary();
         sContextData[param4]["Starling.programs"] = new Dictionary();
         param2.scaleMode = "noScale";
         param2.align = "TL";
         for each(var _loc7_ in touchEventTypes)
         {
            param2.addEventListener(_loc7_,onTouch,false,0,true);
         }
         param2.addEventListener("enterFrame",onEnterFrame,false,0,true);
         param2.addEventListener("keyDown",onKey,false,0,true);
         param2.addEventListener("keyUp",onKey,false,0,true);
         param2.addEventListener("resize",onResize,false,0,true);
         param2.addEventListener("mouseLeave",onMouseLeave,false,0,true);
         mStage3D.addEventListener("context3DCreate",onContextCreated,false,10,true);
         mStage3D.addEventListener("error",onStage3DError,false,10,true);
         if(mStage3D.context3D && mStage3D.context3D.driverInfo != "Disposed")
         {
            mShareContext = true;
            setTimeout(initialize,1);
         }
         else
         {
            mShareContext = false;
            try
            {
               if((_loc8_ = mStage3D.requestContext3D).length == 1)
               {
                  _loc8_(param5);
               }
               else
               {
                  _loc8_(param5,param6);
               }
            }
            catch(e:Error)
            {
               showFatalError("Context3D error: " + e.message);
            }
         }
      }
      
      public static function get current() : Starling
      {
         return sCurrent;
      }
      
      public static function get context() : Context3D
      {
         return !!sCurrent ? sCurrent.context : null;
      }
      
      public static function get juggler() : Juggler
      {
         return !!sCurrent ? sCurrent.juggler : null;
      }
      
      public static function get contentScaleFactor() : Number
      {
         return !!sCurrent ? sCurrent.contentScaleFactor : 1;
      }
      
      public static function get multitouchEnabled() : Boolean
      {
         return Multitouch.inputMode == "touchPoint";
      }
      
      public static function set multitouchEnabled(param1:Boolean) : void
      {
         if(sCurrent)
         {
            throw new IllegalOperationError("\'multitouchEnabled\' must be set before Starling instance is created");
         }
         Multitouch.inputMode = param1 ? "touchPoint" : "none";
      }
      
      public static function get handleLostContext() : Boolean
      {
         return sHandleLostContext;
      }
      
      public static function set handleLostContext(param1:Boolean) : void
      {
         if(sCurrent)
         {
            throw new IllegalOperationError("\'handleLostContext\' must be set before Starling instance is created");
         }
         sHandleLostContext = param1;
      }
      
      public function dispose() : void
      {
         var _loc2_:Function = null;
         stop(true);
         mNativeStage.removeEventListener("enterFrame",onEnterFrame,false);
         mNativeStage.removeEventListener("keyDown",onKey,false);
         mNativeStage.removeEventListener("keyUp",onKey,false);
         mNativeStage.removeEventListener("resize",onResize,false);
         mNativeStage.removeEventListener("mouseLeave",onMouseLeave,false);
         mNativeStage.removeChild(mNativeOverlay);
         mStage3D.removeEventListener("context3DCreate",onContextCreated,false);
         mStage3D.removeEventListener("error",onStage3DError,false);
         for each(var _loc1_ in touchEventTypes)
         {
            mNativeStage.removeEventListener(_loc1_,onTouch,false);
         }
         if(mStage)
         {
            mStage.dispose();
         }
         if(mSupport)
         {
            mSupport.dispose();
         }
         if(mTouchProcessor)
         {
            mTouchProcessor.dispose();
         }
         if(sCurrent == this)
         {
            sCurrent = null;
         }
         if(mContext && !mShareContext)
         {
            _loc2_ = mContext.dispose;
            if(_loc2_.length == 1)
            {
               _loc2_(false);
            }
            else
            {
               _loc2_();
            }
         }
      }
      
      private function initialize() : void
      {
         makeCurrent();
         initializeGraphicsAPI();
         initializeRoot();
         mTouchProcessor.simulateMultitouch = mSimulateMultitouch;
         mLastFrameTimestamp = getTimer() / 1000;
      }
      
      private function initializeGraphicsAPI() : void
      {
         mContext = mStage3D.context3D;
         mContext.enableErrorChecking = mEnableErrorChecking;
         contextData["Starling.programs"] = new Dictionary();
         updateViewPort(true);
         trace("[Starling] Initialization complete.");
         trace("[Starling] Display Driver:",mContext.driverInfo);
         dispatchEventWith("context3DCreate",false,mContext);
      }
      
      private function initializeRoot() : void
      {
         if(mRoot == null)
         {
            mRoot = new mRootClass() as DisplayObject;
            if(mRoot == null)
            {
               throw new Error("Invalid root class: " + mRootClass);
            }
            mStage.addChildAt(mRoot,0);
            dispatchEventWith("rootCreated",false,mRoot);
         }
      }
      
      public function nextFrame() : void
      {
         var _loc1_:Number = getTimer() / 1000;
         var _loc2_:Number = _loc1_ - mLastFrameTimestamp;
         mLastFrameTimestamp = _loc1_;
         advanceTime(_loc2_);
         render();
      }
      
      public function advanceTime(param1:Number) : void
      {
         makeCurrent();
         mTouchProcessor.advanceTime(param1);
         mStage.advanceTime(param1);
         mJuggler.advanceTime(param1);
      }
      
      public function render() : void
      {
         if(!contextValid)
         {
            return;
         }
         makeCurrent();
         updateViewPort();
         updateNativeOverlay();
         mSupport.nextFrame();
         if(!mShareContext)
         {
            RenderSupport.clear(mStage.color,1);
         }
         var _loc1_:Number = mViewPort.width / mStage.stageWidth;
         var _loc2_:Number = mViewPort.height / mStage.stageHeight;
         mContext.setDepthTest(false,"always");
         mContext.setCulling("none");
         mSupport.renderTarget = null;
         mSupport.setOrthographicProjection(mViewPort.x < 0 ? -mViewPort.x / _loc1_ : 0,mViewPort.y < 0 ? -mViewPort.y / _loc2_ : 0,mClippedViewPort.width / _loc1_,mClippedViewPort.height / _loc2_);
         mStage.render(mSupport,1);
         mSupport.finishQuadBatch();
         if(mStatsDisplay)
         {
            mStatsDisplay.drawCount = mSupport.drawCount;
         }
         if(!mShareContext)
         {
            mContext.present();
         }
      }
      
      private function updateViewPort(param1:Boolean = false) : void
      {
         if(param1 || mPreviousViewPort.width != mViewPort.width || mPreviousViewPort.height != mViewPort.height || mPreviousViewPort.x != mViewPort.x || mPreviousViewPort.y != mViewPort.y)
         {
            mPreviousViewPort.setTo(mViewPort.x,mViewPort.y,mViewPort.width,mViewPort.height);
            mClippedViewPort = mViewPort.intersection(new Rectangle(0,0,mNativeStage.stageWidth,mNativeStage.stageHeight));
            if(!mShareContext)
            {
               if(mProfile == "baselineConstrained")
               {
                  configureBackBuffer(32,32,mAntiAliasing,false);
               }
               mStage3D.x = mClippedViewPort.x;
               mStage3D.y = mClippedViewPort.y;
               configureBackBuffer(mClippedViewPort.width,mClippedViewPort.height,mAntiAliasing,false,mSupportHighResolutions);
               if(mSupportHighResolutions && "contentsScaleFactor" in mNativeStage)
               {
                  mNativeStageContentScaleFactor = mNativeStage["contentsScaleFactor"];
               }
               else
               {
                  mNativeStageContentScaleFactor = 1;
               }
            }
         }
      }
      
      private function configureBackBuffer(param1:int, param2:int, param3:int, param4:Boolean, param5:Boolean = false) : void
      {
         var _loc6_:Function = mContext.configureBackBuffer;
         var _loc7_:Array = [param1,param2,param3,param4];
         if(_loc6_.length > 4)
         {
            _loc7_.push(param5);
         }
         _loc6_.apply(mContext,_loc7_);
      }
      
      private function updateNativeOverlay() : void
      {
         mNativeOverlay.x = mViewPort.x;
         mNativeOverlay.y = mViewPort.y;
         mNativeOverlay.scaleX = mViewPort.width / mStage.stageWidth;
         mNativeOverlay.scaleY = mViewPort.height / mStage.stageHeight;
      }
      
      private function showFatalError(param1:String) : void
      {
         var _loc3_:TextField = new TextField();
         var _loc2_:TextFormat = new TextFormat("Verdana",12,16777215);
         _loc2_.align = "center";
         _loc3_.defaultTextFormat = _loc2_;
         _loc3_.wordWrap = true;
         _loc3_.width = mStage.stageWidth * 0.75;
         _loc3_.autoSize = "center";
         _loc3_.text = param1;
         _loc3_.x = (mStage.stageWidth - _loc3_.width) / 2;
         _loc3_.y = (mStage.stageHeight - _loc3_.height) / 2;
         _loc3_.background = true;
         _loc3_.backgroundColor = 4456448;
         nativeOverlay.addChild(_loc3_);
      }
      
      public function makeCurrent() : void
      {
         sCurrent = this;
      }
      
      public function start() : void
      {
         mStarted = mRendering = true;
         mLastFrameTimestamp = getTimer() / 1000;
      }
      
      public function stop(param1:Boolean = false) : void
      {
         mStarted = false;
         mRendering = !param1;
      }
      
      private function onStage3DError(param1:ErrorEvent) : void
      {
         var _loc2_:String = null;
         if(param1.errorID == 3702)
         {
            _loc2_ = Capabilities.playerType == "Desktop" ? "renderMode" : "wmode";
            showFatalError("Context3D not available! Possible reasons: wrong " + _loc2_ + " or missing device support.");
         }
         else
         {
            showFatalError("Stage3D error: " + param1.text);
         }
      }
      
      private function onContextCreated(param1:Event) : void
      {
         if(!Starling.handleLostContext && mContext)
         {
            stop();
            param1.stopImmediatePropagation();
            showFatalError("Fatal error: The application lost the device context!");
            trace("[Starling] The device context was lost. Enable \'Starling.handleLostContext\' to avoid this error.");
         }
         else
         {
            initialize();
         }
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(!mShareContext)
         {
            if(mStarted)
            {
               nextFrame();
            }
            else if(mRendering)
            {
               render();
            }
         }
      }
      
      private function onKey(param1:flash.events.KeyboardEvent) : void
      {
         if(!mStarted)
         {
            return;
         }
         var _loc2_:starling.events.KeyboardEvent = new starling.events.KeyboardEvent(param1.type,param1.charCode,param1.keyCode,param1.keyLocation,param1.ctrlKey,param1.altKey,param1.shiftKey);
         makeCurrent();
         mStage.broadcastEvent(_loc2_);
         if(_loc2_.isDefaultPrevented())
         {
            param1.preventDefault();
         }
      }
      
      private function onResize(param1:Event) : void
      {
         var _loc2_:flash.display.Stage = param1.target as flash.display.Stage;
         mStage.dispatchEvent(new ResizeEvent("resize",_loc2_.stageWidth,_loc2_.stageHeight));
      }
      
      private function onMouseLeave(param1:Event) : void
      {
         mTouchProcessor.enqueueMouseLeftStage();
      }
      
      private function onTouch(param1:Event) : void
      {
         var _loc6_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc3_:int = 0;
         var _loc10_:String = null;
         var _loc2_:MouseEvent = null;
         var _loc7_:TouchEvent = null;
         if(!mStarted)
         {
            return;
         }
         var _loc5_:Number = 1;
         var _loc8_:Number = 1;
         var _loc4_:Number = 1;
         if(param1 is MouseEvent)
         {
            _loc2_ = param1 as MouseEvent;
            _loc6_ = _loc2_.stageX;
            _loc9_ = _loc2_.stageY;
            _loc3_ = 0;
            if(param1.type == "mouseDown")
            {
               mLeftMouseDown = true;
            }
            else if(param1.type == "mouseUp")
            {
               mLeftMouseDown = false;
            }
         }
         else
         {
            _loc7_ = param1 as TouchEvent;
            if(Mouse.supportsCursor && _loc7_.isPrimaryTouchPoint)
            {
               return;
            }
            _loc6_ = _loc7_.stageX;
            _loc9_ = _loc7_.stageY;
            _loc3_ = _loc7_.touchPointID;
            _loc5_ = _loc7_.pressure;
            _loc8_ = _loc7_.sizeX;
            _loc4_ = _loc7_.sizeY;
         }
         switch(param1.type)
         {
            case "touchBegin":
               _loc10_ = "began";
               break;
            case "touchMove":
               _loc10_ = "moved";
               break;
            case "touchEnd":
               _loc10_ = "ended";
               break;
            case "mouseDown":
               _loc10_ = "began";
               break;
            case "mouseUp":
               _loc10_ = "ended";
               break;
            case "mouseMove":
               _loc10_ = mLeftMouseDown ? "moved" : "hover";
         }
         _loc6_ = mStage.stageWidth * (_loc6_ - mViewPort.x) / mViewPort.width;
         _loc9_ = mStage.stageHeight * (_loc9_ - mViewPort.y) / mViewPort.height;
         mTouchProcessor.enqueue(_loc3_,_loc10_,_loc6_,_loc9_,_loc5_,_loc8_,_loc4_);
         if(param1.type == "mouseUp")
         {
            mTouchProcessor.enqueue(_loc3_,"hover",_loc6_,_loc9_);
         }
      }
      
      private function get touchEventTypes() : Array
      {
         var _loc1_:Array = [];
         if(multitouchEnabled)
         {
            _loc1_.push("touchBegin","touchMove","touchEnd");
         }
         if(!multitouchEnabled || Mouse.supportsCursor)
         {
            _loc1_.push("mouseDown","mouseMove","mouseUp");
         }
         return _loc1_;
      }
      
      public function registerProgram(param1:String, param2:ByteArray, param3:ByteArray) : Program3D
      {
         deleteProgram(param1);
         var _loc4_:Program3D;
         (_loc4_ = mContext.createProgram()).upload(param2,param3);
         programs[param1] = _loc4_;
         return _loc4_;
      }
      
      public function deleteProgram(param1:String) : void
      {
         var _loc2_:Program3D = getProgram(param1);
         if(_loc2_)
         {
            _loc2_.dispose();
            delete programs[param1];
         }
      }
      
      public function getProgram(param1:String) : Program3D
      {
         return programs[param1] as Program3D;
      }
      
      public function hasProgram(param1:String) : Boolean
      {
         return param1 in programs;
      }
      
      private function get programs() : Dictionary
      {
         return contextData["Starling.programs"];
      }
      
      private function get contextValid() : Boolean
      {
         return mContext && mContext.driverInfo != "Disposed";
      }
      
      public function get isStarted() : Boolean
      {
         return mStarted;
      }
      
      public function get juggler() : Juggler
      {
         return mJuggler;
      }
      
      public function get context() : Context3D
      {
         return mContext;
      }
      
      public function get contextData() : Dictionary
      {
         return sContextData[mStage3D] as Dictionary;
      }
      
      public function get backBufferWidth() : int
      {
         return mClippedViewPort.width;
      }
      
      public function get backBufferHeight() : int
      {
         return mClippedViewPort.height;
      }
      
      public function get simulateMultitouch() : Boolean
      {
         return mSimulateMultitouch;
      }
      
      public function set simulateMultitouch(param1:Boolean) : void
      {
         mSimulateMultitouch = param1;
         if(mContext)
         {
            mTouchProcessor.simulateMultitouch = param1;
         }
      }
      
      public function get enableErrorChecking() : Boolean
      {
         return mEnableErrorChecking;
      }
      
      public function set enableErrorChecking(param1:Boolean) : void
      {
         mEnableErrorChecking = param1;
         if(mContext)
         {
            mContext.enableErrorChecking = param1;
         }
      }
      
      public function get antiAliasing() : int
      {
         return mAntiAliasing;
      }
      
      public function set antiAliasing(param1:int) : void
      {
         if(mAntiAliasing != param1)
         {
            mAntiAliasing = param1;
            if(contextValid)
            {
               updateViewPort(true);
            }
         }
      }
      
      public function get viewPort() : Rectangle
      {
         return mViewPort;
      }
      
      public function set viewPort(param1:Rectangle) : void
      {
         mViewPort = param1.clone();
      }
      
      public function get contentScaleFactor() : Number
      {
         return mViewPort.width * mNativeStageContentScaleFactor / mStage.stageWidth;
      }
      
      public function get nativeOverlay() : Sprite
      {
         return mNativeOverlay;
      }
      
      public function get showStats() : Boolean
      {
         return mStatsDisplay && mStatsDisplay.parent;
      }
      
      public function set showStats(param1:Boolean) : void
      {
         if(param1 == showStats)
         {
            return;
         }
         if(param1)
         {
            if(mStatsDisplay)
            {
               mStage.addChild(mStatsDisplay);
            }
            else
            {
               showStatsAt();
            }
         }
         else
         {
            mStatsDisplay.removeFromParent();
         }
      }
      
      public function showStatsAt(param1:String = "left", param2:String = "top", param3:Number = 1) : void
      {
         var stageWidth:int;
         var stageHeight:int;
         var hAlign:String = param1;
         var vAlign:String = param2;
         var scale:Number = param3;
         var onRootCreated:* = function():void
         {
            showStatsAt(hAlign,vAlign,scale);
            removeEventListener("rootCreated",onRootCreated);
         };
         if(mContext == null)
         {
            addEventListener("rootCreated",onRootCreated);
         }
         else
         {
            if(mStatsDisplay == null)
            {
               mStatsDisplay = new StatsDisplay();
               mStatsDisplay.touchable = false;
               mStage.addChild(mStatsDisplay);
            }
            stageWidth = mStage.stageWidth;
            stageHeight = mStage.stageHeight;
            mStatsDisplay.scaleX = mStatsDisplay.scaleY = scale;
            if(hAlign == "left")
            {
               mStatsDisplay.x = 0;
            }
            else if(hAlign == "right")
            {
               mStatsDisplay.x = stageWidth - mStatsDisplay.width;
            }
            else
            {
               mStatsDisplay.x = int((stageWidth - mStatsDisplay.width) / 2);
            }
            if(vAlign == "top")
            {
               mStatsDisplay.y = 0;
            }
            else if(vAlign == "bottom")
            {
               mStatsDisplay.y = stageHeight - mStatsDisplay.height;
            }
            else
            {
               mStatsDisplay.y = int((stageHeight - mStatsDisplay.height) / 2);
            }
         }
      }
      
      public function get stage() : starling.display.Stage
      {
         return mStage;
      }
      
      public function get stage3D() : Stage3D
      {
         return mStage3D;
      }
      
      public function get nativeStage() : flash.display.Stage
      {
         return mNativeStage;
      }
      
      public function get root() : DisplayObject
      {
         return mRoot;
      }
      
      public function get shareContext() : Boolean
      {
         return mShareContext;
      }
      
      public function set shareContext(param1:Boolean) : void
      {
         mShareContext = param1;
      }
      
      public function get profile() : String
      {
         return mProfile;
      }
      
      public function get supportHighResolutions() : Boolean
      {
         return mSupportHighResolutions;
      }
      
      public function set supportHighResolutions(param1:Boolean) : void
      {
         if(mSupportHighResolutions != param1)
         {
            mSupportHighResolutions = param1;
            if(contextValid)
            {
               updateViewPort(true);
            }
         }
      }
      
      public function get touchProcessor() : TouchProcessor
      {
         return mTouchProcessor;
      }
      
      public function set touchProcessor(param1:TouchProcessor) : void
      {
         if(param1 != mTouchProcessor)
         {
            mTouchProcessor.dispose();
            mTouchProcessor = param1;
         }
      }
   }
}
