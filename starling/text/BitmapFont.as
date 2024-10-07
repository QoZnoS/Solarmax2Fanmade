package starling.text
{
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import starling.display.Image;
   import starling.display.QuadBatch;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class BitmapFont
   {
      
      public static const NATIVE_SIZE:int = -1;
      
      public static const MINI:String = "mini";
      
      private static const CHAR_SPACE:int = 32;
      
      private static const CHAR_TAB:int = 9;
      
      private static const CHAR_NEWLINE:int = 10;
      
      private static const CHAR_CARRIAGE_RETURN:int = 13;
       
      
      private var mTexture:Texture;
      
      private var mChars:Dictionary;
      
      private var mName:String;
      
      private var mSize:Number;
      
      private var mLineHeight:Number;
      
      private var mBaseline:Number;
      
      private var mHelperImage:Image;
      
      private var mCharLocationPool:Vector.<CharLocation>;
      
      public function BitmapFont(param1:Texture = null, param2:XML = null)
      {
         super();
         if(param1 == null && param2 == null)
         {
            param1 = MiniBitmapFont.texture;
            param2 = MiniBitmapFont.xml;
         }
         mName = "unknown";
         mLineHeight = mSize = mBaseline = 14;
         mTexture = param1;
         mChars = new Dictionary();
         mHelperImage = new Image(param1);
         mCharLocationPool = new Vector.<CharLocation>(0);
         if(param2)
         {
            parseFontXml(param2);
         }
      }
      
      public function dispose() : void
      {
         if(mTexture)
         {
            mTexture.dispose();
         }
      }
      
      private function parseFontXml(param1:XML) : void
      {
         var _loc12_:int = 0;
         var _loc14_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc2_:Rectangle = null;
         var _loc8_:Texture = null;
         var _loc10_:BitmapChar = null;
         var _loc15_:int = 0;
         var _loc5_:int = 0;
         var _loc11_:Number = NaN;
         var _loc3_:Number = mTexture.scale;
         var _loc13_:Rectangle = mTexture.frame;
         mName = param1.info.attribute("face");
         mSize = parseFloat(param1.info.attribute("size")) / _loc3_;
         mLineHeight = parseFloat(param1.common.attribute("lineHeight")) / _loc3_;
         mBaseline = parseFloat(param1.common.attribute("base")) / _loc3_;
         if(param1.info.attribute("smooth").toString() == "0")
         {
            smoothing = "none";
         }
         if(mSize <= 0)
         {
            trace("[Starling] Warning: invalid font size in \'" + mName + "\' font.");
            mSize = mSize == 0 ? 16 : mSize * -1;
         }
         for each(var _loc9_ in param1.chars.char)
         {
            _loc12_ = parseInt(_loc9_.attribute("id"));
            _loc14_ = parseFloat(_loc9_.attribute("xoffset")) / _loc3_;
            _loc4_ = parseFloat(_loc9_.attribute("yoffset")) / _loc3_;
            _loc7_ = parseFloat(_loc9_.attribute("xadvance")) / _loc3_;
            _loc2_ = new Rectangle();
            _loc2_.x = parseFloat(_loc9_.attribute("x")) / _loc3_ + _loc13_.x;
            _loc2_.y = parseFloat(_loc9_.attribute("y")) / _loc3_ + _loc13_.y;
            _loc2_.width = parseFloat(_loc9_.attribute("width")) / _loc3_;
            _loc2_.height = parseFloat(_loc9_.attribute("height")) / _loc3_;
            _loc8_ = Texture.fromTexture(mTexture,_loc2_);
            _loc10_ = new BitmapChar(_loc12_,_loc8_,_loc14_,_loc4_,_loc7_);
            addChar(_loc12_,_loc10_);
         }
         for each(var _loc6_ in param1.kernings.kerning)
         {
            _loc15_ = parseInt(_loc6_.attribute("first"));
            _loc5_ = parseInt(_loc6_.attribute("second"));
            _loc11_ = parseFloat(_loc6_.attribute("amount")) / _loc3_;
            if(_loc5_ in mChars)
            {
               getChar(_loc5_).addKerning(_loc15_,_loc11_);
            }
         }
      }
      
      public function getChar(param1:int) : BitmapChar
      {
         return mChars[param1];
      }
      
      public function addChar(param1:int, param2:BitmapChar) : void
      {
         mChars[param1] = param2;
      }
      
      public function createSprite(param1:Number, param2:Number, param3:String, param4:Number = -1, param5:uint = 16777215, param6:String = "center", param7:String = "center", param8:Boolean = true, param9:Boolean = true) : Sprite
      {
         var _loc14_:int = 0;
         var _loc15_:CharLocation = null;
         var _loc12_:Image = null;
         var _loc11_:Vector.<CharLocation>;
         var _loc10_:int = int((_loc11_ = arrangeChars(param1,param2,param3,param4,param6,param7,param8,param9)).length);
         var _loc13_:Sprite = new Sprite();
         _loc14_ = 0;
         while(_loc14_ < _loc10_)
         {
            (_loc12_ = (_loc15_ = _loc11_[_loc14_]).char.createImage()).x = _loc15_.x;
            _loc12_.y = _loc15_.y;
            _loc12_.scaleX = _loc12_.scaleY = _loc15_.scale;
            _loc12_.color = param5;
            _loc13_.addChild(_loc12_);
            _loc14_++;
         }
         return _loc13_;
      }
      
      public function fillQuadBatch(param1:QuadBatch, param2:Number, param3:Number, param4:String, param5:Number = -1, param6:uint = 16777215, param7:String = "center", param8:String = "center", param9:Boolean = true, param10:Boolean = true) : void
      {
         var _loc13_:int = 0;
         var _loc14_:CharLocation = null;
         var _loc12_:Vector.<CharLocation>;
         var _loc11_:int = int((_loc12_ = arrangeChars(param2,param3,param4,param5,param7,param8,param9,param10)).length);
         mHelperImage.color = param6;
         if(_loc11_ > 8192)
         {
            throw new ArgumentError("Bitmap Font text is limited to 8192 characters.");
         }
         _loc13_ = 0;
         while(_loc13_ < _loc11_)
         {
            _loc14_ = _loc12_[_loc13_];
            mHelperImage.texture = _loc14_.char.texture;
            mHelperImage.readjustSize();
            mHelperImage.x = _loc14_.x;
            mHelperImage.y = _loc14_.y;
            mHelperImage.scaleX = mHelperImage.scaleY = _loc14_.scale;
            param1.addImage(mHelperImage);
            _loc13_++;
         }
      }
      
      private function arrangeChars(param1:Number, param2:Number, param3:String, param4:Number = -1, param5:String = "center", param6:String = "center", param7:Boolean = true, param8:Boolean = true) : Vector.<CharLocation>
      {
         var _loc33_:* = undefined;
         var _loc31_:CharLocation = null;
         var _loc20_:int = 0;
         var _loc13_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc9_:* = 0;
         var _loc26_:* = 0;
         var _loc36_:Number = NaN;
         var _loc34_:Number = NaN;
         var _loc29_:* = undefined;
         var _loc28_:int = 0;
         var _loc24_:Boolean = false;
         var _loc17_:int = 0;
         var _loc14_:BitmapChar = null;
         var _loc15_:int = 0;
         var _loc18_:int = 0;
         var _loc35_:int = 0;
         var _loc16_:* = undefined;
         var _loc30_:int = 0;
         var _loc27_:CharLocation = null;
         var _loc19_:Number = NaN;
         var _loc22_:int = 0;
         if(param3 == null || param3.length == 0)
         {
            return new Vector.<CharLocation>(0);
         }
         if(param4 < 0)
         {
            param4 *= -mSize;
         }
         var _loc25_:Boolean = false;
         while(!_loc25_)
         {
            _loc10_ = param4 / mSize;
            _loc13_ = param1 / _loc10_;
            _loc23_ = param2 / _loc10_;
            _loc33_ = new Vector.<Vector.<CharLocation>>();
            if(mLineHeight <= _loc23_)
            {
               _loc9_ = -1;
               _loc26_ = -1;
               _loc36_ = 0;
               _loc34_ = 0;
               _loc29_ = new Vector.<CharLocation>(0);
               _loc20_ = param3.length;
               _loc28_ = 0;
               while(_loc28_ < _loc20_)
               {
                  _loc24_ = false;
                  _loc17_ = param3.charCodeAt(_loc28_);
                  _loc14_ = getChar(_loc17_);
                  if(_loc17_ == 10 || _loc17_ == 13)
                  {
                     _loc24_ = true;
                  }
                  else if(_loc14_ == null)
                  {
                     trace("[Starling] Missing character: " + _loc17_);
                  }
                  else
                  {
                     if(_loc17_ == 32 || _loc17_ == 9)
                     {
                        _loc9_ = _loc28_;
                     }
                     if(param8)
                     {
                        _loc36_ += _loc14_.getKerning(_loc26_);
                     }
                     (_loc31_ = !!mCharLocationPool.length ? mCharLocationPool.pop() : new CharLocation(_loc14_)).char = _loc14_;
                     _loc31_.x = _loc36_ + _loc14_.xOffset;
                     _loc31_.y = _loc34_ + _loc14_.yOffset;
                     _loc29_.push(_loc31_);
                     _loc36_ += _loc14_.xAdvance;
                     _loc26_ = _loc17_;
                     if(_loc31_.x + _loc14_.width > _loc13_)
                     {
                        _loc15_ = _loc9_ == -1 ? 1 : _loc28_ - _loc9_;
                        _loc18_ = _loc29_.length - _loc15_;
                        _loc29_.splice(_loc18_,_loc15_);
                        if(_loc29_.length != 0)
                        {
                           _loc28_ -= _loc15_;
                           _loc24_ = true;
                        }
                        break;
                     }
                  }
                  if(_loc28_ == _loc20_ - 1)
                  {
                     _loc33_.push(_loc29_);
                     _loc25_ = true;
                  }
                  else if(_loc24_)
                  {
                     _loc33_.push(_loc29_);
                     if(_loc9_ == _loc28_)
                     {
                        _loc29_.pop();
                     }
                     if(_loc34_ + 2 * mLineHeight > _loc23_)
                     {
                        break;
                     }
                     _loc29_ = new Vector.<CharLocation>(0);
                     _loc36_ = 0;
                     _loc34_ += mLineHeight;
                     _loc9_ = -1;
                     _loc26_ = -1;
                  }
                  _loc28_++;
               }
            }
            if(param7 && !_loc25_ && param4 > 3)
            {
               param4 -= 1;
               _loc33_.length = 0;
            }
            else
            {
               _loc25_ = true;
            }
         }
         var _loc21_:Vector.<CharLocation> = new Vector.<CharLocation>(0);
         var _loc12_:int = int(_loc33_.length);
         var _loc32_:Number = _loc34_ + mLineHeight;
         var _loc11_:int = 0;
         if(param6 == "bottom")
         {
            _loc11_ = _loc23_ - _loc32_;
         }
         else if(param6 == "center")
         {
            _loc11_ = (_loc23_ - _loc32_) / 2;
         }
         _loc35_ = 0;
         while(_loc35_ < _loc12_)
         {
            if((_loc20_ = int((_loc16_ = _loc33_[_loc35_]).length)) != 0)
            {
               _loc30_ = 0;
               _loc19_ = (_loc27_ = _loc16_[_loc16_.length - 1]).x - _loc27_.char.xOffset + _loc27_.char.xAdvance;
               if(param5 == "right")
               {
                  _loc30_ = _loc13_ - _loc19_;
               }
               else if(param5 == "center")
               {
                  _loc30_ = (_loc13_ - _loc19_) / 2;
               }
               _loc22_ = 0;
               while(_loc22_ < _loc20_)
               {
                  (_loc31_ = _loc16_[_loc22_]).x = _loc10_ * (_loc31_.x + _loc30_);
                  _loc31_.y = _loc10_ * (_loc31_.y + _loc11_);
                  _loc31_.scale = _loc10_;
                  if(_loc31_.char.width > 0 && _loc31_.char.height > 0)
                  {
                     _loc21_.push(_loc31_);
                  }
                  mCharLocationPool.push(_loc31_);
                  _loc22_++;
               }
            }
            _loc35_++;
         }
         return _loc21_;
      }
      
      public function get name() : String
      {
         return mName;
      }
      
      public function get size() : Number
      {
         return mSize;
      }
      
      public function get lineHeight() : Number
      {
         return mLineHeight;
      }
      
      public function set lineHeight(param1:Number) : void
      {
         mLineHeight = param1;
      }
      
      public function get smoothing() : String
      {
         return mHelperImage.smoothing;
      }
      
      public function set smoothing(param1:String) : void
      {
         mHelperImage.smoothing = param1;
      }
      
      public function get baseline() : Number
      {
         return mBaseline;
      }
   }
}

import starling.text.BitmapChar;

class CharLocation
{
    
   
   public var char:BitmapChar;
   
   public var scale:Number;
   
   public var x:Number;
   
   public var y:Number;
   
   public function CharLocation(param1:BitmapChar)
   {
      super();
      this.char = param1;
   }
}
