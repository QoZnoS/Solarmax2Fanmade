/* 计时器基本原理：取一个初始值，每帧为其减去这一帧的时间，计时归零时执行相应函数并重置计时器
   需搞懂的机制：ai计时器，触发器
   需要的新功能：天体实时生成与摧毁
   
   ai计时器：具有同等于势力数的项数，每一项均为倒计时
   发送ai飞船时重置计时器为1s，ai统计出兵天体时只统计计时器为0的天体（存在特例）
   相当于单个天体的AI出兵冷却时间，由 EnemyAI.as 决定是否采用

   障碍机制：障碍生成时执行getBarrierLinks()计算需连接的障碍存进barrierLinks，这是单个障碍的一维数组
   接着GameScene.as中执行getBarrierLines()计算所有障碍连接并存进barrierLines，这是单局游戏的二维数组，每一项均为需连接的[障碍A，障碍B]
   接着GameScene.as中执行addBarriers()绘制障碍线

   天体状态：
   conflict：战争，存在两方及以上势力飞船时判定
   capturing：占据，仅存在非己方势力飞船时判定

   warps数组用于处理传送门目的地的特效，原理如下：
   sendShips()或sendAIShips()中执行Ship.as中的warpTo()，飞船依次经过12阶段
   在起飞阶段到达目的地后将目的地天体的warps中对应势力项改为true，接着天体在update()中检测warps数组播放特效
*/
package Game.Entity
{
   import Game.GameScene;
   import flash.geom.Point;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.text.TextField;

   public class Node extends GameEntity
   {
      // #region 类变量
      // 基本变量
      public var x:Number; // 坐标x
      public var y:Number; // 坐标y
      public var team:int; // 势力
      public var size:Number; // 大小
      public var type:int; // 类型
      public var tag:int; // 标记符，debug用
      public var startVal:int; // 初始人口
      public var popVal:int; // 人口上限
      public var attackRange:Number; // 攻击半径
      public var attackRate:Number; // 攻击间隔
      public var buildRate:Number; // 生产速度，生产时间的倒数
      public var orbitNode:Node; // 轨道中心天体
      public var orbitDist:Number; // 轨道半径
      public var orbitSpeed:Number; // 轨道运转速度
      // 状态变量
      public var hp:Number; // 占领度，中立为0，被任意势力完全占领为100
      public var conflict:Boolean; // 战斗状态，判断天体上是否有战斗
      public var capturing:Boolean; // 占据状态
      public var captureTeam:int; // 占领条势力
      public var captureRate:Number; // 占领速度
      public var buildTimer:Number; // 生产计时器
      public var attackTimer:Number; // 攻击计时器
      public var orbitAngle:Number; // 轨道旋转角度
      public var ships:Array; // 第一维储存的每个数组对应一个势力，第二维数组用于储存飞船的引用，一个值指代一个飞船，二维数组的长度表示该天体上该势力的飞船总数
      // AI相关变量
      public var aiValue:Number; // ai价值（EnemyAI.as
      public var aiStrength:Number; // ai强度（EnemyAI.as
      public var aiTimers:Array; // ai计时器
      public var transitShips:Array; // 
      public var oppNodeLinks:Array; // 
      public var nodeLinks:Array; // 
      // 贴图相关变量
      public var glow:Image; // 光效图片
      public var image:Image; // 天体图片
      public var halo:Image; // 光圈图片
      public var label:TextField; // 非战斗状态下的兵力文本
      public var glowing:Boolean; // 是否正在发光（天体改变势力时的特效
      public var labels:Array; // 战斗状态下的兵力文本列表
      public var warps:Array; // 是否有传送，只和传送门目的地特效有关
      public var winPulseTimer:Number; // 通关占领特效计时器
      public var triggerTimer:Number; // 用于特殊事件
      public var labelDist:Number; // 文本圈大小
      // 其他变量
      public var lineDist:Number; // 选中圈大小
      public var touchDist:Number; // 传统操作模式下的选中圈大小
      public var winTeam:int; // 获胜势力，游戏结束后在 GameScene.as 中统一
      public var barrierLinks:Array; // 障碍连接数组
      public var barrierCostom:Boolean; // 障碍是否为自定义连接
      public var linked:Boolean; // 是否被连接

      private var drawQuad:Quad; // 
      private var quadImage:Image; // 
      // #endregion
      public function Node() // 构造函数，设定默认天体数据
      {
         var _TextField:TextField = null; // 文本
         drawQuad = new Quad(2, 2, 16777215);
         super();
         var _Color:uint = uint(Globals.teamColors[0]);
         image = new Image(Root.assets.getTexture("planet01")); // 设定默认天体
         image.pivotX = image.pivotY = image.width * 0.5;
         image.scaleX = image.scaleY = 0.5;
         image.color = _Color;
         halo = new Image(Root.assets.getTexture("halo"));
         halo.pivotX = halo.pivotY = halo.width * 0.5;
         halo.scaleX = halo.scaleY = image.scaleY;
         halo.color = _Color;
         halo.alpha = 0.75;
         glow = new Image(Root.assets.getTexture("planet_shape"));
         glow.pivotX = glow.pivotY = glow.width * 0.5;
         glow.scaleX = glow.scaleY = image.scaleY;
         label = new TextField(60, 48, "00", "Downlink12", -1, Globals.teamColors[0]); // 默认兵力文本
         label.vAlign = label.hAlign = "center";
         label.pivotX = 30;
         label.pivotY = 24;
         nodeLinks = [];
         oppNodeLinks = [];
         barrierLinks = []; // 障碍链接数组
         ships = []; // 第一维储存的每个数组对应一个势力，第二维数组用于储存飞船的引用，一个值指代一个飞船，二维数组的长度表示该天体上该势力的飞船总数
         transitShips = [];
         aiTimers = [];
         warps = [];
         labels = []; // 储存战斗状态下各势力的兵力文本标签
         for (var i:int = 0; i < Globals.teamCount; i++) // 遍历每个势力
         {
            ships.push([]);
            transitShips.push(0);
            aiTimers.push(0);
            warps.push(false);
            _TextField = new TextField(60, 48, "00", "Downlink12", -1, Globals.teamColors[i]); // 创建文本对象
            _TextField.vAlign = _TextField.hAlign = "center"; // 设置垂直对齐和水平对齐为“中心”（starling插件的内容
            _TextField.pivotX = 30; // X坐标
            _TextField.pivotY = 24; // Y坐标
            _TextField.visible = false; // 默认不可见
            labels.push(_TextField); // 加入labels数组
         }
      }
      // #region 生成天体 移除天体
      /* 生成天体initNode(来源，X，Y，类型，大小，势力，轨道中心天体tag，轨道方向，轨道速度)
       类型：0星球，1传送门，2废稿，3障碍，4炮塔，5星核，6堡垒,7脉冲
       势力：0中立，1蓝，2红，3橙，4绿，5灰（32关），6黑
       轨道方向true为顺时针，false为逆时针
       轨道速度默认0.1 */
      public function initNode(_GameScene:GameScene, _x:Number, _y:Number, _type:int, _size:Number, _team:int, _OrbitNode:Node = null, _Clockwise:Boolean = true, _OrbitSpeed:Number = 0.1):void
      {
         var i:int = 0;
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         super.init(_GameScene);
         this.size = _size; // 输入大小
         this.type = _type; // 输入类型
         this.team = _team; // 输入势力
         captureTeam = _team; // 占据势力
         hp = 0; // 占领度
         aiValue = 0; // 
         if (_team > 0)
            hp = 100; // 设定非中立天体默认占领度为100
         buildTimer = 1; // 生产计时器
         popVal = 0; // 人口上限
         buildRate = 0; // 生产速度
         startVal = 0; // 初始人口
         attackTimer = 0; // 攻击计时器
         attackRate = 0; // 攻击间隔，<=0时无法攻击
         attackRange = 0; // 攻击范围
         triggerTimer = 0; // 
         winPulseTimer = 0; // 
         winTeam = -1; // 获胜队伍
         updateLabelSizes(); // 更新文本大小
         this.x = _x; // 输入X
         this.y = _y; // 输入Y
         image.visible = halo.visible = glow.visible = true; // 贴图设为可见
         glow.alpha = 0; // 光圈设为不透明
         image.x = halo.x = glow.x = label.x = this.x; // 为贴图输入X
         image.y = halo.y = glow.y = label.y = this.y; // 为贴图输入Y
         image.scaleX = image.scaleY = halo.scaleX = halo.scaleY = glow.scaleX = glow.scaleY = 1; // 设定贴图缩放（starling插件内容
         image.color = halo.color = label.color = Globals.teamColors[_team]; // 设定贴图颜色为势力颜色
         label.y += 50 * _size; // 计算文本Y坐标
         label.x += 30 * _size; // 计算文本X坐标
         barrierCostom = false; // 默认不为自定义障碍
         linked = false; // 
         glowing = false; // 默认无光效
         switch (_type) // 依类型修改天体参数
         {
            case 0: // 星球
               var _ImageID:String = (int(Math.random() * 16) + 1).toString();
               if (_ImageID.length == 1)
                  _ImageID = "0" + _ImageID; // 随机取一个星球贴图的编号
               image.texture = Root.assets.getTexture("planet" + _ImageID); // 更换星球贴图
               halo.texture = Root.assets.getTexture("halo"); // 更换光圈
               glow.texture = Root.assets.getTexture("planet_shape"); // 更换星球光效
               image.scaleX = image.scaleY = glow.scaleX = glow.scaleY = _size; // 设定贴图和背景缩放为大小（_size为大小参数
               popVal = 100 * _size; // 设定人口上限为 100*大小
               buildRate = _size * 2; // 设定生产速度为 2*大小
               startVal = popVal; // 设定初始人口为人口上限
               break;
            case 1: // 传送门
               image.texture = Root.assets.getTexture("warp");
               halo.texture = Root.assets.getTexture("warp_glow");
               glow.texture = Root.assets.getTexture("warp_shape");
               popVal = 0; // 不提供人口上限
               buildRate = 0; // 不产兵
               startVal = 100 * _size; // 提供100*大小的初始兵力
               break;
            case 2: // 废稿造船厂
               image.texture = Root.assets.getTexture("habitat");
               halo.texture = Root.assets.getTexture("halo"); // 原文为habitat_glow
               glow.texture = Root.assets.getTexture("planet_shape"); // 原文为habitat_shape
               popVal = 0; // 不提供人口上限
               buildRate = 8; // 产兵速度相当于400人口星球，与36关星核相同
               startVal = 100 * _size; // 提供100*大小的初始兵力
               break;
            case 3: // 障碍
               image.texture = Root.assets.getTexture("barrier");
               halo.texture = Root.assets.getTexture("barrier_glow");
               glow.texture = Root.assets.getTexture("barrier_shape");
               getBarrierLinks(); // 计算障碍链接参数
               popVal = 0;
               buildRate = 0;
               startVal = 0;
               break;
            case 4: // 炮塔
               image.texture = Root.assets.getTexture("tower");
               halo.texture = Root.assets.getTexture("tower_glow");
               glow.texture = Root.assets.getTexture("tower_shape");
               popVal = 0;
               buildRate = 0;
               startVal = 100 * _size;
               attackRate = 0.2; // 攻击间隔为0.2
               attackRange = 180; // 攻击半径为180
               break;
            case 5: // 星核，此处为白板天体
               image.texture = Root.assets.getTexture("dilator");
               halo.texture = Root.assets.getTexture("dilator_glow");
               glow.texture = Root.assets.getTexture("dilator_shape");
               popVal = 0;
               buildRate = 0;
               startVal = 0;
               break;
            case 6: // 太空堡垒
               image.texture = Root.assets.getTexture("starbase");
               halo.texture = Root.assets.getTexture("starbase_glow");
               glow.texture = Root.assets.getTexture("starbase_shape");
               popVal = 100;
               buildRate = 2;
               startVal = popVal;
               attackRate = 0.15; // 攻击间隔为0.15
               attackRange = 180; // 攻击范围为180
               break;
            case 7: // 脉冲炮
               image.texture = Root.assets.getTexture("pulsecannon");
               halo.texture = Root.assets.getTexture("tower_glow");
               glow.texture = Root.assets.getTexture("tower_shape");
               popVal = 0;
               buildRate = 0;
               startVal = 0;
               attackRate = 5;
               attackRange = 180;
         }
         labelDist = 180 * _size; // 计算文本圈大小
         lineDist = 150 * _size; // 计算选中圈大小
         if (_size < 0.5)
            touchDist = lineDist + (1 - _size * 2) * 50; // 计算传统操作模式下的天体选中圈
         else
            touchDist = lineDist;
         halo.readjustSize();
         halo.scaleY = halo.scaleX = 1; // 设定光圈缩放
         halo.pivotY = halo.pivotX = halo.width * 0.5;
         switch (_type) // 处理贴图大小
         {
            case 0: // 星球
               halo.scaleY = halo.scaleX = _size * 0.5;
               break;
            case 7: // 脉冲
               image.scaleX = image.scaleY = 0.8;
               break;
         }
         if (_OrbitNode) // 设定轨道，_OrbitNode：轨道中心天体
         {
            this.orbitNode = _OrbitNode; // 写入轨道中心
            _dx = this.x - _OrbitNode.x; // 计算横坐标之差
            _dy = this.y - _OrbitNode.y; // 计算纵坐标之差
            orbitDist = Math.sqrt(_dx * _dx + _dy * _dy); // 计算轨道半径
            orbitAngle = Math.atan2(_dy, _dx); // 计算轨道初始角度
            orbitSpeed = _OrbitSpeed; // _OrbitSpeed：轨道速度，这是新二代外加的参数，默认值为0.1
            if (!_Clockwise)
               orbitSpeed = -1 * _OrbitSpeed; // 逆时针轨道速度设为相反数
         }
         else
            this.orbitNode = null; // 没有轨道中心天体时无轨道
         _GameScene.nodeLayer.addChild(image); // 添加贴图的可视化对象
         if (halo.color == 0)
         {
            _GameScene.nodeGlowLayer2.addChild(halo);
            _GameScene.nodeGlowLayer2.addChild(glow);
         }
         else
         {
            _GameScene.nodeGlowLayer.addChild(halo);
            _GameScene.nodeGlowLayer.addChild(glow);
         }
         _GameScene.labelLayer.addChild(label); // 添加兵力文本的可视化对象
         for (i = 0; i < labels.length; i++) // 为数组中每个文本添加可视化对象
         {
            _GameScene.labelLayer.addChild(labels[i]);
         }
         for (i = 0; i < aiTimers.length; i++) // 重置计时器
         {
            aiTimers[i] = 0;
         }
         for (i = 0; i < transitShips.length; i++) // 
         {
            transitShips[i] = 0;
         }
      }

      public function initBoss(_GameScene:GameScene, _x:Number, _y:Number):void // 生成一个星核
      {
         var i:int = 0;
         super.init(_GameScene);
         this.size = 0.4;
         this.type = 5;
         this.team = 6;
         captureTeam = 6;
         hp = 100;
         aiValue = 0;
         buildTimer = 1;
         startVal = 0;
         attackTimer = 0;
         attackRate = 0;
         attackRange = 0;
         triggerTimer = 0;
         winPulseTimer = 0;
         winTeam = -1;
         updateLabelSizes();
         this.x = _x;
         this.y = _y;
         image.visible = halo.visible = glow.visible = true;
         image.x = halo.x = label.x = glow.x = this.x;
         image.y = halo.y = label.y = glow.y = this.y;
         image.scaleX = image.scaleY = halo.scaleX = halo.scaleY = glow.scaleX = glow.scaleY = 1;
         image.color = halo.color = glow.color = label.color = Globals.teamColors[team];
         label.y += 50 * size;
         label.x += 30 * size;
         lineDist = 150 * size;
         labelDist = 180 * size;
         orbitNode = null;
         linked = false;
         image.texture = Root.assets.getTexture("dilator");
         halo.texture = Root.assets.getTexture("dilator_glow");
         glow.texture = Root.assets.getTexture("dilator_shape");
         popVal = 0;
         buildRate = 0;
         startVal = 300;
         halo.readjustSize();
         halo.pivotX = halo.pivotY = halo.width * 0.5;
         _GameScene.nodeLayer.addChild(image);
         _GameScene.nodeGlowLayer2.addChild(halo);
         _GameScene.nodeGlowLayer2.addChild(glow);
         _GameScene.labelLayer.addChild(label);
         for (i = 0; i < labels.length; i++)
         {
            _GameScene.labelLayer.addChild(labels[i]);
         }
         for (i = 0; i < aiTimers.length; i++)
         {
            aiTimers[i] = 0;
         }
         for (i = 0; i < transitShips.length; i++)
         {
            transitShips[i] = 0;
         }
      }

      public function updateLabelSizes():void // 切换兵力文本大小
      {
         var i:int = 0;
         switch (Globals.textSize) // 读取文本大小设置
         {
            case 0: // 大小设置为0
               label.fontName = "Downlink10"; // 切换和平状态下的字体图
               label.fontSize = -1; // 默认大小
               for (i = 0; i < labels.length; i++) // 设定战斗状态下每个势力的文本
               {
                  labels[i].fontName = "Downlink10";
                  labels[i].fontSize = -1;
               }
               break;
            case 1: // 大小设置为1
               label.fontName = "Downlink12";
               label.fontSize = -1;
               for (i = 0; i < labels.length; i++)
               {
                  labels[i].fontName = "Downlink12";
                  labels[i].fontSize = -1;
               }
               break;
            case 2: // 大小设置为2
               label.fontName = "Downlink18";
               label.fontSize = -1;
               for (i = 0; i < labels.length; i++)
               {
                  labels[i].fontName = "Downlink18";
                  labels[i].fontSize = -1;
               }
               return;
         }
      }

      override public function deInit():void // 移除天体
      {
         var i:int = 0;
         game.nodeLayer.removeChild(image); // 移除贴图
         if (game.nodeGlowLayer.contains(halo))
         {
            game.nodeGlowLayer.removeChild(halo);
         }
         if (game.nodeGlowLayer2.contains(halo))
         {
            game.nodeGlowLayer2.removeChild(halo);
         }
         if (game.nodeGlowLayer.contains(glow))
         {
            game.nodeGlowLayer.removeChild(glow);
         }
         if (game.nodeGlowLayer2.contains(glow))
         {
            game.nodeGlowLayer2.removeChild(glow);
         }
         game.labelLayer.removeChild(label); // 移除和平时文本
         for (i = 0; i < labels.length; i++) // 循环移除和战斗时文本
         {
            game.labelLayer.removeChild(labels[i]); // 移除文本
         }
         for (i = 0; i < ships.length; i++) // 循环移除每个势力的飞船
         {
            ships[i].length = 0; // 移除遍历势力飞船
            transitShips[i] = 0;
         }
         // 移除其他参数
         barrierLinks.length = 0;
         nodeLinks.length = 0;
         oppNodeLinks.length = 0;
      }
      // #endregion
      // #region 更新
      override public function update(_dt:Number):void // 更新天体
      {
         var i:int = 0;
         var j:int = 0;
         var _Ship:Ship = null;
         updateOrbit(_dt); // 更新轨道
         updateImagePositions(); // 更新贴图位置
         label.visible = false; // 默认兵力文本设为不可见
         for (i = 0; i < labels.length; i++) // 战斗时文本也设为不可见
         {
            labels[i].visible = false;
         }
         for (i = 0; i < ships.length; i++) // 处理飞出天体的飞船
         {
            l = int(ships[i].length);
            for (j = 0; j < l; j++)
            {
               _Ship = ships[i][j];
               if (_Ship.state == 0)
                  continue; // 不处理驻留的飞船
               if (_Ship.state == 1)
               {
                  if (aiTimers[i] < 0.5)
                     aiTimers[i] = 0.5;
               }
               else
               {
                  ships[i][j] = ships[i][l - 1];
                  ships[i].pop();
                  l--;
                  j--;
               }
            }
         }
         if (glowing) // 处理势力改变时的光效，先亮度拉满
         {
            glow.alpha += _dt * 4; // 不透明度增加
            if (glow.alpha >= 1) // 亮度满时换贴图颜色
            {
               glow.alpha = 1;
               glowing = false;
               image.color = halo.color = Globals.teamColors[team];
               if (halo.color == 0)
                  game.nodeGlowLayer2.addChild(halo);
               else
                  game.nodeGlowLayer.addChild(halo);
            }
         }
         else if (glow.alpha > 0) // 再归零
         {
            glow.alpha -= _dt * 2; // 不透明度减少
            if (glow.alpha <= 0)
               glow.alpha = 0;
         }
         for (i = 0; i < warps.length; i++) // 有传送时播放传送门目的地特效
         {
            if (warps[i])
               showWarpArrive(i);
            warps[i] = false;
         }
         updateTimer(_dt); // 更新各种计时器
         updateAttack(_dt); // 更新天体攻击
         updateConflict(_dt); // 更新飞船攻击
         updateCapture(_dt); // 更新占领度
         updateBuild(_dt); // 更新飞船生产
      }

      public function updateOrbit(_dt:Number):void // 更新轨道
      {
         if (!orbitNode)
            return;
         orbitAngle += orbitSpeed * _dt; // 将轨道角度加上轨道速度*游戏速度
         if (orbitAngle > Math.PI * 2)
            orbitAngle -= Math.PI * 2; // 重置角度
         this.x = orbitNode.x + Math.cos(orbitAngle) * orbitDist; // 计算更新后的x坐标
         this.y = orbitNode.y + Math.sin(orbitAngle) * orbitDist; // 计算更新后的y坐标
      }

      public function updateImagePositions():void // 更新贴图位置
      {
         image.x = halo.x = glow.x = x;
         image.y = halo.y = glow.y = y;
         label.x = x + 30 * size;
         label.y = y + 50 * size;
      }

      public function updateTimer(_dt:Number):void // 更新计时器
      {
         for (var i:int = 0; i < aiTimers.length; i++) // 计算AI计时器
         {
            if (aiTimers[i] > 0)
               aiTimers[i] = Math.max(0, aiTimers[i] - _dt);
         }
         if (triggerTimer > 0)
            triggerTimer = Math.max(0, triggerTimer - _dt);
         if (winPulseTimer > 0)
         {
            winPulseTimer = Math.max(0, winPulseTimer - _dt);
            if (winPulseTimer == 0)
               changeTeam(winTeam);
         }
      }

      public function updateAttack(_dt:Number):void // 更新天体攻击
      {
         if (attackRate <= 0 || team == 0 && Globals.level != 31)
            return; // 排除32关以外的中立和无范围天体
         if (attackTimer > 0) // 更新计时器
         {
            attackTimer -= _dt;
            if (attackTimer > 0)
               return; // 计时器未归零时不执行攻击代码
         }
         var i:int = 0;
         var j:int = 0;
         var k:int = 0;
         var _Ship:Ship = null;
         var _ShipinRange:Array = null;
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         var _Node:Node = null;
         switch (type)
         {
            case 4: // 炮塔
            case 6: // 堡垒
               _ShipinRange = []; // 记录攻击范围内的飞船
               for each (_Ship in game.ships.active)
               {
                  if (_Ship.team == team || _Ship.state != 3)
                     continue; // 该飞船在飞行中且不为己方飞船时
                  _dx = _Ship.x - this.x; // 计算横坐标差
                  _dy = _Ship.y - this.y; // 计算纵坐标差
                  if (_dx > attackRange || _dx < -attackRange || _dy > attackRange || _dy < -attackRange)
                     continue; // 矩形判断，减少计算量
                  if (Math.sqrt(_dx * _dx + _dy * _dy) < attackRange)
                     _ShipinRange.push(_Ship); // 判断遍历飞船是否在攻击范围内并记录飞船
               }
               if (_ShipinRange.length != 0) // 范围内有飞船时
               {
                  _Ship = _ShipinRange[Math.floor(Math.random() * _ShipinRange.length)]; // roll一个飞船
                  _Ship.hp = 0; // 使其血量归零
                  _Ship.destroy(); // 摧毁飞船
                  game.addBeam(x, y, _Ship.x, _Ship.y, Globals.teamColors[team], type); // 播放攻击特效
                  GS.playLaser(this.x); // 播放攻击音效
                  attackTimer = attackRate; // 重置计时器
               }
               break;
            case 7: // 脉冲炮
               for each (_Node in game.nodes.active)
               {
                  if (_Node == this)
                     continue; // 排除自身
                  _dx = _Node.x - this.x;
                  _dy = _Node.y - this.y;
                  if (_dx > attackRange || _dx < -attackRange || _dy > attackRange || _dy < -attackRange)
                     continue; // 先做矩形判断减少计算量
                  if (Math.sqrt(_dx * _dx + _dy * _dy) > attackRange)
                     continue; // 再做精确距离计算
                  for (j = 0; j < Globals.teamCount; j++) // 遍历势力
                  {
                     _Ship = null;
                     k = 0;
                     while (k < 5 && _Node.ships[j].length > 0) // 挑5个飞船宰了
                     {
                        _Ship = _Node.ships[j][0];
                        if (_Ship.team != this.team && _Ship.state == 0)
                        {
                           _Ship.hp = 0;
                           _Ship.destroy();
                           _Node.ships[j].shift();
                           GS.playLaser(this.x); // 播放攻击音效
                        }
                        k++;
                     }
                  }
               }
               game.addDarkPulse(this, Globals.teamColors[this.team], 3, 25, 50, 0); // 播放特效
               attackTimer = attackRate; // 重置计时器
         }
      }

      public function updateConflict(_dt:Number):void // 更新飞船攻击
      {
         var i:int = 0;
         var j:int = 0;
         var _Ship:Ship = null;
         var _AttackArray:Array = null;
         var _ShipState0:int = 0;
         var _Attack:Number = NaN;
         var _DisAttack:Array = null;
         var _DisShip:Ship = null;
         var _ArcRatio:Number = NaN;
         var _ArcAngle:Number = NaN;
         var _LableAngle:Number = NaN;
         var _ShipTeam:Array = []; // 统计飞船势力
         var _ShipStat:int = 0; // 该天体上的总飞船数
         var _conflict:Boolean = false;
         for (i = 0; i < ships.length; i++) // 判断是否有战斗
         {
            if (ships[i].length > 0) // 该势力有飞船时执行
            {
               _ShipTeam.push(i); // 储存该势力
               _ShipStat += ships[i].length;
            }
            if (_ShipTeam.length > 1)
               _conflict = true; // 该天体存在两种以上势力飞船时设为战争状态
         }
         if (_conflict) // 在战斗状态下
         {
            _AttackArray = []; // 储存各飞船势力的消除量（能够消除的血量）
            for (i = 0; i < _ShipTeam.length; i++) // 计算各飞船势力的消除量
            {
               _ShipState0 = 0;
               for (j = 0; j < ships[_ShipTeam[i]].length; j++) // 统计该势力不飞走的飞船数
               {
                  if (ships[_ShipTeam[i]][j].state == 0)
                     _ShipState0++;
               }
               _Attack = _ShipState0 * 10 * _dt / (_ShipTeam.length - 1); // 计算该势力飞船的总攻击力，公式：10 * 帧时间 * 飞船数 /（飞船势力数-1）
               _AttackArray.push(_Attack); // 储存该势力飞船的总攻击力存
            }
            for (i = 0; i < _ShipTeam.length; i++) // 让所有飞船势力被攻击一次
            {
               for (j = 0; j < _AttackArray.length; j++) // 消除所有攻击势力的消除量
               {
                  if (i == j)
                     continue; // 不对自身执行
                  _Attack = Number(_AttackArray[j]); // 记录攻击势力的飞船消除量
                  _DisAttack = ships[_ShipTeam[i]]; // 指向被攻击势力的全部飞船（该天体上
                  while (_Attack > 0 && _DisAttack.length > 0) // 执行对消直到消除量归零或被攻击方没有飞船
                  {
                     _DisShip = _DisAttack[_DisAttack.length - 1]; // 被攻击飞船
                     if (_DisShip.hp > _Attack) // 血量大于攻击势力消除量时
                     {
                        // 对 消
                        _DisShip.hp -= _Attack;
                        break;
                     }
                     else // 血量小于消除量时
                     {
                        _Attack -= _DisShip.hp;
                        _DisShip.hp = 0;
                        _DisAttack.pop(); // 使天体不再承认该飞船
                        _DisShip.destroy(); // 摧毁飞船
                     }
                  }
               }
            }
            _ArcAngle = -Math.PI / 2 - Math.PI * ships[_ShipTeam[0]].length / _ShipStat;
            _LableAngle = Math.PI * 2 / _ShipTeam.length;
            for (i = 0; i < _ShipTeam.length; i++)
            {
               // 绘制战斗弧
               _ArcRatio = ships[_ShipTeam[i]].length / _ShipStat;
               drawCircle(x, y, Globals.teamColors[_ShipTeam[i]], lineDist, lineDist - 2, false, 1, _ArcRatio - 0.006366197723675814, _ArcAngle + 0.01);
               _ArcAngle += Math.PI * 2 * _ArcRatio;
               // 修改兵力文本
               labels[i].x = x + Math.cos(-Math.PI / 2 + i * _LableAngle) * labelDist;
               labels[i].y = y + Math.sin(-Math.PI / 2 + i * _LableAngle) * labelDist;
               labels[i].text = ships[_ShipTeam[i]].length.toString();
               labels[i].color = Globals.teamColors[_ShipTeam[i]];
               if (labels[i].color > 0)
                  labels[i].visible = true;
            }
         }
         conflict = _conflict;
      }

      public function updateCapture(_dt:Number):void // 更新占领度
      {
         if (conflict) // 战争状态下不执行该函数
         {
            capturing = false;
            return;
         }
         var _capturing:Boolean = false;
         var _captureTeam:int = 0;
         for (var i:int = 0; i < ships.length; i++) // 判定占据状态，计算占据势力
         {
            if (ships[i].length > 0)
            {
               if (i != team)
                  _capturing = true;
               _captureTeam = i;
               if (team == 0 && hp == 0)
                  captureTeam = _captureTeam;
               break;
            }
         }
         captureRate = ships[_captureTeam].length / (size * 100) * 10;
         switch (type) // 按天体计算占领速度加权
         {
            case 4: // 炮塔
            case 6: // 堡垒
               captureRate *= 0.5;
               break;
            case 5: // 星核
               captureRate *= 0.25;
               if (Globals.level > 31 && Globals.level < 35)
                  captureRate = 0; // 禁止 33 34 35 星核被占领
            default:
               break;
         }
         captureRate = Math.min(captureRate, 100); // 防止占领速度超过100
         if (captureTeam == _captureTeam)
            hp = Math.min(hp + captureRate * _dt, 100); // 占领条同占据势力则增加占领度
         else
            hp = Math.max(0, hp - captureRate * _dt); // 否则减少占领度
         if (team == 0 && hp == 100)
            changeTeam(captureTeam); // 中立天体占领度满时变为占领度势力
         if (team != 0 && hp == 0)
            changeTeam(0); // 非中立天体占领度空时变为中立
         if (_capturing || hp != 100 && captureTeam == _captureTeam && team != 0) // 占据状态下显示占领条
         {
            var _ArcAngle:Number = -Math.PI / 2 - Math.PI * (hp / 100);
            drawCircle(x, y, Globals.teamColors[captureTeam], lineDist, lineDist - 2, false, 0.1);
            drawCircle(x, y, Globals.teamColors[captureTeam], lineDist, lineDist - 2, false, 0.7, hp / 100, _ArcAngle);
         }
         if (_captureTeam != 0) // 非中立飞船占据显示兵力
         {
            label.text = ships[_captureTeam].length.toString();
            label.color = Globals.teamColors[_captureTeam];
            label.visible = (label.color > 0);
         }
         capturing = _capturing;
      }

      public function updateBuild(_dt:Number):void // 更新飞船生产
      {
         if (team == 0 || Globals.teamPops[team] >= Globals.teamCaps[team] || capturing || conflict && ships[team].length == 0)
            return; // 不产兵条件：中立/兵力到上限/被占据/战争状态没自己兵
         buildTimer -= buildRate * _dt; // 计算生产计时器
         if (buildTimer <= 0) // 计时结束时
         {
            buildTimer = 1; // 重置倒计时
            game.addShip(this, team); // 生产飞船
         }
      }
      // #endregion
      // #region 功能类函数
      public function changeTeam(_team:int):void // 改变势力
      {
         if (Globals.level == 35 && type == 5)
            return; // 36关星核不做处理
         var _Nodeteam:int = this.team;
         this.team = _team;
         glowing = true; // 激活光效
         glow.color = Globals.teamColors[_team]; // 设定光效颜色
         if (glow.color == 0)
            game.nodeGlowLayer2.addChild(glow); // 黑色光效区别处理
         else
            game.nodeGlowLayer.addChild(glow);
         game.addPulse(this, Globals.teamColors[_team], 0);
         GS.playCapture(this.x); // 播放占领音效
         if (_Nodeteam != 1 && _team == 1 && popVal > 0)
         {
            game.ui.popLabel2.color = 65280;
            game.ui.popLabel2.alpha = 1;
            game.ui.popLabel3.color = 3407667;
            game.ui.popLabel3.alpha = 1;
            game.ui.popLabel3.text = "+ " + popVal;
         }
         else if (_Nodeteam == 1 && _team != 1 && popVal > 0)
         {
            game.ui.popLabel2.color = 16711680;
            game.ui.popLabel2.alpha = 1;
            game.ui.popLabel3.color = 16724787;
            game.ui.popLabel3.alpha = 1;
            game.ui.popLabel3.text = "- " + popVal;
         }
      }

      public function changeShipsTeam(_team:int):void // 改变天体上所有飞船为_team势力
      {
         var _Ship:Ship = null;
         for (var i:int = 0; i < ships.length; i++)
         {
            if (i == _team)
               continue;
            while (ships[i].length > 0)
            {
               _Ship = ships[i].pop();
               _Ship.changeTeam(_team);
            }
         }
      }

      public function sendShips(_team:int, _Node:Node):void // 调动玩家飞船
      {
         if (_Node == this)
            return; // 防止调动飞船到自身
         var _Ship:Ship = null;
         var _warp:Boolean = false; // 是否为传送门
         var l:int = Math.ceil(ships[_team].length * game.ui.movePerc); // 计算调动的飞船数，Math.ceil()为至少调动1飞船判定
         for (var i:int = 0; i < l; i++) // 遍历每个需调动的飞船
         {
            _Ship = ships[_team][i];
            if (_Ship.state != 0)
               l = Math.min(l + 1, ships[_team].length); // 这里是为了允许快速操作，跳过将要起飞的飞船并将循环次数增加1
            else
               _warp = moveShip(_Ship, _team, _Node);
         }
         if (_warp)
            showWarpPulse(_team); // 展示传送门特效
      }

      public function sendAIShips(_team:int, _Node:Node, _ships:int):void // 调动AI飞船，使用飞船数量参数
      {
         if (_Node == this)
            return; // 防止调动飞船到自身
         var _Ship:Ship = null;
         var _warp:Boolean = false; // 是否为传送门
         var _ShipNumber:int = Math.min(_ships, ships[_team].length);
         for (var i:int = 0; i < _ShipNumber; i++) // 遍历每个需调动的飞船
         {
            _Ship = ships[_team][i];
            if (_Ship.state != 0)
               _ShipNumber = Math.min(_ShipNumber + 1, ships[_team].length); // 这里是为了允许快速操作，跳过将要起飞的飞船并将循环次数增加1
            else
               _warp = moveShip(_Ship, _team, _Node);
         }
         if (aiTimers[_team] < 1)
            aiTimers[_team] = 1;
         if (_warp)
            showWarpPulse(_team); // 播放传送门特效
      }

      private function moveShip(_Ship:Ship, _team:int, _Node:Node):Boolean // 控制飞船移动并返回是否为传送门
      {
         if (type == 1 && _team == this.team)
         {
            _Ship.warpTo(_Node);
            return true;
         }
         else
         {
            _Ship.moveTo(_Node);
            return false;
         }
      }
      // #endregion
      // #region AI工具及相关计算工具函数
      public function unloadShips():void // 将飞船分配到周围天体上，按距离依次，兵力用完为止（传 送 门 分 兵
      {
         var _Node:Node = null;
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         var _Distance:Number = NaN;
         var _Ship:Number = NaN;
         var _NodeArray:Array = game.nodes.active;
         var _targetNode:Array = [];
         var _ShipArray:Array = [];
         for each (_Node in game.nodes.active) // 按距离计算每个目标天体的价值
         {
            if (_Node != this && _Node.type != 3)
            {
               _dx = _Node.x - this.x;
               _dy = _Node.y - this.y;
               _Distance = Math.sqrt(_dx * _dx + _dy * _dy);
               _Node.aiValue = _Distance;
               _targetNode.push(_Node);
            }
         }
         _targetNode.sortOn("aiValue", 16); // 按价值从小到大对目标天体排序
         var _ShipCount:int = int(ships[team].length);
         for each (_Node in _targetNode)
         {
            _Ship = _Node.predictedOppStrength(team) * 2 - _Node.predictedTeamStrength(team) * 0.5; // 飞船数：非己方预测强度二倍减去己方预测强度一半
            if (_Ship < _Node.size * 200)
               _Ship = _Node.size * 200; // 不足200倍size时补齐到200倍size
            if (_Ship < _ShipCount) // 未达到总飞船数时，从总飞船数中抽去这部分飞船
            {
               _ShipCount -= _Ship;
               _ShipArray.push(_Ship);
            }
            else // 达到或超过总飞船数时
            {
               if (_ShipArray.length > 0)
                  _ShipArray[_ShipArray.length - 1] += _ShipCount; // 将剩余飞船加在最后一项
               else
                  _ShipArray.push(_ShipCount); // 没有项时添加这一项
               _ShipCount = 0; // 清空总飞船数
            }
            if (_ShipCount == 0)
               break; // 总飞船数耗尽时跳出循环
         }
         for (var i:int = 0; i < _ShipArray.length; i++)
         {
            sendAIShips(team, _targetNode[i], _ShipArray[i]);
         }
      }

      public function getTransitShips(_team:int):void // 统计飞向自身的飞船，包括指定势力的和移动距离大于50px的
      {
         for (var i:int = 0; i < transitShips.length; i++) // 重置数组
         {
            transitShips[i] = 0;
         }
         for each (var _Ship:Ship in game.ships.active)
         {
            if (!(_Ship.node == this && _Ship.state == 3))
               continue; // 飞船在飞行中且飞向自身
            if (_Ship.team == _team || _Ship.jumpDist > 50)
               transitShips[_Ship.team]++; // 为参数势力或移动距离大于50px
         }
      }

      public function oppStrength(_team:int):int // 返回飞船数最多的势力的总飞船数
      {
         var _Strength:int = 0;
         for (var i:int = 0; i < ships.length; i++)
         {
            if (i != _team)
            {
               if (ships[i].length > _Strength)
                  _Strength = int(ships[i].length);
            }
         }
         return _Strength;
      }

      public function predictedOppStrength(_team:int):int // 估算后续可能面对的非指定势力方最强飞船强度
      {
         var _Strength:Number = NaN;
         var _preStrength:int = 0;
         for (var i:int = 0; i < ships.length; i++)
         {
            if (i == _team)
               continue;
            _Strength = ships[i].length + transitShips[i];
            if (this.buildRate > 0 && this.team == i)
               _Strength *= 1.25;
            if (_Strength > _preStrength)
               _preStrength = _Strength;
         }
         return _preStrength;
      }

      public function teamStrength(_team:int):int // 返回该势力飞船数
      {
         return Number(ships[_team].length);
      }

      public function predictedTeamStrength(_team:int):int // 预测该势力可能的强度
      {
         var _Strength:Number = ships[_team].length + transitShips[_team];
         if (this.buildRate > 0 && _team == this.team)
            _Strength *= 1.25;
         return _Strength;
      }

      public function getOppLinks(_team:int):void // 计算可到达的有前往价值的天体
      {
         oppNodeLinks.length = 0;
         for each (var _Node:Node in nodeLinks)
         {
            if (_Node == this)
               continue;
            if (_Node.team == 0 || _Node.team != _team || _Node.predictedOppStrength(_team) > 0)
               oppNodeLinks.push(_Node);
         }
      }
      // #endregion
      // #region hardAI 特制工具函数
      public function getOppClose2Node(_team:int):Array // 返回将在 1.6 秒内着陆的[己方强度，最强方强度，最强方势力]
      {
         // 众所周知飞船起飞有约 0.8~1 秒制动时长，这里取 1.6 秒以确保飞船能安全撤离
         var _ships:Array = [];
         for (var i:int = 0; i < Globals.teamCount; i++)
         {
            _ships.push([]);
         }
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         var _Distance:Number = NaN;
         for each (var _Ship:Ship in game.ships.active)
         {
            if (_Ship.state == 0 || _Ship.node == this)
               continue; // 排除未起飞的和不飞向自身的飞船
            if (_Ship.warping)
               _ships[_Ship.team].push(_Ship); // 记录使用传送门的飞船
            else if (this.orbitNode) // 自身有轨道则需特殊处理
            {
               _dx = _Ship.x - this.x;
               _dy = _Ship.y - this.y;
               _Distance = Math.sqrt(_dx * _dx + _dy * _dy);
               if (_Distance / _Ship.jumpSpeed < 1.6)
                  _ships[_Ship.team].push(_Ship);
            }
            else if (_Ship.targetDist / _Ship.jumpSpeed < 1.6)
               _ships[_Ship.team].push(_Ship);
         }
         var _maxStrength:int = 0;
         var _maxTeam:int = 0;
         for (var i:int = 0; i < Globals.teamCount; i++)
         {
            if (_ships[i].length > _maxStrength)
            {
               _maxStrength = _ships[i].length;
               _maxTeam = i;
            }
         }
         return [_ships[_team].length, _maxStrength, _maxTeam];
      }
      // #endregion
      // #region 一般计算工具函数
      public function getNodeLinks(_team:int):void // 计算指定势力可到达的天体
      {
         nodeLinks.length = 0;
         for each (var _Node:Node in game.nodes.active)
         {
            if (_Node == this)
               continue;
            if (nodesBlocked(this, _Node) == null || this.type == 1 && this.team == _team)
               nodeLinks.push(_Node);
         }
      }

      public function nodesBlocked(_Node1:Node, _Node2:Node):Point // 判断路径是否被拦截并计算拦截点
      {
         var _bar1:Point = null;
         var _bar2:Point = null;
         var _Intersection:Point = null;
         var l:int = game.barrierLines.length;
         if (l == 0)
            return null;
         for (var i:int = 0; i < l; i++)
         {
            _bar1 = game.barrierLines[i][0];
            _bar2 = game.barrierLines[i][1];
            _Intersection = getIntersection(_Node1.x, _Node1.y, _Node2.x, _Node2.y, _bar1.x, _bar1.y, _bar2.x, _bar2.y); // 计算交点
            if (_Intersection)
               return _Intersection;
         }
         return null;
      }

      public function getBarrierLinks():void // 计算需连接的障碍
      {
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         for each (var _Node:Node in game.nodes.active)
         {
            if (_Node == this || _Node.type != 3)
               continue;
            if (_Node.x != this.x && _Node.y != this.y)
               continue; // 横纵坐标至少有一个相等
            _dx = _Node.x - this.x;
            _dy = _Node.y - this.y;
            if (Math.sqrt(_dx * _dx + _dy * _dy) < 180)
               barrierLinks.push(_Node);
         }
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
      // #region 特效与绘图
      public function bossAppear():void
      {
         image.visible = false;
         halo.visible = false;
         glow.visible = false;
         var _delay:Number = 0;
         var _rate:Number = 1;
         var _delayStep:Number = 0.5;
         var _angle:Number = 1.5707963267948966;
         var _maxSize:Number = 2;
         for (var i:int = 0; i < 24; i++)
         {
            game.addDarkPulse(this, 0, 1, _maxSize, _rate, _angle, _delay);
            _delay += _delayStep;
            _angle += 2.0943951023931953;
            game.addDarkPulse(this, 0, 1, _maxSize, _rate, _angle, _delay);
            _delay += _delayStep;
            _angle += 2.0943951023931953;
            game.addDarkPulse(this, 0, 1, _maxSize, _rate, _angle, _delay);
            _delay += _delayStep;
            _angle += 2.0943951023931953;
            _rate *= 1.15;
            _delayStep *= 0.75;
            _maxSize *= 0.9;
         }
         game.addDarkPulse(this, 0, 2, 2, 2, 0, _delay - 0.75);
         game.addDarkPulse(this, 0, 2, 2, 2, 0, _delay - 0.4);
         triggerTimer = _delay;
      }

      public function bossAppear2():void
      {
         image.visible = false;
         halo.visible = false;
         glow.visible = false;
         var _delay:Number = 0;
         var _rate:Number = 1;
         var _delayStep:Number = 0.5;
         var _angle:Number = 1.5707963267948966;
         var _maxSize:Number = 2;
         for (var i:int = 0; i < 18; i++)
         {
            game.addDarkPulse(this, 0, 1, _maxSize, _rate, _angle, _delay);
            _delay += _delayStep;
            _angle += 2.0943951023931953;
            game.addDarkPulse(this, 0, 1, _maxSize, _rate, _angle, _delay);
            _delay += _delayStep;
            _angle += 2.0943951023931953;
            game.addDarkPulse(this, 0, 1, _maxSize, _rate, _angle, _delay);
            _delay += _delayStep;
            _angle += 2.0943951023931953;
            _rate *= 1.3;
            _delayStep *= 0.6;
            _maxSize *= 0.8;
         }
         game.addDarkPulse(this, 0, 2, 2, 2, 0, _delay - 0.75);
         game.addDarkPulse(this, 0, 2, 2, 2, 0, _delay - 0.4);
         triggerTimer = _delay;
      }

      public function bossReady():void
      {
         image.visible = true;
         halo.visible = true;
         glow.visible = true;
         var _delay:Number = 0;
         var _angle:Number = 1.5707963267948966;
         var _maxSize:Number = 1;
         for (var i:int = 0; i < 3; i++)
         {
            game.addDarkPulse(this, 0, 0, _maxSize, 2, _angle, _delay);
            _delay += 0.05;
            _angle += 2.0943951023931953;
            game.addDarkPulse(this, 0, 0, _maxSize, 2, _angle, _delay);
            _delay += 0.05;
            _angle += 2.0943951023931953;
            game.addDarkPulse(this, 0, 0, _maxSize, 2, _angle, _delay);
            _delay += 0.05;
            _angle += 2.0943951023931953;
            _maxSize *= 1.5;
         }
         aiTimers[6] = 0.5;
      }

      public function bossReady2():void
      {
         image.visible = true;
         halo.visible = true;
         glow.visible = true;
         var _delay:Number = 0;
         var _angle:Number = 1.5707963267948966;
         var _maxSize:Number = 1;
         for (var i:int = 0; i < 2; i++)
         {
            game.addDarkPulse(this, 0, 0, _maxSize, 3, _angle, _delay);
            _delay += 0.04;
            _angle += 2.0943951023931953;
            game.addDarkPulse(this, 0, 0, _maxSize, 3, _angle, _delay);
            _delay += 0.04;
            _angle += 2.0943951023931953;
            game.addDarkPulse(this, 0, 0, _maxSize, 3, _angle, _delay);
            _delay += 0.04;
            _angle += 2.0943951023931953;
            _maxSize *= 1.5;
         }
         aiTimers[6] = 0.5;
      }

      public function bossDisappear():void
      {
         var _delay:Number = 0;
         var _rate:Number = 1;
         var _delayStep:Number = 0.5;
         var _angle:Number = 1.5707963267948966;
         var _maxSize:Number = 2;
         for (var i:int = 0; i < 12; i++)
         {
            game.addDarkPulse(this, 0, 1, _maxSize, _rate, _angle, _delay);
            _delay += _delayStep;
            _angle += 2.0943951023931953;
            game.addDarkPulse(this, 0, 1, _maxSize, _rate, _angle, _delay);
            _delay += _delayStep;
            _angle += 2.0943951023931953;
            game.addDarkPulse(this, 0, 1, _maxSize, _rate, _angle, _delay);
            _delay += _delayStep;
            _angle += 2.0943951023931953;
            _rate *= 1.5;
            _delayStep *= 0.5;
            _maxSize *= 0.7;
         }
         game.addDarkPulse(this, 0, 2, 2, 2, 0, _delay - 0.75);
         triggerTimer = _delay;
      }

      public function bossDisappear2():void
      {
         var _delay:Number = 0;
         var _rate:Number = 1;
         var _delayStep:Number = 0.5;
         var _angle:Number = 1.5707963267948966;
         var _maxSize:Number = 2;
         for (var i:int = 0; i < 6; i++)
         {
            game.addDarkPulse(this, 0, 1, _maxSize, _rate, _angle, _delay);
            _delay += _delayStep;
            _angle += 2.0943951023931953;
            game.addDarkPulse(this, 0, 1, _maxSize, _rate, _angle, _delay);
            _delay += _delayStep;
            _angle += 2.0943951023931953;
            game.addDarkPulse(this, 0, 1, _maxSize, _rate, _angle, _delay);
            _delay += _delayStep;
            _angle += 2.0943951023931953;
            _rate *= 1.65;
            _delayStep *= 0.5;
            _maxSize *= 0.7;
         }
         game.addDarkPulse(this, 0, 2, 2, 2, 0, _delay - 0.8);
         triggerTimer = _delay;
      }

      public function bossHide():void
      {
         image.visible = false;
         halo.visible = false;
         glow.visible = false;
         active = false;
      }

      public function showWarpPulse(_team:int):void // 传送门特效
      {
         var _delay:Number = 0;
         var _rate:Number = 2.6;
         var _delayStep:Number = 0.12;
         var _angle:Number = 1.5707963267948966;
         var _maxSize:Number = 1;
         for (var i:int = 0; i < 3; i++)
         {
            game.addDarkPulse(this, Globals.teamColors[_team], 1, _maxSize, _rate, _angle, _delay);
            _delay += _delayStep;
            _angle += 2.0943951023931953;
            game.addDarkPulse(this, Globals.teamColors[_team], 1, _maxSize, _rate, _angle, _delay);
            _delay += _delayStep;
            _angle += 2.0943951023931953;
            game.addDarkPulse(this, Globals.teamColors[_team], 1, _maxSize, _rate, _angle, _delay);
            _delay += _delayStep;
            _angle += 2.0943951023931953;
            _rate *= 1.1;
            _delayStep *= 0.9;
            _maxSize *= 0.8;
         }
         game.addDarkPulse(this, Globals.teamColors[_team], 2, 2, 2, 0);
         GS.playWarpCharge(this.x);
      }

      public function showWarpArrive(_team:int):void // 传送门目的地特效
      {
         var _rate:Number = 2;
         var _angle:Number = 1.5707963267948966;
         var _maxSize:Number = this.size * 2;
         game.addDarkPulse(this, Globals.teamColors[_team], 0, _maxSize, _rate, _angle, 0);
         _angle += 2.0943951023931953;
         game.addDarkPulse(this, Globals.teamColors[_team], 0, _maxSize, _rate, _angle, 0);
         _angle += 2.0943951023931953;
         game.addDarkPulse(this, Globals.teamColors[_team], 0, _maxSize, _rate, _angle, 0);
         _angle += 2.0943951023931953;
         _rate *= 1.1;
         _maxSize *= 1.2;
         game.addDarkPulse(this, Globals.teamColors[_team], 3, 18 * this.size, 28 * this.size, 0);
      }
      // 画圆
      public function drawCircle(_x:Number, _y:Number, _Color:uint, _R:Number, _voidR:Number = 0, mTinted:Boolean = false, _alpha:Number = 1, _quality2:Number = 1, _angle:Number = 0, _quality1:int = 64):void
      {
         if (!quadImage)
         {
            quadImage = new Image(Root.assets.getTexture("quad8x4"));
            quadImage.adjustVertices();
         }
         quadImage.color = _Color;
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
         var _angleStep:Number = Math.PI * 2 / _quality1;
         var _lineNumber:int = Math.ceil(_quality1 * _quality2);
         for (var i:int = 0; i < _lineNumber; i++)
         {
            quadImage.x = _x;
            quadImage.y = _y;
            if (i == _lineNumber - 1)
               _angleStep = Math.PI * 2 * _quality2 - _angleStep * (_lineNumber - 1);
            quadImage.setVertexPosition(0, Math.cos(_angle) * _R, Math.sin(_angle) * _R);
            quadImage.setVertexPosition(1, Math.cos(_angle + _angleStep) * _R, Math.sin(_angle + _angleStep) * _R);
            quadImage.setVertexPosition(2, Math.cos(_angle) * _voidR, Math.sin(_angle) * _voidR);
            quadImage.setVertexPosition(3, Math.cos(_angle + _angleStep) * _voidR, Math.sin(_angle + _angleStep) * _voidR);
            quadImage.vertexChanged();
            game.uiBatch.addImage(quadImage);
            _angle += _angleStep;
         }
      }
      // #endregion
   }
}
