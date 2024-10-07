//提供音效相关函数，全静态

package
{
   import com.greensock.TweenLite;
   import flash.media.SoundChannel;
   import flash.media.SoundMixer;
   import flash.media.SoundTransform;
   import starling.core.Starling;
   
   public class GS
   {
      
      public static var st:SoundTransform;
      
      public static var mt:SoundTransform;
      
      public static var mute:SoundTransform;
      
      public static var timers:Array = [0,0,0,0,0,0,0,0,0,0];
      
      public static var gap:Number = 0.1;
      
      public static var musicChannel:SoundChannel;
      
      public static var lastSong:String = "";
      
      public static var lastLoop:String = "";
      
      public static var lastPosition:Number = 0;
      
      public static var musicPaused:Boolean = false;
       
      
      public function GS()
      {
         super();
      }
      
      public static function init() : void
      {
         Root.assets.addSound("bgm01",new bgm01());
         Root.assets.addSound("bgm02",new bgm02());
         Root.assets.addSound("bgm04",new bgm04());
         Root.assets.addSound("bgm05",new bgm05());
         Root.assets.addSound("bgm06",new bgm06());
         Root.assets.addSound("bgm07",new bgm07());
         st = new SoundTransform(Globals.soundVolume);
         mt = new SoundTransform(Globals.musicVolume);
         mute = new SoundTransform(0);
      }
      
      public static function update(param1:Number) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(timers.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(timers[_loc3_] > 0)
            {
               var _loc4_:* = _loc3_;
               var _loc5_:* = timers[_loc4_] - param1;
               timers[_loc4_] = _loc5_;
               if(timers[_loc3_] < 0)
               {
                  timers[_loc3_] = 0;
               }
            }
            _loc3_++;
         }
      }
      
      public static function updateTransforms() : void
      {
         st.volume = Globals.soundVolume;
         mt.volume = Globals.musicVolume;
         if(musicChannel)
         {
            musicChannel.soundTransform = mt;
         }
      }
      
      public static function playMusic(param1:String, param2:Boolean = true) : void
      {
         var prevChannel:SoundChannel;
         var transform:SoundTransform;
         var transform2:SoundTransform;
         var name:String = param1;
         var loop:Boolean = param2;
         var loopVal:int = 0;
         if(loop)
         {
            loopVal = 2147483647;
         }
         if(name != lastSong)
         {
            if(musicChannel)
            {
               prevChannel = musicChannel;
               transform = new SoundTransform(Globals.musicVolume,0);
               Starling.juggler.tween(transform,1,{
                  "volume":0,
                  "onUpdate":function():void
                  {
                     prevChannel.soundTransform = transform;
                  },
                  "onComplete":prevChannel.stop
               });
            }
            lastSong = name;
            transform2 = new SoundTransform(0,0);
            musicChannel = Root.assets.playSound(name,0,loopVal,transform2);
            if(musicChannel)
            {
               Starling.juggler.tween(transform2,0.5,{
                  "volume":Globals.musicVolume,
                  "onUpdate":function():void
                  {
                     musicChannel.soundTransform = transform2;
                  }
               });
            }
         }
         else if(!musicChannel)
         {
            lastSong = name;
            transform2 = new SoundTransform(0,0);
            musicChannel = Root.assets.playSound(name,0,loopVal,transform2);
            Starling.juggler.tween(transform2,0.5,{
               "volume":Globals.musicVolume,
               "onUpdate":function():void
               {
                  musicChannel.soundTransform = transform2;
               }
            });
         }
      }
      
      public static function fadeOutMusic(param1:Number) : void
      {
         var transform:SoundTransform;
         var time:Number = param1;
         if(musicChannel)
         {
            transform = new SoundTransform(Globals.musicVolume,0);
            Starling.juggler.tween(transform,time,{
               "volume":0,
               "onUpdate":function():void
               {
                  musicChannel.soundTransform = transform;
               },
               "onComplete":function():void
               {
                  musicChannel.stop();
               }
            });
            lastSong = null;
         }
      }
      
      public static function pauseMusic() : void
      {
         var prevChannel:SoundChannel;
         var transform:SoundTransform;
         if(musicChannel)
         {
            musicPaused = true;
            if(lastSong == "")
            {
               return;
            }
            prevChannel = musicChannel;
            transform = new SoundTransform(Globals.musicVolume,0);
            lastPosition = prevChannel.position;
            TweenLite.to(transform,1,{
               "volume":0,
               "onUpdate":function():void
               {
                  prevChannel.soundTransform = transform;
               },
               "onComplete":function():void
               {
                  prevChannel.stop();
                  if(musicPaused)
                  {
                     SoundMixer.stopAll();
                  }
               }
            });
         }
      }
      
      public static function resumeMusic() : void
      {
         var loop:int;
         var startPos:Number;
         var transform:SoundTransform;
         musicPaused = false;
         if(lastSong == "")
         {
            return;
         }
         loop = 2147483647;
         startPos = 0;
         if(lastSong == "bgm07" || lastSong == "bgm_dark")
         {
            loop = 0;
            startPos = lastPosition;
         }
         transform = new SoundTransform(0,0);
         musicChannel = Root.assets.playSound(lastSong,startPos,loop,transform);
         Starling.juggler.tween(transform,0.5,{
            "volume":Globals.musicVolume,
            "onUpdate":function():void
            {
               musicChannel.soundTransform = transform;
            }
         });
      }
      
      public static function playSound(param1:String, param2:Number = 1, param3:Number = 0) : void
      {
         st.volume = param2 * Globals.soundVolume * Globals.soundMult;
         if(st.volume == 0)
         {
            return;
         }
         st.pan = param3;
         Root.assets.playSound(param1,0,0,st);
      }
      
      public static function playSoundLikeMusic(param1:String, param2:Number = 1, param3:Number = 0) : void
      {
         st.volume = param2 * Globals.musicVolume;
         st.pan = param3;
         Root.assets.playSound(param1,0,0,st);
      }
      
      public static function playClick() : void
      {
         playSound("click",0.75);
      }
      
      public static function playClickUp() : void
      {
         playSound("click_up");
      }
      
      public static function playClickDown() : void
      {
         playSound("click_down");
      }
      
      public static function playExplosion(param1:Number) : void
      {
         if(timers[0] > 0)
         {
            return;
         }
         timers[0] = gap;
         var _loc3_:Number = (param1 - 512) / 512;
         var _loc2_:int = Math.random() * 8;
         playSound("explosion0" + (_loc2_ + 1).toString(),1,_loc3_);
      }
      
      public static function playJumpCharge(param1:Number) : void
      {
         if(timers[1] > 0)
         {
            return;
         }
         timers[1] = gap;
         var _loc2_:Number = (param1 - 512) / 512;
         playSound("jumpCharge",0.5,_loc2_);
      }
      
      public static function playJumpStart(param1:Number) : void
      {
         if(timers[2] > 0)
         {
            return;
         }
         timers[2] = gap;
         var _loc2_:Number = (param1 - 512) / 512;
         playSound("jumpStart",0.5,_loc2_);
      }
      
      public static function playJumpEnd(param1:Number) : void
      {
         if(timers[3] > 0)
         {
            return;
         }
         timers[3] = gap;
         var _loc2_:Number = (param1 - 512) / 512;
         playSound("jumpEnd",0.5,_loc2_);
      }
      
      public static function playLaser(param1:Number) : void
      {
         if(timers[4] > 0)
         {
            return;
         }
         timers[4] = gap;
         var _loc2_:Number = (param1 - 512) / 512;
         playSound("laser",1,_loc2_);
      }
      
      public static function playCapture(param1:Number) : void
      {
         if(timers[5] > 0)
         {
            return;
         }
         timers[5] = 0.05;
         var _loc3_:Number = (param1 - 512) / 512;
         playSound("capture",1,_loc3_);
      }
      
      public static function playWarp(param1:Number) : void
      {
         if(timers[6] > 0)
         {
            return;
         }
         timers[6] = gap;
         var _loc2_:Number = (param1 - 512) / 512;
         playSound("warp",0.6,_loc2_);
      }
      
      public static function playWarpCharge(param1:Number) : void
      {
         if(timers[7] > 0)
         {
            return;
         }
         timers[7] = gap;
         var _loc2_:Number = (param1 - 512) / 512;
         playSound("warp_charge",0.6,_loc2_);
      }
   }
}
