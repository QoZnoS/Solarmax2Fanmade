package starling.display
{
   import com.adobe.utils.AGALMiniAssembler;
   import flash.display3D.Context3D;
   import flash.display3D.IndexBuffer3D;
   import flash.display3D.VertexBuffer3D;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import starling.core.RenderSupport;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.errors.MissingContextError;
   import starling.filters.FragmentFilter;
   import starling.textures.Texture;
   import starling.utils.MatrixUtil;
   import starling.utils.VertexData;
   
   use namespace starling_internal;
   
   public class QuadBatch extends DisplayObject
   {
      
      public static const MAX_NUM_QUADS:int = 8192;
      
      private static const QUAD_PROGRAM_NAME:String = "QB_q";
      
      private static var sHelperMatrix:Matrix = new Matrix();
      
      private static var sRenderAlpha:Vector.<Number> = new <Number>[1,1,1,1];
      
      private static var sRenderMatrix:Matrix3D = new Matrix3D();
      
      private static var sProgramNameCache:Dictionary = new Dictionary();
       
      
      private var mNumQuads:int;
      
      private var mSyncRequired:Boolean;
      
      private var mBatchable:Boolean;
      
      private var mTinted:Boolean;
      
      private var mTexture:Texture;
      
      private var mSmoothing:String;
      
      private var mVertexBuffer:VertexBuffer3D;
      
      private var mIndexData:Vector.<uint>;
      
      private var mIndexBuffer:IndexBuffer3D;
      
      protected var mVertexData:VertexData;
      
      public function QuadBatch()
      {
         super();
         mVertexData = new VertexData(0,true);
         mIndexData = new Vector.<uint>(0);
         mNumQuads = 0;
         mTinted = false;
         mSyncRequired = false;
         mBatchable = false;
         Starling.current.stage3D.addEventListener("context3DCreate",onContextCreated,false,0,true);
      }
      
      public static function compile(param1:DisplayObject, param2:Vector.<QuadBatch>) : void
      {
         compileObject(param1,param2,-1,new Matrix());
      }
      
      private static function compileObject(param1:DisplayObject, param2:Vector.<QuadBatch>, param3:int, param4:Matrix, param5:Number = 1, param6:String = null, param7:Boolean = false) : int
      {
         var _loc15_:int = 0;
         var _loc11_:QuadBatch = null;
         var _loc23_:int = 0;
         var _loc19_:Matrix = null;
         var _loc16_:DisplayObject = null;
         var _loc14_:String = null;
         var _loc8_:Texture = null;
         var _loc10_:String = null;
         var _loc13_:Boolean = false;
         var _loc9_:int = 0;
         var _loc12_:Image = null;
         var _loc21_:Boolean = false;
         var _loc17_:Number = param1.alpha;
         var _loc22_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         var _loc18_:Quad = param1 as Quad;
         var _loc20_:QuadBatch = param1 as QuadBatch;
         var _loc24_:FragmentFilter = param1.filter;
         if(param3 == -1)
         {
            _loc21_ = true;
            param3 = 0;
            _loc17_ = 1;
            param6 = param1.blendMode;
            param7 = true;
            if(param2.length == 0)
            {
               param2.push(new QuadBatch());
            }
            else
            {
               param2[0].reset();
            }
         }
         if(_loc24_ && !param7)
         {
            if(_loc24_.mode == "above")
            {
               param3 = compileObject(param1,param2,param3,param4,param5,param6,true);
            }
            param3 = compileObject(_loc24_.starling_internal::compile(param1),param2,param3,param4,param5,param6);
            if(_loc24_.mode == "below")
            {
               param3 = compileObject(param1,param2,param3,param4,param5,param6,true);
            }
         }
         else if(_loc22_)
         {
            _loc23_ = _loc22_.numChildren;
            _loc19_ = new Matrix();
            _loc15_ = 0;
            while(_loc15_ < _loc23_)
            {
               if((_loc16_ = _loc22_.getChildAt(_loc15_)).hasVisibleArea)
               {
                  _loc14_ = _loc16_.blendMode == "auto" ? param6 : _loc16_.blendMode;
                  _loc19_.copyFrom(param4);
                  RenderSupport.transformMatrixForObject(_loc19_,_loc16_);
                  param3 = compileObject(_loc16_,param2,param3,_loc19_,param5 * _loc17_,_loc14_);
               }
               _loc15_++;
            }
         }
         else
         {
            if(!(_loc18_ || _loc20_))
            {
               throw new Error("Unsupported display object: " + getQualifiedClassName(param1));
            }
            if(_loc18_)
            {
               _loc8_ = !!(_loc12_ = _loc18_ as Image) ? _loc12_.texture : null;
               _loc10_ = String(!!_loc12_ ? _loc12_.smoothing : null);
               _loc13_ = _loc18_.tinted;
               _loc9_ = 1;
            }
            else
            {
               _loc8_ = _loc20_.mTexture;
               _loc10_ = _loc20_.mSmoothing;
               _loc13_ = _loc20_.mTinted;
               _loc9_ = _loc20_.mNumQuads;
            }
            if((_loc11_ = param2[param3]).isStateChange(_loc13_,param5 * _loc17_,_loc8_,_loc10_,param6,_loc9_))
            {
               param3++;
               if(param2.length <= param3)
               {
                  param2.push(new QuadBatch());
               }
               (_loc11_ = param2[param3]).reset();
            }
            if(_loc18_)
            {
               _loc11_.addQuad(_loc18_,param5,_loc8_,_loc10_,param4,param6);
            }
            else
            {
               _loc11_.addQuadBatch(_loc20_,param5,param4,param6);
            }
         }
         if(_loc21_)
         {
            _loc15_ = param2.length - 1;
            while(_loc15_ > param3)
            {
               param2.pop().dispose();
               _loc15_--;
            }
         }
         return param3;
      }
      
      private static function registerPrograms() : void
      {
         var _loc2_:String = null;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc11_:Array = null;
         var _loc1_:String = null;
         var _loc4_:Starling;
         if((_loc4_ = Starling.current).hasProgram("QB_q"))
         {
            return;
         }
         var _loc12_:AGALMiniAssembler = new AGALMiniAssembler();
         _loc2_ = "m44 op, va0, vc1 \nmul v0, va1, vc0 \n";
         _loc8_ = "mov oc, v0       \n";
         _loc4_.registerProgram("QB_q",_loc12_.assemble("vertex",_loc2_),_loc12_.assemble("fragment",_loc8_));
         for each(var _loc5_ in [true,false])
         {
            _loc2_ = !!_loc5_ ? "m44 op, va0, vc1 \nmul v0, va1, vc0 \nmov v1, va2      \n" : "m44 op, va0, vc1 \nmov v1, va2      \n";
            _loc8_ = _loc5_ ? "tex ft1,  v1, fs0 <???> \nmul  oc, ft1,  v0       \n" : "tex  oc,  v1, fs0 <???> \n";
            _loc9_ = ["none","bilinear","trilinear"];
            _loc11_ = ["bgra","compressed","compressedAlpha"];
            for each(var _loc7_ in [true,false])
            {
               for each(var _loc10_ in [true,false])
               {
                  for each(var _loc3_ in _loc9_)
                  {
                     for each(var _loc6_ in _loc11_)
                     {
                        _loc1_ = RenderSupport.getTextureLookupFlags(_loc6_,_loc10_,_loc7_,_loc3_);
                        _loc4_.registerProgram(getImageProgramName(_loc5_,_loc10_,_loc7_,_loc6_,_loc3_),_loc12_.assemble("vertex",_loc2_),_loc12_.assemble("fragment",_loc8_.replace("<???>",_loc1_)));
                     }
                  }
               }
            }
         }
      }
      
      private static function getImageProgramName(param1:Boolean, param2:Boolean = true, param3:Boolean = false, param4:String = "bgra", param5:String = "bilinear") : String
      {
         var _loc7_:* = 0;
         if(param1)
         {
            _loc7_ |= 1;
         }
         if(param2)
         {
            _loc7_ |= 2;
         }
         if(param3)
         {
            _loc7_ |= 4;
         }
         if(param5 == "none")
         {
            _loc7_ |= 8;
         }
         else if(param5 == "trilinear")
         {
            _loc7_ |= 16;
         }
         if(param4 == "compressed")
         {
            _loc7_ |= 32;
         }
         else if(param4 == "compressedAlpha")
         {
            _loc7_ |= 64;
         }
         var _loc6_:String;
         if((_loc6_ = String(sProgramNameCache[_loc7_])) == null)
         {
            _loc6_ = "QB_i." + _loc7_.toString(16);
            sProgramNameCache[_loc7_] = _loc6_;
         }
         return _loc6_;
      }
      
      override public function dispose() : void
      {
         Starling.current.stage3D.removeEventListener("context3DCreate",onContextCreated);
         mVertexData.numVertices = 0;
         mIndexData.length = 0;
         if(mVertexBuffer)
         {
            mVertexBuffer.dispose();
            mVertexBuffer = null;
         }
         if(mIndexBuffer)
         {
            mIndexBuffer.dispose();
            mIndexBuffer = null;
         }
         super.dispose();
      }
      
      private function onContextCreated(param1:Object) : void
      {
         createBuffers();
         registerPrograms();
      }
      
      protected function onVertexDataChanged() : void
      {
         mSyncRequired = true;
      }
      
      public function clone() : QuadBatch
      {
         var _loc1_:QuadBatch = new QuadBatch();
         _loc1_.mVertexData = mVertexData.clone(0,mNumQuads * 4);
         _loc1_.mIndexData = mIndexData.slice(0,mNumQuads * 6);
         _loc1_.mNumQuads = mNumQuads;
         _loc1_.mTinted = mTinted;
         _loc1_.mTexture = mTexture;
         _loc1_.mSmoothing = mSmoothing;
         _loc1_.mSyncRequired = true;
         _loc1_.blendMode = blendMode;
         _loc1_.alpha = alpha;
         return _loc1_;
      }
      
      private function expand() : void
      {
         var _loc1_:int = this.capacity;
         this.capacity = _loc1_ < 8 ? 16 : _loc1_ * 2;
      }
      
      private function createBuffers() : void
      {
         var _loc3_:int = mVertexData.numVertices;
         var _loc1_:int = int(mIndexData.length);
         var _loc2_:Context3D = Starling.context;
         if(mVertexBuffer)
         {
            mVertexBuffer.dispose();
         }
         if(mIndexBuffer)
         {
            mIndexBuffer.dispose();
         }
         if(_loc3_ == 0)
         {
            return;
         }
         if(_loc2_ == null)
         {
            throw new MissingContextError();
         }
         mVertexBuffer = _loc2_.createVertexBuffer(_loc3_,8);
         mVertexBuffer.uploadFromVector(mVertexData.rawData,0,_loc3_);
         mIndexBuffer = _loc2_.createIndexBuffer(_loc1_);
         mIndexBuffer.uploadFromVector(mIndexData,0,_loc1_);
         mSyncRequired = false;
      }
      
      private function syncBuffers() : void
      {
         if(mVertexBuffer == null)
         {
            registerPrograms();
            createBuffers();
         }
         else
         {
            mVertexBuffer.uploadFromVector(mVertexData.rawData,0,mVertexData.numVertices);
            mSyncRequired = false;
         }
      }
      
      public function renderCustom(param1:Matrix, param2:Number = 1, param3:String = null) : void
      {
         if(mNumQuads == 0)
         {
            return;
         }
         if(mSyncRequired)
         {
            syncBuffers();
         }
         var _loc6_:Boolean = mVertexData.premultipliedAlpha;
         var _loc4_:Context3D = Starling.context;
         var _loc5_:Boolean = mTinted || param2 != 1;
         var _loc7_:String = !!mTexture ? getImageProgramName(_loc5_,mTexture.mipMapping,mTexture.repeat,mTexture.format,mSmoothing) : "QB_q";
         sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = _loc6_ ? param2 : 1;
         sRenderAlpha[3] = param2;
         MatrixUtil.convertTo3D(param1,sRenderMatrix);
         RenderSupport.setBlendFactors(_loc6_,!!param3 ? param3 : this.blendMode);
         _loc4_.setProgram(Starling.current.getProgram(_loc7_));
         _loc4_.setProgramConstantsFromVector("vertex",0,sRenderAlpha,1);
         _loc4_.setProgramConstantsFromMatrix("vertex",1,sRenderMatrix,true);
         _loc4_.setVertexBufferAt(0,mVertexBuffer,0,"float2");
         if(mTexture == null || _loc5_)
         {
            _loc4_.setVertexBufferAt(1,mVertexBuffer,2,"float4");
         }
         if(mTexture)
         {
            _loc4_.setTextureAt(0,mTexture.base);
            _loc4_.setVertexBufferAt(2,mVertexBuffer,6,"float2");
         }
         _loc4_.drawTriangles(mIndexBuffer,0,mNumQuads * 2);
         if(mTexture)
         {
            _loc4_.setTextureAt(0,null);
            _loc4_.setVertexBufferAt(2,null);
         }
         _loc4_.setVertexBufferAt(1,null);
         _loc4_.setVertexBufferAt(0,null);
      }
      
      public function reset() : void
      {
         mNumQuads = 0;
         mTexture = null;
         mSmoothing = null;
         mSyncRequired = true;
      }
      
      public function addImage(param1:Image, param2:Number = 1, param3:Matrix = null, param4:String = null) : void
      {
         addQuad(param1,param2,param1.texture,param1.smoothing,param3,param4);
      }
      
      public function addQuad(param1:Quad, param2:Number = 1, param3:Texture = null, param4:String = null, param5:Matrix = null, param6:String = null) : void
      {
         if(param5 == null)
         {
            param5 = param1.transformationMatrix;
         }
         var _loc8_:Number = param2 * param1.alpha;
         var _loc7_:int = mNumQuads * 4;
         if(mNumQuads + 1 > mVertexData.numVertices / 4)
         {
            expand();
         }
         if(mNumQuads == 0)
         {
            this.blendMode = !!param6 ? param6 : param1.blendMode;
            mTexture = param3;
            mTinted = !!param3 ? param1.tinted || param2 != 1 : false;
            mSmoothing = param4;
            mVertexData.setPremultipliedAlpha(param1.premultipliedAlpha);
         }
         param1.copyVertexDataTransformedTo(mVertexData,_loc7_,param5);
         if(_loc8_ != 1)
         {
            mVertexData.scaleAlpha(_loc7_,_loc8_,4);
         }
         mSyncRequired = true;
         mNumQuads++;
      }
      
      public function addQuadBatch(param1:QuadBatch, param2:Number = 1, param3:Matrix = null, param4:String = null) : void
      {
         if(param3 == null)
         {
            param3 = param1.transformationMatrix;
         }
         var _loc8_:Boolean = param1.mTinted || param2 != 1;
         var _loc6_:Number = param2 * param1.alpha;
         var _loc5_:int = mNumQuads * 4;
         var _loc7_:int = param1.numQuads;
         if(mNumQuads + _loc7_ > capacity)
         {
            capacity = mNumQuads + _loc7_;
         }
         if(mNumQuads == 0)
         {
            this.blendMode = !!param4 ? param4 : param1.blendMode;
            mTexture = param1.mTexture;
            mTinted = _loc8_;
            mSmoothing = param1.mSmoothing;
            mVertexData.setPremultipliedAlpha(param1.mVertexData.premultipliedAlpha,false);
         }
         param1.mVertexData.copyTransformedTo(mVertexData,_loc5_,param3,0,_loc7_ * 4);
         if(_loc6_ != 1)
         {
            mVertexData.scaleAlpha(_loc5_,_loc6_,_loc7_ * 4);
         }
         mSyncRequired = true;
         mNumQuads += _loc7_;
      }
      
      public function isStateChange(param1:Boolean, param2:Number, param3:Texture, param4:String, param5:String, param6:int = 1) : Boolean
      {
         if(mNumQuads == 0)
         {
            return false;
         }
         if(mNumQuads + param6 > 8192)
         {
            return true;
         }
         if(mTexture == null && param3 == null)
         {
            return this.blendMode != param5;
         }
         if(mTexture != null && param3 != null)
         {
            return mTexture.base != param3.base || mTexture.repeat != param3.repeat || mSmoothing != param4 || mTinted != (param1 || param2 != 1) || this.blendMode != param5;
         }
         return true;
      }
      
      public function transformQuad(param1:int, param2:Matrix) : void
      {
         mVertexData.transformVertex(param1 * 4,param2,4);
         mSyncRequired = true;
      }
      
      public function getVertexColor(param1:int, param2:int) : uint
      {
         return mVertexData.getColor(param1 * 4 + param2);
      }
      
      public function setVertexColor(param1:int, param2:int, param3:uint) : void
      {
         mVertexData.setColor(param1 * 4 + param2,param3);
         mSyncRequired = true;
      }
      
      public function getVertexAlpha(param1:int, param2:int) : Number
      {
         return mVertexData.getAlpha(param1 * 4 + param2);
      }
      
      public function setVertexAlpha(param1:int, param2:int, param3:Number) : void
      {
         mVertexData.setAlpha(param1 * 4 + param2,param3);
         mSyncRequired = true;
      }
      
      public function getQuadColor(param1:int) : uint
      {
         return mVertexData.getColor(param1 * 4);
      }
      
      public function setQuadColor(param1:int, param2:uint) : void
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < 4)
         {
            mVertexData.setColor(param1 * 4 + _loc3_,param2);
            _loc3_++;
         }
         mSyncRequired = true;
      }
      
      public function getQuadAlpha(param1:int) : Number
      {
         return mVertexData.getAlpha(param1 * 4);
      }
      
      public function setQuadAlpha(param1:int, param2:Number) : void
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < 4)
         {
            mVertexData.setAlpha(param1 * 4 + _loc3_,param2);
            _loc3_++;
         }
         mSyncRequired = true;
      }
      
      public function getQuadBounds(param1:int, param2:Matrix = null, param3:Rectangle = null) : Rectangle
      {
         return mVertexData.getBounds(param2,param1 * 4,4,param3);
      }
      
      override public function getBounds(param1:DisplayObject, param2:Rectangle = null) : Rectangle
      {
         if(param2 == null)
         {
            param2 = new Rectangle();
         }
         var _loc3_:Matrix = param1 == this ? null : getTransformationMatrix(param1,sHelperMatrix);
         return mVertexData.getBounds(_loc3_,0,mNumQuads * 4,param2);
      }
      
      override public function render(param1:RenderSupport, param2:Number) : void
      {
         if(mNumQuads)
         {
            if(mBatchable)
            {
               param1.batchQuadBatch(this,param2);
            }
            else
            {
               param1.finishQuadBatch();
               param1.raiseDrawCount();
               renderCustom(param1.mvpMatrix,alpha * param2,param1.blendMode);
            }
         }
      }
      
      public function get numQuads() : int
      {
         return mNumQuads;
      }
      
      public function get tinted() : Boolean
      {
         return mTinted;
      }
      
      public function get texture() : Texture
      {
         return mTexture;
      }
      
      public function get smoothing() : String
      {
         return mSmoothing;
      }
      
      public function get premultipliedAlpha() : Boolean
      {
         return mVertexData.premultipliedAlpha;
      }
      
      public function get batchable() : Boolean
      {
         return mBatchable;
      }
      
      public function set batchable(param1:Boolean) : void
      {
         mBatchable = param1;
      }
      
      public function get capacity() : int
      {
         return mVertexData.numVertices / 4;
      }
      
      public function set capacity(param1:int) : void
      {
         var _loc3_:* = 0;
         var _loc2_:int = capacity;
         if(param1 == _loc2_)
         {
            return;
         }
         if(param1 == 0)
         {
            throw new Error("Capacity must be > 0");
         }
         if(param1 > 8192)
         {
            param1 = 8192;
         }
         if(mNumQuads > param1)
         {
            mNumQuads = param1;
         }
         mVertexData.numVertices = param1 * 4;
         mIndexData.length = param1 * 6;
         _loc3_ = _loc2_;
         while(_loc3_ < param1)
         {
            mIndexData[int(_loc3_ * 6)] = _loc3_ * 4;
            mIndexData[int(_loc3_ * 6 + 1)] = _loc3_ * 4 + 1;
            mIndexData[int(_loc3_ * 6 + 2)] = _loc3_ * 4 + 2;
            mIndexData[int(_loc3_ * 6 + 3)] = _loc3_ * 4 + 1;
            mIndexData[int(_loc3_ * 6 + 4)] = _loc3_ * 4 + 3;
            mIndexData[int(_loc3_ * 6 + 5)] = _loc3_ * 4 + 2;
            _loc3_++;
         }
         createBuffers();
         registerPrograms();
      }
   }
}
