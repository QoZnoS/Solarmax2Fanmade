// 在EndScene中被调用
package Game.Entity
{
   import Menus.EndScene;
   import starling.display.Image;

   public class EndStar extends GameEntity
   {

      public static const STATE_GROW:int = 0;

      public static const STATE_SHRINK:int = 1;

      public static const STATE_BLINK:int = 2;

      public var x:Number;

      public var y:Number;

      public var image:Image;

      public var glare1:Image;

      public var glare2:Image;

      public var glare3:Image;

      public var glare4:Image;

      public var delay:Number;

      public var size:Number;

      public var mult:Number;

      public var endScene:EndScene;

      public var state:int;

      public function EndStar()
      {
         super();
         image = new Image(Root.assets.getTexture("spot_glow"));
         image.pivotX = image.pivotY = image.width * 0.5;
         image.color = Globals.teamColors[1];
         image.blendMode = "add";
         glare1 = new Image(Root.assets.getTexture("warp_glare"));
         glare1.pivotX = glare1.width * 0.5;
         glare1.pivotY = glare1.height * 0.5;
         glare1.color = Globals.teamColors[1];
         glare1.alpha = 0.6;
         glare1.blendMode = "add";
         glare2 = new Image(Root.assets.getTexture("warp_glare"));
         glare2.pivotX = glare2.width * 0.5;
         glare2.pivotY = glare2.height * 0.5;
         glare2.color = Globals.teamColors[1];
         glare2.alpha = 0.6;
         glare2.blendMode = "add";
         glare2.rotation = 1.5707963267948966;
         glare3 = new Image(Root.assets.getTexture("warp_glare"));
         glare3.pivotX = glare3.width * 0.5;
         glare3.pivotY = glare3.height * 0.5;
         glare3.color = Globals.teamColors[1];
         glare3.alpha = 0.4;
         glare3.blendMode = "add";
         glare3.rotation = 0.7853981633974483;
         glare4 = new Image(Root.assets.getTexture("warp_glare"));
         glare4.pivotX = glare4.width * 0.5;
         glare4.pivotY = glare4.height * 0.5;
         glare4.color = Globals.teamColors[1];
         glare4.alpha = 0.4;
         glare4.blendMode = "add";
         glare4.rotation = -0.7853981633974483;
      }

      public function initStar(_EndScene:EndScene, _x:Number, _y:Number, _delay:Number):void
      {
         init(null);
         this.endScene = _EndScene;
         this.x = _x;
         this.y = _y;
         this.delay = _delay;
         size = 0;
         mult = 0.3 + Math.random() * 0.5;
         image.x = glare1.x = glare2.x = glare3.x = glare4.x = _x;
         image.y = glare1.y = glare2.y = glare3.y = glare4.y = _y;
         image.scaleX = image.scaleY = glare1.scaleX = glare1.scaleY = glare2.scaleX = glare2.scaleY = glare3.scaleX = glare3.scaleY = glare4.scaleX = glare4.scaleY = 0;
         _EndScene.addChild(glare1);
         _EndScene.addChild(glare2);
         _EndScene.addChild(glare3);
         _EndScene.addChild(glare4);
         _EndScene.addChild(image);
         state = 0;
      }

      override public function deInit():void
      {
         endScene.removeChild(glare1);
         endScene.removeChild(glare2);
         endScene.removeChild(glare3);
         endScene.removeChild(glare4);
         endScene.removeChild(image);
      }

      override public function update(_dt:Number):void
      {
         image.x = glare1.x = glare2.x = glare3.x = glare4.x = x;
         image.y = glare1.y = glare2.y = glare3.y = glare4.y = y;
         if (delay > 0)
         {
            delay -= _dt;
            return;
         }
         switch (state)
         {
            case 0:
               size += _dt * 3;
               if (size > 1.5)
               {
                  size = 1.5;
                  state = 1;
               }
               image.scaleX = image.scaleY = size * 0.3 * mult;
               break;
            case 1:
               size -= _dt * 0.5;
               if (size <= 1)
               {
                  size = 1;
                  state = 2;
               }
               image.scaleX = image.scaleY = size * 0.3 * mult;
         }
         var _scale:Number = size * mult * (0.8 + Math.random() * 0.2);
         glare1.scaleX = glare2.scaleX = _scale * 1;
         glare1.scaleY = glare2.scaleY = _scale * 0.3;
         glare3.scaleX = glare4.scaleX = _scale * 0.75;
         glare3.scaleY = glare4.scaleY = _scale * 0.3;
      }
   }
}
