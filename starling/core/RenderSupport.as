package starling.core
{
   import com.adobe.utils.AGALMiniAssembler;
   import flash.display3D.Context3D;
   import flash.display3D.Program3D;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.display.BlendMode;
   import starling.display.DisplayObject;
   import starling.display.Quad;
   import starling.display.QuadBatch;
   import starling.errors.MissingContextError;
   import starling.textures.Texture;
   import starling.utils.Color;
   import starling.utils.MatrixUtil;
   import starling.utils.RectangleUtil;
   
   public class RenderSupport
   {
      
      private static var sPoint:Point = new Point();
      
      private static var sClipRect:Rectangle = new Rectangle();
      
      private static var sBufferRect:Rectangle = new Rectangle();
      
      private static var sScissorRect:Rectangle = new Rectangle();
      
      private static var sAssembler:AGALMiniAssembler = new AGALMiniAssembler();
       
      
      private var mProjectionMatrix:Matrix;
      
      private var mModelViewMatrix:Matrix;
      
      private var mMvpMatrix:Matrix;
      
      private var mMvpMatrix3D:Matrix3D;
      
      private var mMatrixStack:Vector.<Matrix>;
      
      private var mMatrixStackSize:int;
      
      private var mDrawCount:int;
      
      private var mBlendMode:String;
      
      private var mRenderTarget:Texture;
      
      private var mClipRectStack:Vector.<Rectangle>;
      
      private var mClipRectStackSize:int;
      
      private var mQuadBatches:Vector.<QuadBatch>;
      
      private var mCurrentQuadBatchID:int;
      
      public function RenderSupport()
      {
         super();
         mProjectionMatrix = new Matrix();
         mModelViewMatrix = new Matrix();
         mMvpMatrix = new Matrix();
         mMvpMatrix3D = new Matrix3D();
         mMatrixStack = new Vector.<Matrix>(0);
         mMatrixStackSize = 0;
         mDrawCount = 0;
         mRenderTarget = null;
         mBlendMode = "normal";
         mClipRectStack = new Vector.<Rectangle>(0);
         mCurrentQuadBatchID = 0;
         mQuadBatches = new <QuadBatch>[new QuadBatch()];
         loadIdentity();
         setOrthographicProjection(0,0,400,300);
      }
      
      public static function transformMatrixForObject(param1:Matrix, param2:DisplayObject) : void
      {
         MatrixUtil.prependMatrix(param1,param2.transformationMatrix);
      }
      
      public static function setDefaultBlendFactors(param1:Boolean) : void
      {
         setBlendFactors(param1);
      }
      
      public static function setBlendFactors(param1:Boolean, param2:String = "normal") : void
      {
         var _loc3_:Array = BlendMode.getBlendFactors(param2,param1);
         Starling.context.setBlendFactors(_loc3_[0],_loc3_[1]);
      }
      
      public static function clear(param1:uint = 0, param2:Number = 0) : void
      {
         Starling.context.clear(Color.getRed(param1) / 255,Color.getGreen(param1) / 255,Color.getBlue(param1) / 255,param2);
      }
      
      public static function assembleAgal(param1:String, param2:String, param3:Program3D = null) : Program3D
      {
         var _loc4_:Context3D = null;
         if(param3 == null)
         {
            if((_loc4_ = Starling.context) == null)
            {
               throw new MissingContextError();
            }
            param3 = _loc4_.createProgram();
         }
         param3.upload(sAssembler.assemble("vertex",param1),sAssembler.assemble("fragment",param2));
         return param3;
      }
      
      public static function getTextureLookupFlags(param1:String, param2:Boolean, param3:Boolean = false, param4:String = "bilinear") : String
      {
         var _loc5_:Array = ["2d",param3 ? "repeat" : "clamp"];
         if(param1 == "compressed")
         {
            _loc5_.push("dxt1");
         }
         else if(param1 == "compressedAlpha")
         {
            _loc5_.push("dxt5");
         }
         if(param4 == "none")
         {
            _loc5_.push("nearest",param2 ? "mipnearest" : "mipnone");
         }
         else if(param4 == "bilinear")
         {
            _loc5_.push("linear",param2 ? "mipnearest" : "mipnone");
         }
         else
         {
            _loc5_.push("linear",param2 ? "miplinear" : "mipnone");
         }
         return "<" + _loc5_.join() + ">";
      }
      
      public function dispose() : void
      {
         for each(var _loc1_ in mQuadBatches)
         {
            _loc1_.dispose();
         }
      }
      
      public function setOrthographicProjection(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         mProjectionMatrix.setTo(2 / param3,0,0,-2 / param4,-(2 * param1 + param3) / param3,(2 * param2 + param4) / param4);
         applyClipRect();
      }
      
      public function loadIdentity() : void
      {
         mModelViewMatrix.identity();
      }
      
      public function translateMatrix(param1:Number, param2:Number) : void
      {
         MatrixUtil.prependTranslation(mModelViewMatrix,param1,param2);
      }
      
      public function rotateMatrix(param1:Number) : void
      {
         MatrixUtil.prependRotation(mModelViewMatrix,param1);
      }
      
      public function scaleMatrix(param1:Number, param2:Number) : void
      {
         MatrixUtil.prependScale(mModelViewMatrix,param1,param2);
      }
      
      public function prependMatrix(param1:Matrix) : void
      {
         MatrixUtil.prependMatrix(mModelViewMatrix,param1);
      }
      
      public function transformMatrix(param1:DisplayObject) : void
      {
         MatrixUtil.prependMatrix(mModelViewMatrix,param1.transformationMatrix);
      }
      
      public function pushMatrix() : void
      {
         if(mMatrixStack.length < mMatrixStackSize + 1)
         {
            mMatrixStack.push(new Matrix());
         }
         mMatrixStack[mMatrixStackSize++].copyFrom(mModelViewMatrix);
      }
      
      public function popMatrix() : void
      {
         mModelViewMatrix.copyFrom(mMatrixStack[--mMatrixStackSize]);
      }
      
      public function resetMatrix() : void
      {
         mMatrixStackSize = 0;
         loadIdentity();
      }
      
      public function get mvpMatrix() : Matrix
      {
         mMvpMatrix.copyFrom(mModelViewMatrix);
         mMvpMatrix.concat(mProjectionMatrix);
         return mMvpMatrix;
      }
      
      public function get mvpMatrix3D() : Matrix3D
      {
         return MatrixUtil.convertTo3D(mvpMatrix,mMvpMatrix3D);
      }
      
      public function get modelViewMatrix() : Matrix
      {
         return mModelViewMatrix;
      }
      
      public function get projectionMatrix() : Matrix
      {
         return mProjectionMatrix;
      }
      
      public function set projectionMatrix(param1:Matrix) : void
      {
         mProjectionMatrix.copyFrom(param1);
         applyClipRect();
      }
      
      public function applyBlendMode(param1:Boolean) : void
      {
         setBlendFactors(param1,mBlendMode);
      }
      
      public function get blendMode() : String
      {
         return mBlendMode;
      }
      
      public function set blendMode(param1:String) : void
      {
         if(param1 != "auto")
         {
            mBlendMode = param1;
         }
      }
      
      public function get renderTarget() : Texture
      {
         return mRenderTarget;
      }
      
      public function set renderTarget(param1:Texture) : void
      {
         mRenderTarget = param1;
         applyClipRect();
         if(param1)
         {
            Starling.context.setRenderToTexture(param1.base);
         }
         else
         {
            Starling.context.setRenderToBackBuffer();
         }
      }
      
      public function pushClipRect(param1:Rectangle) : Rectangle
      {
         if(mClipRectStack.length < mClipRectStackSize + 1)
         {
            mClipRectStack.push(new Rectangle());
         }
         mClipRectStack[mClipRectStackSize].copyFrom(param1);
         param1 = mClipRectStack[mClipRectStackSize];
         if(mClipRectStackSize > 0)
         {
            RectangleUtil.intersect(param1,mClipRectStack[mClipRectStackSize - 1],param1);
         }
         ++mClipRectStackSize;
         applyClipRect();
         return param1;
      }
      
      public function popClipRect() : void
      {
         if(mClipRectStackSize > 0)
         {
            --mClipRectStackSize;
            applyClipRect();
         }
      }
      
      public function applyClipRect() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:Rectangle = null;
         finishQuadBatch();
         var _loc3_:Context3D = Starling.context;
         if(_loc3_ == null)
         {
            return;
         }
         if(mClipRectStackSize > 0)
         {
            _loc4_ = mClipRectStack[mClipRectStackSize - 1];
            if(mRenderTarget)
            {
               _loc2_ = mRenderTarget.root.nativeWidth;
               _loc1_ = mRenderTarget.root.nativeHeight;
            }
            else
            {
               _loc2_ = Starling.current.backBufferWidth;
               _loc1_ = Starling.current.backBufferHeight;
            }
            MatrixUtil.transformCoords(mProjectionMatrix,_loc4_.x,_loc4_.y,sPoint);
            sClipRect.x = (sPoint.x * 0.5 + 0.5) * _loc2_;
            sClipRect.y = (0.5 - sPoint.y * 0.5) * _loc1_;
            MatrixUtil.transformCoords(mProjectionMatrix,_loc4_.right,_loc4_.bottom,sPoint);
            sClipRect.right = (sPoint.x * 0.5 + 0.5) * _loc2_;
            sClipRect.bottom = (0.5 - sPoint.y * 0.5) * _loc1_;
            sBufferRect.setTo(0,0,_loc2_,_loc1_);
            RectangleUtil.intersect(sClipRect,sBufferRect,sScissorRect);
            if(sScissorRect.width < 1 || sScissorRect.height < 1)
            {
               sScissorRect.setTo(0,0,1,1);
            }
            _loc3_.setScissorRectangle(sScissorRect);
         }
         else
         {
            _loc3_.setScissorRectangle(null);
         }
      }
      
      public function batchQuad(param1:Quad, param2:Number, param3:Texture = null, param4:String = null) : void
      {
         if(mQuadBatches[mCurrentQuadBatchID].isStateChange(param1.tinted,param2,param3,param4,mBlendMode))
         {
            finishQuadBatch();
         }
         mQuadBatches[mCurrentQuadBatchID].addQuad(param1,param2,param3,param4,mModelViewMatrix,mBlendMode);
      }
      
      public function batchQuadBatch(param1:QuadBatch, param2:Number) : void
      {
         if(mQuadBatches[mCurrentQuadBatchID].isStateChange(param1.tinted,param2,param1.texture,param1.smoothing,mBlendMode))
         {
            finishQuadBatch();
         }
         mQuadBatches[mCurrentQuadBatchID].addQuadBatch(param1,param2,mModelViewMatrix,mBlendMode);
      }
      
      public function finishQuadBatch() : void
      {
         var _loc1_:QuadBatch = mQuadBatches[mCurrentQuadBatchID];
         if(_loc1_.numQuads != 0)
         {
            _loc1_.renderCustom(mProjectionMatrix);
            _loc1_.reset();
            ++mCurrentQuadBatchID;
            ++mDrawCount;
            if(mQuadBatches.length <= mCurrentQuadBatchID)
            {
               mQuadBatches.push(new QuadBatch());
            }
         }
      }
      
      public function nextFrame() : void
      {
         resetMatrix();
         trimQuadBatches();
         mCurrentQuadBatchID = 0;
         mBlendMode = "normal";
         mDrawCount = 0;
      }
      
      private function trimQuadBatches() : void
      {
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:int = mCurrentQuadBatchID + 1;
         var _loc1_:int = int(mQuadBatches.length);
         if(_loc1_ >= 16 && _loc1_ > 2 * _loc3_)
         {
            _loc2_ = _loc1_ - _loc3_;
            _loc4_ = 0;
            while(_loc4_ < _loc2_)
            {
               mQuadBatches.pop().dispose();
               _loc4_++;
            }
         }
      }
      
      public function clear(param1:uint = 0, param2:Number = 0) : void
      {
         RenderSupport.clear(param1,param2);
      }
      
      public function raiseDrawCount(param1:uint = 1) : void
      {
         mDrawCount += param1;
      }
      
      public function get drawCount() : int
      {
         return mDrawCount;
      }
   }
}
