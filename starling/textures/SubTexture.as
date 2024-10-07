package starling.textures
{
   import flash.display3D.textures.TextureBase;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.utils.VertexData;
   
   public class SubTexture extends Texture
   {
      
      private static var sTexCoords:Point = new Point();
       
      
      private var mParent:Texture;
      
      private var mClipping:Rectangle;
      
      private var mRootClipping:Rectangle;
      
      private var mOwnsParent:Boolean;
      
      public function SubTexture(param1:Texture, param2:Rectangle, param3:Boolean = false)
      {
         super();
         mParent = param1;
         mOwnsParent = param3;
         if(param2 == null)
         {
            setClipping(new Rectangle(0,0,1,1));
         }
         else
         {
            setClipping(new Rectangle(param2.x / param1.width,param2.y / param1.height,param2.width / param1.width,param2.height / param1.height));
         }
      }
      
      override public function dispose() : void
      {
         if(mOwnsParent)
         {
            mParent.dispose();
         }
         super.dispose();
      }
      
      private function setClipping(param1:Rectangle) : void
      {
         var _loc3_:Rectangle = null;
         mClipping = param1;
         mRootClipping = param1.clone();
         var _loc2_:SubTexture = mParent as SubTexture;
         while(_loc2_)
         {
            _loc3_ = _loc2_.mClipping;
            mRootClipping.x = _loc3_.x + mRootClipping.x * _loc3_.width;
            mRootClipping.y = _loc3_.y + mRootClipping.y * _loc3_.height;
            mRootClipping.width *= _loc3_.width;
            mRootClipping.height *= _loc3_.height;
            _loc2_ = _loc2_.mParent as SubTexture;
         }
      }
      
      override public function adjustVertexData(param1:VertexData, param2:int, param3:int) : void
      {
         var _loc9_:* = 0;
         super.adjustVertexData(param1,param2,param3);
         var _loc5_:Number = mRootClipping.x;
         var _loc6_:Number = mRootClipping.y;
         var _loc8_:Number = mRootClipping.width;
         var _loc4_:Number = mRootClipping.height;
         var _loc7_:int = param2 + param3;
         _loc9_ = param2;
         while(_loc9_ < _loc7_)
         {
            param1.getTexCoords(_loc9_,sTexCoords);
            param1.setTexCoords(_loc9_,_loc5_ + sTexCoords.x * _loc8_,_loc6_ + sTexCoords.y * _loc4_);
            _loc9_++;
         }
      }
      
      override public function adjustTexCoords(param1:Vector.<Number>, param2:int = 0, param3:int = 0, param4:int = -1) : void
      {
         var _loc6_:int = 0;
         if(param4 < 0)
         {
            param4 = (param1.length - param2 - 2) / (param3 + 2) + 1;
         }
         var _loc5_:* = param2;
         _loc6_ = 0;
         while(_loc6_ < param4)
         {
            param1[_loc5_] = mRootClipping.x + param1[_loc5_] * mRootClipping.width;
            _loc5_ += 1;
            param1[_loc5_] = mRootClipping.y + param1[_loc5_] * mRootClipping.height;
            _loc5_ += 1 + param3;
            _loc6_++;
         }
      }
      
      public function get parent() : Texture
      {
         return mParent;
      }
      
      public function get ownsParent() : Boolean
      {
         return mOwnsParent;
      }
      
      public function get clipping() : Rectangle
      {
         return mClipping.clone();
      }
      
      override public function get base() : TextureBase
      {
         return mParent.base;
      }
      
      override public function get root() : ConcreteTexture
      {
         return mParent.root;
      }
      
      override public function get format() : String
      {
         return mParent.format;
      }
      
      override public function get width() : Number
      {
         return mParent.width * mClipping.width;
      }
      
      override public function get height() : Number
      {
         return mParent.height * mClipping.height;
      }
      
      override public function get nativeWidth() : Number
      {
         return mParent.nativeWidth * mClipping.width;
      }
      
      override public function get nativeHeight() : Number
      {
         return mParent.nativeHeight * mClipping.height;
      }
      
      override public function get mipMapping() : Boolean
      {
         return mParent.mipMapping;
      }
      
      override public function get premultipliedAlpha() : Boolean
      {
         return mParent.premultipliedAlpha;
      }
      
      override public function get scale() : Number
      {
         return mParent.scale;
      }
   }
}
