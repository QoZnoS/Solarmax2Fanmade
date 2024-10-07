package Menus
{
   import Game.Entity.EndStar;
   import Game.Entity.EntityPool;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.QuadBatch;
   import starling.display.Sprite;
   import starling.events.EnterFrameEvent;

   public class EndScene extends Sprite
   {
      public var stars:EntityPool;
      public var batch:QuadBatch;
      public var cover:Quad;
      public var quadImage:Image;
      public var pulseSize:Number;
      public var pulseWidth:Number;
      public var timer:Number;

      public function EndScene()
      {
         super();
         quadImage = new Image(Root.assets.getTexture("quad"));
         quadImage.adjustVertices();
         stars = new EntityPool();
         batch = new QuadBatch();
         addChild(batch);
         cover = new Quad(1024, 768, 16777215);
         cover.blendMode = "add";
         cover.alpha = 0;
         addChild(cover);
         this.touchable = false;
         this.visible = false;
      }

      public function init():void
      {
         var _EndStar1:EndStar = null;
         var _Distance:Number = NaN;
         var _angle:Number = NaN;
         var _sqrt500:Number = Math.sqrt(500);
         var _EndStar2:EndStar = makeStar(512, 384);
         _EndStar2.mult = 1;
         for (var i:int = 0; i < 50; i++)
         {
            _EndStar1 = makeStar(512, 384);
            _Distance = Math.random() * _sqrt500;
            _Distance = _Distance * _Distance + 50;
            _angle = Math.random() * 3.141592653589793 * 2;
            _EndStar1.x = 512 + Math.cos(_angle) * _Distance;
            _EndStar1.y = 384 + Math.sin(_angle) * _Distance;
            while (checkProximity(stars.active, _EndStar1, 60))
            {
               _Distance = Math.random() * _sqrt500;
               _Distance = _Distance * _Distance + 50;
               _angle = Math.random() * 3.141592653589793 * 2;
               _EndStar1.x = 512 + Math.cos(_angle) * _Distance;
               _EndStar1.y = 384 + Math.sin(_angle) * _Distance;
            }
         }
         for each (_EndStar1 in stars.active)
         {
            if (_EndStar1 == _EndStar2)
               continue;
            _EndStar1.delay = getDistance(_EndStar2, _EndStar1) * 0.05;
         }
         pulseSize = 0;
         pulseWidth = 10;
         timer = 20;
         cover.alpha = 0;
         cover.visible = true;
         this.visible = true;
         addEventListener("enterFrame", update);
      }

      public function checkProximity(_StarArray:Array, _EndStar1:EndStar, _Distance:Number):Boolean // 检测_EndStar1 距数组每项的距离是否均小于_Distance
      {
         for each (var _EndStar2:EndStar in _StarArray)
         {
            if (_EndStar2 == _EndStar1)
               continue;
            if (getDistance(_EndStar1, _EndStar2) > _Distance)
               continue;
            return true;
         }
         return false;
      }

      public function getDistance(_EndStar1:EndStar, _EndStar2:EndStar):Number // 计算距离
      {
         var _dx:Number = _EndStar1.x - _EndStar2.x;
         var _dy:Number = _EndStar1.y - _EndStar2.y;
         return Math.sqrt(_dx * _dx + _dy * _dy);
      }

      public function deInit():void
      {
         stars.deInit();
         cover.alpha = 0;
         cover.visible = false;
         batch.reset();
         this.visible = false;
         this.touchable = false;
         removeEventListener("enterFrame", update);
      }

      public function makeStar(_x:Number, _y:Number, _delay:Number = 0):EndStar
      {
         var _EndStar:EndStar;
         if (!(_EndStar = stars.getReserve() as EndStar))
            _EndStar = new EndStar();
         _EndStar.initStar(this, _x, _y, _delay);
         stars.addEntity(_EndStar);
         return _EndStar;
      }

      public function update(e:EnterFrameEvent):void
      {
         var _dt:Number = e.passedTime;
         timer -= _dt;
         if (cover.alpha == 1)
         {
            if (timer <= 0)
            {
               timer = 0;
               dispatchEventWith("done");
            }
         }
         else if (timer <= 0)
         {
            timer = 0;
            if (cover.alpha < 1)
            {
               cover.alpha += _dt * 0.1;
               if (cover.alpha >= 1)
               {
                  cover.alpha = 1;
                  timer = 5;
               }
            }
         }
         stars.update(_dt);
         pulseSize += _dt * 20;
         pulseWidth += _dt * 3;
         var _model:Number = pulseSize - pulseWidth;
         if (_model < 0)
            _model = 0;
         var _alpha:Number = (1 - pulseSize / 512) * 0.4;
         if (_alpha < 0)
            _alpha = 0;
         var _quality:int = 8 + pulseSize / 512 * 248;
         batch.reset();
         drawCircle(512, 384, Globals.teamColors[1], pulseSize, _model, true, _alpha, 1, 0, _quality);
         batch.blendMode = "add";
      }
      // 画圆
      public function drawCircle(_x:Number, _y:Number, _Color:uint, _R:Number, _voidR:Number = 0, mTinted:Boolean = false, _alpha:Number = 1, _quality2:Number = 1, _angle:Number = 0, _quality1:int = 64):void
      {
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
         var _angleStep:Number = 6.283185307179586 / _quality1;
         var _lineNumber:int = Math.ceil(_quality1 * _quality2);
         for(var i:int = 0; i < _lineNumber; i++)
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
            batch.addImage(quadImage);
            _angle += _angleStep;
         }
      }
   }
}
