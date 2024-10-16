/*EntityPool：nodes,ais,ships,warps,beams,pules,flashs,barriers,explosions,darkpulses,fades
实体池会记录场上的所有实体到对应的active列表中
*/
package Game
{
   import Game.Entity.BarrierFX;
   import Game.Entity.BeamFX;
   import Game.Entity.DarkPulse;
   import Game.Entity.EnemyAI;
   import Game.Entity.EntityPool;
   import Game.Entity.ExplodeFX;
   import Game.Entity.FlashFX;
   import Game.Entity.Node;
   import Game.Entity.NodePulse;
   import Game.Entity.SelectFade;
   import Game.Entity.Ship;
   import Game.Entity.WarpFX;
   import flash.geom.Point;
   import starling.animation.Juggler;
   import starling.core.Starling;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.QuadBatch;
   import starling.display.Sprite;
   import starling.events.EnterFrameEvent;

   public class GameScene extends Sprite
   {
      // #region 类变量
      // 显示层
      public var gameLayer:Sprite;
      public var gameContainer:Sprite;
      public var shipsLayer1:Sprite;
      public var nodeLayer:Sprite;
      public var nodeGlowLayer:Sprite;
      public var nodeGlowLayer2:Sprite;
      public var shipsLayer2:Sprite;
      public var fxLayer:Sprite;
      public var shapeLayer:Sprite;
      public var labelLayer:Sprite;
      public var uiLayer:Sprite;
      // 
      public var shipsBatch1:QuadBatch;
      public var shipsBatch1b:QuadBatch;
      public var shipsBatch2:QuadBatch;
      public var shipsBatch2b:QuadBatch;
      public var uiBatch:QuadBatch;
      public var mouseBatch:QuadBatch;
      // 实体池
      public var entities:Array;
      public var ais:EntityPool;
      public var nodes:EntityPool;
      public var ships:EntityPool;
      public var warps:EntityPool;
      public var beams:EntityPool;
      public var pulses:EntityPool;
      public var flashes:EntityPool;
      public var barriers:EntityPool;
      public var explosions:EntityPool;
      public var darkPulses:EntityPool;
      public var fades:EntityPool;
      // 其他
      public var cover:Quad; // 通关时的遮罩
      public var ui:GameUI;
      public var barrierLines:Array;
      public var tutorial:TutorialSprite;
      public var level:int;
      public var gameOver:Boolean;
      public var gameOverTimer:Number;
      public var winningTeam:int;
      public var triggers:Array;
      public var juggler:Juggler;
      public var darkPulse:Image;
      public var bossTimer:Number;
      public var slowMult:Number;
      // #endregion
      public function GameScene() // 构造函数，用于初始化
      {
         super();
         // 造一堆实例对象
         gameLayer = new Sprite();
         gameContainer = new Sprite();
         shipsLayer1 = new Sprite();
         nodeLayer = new Sprite();
         nodeGlowLayer = new Sprite();
         nodeGlowLayer2 = new Sprite();
         shipsLayer2 = new Sprite();
         fxLayer = new Sprite();
         shapeLayer = new Sprite();
         labelLayer = new Sprite();
         uiLayer = new Sprite();
         uiBatch = new QuadBatch();
         shipsBatch1 = new QuadBatch();
         shipsBatch1b = new QuadBatch();
         shipsBatch2 = new QuadBatch();
         shipsBatch2b = new QuadBatch();
         mouseBatch = new QuadBatch();
         // 造一堆可视化对象
         gameContainer.addChild(gameLayer);
         gameLayer.addChild(shipsLayer1);
         gameLayer.addChild(nodeLayer);
         gameLayer.addChild(nodeGlowLayer);
         gameLayer.addChild(nodeGlowLayer2);
         gameLayer.addChild(shipsLayer2);
         gameLayer.addChild(fxLayer);
         gameLayer.addChild(shapeLayer);
         gameLayer.addChild(labelLayer);
         addChild(gameContainer);
         addChild(uiLayer);
         // 通关时的遮罩
         cover = new Quad(1024, 768, 16777215);
         cover.touchable = false;
         cover.blendMode = "add";
         cover.alpha = 0;
         addChild(cover);
         // 其他可视化对象
         shipsLayer1.addChild(shipsBatch1);
         shipsLayer1.addChild(shipsBatch1b);
         shipsLayer2.addChild(shipsBatch2);
         shipsLayer2.addChild(shipsBatch2b);
         fxLayer.blendMode = "add";
         shapeLayer.addChild(uiBatch);
         shapeLayer.addChild(mouseBatch);
         nodeGlowLayer.blendMode = "add";
         uiLayer.blendMode = "add";
         gameContainer.x = gameContainer.pivotX = 512;
         gameContainer.y = gameContainer.pivotY = 384;
         juggler = new Juggler();
         darkPulse = new Image(Root.assets.getTexture("halo"));
         darkPulse.pivotY = darkPulse.pivotX = darkPulse.width * 0.5;
         darkPulse.x = 512;
         darkPulse.y = 384;
         darkPulse.color = 0;
         nodeGlowLayer2.addChild(darkPulse);
         darkPulse.visible = false;
         ais = new EntityPool();
         nodes = new EntityPool();
         ships = new EntityPool();
         warps = new EntityPool();
         beams = new EntityPool();
         pulses = new EntityPool();
         flashes = new EntityPool();
         barriers = new EntityPool();
         explosions = new EntityPool();
         darkPulses = new EntityPool();
         fades = new EntityPool();
         entities = [ships, nodes, ais, warps, beams, pulses, flashes, barriers, explosions, darkPulses, fades]; // 实体池列表
         triggers = [false, false, false, false, false]; // 特殊事件
         barrierLines = []; // 障碍连接数据
         ui = new GameUI();
         tutorial = new TutorialSprite();
         this.alpha = 0;
         this.visible = false;
         gameOver = true;
      }
      // #region 进入关卡
      public function init():void // 进入关卡时触发，生成关卡
      {
         var i:int = 0;
         var _aiArray:Array = [];
         this.level = Globals.level;
         _aiArray = nodeIn(); // 生成天体，同时返回需生成的ai
         for (i = 0; i < _aiArray.length; i++)
         {
            addAI(_aiArray[i]); // 为有天体的常规势力添加ai
         }
         if (Globals.level >= 35) // 为36关黑色设定ai
         {
            addAI(6, 3);
            bossTimer = 0;
         }
         for (i = 0; i < triggers.length; i++)
         {
            triggers[i] = false; // 重置特殊事件
         }
         // 执行一些初始化函数
         ui.init(this);
         tutorial.init(this);
         getBarrierLines();
         addBarriers();
         hideSingleBarriers();
         if (darkPulse)
            darkPulse.visible = false;
         // 重置一些变量
         this.alpha = 0;
         this.visible = true;
         cover.alpha = 0;
         uiLayer.alpha = 1;
         labelLayer.alpha = 1;
         shipsLayer1.alpha = 1;
         shipsLayer2.alpha = 1;
         Globals.soundMult = 1;
         gameOver = false;
         gameOverTimer = 3;
         winningTeam = -1;
         // 以下部分决定bgm的播放
         if (Globals.level < 9)
            GS.playMusic("bgm02");
         else if (Globals.level < 23)
            GS.playMusic("bgm04");
         else if (Globals.level < 32)
            GS.playMusic("bgm05");
         else
            GS.playMusic("bgm06");
         addEventListener("enterFrame", update); // 添加帧监听器，每帧执行一次update
         animateIn(); // 播放关卡进入动画
      }

      public function nodeIn():Array // 生成天体并返回需添加的ai
      {
         var _Node:Node = null;
         var _Level:Array = LevelData.maps[level];
         var _aiArray:Array = [];
         for each (var _NodeData:Array in _Level) // 处理每个天体
         {
            if (_NodeData.length >= 7)
               _Node = addNode(_NodeData[0], _NodeData[1], _NodeData[2], _NodeData[3], _NodeData[4], _NodeData[5], _NodeData[6]);
            else
               _Node = addNode(_NodeData[0], _NodeData[1], _NodeData[2], _NodeData[3], _NodeData[4], _NodeData[5]);
            if (Globals.level != 31) // 修改32关之外的天体数据
            {
               if (Globals.level == 35 && _Node.team == 6)
                  _Node.startVal = 0; // 36关黑色除星核无初始兵力
               if (_Node.type == 5) // 设定星核数据
               {
                  _Node.buildRate = 8;
                  _Node.popVal = 280;
                  _Node.startVal = 150;
               }
            }
            if (_NodeData.length >= 8) // 检验第八项数据(自定义兵力或障碍)
            {
               if (_NodeData[7] is Array)
               {
                  if (_Node.type == 3) // 障碍
                  {
                     _Node.barrierLinks.length = 0;
                     _Node.barrierCostom = true;
                     for each (var _Barrier:int in _NodeData[7])
                     {
                        _Node.barrierLinks.push(_Barrier);
                     }
                  }
                  else // 兵力
                  {
                     for (var i:int = 0; i < _NodeData[7].length; i++)
                     {
                        addShips(_Node, i, _NodeData[7][i]);
                     }
                  }
                  _Node.startVal = 0; // 禁用原版初始人口设定
               }
               else
               {
                  if (_Node.type == 3) // 障碍
                  {
                     _Node.barrierLinks.length = 0;
                     _Node.barrierCostom = true;
                     _Node.barrierLinks.push(_NodeData[7]);
                  }
                  else
                     _Node.startVal = int(_NodeData[7]); // 设定初始人口为该参数
               }
            }
            if (_aiArray.indexOf(_NodeData[4]) == -1) // 写入具有常规ai的势力，此处检验势力是否已写入，避免重复写入
            {
               switch (_NodeData[4])
               {
                  case 0: // 排除中立势力
                  case 1: // 排除玩家势力
                  case 5: // 排除灰色势力
                  case 6: // 排除黑色势力
                     break;
                  default:
                     _aiArray.push(_NodeData[4]);
                     break;
               }
            }
            if (_Node.team > 0 && _Node.startVal > 0)
               addShips(_Node, _Node.team, _Node.startVal); // 为非中立天体添加初始飞船
         }
         return _aiArray;
      }

      public function animateIn():void // 关卡进入动画
      {
         this.alpha = 0;
         this.visible = true;
         gameContainer.scaleY = 0.7; // 动画初始缩放
         gameContainer.scaleX = 0.7; // 动画初始缩放
         gameContainer.y = 354;
         Starling.juggler.tween(gameContainer, Globals.transitionSpeed, {
                  "scaleX": 1,
                  "scaleY": 1,
                  "y": 384,
                  "transition": "easeInOut"
               });
         Starling.juggler.tween(this, Globals.transitionSpeed, {
                  "alpha": 1,
                  "transition": "easeInOut"
               });
      }

      public function getBarrierLines():void // 计算障碍线数组
      {
         var i:int = 0;
         var j:int = 0;
         var k:int = 0;
         var L_1:int = 0;
         var L_2:int = 0;
         var L_3:int = 0;
         var _Node1:Node = null;
         var _Node2:Node = null;
         var _Array:Array;
         var _Exist:Boolean;
         barrierLines.length = 0; // 清空障碍线数组
         L_1 = int(nodes.active.length);
         i = 0;
         while (i < L_1)
         {
            _Node1 = nodes.active[i];
            if (_Node1.type == 3)
            {
               L_2 = int(_Node1.barrierLinks.length); // 该天体需连接的障碍总数
               j = 0;
               while (j < L_2)
               {
                  if (_Node1.barrierLinks[j] is Node)
                  {
                     _Node2 = _Node1.barrierLinks[j];
                  }
                  else if (_Node1.barrierLinks[j] < L_1)
                  {
                     _Node2 = nodes.active[_Node1.barrierLinks[j]];
                  }
                  if (!(!_Node1.barrierCostom && _Node2.barrierCostom))
                  {
                     _Array = [new Point(_Node1.x, _Node1.y), new Point(_Node2.x, _Node2.y)];
                     L_3 = int(barrierLines.length);
                     k = 0;
                     _Exist = false;
                     while (k < L_3)
                     {
                        if (check4same(_Array, barrierLines[k]))
                        {
                           _Exist = true;
                        }
                        k++;
                     }
                     if (!_Exist && _Node2.type == 3)
                     {
                        barrierLines.push(_Array);
                        _Node1.linked = true;
                        _Node2.linked = true;
                     }
                  }
                  j++;
               }
            }
            i++;
         }
      }

      public function check4same(_Array1:Array, _Array2:Array):Boolean // 用于getBarrierLines()中的查重
      {
         var _1:Point = _Array1[0];
         var _2:Point = _Array1[1];
         var _3:Point = _Array2[0];
         var _4:Point = _Array2[1];
         var _result:Boolean = false;
         if (_1.x == _3.x && _1.y == _3.y && _2.x == _4.x && _2.y == _4.y)
            _result = true;
         if (_1.x == _4.x && _1.y == _4.y && _2.x == _3.x && _2.y == _3.y)
            _result = true;
         return _result;
      }

      public function hideSingleBarriers():void // 隐藏单个障碍
      {
         for each (var _Node:Node in nodes.active)
         {
            if (_Node.type == 3 && !_Node.linked)
            {
               _Node.image.visible = false;
               _Node.halo.visible = false;
            }
         }
      }
      // #endregion
      // #region 界面功能
      public function deInit():void // 退出关卡，移除实体和更新帧监听器
      {
         tutorial.deInit();
         for each (var _pool:EntityPool in entities)
         {
            _pool.deInit();
         }
         removeEventListener("enterFrame", update); // 移除更新帧监听器
         clearGraphics();
      }

      public function quit():void // 移除UI，执行animateOut()
      {
         ui.deInit();
         animateOut();
         dispatchEventWith("menu");
      }

      public function next():void // 解锁下一关，执行animateOut()
      {
         if (Globals.levelData[Globals.level] < Globals.currentDifficulty)
         {
            Globals.levelData[Globals.level] = Globals.currentDifficulty;
         }
         if (Globals.levelReached < Globals.level + 1)
         {
            Globals.levelReached = Globals.level + 1;
            dispatchEventWith("next");
         }
         else
         {
            dispatchEventWith("menu");
         }
         Globals.save();
         ui.deInit();
         animateOut();
      }

      public function animateOut():void // 关卡退出动画，执行hide()
      {
         Starling.juggler.tween(gameContainer, Globals.transitionSpeed, {
                  "scaleX": 0.7,
                  "scaleY": 0.7,
                  "y": 354,
                  "transition": "easeInOut"
               });
         Starling.juggler.tween(this, Globals.transitionSpeed, {
                  "alpha": 0,
                  "onComplete": hide,
                  "transition": "easeInOut"
               });
      }

      public function hide():void // 隐藏UI，执行deInit()
      {
         this.visible = false;
         deInit();
      }

      public function pause():void // 调用暂停
      {
         Globals.main.on_deactivate(null);
      }

      public function restart():void // 重开
      {
         Starling.juggler.tween(this, 0.1, {
                  "alpha": 0,
                  "transition": "easeIn",
                  "onComplete": function():void
                  {
                     ui.deInit();
                     deInit();
                     init();
                  }
               });
      }
      // #endregion
      // #region 逐帧更新
      public function update(e:EnterFrameEvent):void // 更新
      {
         var dt:Number = e.passedTime;
         if (this.alpha == 0)
            return; // 不是哥们你啥时候不透明度不为零啊
         GS.update(dt); // 更新音效计时器
         dt *= this.alpha; // wtf？？
         dt = updateSpeed(dt); // 更新游戏速度
         countTeamCaps(); // 统计兵力
         juggler.advanceTime(dt); // 插件内容，动画相关
         clearGraphics(); // 重置图像
         for each (var _pool:EntityPool in entities) // 依次执行所有实体的更新函数
         {
            _pool.update(dt);
         }
         ui.update(dt); // 更新ui
         shipsBatch1.blendMode = "add";
         shipsBatch2.blendMode = "add";
         specialEvents(); // 处理特殊关卡的特殊事件
         if (darkPulse.visible)
            expandDarkPulse(dt);
         if (Globals.level != 35)
            updateGameOver(dt);
      }

      public function updateSpeed(_dt:Number):Number // 更新游戏速度
      {
         if (Globals.level == 35 && gameOver) // 36关通关时
         {
            slowMult -= _dt * 0.75;
            if (slowMult < 0.1)
               slowMult = 0.1;
            _dt *= slowMult;
         }
         if (ui.speedBtns[0].toggled) // 减速按钮
         {
            if (!(Globals.level == 31 && triggers[0]))
            {
               if (!(Globals.level == 35 && triggers[0]))
               {
                  _dt *= 0.5;
               }
            }
         }
         if (ui.speedBtns[2].toggled) // 加速按钮
         {
            if (!(Globals.level == 31 && triggers[0]))
            {
               if (!(Globals.level == 35 && triggers[0]))
               {
                  _dt *= 2;
               }
            }
         }
         return _dt;
      }

      public function countTeamCaps():void // 统计兵力
      {
         for(var _team:int = 0; _team < Globals.teamCount; _team++) // 重置兵力
         {
            Globals.teamCaps[_team] = 0;
            Globals.teamPops[_team] = 0;
         }
         for each (var _Node:Node in nodes.active) // 统计兵力上限
         {
            Globals.teamCaps[_Node.team] += _Node.popVal;
         }
         for each (var _Ship:Ship in ships.active) // 统计总兵力
         {
            Globals.teamPops[_Ship.team]++;
         }
      }

      public function clearGraphics():void
      {
         shipsBatch1.reset();
         shipsBatch1b.reset();
         shipsBatch2.reset();
         shipsBatch2b.reset();
         uiBatch.reset();
         mouseBatch.reset();
      }

      public function specialEvents():void // 特殊事件
      {
         var i:int;
         var _boss:Node;
         var _timer:Number;
         var _rate:Number;
         var _addTime:Number;
         var _angle:Number;
         var _angleStep:Number;
         var _size:Number;
         switch (Globals.level) // 处理特殊关卡的特殊事件
         {
            case 0: // 前两关处理教程提示
               if (!triggers[0])
               {
                  if (nodes.active[0].ships[1].length < 60)
                     triggers[0] = true;
               }
               break;
            case 1:
               if (!triggers[0])
               {
                  if (ui.movePerc < 1)
                     triggers[0] = true;
               }
               break;
            case 31:
               if (!triggers[0])
               {
                  _boss = nodes.active[0];
                  if (_boss.hp == 100)
                  {
                     triggers[0] = true;
                     _timer = 0;
                     _rate = 0.5;
                     _addTime = 1;
                     _angle = 1.5707963267948966;
                     _angleStep = 2.0943951023931953;
                     _size = 2;
                     for (i = 0; i < 64; i++)
                     {
                        addDarkPulse(_boss, 0, 1, _size, _rate, _angle, _timer);
                        _timer += _addTime;
                        _angle += _angleStep;
                        addDarkPulse(_boss, 0, 1, _size, _rate, _angle, _timer);
                        _timer += _addTime;
                        _angle += _angleStep;
                        addDarkPulse(_boss, 0, 1, _size, _rate, _angle, _timer);
                        _timer += _addTime;
                        _angle += _angleStep;
                        if (i < 20)
                        {
                           _rate *= 1.1;
                           _addTime *= 0.85;
                        }
                        _size *= 0.975;
                     }
                     addDarkPulse(_boss, 0, 2, 2.5, 0.75, 0, _timer - 5.5);
                     addDarkPulse(_boss, 0, 2, 2.5, 1, 0, _timer - 4.5);
                     _boss.triggerTimer = _timer - 3;
                     Starling.juggler.tween(Globals, 5, {"soundMult": 0});
                     GS.playMusic("bgm_dark", false);
                  }
               }
               if (triggers[0] && !triggers[1])
               {
                  _boss = nodes.active[0];
                  if (_boss.triggerTimer == 0)
                  {
                     triggers[1] = true;
                     _boss.bossReady();
                     _boss.changeTeam(6);
                     _boss.changeShipsTeam(6);
                     addAI(6, 2);
                     _boss.triggerTimer = 3;
                     darkPulse.color = 0;
                     darkPulse.blendMode = "normal";
                     darkPulse.scaleX = darkPulse.scaleY = 0;
                     darkPulse.visible = true;
                  }
               }
               if (triggers[1] && !triggers[2])
               {
                  _boss = nodes.active[0];
                  if (_boss.triggerTimer == 0)
                  {
                     triggers[2] = true;
                     _boss.bossDisappear();
                  }
               }
               break;
            case 32:
            case 33:
            case 34:
               if (!triggers[0]) // 阶段一，生成星核
               {
                  for (i = 0; i < Globals.teamCaps.length; i++)
                  {
                     if (Globals.teamCaps[i] > 220 && Globals.teamPops[i] > 220)
                     {
                        _boss = nodes.getReserve() as Node;
                        if (!_boss)
                           _boss = new Node();
                        _boss.initBoss(this, 512, 384);
                        nodes.addEntity(_boss);
                        _boss.bossAppear();
                        triggers[0] = true;
                        GS.fadeOutMusic(2);
                        GS.playSound("boss_appear");
                        break;
                     }
                  }
               }
               if (triggers[0] && !triggers[1]) // 阶段二，生成飞船，添加ai
               {
                  _boss = nodes.active[nodes.active.length - 1];
                  if (_boss.triggerTimer == 0)
                  {
                     triggers[1] = true;
                     _boss.bossReady();
                     if (Globals.level == 33)
                        addShips(_boss, 6, 320);
                     else
                        addShips(_boss, 6, 350);
                     addAI(6, 2);
                     _boss.triggerTimer = 3;
                     GS.playSound("boss_ready", 1.5);
                  }
               }
               if (triggers[1] && !triggers[2]) // 阶段三，星核消失动画
               {
                  _boss = nodes.active[nodes.active.length - 1];
                  if (_boss.triggerTimer == 0)
                  {
                     triggers[2] = true;
                     _boss.bossDisappear();
                     GS.playSound("boss_reverse");
                  }
               }
               if (triggers[2] && !triggers[3]) // 阶段四，移除星核
               {
                  _boss = nodes.active[nodes.active.length - 1];
                  if (_boss.triggerTimer == 0)
                  {
                     triggers[3] = true;
                     _boss.bossHide();
                     _boss.active = false;
                     GS.playMusic("bgm06");
                  }
               }
               break;
            case 35: // 这里末尾有个return
               if (!gameOver)
               {
                  _boss = nodes.active[0];
                  if (!triggers[0] && _boss.hp == 0) // 阶段一，坍缩动画
                  {
                     triggers[0] = true;
                     _timer = 0;
                     _rate = 0.5;
                     _addTime = 1;
                     _angle = 1.5707963267948966;
                     _angleStep = 2.0943951023931953;
                     _size = 2;
                     for (i = 0; i < 64; i++)
                     {
                        addDarkPulse(_boss, Globals.teamColors[1], 1, _size, _rate, _angle, _timer);
                        _timer += _addTime;
                        _angle += _angleStep;
                        addDarkPulse(_boss, Globals.teamColors[1], 1, _size, _rate, _angle, _timer);
                        _timer += _addTime;
                        _angle += _angleStep;
                        addDarkPulse(_boss, Globals.teamColors[1], 1, _size, _rate, _angle, _timer);
                        _timer += _addTime;
                        _angle += _angleStep;
                        if (i < 20)
                        {
                           _rate *= 1.1;
                           _addTime *= 0.85;
                        }
                        _size *= 0.975;
                     }
                     addDarkPulse(_boss, Globals.teamColors[1], 2, 2.5, 0.75, 0, _timer - 5.5);
                     addDarkPulse(_boss, Globals.teamColors[1], 2, 2.5, 1, 0, _timer - 4.5);
                     _boss.triggerTimer = _timer - 2.5;
                     Globals.levelReached = 36;
                     if (Globals.levelData[Globals.level] < Globals.currentDifficulty)
                        Globals.levelData[Globals.level] = Globals.currentDifficulty;
                     Globals.save();
                     GS.playMusic("bgm07", false);
                     Starling.juggler.tween(Globals, 10, {"soundMult": 0});
                     ui.deInit();
                     Starling.juggler.tween(uiLayer, 5, {"alpha": 0});
                     Starling.juggler.tween(labelLayer, 5, {
                              "alpha": 0,
                              "delay": 22
                           });
                     Starling.juggler.tween(shipsLayer1, 5, {
                              "alpha": 0,
                              "delay": 50
                           });
                     Starling.juggler.tween(shipsLayer2, 5, {
                              "alpha": 0,
                              "delay": 50
                           });
                  }
                  if (triggers[0] && !triggers[1]) // 阶段二，膨胀动画
                  {
                     _boss = nodes.active[0];
                     if (_boss.triggerTimer == 0)
                     {
                        triggers[1] = true;
                        _timer = 0;
                        _rate = 2;
                        _addTime = 0.15;
                        _angle = 1.5707963267948966;
                        _angleStep = 2.0943951023931953;
                        _size = 1.75;
                        for (i = 0; i < 9; i++)
                        {
                           addDarkPulse(_boss, Globals.teamColors[1], 0, _size, _rate, _angle, _timer);
                           _timer += _addTime;
                           _angle += _angleStep;
                           addDarkPulse(_boss, Globals.teamColors[1], 0, _size, _rate, _angle, _timer);
                           _timer += _addTime;
                           _angle += _angleStep;
                           addDarkPulse(_boss, Globals.teamColors[1], 0, _size, _rate, _angle, _timer);
                           _timer += _addTime;
                           _angle += _angleStep;
                           _size *= 1.2;
                        }
                        addDarkPulse(_boss, Globals.teamColors[1], 3, 20, 5, 0, _timer - 3.5);
                        addDarkPulse(_boss, Globals.teamColors[1], 3, 25, 10, 0, _timer - 3.5);
                        addDarkPulse(_boss, Globals.teamColors[1], 3, 30, 15, 0, _timer - 3.5);
                        addDarkPulse(_boss, Globals.teamColors[1], 3, 40, 20, 0, _timer - 4);
                        addDarkPulse(_boss, Globals.teamColors[1], 3, 50, 25, 0, _timer - 4);
                        addDarkPulse(_boss, Globals.teamColors[1], 3, 60, 30, 0, _timer - 4);
                        addDarkPulse(_boss, Globals.teamColors[1], 3, 50, 20, 0, _timer - 3);
                        addDarkPulse(_boss, Globals.teamColors[1], 3, 60, 30, 0, _timer - 2);
                        addDarkPulse(_boss, Globals.teamColors[1], 3, 50, 6, 0, _timer - 2);
                        addDarkPulse(_boss, Globals.teamColors[1], 3, 60, 8, 0, _timer - 2);
                        _boss.triggerTimer = _timer - 3.5;
                     }
                  }
                  if (triggers[1] && !triggers[2]) // 阶段三，画面缩小，天体消失，回到主界面
                  {
                     _boss = nodes.active[0];
                     if (_boss.triggerTimer == 0)
                     {
                        _boss.active = false;
                        gameOver = true;
                        gameOverTimer = 1;
                        slowMult = 1;
                        triggers[2] = true;
                        darkPulse.color = Globals.teamColors[1];
                        darkPulse.blendMode = "add";
                        darkPulse.scaleX = darkPulse.scaleY = 0;
                        darkPulse.visible = true;
                        Starling.juggler.tween(gameContainer, 25, {
                                 "scaleX": 0.01,
                                 "scaleY": 0.01,
                                 "delay": 20,
                                 "transition": "easeInOut"
                              }); // 画面缩小动画
                        Starling.juggler.tween(this, 5, {
                                 "alpha": 0,
                                 "delay": 40,
                                 "onComplete": hide
                              }); // 天体消失动画
                        Starling.juggler.delayCall(function():void
                           {
                              dispatchEventWith("end"); // 执行Root.as 中的on_end
                           }, 40); // 退回到主界面
                     }
                  }
                  if (triggers[2] && gameOver)
                  {
                  }
               }
               break;
            default:
               return;
         }
      }

      public function expandDarkPulse(_dt:Number):void // 同化波
      {
         var _team:int = 1;
         var _Node:Node = null;
         var _x:Number = NaN;
         var _y:Number = NaN;
         var _Distance:Number = NaN;
         var _Ship:Ship = null;
         if (darkPulse.color == 0)
            _team = 6;
         if (_team == 1)
            darkPulse.scaleX += _dt * 2;
         else
            darkPulse.scaleX += _dt * 0.5;
         darkPulse.scaleY = darkPulse.scaleX;
         if (darkPulse.width > 3072)
         {
            darkPulse.visible = false;
            gameOver = true;
            winningTeam = 1;
            gameOverTimer = 0.5;
         }
         for each (_Node in nodes.active)
         {
            if (_Node.team == _team)
               continue;
            _x = _Node.x - darkPulse.x;
            _y = _Node.y - darkPulse.y;
            _Distance = Math.sqrt(_x * _x + _y * _y);
            if (_Distance < darkPulse.width * 0.25)
            {
               _Node.changeTeam(_team);
               _Node.changeShipsTeam(_team);
               _Node.hp = 100;
            }
         }
         for each (_Ship in ships.active)
         {
            if (_Ship.team == _team)
               continue;
            _x = _Ship.x - darkPulse.x;
            _y = _Ship.y - darkPulse.y;
            _Distance = Math.sqrt(_x * _x + _y * _y);
            if (_Distance < darkPulse.width * 0.25)
               _Ship.changeTeam(_team);
         }
      }

      public function updateGameOver(_dt:Number):void // 通关检测及通关动画
      {
         if (!gameOver) // 通关判断
         {
            checkWinningTeam();
            if (Globals.level == 31 && winningTeam == 1 || winningTeam == 6)
               gameOver = false; // 32关禁用常规通关判定，禁止黑色通关
            if (gameOver) // 处理游戏结束时的动画
            {
               var _ripple:int = 1;
               for each (var _Node:Node in nodes.active)
               {
                  if (_Node.type == 3)
                     continue;
                  _Node.winPulseTimer = _ripple * 0.101;
                  _Node.winTeam = winningTeam;
                  _ripple++;
               }
               cover.color = Globals.teamColors[winningTeam];
               Starling.juggler.tween(cover, 1, {"alpha": 0.4});
               Starling.juggler.tween(cover, 1, {
                        "alpha": 0,
                        "delay": 1
                     });
            }
         }
         else if (gameOverTimer > 0)
         {
            gameOverTimer -= _dt;
            if (gameOverTimer <= 0)
            {
               if (winningTeam == 1)
                  next();
               else
                  quit();
            }
         }
      }

      public function checkWinningTeam():void // 决胜判断
      {
         var i:int = 0;
         var _Node:Node = null;
         if (Globals.level == 0) // 第一关的特殊通关条件：非障碍天体均被玩家占领
         {
            winningTeam = 1; // 玩家势力获胜
            gameOver = true; // 不判定游戏继续时，游戏结束
            for each (_Node in nodes.active)
            {
               if (_Node.team != 1 && _Node.type != 3)
                  gameOver = false;
            }
            return; // 终止该函数
         }
         for (i = 0; i < Globals.teamCount; i++) // 判断场上的飞船仅剩一方势力
         {
            gameOver = true;
            for (var j:int = 0; j < Globals.teamCount; j++)
            {
               if (i == j)
                  continue;
               if (Globals.teamPops[j] > 0) // 该其他势力有飞船时
               {
                  gameOver = false;
                  break; // 结束内循环
               }
            }
            if (gameOver == true)
               break;
         }
         if (gameOver == false)
            return;
         for each (_Node in nodes.active) // 判断非中立天体上都有获胜势力的飞船
         {
            if (_Node.team == 0 || _Node.team == i)
               continue;
            if (_Node.type == 3 || _Node.type == 5)
               continue; // 排除障碍和星核
            if (_Node.ships[i].length == 0 && i != 0) // 如果天体上没有飞船
            {
               gameOver = false; // 游戏继续
               return;
            }
            if (i == 0 && _Node.buildRate != 0) // 都没飞船也都产不了兵判中立赢
            {
               gameOver = false; // 游戏继续
               return;
            }
         }
         winningTeam = i;
      }
      // #endregion
      // #region 添加实体
      public function addAI(_team:int, _type:int = 1):void
      {
         var _EnemyAI:EnemyAI = ais.getReserve() as EnemyAI;
         if (!_EnemyAI)
            _EnemyAI = new EnemyAI();
         _EnemyAI.initAI(this, _team, _type);
         ais.addEntity(_EnemyAI);
      }

      public function addNode(_x:Number, _y:Number, _type:int, _size:Number, _team:Number, _orbit:int, _orbitSpeed:Number = 0.1):Node
      {
         var _clock:Boolean = false; // 轨道方向，true为顺时针，false为逆时针
         var _Node:Node; // 天体对象
         if (!(_Node = nodes.getReserve() as Node))
            _Node = new Node();
         var _orbitNode:Node = null; // 轨道中心天体对象
         if (_orbit > -1) // 轨道判断
         {
            _clock = true;
            if (_orbit >= 100)
            {
               _orbit -= 100;
               _clock = false;
            }
            _orbitNode = nodes.active[_orbit];
         }
         _Node.initNode(this, _x, _y, _type, _size, _team, _orbitNode, _clock, _orbitSpeed);
         nodes.addEntity(_Node);
         _Node.tag = nodes.active.length - 1;
         return _Node;
      }

      public function addShips(_Node:Node, _team:int, _Number:int):void // 添加多个飞船
      {
         for (var i:int = 0; i < _Number; i++)
         {
            addShip(_Node, _team, false);
         }
      }

      public function addShip(_Node:Node, _team:int, _productionEffect:Boolean = true):void // 添加单个飞船
      {
         var _Ship:Ship;
         if (!(_Ship = ships.getReserve() as Ship))
            _Ship = new Ship();
         _Ship.initShip(this, _team, _Node, _productionEffect);
         ships.addEntity(_Ship);
      }

      public function addBarriers():void // 绘制障碍线
      {
         var _x1:Number = NaN;
         var _y1:Number = NaN;
         var _x2:Number = NaN;
         var _y2:Number = NaN;
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         var _Angle:Number = NaN;
         var _Distance:Number = NaN;
         var _x3:Number = NaN;
         var _y3:Number = NaN;
         var _space:Number = 8;
         var _dspace:int = 0;
         for each (var _barrierArray:Array in barrierLines)
         {
            _x1 = Number(_barrierArray[0].x);
            _y1 = Number(_barrierArray[0].y);
            _x2 = Number(_barrierArray[1].x);
            _y2 = Number(_barrierArray[1].y);
            _space = 8; // 贴图间距
            _dx = _x2 - _x1;
            _dy = _y2 - _y1;
            _Angle = Math.atan2(_dy, _dx);
            _Distance = Math.sqrt(_dx * _dx + _dy * _dy);
            _x3 = _x1 + Math.cos(_Angle) * _space;
            _y3 = _y1 + Math.sin(_Angle) * _space;
            _dspace = int(_space);
            while (_dspace < int(Math.floor(_Distance)))
            {
               _dx = _x3 + Math.cos(_Angle) * _space * 0.5;
               _dy = _y3 + Math.sin(_Angle) * _space * 0.5;
               addBarrier(_x3, _y3, _Angle, 16729156);
               _x3 += Math.cos(_Angle) * _space;
               _y3 += Math.sin(_Angle) * _space;
               _dspace += int(_space);
            }
         }
      }

      public function addBarrier(_x:Number, _y:Number, _Angle:Number, _Color:uint):void // 添加障碍线贴图
      {
         var _BarrierFX:BarrierFX;
         if (!(_BarrierFX = barriers.getReserve() as BarrierFX))
            _BarrierFX = new BarrierFX();
         _BarrierFX.initBarrier(this, _x, _y, _Angle, _Color);
         barriers.addEntity(_BarrierFX);
      }
      // #endregion
      // #region 添加特效
      public function addWarp(_GameScene:Number, _x:Number, _y:Number, _prevX:Number, _prevY:uint, _foreground:Boolean):void
      {
         var _warp:WarpFX;
         if (!(_warp = warps.getReserve() as WarpFX))
            _warp = new WarpFX();
         _warp.initWarp(this, _GameScene, _x, _y, _prevX, _prevY, _foreground);
         warps.addEntity(_warp);
      }

      public function addBeam(_x1:Number, _y1:Number, _x2:Number, _y2:Number, _color:uint, _Nodetype:int):void
      {
         var _BeamFX:BeamFX;
         if (!(_BeamFX = beams.getReserve() as BeamFX))
            _BeamFX = new BeamFX();
         _BeamFX.initBeam(this, _x1, _y1, _x2, _y2, _color, _Nodetype);
         beams.addEntity(_BeamFX);
      }

      public function addPulse(_Node:Node, _Color:uint, _type:int, _delay:Number = 0):void
      {
         var _NodePulse:NodePulse;
         if (!(_NodePulse = pulses.getReserve() as NodePulse))
            _NodePulse = new NodePulse();
         _NodePulse.initPulse(this, _Node, _Color, _type, _delay);
         pulses.addEntity(_NodePulse);
      }

      public function addDarkPulse(_Node:Node, _Color:uint, _type:int, _maxSize:Number, _rate:Number, _angle:Number, _delay:Number = 0):void
      {
         var _DarkPulse:DarkPulse;
         if (!(_DarkPulse = darkPulses.getReserve() as DarkPulse))
            _DarkPulse = new DarkPulse();
         _DarkPulse.initPulse(this, _Node, _Color, _type, _maxSize, _rate, _angle, _delay);
         darkPulses.addEntity(_DarkPulse);
      }

      public function addFade(_x:Number, _y:Number, _size:Number, _color:uint, _type:int):void // type 0为扩散式 1为收缩式
      {
         var _SelectFade:SelectFade;
         if (!(_SelectFade = fades.getReserve() as SelectFade))
            _SelectFade = new SelectFade();
         _SelectFade.initSelectFade(this, _x, _y, _size, _color, _type);
         fades.addEntity(_SelectFade);
      }
      // 下面这俩只在摧毁飞船时调用过
      public function addFlash(_x:Number, _y:Number, _Color:uint, _foreground:Boolean):void
      {
         var _Flash:FlashFX;
         if (!(_Flash = explosions.getReserve() as FlashFX))
            _Flash = new FlashFX();
         _Flash.initExplosion(this, _x, _y, _Color, _foreground);
         flashes.addEntity(_Flash);
      }

      public function addExplosion(_x:Number, _y:Number, _Color:uint, _foreground:Boolean):void
      {
         var _Explode:ExplodeFX;
         if (!(_Explode = explosions.getReserve() as ExplodeFX))
            _Explode = new ExplodeFX();
         _Explode.initExplosion(this, _x, _y, _Color, _foreground);
         explosions.addEntity(_Explode);
      }
      // #endregion
   }
}
