// 已完工

package Game
{
   import Game.Entity.Node;
   import Game.Entity.SelectFade;
   import Menus.MenuButton;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import starling.core.Starling;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.text.TextField;

   public class GameUI
   {
      // #region 类变量
      public var quad:Quad;
      public var dragQuad:Quad;
      public var dragLine:Quad;
      public var quadImage:Image;
      public var quadImage2:Image;
      public var barrierImage:Image;
      public var game:GameScene;
      public var touchQuad:Quad;
      public var touches:Vector.<Touch>;
      public var movePerc:Number;
      public var fleetSlider:FleetSlider;
      public var sliderMedium:FleetSlider;
      public var sliderLarge:FleetSlider;
      public var popLabel:TextField;
      public var popLabel2:TextField;
      public var popLabel3:TextField;
      public var closeBtn:MenuButton;
      public var pauseBtn:MenuButton;
      public var restartBtn:MenuButton;
      public var speedBtns:Array;
      public var speedMult:Number;
      public var selectedNodes:Array;
      public var down_x:Number;
      public var down_y:Number;
      public var drag_x:Number;
      public var drag_y:Number;
      public var mouseDown:Boolean;
      public var dragging:Boolean;
      public var rightDown:Boolean;

      public var debug_mouse_x:Number;
      public var debug_mouse_y:Number;
      public var debug_touch_Node:Node;
      // #endregion
      public function GameUI() // 构造函数，初始化对象
      {
         super();
         quad = new Quad(10, 10, 16777215);
         touchQuad = new Quad(1024, 768, 16711680);
         touchQuad.alpha = 0;
         dragQuad = new Quad(10, 10, Globals.teamColors[1]);
         dragLine = new Quad(2, 2, Globals.teamColors[1]);
         quadImage = new Image(Root.assets.getTexture("quad"));
         quadImage.adjustVertices();
         quadImage2 = new Image(Root.assets.getTexture("quad8x4"));
         quadImage2.adjustVertices();
         var _Color:Number = 16755370;
         popLabel = new TextField(600, 40, "POPULATION : 50 / 50", "Downlink12", -1, _Color);
         popLabel.vAlign = popLabel.hAlign = "center";
         popLabel.pivotX = 300;
         popLabel.pivotY = 20;
         popLabel.alpha = 0.5;
         popLabel.x = 512;
         popLabel.y = 136;
         popLabel2 = new TextField(600, 40, "POPULATION : 50 / 50", "Downlink12", -1, _Color);
         popLabel2.vAlign = popLabel2.hAlign = "center";
         popLabel2.pivotX = 300;
         popLabel2.pivotY = 20;
         popLabel2.alpha = 0.5;
         popLabel2.x = popLabel.x;
         popLabel2.y = popLabel.y;
         popLabel2.alpha = 0;
         popLabel3 = new TextField(200, 40, "+ 30", "Downlink12", -1, _Color);
         popLabel3.vAlign = "center";
         popLabel3.hAlign = "left";
         popLabel3.pivotX = 0;
         popLabel3.pivotY = 20;
         popLabel3.alpha = 0.5;
         popLabel3.x = popLabel.x;
         popLabel3.y = popLabel.y;
         popLabel3.alpha = 0;
         sliderMedium = new FleetSlider(1);
         sliderMedium.x = 256;
         sliderMedium.y = 640 - sliderMedium.height * 0.5;
         sliderLarge = new FleetSlider(2);
         sliderLarge.x = 192;
         sliderLarge.y = 640 - sliderLarge.height * 0.5;
         closeBtn = new MenuButton("btn_close");
         closeBtn.x = 15 + Globals.margin;
         closeBtn.y = 124;
         pauseBtn = new MenuButton("btn_pause");
         pauseBtn.x = closeBtn.x + closeBtn.width * 1.1;
         pauseBtn.y = 124;
         restartBtn = new MenuButton("btn_restart");
         restartBtn.x = pauseBtn.x + pauseBtn.width * 1.1;
         restartBtn.y = 123;
         speedBtns = [];
         speedMult = 1;
         var _SpeedButton:SpeedButton = null;
         for (var i:int = 0; i < 3; i++) // 遍历三个速度按钮
         {
            _SpeedButton = new SpeedButton(this,"btn_play" + (i + 1).toString(), speedBtns); // 输入的speedBtns为此按钮之前的速度按钮
            _SpeedButton.x = 870 + i * (pauseBtn.width - 2); // 计算x坐标
            _SpeedButton.y = 124; // 设定y坐标
            if (i == 2)
               _SpeedButton.x -= 4;
            speedBtns.push(_SpeedButton);
         }
         selectedNodes = [];
      }
      // #region 启动游戏界面UI，处理相关控件
      public function init(_GameScene:GameScene):void // 进入关卡后
      {
         this.game = _GameScene;
         switch (Globals.textSize)
         {
            case 0:
               popLabel.fontName = "Downlink12";
               popLabel2.fontName = "Downlink12";
               popLabel3.fontName = "Downlink12";
               fleetSlider = sliderMedium;
               sliderMedium.visible = true;
               sliderLarge.visible = false;
               closeBtn.setImage("btn_close");
               pauseBtn.setImage("btn_pause");
               restartBtn.setImage("btn_restart");
               break;
            case 1:
               popLabel.fontName = "Downlink12";
               popLabel2.fontName = "Downlink12";
               popLabel3.fontName = "Downlink12";
               fleetSlider = sliderMedium;
               sliderMedium.visible = true;
               sliderLarge.visible = false;
               closeBtn.setImage("btn_close");
               pauseBtn.setImage("btn_pause");
               restartBtn.setImage("btn_restart");
               break;
            case 2:
               popLabel.fontName = "Downlink18";
               popLabel2.fontName = "Downlink18";
               popLabel3.fontName = "Downlink18";
               fleetSlider = sliderLarge;
               sliderMedium.visible = false;
               sliderLarge.visible = true;
               closeBtn.setImage("btn_close2x", 0.75);
               pauseBtn.setImage("btn_pause2x", 0.75);
               restartBtn.setImage("btn_restart2x", 0.75);
         }
         popLabel.fontSize = -1;
         popLabel2.fontSize = -1;
         popLabel3.fontSize = -1;
         closeBtn.x = 15 + Globals.margin;
         pauseBtn.x = closeBtn.x + closeBtn.width * 1.1;
         restartBtn.x = pauseBtn.x + pauseBtn.width * 1.1;
         movePerc = 1;
         movePercentBar(movePerc);
         quad.scaleY = 1;
         quad.scaleX = 1;
         fleetSlider.init();
         closeBtn.init();
         closeBtn.addEventListener("clicked", on_closeBtn);
         pauseBtn.init();
         pauseBtn.addEventListener("clicked", on_pauseBtn);
         restartBtn.init();
         restartBtn.addEventListener("clicked", on_restartBtn);
         _GameScene.uiLayer.addChild(popLabel);
         _GameScene.uiLayer.addChild(popLabel2);
         _GameScene.uiLayer.addChild(popLabel3);
         _GameScene.uiLayer.addChild(touchQuad);
         _GameScene.uiLayer.addChild(fleetSlider);
         _GameScene.uiLayer.addChild(restartBtn);
         _GameScene.uiLayer.addChild(closeBtn);
         _GameScene.uiLayer.addChild(pauseBtn);
         var _SpeedButton:SpeedButton = null;
         speedMult = 1;
         for (var i:int = 0; i < speedBtns.length; i++)
         {
            _SpeedButton = speedBtns[i];
            if (i == 1)
               _SpeedButton.setImage("btn_speed1x", 0.75 + 0.6 * Globals.textSize);
            else
               _SpeedButton.setImage("btn_play" + (i + 1).toString(), 0.6 + 0.4 * Globals.textSize);
            _GameScene.uiLayer.addChild(_SpeedButton);
            _SpeedButton.init();
            if (i == 1)
            {
               _SpeedButton.toggled = true;
               _SpeedButton.image.alpha = 0.6;
            }
         }
         speedBtns[2].x = 1024 - speedBtns[2].width + 5 - Globals.margin;
         speedBtns[1].x = speedBtns[2].x - speedBtns[1].width * 0.8 - 9;
         speedBtns[0].x = speedBtns[1].x - speedBtns[0].width * 1.25;
         mouseDown = false;
         if (Globals.touchControls)
            touchQuad.addEventListener("touch", on_touch); // 按操作方式添加事件监听器
         else
         {
            Starling.current.nativeStage.addEventListener("mouseDown", on_mouseDown);
            Starling.current.nativeStage.addEventListener("mouseMove", on_mouseMove);
            Starling.current.nativeStage.addEventListener("mouseUp", on_mouseUp);
            Starling.current.nativeStage.addEventListener("rightMouseDown", on_rightDown);
            Starling.current.nativeStage.addEventListener("rightMouseUp", on_rightUp);
         }
         Starling.current.nativeStage.addEventListener("mouseWheel", on_wheel);
      }

      public function deInit():void // 移除相关控件
      {
         if (touches)
            touches.length = 0;
         fleetSlider.deInit();
         closeBtn.deInit();
         closeBtn.removeEventListener("clicked", on_closeBtn);
         pauseBtn.deInit();
         pauseBtn.removeEventListener("clicked", on_pauseBtn);
         restartBtn.deInit();
         restartBtn.removeEventListener("clicked", on_restartBtn);
         for each (var _SpeedButton:SpeedButton in speedBtns)
         {
            _SpeedButton.deInit();
         }
         if (Globals.touchControls)
            touchQuad.removeEventListener("touch", on_touch);
         else
         {
            Starling.current.nativeStage.removeEventListener("mouseDown", on_mouseDown);
            Starling.current.nativeStage.removeEventListener("mouseMove", on_mouseMove);
            Starling.current.nativeStage.removeEventListener("mouseUp", on_mouseUp);
            Starling.current.nativeStage.removeEventListener("rightMouseDown", on_rightDown);
            Starling.current.nativeStage.removeEventListener("rightMouseUp", on_rightUp);
         }
         Starling.current.nativeStage.removeEventListener("mouseWheel", on_wheel);
      }

      public function on_closeBtn():void
      {
         game.quit();
      }

      public function on_pauseBtn():void
      {
         game.pause();
      }

      public function on_restartBtn():void
      {
         game.restart();
      }

      public function on_wheel(_Mouse:MouseEvent):void // 鼠标滚轮（控制分兵条）
      {
         if (game.alpha == 0)
            return;
         if (_Mouse.delta < 0)
            movePerc -= 0.1;
         else
            movePerc += 0.1;
         if (movePerc < 0)
            movePerc = 0;
         if (movePerc > 1)
            movePerc = 1;
         movePercentBar(movePerc);
      }
      // #endregion
      // #region 常规操作
      public function on_touch(_TouchEvent:TouchEvent):void // 常规操作下的点击
      {
         if (game.alpha < 0.5)
            return;
         touchHover(_TouchEvent);
         touchBegan(_TouchEvent);
         touchMoved(_TouchEvent);
         touchEnded(_TouchEvent);
         touches = _TouchEvent.getTouches(touchQuad);
      }

      public function touchHover(_TouchEvent:TouchEvent):void // 专用于选中渐变圈
      {
         var _TouchArray:Vector.<Touch> = _TouchEvent.getTouches(touchQuad, "hover");
         if (!_TouchArray)
            return;
         for each (var _Touch:Touch in _TouchArray)
         {
            _Touch.hoverNode = getClosestNode(_Touch.globalX, _Touch.globalY);
            debug_mouse_x = _Touch.globalX;
            debug_mouse_y = _Touch.globalY;
            debug_touch_Node = _Touch.hoverNode;
         }
      }

      public function touchBegan(_TouchEvent:TouchEvent):void // 获取鼠标按下时选中的初始天体
      {
         var _TouchArray:Vector.<Touch> = _TouchEvent.getTouches(touchQuad, "began");
         if (!_TouchArray)
            return;
         for each (var _Touch:Touch in _TouchArray)
         {
            if (!_Touch.downNodes)
               _Touch.downNodes = [];
            _Touch.downNodes.length = 0;
            var _Node:Node = getClosestNode(_Touch.globalX, _Touch.globalY);
            if (_Node && _Touch.downNodes.indexOf(_Node) == -1)
               _Touch.downNodes.push(_Node);
         }
      }

      public function touchMoved(_TouchEvent:TouchEvent):void // 获取鼠标移动中选中的初始天体
      {
         var _TouchArray:Vector.<Touch> = _TouchEvent.getTouches(touchQuad, "moved");
         if (!_TouchArray)
            return;
         for each (var _Touch:Touch in _TouchArray)
         {
            if (!_Touch.downNodes)
               _Touch.downNodes = [];
            var _Node:Node = getClosestNode(_Touch.globalX, _Touch.globalY);
            if (_Node && _Touch.downNodes.indexOf(_Node) == -1 && _Touch.downNodes.length == 0)
               _Touch.downNodes.push(_Node);
            _Touch.hoverNode = null;
            if (_Node)
               _Touch.hoverNode = _Node;
         }
      }

      public function touchEnded(_TouchEvent:TouchEvent):void // 获取鼠标释放时选中的目标天体，并发送飞船
      {
         var _Node1:Node = null;
         var _Node2:Node = null;
         var _TouchArray:Vector.<Touch> = _TouchEvent.getTouches(touchQuad, "ended");
         if (!_TouchArray)
            return;
         for each (var _Touch:Touch in _TouchArray)
         {
            if (_Touch.hoverNode && _Touch.downNodes.length > 0)
            {
               _Node1 = _Touch.hoverNode;
               game.addFade(_Node1.x, _Node1.y, _Node1.size, 16777215, 1);
               for each (_Node2 in _Touch.downNodes)
               {
                  if (_Node2 == _Node1 || nodesBlocked(_Node2, _Node1))
                     continue;
                  _Node2.sendShips(1, _Node1);
                  game.addFade(_Node2.x, _Node2.y, _Node2.size, 16777215, 0);
               }
            }
            _Touch.hoverNode = null;
            if (_Touch.downNodes)
               _Touch.downNodes.length = 0;
         }
      }
      // #endregion
      // #region 传统操作
      public function on_mouseDown(_Mouse:MouseEvent):void // 鼠标左键按下
      {
         if (game.alpha < 0.5)
            return;
         down_x = (_Mouse.stageX - Starling.current.viewPort.x) / Starling.contentScaleFactor;
         down_y = (_Mouse.stageY - Starling.current.viewPort.y) / Starling.contentScaleFactor;
         mouseDown = true;
         dragging = false;
      }

      public function on_mouseMove(_Mouse:MouseEvent):void // 鼠标左键拖动（框选天体）
      {
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         if (game.alpha < 0.5)
            return;
         if (!mouseDown)
            return;
         drag_x = (_Mouse.stageX - Starling.current.viewPort.x) / Starling.contentScaleFactor;
         drag_y = (_Mouse.stageY - Starling.current.viewPort.y) / Starling.contentScaleFactor;
         if (dragging)
            return;
         _dx = drag_x - down_x;
         _dy = drag_y - down_y;
         if (Math.sqrt(_dx * _dx + _dy * _dy) > 5)
         {
            dragging = true;
            if (!_Mouse.shiftKey)
               selectedNodes.length = 0;
         }
      }

      public function on_mouseUp(_Mouse:MouseEvent):void // 鼠标左键抬起（选中天体）
      {
         var _x:Number = NaN;
         var _y:Number = NaN;
         var _Node:Node = null;
         mouseDown = false;
         if (game.alpha < 0.5)
            return;
         if (dragging)
            return;
         _x = (_Mouse.stageX - Starling.current.viewPort.x) / Starling.contentScaleFactor;
         _y = (_Mouse.stageY - Starling.current.viewPort.y) / Starling.contentScaleFactor;
         _Node = getClosestNode(_x, _y);
         if (_Mouse.shiftKey)
         {
            if (_Node && selectedNodes.indexOf(_Node) == -1)
               selectedNodes.push(_Node);
            else if (_Node && selectedNodes.indexOf(_Node) != -1)
               selectedNodes.splice(selectedNodes.indexOf(_Node), 1);
         }
         else
         {
            selectedNodes.length = 0;
            if (_Node)
               selectedNodes.push(_Node);
         }
      }

      public function on_rightDown(_Mouse:MouseEvent):void // 鼠标右键按下
      {
         if (game.alpha < 0.5)
            return;
         rightDown = true;
      }

      public function on_rightUp(_Mouse:MouseEvent):void // 鼠标右键抬起（发送飞船）
      {
         rightDown = false;
         if (game.alpha < 0.5)
            return;
         var _x:Number = (_Mouse.stageX - Starling.current.viewPort.x) / Starling.contentScaleFactor;
         var _y:Number = (_Mouse.stageY - Starling.current.viewPort.y) / Starling.contentScaleFactor;
         var _currentNode:Node = getClosestNode(_x, _y);
         if (!_currentNode)
            return;
         game.addFade(_currentNode.x, _currentNode.y, _currentNode.size, 16777215, 1);
         for each (var _Node:Node in selectedNodes)
         {
            if (_Node == _currentNode || nodesBlocked(_Node, _currentNode))
               continue;
            _Node.sendShips(1, _currentNode);
            game.addFade(_Node.x, _Node.y, _Node.size, 16777215, 0);
         }
      }
      // #endregion
      // #region 更新
      public function update(_dt:Number):void
      {
         movePerc = fleetSlider.total;
         movePercentBar(movePerc);
         popLabel.text = "POPULATION : " + Globals.teamPops[1] + " / " + Globals.teamCaps[1];
         popLabel2.text = popLabel.text;
         if (popLabel2.alpha > 0)
            popLabel2.alpha = Math.max(0, popLabel2.alpha - _dt * 0.5);
         if (popLabel3.alpha > 0)
         {
            popLabel3.x = 512 + popLabel.textBounds.width * 0.5 + 10;
            popLabel3.alpha = Math.max(0, popLabel3.alpha - _dt * 0.5);
         }
         if (Globals.touchControls)
            drawTouches();
         else
            drawMouse();
         var _R:Number = NaN;
         var _voidR:Number = NaN;
         for each (var _Fade:SelectFade in game.fades.active)
         {
            _R = 150 * _Fade.size - 4;
            _voidR = Math.max(0, _R - 3);
            drawCircle(_Fade.x, _Fade.y, _Fade.color, _R, _voidR, false, _Fade.alpha);
         }
      }

      public function movePercentBar(_Total:Number):void
      {
         fleetSlider.total = _Total;
         fleetSlider.update();
      }
      // #endregion
      // #region 计算工具
      public function getClosestNode(_x:Number, _y:Number):Node
      {
         var _ClosestNode:Node = null;
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         var _Distance:Number = NaN;
         var _lineDist:Number = NaN;
         var _ClosestDist:Number = 200;
         for each (var _Node:Node in game.nodes.active)
         {
            if (_Node.type == 3)
               continue;
            _dx = _Node.x - _x;
            _dy = _Node.y - _y;
            _Distance = Math.sqrt(_dx * _dx + _dy * _dy);
            _lineDist = _Node.lineDist;
            if (_Distance < _lineDist && _Distance < _ClosestDist)
            {
               _ClosestDist = _Distance;
               _ClosestNode = _Node;
            }
         }
         return _ClosestNode;
      }

      public function lineBlocked(_x1:Number, _y1:Number, _x2:Number, _y2:Number):Point
      {
         var _Intersection:Point = null;
         var _bar1:Point = null;
         var _bar2:Point = null;
         for each (var _bar:Array in game.barrierLines)
         {
            _bar1 = _bar[0];
            _bar2 = _bar[1];
            _Intersection = getIntersection(_x1, _y1, _x2, _y2, _bar1.x, _bar1.y, _bar2.x, _bar2.y);
            if (_Intersection)
               return _Intersection;
         }
         return null;
      }

      public function nodesBlocked(_Node1:Node, _Node2:Node):Point // 判断路径是否被拦截并计算拦截点
      {
         var _bar1:Point = null;
         var _bar2:Point = null;
         var _Intersection:Point = null;
         if (_Node1.team == 1 && _Node1.type == 1)
            return null;
         for each (var _bar:Array in game.barrierLines)
         {
            _bar1 = _bar[0];
            _bar2 = _bar[1];
            _Intersection = getIntersection(_Node1.x, _Node1.y, _Node2.x, _Node2.y, _bar1.x, _bar1.y, _bar2.x, _bar2.y); // 计算交点
            if (_Intersection)
               return _Intersection;
         }
         return null;
      }
      // 计算交点
      public function getIntersection(_p1x:Number, _p1y:Number, _p2x:Number, _p2y:Number, _p3x:Number, _p3y:Number, _p4x:Number, _p4y:Number):Point
      {
         var _L1dx:Number = _p2x - _p1x;
         var _L1dy:Number = _p2y - _p1y;
         var _L2dx:Number = _p4x - _p3x;
         var _L2dy:Number = _p4y - _p3y;
         var _Ratio1:Number = (-_L1dy * (_p1x - _p3x) + _L1dx * (_p1y - _p3y)) / (-_L2dx * _L1dy + _L1dx * _L2dy);
         var _Ratio2:Number = (_L2dx * (_p1y - _p3y) - _L2dy * (_p1x - _p3x)) / (-_L2dx * _L1dy + _L1dx * _L2dy);
         if (_Ratio1 >= 0 && _Ratio1 <= 1 && _Ratio2 >= 0 && _Ratio2 <= 1)
            return new Point(_p1x + _Ratio2 * _L1dx, _p1y + _Ratio2 * _L1dy);
         return null;
      }
      // #endregion
      // #region 绘图工具
      public function drawTouches():void // 绘制常规操作下的定位圈和鼠标线
      {
         const _Color:uint = 16777215; // #FFFFFF
         var _Tx:Number = NaN; // T 表示 touch 触摸点
         var _Ty:Number = NaN;
         var _Block:Point = null;
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         var _Distance:Number = NaN;
         var _Angle:Number = NaN;
         var _Nx:Number = NaN; // N 表示 node 天体
         var _Ny:Number = NaN;
         if (!touches)
            return;
         for each (var _Touch:Touch in touches)
         {
            if (_Touch.hoverNode)
            {
               drawCircle(_Touch.hoverNode.x, _Touch.hoverNode.y, Globals.teamColors[_Touch.hoverNode.team], _Touch.hoverNode.lineDist - 4, _Touch.hoverNode.size * 25 * 2, true, 0.5);
               if (_Touch.hoverNode.attackRate > 0)
                  drawDashedCircle(_Touch.hoverNode.x, _Touch.hoverNode.y, Globals.teamColors[_Touch.hoverNode.team], _Touch.hoverNode.attackRange, _Touch.hoverNode.attackRange - 2, false, 0.5, 1, 0, 256);
            }
            if (_Touch.downNodes && _Touch.downNodes.length > 0) // 若已选中天体
            {
               for each (var _Node:Node in _Touch.downNodes)
               {
                  drawCircle(_Node.x, _Node.y, _Color, _Node.lineDist - 4, _Node.lineDist - 7, false, 0.8);
                  _Tx = _Touch.globalX;
                  _Ty = _Touch.globalY;
                  if (_Touch.hoverNode) // 绘制目标天体的定位圈
                  {
                     _Block = nodesBlocked(_Node, _Touch.hoverNode);
                     _Tx = _Touch.hoverNode.x;
                     _Ty = _Touch.hoverNode.y;
                     if (_Block)
                        drawCircle(_Tx, _Ty, 16724787, _Touch.hoverNode.lineDist - 4, _Touch.hoverNode.lineDist - 7, false, 0.8);
                     else
                        drawCircle(_Tx, _Ty, _Color, _Touch.hoverNode.lineDist - 4, _Touch.hoverNode.lineDist - 7, false, 0.8);
                  }
                  else
                     _Block = lineBlocked(_Node.x, _Node.y, _Tx, _Ty);
                  _dx = _Tx - _Node.x;
                  _dy = _Ty - _Node.y;
                  _Distance = Math.sqrt(_dx * _dx + _dy * _dy);
                  if (_Distance > _Node.lineDist - 5) // 鼠标移出天体定位圈时绘制
                  {
                     _Angle = Math.atan2(_dy, _dx);
                     _Nx = _Node.x + Math.cos(_Angle) * (_Node.lineDist - 5);
                     _Ny = _Node.y + Math.sin(_Angle) * (_Node.lineDist - 5);
                     if (_Touch.hoverNode)
                     {
                        _Tx -= Math.cos(_Angle) * (_Touch.hoverNode.lineDist - 5);
                        _Ty -= Math.sin(_Angle) * (_Touch.hoverNode.lineDist - 5);
                     }
                     if (_Block) // 分段绘制鼠标线
                     {
                        drawLine(_Nx, _Ny, _Block.x, _Block.y, _Color, 3, 0.8);
                        drawLine(_Block.x, _Block.y, _Tx, _Ty, 16724787, 3, 0.8);
                     }
                     else
                        drawLine(_Nx, _Ny, _Tx, _Ty, _Color, 3, 0.8);
                  }
               }
            }
         }
      }

      public function drawMouse():void // 绘制传统操作下的选中框定位圈连接线
      {
         var _quadtypeX:Number = NaN;
         var _quadtypeY:Number = NaN;
         var i:int = 0;
         var _Node1:Node = null;
         var _mouseX:Number = NaN;
         var _mouseY:Number = NaN;
         var _Node2:Node = null;
         var _Block:Point = null;
         var _x:Number = NaN;
         var _y:Number = NaN;
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         var _angle:Number = NaN;
         var _lx:Number = NaN;
         var _ly:Number = NaN;
         game.mouseBatch.reset();
         if (mouseDown && dragging)
         {
            dragQuad.x = down_x;
            dragQuad.y = down_y;
            dragQuad.width = drag_x - down_x;
            dragQuad.height = drag_y - down_y;
            dragQuad.alpha = 0.2;
            game.mouseBatch.addQuad(dragQuad);
            _quadtypeX = drag_x - down_x > 0 ? 1 : -1;
            _quadtypeY = drag_y - down_y > 0 ? 1 : -1;
            dragLine.alpha = 0.5;
            dragLine.width = (dragQuad.width + 2) * _quadtypeX;
            dragLine.height = _quadtypeY;
            dragLine.x = down_x - _quadtypeX;
            dragLine.y = down_y - _quadtypeY;
            game.mouseBatch.addQuad(dragLine);
            dragLine.x = down_x - _quadtypeX;
            dragLine.y = down_y + dragQuad.height * _quadtypeY;
            game.mouseBatch.addQuad(dragLine);
            dragLine.width = _quadtypeX;
            dragLine.height = dragQuad.height * _quadtypeY;
            dragLine.x = down_x - _quadtypeX;
            dragLine.y = down_y;
            game.mouseBatch.addQuad(dragLine);
            dragLine.x = down_x + dragQuad.width * _quadtypeX;
            dragLine.y = down_y;
            game.mouseBatch.addQuad(dragLine);
            game.mouseBatch.blendMode = "add";
            for each (_Node1 in game.nodes.active)
            {
               if (_Node1.ships[1].length == 0 && _Node1.team != 1)
                  continue;
               if (selectedNodes.indexOf(_Node1) != -1)
                  continue;
               if (_quadtypeX > 0 && _quadtypeY > 0)
               {
                  if (_Node1.x > down_x && _Node1.x < drag_x && _Node1.y > down_y && _Node1.y < drag_y)
                     selectedNodes.push(_Node1);
               }
               else if (_quadtypeX > 0 && _quadtypeY < 0)
               {
                  if (_Node1.x > down_x && _Node1.x < drag_x && _Node1.y > drag_y && _Node1.y < down_y)
                     selectedNodes.push(_Node1);
               }
               else if (_quadtypeX < 0 && _quadtypeY > 0)
               {
                  if (_Node1.x > drag_x && _Node1.x < down_x && _Node1.y > down_y && _Node1.y < drag_y)
                     selectedNodes.push(_Node1);
               }
               else if (_quadtypeX < 0 && _quadtypeY < 0)
               {
                  if (_Node1.x > drag_x && _Node1.x < down_x && _Node1.y > drag_y && _Node1.y < down_y)
                     selectedNodes.push(_Node1);
               }
            }
         }
         else
         {
            _mouseX = (Starling.current.nativeStage.mouseX - Starling.current.viewPort.x) / Starling.contentScaleFactor;
            _mouseY = (Starling.current.nativeStage.mouseY - Starling.current.viewPort.y) / Starling.contentScaleFactor;
            _Node2 = getClosestNode(_mouseX, _mouseY);
            if (_Node2)
            {
               drawCircle(_Node2.x, _Node2.y, Globals.teamColors[_Node2.team], _Node2.lineDist - 4, _Node2.size * 25 * 2, true, 0.5);
               if (_Node2.attackRate > 0 && _Node2.attackRange > 0)
                  drawDashedCircle(_Node2.x, _Node2.y, Globals.teamColors[_Node2.team], _Node2.attackRange, _Node2.attackRange - 2, false, 0.5, 1, 0, 256);
               if (rightDown && selectedNodes.length > 0)
               {
                  for each (_Node1 in selectedNodes)
                  {
                     _Block = nodesBlocked(_Node1, _Node2);
                     _x = _Node2.x;
                     _y = _Node2.y;
                     _dx = _x - _Node1.x;
                     _dy = _y - _Node1.y;
                     if (Math.sqrt(_dx * _dx + _dy * _dy) > _Node1.lineDist - 5)
                     {
                        _angle = Math.atan2(_dy, _dx);
                        _lx = _Node1.x + Math.cos(_angle) * (_Node1.lineDist - 5);
                        _ly = _Node1.y + Math.sin(_angle) * (_Node1.lineDist - 5);
                        _x -= Math.cos(_angle) * (_Node2.lineDist - 5);
                        _y -= Math.sin(_angle) * (_Node2.lineDist - 5);
                        if (_Block)
                        {
                           drawLine(_lx, _ly, _Block.x, _Block.y, 16777215, 3, 0.8);
                           drawLine(_Block.x, _Block.y, _x, _y, 16724787, 3, 0.8);
                        }
                        else
                           drawLine(_lx, _ly, _x, _y, 16777215, 3, 0.8);
                     }
                  }
                  if (_Block)
                     drawCircle(_Node2.x, _Node2.y, 16724787, _Node2.lineDist - 4, _Node2.lineDist - 7, false, 0.8);
                  else
                     drawCircle(_Node2.x, _Node2.y, 16777215, _Node2.lineDist - 4, _Node2.lineDist - 7, false, 0.8);
               }
            }
         }
         for each (_Node1 in selectedNodes)
         {
            drawCircle(_Node1.x, _Node1.y, 16777215, _Node1.lineDist - 4, _Node1.lineDist - 7, false, 0.8);
         }
      }

      public function drawLine(_x1:Number, _y1:Number, _x2:Number, _y2:Number, _Color:uint, _Width:Number = 2, _alpha:Number = 1):void
      {
         var _quadImage:Image = quadImage;
         if (_Width <= 3)
            _quadImage = quadImage2;
         _quadImage.color = _Color;
         _quadImage.setVertexAlpha(2, 1);
         _quadImage.setVertexAlpha(3, 1);
         _quadImage.alpha = _alpha;
         _quadImage.rotation = 0;
         var _dx:Number = _x2 - _x1;
         var _dy:Number = _y2 - _y1;
         var _angle:Number = Math.atan2(_dy, _dx);
         var _Distance:Number = Math.sqrt(_dx * _dx + _dy * _dy);
         _quadImage.x = _x1;
         _quadImage.y = _y1;
         _quadImage.setVertexPosition(0, 0, 0);
         _quadImage.setVertexPosition(1, _Distance, 0);
         _quadImage.setVertexPosition(2, 0, _Width);
         _quadImage.setVertexPosition(3, _Distance, _Width);
         _quadImage.rotation = _angle;
         game.uiBatch.addImage(_quadImage);
      }

      public function drawDashedLine(_x1:Number, _y1:Number, _x2:Number, _y2:Number, _Color:uint, _Width:Number = 2, _alpha:Number = 1, _StartStep:Number = 0):void
      {
         var _Step:int = 0;
         var _dx:Number = _x2 - _x1;
         var _dy:Number = _y2 - _y1;
         var _angle:Number = Math.atan2(_dy, _dx);
         var _Distance:Number = Math.sqrt(_dx * _dx + _dy * _dy);
         var _Start:Number = 12 + 12 * _StartStep;
         var _Ax:Number = _x1 + Math.cos(_angle) * _Start;
         var _Ay:Number = _y1 + Math.sin(_angle) * _Start;
         _Step = _Start;
         while (_Step < _Distance - 12)
         {
            _dx = _Ax + Math.cos(_angle) * 12 * 0.5;
            _dy = _Ay + Math.sin(_angle) * 12 * 0.5;
            drawLine(_Ax, _Ay, _dx, _dy, _Color, _Width, _alpha);
            _Step += 12;
         }
      }

      public function drawCircle(_x:Number, _y:Number, _Color:uint, _R:Number, _voidR:Number = 0, _mTinted:Boolean = false, _alpha:Number = 1, _quality2:Number = 1, _angle:Number = 0, _quality1:int = 64):void
      {
         var _quadImage:Image = quadImage;
         if (_R - _voidR <= 3)
            _quadImage = quadImage2;
         _quadImage.color = _Color;
         if (_mTinted)
         {
            _quadImage.setVertexAlpha(2, 0);
            _quadImage.setVertexAlpha(3, 0);
         }
         else
         {
            _quadImage.setVertexAlpha(2, 1);
            _quadImage.setVertexAlpha(3, 1);
         }
         _quadImage.alpha = _alpha;
         _quadImage.rotation = 0;
         var _angleStep:Number = 6.283185307179586 / _quality1;
         var _lineNumber:int = Math.ceil(_quality1 * _quality2);
         for (var i:int = 0; i < _lineNumber; i++)
         {
            _quadImage.x = _x;
            _quadImage.y = _y;
            if (i == _lineNumber - 1)
               _angleStep = 6.283185307179586 * _quality2 - _angleStep * (_lineNumber - 1);
            _quadImage.setVertexPosition(0, Math.cos(_angle) * _R, Math.sin(_angle) * _R);
            _quadImage.setVertexPosition(1, Math.cos(_angle + _angleStep) * _R, Math.sin(_angle + _angleStep) * _R);
            _quadImage.setVertexPosition(2, Math.cos(_angle) * _voidR, Math.sin(_angle) * _voidR);
            _quadImage.setVertexPosition(3, Math.cos(_angle + _angleStep) * _voidR, Math.sin(_angle + _angleStep) * _voidR);
            _quadImage.vertexChanged();
            game.uiBatch.addImage(_quadImage);
            _angle += _angleStep;
         }
      }

      public function drawDashedCircle(_x:Number, _y:Number, _Color:uint, _R:Number, _voidR:Number = 0, _mTinted:Boolean = false, _alpha:Number = 1, _quality2:Number = 1, _angle:Number = 0, _quality1:int = 64):void
      {
         var _quadImage:Image = quadImage;
         if (_R - _voidR <= 3)
            _quadImage = quadImage2;
         _quadImage.color = _Color;
         if (_mTinted)
         {
            _quadImage.setVertexAlpha(2, 0);
            _quadImage.setVertexAlpha(3, 0);
         }
         else
         {
            _quadImage.setVertexAlpha(2, 1);
            _quadImage.setVertexAlpha(3, 1);
         }
         _quadImage.alpha = _alpha;
         _quadImage.rotation = 0;
         var _angleStep:Number = 6.283185307179586 / _quality1;
         var _lineNumber:int = Math.ceil(_quality1 * _quality2) * 0.505;
         for (var i:int = 0; i < _lineNumber; i++)
         {
            _quadImage.x = _x;
            _quadImage.y = _y;
            if (i == _lineNumber - 1)
               _angleStep = 6.283185307179586 * _quality2 - _angleStep * (_lineNumber - 1);
            _quadImage.setVertexPosition(0, Math.cos(_angle) * _R, Math.sin(_angle) * _R);
            _quadImage.setVertexPosition(1, Math.cos(_angle + _angleStep) * _R, Math.sin(_angle + _angleStep) * _R);
            _quadImage.setVertexPosition(2, Math.cos(_angle) * _voidR, Math.sin(_angle) * _voidR);
            _quadImage.setVertexPosition(3, Math.cos(_angle + _angleStep) * _voidR, Math.sin(_angle + _angleStep) * _voidR);
            _quadImage.vertexChanged();
            game.uiBatch.addImage(_quadImage);
            _angle += _angleStep * 2;
         }
      }
      // #endregion
   }
}
