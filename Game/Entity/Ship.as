package Game.Entity
{
   import Game.GameScene;
   import starling.display.Image;

   public class Ship extends GameEntity
   {
      // #region 类变量
      public var x:Number; // 坐标x
      public var y:Number; // 坐标y
      public var tx:Number; // 坐标x的偏移量
      public var ty:Number; // 坐标y的偏移量
      public var node:Node; // 所属天体
      public var team:int; // 势力
      public var image:Image; // 贴图
      public var trail:Image; // 拖尾
      public var pulse:Image; // 光圈
      public var orbitDist:Number; // 绕天体轨道大小
      public var orbitAngle:Number; // 绕天体轨道角度
      public var orbitSpeed:Number; // 绕天体旋转速度
      public var jumpSpeed:Number; // 移动速度
      public var chargeRate:Number; // 制动速度
      public var jumpDist:Number; // 本次飞行走过的距离
      public var jumpAngle:Number; // 移动方向
      public var trailLength:Number; // 拖尾长度
      public var hp:Number; // 血量
      public var warping:Boolean; // 是否在传送
      public var foreground:Boolean; // 决定与天体贴图的图层关系
      public var state:int; // 状态数
      public var targetDist:Number; // 到目标的距离
      // #endregion
      public function Ship() // 构造函数，用于初始化
      {
         super();
         state = 0;
         image = new Image(Root.assets.getTexture("ship"));
         image.pivotX = image.pivotY = image.width * 0.5;
         trail = new Image(Root.assets.getTexture("quad8x4"));
         trail.pivotX = trail.width;
         trail.pivotY = trail.height * 0.5;
         trail.adjustVertices();
         trail.setVertexAlpha(0, 0);
         trail.setVertexAlpha(2, 0);
         pulse = new Image(Root.assets.getTexture("ship_pulse"));
         pulse.pivotX = pulse.pivotY = pulse.width * 0.5;
      }

      public function initShip(_GameScene:GameScene, _team:int, _Node:Node, _productionEffect:Boolean = true):void
      {
         super.init(_GameScene);
         this.team = _team;
         this.node = _Node;
         _Node.ships[_team].push(this);
         image.alpha = 1;
         image.color = Globals.teamColors[_team];
         image.scaleX = image.scaleY = 1;
         trail.alpha = 0;
         trail.color = image.color;
         trail.scaleX = trail.scaleY = 1;
         trailLength = 2;
         pulse.color = image.color;
         pulse.alpha = 0;
         orbitDist = (40 + Math.random() * 40) * _Node.size * 2;
         orbitAngle = Math.random() * 3.141592653589793 * 2;
         orbitSpeed = Math.random() * 0.15 + 0.05;
         trailLength = 2;
         resetChargeRate();
         jumpDist = 0;
         if (team != 6)
            jumpSpeed = 50;
         else if (team == 6)
            jumpSpeed = 100;
         hp = 100;
         state = 0; // 状态数
         if (_productionEffect) // 生产飞船时的动画
         {
            image.alpha = 0;
            pulse.alpha = 1;
            pulse.visible = true;
            pulse.scaleX = pulse.scaleY = 1;
         }
         x = _Node.x + Math.cos(orbitAngle) * orbitDist;
         y = _Node.y + Math.sin(orbitAngle) * orbitDist * 0.15;
         if (orbitAngle > 0 && orbitAngle < 3.141592653589793)
            foreground = true;
         else
            foreground = false;
      }

      override public function deInit():void
      {
      }
      // #region 更新
      override public function update(_dt:Number):void // 更新
      {
         switch (state) // 按状态决定更新方式
         {
            case 0: // 在天体上
               updateOrbit(_dt); // 围绕天体旋转
               break;
            case 1: // 接收到起飞命令，进入制动阶段（受制动速度影响，拉伸贴图至原长6倍）
               updatePreJump1(_dt);
               break;
            case 2: // 制动结束，进入起飞阶段（不受制动速度影响，压缩贴图至原长2倍）
               updatePreJump2(_dt); // 若为传送门则跳过状态3
               break;
            case 3: // 起飞后，保持贴图2倍拉伸飞向目标天体
               updateJump(_dt);
               break;
         }
         if (!node.active)
            moveTo(closestNode()); // 飞船所属天体消失时自动飞向最近的天体（不含障碍，存在随机数
      }

      public function updateOrbit(_dt:Number):void // 围绕天体旋转
      {
         if (image.alpha < 1 || pulse.scaleX > 0) // 生产飞船时的动画
         {
            image.alpha += _dt;
            pulse.alpha = image.alpha * 0.5;
            pulse.scaleX = pulse.scaleY = 1 - image.alpha;
            if (image.alpha >= 1)
            {
               image.alpha = 1;
               pulse.alpha = 0;
            }
         }
         if (image.scaleX > 1) // 着陆时恢复贴图缩放
         {
            image.scaleX = Math.max(1, image.scaleX - _dt * 2);
            image.scaleY = image.scaleX;
         }
         if (trail.alpha > 0) // 着陆时减少拖尾长度和不透明度
         {
            trail.alpha -= _dt * 0.5;
            trail.rotation = 0;
            trailLength -= _dt * 120;
            if (trail.alpha <= 0 || trailLength <= 1)
            {
               trail.alpha = 0;
               trailLength = 1;
            }
            trail.width = trailLength;
            trail.rotation = jumpAngle;
            if (orbitAngle > 0 && orbitAngle < 3.141592653589793)
               foreground = true; // 判断与天体贴图的图层关系
            else
               foreground = false;
            drawTrail();
         }
         if (!node.conflict && !node.capturing)
            hp = Math.min(100, hp + _dt * 50);
         orbitAngle += orbitSpeed * _dt;
         if (orbitAngle > 6.283185307179586)
            orbitAngle -= 6.283185307179586;
         if (orbitAngle < 0)
            orbitAngle += 6.283185307179586;
         x = node.x + Math.cos(orbitAngle) * orbitDist;
         y = node.y + Math.sin(orbitAngle) * orbitDist * 0.15;
         if (orbitAngle > 0 && orbitAngle < 3.141592653589793)
            foreground = true;
         else
            foreground = false;
         drawImage();
         if (pulse.alpha > 0)
            drawPulse();
      }

      public function updatePreJump1(_dt:Number):void // 制动飞船
      {
         image.rotation = 0;
         image.scaleX += _dt * chargeRate;
         if (image.scaleX > 6)
         {
            image.scaleX = 6;
            state = 2;
         }
         image.scaleY = 1 - image.scaleX / 6 * 0.25;
         image.rotation = jumpAngle;
         if (orbitAngle > 0 && orbitAngle < 3.141592653589793)
            foreground = true;
         else
            foreground = false;
         drawImage();
      }

      public function updatePreJump2(_dt:Number):void // 准备起飞
      {
         var _foreground:Boolean = false;
         image.rotation = 0;
         image.scaleX = Math.max(2, image.scaleX - _dt * 40);
         image.scaleY = 1 - image.scaleX / 6 * 0.25;
         if (image.scaleX == 2)
         {
            image.scaleY = 0.5;
            if (warping)
            {
               _foreground = false;
               if (orbitAngle > 0 && orbitAngle < 3.141592653589793)
                  _foreground = true;
               game.addWarp(x, y, tx, ty, Globals.teamColors[team], _foreground);
               x = tx;
               y = ty;
               node.ships[team].push(this);
               if (node.aiTimers[team] < 0.1)
                  node.aiTimers[team] = 0.1;
               node.warps[team] = true;
               state = 0;
               GS.playWarp(this.x);
            }
            else
            {
               state = 3;
               GS.playJumpStart(this.x);
            }
         }
         image.rotation = jumpAngle;
         drawImage();
      }

      public function updateJump(_dt:Number):void // 飞行状态下的更新
      {
         var _x1:Number = NaN;
         var _y1:Number = NaN;
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         var _Angle:Number = NaN;
         var _Distance:Number = NaN;
         var _dtime:Number = NaN;
         var _dAngle:Number = NaN;
         var _x2:Number = NaN;
         var _y2:Number = NaN;
         jumpSpeed += 4 * _dt; // 飞船加速度
         if (team == 6)
            jumpSpeed += 4 * _dt;
         if (node.orbitNode)
         {
            _x1 = Math.cos(orbitAngle) * orbitDist;
            _y1 = Math.sin(orbitAngle) * orbitDist;
            tx = node.x + _x1;
            ty = node.y + _y1 * 0.15;
            _dx = tx - x;
            _dy = ty - y;
            _Angle = Math.atan2(_dy, _dx);
            _dtime = (_Distance = Math.sqrt(_dx * _dx + _dy * _dy)) / jumpSpeed;
            _dAngle = node.orbitAngle + node.orbitSpeed * _dtime;
            if (_dAngle > 6.283185307179586)
               _dAngle -= 6.283185307179586;
            _x2 = node.orbitNode.x + Math.cos(_dAngle) * node.orbitDist;
            _y2 = node.orbitNode.y + Math.sin(_dAngle) * node.orbitDist;
            tx = _x2 + _x1;
            ty = _y2 + _y1 * 0.15;
            _dx = tx - x;
            _dy = ty - y;
            _dtime = (_Distance = Math.sqrt(_dx * _dx + _dy * _dy)) / jumpSpeed;
            _dAngle = node.orbitAngle + node.orbitSpeed * _dtime;
            if (_dAngle > 6.283185307179586)
               _dAngle -= 6.283185307179586;
            _x2 = node.orbitNode.x + Math.cos(_dAngle) * node.orbitDist;
            _y2 = node.orbitNode.y + Math.sin(_dAngle) * node.orbitDist;
            tx = _x2 + _x1;
            ty = _y2 + _y1 * 0.15;
            _dx = tx - x;
            _dy = ty - y;
            _Distance = Math.sqrt(_dx * _dx + _dy * _dy);
            _Angle = Math.atan2(_dy, _dx);
         }
         else
         {
            targetDist -= jumpSpeed * _dt;
            _Distance = targetDist;
            _Angle = jumpAngle;
         }
         if (_Distance > jumpSpeed * _dt)
         {
            x += Math.cos(_Angle) * jumpSpeed * _dt;
            y += Math.sin(_Angle) * jumpSpeed * _dt;
            jumpAngle = _Angle;
         }
         else
         {
            x = tx;
            y = ty;
            node.ships[team].push(this);
            if (node.aiTimers[team] < 0.1)
               node.aiTimers[team] = 0.1;
            state = 0;
            GS.playJumpEnd(this.x);
         }
         jumpDist += jumpSpeed * _dt;
         trail.rotation = 0;
         trailLength = 16 * (jumpSpeed / 50 - 0.5);
         if (trailLength > 75)
            trailLength = 4 * (jumpSpeed / 50 + 13.5625);
         trail.width = trailLength;
         trail.rotation = jumpAngle;
         image.rotation = jumpAngle;
         trail.visible = true;
         if (orbitAngle > 0 && orbitAngle < 3.141592653589793)
            foreground = true;
         else
            foreground = false;
         drawImage();
         drawTrail();
      }

      public function resetChargeRate():void // 重置制动速度
      {
         chargeRate = Math.random() * 6 + 6;
      }
      // #endregion
      // #region 绘制贴图相关
      public function drawImage():void // 绘制贴图
      {
         image.x = x;
         image.y = y;
         if (image.color == 0)
         {
            if (foreground)
               game.shipsBatch2b.addImage(image);
            else
               game.shipsBatch1b.addImage(image);
         }
         else if (foreground)
            game.shipsBatch2.addImage(image);
         else
            game.shipsBatch1.addImage(image);
      }

      public function drawTrail():void // 绘制拖尾
      {
         trail.x = x;
         trail.y = y;
         if (image.color == 0)
         {
            if (foreground)
               game.shipsBatch2b.addImage(trail);
            else
               game.shipsBatch1b.addImage(trail);
         }
         else if (foreground)
            game.shipsBatch2.addImage(trail);
         else
            game.shipsBatch1.addImage(trail);
      }

      public function drawPulse():void // 绘制光圈
      {
         pulse.x = x;
         pulse.y = y;
         if (image.color == 0)
         {
            if (foreground)
               game.shipsBatch2b.addImage(pulse);
            else
               game.shipsBatch1b.addImage(pulse);
         }
         else if (foreground)
            game.shipsBatch2.addImage(pulse);
         else
            game.shipsBatch1.addImage(pulse);
      }
      // #endregion
      // #region 其他功能性函数
      public function destroy():void // 摧毁飞船
      {
         active = false;
         var _foreground:Boolean = false;
         if (orbitAngle > 0 && orbitAngle < 3.141592653589793)
            _foreground = true;
         game.addFlash(x, y, Globals.teamColors[team], _foreground);
         game.addExplosion(x, y, Globals.teamColors[team], _foreground);
         GS.playExplosion(this.x);
      }

      public function moveTo(_Node:Node):void // 移动至参数_Node指定天体
      {
         var _dtime:Number = NaN;
         var _dAngle:Number = NaN;
         var _x2:Number = NaN;
         var _y2:Number = NaN;
         var _x1:Number = NaN;
         var _y1:Number = NaN;
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         var _Distance:Number;
         // 依势力改变速度
         if (jumpSpeed > 50 && team != 6)
            jumpSpeed = 50;
         if (jumpSpeed > 100 && team == 6)
            jumpSpeed = 100;
         this.node = _Node;
         orbitDist = (40 + Math.random() * 40) * node.size * 2;
         orbitSpeed = Math.random() * 0.15 + 0.05;
         _x1 = Math.cos(orbitAngle) * orbitDist;
         _y1 = Math.sin(orbitAngle) * orbitDist;
         tx = node.x + _x1;
         ty = node.y + _y1 * 0.15;
         _dx = tx - x;
         _dy = ty - y;
         jumpAngle = Math.atan2(_dy, _dx);
         targetDist = _Distance = Math.sqrt(_dx * _dx + _dy * _dy);
         if (node.orbitNode)
         {
            _dtime = _Distance / jumpSpeed;
            _dAngle = node.orbitAngle + node.orbitSpeed * _dtime;
            if (_dAngle > 6.283185307179586)
               _dAngle -= 6.283185307179586;
            _x2 = node.orbitNode.x + Math.cos(_dAngle) * node.orbitDist;
            _y2 = node.orbitNode.y + Math.sin(_dAngle) * node.orbitDist;
            tx = _x2 + _x1;
            ty = _y2 + _y1 * 0.15;
            _dx = tx - x;
            _dy = ty - y;
            _dtime = (_Distance = Math.sqrt(_dx * _dx + _dy * _dy)) / jumpSpeed;
            _dAngle = node.orbitAngle + node.orbitSpeed * _dtime;
            if (_dAngle > 6.283185307179586)
               _dAngle -= 6.283185307179586;
            _x2 = node.orbitNode.x + Math.cos(_dAngle) * node.orbitDist;
            _y2 = node.orbitNode.y + Math.sin(_dAngle) * node.orbitDist;
            tx = _x2 + _x1;
            ty = _y2 + _y1 * 0.15;
            _dx = tx - x;
            _dy = ty - y;
            _Distance = Math.sqrt(_dx * _dx + _dy * _dy);
            jumpAngle = Math.atan2(_dy, _dx);
            targetDist = _Distance;
         }
         trail.rotation = 0;
         trailLength = 1;
         trail.width = trailLength;
         trail.alpha = 0.5;
         jumpDist = 0;
         if (state == 0)
         {
            image.scaleY = 1;
            image.scaleX = 1;
            resetChargeRate();
         }
         image.alpha = 1;
         state = 1;
         warping = false;
         GS.playJumpCharge(this.x);
      }

      public function warpTo(_Node:Node):void // 传送至参数_Node指定天体
      {
         this.node = _Node;
         orbitDist = (40 + Math.random() * 40) * node.size * 2;
         orbitSpeed = Math.random() * 0.15 + 0.05;
         var _x:Number = Math.cos(orbitAngle) * orbitDist;
         var _y:Number = Math.sin(orbitAngle) * orbitDist;
         tx = node.x + _x;
         ty = node.y + _y * 0.15;
         var _dx:Number = tx - x;
         var _dy:Number = ty - y;
         jumpAngle = Math.atan2(_dy, _dx);
         trail.rotation = 0;
         trailLength = 1;
         trail.width = trailLength;
         trail.alpha = 0.5;
         jumpDist = 0;
         if (state == 0)
         {
            image.scaleY = 1;
            image.scaleX = 1;
            chargeRate = 6;
         }
         image.alpha = 1;
         state = 1;
         warping = true;
         GS.playJumpCharge(this.x);
      }

      public function changeTeam(_team:int):void // 改变飞船势力
      {
         this.team = _team;
         if (node.ships[_team].indexOf(this) == -1)
            node.ships[_team].push(this);
         image.color = Globals.teamColors[_team];
         trail.color = image.color;
         pulse.color = image.color;
      }

      public function closestNode():Node // 计算最近的天体（不含障碍，存在随机数
      {
         var _closestNode:Node = null;
         var _dx:Number = NaN;
         var _dy:Number = NaN;
         var _Distance:Number = NaN;
         var _closestDist:Number = 99999;
         for each (var _Node:Node in game.nodes.active)
         {
            if (!_Node.active)
               continue;
            if (_Node.type == 3)
               continue;
            // 计算距离，结果带有0~32px的随机误差
            _dx = _Node.x - this.x;
            _dy = _Node.y - this.y;
            _Distance = Math.sqrt(_dx * _dx + _dy * _dy) + Math.random() * 32;
            if (_Distance < _closestDist)
            {
               _closestDist = _Distance;
               _closestNode = _Node;
            }
         }
         return _closestNode;
      }
      // #endregion
   }
}
