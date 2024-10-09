// 该类管理整个设置界面
package Menus
{
   import starling.core.Starling;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.EnterFrameEvent;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.text.TextField;

   public class OptionsMenu extends Sprite
   {
      public var windowStrings:Array; // 窗口模式文本
      public var aaStrings:Array; // 抗锯齿文本
      public var sizeStrings:Array; // 字体大小文本
      public var controlStrings:Array; // 控制方式文本
      public var lineHeight:Number;
      public var COLOR:uint;

      public var title:TitleMenu; // 接入标题类
      public var menuBtn:MenuButton;
      public var quitBtn:MenuButton;
      public var prevBtn:MenuButton; // 上一页按钮
      public var nextBtn:MenuButton; // 下一页按钮
      public var fullscreen:Array;
      public var antialias:Array;
      public var textsizes:Array;
      public var controls:Array;
      public var audioSlider:OptionSlider;
      public var musicSlider:OptionSlider;
      public var transitionSlider:OptionSlider2;
      public var satSlider:OptionSlider;
      public var resetBtn:OptionButton;
      public var resetBtn2:OptionButton;
      public var tooltip1:Tooltip;
      public var tooltip2:Tooltip;
      public var page:int = 0;
      public var pages:Array; // 选项页面数组
      public var pageLayers:Array; // 页面层数组
      public var page0:Sprite;
      public var page1:Sprite;
      public var page2:Sprite;

      public var mapPage:int = 0; // 地图页面索引

      public function OptionsMenu(_titleMenu:TitleMenu)
      {
         super();
         windowStrings = ["FULLSCREEN", "RESIZEABLE WINDOW"];
         aaStrings = ["0x", "2x", "4x", "8x", "16x"];
         sizeStrings = ["SMALL", "MEDIUM", "LARGE"];
         controlStrings = ["MULTI-TOUCH", "TRADITIONAL"];
         lineHeight = 36;
         COLOR = 16752059;
         this.title = _titleMenu;
         var bg:Quad = new Quad(1024, 768, 0);
         bg.alpha = 0.65;
         addChild(bg);
         page = 0;
         pages = [[], [[],[]], []];
         pageLayers = [];
         page0 = new Sprite();
         page1 = new Sprite();
         page2 = new Sprite();
         pageLayers.push(page0);
         pageLayers.push(page1);
         pageLayers.push(page2);
         for (var i:int = 0; i < pages.length; i++)
         {
            pageLayers[i].x = pageLayers[i].pivotX = 512;
            pageLayers[i].y = pageLayers[i].pivotY = 384;
            addChild(pageLayers[i]);
         }
         // #region 左上角四个按钮
         quitBtn = new MenuButton("btn_close");
         quitBtn.x = 15 + Globals.margin;
         quitBtn.y = 124;
         quitBtn.blendMode = "add";
         addChild(quitBtn);
         menuBtn = new MenuButton("btn_menu");
         menuBtn.x = 50 + Globals.margin;
         menuBtn.y = 124;
         menuBtn.blendMode = "add";
         addChild(menuBtn);
         prevBtn = new MenuButton("tutorial_arrow");
         prevBtn.x = 120 + Globals.margin;
         prevBtn.y = 146;
         prevBtn.image.rotation = Math.PI;
         prevBtn.blendMode = "add";
         prevBtn.setImage("tutorial_arrow", 0.75);
         addChild(prevBtn);
         nextBtn = new MenuButton("tutorial_arrow");
         nextBtn.x = 130 + Globals.margin;
         nextBtn.y = 124;
         nextBtn.blendMode = "add";
         nextBtn.setImage("tutorial_arrow", 0.75);
         addChild(nextBtn);
         // #endregion
         createPage0();
         createPage1();
         createPage2();
         tooltip1 = new Tooltip(0);
         tooltip1.visible = false;
         tooltip1.x = controls[0].x;
         tooltip1.y = controls[0].y;
         addChild(tooltip1);
         controls[0].quad.addEventListener("touch", on_tooltip1);
         tooltip2 = new Tooltip(1);
         tooltip2.visible = false;
         tooltip2.x = controls[1].x;
         tooltip2.y = controls[1].y;
         addChild(tooltip2);
         controls[1].quad.addEventListener("touch", on_tooltip2);
         menuBtn.init();
         menuBtn.addEventListener("clicked", on_menu);
         quitBtn.init();
         quitBtn.addEventListener("clicked", on_menu);
         prevBtn.init();
         prevBtn.addEventListener("clicked", on_prev);
         nextBtn.init();
         nextBtn.addEventListener("clicked", on_next);
         on_refresh();
      }

      public function createPage0():void
      {
         var i:int;
         var _btn:OptionButton;
         // #region VIDEO
         pages[0].push(new TextField(200, 40, "VIDEO", "Downlink18", -1, COLOR));
         pages[0].push(new TextField(200, 40, "WINDOW MODE:", "Downlink12", -1, COLOR));
         fullscreen = [];
         for (i = 0; i < windowStrings.length; i++)
         {
            _btn = new OptionButton(windowStrings[i], COLOR, fullscreen);
            _btn.x = 330 + i * 140;
            _btn.init();
            _btn.addEventListener("clicked", on_fullscreen);
            fullscreen.push(_btn);
            pages[0].push(fullscreen);
         }
         pages[0].push(new TextField(200, 40, "ANTI-ALIASING:", "Downlink12", -1, COLOR));
         antialias = [];
         for (i = 0; i < aaStrings.length; i++)
         {
            _btn = new OptionButton(aaStrings[i], COLOR, antialias);
            _btn.x = 330 + i * 60;
            _btn.init();
            _btn.addEventListener("clicked", on_antialias);
            antialias.push(_btn);
            pages[0].push(antialias);
         }
         // #endregion
         // #region AUDIO
         pages[0].push(new TextField(200, 40, "AUDIO", "Downlink18", -1, COLOR));
         pages[0].push(new TextField(200, 40, "SOUND VOLUME:", "Downlink12", -1, COLOR));
         audioSlider = new OptionSlider(1);
         audioSlider.x = 330;
         audioSlider.init();
         pages[0].push(audioSlider);
         pages[0].push(new TextField(200, 40, "MUSIC VOLUME:", "Downlink12", -1, COLOR));
         musicSlider = new OptionSlider(1);
         musicSlider.x = 330;
         musicSlider.init();
         pages[0].push(musicSlider);
         // #endregion
         // #region GAME
         pages[0].push(new TextField(200, 40, "GAME", "Downlink18", -1, COLOR));
         pages[0].push(new TextField(200, 40, "TEXT SIZE:", "Downlink12", -1, COLOR));
         textsizes = [];
         for (i = 0; i < sizeStrings.length; i++)
         {
            _btn = new OptionButton(sizeStrings[i], COLOR, textsizes);
            _btn.x = 330 + i * 90;
            _btn.init();
            _btn.addEventListener("clicked", on_textsize);
            textsizes.push(_btn);
            pages[0].push(textsizes);
         }
         pages[0].push(new TextField(200, 40, "CONTROL METHOD:", "Downlink12", -1, COLOR));
         controls = [];
         for (i = 0; i < controlStrings.length; i++)
         {
            _btn = new OptionButton(controlStrings[i], COLOR, controls);
            _btn.x = 330 + i * 130;
            _btn.init();
            _btn.addEventListener("clicked", on_controls);
            controls.push(_btn);
            pages[0].push(controls);
         }
         pages[0].push(new TextField(200, 40, "TRANSITION SPEED:", "Downlink12", -1, COLOR));
         transitionSlider = new OptionSlider2(1);
         transitionSlider.x = 330;
         transitionSlider.init();
         pages[0].push(transitionSlider);
         pages[0].push(new TextField(200, 40, "SAVE FILE:", "Downlink12", -1, COLOR));
         resetBtn = new OptionButton("RESET PROGRESS", 16742263, null);
         resetBtn.x = 330;
         resetBtn.y = _y;
         resetBtn.init();
         resetBtn.addEventListener("clicked", on_show_reset);
         pages[0].push(resetBtn);
         resetBtn2 = new OptionButton("CONFIRM?", 16720418, null);
         resetBtn2.x = 330 + resetBtn.width - 60;
         resetBtn2.init();
         resetBtn2.addEventListener("clicked", on_reset);
         pages[0].push(resetBtn2);
         // #endregion
         // #region 添加实例化对象
         var _y:Number = 120;
         for (i = 0; i < pages[0].length; i++)
         {
            if (pages[0][i] is TextField)
            {
               addLabel(pages[0][i], 100, _y);
               if (pages[0][i].fontName == "Downlink18")
                  _y += lineHeight * 1.6;
               else
                  _y += lineHeight;
               pages[0][i].y = _y;
            }
            else if (pages[0][i] is Array)
            {
               for (var j:int = 0; j < pages[0][i].length; j++)
               {
                  pages[0][i][j].y = _y;
                  pageLayers[0].addChild(pages[0][i][j]);
               }
            }
            else
            {
               pages[0][i].y = _y;
               pageLayers[0].addChild(pages[0][i]);
            }
         }
         // #endregion
      }

      public function createPage1():void
      {
         var _text:TextField = new TextField(200, 40, "MAP MANAGER", "Downlink18", -1, COLOR);
         pages[1][0].push(_text);
         addLabel(_text, 412, 122, 1, "center");
         var _btn:MenuButton = new MenuButton("btn_restart");
         _btn.x = 604;
         _btn.y = 124;
         _btn.init();
         _btn.addEventListener("clicked", on_refresh);
         pages[1][0].push(_btn);
         pageLayers[1].addChild(_btn);
         _btn = new MenuButton("tutorial_arrow");
         _btn.x = 670;
         _btn.y = 146;
         _btn.image.rotation = Math.PI;
         _btn.init();
         _btn.setImage("tutorial_arrow", 0.75);
         _btn.addEventListener("clicked", on_page1_prev);
         pages[1][0].push(_btn);
         pageLayers[1].addChild(_btn);
         _btn = new MenuButton("tutorial_arrow");
         _btn.x = 680;
         _btn.y = 124;
         _btn.init();
         _btn.setImage("tutorial_arrow", 0.75);
         _btn.addEventListener("clicked", on_page1_next);
         pages[1][0].push(_btn);
         pageLayers[1].addChild(_btn);
      }

      public function createPage2():void
      {
         // #region 添加文本
         pages[2].push(new TextField(400, 40, "ORIGINAL", "Downlink18", -1, COLOR));
         pages[2].push(new TextField(400, 40, "DESIGN, ART, CODE:", "Downlink12", -1, COLOR));
         pages[2].push(new TextField(400, 40, "NICO TUASON", "Downlink12", -1, COLOR));
         pages[2].push(new TextField(400, 40, "MUSIC:", "Downlink12", -1, COLOR));
         pages[2].push(new TextField(400, 40, "JOHN CAMARA", "Downlink12", -1, COLOR));
         pages[2].push(new TextField(400, 40, "PLAYTESTING:", "Downlink12", -1, COLOR));
         pages[2].push(new TextField(400, 40, "TERRY TUASON", "Downlink12", -1, COLOR));
         pages[2].push(new TextField(400, 40, "MODIFIED", "Downlink18", -1, COLOR));
         pages[2].push(new TextField(400, 40, "CODE:", "Downlink12", -1, COLOR));
         pages[2].push(new TextField(400, 40, "QoZnoS", "Downlink12", -1, COLOR));
         pages[2].push(new TextField(400, 40, "SPECIAL THANKS:", "Downlink18", -1, COLOR));
         pages[2].push(new TextField(400, 40, "Solarmax23333", "Downlink12", -1, COLOR));
         // #endregion
         // #region 添加实例化对象
         var _y:Number = 120;
         var _side:int = 0;
         for (var i:int = 0; i < pages[2].length; i++)
         {
            if (pages[2][i].fontName == "Downlink18")
            {
               addLabel(pages[2][i], 312, _y, 2, "center");
               _y += lineHeight * 1.6;
            }
            else
            {
               if (_side == 0)
               {
                  addLabel(pages[2][i], 100, _y, 2, "right");
                  _side = 1;
                  _y += lineHeight;
               }
               else
               {
                  addLabel(pages[2][i], 520, _y, 2, "left");
                  _side = 0;
               }
            }
            pages[2][i].y = _y;
         }
         // #endregion
      }

      private function addLabel(_label:TextField, _x:Number, _y:Number, _page:int = 0, _hAlign:String = "right"):void
      {
         _label.hAlign = _hAlign;
         _label.vAlign = "top";
         _label.x = _x;
         _label.y = _y;
         pageLayers[_page].addChild(_label);
      }

      public function animateIn():void
      {
         this.alpha = 0;
         this.visible = true;
         Starling.juggler.removeTweens(this);
         Starling.juggler.tween(this, 0.15, {"alpha": 1});
         if (Globals.fullscreen)
            fullscreen[0].toggle();
         else
            fullscreen[1].toggle();
         if (Globals.touchControls)
            controls[0].toggle();
         else
            controls[1].toggle();
         antialias[Globals.antialias].toggle();
         if (Globals.textSize == 2)
            menuBtn.setImage("btn_menu2x", 0.75);
         else
            menuBtn.setImage("btn_menu");
         textsizes[Globals.textSize].toggle();
         audioSlider.total = Globals.soundVolume;
         musicSlider.total = Globals.musicVolume;
         transitionSlider.total = Globals.transitionSpeed * 0.5;
         Starling.juggler.removeTweens(resetBtn2);
         resetBtn2.alpha = 0;
         audioSlider.update();
         musicSlider.update();
         transitionSlider.update();
         addEventListener("enterFrame", update);
      }

      public function animateOut():void
      {
         Starling.juggler.removeTweens(this);
         Starling.juggler.tween(this, 0.15, {
                  "alpha": 0,
                  "onComplete": hide
               });
         removeEventListener("enterFrame", update);
      }

      public function hide():void
      {
         this.visible = false;
      }
      // #region 界面按钮
      public function on_menu(_click:Event):void
      {
         Globals.save();
         animateOut();
      }

      public function on_prev(_click:Event):void
      {
         if (page > 0)
            page--;
      }

      public function on_next(_click:Event):void
      {
         if (page < pages.length - 1)
            page++;
      }
      // #endregion
      // #region page0按钮
      public function on_fullscreen(_click:Event):void
      {
         var _index:int = fullscreen.indexOf(_click.target);
         if (_index == 0)
            Globals.fullscreen = true;
         else
            Globals.fullscreen = false;
         Globals.main.on_fullscreen();
      }

      public function on_antialias(_click:Event):void
      {
         var _index:int = antialias.indexOf(_click.target);
         Globals.antialias = _index;
      }

      public function on_textsize(_click:Event):void
      {
         var _index:int = textsizes.indexOf(_click.target);
         Globals.textSize = _index;
         title.on_resize();
      }

      public function on_controls(_click:Event):void
      {
         var _index:int = controls.indexOf(_click.target);
         if (_index == 0)
            Globals.touchControls = true;
         else
            Globals.touchControls = false;
      }

      public function on_show_reset(_click:Event):void
      {
         Starling.juggler.tween(resetBtn2, 0.5, {"alpha": 1});
      }

      public function on_reset(_click:Event):void
      {
         title.on_reset();
         animateOut();
      }
      // #endregion
      // #region page1按钮
      public function on_refresh():void
      {
         LevelData.init();
         title.getBarrierData();
         title.getOrbitData();
         var _dataQuad:OptionButton;
         if (pages[1][1].length != 0)
         {
            for each (_dataQuad in pages[1][1])
            {
               _dataQuad.removeEventListener("clicked", on_choose_map);
               pageLayers[1].removeChild(_dataQuad);
            }
            pages[1][1] = [];
         }
         var _y:Number = 160;
         for each (var _data:Array in LevelData.data)
         {
            _dataQuad = new OptionButton("MAPER: " + _data[1][0], COLOR, pages[1][1]);
            _dataQuad.label.fontName = "Downlink18";
            _dataQuad.label.width = 700;
            _dataQuad.label.x += 40;
            _dataQuad.addLabel(new TextField(40, 40,"#" + LevelData.data.indexOf(_data), "Downlink18", -1, COLOR), 0, 0)
            _dataQuad.quad.color = 0;
            _dataQuad.quad.alpha = 0.5;
            _dataQuad.quad.width = _dataQuad.labelBG.width = 768;
            _dataQuad.quad.height = _dataQuad.labelBG.height = 120;
            _dataQuad.x = 128;
            _dataQuad.y = _y;
            _dataQuad.init();
            _dataQuad.addEventListener("clicked", on_choose_map);
            pages[1][1].push(_dataQuad);
            pageLayers[1].addChild(_dataQuad);
            _y += 125;
            if (_y > 600)
               _y -= 500;
         }
         pages[1][1][Globals.currentData].toggle();
      }

      public function on_choose_map(_click:Event):void
      {
         var _index:int = pages[1][1].indexOf(_click.target);
         Globals.currentData = _index;
         LevelData.init();
         title.getBarrierData();
         title.getOrbitData();
         animateOut();
      }

      public function on_page1_prev(_click:Event):void
      {
         if (mapPage > 0)
            mapPage--;
      }

      public function on_page1_next(_click:Event):void
      {
         if (mapPage < pages[1][1].length - 1)
            mapPage++;
      }
      // #endregion
      public function on_tooltip1(_touchEvent:TouchEvent):void
      {
         var _touch:Touch = _touchEvent.getTouch(controls[0].quad);
         if (!_touch)
         {
            tooltip1.visible = false;
            return;
         }
         if (_touch.phase == "hover")
            tooltip1.visible = true;
      }

      public function on_tooltip2(_touchEvent:TouchEvent):void
      {
         var _touch:Touch = _touchEvent.getTouch(controls[1].quad);
         if (!_touch)
         {
            tooltip2.visible = false;
            return;
         }
         if (_touch.phase == "hover")
            tooltip2.visible = true;
      }

      public function update(e:EnterFrameEvent):void
      {
         Globals.soundVolume = audioSlider.total;
         Globals.musicVolume = musicSlider.total;
         GS.updateTransforms();
         Globals.transitionSpeed = transitionSlider.total * 2;
         for (var i:int = 0; i < pageLayers.length; i++)
         {
            pageLayers[i].visible = false;
         }
         pageLayers[page].visible = true;
         if (page == 0)
            prevBtn.visible = false;
         else
            prevBtn.visible = true;
         if (page == pages.length - 1)
            nextBtn.visible = false;
         else
            nextBtn.visible = true;
         if (mapPage == 0)
            pages[1][0][2].visible = false;
         else
            pages[1][0][2].visible = true;
         if (mapPage == Math.floor(pages[1][1].length/4))
            pages[1][0][3].visible = false;
         else
            pages[1][0][3].visible = true;
         for(var i:int = 0; i < pages[1][1].length; i++)
         {
            if(mapPage*4 <= i && i < mapPage*4 + 4)
               pages[1][1][i].visible = true;
            else
               pages[1][1][i].visible = false;
         }
      }
   }
}
