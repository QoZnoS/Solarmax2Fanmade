package starling.textures
{
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class TextureAtlas
   {
      
      private static var sNames:Vector.<String> = new Vector.<String>(0);
       
      
      private var mAtlasTexture:Texture;
      
      private var mTextureRegions:Dictionary;
      
      private var mTextureFrames:Dictionary;
      
      public function TextureAtlas(param1:Texture, param2:XML = null)
      {
         super();
         mTextureRegions = new Dictionary();
         mTextureFrames = new Dictionary();
         mAtlasTexture = param1;
         if(param2)
         {
            parseAtlasXml(param2);
         }
      }
      
      public function dispose() : void
      {
         mAtlasTexture.dispose();
      }
      
      protected function parseAtlasXml(param1:XML) : void
      {
         var _loc7_:String = null;
         var _loc13_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc2_:Rectangle = null;
         var _loc5_:Rectangle = null;
         var _loc3_:Number = mAtlasTexture.scale;
         for each(var _loc12_ in param1.SubTexture)
         {
            _loc7_ = String(_loc12_.attribute("name"));
            _loc13_ = parseFloat(_loc12_.attribute("x")) / _loc3_;
            _loc11_ = parseFloat(_loc12_.attribute("y")) / _loc3_;
            _loc4_ = parseFloat(_loc12_.attribute("width")) / _loc3_;
            _loc6_ = parseFloat(_loc12_.attribute("height")) / _loc3_;
            _loc9_ = parseFloat(_loc12_.attribute("frameX")) / _loc3_;
            _loc10_ = parseFloat(_loc12_.attribute("frameY")) / _loc3_;
            _loc8_ = parseFloat(_loc12_.attribute("frameWidth")) / _loc3_;
            _loc14_ = parseFloat(_loc12_.attribute("frameHeight")) / _loc3_;
            _loc2_ = new Rectangle(_loc13_,_loc11_,_loc4_,_loc6_);
            _loc5_ = _loc8_ > 0 && _loc14_ > 0 ? new Rectangle(_loc9_,_loc10_,_loc8_,_loc14_) : null;
            addRegion(_loc7_,_loc2_,_loc5_);
         }
      }
      
      public function getTexture(param1:String) : Texture
      {
         var _loc2_:Rectangle = mTextureRegions[param1];
         if(_loc2_ == null)
         {
            return null;
         }
         return Texture.fromTexture(mAtlasTexture,_loc2_,mTextureFrames[param1]);
      }
      
      public function getTextures(param1:String = "", param2:Vector.<Texture> = null) : Vector.<Texture>
      {
         if(param2 == null)
         {
            param2 = new Vector.<Texture>(0);
         }
         for each(var _loc3_ in getNames(param1,sNames))
         {
            param2.push(getTexture(_loc3_));
         }
         sNames.length = 0;
         return param2;
      }
      
      public function getNames(param1:String = "", param2:Vector.<String> = null) : Vector.<String>
      {
         if(param2 == null)
         {
            param2 = new Vector.<String>(0);
         }
         for(var _loc3_ in mTextureRegions)
         {
            if(_loc3_.indexOf(param1) == 0)
            {
               param2.push(_loc3_);
            }
         }
         param2.sort(1);
         return param2;
      }
      
      public function getRegion(param1:String) : Rectangle
      {
         return mTextureRegions[param1];
      }
      
      public function getFrame(param1:String) : Rectangle
      {
         return mTextureFrames[param1];
      }
      
      public function addRegion(param1:String, param2:Rectangle, param3:Rectangle = null) : void
      {
         mTextureRegions[param1] = param2;
         mTextureFrames[param1] = param3;
      }
      
      public function removeRegion(param1:String) : void
      {
         delete mTextureRegions[param1];
         delete mTextureFrames[param1];
      }
      
      public function get texture() : Texture
      {
         return mAtlasTexture;
      }
   }
}
