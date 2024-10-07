//警告：该类文件不可直接编译AS3代码
package
{
   import flash.desktop.NativeApplication;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import starling.core.Starling;
   import starling.textures.Texture;
   import starling.utils.AssetManager;
   import starling.utils.RectangleUtil;
   
   public class Main extends Sprite
   {
      
      private static var Background:Class = §startup_png$4fe4de10ec7d07734f28b41eba85d9f8-562842260§;
      
      private static var pause_img:Class = §paused_png$c244c1a75bc59b0cfc80b40b6148446b-935288115§;
       
      
      private var mStarling:Starling;
      
      public var cover:Sprite;
      
      private var keyWidth:Number;
      
      private var screenWidth:Number;
      
      private var screenHeight:Number;
      
      private var scaleFactor:Number;
      
      private var assetDir:String;
      
      private var background:Bitmap;
      
      private var fullScreenWidth:Number;
      
      private var fullScreenHeight:Number;
      
      public function Main()//舞台被创建后执行load()
      {
         super();
         if(stage)
         {
            load();
         }
         else
         {
            addEventListener("addedToStage",onAddedToStage);//创建事件监听器以检测创建舞台
         }
      }
      
      public function onAddedToStage(param1:Object) : void//同上
      {
         removeEventListener("addedToStage",onAddedToStage);
         load();
      }
      
      public function load() : void//初始化参数，导入存档
      {
         Globals.init();//trace("I'm alive!")
         fullScreenWidth = stage.stageWidth;//设定全屏宽度
         fullScreenHeight = stage.stageHeight;//设定全屏高度
         Globals.device = "pc";//设备
         keyWidth = 1920;//缩放整个画面，值越大画面越小
         screenWidth = 2048;//画面宽度
         screenHeight = 1536;//画面高度
         scaleFactor = 2;//比例因子，缩放贴图大小，值越大图越小
         Globals.textSize = 1;//文本大小参数
         Globals.margin = 30;//边距，影响按钮到左右两侧的相对位置
         assetDir = "2048px";//图片文件夹
         background = new Background();//创建背景实例
         Globals.main = this;//
         Globals.load();//导入存档，然后执行start()
      }
      
      public function start() : void//能力不足AI来凑
      {
         // 声明舞台缩放、尺寸、视口和资源的变量
         var stageScale:Number;
         var stageWidth:int;
         var stageHeight:int;
         var viewPort:Rectangle;
         var appDir:File;
         var assets:AssetManager;
         var shape:Shape;
         var pauseImg:Bitmap;
         // 将舞台缩放模式设置为“noScale”并与左上角对齐
         stage.scaleMode = "noScale";
         stage.align = "TL";
         //根据全屏模式设定窗口大小
         if(Globals.fullscreen)
         {
            stage.stageWidth = stage.fullScreenWidth;
            stage.stageHeight = stage.fullScreenHeight;
            stage.displayState = "fullScreenInteractive";
         }
         else
         {
            stage.stageWidth = 1024;
            stage.stageHeight = 640;
            stage.displayState = "normal";
         }
         // 设置舞台尺寸的全局变量
         fullScreenWidth = Globals.stageWidth = stage.stageWidth;
         fullScreenHeight = Globals.stageHeight = stage.stageHeight;
         stageScale = Main.fullScreenWidth / keyWidth;// 根据键宽度计算舞台比例
         // 设置渲染的舞台尺寸
         stageWidth = 1024;
         stageHeight = 768;
         // 为Starling插件启用多点触控和丢失上下文处理
         Starling.multitouchEnabled = true;
         Starling.handleLostContext = true;
         // 根据屏幕和舞台尺寸计算视口矩形
         viewPort = RectangleUtil.fit(new Rectangle(0,0,screenWidth * stageScale,screenHeight * stageScale),new Rectangle(0,0,Main.fullScreenWidth,Main.fullScreenHeight),"none");
         // 获取应用程序目录并创建 AssetManager
         appDir = File.applicationDirectory;
         assets = new AssetManager(Main.scaleFactor,true);
         assets.verbose = Capabilities.isDebugger;
         // 将音频、字体和纹理资源加入队列
         assets.enqueue(appDir.resolvePath("audio"),appDir.resolvePath("fonts/" + assetDir),appDir.resolvePath("textures/" + assetDir));
         assets.enqueue("backgrounds/" + assetDir + "/bg01.png");
         assets.enqueue("backgrounds/" + assetDir + "/bg02.png");
         assets.enqueue("backgrounds/" + assetDir + "/bg03.png");
         assets.enqueue("backgrounds/" + assetDir + "/bg04.png");
         Globals.scaleFactor = Main.scaleFactor;// 设置全局比例因子
         // 设置背景位置、尺寸和平滑度
         background.x = viewPort.x;
         background.y = viewPort.y;
         background.width = viewPort.width;
         background.height = viewPort.height;
         background.smoothing = true;
         addChild(background);
         // 使用指定参数创建一个新的 Starling 实例
         mStarling = new Starling(Root,stage,viewPort,null,"auto","baseline");
         mStarling.stage.stageWidth = stageWidth;
         mStarling.stage.stageHeight = stageHeight;
         mStarling.enableErrorChecking = Capabilities.isDebugger;
         mStarling.antiAliasing = Math.pow(2,Globals.antialias);
         // 为“rootCreated”事件添加事件监听器
         mStarling.addEventListener("rootCreated",(function():*
         {
            var onRootCreated:Function;
            return onRootCreated = function(param1:Object, param2:Root):void
            {
               mStarling.removeEventListener("rootCreated",onRootCreated);
               removeChild(background);
               var _loc3_:Texture = Texture.fromBitmap(background,false,false,Main.scaleFactor);
               param2.start(_loc3_,assets);
               mStarling.start();
            };
         })());
         // 为暂停覆盖创建封面精灵和形状
         cover = new Sprite();
         shape = new Shape();
         shape.graphics.beginFill(0);
         shape.graphics.drawRect(-10,-10,Main.fullScreenWidth + 20,Main.fullScreenHeight + 20);
         shape.graphics.endFill();
         shape.alpha = 0.5;
         cover.addChild(shape);
         // 创建暂停图像并将其添加到封面精灵
         pauseImg = new pause_img();
         var _loc1_:* = Main.fullScreenWidth / 1024 * 0.5;
         pauseImg.scaleY = Main.fullScreenWidth / 1024 * 0.5;
         pauseImg.scaleX = _loc1_;
         pauseImg.x = int(shape.width * 0.5 - pauseImg.width * 0.5 - 10);
         pauseImg.y = int(shape.height * 0.5 - pauseImg.height * 0.5 - 10);
         pauseImg.smoothing = true;
         cover.addChild(pauseImg);
         // 添加事件监听器，用于应用程序激活、停用和舞台调整大小
         NativeApplication.nativeApplication.addEventListener("activate",on_activate);//监听程序得到焦点
         NativeApplication.nativeApplication.addEventListener("deactivate",on_deactivate);//监听程序失去焦点
         stage.addEventListener("resize",on_resize);//监听程序窗口缩放
      }
      /*意义不明，已删除，通过*删除特征*实现
      public function on_key_down(param1:KeyboardEvent) : void
         param1.preventDefault();
         param1.stopImmediatePropagation();
      }
      */
      public function on_fullscreen() : void//更新全屏状态
      {
         if(Globals.fullscreen)
         {
            stage.stageWidth = stage.fullScreenWidth;
            stage.stageHeight = stage.fullScreenHeight;
            stage.displayState = "fullScreenInteractive";
         }
         else
         {
            stage.stageWidth = 1024;
            stage.stageHeight = 640;
            stage.displayState = "normal";
         }
         on_resize(null);
      }
      
      public function on_resize(param1:*) : void//缩放窗口时处理游戏UI缩放
      {
         if(!mStarling || !mStarling.root)
         {
            return;
         }
         fullScreenWidth = Globals.stageWidth = stage.stageWidth;
         fullScreenHeight = Globals.stageHeight = stage.stageHeight;
         var _loc3_:Number = Main.fullScreenWidth / keyWidth;
         var _loc2_:Rectangle = RectangleUtil.fit(new Rectangle(0,0,screenWidth * _loc3_,screenHeight * _loc3_),new Rectangle(0,0,Main.fullScreenWidth,Main.fullScreenHeight),"none");
         mStarling.viewPort = _loc2_;
         var _loc5_:Shape;
         (_loc5_ = cover.getChildAt(0) as Shape).graphics.clear();
         _loc5_.graphics.beginFill(0);
         _loc5_.graphics.drawRect(-10,-10,Main.fullScreenWidth + 20,Main.fullScreenHeight + 20);
         _loc5_.graphics.endFill();
         _loc5_.alpha = 0.5;
         var _loc4_:Bitmap = cover.getChildAt(1) as Bitmap;
         var _loc6_:* = Main.fullScreenWidth / 1024 * 0.5;
         _loc4_.scaleY = Main.fullScreenWidth / 1024 * 0.5;
         _loc4_.scaleX = _loc6_;
         _loc4_.x = int(_loc5_.width * 0.5 - _loc4_.width * 0.5 - 10);
         _loc4_.y = int(_loc5_.height * 0.5 - _loc4_.height * 0.5 - 10);
         _loc4_.smoothing = true;
      }
      
      public function on_antialias() : void//抗锯齿
      {
         mStarling.antiAliasing = Math.pow(2,Globals.antialias);
      }
      
      public function on_activate(param1:*) : void
      {
      }
      
      public function on_deactivate(param1:*) : void//暂停相关，失去焦点时执行
      {
         if(!Globals.nohub)//这里的修改是通过改P-code实现的，调整后台运行
         {
            mStarling.stop();
            GS.pauseMusic();
            addChild(cover);
            cover.addEventListener("click",on_resume);
         }
      }
      
      public function on_resume(param1:MouseEvent) : void//取消暂停相关，点击暂停遮罩时执行
      {
         cover.removeEventListener("click",on_resume);
         removeChild(cover);
         mStarling.start();
         GS.resumeMusic();
      }
   }
}
