package starling.filters
{
   import flash.display3D.Context3D;
   import flash.display3D.IndexBuffer3D;
   import flash.display3D.Program3D;
   import flash.display3D.VertexBuffer3D;
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.utils.getQualifiedClassName;
   import starling.core.RenderSupport;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.QuadBatch;
   import starling.display.Stage;
   import starling.errors.AbstractClassError;
   import starling.errors.MissingContextError;
   import starling.textures.Texture;
   import starling.utils.MatrixUtil;
   import starling.utils.RectangleUtil;
   import starling.utils.VertexData;
   import starling.utils.getNextPowerOfTwo;
   
   use namespace starling_internal;
   
   public class FragmentFilter
   {
      
      private static var sBounds:Rectangle = new Rectangle();
      
      private static var sBoundsPot:Rectangle = new Rectangle();
      
      private static var sStageBounds:Rectangle = new Rectangle();
      
      private static var sTransformationMatrix:Matrix = new Matrix();
       
      
      private const MIN_TEXTURE_SIZE:int = 64;
      
      protected const PMA:Boolean = true;
      
      protected const STD_VERTEX_SHADER:String = "m44 op, va0, vc0 \nmov v0, va1      \n";
      
      protected const STD_FRAGMENT_SHADER:String = "tex oc, v0, fs0 <2d, clamp, linear, mipnone>";
      
      private var mVertexPosAtID:int = 0;
      
      private var mTexCoordsAtID:int = 1;
      
      private var mBaseTextureID:int = 0;
      
      private var mMvpConstantID:int = 0;
      
      private var mNumPasses:int;
      
      private var mPassTextures:Vector.<Texture>;
      
      private var mMode:String;
      
      private var mResolution:Number;
      
      private var mMarginX:Number;
      
      private var mMarginY:Number;
      
      private var mOffsetX:Number;
      
      private var mOffsetY:Number;
      
      private var mVertexData:VertexData;
      
      private var mVertexBuffer:VertexBuffer3D;
      
      private var mIndexData:Vector.<uint>;
      
      private var mIndexBuffer:IndexBuffer3D;
      
      private var mCacheRequested:Boolean;
      
      private var mCache:QuadBatch;
      
      private var mProjMatrix:Matrix;
      
      public function FragmentFilter(param1:int = 1, param2:Number = 1)
      {
         mProjMatrix = new Matrix();
         super();
         if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.filters::FragmentFilter")
         {
            throw new AbstractClassError();
         }
         if(param1 < 1)
         {
            throw new ArgumentError("At least one pass is required.");
         }
         mNumPasses = param1;
         mMarginX = mMarginY = 0;
         mOffsetX = mOffsetY = 0;
         mResolution = param2;
         mMode = "replace";
         mVertexData = new VertexData(4);
         mVertexData.setTexCoords(0,0,0);
         mVertexData.setTexCoords(1,1,0);
         mVertexData.setTexCoords(2,0,1);
         mVertexData.setTexCoords(3,1,1);
         mIndexData = new <uint>[0,1,2,1,3,2];
         mIndexData.fixed = true;
         createPrograms();
         Starling.current.stage3D.addEventListener("context3DCreate",onContextCreated,false,0,true);
      }
      
      public function dispose() : void
      {
         Starling.current.stage3D.removeEventListener("context3DCreate",onContextCreated);
         if(mVertexBuffer)
         {
            mVertexBuffer.dispose();
         }
         if(mIndexBuffer)
         {
            mIndexBuffer.dispose();
         }
         disposePassTextures();
         disposeCache();
      }
      
      private function onContextCreated(param1:Object) : void
      {
         mVertexBuffer = null;
         mIndexBuffer = null;
         mPassTextures = null;
         createPrograms();
      }
      
      public function render(param1:DisplayObject, param2:RenderSupport, param3:Number) : void
      {
         if(mode == "above")
         {
            param1.render(param2,param3);
         }
         if(mCacheRequested)
         {
            mCacheRequested = false;
            mCache = renderPasses(param1,param2,1,true);
            disposePassTextures();
         }
         if(mCache)
         {
            mCache.render(param2,param3);
         }
         else
         {
            renderPasses(param1,param2,param3,false);
         }
         if(mode == "below")
         {
            param1.render(param2,param3);
         }
      }
      
      private function renderPasses(param1:DisplayObject, param2:RenderSupport, param3:Number, param4:Boolean = false) : QuadBatch
      {
         var _loc8_:Texture = null;
         var _loc10_:int = 0;
         var _loc6_:QuadBatch = null;
         var _loc7_:Image = null;
         var _loc11_:Texture = null;
         var _loc9_:Stage = param1.stage;
         var _loc13_:Context3D = Starling.context;
         var _loc5_:Number = Starling.current.contentScaleFactor;
         if(_loc9_ == null)
         {
            throw new Error("Filtered object must be on the stage.");
         }
         if(_loc13_ == null)
         {
            throw new MissingContextError();
         }
         calculateBounds(param1,_loc9_,mResolution * _loc5_,!param4,sBounds,sBoundsPot);
         if(sBounds.isEmpty())
         {
            disposePassTextures();
            return param4 ? new QuadBatch() : null;
         }
         updateBuffers(_loc13_,sBoundsPot);
         updatePassTextures(sBoundsPot.width,sBoundsPot.height,mResolution * _loc5_);
         param2.finishQuadBatch();
         param2.raiseDrawCount(mNumPasses);
         param2.pushMatrix();
         mProjMatrix.copyFrom(param2.projectionMatrix);
         var _loc12_:Texture;
         if(_loc12_ = param2.renderTarget)
         {
            throw new IllegalOperationError("It\'s currently not possible to stack filters! This limitation will be removed in a future Stage3D version.");
         }
         if(param4)
         {
            _loc11_ = Texture.empty(sBoundsPot.width,sBoundsPot.height,true,false,true,mResolution * _loc5_);
         }
         param2.renderTarget = mPassTextures[0];
         param2.clear();
         param2.blendMode = "normal";
         param2.setOrthographicProjection(sBounds.x,sBounds.y,sBoundsPot.width,sBoundsPot.height);
         param1.render(param2,param3);
         param2.finishQuadBatch();
         RenderSupport.setBlendFactors(true);
         param2.loadIdentity();
         param2.pushClipRect(sBounds);
         _loc13_.setVertexBufferAt(mVertexPosAtID,mVertexBuffer,0,"float2");
         _loc13_.setVertexBufferAt(mTexCoordsAtID,mVertexBuffer,6,"float2");
         _loc10_ = 0;
         while(_loc10_ < mNumPasses)
         {
            if(_loc10_ < mNumPasses - 1)
            {
               param2.renderTarget = getPassTexture(_loc10_ + 1);
               param2.clear();
            }
            else if(param4)
            {
               param2.renderTarget = _loc11_;
               param2.clear();
            }
            else
            {
               param2.projectionMatrix = mProjMatrix;
               param2.renderTarget = _loc12_;
               param2.translateMatrix(mOffsetX,mOffsetY);
               param2.blendMode = param1.blendMode;
               param2.applyBlendMode(true);
            }
            _loc8_ = getPassTexture(_loc10_);
            _loc13_.setProgramConstantsFromMatrix("vertex",mMvpConstantID,param2.mvpMatrix3D,true);
            _loc13_.setTextureAt(mBaseTextureID,_loc8_.base);
            activate(_loc10_,_loc13_,_loc8_);
            _loc13_.drawTriangles(mIndexBuffer,0,2);
            deactivate(_loc10_,_loc13_,_loc8_);
            _loc10_++;
         }
         _loc13_.setVertexBufferAt(mVertexPosAtID,null);
         _loc13_.setVertexBufferAt(mTexCoordsAtID,null);
         _loc13_.setTextureAt(mBaseTextureID,null);
         param2.popMatrix();
         param2.popClipRect();
         if(param4)
         {
            param2.renderTarget = _loc12_;
            param2.projectionMatrix.copyFrom(mProjMatrix);
            _loc6_ = new QuadBatch();
            _loc7_ = new Image(_loc11_);
            _loc9_.getTransformationMatrix(param1,sTransformationMatrix);
            MatrixUtil.prependTranslation(sTransformationMatrix,sBounds.x + mOffsetX,sBounds.y + mOffsetY);
            _loc6_.addImage(_loc7_,1,sTransformationMatrix);
            return _loc6_;
         }
         return null;
      }
      
      private function updateBuffers(param1:Context3D, param2:Rectangle) : void
      {
         mVertexData.setPosition(0,param2.x,param2.y);
         mVertexData.setPosition(1,param2.right,param2.y);
         mVertexData.setPosition(2,param2.x,param2.bottom);
         mVertexData.setPosition(3,param2.right,param2.bottom);
         if(mVertexBuffer == null)
         {
            mVertexBuffer = param1.createVertexBuffer(4,8);
            mIndexBuffer = param1.createIndexBuffer(6);
            mIndexBuffer.uploadFromVector(mIndexData,0,6);
         }
         mVertexBuffer.uploadFromVector(mVertexData.rawData,0,4);
      }
      
      private function updatePassTextures(param1:int, param2:int, param3:Number) : void
      {
         var _loc7_:int = 0;
         var _loc5_:int = mNumPasses > 1 ? 2 : 1;
         var _loc6_:Boolean;
         if(_loc6_ = mPassTextures == null || mPassTextures.length != _loc5_ || mPassTextures[0].width != param1 || mPassTextures[0].height != param2)
         {
            if(mPassTextures)
            {
               for each(var _loc4_ in mPassTextures)
               {
                  _loc4_.dispose();
               }
               mPassTextures.length = _loc5_;
            }
            else
            {
               mPassTextures = new Vector.<Texture>(_loc5_);
            }
            _loc7_ = 0;
            while(_loc7_ < _loc5_)
            {
               mPassTextures[_loc7_] = Texture.empty(param1,param2,true,false,true,param3);
               _loc7_++;
            }
         }
      }
      
      private function getPassTexture(param1:int) : Texture
      {
         return mPassTextures[param1 % 2];
      }
      
      private function calculateBounds(param1:DisplayObject, param2:Stage, param3:Number, param4:Boolean, param5:Rectangle, param6:Rectangle) : void
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         var _loc7_:Number = NaN;
         if(param1 == param2 || param1 == Starling.current.root)
         {
            _loc10_ = 0;
            _loc11_ = 0;
            param5.setTo(0,0,param2.stageWidth,param2.stageHeight);
         }
         else
         {
            _loc11_ = mMarginX;
            _loc10_ = mMarginY;
            param1.getBounds(param2,param5);
         }
         if(param4)
         {
            sStageBounds.setTo(0,0,param2.stageWidth,param2.stageHeight);
            RectangleUtil.intersect(param5,sStageBounds,param5);
         }
         if(!param5.isEmpty())
         {
            param5.inflate(_loc11_,_loc10_);
            _loc8_ = 64 / param3;
            _loc9_ = Number(param5.width > _loc8_ ? param5.width : _loc8_);
            _loc7_ = Number(param5.height > _loc8_ ? param5.height : _loc8_);
            param6.setTo(param5.x,param5.y,getNextPowerOfTwo(_loc9_ * param3) / param3,getNextPowerOfTwo(_loc7_ * param3) / param3);
         }
      }
      
      private function disposePassTextures() : void
      {
         for each(var _loc1_ in mPassTextures)
         {
            _loc1_.dispose();
         }
         mPassTextures = null;
      }
      
      private function disposeCache() : void
      {
         if(mCache)
         {
            if(mCache.texture)
            {
               mCache.texture.dispose();
            }
            mCache.dispose();
            mCache = null;
         }
      }
      
      protected function createPrograms() : void
      {
         throw new Error("Method has to be implemented in subclass!");
      }
      
      protected function activate(param1:int, param2:Context3D, param3:Texture) : void
      {
         throw new Error("Method has to be implemented in subclass!");
      }
      
      protected function deactivate(param1:int, param2:Context3D, param3:Texture) : void
      {
      }
      
      protected function assembleAgal(param1:String = null, param2:String = null) : Program3D
      {
         if(param1 == null)
         {
            param1 = "tex oc, v0, fs0 <2d, clamp, linear, mipnone>";
         }
         if(param2 == null)
         {
            param2 = "m44 op, va0, vc0 \nmov v0, va1      \n";
         }
         return RenderSupport.assembleAgal(param2,param1);
      }
      
      public function cache() : void
      {
         mCacheRequested = true;
         disposeCache();
      }
      
      public function clearCache() : void
      {
         mCacheRequested = false;
         disposeCache();
      }
      
      starling_internal function compile(param1:DisplayObject) : QuadBatch
      {
         var _loc2_:RenderSupport = null;
         var _loc3_:Stage = null;
         if(mCache)
         {
            return mCache;
         }
         _loc3_ = param1.stage;
         if(_loc3_ == null)
         {
            throw new Error("Filtered object must be on the stage.");
         }
         _loc2_ = new RenderSupport();
         param1.getTransformationMatrix(_loc3_,_loc2_.modelViewMatrix);
         return renderPasses(param1,_loc2_,1,true);
      }
      
      public function get isCached() : Boolean
      {
         return mCache != null || mCacheRequested;
      }
      
      public function get resolution() : Number
      {
         return mResolution;
      }
      
      public function set resolution(param1:Number) : void
      {
         if(param1 <= 0)
         {
            throw new ArgumentError("Resolution must be > 0");
         }
         mResolution = param1;
      }
      
      public function get mode() : String
      {
         return mMode;
      }
      
      public function set mode(param1:String) : void
      {
         mMode = param1;
      }
      
      public function get offsetX() : Number
      {
         return mOffsetX;
      }
      
      public function set offsetX(param1:Number) : void
      {
         mOffsetX = param1;
      }
      
      public function get offsetY() : Number
      {
         return mOffsetY;
      }
      
      public function set offsetY(param1:Number) : void
      {
         mOffsetY = param1;
      }
      
      protected function get marginX() : Number
      {
         return mMarginX;
      }
      
      protected function set marginX(param1:Number) : void
      {
         mMarginX = param1;
      }
      
      protected function get marginY() : Number
      {
         return mMarginY;
      }
      
      protected function set marginY(param1:Number) : void
      {
         mMarginY = param1;
      }
      
      protected function set numPasses(param1:int) : void
      {
         mNumPasses = param1;
      }
      
      protected function get numPasses() : int
      {
         return mNumPasses;
      }
      
      final protected function get vertexPosAtID() : int
      {
         return mVertexPosAtID;
      }
      
      final protected function set vertexPosAtID(param1:int) : void
      {
         mVertexPosAtID = param1;
      }
      
      final protected function get texCoordsAtID() : int
      {
         return mTexCoordsAtID;
      }
      
      final protected function set texCoordsAtID(param1:int) : void
      {
         mTexCoordsAtID = param1;
      }
      
      final protected function get baseTextureID() : int
      {
         return mBaseTextureID;
      }
      
      final protected function set baseTextureID(param1:int) : void
      {
         mBaseTextureID = param1;
      }
      
      final protected function get mvpConstantID() : int
      {
         return mMvpConstantID;
      }
      
      final protected function set mvpConstantID(param1:int) : void
      {
         mMvpConstantID = param1;
      }
   }
}
