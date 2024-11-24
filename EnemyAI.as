// 建议先通读一遍SimpleAI了解一下ai的基本运作方式
// 天体标准兵力特指100*size

package Game.Entity
{
   import Game.GameScene;
   import flash.geom.Point;

   public class EnemyAI extends GameEntity
   {

      public var team:int; // 势力
      public var actionDelay:Number; // 行动延迟
      public var planets:Array; // 天体
      public var targets:Array; // 目标天体
      public var senders:Array; // 出兵天体
      public var type:int; // 类型

      private var resultInside:Boolean; // 线是否在圆内
      private var resultIntersects:Boolean; // 线和圆是否相交
      private var resultEnter:Point; // 线和圆的第一个交点
      private var resultExit:Point; // 线和圆的第二个交点

      public var debugTrace:Array; // 调试输出栏

      public function EnemyAI() // 初始化ai参数
      {
         super();
         planets = [];
         targets = [];
         senders = [];
         debugTrace = [null, null, null, null, null];
      }

      public function initAI(_GameScene:GameScene, _team:int, _type:int = 1):void
      {
         this.init(_GameScene); // 这里没有init函数，所以调用的是父类GameEntity中的的init（只是将active设为true
         this.team = _team;
         this.type = _type;
         actionDelay = 1.5;
         if (_team == 6) // 黑色ai特有反应快
         {
            actionDelay = 0.25;
         }
      }

      override public function deInit():void
      {
      }

      override public function update(_dt:Number):void
      {
         actionDelay -= _dt;
         if (actionDelay > 0)
            return;
         if (actionDelay <= 0)
         {
            if (team == 6)
               actionDelay = Math.max(0, (3 - Globals.currentDifficulty) * (0.25 + Math.random() * 0.25));
            else if (Globals.level == 33 && (team == 3 || team == 4))
               actionDelay = Math.max(0, (3 - Globals.currentDifficulty) * (1.5 + Math.random() * 1.5));
            else
               actionDelay = Math.max(0, (3 - Globals.currentDifficulty) * (1.5 + Math.random() * 1.5));
         }
         switch (type) // 通过ai类型决定更新方式
         {
            case 0:
               updateSimple(_dt);
               break;
            case 1:
               updateSmart(_dt);
               break;
            case 2:
               updateDark(_dt);
               break;
            case 3:
               updateFinal(_dt);
               break;
            case 4:
               updateHard(_dt);
               break;
         }
      }
      // #region 原版ai
      public function updateSimple(_dt:Number):void
      {
         if (Globals.teamCaps[team] == 0 && Globals.teamPops[team] < 40)
            return; // 上限为0且总飞船数少于40时挂机
         var _Node:Node = null;
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         var _Distance:Number = NaN;
         var _Strength:Number = NaN;
         var _targetNode:Node = null;
         var _senderNode:Node = null;
         var _Ships:int = 0;
         var _NodeArray:Array = game.nodes.active;
         var _CenterX:Number = 0;
         var _CenterY:Number = 0;
         var _NodeCount:Number = 0;
         for each (_Node in _NodeArray) // 计算己方天体的几何中心
         {
            if (_Node.team != team)
               continue;
            _CenterX += _Node.x;
            _CenterY += _Node.y;
            _NodeCount += 1;
         }
         _CenterX /= _NodeCount;
         _CenterY /= _NodeCount;
         // #region 防御部分
         targets.length = 0;
         for each (_Node in _NodeArray) // 计算目标天体
         {
            _Node.getTransitShips(team);
            if (_Node.team != team && _Node.predictedTeamStrength(team) == 0)
               continue; // 条件1：为己方天体或有己方飞船（包括飞行中的
            if (_Node.predictedTeamStrength(team) > _Node.predictedOppStrength(team) * 2)
               continue; // 条件2：预测己方强度低于敌方两倍（即可能打不过敌方
            if (_Node.type == 3)
               continue; // 排除障碍
            _dx = _Node.x - _CenterX;
            _dy = _Node.y - _CenterY;
            _Distance = Math.sqrt(_dx * _dx + _dy * _dy); // 该天体到己方天体几何中心的距离
            _Strength = _Node.predictedTeamStrength(team) - _Node.predictedOppStrength(team); // 己方势力强度减去非己方势力强度
            _Node.aiValue = _Distance + _Strength; // 计算ai价值
            targets.push(_Node);
         }
         targets.sortOn("aiValue", 16); // 依ai价值从小到大对targets进行排序
         // trace("defend targets: " + targets.length);
         if (targets.length > 0) // 目标存在时，出兵防守
         {
            senders.length = 0;
            for each (_Node in _NodeArray) // 统计出兵天体
            {
               if (_Node.aiTimers[team] > 0 || _Node.teamStrength(team) == 0)
                  continue; // 基本条件：该天体己方ai倒计时为0且该天体己方强度不为0
               if (_Node.conflict && _Node.predictedTeamStrength(team) > _Node.predictedOppStrength(team))
                  continue; // 条件：没有战争或预测己方强度低于敌方
               _Node.aiStrength = -_Node.teamStrength(team); // 将该天体己方强度记为飞船数的相反数
               senders.push(_Node);
            }
            senders.sortOn("aiStrength", 16); // 依己方强度从小到大对出兵天体进行排序（由于强度记录的是相反数，此时看绝对值则是从大到小
            // trace("defend senders: " + senders.length);
            for each (_targetNode in targets) // 防守判定
            {
               for each (_senderNode in senders)
               {
                  if (_senderNode == _targetNode || nodesBlocked(_senderNode, _targetNode))
                     continue; // 基本条件：出兵天体和目标天体不为同一个，且二者之间没有被拦截
                  if (_senderNode.teamStrength(team) + _targetNode.predictedTeamStrength(team) <= _targetNode.predictedOppStrength(team))
                     continue; // 出兵条件：出兵天体的强度和目标天体的预测强度之和高于目标天体的预测敌方强度
                  // 飞船数：目标天体上预测敌方强度的二倍减去预测己方强度
                  _Ships = _targetNode.predictedOppStrength(team) * 2 - _targetNode.predictedTeamStrength(team);
                  _senderNode.sendAIShips(team, _targetNode, _Ships); // 发送飞船
                  // trace("defending!");
                  return; // 终止此次ai行动
               }
            }
         }
         // trace("can't defend, or nothing to defend");
         // #endregion
         // #region 进攻部分
         targets.length = 0;
         for each (_Node in _NodeArray) // 计算目标天体
         {
            if (_Node.team == team || _Node.type == 3 || _Node.type == 5)
               continue; // 基本条件：不为己方天体且不为障碍星核
            if (_Node.team == 0 && _Node.predictedOppStrength(team) == 0 && _Node.predictedTeamStrength(team) > _Node.size * 100)
               continue; // 目标条件：不为中立或预测有非己方飞船或己方势力飞船不足100倍size（基本兵力上限）
            _dx = _Node.x - _CenterX;
            _dy = _Node.y - _CenterY;
            _Distance = Math.sqrt(_dx * _dx + _dy * _dy) + Math.random() * 32; // 计算距离，带32px随机数误差
            _Strength = _Node.predictedOppStrength(team) - _Node.predictedTeamStrength(team); // 计算敌方强度：预测敌方强度减去预测己方强度
            _Node.aiValue = _Distance + _Strength; // 计算ai价值：距离加上敌方强度
            targets.push(_Node);
         }
         targets.sortOn("aiValue", 16); // 依ai价值从小到大对targets进行排序
         // trace("attack targets: " + targets.length);
         // trace("teamStr: " + targets[0].predictedTeamStrength(team));
         if (targets.length > 0) // 目标存在时，出兵进攻
         {
            senders.length = 0;
            for each (_Node in _NodeArray) // 统计出兵天体
            {
               if (_Node.aiTimers[team] > 0 || _Node.teamStrength(team) == 0)
                  continue; // 基本条件：该天体己方ai倒计时为0且该天体己方强度不为0
               if (_Node.conflict && _Node.predictedTeamStrength(team) > _Node.predictedOppStrength(team))
                  continue; // 出兵条件：天体上没有战争或预测敌方强度高于预测己方强度
               _Node.aiStrength = -_Node.teamStrength(team); // 将该天体己方强度记为飞船数的相反数
               senders.push(_Node);
            }
            senders.sortOn("aiStrength", 16); // 依己方强度从小到大对出兵天体进行排序（由于强度记录的是相反数，此时看绝对值则是从大到小
            // trace("attack senders: " + senders.length);
            for each (_targetNode in targets) // 进攻判定
            {
               for each (_senderNode in senders)
               {
                  if (_senderNode == _targetNode || nodesBlocked(_senderNode, _targetNode))
                     continue; // 基本条件：出兵天体和目标天体不为同一个，且二者之间没有被拦截
                  if (_senderNode.teamStrength(team) + _targetNode.predictedTeamStrength(team) <= _targetNode.predictedOppStrength(team))
                     continue; // 出兵条件：出兵天体的强度和目标天体的预测强度之和高于目标天体的预测敌方强度
                  // 计算出兵兵力，默认为预测目标天体上敌方兵力的二倍与己方兵力一半的差值
                  _Ships = _targetNode.predictedOppStrength(team) * 2 - _targetNode.predictedTeamStrength(team) * 0.5;
                  if (_targetNode.predictedOppStrength(team) * 2 - _targetNode.predictedTeamStrength(team) * 0.5 < _targetNode.size * 200)
                     _Ships = _targetNode.size * 200; // 若出兵兵力不足二倍目标天体标准兵力，则增加至二倍目标天体标准兵力
                  if (_senderNode.predictedOppStrength(team) > _senderNode.predictedTeamStrength(team))
                     _Ships = _senderNode.teamStrength(team); // 若预测出兵天体所受敌方威胁高于其强度，则派出全部兵力
                  _senderNode.sendAIShips(team, _targetNode, _Ships);
                  // trace("attacking!");
                  return;
               }
            }
         }
         // #endregion
      }

      public function updateSmart(_dt:Number):void
      {
         if (Globals.teamCaps[team] == 0 && Globals.teamPops[team] < 40)
            return; // 上限为0且总飞船数少于40时挂机
         var _Node:Node = null;
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         var _Distence:Number = NaN;
         var _Strength:Number = NaN;
         var _targetNode:Node = null;
         var _senderNode:Node = null;
         var _Ships:int = 0;
         var _towerAttack:Number = NaN;
         var _NodeArray:Array = game.nodes.active;
         var _CenterX:Number = 0;
         var _CenterY:Number = 0;
         var _NodeCount:Number = 0;
         for each (_Node in _NodeArray)
         {
            _Node.getNodeLinks(team);
            _Node.getTransitShips(team);
            if (_Node.team == team)
            {
               _CenterX += _Node.x;
               _CenterY += _Node.y;
               _NodeCount += 1;
            }
         }
         _CenterX /= _NodeCount;
         _CenterY /= _NodeCount;
         // #region 防御
         targets.length = 0;
         for each (_Node in _NodeArray) // 计算目标天体
         {
            if (team == 6 && _Node.type == 5 && _Node.teamStrength(team) > 0)
            {
               _Node.unloadShips();
               return;
            }
            if (team == 6 || _Node.type == 3 || _Node.type == 5)
               continue; // ？排除障碍星核
            if (_Node.team != team && _Node.predictedTeamStrength(team) == 0)
               continue; // 条件1：为己方天体或有己方飞船（包括飞行中的）
            if (_Node.predictedOppStrength(team) == 0)
               continue; // 条件2：有敌方
            if (_Node.predictedTeamStrength(team) > _Node.predictedOppStrength(team) * 2)
               continue; // 条件3：预测己方强度低于敌方两倍（即可能打不过敌方
            _dx = _Node.x - _CenterX;
            _dy = _Node.y - _CenterY;
            _Distence = Math.sqrt(_dx * _dx + _dy * _dy) + Math.random() * 32;
            _Strength = _Node.predictedTeamStrength(team) - _Node.predictedOppStrength(team);
            _Node.aiValue = _Distence + _Strength;
            targets.push(_Node);
         }
         targets.sortOn("aiValue", 16); // 依ai价值从小到大对targets进行排序
         if (targets.length > 0) // 目标天体存在时
         {
            senders.length = 0;
            for each (_Node in _NodeArray) // 计算出兵天体
            {
               if (_Node.aiTimers[team] > 0 || _Node.teamStrength(team) == 0)
                  continue; // 基本条件：该天体己方ai倒计时为0且该天体己方强度不为0
               if (_Node.team != team && _Node.predictedTeamStrength(team) > _Node.predictedOppStrength(team))
                  continue; // 条件：是己方天体或预测己方强度低于敌方
               if (_Node.predictedOppStrength(team) > 0 && _Node.predictedTeamStrength(team) > _Node.predictedOppStrength(team))
                  continue; // 条件：没有敌方或预测己方强度低于敌方
               _Node.aiStrength = -_Node.teamStrength(team); // 将该天体己方强度记为飞船数的相反数
               senders.push(_Node);
            }
            senders.sortOn("aiStrength", 16); // 依己方强度从小到大对出兵天体进行排序（由于强度记录的是相反数，此时看绝对值则是从大到小
            for each (_targetNode in targets)
            {
               for each (_senderNode in senders)
               {
                  if (_senderNode == _targetNode || _senderNode.nodeLinks.indexOf(_targetNode) == -1)
                     continue; // 基本条件：出兵天体和目标天体不为同一个，且二者之间没有被拦截
                  if (_senderNode.teamStrength(team) + _targetNode.predictedTeamStrength(team) < _targetNode.predictedOppStrength(team))
                     continue; // 出兵条件：出兵天体的强度和目标天体的预测强度之和高于目标天体的预测敌方强度
                  // 飞船数：目标天体上预测敌方强度的二倍减去预测己方强度
                  _Ships = _targetNode.predictedOppStrength(team) * 2 - _targetNode.predictedTeamStrength(team);
                  _towerAttack = getLengthInTowerRange(_senderNode, _targetNode) / 4.5; // 估算经过攻击天体损失的兵力（估损
                  _Ships += _towerAttack; // 为飞船数加上估损
                  if (_towerAttack > 0 && Globals.teamPops[team] < _towerAttack)
                     continue; // 条件：没有经过攻击天体或总兵力多于估损
                  if (_towerAttack > 0 && _senderNode.teamStrength(team) < _towerAttack * 0.5)
                     continue; // 条件：没有经过攻击天体或出兵天体强度高于估损的一半
                  // if (Globals.level == 34 && _targetNode.x == 912 && _targetNode.y == 544)
                  // trace("defending");
                  traceDebug("defending       " + _senderNode.x + "." + _senderNode.y + "  to  " + _targetNode.x + "." + _targetNode.y + "  ships:  " + _Ships);
                  _senderNode.sendAIShips(team, _targetNode, _Ships);
                  return;
               }
            }
         }
         // #endregion
         // #region 进攻
         targets.length = 0;
         for each (_Node in _NodeArray) // 计算目标天体
         {
            if (_Node.team == team || _Node.type == 3 || _Node.type == 5)
               continue; // 基本条件：不为己方天体和障碍星核
            if (_Node.predictedOppStrength(team) == 0 && _Node.predictedTeamStrength(team) > _Node.size * 150)
               continue; // 条件：排除己方强度足够且无敌方的天体
            _dx = _Node.x - _CenterX;
            _dy = _Node.y - _CenterY;
            _Distence = Math.sqrt(_dx * _dx + _dy * _dy) + Math.random() * 32;
            _Strength = _Node.predictedOppStrength(team) - _Node.predictedTeamStrength(team);
            _Node.aiValue = _Distence + _Strength;
            targets.push(_Node);
         }
         targets.sortOn("aiValue", 16);
         if (targets.length > 0)
         {
            senders.length = 0;
            for each (_Node in _NodeArray) // 计算出兵天体
            {
               if (_Node.aiTimers[team] > 0 || _Node.teamStrength(team) == 0)
                  continue; // 基本条件：该天体己方ai倒计时为0且该天体己方强度不为0
               if (_Node.predictedOppStrength(team) == 0 && _Node.capturing)
                  continue; // 条件：天体不被己方占据
               if (_Node.team != team && _Node.predictedTeamStrength(team) > _Node.predictedOppStrength(team))
                  continue; // 条件：是己方天体或预测己方强度低于敌方
               if (_Node.predictedOppStrength(team) > 0 && _Node.predictedTeamStrength(team) > _Node.predictedOppStrength(team))
                  continue; // 条件：没有敌方或预测己方强度低于敌方
               _Node.aiStrength = -_Node.teamStrength(team);
               senders.push(_Node);
            }
            senders.sortOn("aiStrength", 16);
            for each (_targetNode in targets)
            {
               for each (_senderNode in senders)
               {
                  if (_senderNode == _targetNode || _senderNode.nodeLinks.indexOf(_targetNode) == -1)
                     continue; // 基本条件：出兵天体和目标天体不为同一个，且二者之间没有被拦截
                  if (_senderNode.teamStrength(team) + _targetNode.predictedTeamStrength(team) <= _targetNode.predictedOppStrength(team))
                     continue; // 出兵条件：出兵天体和目标天体的己方综合强度高于目标天体的预测敌方强度
                  // 基本飞船数：目标天体上预测敌方强度的二倍减去预测己方强度一半
                  _Ships = _targetNode.predictedOppStrength(team) * 2 - _targetNode.predictedTeamStrength(team) * 0.5;
                  if (_senderNode.predictedOppStrength(team) > _senderNode.predictedTeamStrength(team))
                     _Ships = _senderNode.teamStrength(team); // 预测敌方强度大于己方时，派出全部飞船
                  if (_Ships < _targetNode.size * 200)
                     _Ships = _targetNode.size * 200; // 飞船数不应低于目标的二倍标准兵力
                  _towerAttack = getLengthInTowerRange(_senderNode, _targetNode) / 4.5; // 计算估损
                  _Ships += _towerAttack; // 为飞船数加上估损
                  if (_towerAttack > 0 && Globals.teamPops[team] < _towerAttack)
                     continue; // 总兵力不足估损时不派兵
                  if (Globals.level == 31)
                  {
                     if (_towerAttack > 0 && _senderNode.teamStrength(team) < _towerAttack * 2)
                        break; // 32关兵力不足估损二倍时换个目标
                  }
                  if (_towerAttack > 0 && _senderNode.teamStrength(team) < _towerAttack * 0.5)
                     continue; // 出兵天体强度低于估损的一半时不派兵
                  // if (Globals.level == 34 && _targetNode.x == 912 && _targetNode.y == 544)
                  // trace("attacking");
                  traceDebug("attacking       " + _senderNode.x + "." + _senderNode.y + "  to  " + _targetNode.x + "." + _targetNode.y + "  ships:  " + _Ships);
                  _senderNode.sendAIShips(team, _targetNode, _Ships);
                  return;
               }
            }
         }
         // #endregion
         // #region 聚兵
         senders.length = 0;
         for each (_Node in _NodeArray) // 计算出兵天体
         {
            if (_Node.team != team && _Node.predictedOppStrength(team) == 0 && _Node.teamStrength(team) > 0)
               continue; // 条件：没在锁星
            if (_Node.predictedOppStrength(team) > 0 && _Node.predictedTeamStrength(team) > _Node.predictedOppStrength(team))
               continue; // 条件：无敌方或打不过敌方
            _Node.aiStrength = -_Node.teamStrength(team) - _Node.oppStrength(team); // 计算己方和最强方的飞船总数
            _Node.aiValue = -_Node.oppNodeLinks.length; // 按路径数计算价值
            if (_Node.type == 1)
               _Node.aiValue--; // 炮塔权重提高
            senders.push(_Node);
         }
         senders.sortOn("aiStrength", 16); // 依飞船强度从小到大对出兵天体进行排序
         if (senders.length > 0)
         {
            targets.length = 0;
            for each (_Node in _NodeArray) // 计算目标天体
            {
               _Node.getOppLinks(team);
               if (_Node.type == 3 || _Node.type == 5)
                  continue; // 排除障碍星核
               _Node.aiValue = -_Node.oppNodeLinks.length; // 按路径数计算价值
               if (_Node.type == 1)
                  _Node.aiValue--; // 炮塔权重提高
               if (Globals.level == 31 && _Node.type == 6)
                  _Node.aiValue--; // 32关堡垒权重提高
               targets.push(_Node);
            }
            targets.sortOn("aiValue", 16);
            for each (_targetNode in targets)
            {
               for each (_senderNode in senders)
               {
                  if (_senderNode == _targetNode || _senderNode.nodeLinks.indexOf(_targetNode) == -1)
                     continue; // 基本条件：出兵天体和目标天体不为同一个，且二者之间没有被拦截
                  if (_targetNode.aiValue >= _senderNode.aiValue)
                     continue; // 条件：目标天体价值高于出兵天体价值
                  _Ships = _senderNode.teamStrength(team); // 派出全部飞船
                  _towerAttack = getLengthInTowerRange(_senderNode, _targetNode) / 4.5;
                  _Ships += _towerAttack; // 为飞船数加上估损
                  if (_towerAttack > 0 && Globals.teamPops[team] < _towerAttack)
                     continue; // 条件：总兵力不足估损时不派兵
                  if (Globals.level == 31)
                  {
                     if (!(_towerAttack > 0 && _senderNode.teamStrength(team) < _towerAttack * 3))
                        break; // 32关兵力不足估损三倍时换个目标
                  }
                  if (_towerAttack > 0 && _senderNode.teamStrength(team) < _towerAttack * 0.5)
                     continue; // 出兵天体强度低于估损的一半时不派兵
                  // if (Globals.level == 34 && _targetNode.x == 912 && _targetNode.y == 544)
                  // trace("repositioning");
                  if (_Ships != 0)
                     traceDebug("repositioning   " + _senderNode.x + "." + _senderNode.y + "  to  " + _targetNode.x + "." + _targetNode.y + "  ships:  " + _Ships);
                  _senderNode.sendAIShips(team, _targetNode, _Ships);
                  return;
               }
            }
         }
         // #endregion
      }

      public function updateDark(_dt:Number):void // 33~35黑色专用
      {
         if (Globals.teamCaps[team] == 0 && Globals.teamPops[team] < 40)
            return; // 上限为0且总飞船数少于40时挂机
         var _Node:Node = null;
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         var _Distence:Number = NaN;
         var _Strength:Number = NaN;
         var _targetNode:Node = null;
         var _senderNode:Node = null;
         var _Ships:Number = NaN;
         var _towerAttack:Number = NaN;
         var _NodeArray:Array = game.nodes.active;
         var _CenterX:Number = 0;
         var _CenterY:Number = 0;
         var _NodeCount:Number = 0;
         for each (_Node in _NodeArray) // 计算己方天体的几何中心
         {
            _Node.getNodeLinks(team);
            _Node.getTransitShips(team);
            if (_Node.team != team)
               continue;
            _CenterX += _Node.x;
            _CenterY += _Node.y;
            _NodeCount += 1;
         }
         _CenterX /= _NodeCount;
         _CenterY /= _NodeCount;
         for each (_Node in _NodeArray) // 分散星核兵力
         {
            if (team == 6 && _Node.type == 5 && _Node.teamStrength(team) > 0)
            {
               _Node.unloadShips();
               return;
            }
         }
         // #region 进攻
         targets.length = 0;
         for each (_Node in _NodeArray) // 计算目标天体
         {
            if (_Node.team == team || _Node.type == 3 || _Node.type == 5)
               continue; // 排除己方天体和星核障碍
            if (_Node.predictedOppStrength(team) == 0 && _Node.predictedTeamStrength(team) > _Node.size * 200)
               continue; // 条件1：天体未被己方以二倍标准兵力占据
            if (_Node.predictedOppStrength(team) > 0 && _Node.predictedTeamStrength(team) * 0.5 > _Node.predictedOppStrength(team))
               continue; // 条件2：敌方无兵力或高于己方兵力一半
            _dx = _Node.x - _CenterX;
            _dy = _Node.y - _CenterY;
            _Distence = Math.sqrt(_dx * _dx + _dy * _dy) + Math.random() * 32;
            _Strength = _Node.predictedOppStrength(team) - _Node.predictedTeamStrength(team);
            _Node.aiValue = _Distence + _Strength;
            targets.push(_Node);
         }
         targets.sortOn("aiValue", 16);
         if (targets.length > 0)
         {
            senders.length = 0;
            for each (_Node in _NodeArray) // 计算出兵天体
            {
               if (_Node.aiTimers[team] > 0 || _Node.teamStrength(team) == 0)
                  continue; // 基本条件：天体AI计时器为0且有己方飞船
               if (_Node.predictedOppStrength(team) == 0 && _Node.capturing)
                  continue; // 条件1：没在锁星
               if (_Node.team != team && _Node.predictedTeamStrength(team) > _Node.predictedOppStrength(team))
                  continue; // 条件2：为己方天体或己方兵力不足敌方
               if (_Node.predictedOppStrength(team) > 0 && _Node.predictedTeamStrength(team) > _Node.predictedOppStrength(team))
                  continue; // 条件3：敌方无兵力或己方兵力不足敌方
               _Node.aiStrength = -_Node.teamStrength(team);
               senders.push(_Node);
            }
            senders.sortOn("aiStrength", 16);
            for each (_targetNode in targets)
            {
               for each (_senderNode in senders)
               {
                  if (_senderNode == _targetNode || _senderNode.nodeLinks.indexOf(_targetNode) == -1)
                     continue; // 基本条件：出兵天体和目标天体不为同一个，且二者之间没有被拦截
                  if (_senderNode.teamStrength(team) + _targetNode.predictedTeamStrength(team) < _targetNode.predictedOppStrength(team))
                     continue; // 出兵条件：出兵天体的强度和目标天体的预测强度之和高于目标天体的预测敌方强度
                  // 飞船数：目标天体上预测敌方强度的二倍减去预测己方强度一半
                  _Ships = _targetNode.predictedOppStrength(team) * 2 - _targetNode.predictedTeamStrength(team) * 0.5;
                  if (_senderNode.predictedOppStrength(team) > _senderNode.predictedTeamStrength(team))
                     _Ships = _senderNode.teamStrength(team); // 预测出兵天体敌方兵力高于己方兵力时派出全部兵力
                  if (_Ships < _targetNode.size * 200)
                     _Ships = _targetNode.size * 200; // 兵力不足目标二倍标准兵力时派出目标二倍标准兵力
                  _towerAttack = getLengthInTowerRange(_senderNode, _targetNode) / 4.5;
                  _Ships += _towerAttack; // 加上估损
                  if (_towerAttack > 0 && Globals.teamPops[team] < _towerAttack)
                     continue; // 总兵力不足估损时不派兵
                  if (_towerAttack > 0 && _senderNode.teamStrength(team) < _towerAttack * 0.5)
                     continue; // 出兵天体的兵力不足估损的一半时不派兵
                  _senderNode.sendAIShips(team, _targetNode, _Ships);
                  return;
               }
            }
         }
         // #endregion
         // #region 聚兵
         senders.length = 0;
         for each (_Node in _NodeArray) // 计算出兵天体
         {
            if (_Node.team != team || _Node.conflict)
               continue; // 条件：为己方天体且无战争
            _Node.aiValue = -_Node.teamStrength(team);
            senders.push(_Node);
         }
         senders.sortOn("aiValue", 16);
         if (senders.length > 0)
         {
            targets.length = 0;
            for each (_Node in _NodeArray) // 计算目标天体
            {
               _Node.getOppLinks(team);
               if (_Node.type == 3 || _Node.type == 5)
                  continue; // 排除星核障碍
               _Node.aiValue = -_Node.oppNodeLinks.length; // 按路径数计算价值
               if (_Node.type == 1)
                  _Node.aiValue--; // 提高炮塔权重
               if (Globals.level == 31 && _Node.type == 6)
                  _Node.aiValue--; // 32关堡垒权重提高
               targets.push(_Node);
            }
            targets.sortOn("aiValue", 16);
            for each (_senderNode in senders)
            {
               for each (_targetNode in targets)
               {
                  if (_senderNode == _targetNode || _senderNode.nodeLinks.indexOf(_targetNode) == -1)
                     continue; // 基本条件：出兵天体和目标天体不为同一个，且二者之间没有被拦截
                  if (_targetNode.aiValue >= _senderNode.aiValue)
                     continue; // 条件：目标天体价值高于出兵天体价值
                  _Ships = _senderNode.teamStrength(team); // 派出该天体全部兵力
                  _towerAttack = getLengthInTowerRange(_senderNode, _targetNode) / 4.5;
                  _Ships += _towerAttack; // 加上估损
                  if (_towerAttack > 0 && Globals.teamPops[team] < _towerAttack)
                     continue; // 总兵力不足估损时不派兵
                  if (_towerAttack > 0 && _senderNode.teamStrength(team) < _towerAttack * 0.5)
                     continue; // 出兵天体的兵力不足估损的一半时不派兵
                  _senderNode.sendAIShips(team, _targetNode, _Ships);
                  return;
               }
            }
         }
         // #endregion
      }

      public function updateFinal(_dt:Number):void // 36黑色专用
      {
         var _Node:Node = null;
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         var _Distence:Number = NaN;
         var _Strength:Number = NaN;
         var _targetNode:Node = null;
         var _senderNode:Node = null;
         var _Ships:Number = NaN;
         var _towerAttack:Number = NaN;
         var _NodeArray:Array = game.nodes.active;
         var _CenterX:Number = 0;
         var _CenterY:Number = 0;
         var _NodeCount:Number = 0;
         for each (_Node in _NodeArray) // 计算己方天体几何中心
         {
            _Node.getNodeLinks(team);
            _Node.getTransitShips(team);
            if (_Node.team == team)
            {
               _CenterX += _Node.x;
               _CenterY += _Node.y;
               _NodeCount += 1;
            }
         }
         _CenterX /= _NodeCount;
         _CenterY /= _NodeCount;
         targets.length = 0; // 计算目标天体
         if (_NodeArray[0].predictedOppStrength(team) > 0)
            targets.push(_Node); // 星核受威胁时将其作为唯一目标
         else
         {
            for each (_Node in _NodeArray)
            {
               if (_Node.team == team || _Node.type == 3)
                  continue; // 排除己方天体和障碍
               if (_Node.team == 0 && _Node.predictedOppStrength(team) == 0 && _Node.predictedTeamStrength(team) >= _Node.size * 200)
                  continue; // 排除仅被己方以二倍标准兵力占据的中立天体
               if (_Node.predictedOppStrength(team) > 0 && _Node.predictedTeamStrength(team) * 0.5 > _Node.predictedOppStrength(team))
                  continue; // 排除有敌方但兵力不足己方一半的天体
               _dx = _Node.x - _CenterX;
               _dy = _Node.y - _CenterY;
               _Distence = Math.sqrt(_dx * _dx + _dy * _dy) + Math.random() * 32;
               _Strength = _Node.predictedOppStrength(team) - _Node.predictedTeamStrength(team);
               _Node.aiValue = _Distence + _Strength;
               targets.push(_Node);
            }
            targets.sortOn("aiValue", 16);
         }
         if (targets.length > 0)
         {
            senders.length = 0;
            for each (_Node in _NodeArray) // 计算出兵天体
            {
               if (_Node.aiTimers[team] > 0 || _Node.teamStrength(team) == 0)
                  continue; // 基本条件：天体AI计时器为0且有己方飞船
               if (_Node.predictedOppStrength(team) == 0 && _Node.capturing)
                  continue; // 排除被锁星的天体
               if (_Node.type == 5 && _Node.conflict)
                  continue; // 排除战争状态的星核
               if (_Node.team != team && _Node.predictedTeamStrength(team) > _Node.predictedOppStrength(team))
                  continue; // 排除敌方兵力低于己方的非己方天体
               if (_Node.predictedOppStrength(team) > 0 && _Node.predictedTeamStrength(team) > _Node.predictedOppStrength(team))
                  continue; // 排除有敌方但兵力低于己方的天体
               _Node.aiStrength = -_Node.teamStrength(team);
               senders.push(_Node);
            }
            senders.sortOn("aiStrength", 16);
            for each (_targetNode in targets)
            {
               for each (_senderNode in senders)
               {
                  if (_senderNode == _targetNode || _senderNode.nodeLinks.indexOf(_targetNode) == -1)
                     continue; // 基本条件：出兵天体和目标天体不为同一个，且二者之间没有被拦截
                  if (_senderNode.teamStrength(team) + _targetNode.predictedTeamStrength(team) < _targetNode.predictedOppStrength(team))
                     continue; // 出兵条件：出兵天体的强度和目标天体的预测强度之和高于目标天体的预测敌方强度
                  // 飞船数：目标天体上预测敌方强度的二倍减去预测己方强度一半
                  _Ships = _targetNode.predictedOppStrength(team) * 2 - _targetNode.predictedTeamStrength(team) * 0.5;
                  if (_senderNode.predictedOppStrength(team) > _senderNode.predictedTeamStrength(team))
                     _Ships = _senderNode.teamStrength(team); // 预测出兵天体敌方兵力高于己方兵力时派出全部兵力
                  if (_Ships < _targetNode.size * 200)
                     _Ships = _targetNode.size * 200; // 兵力不足目标二倍标准兵力时派出目标二倍标准兵力
                  _towerAttack = getLengthInTowerRange(_senderNode, _targetNode) / 4.5;
                  _Ships += _towerAttack; // 加上估损
                  if (_towerAttack > 0 && Globals.teamPops[team] < _towerAttack)
                     continue; // 总兵力不足估损时不派兵
                  if (_towerAttack > 0 && _senderNode.teamStrength(team) < _towerAttack * 0.5)
                     continue; // 出兵天体的兵力不足估损的一半时不派兵
                  if (_senderNode.type == 5)
                     _senderNode.sendAIShips(team, _targetNode, _senderNode.teamStrength(team) - 150); // 星核特殊出兵机制
                  else
                     _senderNode.sendAIShips(team, _targetNode, _Ships);
                  return;
               }
            }
         }
      }
      // #endregion
      // #region 改版AI
      public function updateHard(_dt:Number):void
      {
         attackV1(_dt);
         if (team == 6 && game.nodes.active[0].type == 5)
            blackDefend(_dt);
      }

      public function attackV1(_dt:Number):void
      {
         var _Node:Node = null;
         var _Distance:Number = NaN;
         senders.length = 0;
         for each (_Node in game.nodes.active) // 计算出兵天体
         {
            if (!senderCheckBasic(_Node))
               continue;
            if (_Node.hard_oppAllStrength(team) != 0 || _Node.conflict) // (预)战争状态
            {
               if (_Node.hard_teamStrength(team) * 0.6 > _Node.hard_oppAllStrength(team))
               {
                  if (_Node.team != team && _Node.hard_teamStrength(team) < _Node.size * 200)
                     continue; // 保留占据兵力
                  senders.push(_Node); // 己方过强时出兵（损失不到五分之一）
                  _Node.senderType = "overflow"; // 类型：兵力溢出
               }
               else if (_Node.hard_AllStrength(team) < _Node.hard_oppAllStrength(team))
               {
                  if (!_Node.hard_retreatCheck(team))
                     continue; // 战术撤退时机检测
                  senders.push(_Node); // 己方过弱时出兵
                  _Node.senderType = "retreat"; // 类型：战术撤退
               }
               continue;
            }
            if (_Node.capturing)
            {
               if (_Node.team == 0 && (100 - _Node.hp) / _Node.captureRate < 0.5 && _Node.type != 1)
               {
                  senders.push(_Node); // 提前出兵
                  _Node.senderType = "attack"; // 类型：正常出兵
               }
               continue;
            }
            senders.push(_Node);
            _Node.senderType = "attackcom"; // 类型：正常出兵
         }
         if (senders.length == 0)
            return;
         targets.length = 0;
         for each (_Node in game.nodes.active) // 计算目标天体
         {
            if (!targetCheckBasic(_Node))
               continue;
            if (_Node.hard_oppAllStrength(team) != 0) // (预)战争状态
            {
               if (_Node.hard_teamStrength(team) * 0.866 < _Node.hard_oppAllStrength(team))
               {
                  targets.push(_Node); // 己方强度不足时作为目标（损失超过一半）
                  _Node.targetType = "lack"; // 类型：兵力不足
               }
               continue;
            }
            if (_Node.team == 0 && _Node.capturing && _Node.captureTeam == team && (100 - _Node.hp) / _Node.captureRate < _Node.aiValue / 50)
               continue; // 不向快占完的天体派兵
            if (_Node.team == team && _Node.type != 1)
               continue; // 除传送门不向己方天体派兵
            targets.push(_Node);
            _Node.targetType = "attack"; // 类型：正常目标
         }
         if (targets.length == 0)
            return;
         for each (var _senderNode:Node in senders) // 出兵
         {
            for each (var _targetNode:Node in targets) // 先排序
            {
               _Distance = calcDistence(_senderNode, _targetNode) + Math.random() * 32;
               _targetNode.aiValue = _Distance * 0.8 + _targetNode.hard_oppAllStrength(team);
               if (_targetNode.attackRate != 0)
                  _targetNode.aiValue += getTowerAIValue();
               if (_targetNode.type == 6)
                  _targetNode.aiValue -= Globals.teamCaps[0];
               if (_targetNode.type == 1)
                  _targetNode.aiValue += getWarpAIValue();
               var _targetClose:Node = breadthFirstSearch(_senderNode, _targetNode);
               if (!_targetClose)
                  continue;
               var _towerAttack:Number = hard_getTowerAttack(_senderNode, _targetClose);
               _targetNode.aiValue += _towerAttack * 4; // 估损权重
            }
            targets.sortOn("aiValue", 16);
            for each (var _targetNode:Node in targets) // 再派兵
            {
               var _targetClose:Node = breadthFirstSearch(_senderNode, _targetNode);
               if (!_targetClose)
                  continue;
               if (_targetClose.type == 1 && _senderNode.type == 1 && _senderNode.team == team)
                  continue; // 避免传送门之间反复横跳
               var _Ships:Number = _senderNode.hard_teamStrength(team);
               if (_senderNode.senderType == "overflow")
               {
                  if (_senderNode.team != team)
                     _Ships -= _senderNode.size * 200; // 尝试占领时减少派兵数量
                  _Ships -= Math.floor(_senderNode.hard_oppAllStrength(team) * 1.667); // 兵力溢出时减少派兵数量
               }
               if (_targetNode.targetType == "lack")
               {
                  if (_targetNode.team == team)
                     _Ships = Math.min(_Ships, Math.floor(_targetNode.hard_oppAllStrength(team) * 1.2 - _targetNode.hard_AllStrength(team)) + 4); // 目标兵力不足时防止派兵过度
                  else if (team != 6)
                     _Ships = Math.min(_Ships, Math.floor(_targetNode.hard_oppAllStrength(team) * 1.6 - _targetNode.hard_AllStrength(team))); // 目标兵力不足时防止派兵过度
                  else
                     _Ships = Math.min(_Ships, Math.floor(_targetNode.hard_oppAllStrength(team) * 2.4 - _targetNode.hard_AllStrength(team)) + 4); // 加强黑色分兵
               }
               _Ships = Math.max(_Ships, ((hard_distance(_senderNode, _targetNode) * _targetNode.buildRate / 50) * 1.2 + 3));
               var _towerAttack:Number = hard_getTowerAttack(_senderNode, _targetClose);
               if (_towerAttack > 0 && _Ships < _towerAttack + 30)
                  continue; // 派出的兵力不超估损30兵时不派兵
               if (_Ships - _towerAttack < _targetNode.hard_oppAllStrength(team) - _targetNode.hard_teamStrength(team))
                  continue; // 己方兵力不足敌方时不派兵
               _senderNode.sendAIShips(team, _targetClose, _Ships);
               traceDebug("attackV1: " + _senderNode.senderType + " " + _senderNode.tag + " -> " + _targetNode.tag + " " + _targetNode.targetType + " ships: " + _Ships + " guessDieShips: " + _towerAttack);
               return;
            }
         }
      }

      public function blackDefend(_dt:Number):void // 回防
      {
         var _boss:Node = game.nodes.active[0];
         if (_boss.conflict || _boss.capturing)
         {
            for each (var _Node:Node in game.nodes.active)
            {
               if (_boss.hard_AllStrength(team) * 0.5 < _boss.hard_oppAllStrength(team))
                  _Node.sendAIShips(team, _boss, _Node.hard_teamStrength(team)); // 回防
            }
         }
      }

      public function senderCheckBasic(_Node:Node):Boolean // 判断能否出兵
      {
         if (_Node.hard_teamStrength(team) == 0)
            return false; // 无己方飞船不出兵
         return true;
      }

      public function targetCheckBasic(_Node:Node):Boolean // 判断能否作为目标天体
      {
         if (_Node.type == 3 || _Node.type == 5)
            return false;
         return true;
      }

      public function moveCheckBasic(_senderNode:Node, _targetNode:Node):Boolean // 移动判断
      {
         if (_senderNode == _targetNode)
            return false;
         if (_senderNode.type == 1 && _senderNode.team == team)
            return true;
         else
         {
            _senderNode.getNodeLinks(team);
            if (_senderNode.nodeLinks.indexOf(_targetNode) != -1)
               return true;
         }
         return false;
      }

      public function getTowerAIValue():Number // 计算攻击天体价值
      {
         var _capValue:Number = 0;
         for (var i:int = 1; i < Globals.teamCaps.length; i++)
         {
            _capValue += Globals.teamCaps[i];
         }
         return (Globals.teamCaps[0] - _capValue);
      }

      public function getWarpAIValue():Number // 计算传送价值
      {
         var _warpValue:Number = 0;
         for each (var _Node:Node in game.nodes.active)
         {
            _warpValue += _Node.popVal;
            if (_Node.team != 0 && _Node.team != team)
               _warpValue -= _Node.attackRange * 3.5;
         }
         return _warpValue;
      }

      public function breadthFirstSearch(_startNode:Node, _targetNode:Node):Node // 广度优先搜索，寻路算法
      {
         clearbreadthFirstSearch();
         if (_startNode == _targetNode)
            return null;
         if (moveCheckBasic(_startNode, _targetNode))
            return _targetNode;
         var _queue:Array = new Array();
         _queue.push(_startNode);
         var _visited:Array = new Array();
         _visited.push(_startNode);
         while (_queue.length > 0)
         {
            var _current:Node = _queue.shift();
            _current.getNodeLinks(team);
            for each (var _next:Node in _current.nodeLinks)
            {
               if (_visited.indexOf(_next) != -1)
                  continue;
               if (moveCheckBasic(_current, _next))
               {
                  _queue.push(_next);
                  _visited.push(_next);
                  _next.breadthFirstSearchNode = _current;
               }
            }
            if (_visited.indexOf(_targetNode) != -1)
            {
               while (_current.breadthFirstSearchNode != null)
               {
                  if (_current.breadthFirstSearchNode == _startNode)
                     return _current;
                  _current = _current.breadthFirstSearchNode;
               }
            }
         }
         return null;
      }

      public function calcDistence(_startNode:Node, _targetNode:Node):Number // 计算寻路距离
      {
         clearbreadthFirstSearch();
         if (_startNode == _targetNode)
            return 9999;
         if (moveCheckBasic(_startNode, _targetNode))
            return hard_distance(_startNode, _targetNode);
         var _distance:Number = 0;
         var _queue:Array = new Array();
         _queue.push(_startNode);
         var _visited:Array = new Array();
         _visited.push(_startNode);
         while (_queue.length > 0)
         {
            var _current:Node = _queue.shift();
            _current.getNodeLinks(team);
            for each (var _next:Node in _current.nodeLinks)
            {
               if (_visited.indexOf(_next) != -1)
                  continue;
               if (moveCheckBasic(_current, _next))
               {
                  _queue.push(_next);
                  _visited.push(_next);
                  _next.breadthFirstSearchNode = _current;
               }
            }
            if (_visited.indexOf(_targetNode) != -1)
            {
               _distance += hard_distance(_current, _targetNode);
               while (_current.breadthFirstSearchNode != null)
               {
                  _distance += hard_distance(_current, _current.breadthFirstSearchNode);
                  if (_current.breadthFirstSearchNode == _startNode)
                     return _distance;
                  _current = _current.breadthFirstSearchNode;
               }
            }
         }
         return 9999;
      }

      public function clearbreadthFirstSearch():void // 清除广度优先搜索父节点
      {
         for each (var _Node:Node in game.nodes.active)
         {
            _Node.breadthFirstSearchNode = null;
         }
      }

      public function hard_getTowerAttack(_Node1:Node, _Node2:Node):Number // 高精度估损
      {
         var _Node:Node = null;
         var _start:Point = null;
         var _end:Point = null;
         var _current:Point = null;
         var _Length:Number = 0;
         var _towerAttack:Number = 0;
         if (_Node1.type == 1 && _Node1.team == team)
            return 0; // 对传送门不执行该函数
         for each (var _Node:Node in game.nodes.active)
         {
            _Length = 0;
            if (_Node.team == 0 || _Node.team == team)
               continue;
            if (_Node.type == 4 || _Node.type == 6)
            {
               _start = new Point(_Node1.x, _Node1.y);
               _end = new Point(_Node2.x, _Node2.y);
               _current = new Point(_Node.x, _Node.y);
               lineIntersectCircle(_start, _end, _current, _Node.attackRange);
               if (resultIntersects)
               {
                  if (resultEnter && resultExit)
                     _Length += Point.distance(resultEnter, resultExit);
                  else if (resultEnter && !resultExit)
                     _Length += Point.distance(resultEnter, _end);
                  else if (!resultEnter && resultExit)
                     _Length += Point.distance(_start, resultExit);
                  else
                     _Length += Point.distance(_start, _end);
               }
               else if (resultInside)
                  _Length += Point.distance(_start, _end);
               if (_Node.type == 4)
                  _towerAttack += 0.1 * _Length;
               else if (_Node.type == 6)
                  _towerAttack += 0.133333333 * _Length;
            }
         }
         return Math.floor(_towerAttack);
      }

      public function hard_distance(_Node1:Node, _Node2:Node):Number // 计算天体距离
      {
         var _dx:Number = _Node2.x - _Node1.x;
         var _dy:Number = _Node2.y - _Node1.y;
         return Math.sqrt(_dx * _dx + _dy * _dy);
      }
      // #endregion
      // #region 计算工具
      // 判断路径是否被拦截并计算拦截点
      public function nodesBlocked(_Node1:Node, _Node2:Node):Point
      {
         if (_Node1.type == 1)
            return null; // 对传送门不执行该函数
         var _bar1:Point = null;
         var _bar2:Point = null;
         var _Intersection:Point = null;
         var i:int = 0;
         while (i < int(game.barrierLines.length))
         {
            _bar1 = game.barrierLines[i][0];
            _bar2 = game.barrierLines[i][1];
            _Intersection = getIntersection(_Node1.x, _Node1.y, _Node2.x, _Node2.y, _bar1.x, _bar1.y, _bar2.x, _bar2.y);
            if (_Intersection)
               return _Intersection;
            i++;
         }
         return null;
      }
      // 计算两条线段的交点
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
      // 返回两天体间经过的炮塔射程距离
      public function getLengthInTowerRange(_Node1:Node, _Node2:Node):Number
      {
         var _Node:Node = null;
         var _start:Point = null;
         var _end:Point = null;
         var _current:Point = null;
         var _Length:Number = 0;
         for each (var _Node:Node in game.nodes.active)
         {
            if (_Node.team == 0 || _Node.team == team)
               continue;
            if (_Node.type == 4 || _Node.type == 6)
            {
               _start = new Point(_Node1.x, _Node1.y);
               _end = new Point(_Node2.x, _Node2.y);
               _current = new Point(_Node.x, _Node.y);
               lineIntersectCircle(_start, _end, _current, _Node.attackRange);
               if (resultIntersects)
               {
                  if (resultEnter && resultExit)
                     _Length += Point.distance(resultEnter, resultExit);
                  else if (resultEnter && !resultExit)
                     _Length += Point.distance(resultEnter, _end);
                  else if (!resultEnter && resultExit)
                     _Length += Point.distance(_start, resultExit);
                  else
                     _Length += Point.distance(_start, _end);
               }
               else if (resultInside)
                  _Length += Point.distance(_start, _end);
            }
         }
         return _Length;
      }

      public function lineIntersectCircle(_pointA:Point, _pointB:Point, _circleCenter:Point, _circleRadius:Number = 1):void // 判断线与圆的关系并返回交点
      {
         var _discriminant:Number = NaN;
         var _intersectionParam1:Number = NaN;
         var _intersectionParam2:Number = NaN;
         resultInside = false;
         resultIntersects = false;
         resultEnter = null;
         resultExit = null;
         var _lineSegmentLengthSquared:Number = (_pointB.x - _pointA.x) * (_pointB.x - _pointA.x) + (_pointB.y - _pointA.y) * (_pointB.y - _pointA.y);
         var _lineConstant:Number = 2 * ((_pointB.x - _pointA.x) * (_pointA.x - _circleCenter.x) + (_pointB.y - _pointA.y) * (_pointA.y - _circleCenter.y));
         var _circleConstant:Number = _circleCenter.x * _circleCenter.x + _circleCenter.y * _circleCenter.y + _pointA.x * _pointA.x + _pointA.y * _pointA.y - 2 * (_circleCenter.x * _pointA.x + _circleCenter.y * _pointA.y) - _circleRadius * _circleRadius;
         if (_lineConstant * _lineConstant - 4 * _lineSegmentLengthSquared * _circleConstant <= 0)
            resultInside = false;
         else
         {
            _discriminant = Math.sqrt(_lineConstant * _lineConstant - 4 * _lineSegmentLengthSquared * _circleConstant);
            _intersectionParam1 = (-_lineConstant + _discriminant) / (2 * _lineSegmentLengthSquared);
            _intersectionParam2 = (-_lineConstant - _discriminant) / (2 * _lineSegmentLengthSquared);
            if ((_intersectionParam1 < 0 || _intersectionParam1 > 1) && (_intersectionParam2 < 0 || _intersectionParam2 > 1))
            {
               if (_intersectionParam1 < 0 && _intersectionParam2 < 0 || _intersectionParam1 > 1 && _intersectionParam2 > 1)
                  resultInside = false;
               else
                  resultInside = true;
            }
            else
            {
               if (0 <= _intersectionParam2 && _intersectionParam2 <= 1)
                  resultEnter = Point.interpolate(_pointA, _pointB, 1 - _intersectionParam2);
               if (0 <= _intersectionParam1 && _intersectionParam1 <= 1)
                  resultExit = Point.interpolate(_pointA, _pointB, 1 - _intersectionParam1);
               resultIntersects = true;
            }
         }
      }
      // #endregion
      // #region 调试工具
      public function traceDebug(_text:String):void
      {
         debugTrace.unshift(_text);
         debugTrace.pop();
      }
      // #endregion
   }
}
