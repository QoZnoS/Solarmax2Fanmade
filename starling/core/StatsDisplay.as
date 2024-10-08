package starling.core
{
   import flash.system.System;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.EnterFrameEvent;
   import starling.text.TextField;
   
   internal class StatsDisplay extends Sprite
   {
       
      
      private const UPDATE_INTERVAL:Number = 0.5;
      
      private var mBackground:Quad;
      
      private var mTextField:TextField;
      
      private var mFrameCount:int = 0;
      
      private var mTotalTime:Number = 0;
      
      private var mFps:Number = 0;
      
      private var mMemory:Number = 0;
      
      private var mDrawCount:int = 0;
      
      public function StatsDisplay()
      {
         super();
         mBackground = new Quad(50,25,0);
         mTextField = new TextField(48,25,"","mini",-1,16777215);
         mTextField.x = 2;
         mTextField.hAlign = "left";
         mTextField.vAlign = "top";
         addChild(mBackground);
         addChild(mTextField);
         blendMode = "none";
         addEventListener("addedToStage",onAddedToStage);
         addEventListener("removedFromStage",onRemovedFromStage);
      }
      
      private function onAddedToStage() : void
      {
         addEventListener("enterFrame",onEnterFrame);
         mTotalTime = mFrameCount = 0;
         update();
      }
      
      private function onRemovedFromStage() : void
      {
         removeEventListener("enterFrame",onEnterFrame);
      }
      
      private function onEnterFrame(param1:EnterFrameEvent) : void
      {
         mTotalTime += param1.passedTime;
         mFrameCount++;
         if(mTotalTime > 0.5)
         {
            update();
            mFrameCount = mTotalTime = 0;
         }
      }
      
      public function update() : void
      {
         mFps = mTotalTime > 0 ? mFrameCount / mTotalTime : 0;
         mMemory = System.totalMemory * 9.54e-7;
         mTextField.text = "FPS: " + mFps.toFixed(mFps < 100 ? 1 : 0) + "\nMEM: " + mMemory.toFixed(mMemory < 100 ? 1 : 0) + "\nDRW: " + (mTotalTime > 0 ? mDrawCount - 2 : mDrawCount);
      }
      
      override public function render(param1:RenderSupport, param2:Number) : void
      {
         param1.finishQuadBatch();
         super.render(param1,param2);
      }
      
      public function get drawCount() : int
      {
         return mDrawCount;
      }
      
      public function set drawCount(param1:int) : void
      {
         mDrawCount = param1;
      }
      
      public function get fps() : Number
      {
         return mFps;
      }
      
      public function set fps(param1:Number) : void
      {
         mFps = param1;
      }
      
      public function get memory() : Number
      {
         return mMemory;
      }
      
      public function set memory(param1:Number) : void
      {
         mMemory = param1;
      }
   }
}
