package starling.text
{
   import flash.display.BitmapData;
   import flash.display3D.Context3DTextureFormat;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import starling.core.RenderSupport;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.QuadBatch;
   import starling.display.Sprite;
   import starling.textures.Texture;
   import starling.utils.HAlign;
   import starling.utils.VAlign;
   
   public class TextField extends DisplayObjectContainer
   {
      
      private static const BITMAP_FONT_DATA_NAME:String = "starling.display.TextField.BitmapFonts";
      
      private static var sNativeTextField:flash.text.TextField = new flash.text.TextField();
       
      
      private var mFontSize:Number;
      
      private var mColor:uint;
      
      private var mText:String;
      
      private var mFontName:String;
      
      private var mHAlign:String;
      
      private var mVAlign:String;
      
      private var mBold:Boolean;
      
      private var mItalic:Boolean;
      
      private var mUnderline:Boolean;
      
      private var mAutoScale:Boolean;
      
      private var mAutoSize:String;
      
      private var mKerning:Boolean;
      
      private var mNativeFilters:Array;
      
      private var mRequiresRedraw:Boolean;
      
      private var mIsRenderedText:Boolean;
      
      private var mTextBounds:Rectangle;
      
      private var mBatchable:Boolean;
      
      private var mHitArea:DisplayObject;
      
      private var mBorder:DisplayObjectContainer;
      
      private var mImage:Image;
      
      private var mQuadBatch:QuadBatch;
      
      public function TextField(param1:int, param2:int, param3:String, param4:String = "Verdana", param5:Number = 12, param6:uint = 0, param7:Boolean = false)
      {
         super();
         mText = !!param3 ? param3 : "";
         mFontSize = param5;
         mColor = param6;
         mHAlign = "center";
         mVAlign = "center";
         mBorder = null;
         mKerning = true;
         mBold = param7;
         mAutoSize = "none";
         this.fontName = param4;
         mHitArea = new Quad(param1,param2);
         mHitArea.alpha = 0;
         addChild(mHitArea);
         addEventListener("flatten",onFlatten);
      }
      
      public static function registerBitmapFont(param1:BitmapFont, param2:String = null) : String
      {
         if(param2 == null)
         {
            param2 = param1.name;
         }
         bitmapFonts[param2.toLowerCase()] = param1;
         return param2;
      }
      
      public static function unregisterBitmapFont(param1:String, param2:Boolean = true) : void
      {
         param1 = param1.toLowerCase();
         if(param2 && bitmapFonts[param1] != undefined)
         {
            bitmapFonts[param1].dispose();
         }
         delete bitmapFonts[param1];
      }
      
      public static function getBitmapFont(param1:String) : BitmapFont
      {
         return bitmapFonts[param1.toLowerCase()];
      }
      
      private static function get bitmapFonts() : Dictionary
      {
         var _loc1_:Dictionary = Starling.current.contextData["starling.display.TextField.BitmapFonts"] as Dictionary;
         if(_loc1_ == null)
         {
            _loc1_ = new Dictionary();
            Starling.current.contextData["starling.display.TextField.BitmapFonts"] = _loc1_;
         }
         return _loc1_;
      }
      
      override public function dispose() : void
      {
         removeEventListener("flatten",onFlatten);
         if(mImage)
         {
            mImage.texture.dispose();
         }
         if(mQuadBatch)
         {
            mQuadBatch.dispose();
         }
         super.dispose();
      }
      
      private function onFlatten() : void
      {
         if(mRequiresRedraw)
         {
            redraw();
         }
      }
      
      override public function render(param1:RenderSupport, param2:Number) : void
      {
         if(mRequiresRedraw)
         {
            redraw();
         }
         super.render(param1,param2);
      }
      
      public function redraw() : void
      {
         if(mRequiresRedraw)
         {
            if(mIsRenderedText)
            {
               createRenderedContents();
            }
            else
            {
               createComposedContents();
            }
            updateBorder();
            mRequiresRedraw = false;
         }
      }
      
      private function createRenderedContents() : void
      {
         var scale:Number;
         var bitmapData:BitmapData;
         var format:String;
         var texture:Texture;
         if(mQuadBatch)
         {
            mQuadBatch.removeFromParent(true);
            mQuadBatch = null;
         }
         if(mTextBounds == null)
         {
            mTextBounds = new Rectangle();
         }
         scale = Starling.contentScaleFactor;
         bitmapData = renderText(scale,mTextBounds);
         format = "BGRA_PACKED" in Context3DTextureFormat ? "bgraPacked4444" : "bgra";
         mHitArea.width = bitmapData.width / scale;
         mHitArea.height = bitmapData.height / scale;
         texture = Texture.fromBitmapData(bitmapData,false,false,scale,format);
         texture.root.onRestore = function():void
         {
            texture.root.uploadBitmapData(renderText(scale,mTextBounds));
         };
         bitmapData.dispose();
         if(mImage == null)
         {
            mImage = new Image(texture);
            mImage.touchable = false;
            addChild(mImage);
         }
         else
         {
            mImage.texture.dispose();
            mImage.texture = texture;
            mImage.readjustSize();
         }
      }
      
      protected function formatText(param1:flash.text.TextField, param2:TextFormat) : void
      {
      }
      
      private function renderText(param1:Number, param2:Rectangle) : BitmapData
      {
         var _loc6_:Number = mHitArea.width * param1;
         var _loc10_:Number = mHitArea.height * param1;
         var _loc7_:String = mHAlign;
         var _loc5_:String = mVAlign;
         if(isHorizontalAutoSize)
         {
            _loc6_ = 2147483647;
            _loc7_ = "left";
         }
         if(isVerticalAutoSize)
         {
            _loc10_ = 2147483647;
            _loc5_ = "top";
         }
         var _loc11_:TextFormat;
         (_loc11_ = new TextFormat(mFontName,mFontSize * param1,mColor,mBold,mItalic,mUnderline,null,null,_loc7_)).kerning = mKerning;
         sNativeTextField.defaultTextFormat = _loc11_;
         sNativeTextField.width = _loc6_;
         sNativeTextField.height = _loc10_;
         sNativeTextField.antiAliasType = "advanced";
         sNativeTextField.selectable = false;
         sNativeTextField.multiline = true;
         sNativeTextField.wordWrap = true;
         sNativeTextField.text = mText;
         sNativeTextField.embedFonts = true;
         sNativeTextField.filters = mNativeFilters;
         if(sNativeTextField.textWidth == 0 || sNativeTextField.textHeight == 0)
         {
            sNativeTextField.embedFonts = false;
         }
         formatText(sNativeTextField,_loc11_);
         if(mAutoScale)
         {
            autoScaleNativeTextField(sNativeTextField);
         }
         var _loc9_:Number = sNativeTextField.textWidth;
         var _loc3_:Number = sNativeTextField.textHeight;
         if(isHorizontalAutoSize)
         {
            sNativeTextField.width = _loc6_ = Math.ceil(_loc9_ + 5);
         }
         if(isVerticalAutoSize)
         {
            sNativeTextField.height = _loc10_ = Math.ceil(_loc3_ + 4);
         }
         if(_loc6_ < 1)
         {
            _loc6_ = 1;
         }
         if(_loc10_ < 1)
         {
            _loc10_ = 1;
         }
         var _loc13_:Number = 0;
         if(_loc7_ == "left")
         {
            _loc13_ = 2;
         }
         else if(_loc7_ == "center")
         {
            _loc13_ = (_loc6_ - _loc9_) / 2;
         }
         else if(_loc7_ == "right")
         {
            _loc13_ = _loc6_ - _loc9_ - 2;
         }
         var _loc4_:Number = 0;
         if(_loc5_ == "top")
         {
            _loc4_ = 2;
         }
         else if(_loc5_ == "center")
         {
            _loc4_ = (_loc10_ - _loc3_) / 2;
         }
         else if(_loc5_ == "bottom")
         {
            _loc4_ = _loc10_ - _loc3_ - 2;
         }
         var _loc12_:BitmapData = new BitmapData(_loc6_,_loc10_,true,0);
         var _loc14_:Matrix = new Matrix(1,0,0,1,0,int(_loc4_) - 2);
         if(("drawWithQuality" in _loc12_ ? _loc12_["drawWithQuality"] : null) is Function)
         {
            null.call(_loc12_,sNativeTextField,_loc14_,null,null,null,false,"medium");
         }
         else
         {
            _loc12_.draw(sNativeTextField,_loc14_);
         }
         sNativeTextField.text = "";
         param2.setTo(_loc13_ / param1,_loc4_ / param1,_loc9_ / param1,_loc3_ / param1);
         return _loc12_;
      }
      
      private function autoScaleNativeTextField(param1:flash.text.TextField) : void
      {
         var _loc4_:TextFormat = null;
         var _loc5_:Number = Number(param1.defaultTextFormat.size);
         var _loc3_:int = param1.height - 4;
         var _loc2_:int = param1.width - 4;
         while(param1.textWidth > _loc2_ || param1.textHeight > _loc3_)
         {
            if(_loc5_ <= 4)
            {
               break;
            }
            (_loc4_ = param1.defaultTextFormat).size = _loc5_--;
            param1.setTextFormat(_loc4_);
         }
      }
      
      private function createComposedContents() : void
      {
         if(mImage)
         {
            mImage.removeFromParent(true);
            mImage = null;
         }
         if(mQuadBatch == null)
         {
            mQuadBatch = new QuadBatch();
            mQuadBatch.touchable = false;
            addChild(mQuadBatch);
         }
         else
         {
            mQuadBatch.reset();
         }
         var _loc5_:BitmapFont;
         if((_loc5_ = getBitmapFont(mFontName)) == null)
         {
            throw new Error("Bitmap font not registered: " + mFontName);
         }
         var _loc4_:Number = mHitArea.width;
         var _loc1_:Number = mHitArea.height;
         var _loc3_:String = mHAlign;
         var _loc2_:String = mVAlign;
         if(isHorizontalAutoSize)
         {
            _loc4_ = 2147483647;
            _loc3_ = "left";
         }
         if(isVerticalAutoSize)
         {
            _loc1_ = 2147483647;
            _loc2_ = "top";
         }
         _loc5_.fillQuadBatch(mQuadBatch,_loc4_,_loc1_,mText,mFontSize,mColor,_loc3_,_loc2_,mAutoScale,mKerning);
         mQuadBatch.batchable = mBatchable;
         if(mAutoSize != "none")
         {
            mTextBounds = mQuadBatch.getBounds(mQuadBatch,mTextBounds);
            if(isHorizontalAutoSize)
            {
               mHitArea.width = mTextBounds.x + mTextBounds.width;
            }
            if(isVerticalAutoSize)
            {
               mHitArea.height = mTextBounds.y + mTextBounds.height;
            }
         }
         else
         {
            mTextBounds = null;
         }
      }
      
      private function updateBorder() : void
      {
         if(mBorder == null)
         {
            return;
         }
         var _loc3_:Number = mHitArea.width;
         var _loc2_:Number = mHitArea.height;
         var _loc1_:Quad = mBorder.getChildAt(0) as Quad;
         var _loc6_:Quad = mBorder.getChildAt(1) as Quad;
         var _loc4_:Quad = mBorder.getChildAt(2) as Quad;
         var _loc5_:Quad = mBorder.getChildAt(3) as Quad;
         _loc1_.width = _loc3_;
         _loc1_.height = 1;
         _loc4_.width = _loc3_;
         _loc4_.height = 1;
         _loc5_.width = 1;
         _loc5_.height = _loc2_;
         _loc6_.width = 1;
         _loc6_.height = _loc2_;
         _loc6_.x = _loc3_ - 1;
         _loc4_.y = _loc2_ - 1;
         _loc1_.color = _loc6_.color = _loc4_.color = _loc5_.color = mColor;
      }
      
      private function get isHorizontalAutoSize() : Boolean
      {
         return mAutoSize == "horizontal" || mAutoSize == "bothDirections";
      }
      
      private function get isVerticalAutoSize() : Boolean
      {
         return mAutoSize == "vertical" || mAutoSize == "bothDirections";
      }
      
      public function get textBounds() : Rectangle
      {
         if(mRequiresRedraw)
         {
            redraw();
         }
         if(mTextBounds == null)
         {
            mTextBounds = mQuadBatch.getBounds(mQuadBatch);
         }
         return mTextBounds.clone();
      }
      
      override public function getBounds(param1:DisplayObject, param2:Rectangle = null) : Rectangle
      {
         if(mRequiresRedraw)
         {
            redraw();
         }
         return mHitArea.getBounds(param1,param2);
      }
      
      override public function set width(param1:Number) : void
      {
         mHitArea.width = param1;
         mRequiresRedraw = true;
      }
      
      override public function set height(param1:Number) : void
      {
         mHitArea.height = param1;
         mRequiresRedraw = true;
      }
      
      public function get text() : String
      {
         return mText;
      }
      
      public function set text(param1:String) : void
      {
         if(param1 == null)
         {
            param1 = "";
         }
         if(mText != param1)
         {
            mText = param1;
            mRequiresRedraw = true;
         }
      }
      
      public function get fontName() : String
      {
         return mFontName;
      }
      
      public function set fontName(param1:String) : void
      {
         if(mFontName != param1)
         {
            if(param1 == "mini" && bitmapFonts[param1] == undefined)
            {
               registerBitmapFont(new BitmapFont());
            }
            mFontName = param1;
            mRequiresRedraw = true;
            mIsRenderedText = getBitmapFont(param1) == null;
         }
      }
      
      public function get fontSize() : Number
      {
         return mFontSize;
      }
      
      public function set fontSize(param1:Number) : void
      {
         if(mFontSize != param1)
         {
            mFontSize = param1;
            mRequiresRedraw = true;
         }
      }
      
      public function get color() : uint
      {
         return mColor;
      }
      
      public function set color(param1:uint) : void
      {
         if(mColor != param1)
         {
            mColor = param1;
            mRequiresRedraw = true;
         }
      }
      
      public function get hAlign() : String
      {
         return mHAlign;
      }
      
      public function set hAlign(param1:String) : void
      {
         if(!HAlign.isValid(param1))
         {
            throw new ArgumentError("Invalid horizontal align: " + param1);
         }
         if(mHAlign != param1)
         {
            mHAlign = param1;
            mRequiresRedraw = true;
         }
      }
      
      public function get vAlign() : String
      {
         return mVAlign;
      }
      
      public function set vAlign(param1:String) : void
      {
         if(!VAlign.isValid(param1))
         {
            throw new ArgumentError("Invalid vertical align: " + param1);
         }
         if(mVAlign != param1)
         {
            mVAlign = param1;
            mRequiresRedraw = true;
         }
      }
      
      public function get border() : Boolean
      {
         return mBorder != null;
      }
      
      public function set border(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         if(param1 && mBorder == null)
         {
            mBorder = new Sprite();
            addChild(mBorder);
            _loc2_ = 0;
            while(_loc2_ < 4)
            {
               mBorder.addChild(new Quad(1,1));
               _loc2_++;
            }
            updateBorder();
         }
         else if(!param1 && mBorder != null)
         {
            mBorder.removeFromParent(true);
            mBorder = null;
         }
      }
      
      public function get bold() : Boolean
      {
         return mBold;
      }
      
      public function set bold(param1:Boolean) : void
      {
         if(mBold != param1)
         {
            mBold = param1;
            mRequiresRedraw = true;
         }
      }
      
      public function get italic() : Boolean
      {
         return mItalic;
      }
      
      public function set italic(param1:Boolean) : void
      {
         if(mItalic != param1)
         {
            mItalic = param1;
            mRequiresRedraw = true;
         }
      }
      
      public function get underline() : Boolean
      {
         return mUnderline;
      }
      
      public function set underline(param1:Boolean) : void
      {
         if(mUnderline != param1)
         {
            mUnderline = param1;
            mRequiresRedraw = true;
         }
      }
      
      public function get kerning() : Boolean
      {
         return mKerning;
      }
      
      public function set kerning(param1:Boolean) : void
      {
         if(mKerning != param1)
         {
            mKerning = param1;
            mRequiresRedraw = true;
         }
      }
      
      public function get autoScale() : Boolean
      {
         return mAutoScale;
      }
      
      public function set autoScale(param1:Boolean) : void
      {
         if(mAutoScale != param1)
         {
            mAutoScale = param1;
            mRequiresRedraw = true;
         }
      }
      
      public function get autoSize() : String
      {
         return mAutoSize;
      }
      
      public function set autoSize(param1:String) : void
      {
         if(mAutoSize != param1)
         {
            mAutoSize = param1;
            mRequiresRedraw = true;
         }
      }
      
      public function get batchable() : Boolean
      {
         return mBatchable;
      }
      
      public function set batchable(param1:Boolean) : void
      {
         mBatchable = param1;
         if(mQuadBatch)
         {
            mQuadBatch.batchable = param1;
         }
      }
      
      public function get nativeFilters() : Array
      {
         return mNativeFilters;
      }
      
      public function set nativeFilters(param1:Array) : void
      {
         if(!mIsRenderedText)
         {
            throw new Error("The TextField.nativeFilters property cannot be used on Bitmap fonts.");
         }
         mNativeFilters = param1.concat();
         mRequiresRedraw = true;
      }
   }
}
