// initPulse(_GameScene, _Node, _Color, _type, _maxSize, _rate, _angle, _delay)
// _Node为天体，_Color为颜色，_type为类型，_maxSize为最大大小，_rate为速度，_angle为角度，_delay为延迟
// 类型的意义详见update(_dt)
package Game.Entity
{
   import Game.GameScene;
   import starling.display.Image;

   public class DarkPulse extends GameEntity
   {

      public static const TYPE_GROW:int = 0;

      public static const TYPE_SHRINK:int = 1;

      public static const TYPE_BLOB:int = 2;

      public static const TYPE_BLOOM:int = 3;

      public var x:Number;

      public var y:Number;

      public var size:Number;

      public var maxSize:Number;

      public var delay:Number;

      public var rate:Number;

      public var angle:Number;

      public var image:Image;

      public var type:int;

      public function DarkPulse()
      {
         super();
         image = new Image(Root.assets.getTexture("halo"));
         image.pivotX = image.pivotY = image.width * 0.5;
      }

      public function initPulse(_GameScene:GameScene, _Node:Node, _Color:uint, _type:int, _maxSize:Number, _rate:Number, _angle:Number, _delay:Number = 0):void
      {
         super.init(_GameScene);
         image.rotation = 0;
         switch (_type)
         {
            case 0:
            case 1:
               image.texture = Root.assets.getTexture("halo");
               break;
            case 2:
            case 3:
               image.texture = Root.assets.getTexture("spot_glow");
         }
         image.readjustSize();
         image.width = image.texture.width;
         image.height = image.texture.height;
         image.scaleX = image.scaleY = 1;
         image.pivotX = image.pivotY = image.width * 0.5;
         image.color = _Color;
         this.x = _Node.x;
         this.y = _Node.y;
         this.type = _type;
         this.maxSize = _maxSize;
         this.rate = _rate;
         this.angle = _angle;
         this.delay = _delay;
         switch (_type)
         {
            case 0:
               size = 0;
               image.alpha = 1;
               image.scaleX = image.scaleY = size;
               break;
            case 1:
               size = _maxSize;
               image.alpha = 0;
               image.scaleX = image.scaleY = size;
               break;
            case 2:
               size = _maxSize;
               image.alpha = 0;
               image.scaleX = image.scaleY = size * 6;
               break;
            case 3:
               size = 0;
               image.alpha = 1;
               image.scaleX = image.scaleY = size;
         }
         image.x = x;
         image.y = y;
         image.color = _Color;
         image.visible = true;
         if (image.color == 0)
            _GameScene.nodeGlowLayer2.addChild(image);
         else
            _GameScene.nodeGlowLayer.addChild(image);
      }

      override public function deInit():void
      {
         if (game.nodeGlowLayer.contains(image))
            game.nodeGlowLayer.removeChild(image);
         if (game.nodeGlowLayer2.contains(image))
            game.nodeGlowLayer2.removeChild(image);
      }

      override public function update(_dt:Number):void
      {
         image.rotation = 0;
         if (delay > 0)
         {
            image.visible = false;
            delay -= _dt;
            if (delay <= 0)
               image.visible = true;
            return;
         }
         var _scale:Number = size / maxSize;
         switch (type)
         {
            case 0: // 使用halo，贴图大小递增
               size += _dt * rate;
               if (size > maxSize)
               {
                  size = maxSize;
                  active = false;
               }
               image.alpha = 1 - _scale;
               image.scaleY = size * _scale;
               image.scaleX = maxSize * 0.5;
               image.rotation = angle;
               break;
            case 1: // 使用halo，贴图大小递减
               size -= _dt * rate;
               if (size < 0)
               {
                  size = 0;
                  active = false;
               }
               image.alpha = 1 - _scale;
               image.scaleY = size * _scale;
               image.scaleX = maxSize * 0.5;
               image.rotation = angle;
               break;
            case 2: // 使用spot_glow，贴图大小递减
               size -= _dt * rate;
               if (size < 0)
               {
                  size = 0;
                  active = false;
               }
               image.alpha = 1 - _scale;
               image.scaleX = image.scaleY = size * 6;
               break;
            case 3: // 使用spot_glow，贴图大小递增
               size += _dt * rate;
               if (size > maxSize)
               {
                  size = maxSize;
                  active = false;
               }
               image.alpha = 1 - _scale;
               image.scaleX = image.scaleY = size;
         }
      }
   }
}
