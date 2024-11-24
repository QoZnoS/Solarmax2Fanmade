package Menus
{
   import flash.desktop.NativeApplication;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import starling.core.Starling;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.QuadBatch;
   import starling.display.Sprite;
   import starling.events.EnterFrameEvent;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.text.TextField;

   public class TitleMenu extends Sprite
   {
      public var cover:Quad; // 进入游戏和通关36时的白光遮罩
      public var title:Image; // Solarmax2 标题
      public var title_blur:Image; // Solarmax2 标题模糊光圈
      public var credits:Array; // 显示作者信息
      public var previewLayer:Sprite;
      public var uiLayer:Sprite;
      public var levels:LevelButtons;
      public var deltaScroll:Point;
      public var mouseDown:Boolean;
      public var quad:Quad;
      public var bQuad:Quad;
      public var touchQuad:Quad;
      public var selector:QuadBatch;
      public var preview:QuadBatch;
      public var preview2:QuadBatch;
      public var previewQuad:QuadBatch;
      public var quadImage:Image;
      public var shapeImage:Image;
      public var menuBtn:MenuButton;
      public var quitBtn:MenuButton;
      public var optionsMenu:OptionsMenu;
      public var currentIndex:int;
      public var nodeTypes:Array;
      public var barrierData:Array; // 三维数组，第一层为关卡，第二层为障碍线，第三层为 [中点X，中点Y，距离，角度]
      public var orbitData:Array; // 三维数组，第一层为关卡，第二层为轨道，第三层为 [中心，距离]
      public var difficultyButtons:Array;
      public var difficultyHolder:Sprite;
      public var starIcon:Image;
      public var starLabel:TextField;

      private var downIndex:int;
      private var dragging:Boolean;
      private var hoverIndex:int;

      public function TitleMenu() // 文档类
      {
         var i:int = 0;
         // 这部分是初始化内容
         dragging = false;
         hoverIndex = -1;
         nodeTypes = ["planet", "warp", "habitat", "barrier", "tower", "dilator", "starbase", "pulsecannon","blackhole","cloneturret"];
         super();
         quad = new Quad(2, 2, 16777215);
         quadImage = new Image(Root.assets.getTexture("quad8x4"));
         quadImage.adjustVertices();
         deltaScroll = new Point(0, 0);
         previewLayer = new Sprite();
         uiLayer = new Sprite();
         addChild(previewLayer);
         addChild(uiLayer);
         // 障碍线预览
         bQuad = new Quad(160, 6, 16733525);
         bQuad.pivotX = 80;
         bQuad.pivotY = 3;
         bQuad.alpha = 1;
         // 
         title = new Image(Root.assets.getTexture("title_logo"));
         title.pivotX = title.width * 0.5;
         title.pivotY = title.height * 0.5;
         title.x = 512;
         title.y = 384;
         title.color = 16755370;
         title.alpha = 0.5;
         title.blendMode = "add";
         addChild(title);
         title_blur = new Image(Root.assets.getTexture("title_logo_blur"));
         title_blur.pivotX = title.width * 0.5;
         title_blur.pivotY = title.height * 0.5;
         title_blur.x = 512;
         title_blur.y = 384;
         title_blur.color = 16755370;
         title_blur.alpha = 0.3;
         title_blur.blendMode = "add";
         addChild(title_blur);
         credits = [];
         credits.push(new TextField(600, 40, "CREATED BY NICO TUASON", "Downlink12", -1, 16755370));
         credits.push(new TextField(600, 40, "MODIFIED BY QoZnoS", "Downlink12", -1, 16755370));
         for (i = 0; i < credits.length; i++) // 留作彩蛋 :P
         {
            credits[i].pivotX = 300;
            credits[i].pivotY = 20;
            credits[i].x = title.x;
            credits[i].y = title.y + 20 * i + 50;
            credits[i].blendMode = "add";
            credits[i].alpha = 0.2;
         }
         levels = new LevelButtons();
         levels.x = title.x;
         levels.y = title.y + 200;
         addChild(levels);
         preview = new QuadBatch();
         preview.blendMode = "add";
         preview.alpha = 0.4;
         previewLayer.addChild(preview);
         preview2 = new QuadBatch();
         preview2.alpha = 0.8;
         previewLayer.addChild(preview2);
         previewQuad = new QuadBatch();
         previewQuad.blendMode = "add";
         previewQuad.alpha = 0.4;
         previewLayer.addChild(previewQuad);
         previewLayer.x = previewLayer.pivotX = 512;
         previewLayer.y = previewLayer.pivotY = 384;
         previewLayer.y -= 30;
         previewLayer.scaleX = previewLayer.scaleY = 0.7;
         shapeImage = new Image(Root.assets.getTexture("planet_shape"));
         shapeImage.pivotX = shapeImage.pivotY = shapeImage.width * 0.5;
         selector = new QuadBatch();
         drawSelector(0, 0, 16755370, 48, 46);
         selector.x = title.x;
         selector.y = levels.y - 1;
         selector.blendMode = "add";
         selector.alpha = 0;
         addChild(selector);
         cover = new Quad(1024, 768, 16777215);
         cover.blendMode = "add";
         cover.touchable = false;
         addChild(cover);
         touchQuad = new Quad(1024, 768, 16711680);
         touchQuad.alpha = 0;
         addChild(touchQuad);
         difficultyHolder = new Sprite();
         difficultyButtons = [];
         var _DBtn:DifficultyButton = null;
         for (i = 0; i < 3; i++)
         {
            _DBtn = new DifficultyButton(i, difficultyButtons);
            _DBtn.x = i * 100;
            difficultyHolder.addChild(_DBtn);
            difficultyButtons.push(_DBtn);
         }
         difficultyHolder.x = 412;
         difficultyHolder.y = 150;
         addChild(difficultyHolder);
         starLabel = new TextField(120, 40, "0", "Downlink22", -1, 16755370);
         starLabel.hAlign = "right";
         starLabel.pivotX = 120;
         starLabel.pivotY = 20;
         starLabel.y = 137;
         starLabel.x = 974 - Globals.margin;
         starLabel.blendMode = "add";
         starLabel.alpha = 0.5;
         addChild(starLabel);
         starIcon = new Image(Root.assets.getTexture("star"));
         starIcon.pivotX = starIcon.width * 0.5;
         starIcon.pivotY = starIcon.height * 0.5;
         starIcon.y = 136;
         starIcon.x = 994 - Globals.margin;
         starIcon.alpha = 0.4;
         starIcon.blendMode = "add";
         addChild(starIcon);
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
         optionsMenu = new OptionsMenu(this);
         addChild(optionsMenu);
         optionsMenu.visible = false;
         // 这部分是计算内容
         getBarrierData();
         getOrbitData();
      }
      // #region 障碍轨道计算器
      public function getBarrierData():void
      {
         barrierData = [];
         for (var i:int = 0; i < LevelData.maps.length; i++)
         {
            var barriers:Array = [];
            var level:Array = LevelData.maps[i];
            var levelLength:int = level.length;
            for (var j:int = 0; j < levelLength; j++)
            {
               if (level[j][2] != 3)
                  continue;
               if (level[j].length >= 8 && level[j][7] is Array)
               {
                  processCustomBarrier(level, j, barriers);
               }
               else
               {
                  processRegularBarrier(level, j, levelLength, barriers);
               }
            }
            barrierData.push(barriers);
         }
      }

      private function processCustomBarrier(level:Array, node:int, barriers:Array):void
      {
         var connectedBarriers:Array = level[node][7] is Array ? level[node][7] : [int(level[node][7])];
         for (var k:int = 0; k < connectedBarriers.length; k++)
         {
            var connectedIndex:int = connectedBarriers[k];
            if (level[connectedIndex][2] != 3)
               continue;
            var barrierInfo:Array = calculateBarrierInfo(level[node], level[connectedIndex]);
            addUniqueBarrier(barriers, barrierInfo);
         }
      }

      private function processRegularBarrier(level:Array, node:int, levelLength:int, barriers:Array):void
      {
         for (var k:int = node + 1; k < levelLength; k++)
         {
            if (level[k][2] != 3 || level[k].length > 7)
               continue;
            if (level[node][0] != level[k][0] && level[node][1] != level[k][1])
               continue;
            var barrierInfo:Array = calculateBarrierInfo(level[node], level[k]);
            if (barrierInfo[2] < 180)
            {
               barriers.push(barrierInfo);
            }
         }
      }

      private function calculateBarrierInfo(barrier1:Array, barrier2:Array):Array
      {
         var dx:Number = barrier2[0] - barrier1[0];
         var dy:Number = barrier2[1] - barrier1[1];
         var distance:Number = Math.sqrt(dx * dx + dy * dy);
         var angle:Number = Math.atan2(dy, dx);
         var midX:Number = barrier1[0] + Math.cos(angle) * distance * 0.5;
         var midY:Number = barrier1[1] + Math.sin(angle) * distance * 0.5;
         return [midX, midY, distance - 10, angle];
      }

      private function addUniqueBarrier(barriers:Array, newBarrier:Array):void
      {
         for (var i:int = 0; i < barriers.length; i++)
         {
            if (check4same(newBarrier, barriers[i]))
               return;
         }
         barriers.push(newBarrier);
      }

      public function check4same(_Array1:Array, _Array2:Array):Boolean // 用于障碍线查重
      {
         var _1:Number = _Array1[0];
         var _2:Number = _Array2[0];
         var _3:Number = _Array1[1];
         var _4:Number = _Array2[1];
         var _5:Number = _Array1[2];
         var _6:Number = _Array2[2];
         var _7:Number = _Array1[3];
         var _8:Number = _Array2[3];
         var _result:Boolean = false;
         if (_1 == _2 && _3 == _4 && _5 == _6 && _7 == _8)
         {
            _result = true;
         }
         return _result;
      }

      public function getOrbitData():void
      {
         orbitData = [];
         for (var i:int = 0; i < LevelData.maps.length; i++)
         {
            var orbit:Array = [];
            var level:Array = LevelData.maps[i];
            var levelLength:int = level.length;
            for (var j:int = 0; j < levelLength; j++)
            {
               var orbitNode:int = int(level[j][5]);
               if (orbitNode == -1)
                  continue;
               if (orbitNode >= 100)
               {
                  orbitNode -= 100;
               }
               var dx:Number = level[j][0] - level[orbitNode][0];
               var dy:Number = level[j][1] - level[orbitNode][1];
               var distance:Number = Math.sqrt(dx * dx + dy * dy);
               addUniqueOrbit(orbit, [orbitNode, distance]);
            }
            orbitData.push(orbit);
         }
      }

      private function addUniqueOrbit(orbit:Array, newOrbit:Array):void
      {
         for (var k:int = 0; k < orbit.length; k++)
         {
            if (orbit[k][0] == newOrbit[0] && orbit[k][1] == newOrbit[1])
            {
               return;
            }
         }
         orbit.push(newOrbit);
      }
      // #endregion
      // #region 界面载入卸载
      public function init():void
      {
         Globals.soundMult = 1;
         commonInit();
         addEventListener("enterFrame", update);
         touchQuad.addEventListener("touch", on_touch);
      }

      public function firstInit():void
      {
         Globals.soundMult = 1;
         cover.visible = true;
         cover.alpha = 1;
         commonInit();
         Starling.juggler.delayCall(function():void
            {
               addEventListener("enterFrame", update);
               touchQuad.addEventListener("touch", on_touch);
               GS.playMusic("bgm01");
            }, 0.55);
      }

      public function initAfterEnd():void
      {
         alpha = 1;
         visible = true;
         currentIndex = 0;
         levels.x = 512;
         deltaScroll.x = 0;
         cover.alpha = 1;
         Root.bg.x = 0;
         previewLayer.y = 354;
         previewLayer.scaleY = 0.7;
         previewLayer.scaleX = 0.7;
         commonInit();
         Starling.juggler.removeTweens(this);
         Starling.juggler.removeTweens(previewLayer);
         addEventListener("enterFrame", update);
         touchQuad.addEventListener("touch", on_touch);
      }

      public function commonInit():void
      {
         mouseDown = false;
         dragging = false;
         menuBtn.init();
         menuBtn.addEventListener("clicked", on_menu);
         quitBtn.init();
         quitBtn.addEventListener("clicked", on_quit);
         levels.updateLevels();
         for (var i:int = 0; i < difficultyButtons.length; i++)
         {
            difficultyButtons[i].init();
            difficultyButtons[i].addEventListener("clicked", on_difficultyButton);
            if (i == Globals.currentDifficulty - 1)
               difficultyButtons[i].toggle();
         }
         updateStarCount();
      }

      public function deInit():void
      {
         for each (var _difficultyBtn:DifficultyButton in difficultyButtons)
         {
            _difficultyBtn.deInit();
            _difficultyBtn.removeEventListener("clicked", on_difficultyButton);
         }
         menuBtn.deInit();
         menuBtn.removeEventListener("clicked", on_menu);
         quitBtn.deInit();
         quitBtn.removeEventListener("clicked", on_quit);
         removeEventListener("enterFrame", update);
         touchQuad.removeEventListener("touch", on_touch);
      }
      // #endregion
      // #region 按钮和动画
      public function on_menu(_click:Event):void
      {
         optionsMenu.animateIn();
      }

      public function on_quit(_click:Event):void
      {
         NativeApplication.nativeApplication.exit();
      }

      public function on_difficultyButton(_click:Event):void
      {
         Globals.currentDifficulty = difficultyButtons.indexOf(_click.target) + 1;
      }

      public function animateIn():void
      {
         updateStarCount();
         this.alpha = 0;
         this.visible = true;
         Starling.juggler.removeTweens(this);
         Starling.juggler.removeTweens(previewLayer);
         Starling.juggler.tween(previewLayer, Globals.transitionSpeed, {
                  "y": 354,
                  "scaleX": 0.7,
                  "scaleY": 0.7,
                  "transition": "easeInOut"
               });
         Starling.juggler.tween(this, Globals.transitionSpeed, {
                  "alpha": 1,
                  "transition": "easeInOut"
               });
      }

      public function animateOut():void
      {
         deInit();
         Starling.juggler.removeTweens(this);
         Starling.juggler.removeTweens(previewLayer);
         Starling.juggler.tween(previewLayer, Globals.transitionSpeed, {
                  "y": 384,
                  "scaleX": 1,
                  "scaleY": 1,
                  "transition": "easeInOut"
               });
         Starling.juggler.tween(this, Globals.transitionSpeed, {
                  "alpha": 0,
                  "transition": "easeInOut",
                  "onComplete": hide
               });
      }

      public function hide():void
      {
         this.visible = false;
      }

      public function nextLevel():void
      {
         if (Globals.level == LevelData.maps.length - 1)
            return;
         Starling.juggler.delayCall(function():void
            {
               currentIndex = Globals.level + 2;
               scrollTo(currentIndex, Globals.transitionSpeed);
            }, Globals.transitionSpeed * 0.75);
      }

      public function on_resize():void
      {
         if (Globals.textSize == 2)
            menuBtn.setImage("btn_menu2x", 0.75);
         else
            menuBtn.setImage("btn_menu");
         levels.updateSize();
      }

      public function on_reset():void
      {
         Globals.levelReached = 0;
         for each (var _star:int in Globals.levelData)
         {
            _star = 0;
         }
         Globals.save();
         initAfterEnd();
      }
      // #endregion
      // #region 更新
      public function update(e:EnterFrameEvent):void
      {
         var _x:Number = NaN;
         var _y:Number = NaN;
         var _R:Number = NaN;
         var _voidR:Number = NaN;
         var _dt:Number = e.passedTime;
         if (this.alpha == 0)
            return;
         if (cover.alpha > 0)
         {
            var _fadeSpeed:Number = currentIndex > 0 ? 0.75 : 0.12;
            cover.alpha = Math.max(0, cover.alpha - _dt * _fadeSpeed);
         }
         if (!Starling.juggler.containsTweens(levels))
         {
            var _scrollDamping:Number = mouseDown ? 0.5 : 0.025;
            deltaScroll.x *= (1 - _scrollDamping);
            levels.x += deltaScroll.x;
            if (!mouseDown && Math.abs(deltaScroll.x) < 2)
            {
               deltaScroll.x = 0;
               var _targetX:Number = Math.round((levels.x - 512) / 120) * 120;
               levels.x += (_targetX - (levels.x - 512)) * 0.1;
            }
         }
         var _minX:Number = 512 - levels.width + 100 + (LevelData.maps.length - (Math.min(Globals.levelReached, LevelData.maps.length - 1) + 1)) * 120;
         levels.x = Math.max(_minX, Math.min(512, levels.x));
         levels.update(_dt, hoverIndex);
         currentIndex = -Math.round((levels.x - 512) / 120);
         var _scale:Number = (levels.x - 512) / -(levels.width - 100);
         Root.bg.setX(Root.bg.x + (-_scale * 1024 * 3 - Root.bg.x) * 0.05);
         updatePreview();
         selector.reset();
         _scale = 1 - Math.abs(levels.x + currentIndex * 120 - 512) / 60;
         _R = 48 * _scale;
         _voidR = _R - 2;
         if (Globals.textSize == 2)
            _voidR = _R - 3;
         if (_voidR < 0)
            _voidR = 0;
         drawSelector(0, 0, 16755370, _R, _voidR);
         selector.blendMode = "add";
         selector.alpha = _scale * 0.5;
         for each (var _difficultyBtn:DifficultyButton in difficultyButtons)
         {
            if (currentIndex > 0)
               _difficultyBtn.scaleX = _difficultyBtn.scaleY = _difficultyBtn.alpha = _scale;
            else
               _difficultyBtn.scaleX = _difficultyBtn.scaleY = _difficultyBtn.alpha = 0;
            if (Globals.levelData[currentIndex - 1] > 0 && difficultyButtons.indexOf(_difficultyBtn) + 1 <= Globals.levelData[currentIndex - 1])
               _difficultyBtn.showStar(true);
            else
               _difficultyBtn.showStar(false);
         }
         if (currentIndex == 0) // 处理进游戏后的 SOLARMAX2 标题渐变
         {
            if (title.alpha < 0.5)
               title.alpha = Math.min(0.5, title.alpha + _dt * 0.5);
         }
         else if (title.alpha > 0)
            title.alpha = Math.max(0, title.alpha - _dt * 0.5);
         title_blur.alpha = title.alpha * 0.6;
         for each (var _text:TextField in credits)
         {
            _text.alpha = title.alpha / 0.5 * 0.2;
         }
      }

      public function updateStarCount():void
      {
         var _allStar:int = 0;
         for each (var _star:int in Globals.levelData)
         {
            _allStar += _star;
         }
         starLabel.text = _allStar.toString();
      }

      private function updatePreview():void
      {
         preview.reset();
         preview2.reset();
         previewQuad.reset();
         if (currentIndex > 0 && LevelData.maps[currentIndex - 1])
         {
            var _data:Array = null;
            var _orbit:Array = null;
            var _x:Number = NaN;
            var _y:Number = NaN;
            var _distence:Number = NaN;
            var _indistence:Number = NaN;
            var _scale:Number = 1 - Math.abs(levels.x + currentIndex * 120 - 512) / 60;
            var _levelData:Array = LevelData.maps[currentIndex - 1];
            for each (var _node:Array in _levelData)
            {
               shapeImage.x = _node[0];
               shapeImage.y = _node[1];
               shapeImage.texture = Root.assets.getTexture(nodeTypes[_node[2]] + "_shape");
               switch (_node[2])
               {
                  case 0:
                     shapeImage.scaleX = shapeImage.scaleY = _node[3] * _scale;
                     break;
                  case 7:
                     shapeImage.scaleX = shapeImage.scaleY = 0.8 * _scale;
                     break;
                  case 8:
                     shapeImage.scaleX = shapeImage.scaleY = 0.75 * _scale;
                     break;
                  default:
                     shapeImage.scaleX = shapeImage.scaleY = _scale;
               }
               shapeImage.color = Globals.teamColors[_node[4]];
               if (shapeImage.color == 0)
                  preview2.addImage(shapeImage);
               else
                  preview.addImage(shapeImage);
            }
            for each (var _barrier:Array in barrierData[currentIndex - 1])
            {
               bQuad.rotation = 0;
               bQuad.width = _barrier[2] * _scale;
               bQuad.x = _barrier[0];
               bQuad.y = _barrier[1];
               bQuad.rotation = _barrier[3];
               previewQuad.addQuad(bQuad);
            }
            for each (var _orbit:Array in orbitData[currentIndex - 1])
            {
               _x = Number(_levelData[_orbit[0]][0]);
               _y = Number(_levelData[_orbit[0]][1]);
               _distence = _orbit[1] * _scale + 2;
               _indistence = Math.max(0, _distence - 2);
               drawCircle(_x, _y, 16777215, _distence, _indistence, false, 0.5, 1, 0, 128);
            }
         }
         preview.blendMode = "add";
         preview.blendMode = "add";
      }

      public function on_key_down(_key:KeyboardEvent):void // 保留函数
      {
      }

      public function on_touch(_getTouch:TouchEvent):void
      {
         var _endPoint:Point = null;
         var _level:int = 0;
         var _touch:Touch = _getTouch.getTouch(touchQuad);
         if (!_touch)
            return;
         switch (_touch.phase)
         {
            case "hover":
               hoverIndex = getClosestIndex(_touch.globalX, _touch.globalY);
               break;
            case "began":
               Starling.juggler.removeTweens(levels);
               downIndex = getClosestIndex(_touch.globalX, _touch.globalY);
               mouseDown = true;
               break;
            case "moved":
               _endPoint = _touch.getMovement(this);
               if (Math.abs(_endPoint.x) > 2)
               {
                  downIndex = -1;
                  dragging = true;
               }
               deltaScroll.x += _endPoint.x;
               break;
            case "ended":
               if (downIndex > -1 && getClosestIndex(_touch.globalX, _touch.globalY) == downIndex && !dragging)
               {
                  if (downIndex > 0 && downIndex == currentIndex)
                     loadMap();
                  else
                  {
                     _level = Math.min(Globals.levelReached, LevelData.maps.length - 1);
                     if (downIndex <= _level + 1)
                        scrollTo(downIndex);
                  }
               }
               else if (!dragging && currentIndex > 0)
               {
                  if (_touch.globalX > 140 && _touch.globalX < 884 && _touch.globalY > 220 && _touch.globalY < 508)
                     loadMap();
               }
               mouseDown = false;
               dragging = false;
         }
      }

      public function scrollTo(_level:int, _time:Number = 0.5):void
      {
         deltaScroll.x = 0;
         Starling.juggler.tween(levels, _time, {
                  "x": -_level * 120 + 512,
                  "transition": "easeOut"
               });
      }

      public function scrollToCurrent():void
      {
         var _levelReached:int = Math.min(Globals.levelReached, LevelData.maps.length - 1);
         if (_levelReached > 0)
         {
            scrollTo(_levelReached + 1, Globals.transitionSpeed);
            currentIndex = _levelReached + 1;
         }
      }
      // #endregion
      // #region 功能函数
      public function loadMap():void
      {
         Globals.level = currentIndex - 1;
         dispatchEventWith("start");
         animateOut();
         GS.playClick();
      }

      public function getClosestIndex(_mouseX:Number, _mouseY:Number):int
      {
         var index:int = Math.round((_mouseX - levels.x) / 120);
         if (index < 0)
            return -1;
         var dx:Number = index * 120 + levels.x - _mouseX;
         var dy:Number = levels.y - _mouseY;
         var distance:Number = dx * dx + dy * dy;
         return (distance < 2304) ? index : -1; // 2304 is 48^2 保证鼠标在关卡按钮附近
      }

      public function drawCircle(_x:Number, _y:Number, _color:uint, _R:Number, _voidR:Number = 0, mTinted:Boolean = false, _alpha:Number = 1, _quality2:Number = 1, _angle:Number = 0, _quality1:int = 64):void
      {
         quadImage.color = _color;
         if (mTinted)
         {
            quadImage.setVertexAlpha(2, 0);
            quadImage.setVertexAlpha(3, 0);
         }
         else
         {
            quadImage.setVertexAlpha(2, 1);
            quadImage.setVertexAlpha(3, 1);
         }
         quadImage.alpha = _alpha;
         quadImage.rotation = 0;
         var _angleStep:Number = 6.283185307179586 / _quality1;
         var _lineNumber:int = Math.ceil(_quality1 * _quality2);
         for (var i:int = 0; i < _lineNumber; i++)
         {
            quadImage.x = _x;
            quadImage.y = _y;
            if (i == _lineNumber - 1)
               _angleStep = 6.283185307179586 * _quality2 - _angleStep * (_lineNumber - 1);
            quadImage.setVertexPosition(0, Math.cos(_angle) * _R, Math.sin(_angle) * _R);
            quadImage.setVertexPosition(1, Math.cos(_angle + _angleStep) * _R, Math.sin(_angle + _angleStep) * _R);
            quadImage.setVertexPosition(2, Math.cos(_angle) * _voidR, Math.sin(_angle) * _voidR);
            quadImage.setVertexPosition(3, Math.cos(_angle + _angleStep) * _voidR, Math.sin(_angle + _angleStep) * _voidR);
            quadImage.vertexChanged();
            preview.addImage(quadImage);
            _angle += _angleStep;
         }
      }

      public function drawSelector(_x:Number, _y:Number, _color:uint, _R:Number, _voidR:Number = 0, mTinted:Boolean = false, _alpha:Number = 1, _quality2:Number = 1, _angle:Number = 0, _quality1:int = 64):void
      {
         quadImage.color = _color;
         if (mTinted)
         {
            quadImage.setVertexAlpha(2, 0);
            quadImage.setVertexAlpha(3, 0);
         }
         else
         {
            quadImage.setVertexAlpha(2, 1);
            quadImage.setVertexAlpha(3, 1);
         }
         quadImage.alpha = _alpha;
         quadImage.rotation = 0;
         var _angleStep:Number = 6.283185307179586 / _quality1;
         var _lineNumber:int = Math.ceil(_quality1 * _quality2);
         for (var i:int = 0; i < _lineNumber; i++)
         {
            quadImage.x = _x;
            quadImage.y = _y;
            if (i == _lineNumber - 1)
               _angleStep = 6.283185307179586 * _quality2 - _angleStep * (_lineNumber - 1);
            quadImage.setVertexPosition(0, Math.cos(_angle) * _R, Math.sin(_angle) * _R);
            quadImage.setVertexPosition(1, Math.cos(_angle + _angleStep) * _R, Math.sin(_angle + _angleStep) * _R);
            quadImage.setVertexPosition(2, Math.cos(_angle) * _voidR, Math.sin(_angle) * _voidR);
            quadImage.setVertexPosition(3, Math.cos(_angle + _angleStep) * _voidR, Math.sin(_angle + _angleStep) * _voidR);
            quadImage.vertexChanged();
            selector.addImage(quadImage);
            _angle += _angleStep;
         }
      }
      // #endregion
   }
}
