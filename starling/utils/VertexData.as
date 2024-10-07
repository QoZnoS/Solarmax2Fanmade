package starling.utils
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class VertexData
   {
      
      public static const ELEMENTS_PER_VERTEX:int = 8;
      
      public static const POSITION_OFFSET:int = 0;
      
      public static const COLOR_OFFSET:int = 2;
      
      public static const TEXCOORD_OFFSET:int = 6;
      
      private static var sHelperPoint:Point = new Point();
       
      
      private var mRawData:Vector.<Number>;
      
      private var mPremultipliedAlpha:Boolean;
      
      private var mNumVertices:int;
      
      public function VertexData(param1:int, param2:Boolean = false)
      {
         super();
         mRawData = new Vector.<Number>(0);
         mPremultipliedAlpha = param2;
         this.numVertices = param1;
      }
      
      public function clone(param1:int = 0, param2:int = -1) : VertexData
      {
         if(param2 < 0 || param1 + param2 > mNumVertices)
         {
            param2 = mNumVertices - param1;
         }
         var _loc3_:VertexData = new VertexData(0,mPremultipliedAlpha);
         _loc3_.mNumVertices = param2;
         _loc3_.mRawData = mRawData.slice(param1 * 8,param2 * 8);
         _loc3_.mRawData.fixed = true;
         return _loc3_;
      }
      
      public function copyTo(param1:VertexData, param2:int = 0, param3:int = 0, param4:int = -1) : void
      {
         copyTransformedTo(param1,param2,null,param3,param4);
      }
      
      public function copyTransformedTo(param1:VertexData, param2:int = 0, param3:Matrix = null, param4:int = 0, param5:int = -1) : void
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(param5 < 0 || param4 + param5 > mNumVertices)
         {
            param5 = mNumVertices - param4;
         }
         var _loc8_:Vector.<Number> = param1.mRawData;
         var _loc7_:int = param2 * 8;
         var _loc9_:int = param4 * 8;
         var _loc6_:int = (param4 + param5) * 8;
         if(param3)
         {
            while(_loc9_ < _loc6_)
            {
               _loc11_ = mRawData[_loc9_++];
               _loc10_ = mRawData[_loc9_++];
               _loc8_[_loc7_++] = param3.a * _loc11_ + param3.c * _loc10_ + param3.tx;
               _loc8_[_loc7_++] = param3.d * _loc10_ + param3.b * _loc11_ + param3.ty;
               _loc8_[_loc7_++] = mRawData[_loc9_++];
               _loc8_[_loc7_++] = mRawData[_loc9_++];
               _loc8_[_loc7_++] = mRawData[_loc9_++];
               _loc8_[_loc7_++] = mRawData[_loc9_++];
               _loc8_[_loc7_++] = mRawData[_loc9_++];
               _loc8_[_loc7_++] = mRawData[_loc9_++];
            }
         }
         else
         {
            while(_loc9_ < _loc6_)
            {
               _loc8_[_loc7_++] = mRawData[_loc9_++];
            }
         }
      }
      
      public function append(param1:VertexData) : void
      {
         var _loc5_:int = 0;
         mRawData.fixed = false;
         var _loc2_:int = int(mRawData.length);
         var _loc3_:Vector.<Number> = param1.mRawData;
         var _loc4_:int = int(_loc3_.length);
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            mRawData[_loc2_++] = _loc3_[_loc5_];
            _loc5_++;
         }
         mNumVertices += param1.numVertices;
         mRawData.fixed = true;
      }
      
      public function setPosition(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:int = param1 * 8 + 0;
         mRawData[_loc4_] = param2;
         mRawData[_loc4_ + 1] = param3;
      }
      
      public function getPosition(param1:int, param2:Point) : void
      {
         var _loc3_:int = param1 * 8 + 0;
         param2.x = mRawData[_loc3_];
         param2.y = mRawData[_loc3_ + 1];
      }
      
      public function setColorAndAlpha(param1:int, param2:uint, param3:Number) : void
      {
         if(param3 < 0.001)
         {
            param3 = 0.001;
         }
         else if(param3 > 1)
         {
            param3 = 1;
         }
         var _loc4_:int = param1 * 8 + 2;
         var _loc5_:Number = mPremultipliedAlpha ? param3 : 1;
         mRawData[_loc4_] = (param2 >> 16 & 255) / 255 * _loc5_;
         mRawData[_loc4_ + 1] = (param2 >> 8 & 255) / 255 * _loc5_;
         mRawData[_loc4_ + 2] = (param2 & 255) / 255 * _loc5_;
         mRawData[_loc4_ + 3] = param3;
      }
      
      public function setColor(param1:int, param2:uint) : void
      {
         var _loc3_:int = param1 * 8 + 2;
         var _loc4_:Number = mPremultipliedAlpha ? mRawData[_loc3_ + 3] : 1;
         mRawData[_loc3_] = (param2 >> 16 & 255) / 255 * _loc4_;
         mRawData[_loc3_ + 1] = (param2 >> 8 & 255) / 255 * _loc4_;
         mRawData[_loc3_ + 2] = (param2 & 255) / 255 * _loc4_;
      }
      
      public function getColor(param1:int) : uint
      {
         var _loc2_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc6_:int = param1 * 8 + 2;
         if((mPremultipliedAlpha ? mRawData[_loc6_ + 3] : 1) == 0)
         {
            return 0;
         }
         _loc2_ = mRawData[_loc6_] / 1;
         _loc4_ = mRawData[_loc6_ + 1] / 1;
         _loc3_ = mRawData[_loc6_ + 2] / 1;
         return int(_loc2_ * 255) << 16 | int(_loc4_ * 255) << 8 | int(_loc3_ * 255);
      }
      
      public function setAlpha(param1:int, param2:Number) : void
      {
         if(mPremultipliedAlpha)
         {
            setColorAndAlpha(param1,getColor(param1),param2);
         }
         else
         {
            mRawData[int(param1 * 8 + 2 + 3)] = param2;
         }
      }
      
      public function getAlpha(param1:int) : Number
      {
         var _loc2_:int = param1 * 8 + 2 + 3;
         return mRawData[_loc2_];
      }
      
      public function setTexCoords(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:int = param1 * 8 + 6;
         mRawData[_loc4_] = param2;
         mRawData[_loc4_ + 1] = param3;
      }
      
      public function getTexCoords(param1:int, param2:Point) : void
      {
         var _loc3_:int = param1 * 8 + 6;
         param2.x = mRawData[_loc3_];
         param2.y = mRawData[_loc3_ + 1];
      }
      
      public function translateVertex(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:int;
         var _loc5_:* = _loc4_ = param1 * 8 + 0;
         var _loc6_:* = mRawData[_loc5_] + param2;
         mRawData[_loc5_] = _loc6_;
         mRawData[_loc4_ + 1] += param3;
      }
      
      public function transformVertex(param1:int, param2:Matrix, param3:int = 1) : void
      {
         var _loc5_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc6_:int = 0;
         var _loc4_:int = param1 * 8 + 0;
         _loc6_ = 0;
         while(_loc6_ < param3)
         {
            _loc7_ = mRawData[_loc4_];
            _loc5_ = mRawData[_loc4_ + 1];
            mRawData[_loc4_] = param2.a * _loc7_ + param2.c * _loc5_ + param2.tx;
            mRawData[_loc4_ + 1] = param2.d * _loc5_ + param2.b * _loc7_ + param2.ty;
            _loc4_ += 8;
            _loc6_++;
         }
      }
      
      public function setUniformColor(param1:uint) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < mNumVertices)
         {
            setColor(_loc2_,param1);
            _loc2_++;
         }
      }
      
      public function setUniformAlpha(param1:Number) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < mNumVertices)
         {
            setAlpha(_loc2_,param1);
            _loc2_++;
         }
      }
      
      public function scaleAlpha(param1:int, param2:Number, param3:int = 1) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         if(param2 == 1)
         {
            return;
         }
         if(param3 < 0 || param1 + param3 > mNumVertices)
         {
            param3 = mNumVertices - param1;
         }
         if(mPremultipliedAlpha)
         {
            _loc5_ = 0;
            while(_loc5_ < param3)
            {
               setAlpha(param1 + _loc5_,getAlpha(param1 + _loc5_) * param2);
               _loc5_++;
            }
         }
         else
         {
            _loc4_ = param1 * 8 + 2 + 3;
            _loc5_ = 0;
            while(_loc5_ < param3)
            {
               var _loc6_:int = _loc4_ + _loc5_ * 8;
               var _loc7_:* = mRawData[_loc6_] * param2;
               mRawData[_loc6_] = _loc7_;
               _loc5_++;
            }
         }
      }
      
      public function getBounds(param1:Matrix = null, param2:int = 0, param3:int = -1, param4:Rectangle = null) : Rectangle
      {
         var _loc9_:* = NaN;
         var _loc12_:* = NaN;
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         var _loc11_:int = 0;
         var _loc10_:Number = NaN;
         if(param4 == null)
         {
            param4 = new Rectangle();
         }
         if(param3 < 0 || param2 + param3 > mNumVertices)
         {
            param3 = mNumVertices - param2;
         }
         if(param3 == 0)
         {
            if(param1 == null)
            {
               param4.setEmpty();
            }
            else
            {
               MatrixUtil.transformCoords(param1,0,0,sHelperPoint);
               param4.setTo(sHelperPoint.x,sHelperPoint.y,0,0);
            }
         }
         else
         {
            _loc9_ = 1.7976931348623157e+308;
            var _loc6_:* = -1.7976931348623157e+308;
            _loc12_ = 1.7976931348623157e+308;
            var _loc5_:* = -1.7976931348623157e+308;
            _loc7_ = param2 * 8 + 0;
            if(param1 == null)
            {
               _loc11_ = 0;
               while(_loc11_ < param3)
               {
                  _loc10_ = mRawData[_loc7_];
                  _loc8_ = mRawData[_loc7_ + 1];
                  _loc7_ += 8;
                  if(_loc9_ > _loc10_)
                  {
                     _loc9_ = _loc10_;
                  }
                  if(_loc6_ < _loc10_)
                  {
                     _loc6_ = _loc10_;
                  }
                  if(_loc12_ > _loc8_)
                  {
                     _loc12_ = _loc8_;
                  }
                  if(_loc5_ < _loc8_)
                  {
                     _loc5_ = _loc8_;
                  }
                  _loc11_++;
               }
            }
            else
            {
               _loc11_ = 0;
               while(_loc11_ < param3)
               {
                  _loc10_ = mRawData[_loc7_];
                  _loc8_ = mRawData[_loc7_ + 1];
                  _loc7_ += 8;
                  MatrixUtil.transformCoords(param1,_loc10_,_loc8_,sHelperPoint);
                  if(_loc9_ > sHelperPoint.x)
                  {
                     _loc9_ = sHelperPoint.x;
                  }
                  if(_loc6_ < sHelperPoint.x)
                  {
                     _loc6_ = sHelperPoint.x;
                  }
                  if(_loc12_ > sHelperPoint.y)
                  {
                     _loc12_ = sHelperPoint.y;
                  }
                  if(_loc5_ < sHelperPoint.y)
                  {
                     _loc5_ = sHelperPoint.y;
                  }
                  _loc11_++;
               }
            }
            param4.setTo(_loc9_,_loc12_,_loc6_ - _loc9_,_loc5_ - _loc12_);
         }
         return param4;
      }
      
      public function toString() : String
      {
         var _loc5_:int = 0;
         var _loc2_:String = "[VertexData \n";
         var _loc1_:Point = new Point();
         var _loc3_:Point = new Point();
         _loc5_ = 0;
         while(_loc5_ < numVertices)
         {
            getPosition(_loc5_,_loc1_);
            getTexCoords(_loc5_,_loc3_);
            _loc2_ += "  [Vertex " + _loc5_ + ": " + "x=" + _loc1_.x.toFixed(1) + ", " + "y=" + _loc1_.y.toFixed(1) + ", " + "rgb=" + getColor(_loc5_).toString(16) + ", " + "a=" + getAlpha(_loc5_).toFixed(2) + ", " + "u=" + _loc3_.x.toFixed(4) + ", " + "v=" + _loc3_.y.toFixed(4) + "]" + (_loc5_ == numVertices - 1 ? "\n" : ",\n");
            _loc5_++;
         }
         return _loc2_ + "]";
      }
      
      public function get tinted() : Boolean
      {
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:int = 2;
         _loc3_ = 0;
         while(_loc3_ < mNumVertices)
         {
            _loc1_ = 0;
            while(_loc1_ < 4)
            {
               if(mRawData[_loc2_ + _loc1_] != 1)
               {
                  return true;
               }
               _loc1_++;
            }
            _loc2_ += 8;
            _loc3_++;
         }
         return false;
      }
      
      public function setPremultipliedAlpha(param1:Boolean, param2:Boolean = true) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(param1 == mPremultipliedAlpha)
         {
            return;
         }
         if(param2)
         {
            _loc6_ = mNumVertices * 8;
            _loc7_ = 2;
            while(_loc7_ < _loc6_)
            {
               _loc3_ = mRawData[_loc7_ + 3];
               _loc4_ = mPremultipliedAlpha ? _loc3_ : 1;
               _loc5_ = param1 ? _loc3_ : 1;
               if(_loc4_ != 0)
               {
                  mRawData[_loc7_] = mRawData[_loc7_] / _loc4_ * _loc5_;
                  mRawData[_loc7_ + 1] = mRawData[_loc7_ + 1] / _loc4_ * _loc5_;
                  mRawData[_loc7_ + 2] = mRawData[_loc7_ + 2] / _loc4_ * _loc5_;
               }
               _loc7_ += 8;
            }
         }
         mPremultipliedAlpha = param1;
      }
      
      public function get premultipliedAlpha() : Boolean
      {
         return mPremultipliedAlpha;
      }
      
      public function set premultipliedAlpha(param1:Boolean) : void
      {
         setPremultipliedAlpha(param1);
      }
      
      public function get numVertices() : int
      {
         return mNumVertices;
      }
      
      public function set numVertices(param1:int) : void
      {
         var _loc2_:int = 0;
         mRawData.fixed = false;
         mRawData.length = param1 * 8;
         _loc2_ = mNumVertices;
         while(_loc2_ < param1)
         {
            mRawData[int(_loc2_ * 8 + 2 + 3)] = 1;
            _loc2_++;
         }
         mNumVertices = param1;
         mRawData.fixed = true;
      }
      
      public function get rawData() : Vector.<Number>
      {
         return mRawData;
      }
   }
}
