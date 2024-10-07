package starling.utils
{
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.net.FileReference;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.system.System;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.clearTimeout;
   import flash.utils.describeType;
   import flash.utils.getQualifiedClassName;
   import flash.utils.setTimeout;
   import starling.core.Starling;
   import starling.events.EventDispatcher;
   import starling.text.BitmapFont;
   import starling.text.TextField;
   import starling.textures.AtfData;
   import starling.textures.Texture;
   import starling.textures.TextureAtlas;
   
   public class AssetManager extends EventDispatcher
   {
      
      private static var sNames:Vector.<String> = new Vector.<String>(0);
       
      
      private var mScaleFactor:Number;
      
      private var mUseMipMaps:Boolean;
      
      private var mCheckPolicyFile:Boolean;
      
      private var mVerbose:Boolean;
      
      private var mNumLostTextures:int;
      
      private var mNumRestoredTextures:int;
      
      private var mQueue:Array;
      
      private var mIsLoading:Boolean;
      
      private var mTimeoutID:uint;
      
      private var mTextures:Dictionary;
      
      private var mAtlases:Dictionary;
      
      private var mSounds:Dictionary;
      
      private var mXmls:Dictionary;
      
      private var mObjects:Dictionary;
      
      private var mByteArrays:Dictionary;
      
      public function AssetManager(param1:Number = 1, param2:Boolean = false)
      {
         super();
         mVerbose = mCheckPolicyFile = mIsLoading = false;
         mScaleFactor = param1 > 0 ? param1 : Starling.contentScaleFactor;
         mUseMipMaps = param2;
         mQueue = [];
         mTextures = new Dictionary();
         mAtlases = new Dictionary();
         mSounds = new Dictionary();
         mXmls = new Dictionary();
         mObjects = new Dictionary();
         mByteArrays = new Dictionary();
      }
      
      public function dispose() : void
      {
         for each(var _loc1_ in mTextures)
         {
            _loc1_.dispose();
         }
         for each(var _loc2_ in mAtlases)
         {
            _loc2_.dispose();
         }
      }
      
      public function getTexture(param1:String) : Texture
      {
         var _loc2_:Texture = null;
         if(param1 in mTextures)
         {
            return mTextures[param1];
         }
         for each(var _loc3_ in mAtlases)
         {
            _loc2_ = _loc3_.getTexture(param1);
            if(_loc2_)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getTextures(param1:String = "", param2:Vector.<Texture> = null) : Vector.<Texture>
      {
         if(param2 == null)
         {
            param2 = new Vector.<Texture>(0);
         }
         for each(var _loc3_ in getTextureNames(param1,sNames))
         {
            param2.push(getTexture(_loc3_));
         }
         sNames.length = 0;
         return param2;
      }
      
      public function getTextureNames(param1:String = "", param2:Vector.<String> = null) : Vector.<String>
      {
         param2 = getDictionaryKeys(mTextures,param1,param2);
         for each(var _loc3_ in mAtlases)
         {
            _loc3_.getNames(param1,param2);
         }
         param2.sort(1);
         return param2;
      }
      
      public function getTextureAtlas(param1:String) : TextureAtlas
      {
         return mAtlases[param1] as TextureAtlas;
      }
      
      public function getSound(param1:String) : Sound
      {
         return mSounds[param1];
      }
      
      public function getSoundNames(param1:String = "", param2:Vector.<String> = null) : Vector.<String>
      {
         return getDictionaryKeys(mSounds,param1,param2);
      }
      
      public function playSound(param1:String, param2:Number = 0, param3:int = 0, param4:SoundTransform = null) : SoundChannel
      {
         if(param1 in mSounds)
         {
            return getSound(param1).play(param2,param3,param4);
         }
         return null;
      }
      
      public function getXml(param1:String) : XML
      {
         return mXmls[param1];
      }
      
      public function getXmlNames(param1:String = "", param2:Vector.<String> = null) : Vector.<String>
      {
         return getDictionaryKeys(mXmls,param1,param2);
      }
      
      public function getObject(param1:String) : Object
      {
         return mObjects[param1];
      }
      
      public function getObjectNames(param1:String = "", param2:Vector.<String> = null) : Vector.<String>
      {
         return getDictionaryKeys(mObjects,param1,param2);
      }
      
      public function getByteArray(param1:String) : ByteArray
      {
         return mByteArrays[param1];
      }
      
      public function getByteArrayNames(param1:String = "", param2:Vector.<String> = null) : Vector.<String>
      {
         return getDictionaryKeys(mByteArrays,param1,param2);
      }
      
      public function addTexture(param1:String, param2:Texture) : void
      {
         log("Adding texture \'" + param1 + "\'");
         if(param1 in mTextures)
         {
            log("Warning: name was already in use; the previous texture will be replaced.");
         }
         mTextures[param1] = param2;
      }
      
      public function addTextureAtlas(param1:String, param2:TextureAtlas) : void
      {
         log("Adding texture atlas \'" + param1 + "\'");
         if(param1 in mAtlases)
         {
            log("Warning: name was already in use; the previous atlas will be replaced.");
         }
         mAtlases[param1] = param2;
      }
      
      public function addSound(param1:String, param2:Sound) : void
      {
         log("Adding sound \'" + param1 + "\'");
         if(param1 in mSounds)
         {
            log("Warning: name was already in use; the previous sound will be replaced.");
         }
         mSounds[param1] = param2;
      }
      
      public function addXml(param1:String, param2:XML) : void
      {
         log("Adding XML \'" + param1 + "\'");
         if(param1 in mXmls)
         {
            log("Warning: name was already in use; the previous XML will be replaced.");
         }
         mXmls[param1] = param2;
      }
      
      public function addObject(param1:String, param2:Object) : void
      {
         log("Adding object \'" + param1 + "\'");
         if(param1 in mObjects)
         {
            log("Warning: name was already in use; the previous object will be replaced.");
         }
         mObjects[param1] = param2;
      }
      
      public function addByteArray(param1:String, param2:ByteArray) : void
      {
         log("Adding byte array \'" + param1 + "\'");
         if(param1 in mObjects)
         {
            log("Warning: name was already in use; the previous byte array will be replaced.");
         }
         mByteArrays[param1] = param2;
      }
      
      public function removeTexture(param1:String, param2:Boolean = true) : void
      {
         log("Removing texture \'" + param1 + "\'");
         if(param2 && param1 in mTextures)
         {
            mTextures[param1].dispose();
         }
         delete mTextures[param1];
      }
      
      public function removeTextureAtlas(param1:String, param2:Boolean = true) : void
      {
         log("Removing texture atlas \'" + param1 + "\'");
         if(param2 && param1 in mAtlases)
         {
            mAtlases[param1].dispose();
         }
         delete mAtlases[param1];
      }
      
      public function removeSound(param1:String) : void
      {
         log("Removing sound \'" + param1 + "\'");
         delete mSounds[param1];
      }
      
      public function removeXml(param1:String, param2:Boolean = true) : void
      {
         log("Removing xml \'" + param1 + "\'");
         if(param2 && param1 in mXmls)
         {
            System.disposeXML(mXmls[param1]);
         }
         delete mXmls[param1];
      }
      
      public function removeObject(param1:String) : void
      {
         log("Removing object \'" + param1 + "\'");
         delete mObjects[param1];
      }
      
      public function removeByteArray(param1:String, param2:Boolean = true) : void
      {
         log("Removing byte array \'" + param1 + "\'");
         if(param2 && param1 in mByteArrays)
         {
            mByteArrays[param1].clear();
         }
         delete mByteArrays[param1];
      }
      
      public function purgeQueue() : void
      {
         mIsLoading = false;
         mQueue.length = 0;
         clearTimeout(mTimeoutID);
      }
      
      public function purge() : void
      {
         log("Purging all assets, emptying queue");
         purgeQueue();
         for each(var _loc1_ in mTextures)
         {
            _loc1_.dispose();
         }
         for each(var _loc2_ in mAtlases)
         {
            _loc2_.dispose();
         }
         mTextures = new Dictionary();
         mAtlases = new Dictionary();
         mSounds = new Dictionary();
         mXmls = new Dictionary();
         mObjects = new Dictionary();
         mByteArrays = new Dictionary();
      }
      
      public function enqueue(... rest) : void
      {
         var _loc4_:XML = null;
         var _loc2_:* = null;
         for each(var _loc3_ in rest)
         {
            if(_loc3_ is Array)
            {
               enqueue.apply(this,_loc3_);
            }
            else if(_loc3_ is Class)
            {
               _loc4_ = describeType(_loc3_);
               if(mVerbose)
               {
                  log("Looking for static embedded assets in \'" + _loc4_.@name.split("::").pop() + "\'");
               }
               for each(_loc2_ in _loc4_.constant.(@type == "Class"))
               {
                  enqueueWithName(_loc3_[_loc2_.@name],_loc2_.@name);
               }
               for each(_loc2_ in _loc4_.variable.(@type == "Class"))
               {
                  enqueueWithName(_loc3_[_loc2_.@name],_loc2_.@name);
               }
            }
            else if(getQualifiedClassName(_loc3_) == "flash.filesystem::File")
            {
               if(!_loc3_["exists"])
               {
                  log("File or directory not found: \'" + _loc3_["url"] + "\'");
               }
               else if(!_loc3_["isHidden"])
               {
                  if(_loc3_["isDirectory"])
                  {
                     enqueue.apply(this,_loc3_["getDirectoryListing"]());
                  }
                  else
                  {
                     enqueueWithName(_loc3_["url"]);
                  }
               }
            }
            else if(_loc3_ is String)
            {
               enqueueWithName(_loc3_);
            }
            else
            {
               log("Ignoring unsupported asset type: " + getQualifiedClassName(_loc3_));
            }
         }
      }
      
      public function enqueueWithName(param1:Object, param2:String = null) : String
      {
         if(param2 == null)
         {
            param2 = getName(param1);
         }
         log("Enqueuing \'" + param2 + "\'");
         mQueue.push({
            "name":param2,
            "asset":param1
         });
         return param2;
      }
      
      public function loadQueue(param1:Function) : void
      {
         var xmls:Vector.<XML>;
         var numElements:int;
         var currentRatio:Number;
         var onProgress:Function = param1;
         var resume:* = function():void
         {
            if(!mIsLoading)
            {
               return;
            }
            currentRatio = !!mQueue.length ? 1 - mQueue.length / numElements : 1;
            if(mQueue.length)
            {
               mTimeoutID = setTimeout(processNext,1);
            }
            else
            {
               processXmls();
               mIsLoading = false;
            }
            if(onProgress != null)
            {
               onProgress(currentRatio);
            }
         };
         var processNext:* = function():void
         {
            var _loc1_:Object = mQueue.pop();
            clearTimeout(mTimeoutID);
            processRawAsset(_loc1_.name,_loc1_.asset,xmls,progress,resume);
         };
         var processXmls:* = function():void
         {
            var xml:XML;
            var name:String;
            var texture:Texture;
            var rootNode:String;
            xmls.sort(function(param1:XML, param2:XML):int
            {
               return param1.localName() == "TextureAtlas" ? -1 : 1;
            });
            for each(xml in xmls)
            {
               rootNode = String(xml.localName());
               if(rootNode == "TextureAtlas")
               {
                  name = getName(xml.@imagePath.toString());
                  texture = getTexture(name);
                  if(texture)
                  {
                     addTextureAtlas(name,new TextureAtlas(texture,xml));
                     removeTexture(name,false);
                  }
                  else
                  {
                     log("Cannot create atlas: texture \'" + name + "\' is missing.");
                  }
               }
               else
               {
                  if(rootNode != "font")
                  {
                     throw new Error("XML contents not recognized: " + rootNode);
                  }
                  name = getName(xml.pages.page.@file.toString());
                  texture = getTexture(name);
                  if(texture)
                  {
                     log("Adding bitmap font \'" + name + "\'");
                     TextField.registerBitmapFont(new BitmapFont(texture,xml),name);
                     removeTexture(name,false);
                  }
                  else
                  {
                     log("Cannot create bitmap font: texture \'" + name + "\' is missing.");
                  }
               }
               System.disposeXML(xml);
            }
         };
         var progress:* = function(param1:Number):void
         {
            onProgress(currentRatio + 1 / numElements * Math.min(1,param1) * 0.99);
         };
         if(Starling.context == null)
         {
            throw new Error("The Starling instance needs to be ready before textures can be loaded.");
         }
         if(mIsLoading)
         {
            throw new Error("The queue is already being processed");
         }
         xmls = new Vector.<XML>(0);
         numElements = int(mQueue.length);
         currentRatio = 0;
         mIsLoading = true;
         resume();
      }
      
      private function processRawAsset(param1:String, param2:Object, param3:Vector.<XML>, param4:Function, param5:Function) : void
      {
         var name:String = param1;
         var rawAsset:Object = param2;
         var xmls:Vector.<XML> = param3;
         var onProgress:Function = param4;
         var onComplete:Function = param5;
         var process:* = function(param1:Object):void
         {
            var texture:Texture;
            var bytes:ByteArray;
            var xml:XML;
            var rootNode:String;
            var asset:Object = param1;
            if(!mIsLoading)
            {
               onComplete();
            }
            else if(asset is Sound)
            {
               addSound(name,asset as Sound);
               onComplete();
            }
            else if(asset is Bitmap)
            {
               texture = Texture.fromBitmap(asset as Bitmap,mUseMipMaps,false,mScaleFactor);
               texture.root.onRestore = function():void
               {
                  mNumLostTextures++;
                  loadRawAsset(name,rawAsset,null,function(param1:Object):void
                  {
                     try
                     {
                        texture.root.uploadBitmap(param1 as Bitmap);
                     }
                     catch(e:Error)
                     {
                        log("Texture restoration failed: " + e.message);
                     }
                     param1.bitmapData.dispose();
                     mNumRestoredTextures++;
                     if(mNumLostTextures == mNumRestoredTextures)
                     {
                        dispatchEventWith("texturesRestored");
                     }
                  });
               };
               asset.bitmapData.dispose();
               addTexture(name,texture);
               onComplete();
            }
            else if(asset is ByteArray)
            {
               bytes = asset as ByteArray;
               if(AtfData.isAtfData(bytes))
               {
                  texture = Texture.fromAtfData(bytes,mScaleFactor,mUseMipMaps,onComplete);
                  texture.root.onRestore = function():void
                  {
                     mNumLostTextures++;
                     loadRawAsset(name,rawAsset,null,function(param1:Object):void
                     {
                        try
                        {
                           texture.root.uploadAtfData(param1 as ByteArray,0,true);
                        }
                        catch(e:Error)
                        {
                           log("Texture restoration failed: " + e.message);
                        }
                        param1.clear();
                        mNumRestoredTextures++;
                        if(mNumLostTextures == mNumRestoredTextures)
                        {
                           dispatchEventWith("texturesRestored");
                        }
                     });
                  };
                  bytes.clear();
                  addTexture(name,texture);
               }
               else if(byteArrayStartsWith(bytes,"{") || byteArrayStartsWith(bytes,"["))
               {
                  addObject(name,JSON.parse(bytes.readUTFBytes(bytes.length)));
                  bytes.clear();
                  onComplete();
               }
               else if(byteArrayStartsWith(bytes,"<"))
               {
                  process(new XML(bytes));
                  bytes.clear();
               }
               else
               {
                  addByteArray(name,bytes);
                  onComplete();
               }
            }
            else if(asset is XML)
            {
               xml = asset as XML;
               rootNode = String(xml.localName());
               if(rootNode == "TextureAtlas" || rootNode == "font")
               {
                  xmls.push(xml);
               }
               else
               {
                  addXml(name,xml);
               }
               onComplete();
            }
            else if(asset == null)
            {
               onComplete();
            }
            else
            {
               log("Ignoring unsupported asset type: " + getQualifiedClassName(asset));
               onComplete();
            }
            asset = null;
            bytes = null;
         };
         loadRawAsset(name,rawAsset,onProgress,process);
      }
      
      private function loadRawAsset(param1:String, param2:Object, param3:Function, param4:Function) : void
      {
         var url:String;
         var name:String = param1;
         var rawAsset:Object = param2;
         var onProgress:Function = param3;
         var onComplete:Function = param4;
         var onIoError:* = function(param1:IOErrorEvent):void
         {
            log("IO error: " + param1.text);
            onComplete(null);
         };
         var onLoadProgress:* = function(param1:ProgressEvent):void
         {
            if(onProgress != null)
            {
               onProgress(param1.bytesLoaded / param1.bytesTotal);
            }
         };
         var onUrlLoaderComplete:* = function(param1:Object):void
         {
            var _loc5_:Sound = null;
            var _loc4_:LoaderContext = null;
            var _loc3_:Loader = null;
            var _loc2_:ByteArray = urlLoader.data as ByteArray;
            urlLoader.removeEventListener("ioError",onIoError);
            urlLoader.removeEventListener("progress",onLoadProgress);
            urlLoader.removeEventListener("complete",onUrlLoaderComplete);
            switch(extension)
            {
               case "mp3":
                  (_loc5_ = new Sound()).loadCompressedDataFromByteArray(_loc2_,_loc2_.length);
                  _loc2_.clear();
                  onComplete(_loc5_);
                  break;
               case "jpg":
               case "jpeg":
               case "png":
               case "gif":
                  _loc4_ = new LoaderContext(mCheckPolicyFile);
                  _loc3_ = new Loader();
                  _loc4_.imageDecodingPolicy = "onLoad";
                  _loc3_.contentLoaderInfo.addEventListener("complete",onLoaderComplete);
                  _loc3_.loadBytes(_loc2_,_loc4_);
                  break;
               default:
                  onComplete(_loc2_);
            }
         };
         var onLoaderComplete:* = function(param1:Object):void
         {
            urlLoader.data.clear();
            param1.target.removeEventListener("complete",onLoaderComplete);
            onComplete(param1.target.content);
         };
         var extension:String = null;
         var urlLoader:URLLoader = null;
         if(rawAsset is Class)
         {
            setTimeout(onComplete,1,new rawAsset());
         }
         else if(rawAsset is String)
         {
            url = rawAsset as String;
            extension = String(url.split(".").pop().toLowerCase().split("?")[0]);
            urlLoader = new URLLoader();
            urlLoader.dataFormat = "binary";
            urlLoader.addEventListener("ioError",onIoError);
            urlLoader.addEventListener("progress",onLoadProgress);
            urlLoader.addEventListener("complete",onUrlLoaderComplete);
            urlLoader.load(new URLRequest(url));
         }
      }
      
      protected function getName(param1:Object) : String
      {
         var _loc2_:Array = null;
         var _loc3_:String = null;
         if(param1 is String || param1 is FileReference)
         {
            _loc3_ = param1 is String ? param1 as String : (param1 as FileReference).name;
            _loc3_ = _loc3_.replace(/%20/g," ");
            _loc2_ = /(.*[\\\/])?(.+)(\.[\w]{1,4})/.exec(_loc3_);
            if(_loc2_ && _loc2_.length == 4)
            {
               return _loc2_[2];
            }
            throw new ArgumentError("Could not extract name from String \'" + param1 + "\'");
         }
         _loc3_ = getQualifiedClassName(param1);
         throw new ArgumentError("Cannot extract names for objects of type \'" + _loc3_ + "\'");
      }
      
      protected function log(param1:String) : void
      {
         if(mVerbose)
         {
            trace("[AssetManager]",param1);
         }
      }
      
      private function byteArrayStartsWith(param1:ByteArray, param2:String) : Boolean
      {
         var _loc7_:* = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = int(param1.length);
         var _loc6_:int = param2.charCodeAt(0);
         if(_loc5_ >= 4 && (param1[0] == 0 && param1[1] == 0 && param1[2] == 254 && param1[3] == 255) || param1[0] == 255 && param1[1] == 254 && param1[2] == 0 && param1[3] == 0)
         {
            _loc4_ = 4;
         }
         else if(_loc5_ >= 3 && param1[0] == 239 && param1[1] == 187 && param1[2] == 191)
         {
            _loc4_ = 3;
         }
         else if(_loc5_ >= 2 && (param1[0] == 254 && param1[1] == 255) || param1[0] == 255 && param1[1] == 254)
         {
            _loc4_ = 2;
         }
         _loc7_ = _loc4_;
         while(_loc7_ < _loc5_)
         {
            _loc3_ = int(param1[_loc7_]);
            if(!(_loc3_ == 0 || _loc3_ == 10 || _loc3_ == 13 || _loc3_ == 32))
            {
               return _loc3_ == _loc6_;
            }
            _loc7_++;
         }
         return false;
      }
      
      private function getDictionaryKeys(param1:Dictionary, param2:String = "", param3:Vector.<String> = null) : Vector.<String>
      {
         if(param3 == null)
         {
            param3 = new Vector.<String>(0);
         }
         for(var _loc4_ in param1)
         {
            if(_loc4_.indexOf(param2) == 0)
            {
               param3.push(_loc4_);
            }
         }
         param3.sort(1);
         return param3;
      }
      
      protected function get queue() : Array
      {
         return mQueue;
      }
      
      public function get numQueuedAssets() : int
      {
         return mQueue.length;
      }
      
      public function get verbose() : Boolean
      {
         return mVerbose;
      }
      
      public function set verbose(param1:Boolean) : void
      {
         mVerbose = param1;
      }
      
      public function get useMipMaps() : Boolean
      {
         return mUseMipMaps;
      }
      
      public function set useMipMaps(param1:Boolean) : void
      {
         mUseMipMaps = param1;
      }
      
      public function get scaleFactor() : Number
      {
         return mScaleFactor;
      }
      
      public function set scaleFactor(param1:Number) : void
      {
         mScaleFactor = param1;
      }
      
      public function get checkPolicyFile() : Boolean
      {
         return mCheckPolicyFile;
      }
      
      public function set checkPolicyFile(param1:Boolean) : void
      {
         mCheckPolicyFile = param1;
      }
   }
}
