package
{
   import Game.Debug;
   import Game.GameScene;
   import Menus.EndScene;
   import Menus.TitleMenu;
   import flash.events.KeyboardEvent;
   import starling.core.Starling;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.filters.ColorMatrixFilter;
   import starling.textures.Texture;
   import starling.utils.AssetManager;
   import utils.ProgressBar;
   
   public class Root extends Sprite
   {
      
      private static var sAssets:AssetManager;
      
      public static var bg:ScrollingBackground;
       
      
      private var mActiveScene:Sprite;
      
      public var scenes:Sprite;
      
      public var titleMenu:TitleMenu;
      
      public var gameScene:GameScene;
      
      public var endScene:EndScene;

      public var debug:Debug;
      
      public function Root()
      {
         super();
      }
      
      public static function get assets() : AssetManager
      {
         return sAssets;
      }
      
      public function start(param1:Texture, param2:AssetManager) : void
      {
         var bgImage:Image;
         var progressBar:ProgressBar;//对象类型：进度条
         var background:Texture = param1;
         var assets:AssetManager = param2;
         var sprogressBar:ProgressBar;//新二代用复刻三代进度条
         sAssets = assets;
         this.alpha = 0.9999;
         bgImage = new Image(background);
         addChild(bgImage);
         progressBar = new ProgressBar(512,3,true);//实例化对象，参数：长512，宽3，类型为原版进度条
         //调整位置
         progressBar.x = (background.width - progressBar.width) / 2;
         //progressBar.y = (background.height - progressBar.height) / 2;   新二代已删除
         progressBar.y = background.height * 0.55;
         addChild(progressBar);
         //新二代进度条
         sprogressBar = new ProgressBar(512,30,false);//实例化对象，参数：长512，宽30，类型为新版进度条
         sprogressBar.x = (background.width - progressBar.width) / 2;
         sprogressBar.y = background.height * 0.48;
         addChild(sprogressBar);
         assets.loadQueue((function():*
         {
            var onProgress:Function;//声明函数对象
            return onProgress = function(param1:Number):void
            {
               var ratio:Number = param1;
               progressBar.ratio = ratio;
               sprogressBar.ratio = ratio;//新版进度条代码
               if(ratio == 1)//加载完成时
               {
                  Starling.juggler.delayCall(function():void
                  {
                     progressBar.removeFromParent(true);
                     sprogressBar.removeFromParent(true);//新版进度条代码
                     removeChildAt(0);
                     LevelData.init();
                     bg = new ScrollingBackground();
                     addChild(bg);
                     titleMenu = new TitleMenu();
                     gameScene = new GameScene();
                     endScene = new EndScene();
                     debug = new Debug();
                     addChild(titleMenu);
                     addChild(gameScene);
                     addChild(endScene);
                     GS.init();
                     if(Globals.blackQuad)//新二代增加的黑边存在性判断
                     {
                        var _loc2_:Quad = new Quad(1024,114,0);
                        _loc2_.alpha = 0.4;
                        addChild(_loc2_);
                        var _loc1_:Quad = new Quad(1024,114,0);
                        _loc1_.y = 768 - _loc1_.height;
                        _loc1_.alpha = 0.4;
                        addChild(_loc1_);
                     }
                     titleMenu.firstInit();
                     addChild(debug);
                     debug.init(gameScene,titleMenu);
                     titleMenu.addEventListener("start",on_title_start);
                     Starling.current.nativeStage.addEventListener("keyDown",on_key_down);
                  },0.15);
               }
            };
         })());
      }
      
      public function on_key_down(param1:KeyboardEvent) : void
      {
         debug.on_key_down(param1.keyCode);
         switch(param1.keyCode)
         {
            case 27://对应Esc键
               if(titleMenu.visible)
               {
                  if(titleMenu.optionsMenu.visible)
                  {
                     titleMenu.optionsMenu.animateOut();
                     break;
                  }
                  titleMenu.on_menu(null);
                  break;
               }
               if(gameScene.visible)
                  gameScene.quit();
               break;
            case 81: // Q 启用 Debug 模式
               debug.startDebugMode();
               break;
         }
         if(gameScene.visible)
         {
            switch(param1.keyCode)
            {
               case 32://对应Spacebar，即空格
                  if(!Starling.current.isStarted)
                  {
                     Globals.main.on_resume(null);
                     break;
                  }
                  gameScene.pause();
                  break;
               case 49://大键盘上的1
               case 97://小键盘上的1
                  gameScene.ui.movePerc = 0.1;
                  break;
               case 50://大键盘上的2
               case 98://小键盘上的2
                  gameScene.ui.movePerc = 0.2;
                  break;
               case 51:
               case 99:
                  gameScene.ui.movePerc = 0.3;
                  break;
               case 52:
               case 100:
                  gameScene.ui.movePerc = 0.4;
                  break;
               case 53:
               case 101:
                  gameScene.ui.movePerc = 0.5;
                  break;
               case 54:
               case 102:
                  gameScene.ui.movePerc = 0.6;
                  break;
               case 55:
               case 103:
                  gameScene.ui.movePerc = 0.7;
                  break;
               case 56:
               case 104:
                  gameScene.ui.movePerc = 0.8;
                  break;
               case 57:
               case 105:
                  gameScene.ui.movePerc = 0.9;
                  break;
               case 48:
               case 96:
                  gameScene.ui.movePerc = 1;
            }
            gameScene.ui.movePercentBar(gameScene.ui.movePerc);
         }
         param1.preventDefault();
         param1.stopImmediatePropagation();
      }
      
      public function applyFilter() : void
      {
         var _loc1_:ColorMatrixFilter = new ColorMatrixFilter();
         _loc1_.adjustBrightness(0.1);
         _loc1_.adjustContrast(0.25);
         this.filter = _loc1_;
      }
      
      public function initTitleMenu() : void
      {
         titleMenu.init();
         titleMenu.addEventListener("start",on_title_start);
      }
      
      public function deInitTitleMenu() : void
      {
         titleMenu.deInit();
         titleMenu.removeEventListener("start",on_title_start);
      }
      
      public function on_title_start(param1:Event) : void
      {
         initGameScene();
      }
      
      public function resumeGameScene() : void
      {
         gameScene.animateIn();
      }
      
      public function initGameScene() : void
      {
         gameScene.init();
         if(!gameScene.hasEventListener("menu"))
            gameScene.addEventListener("menu",on_menu);
         if(!gameScene.hasEventListener("next"))
            gameScene.addEventListener("next",on_next);
         if(!gameScene.hasEventListener("end"))
            gameScene.addEventListener("end",on_end);
         debug.init_game();
      }
      
      public function deInitGameScene() : void
      {
         gameScene.deInit();
         gameScene.removeEventListener("menu",on_menu);
         gameScene.removeEventListener("next",on_next);
         gameScene.removeEventListener("end",on_end);
      }
      
      public function on_menu(param1:Event) : void
      {
         titleMenu.init();
         titleMenu.animateIn();
      }
      
      public function on_next(param1:Event) : void
      {
         titleMenu.init();
         titleMenu.animateIn();
         titleMenu.nextLevel();
      }
      
      public function on_end(param1:Event) : void
      {
         endScene.init();
         endScene.addEventListener("done",on_end_done);
      }
      
      public function on_end_done(param1:Event) : void
      {
         endScene.removeEventListener("done",on_end_done);
         endScene.deInit();
         titleMenu.initAfterEnd();
         GS.playMusic("bgm01");
      }
   }
}
