package
{
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import starling.errors.AbstractClassError;

   public class Globals
   {
      public static var main:Main;
      public static var level:int = 0; // 关卡
      public static var scaleFactor:Number = 2; // 比例因子
      public static var margin:Number = 0; // 边距，Main中设定30，影响按钮到左右两侧的相对位置
      public static var soundMult:Number = 1; // 
      public static var musicMult:Number = 1; // 未采用参数
      public static var stageWidth:Number = 1920; // 画面宽度
      public static var stageHeight:Number = 1080; // 画面高度
      public static var device:String = "pc"; // 设备类型
      public static var teamColors:Array = [13421772, 6272767, 16735635, 16747610, 13303662, 10066329, 0]; // 势力颜色
      public static var teamCaps:Array = [0,0,0,0,0,0,0]; // 势力在关卡内的总飞船上限
      public static var teamPops:Array = [0,0,0,0,0,0,0]; // 势力在关卡内的总飞船数
      public static var teamCount:int = 7; // 势力总数

      public static var file:File; // 文件
      public static var fileStream:FileStream;
      // 以下为存档数据
      public static var playerData:Array; // 储存玩家存档，与playerData.txt同步
      public static var levelReached:int = 0; // 已通过关卡，playerData.txt第一项
      public static var soundVolume:Number = 1; // 音乐音量，playerData.txt第二项
      public static var musicVolume:Number = 1; // 音效音量，playerData.txt第三项
      public static var transitionSpeed:Number = 1; // 动画时长，playerData.txt第四项
      public static var bgSaturation:Number = 1; // 未采用参数，playerData.txt第五项
      public static var textSize:int = 1; // 文本大小参数，playerData.txt第六项
      public static var resolution:String = "1920x1080"; // 未采用参数，playerData.txt第七项
      public static var fullscreen:Boolean = false; // 是否全屏，playerData.txt第八项
      public static var antialias:int = 3; // 抗锯齿参数，playerData.txt第九项
      public static var kills:Number = 0; // 未采用参数，playerData.txt第十项
      public static var losses:Number = 0; // 未采用参数，playerData.txt第十一项
      public static var colonized:Number = 0; // 未采用参数，playerData.txt第十二项
      public static var decolonized:Number = 0; // 未采用参数，playerData.txt第十三项
      public static var nodeslost:Number = 0; // 未采用参数，playerData.txt第十四项
      public static var additiveGlow:Boolean = true; // 未采用参数，playerData.txt第十五项
      public static var touchControls:Boolean = true; // 控制方式，playerData.txt第十六项
      public static var levelData:Array = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]; // 每关已获取的星数，playerData.txt第十七项
      public static var currentDifficulty:int = 2; // 当前难度，playerData.txt第十八项，levelData后第一项
      public static var blackQuad:Boolean = true; // 是否生成黑边，playerData.txt第十九项，levelData后第二项
      public static var currentData:int = 0; // 当前关卡数据，playerData.txt第二十项，levelData后第三项
      public static var nohup:Boolean = false; // 禁用暂停，playerData.txt第二十一项，levelData后第四项

      public function Globals()
      {
         super();
         throw new AbstractClassError();
      }

      public static function init():void 
      {
         trace("I'm alive!"); // 输出到控制台，游戏内看不到
      }

      public static function load():void // 加载存档文件
      {
         var _data:String = null; // 字符串，储存存档
         file = File.applicationStorageDirectory.resolvePath("playerData.txt"); // 读取文件playData.txt
         fileStream = new FileStream();
         if (!file.exists) // 如果文件不存在
         {
            // 储存默认数据到playerData.txt
            playerData = [levelReached, soundVolume, musicVolume, transitionSpeed, bgSaturation, textSize, resolution, fullscreen, antialias, kills, losses, colonized, decolonized, nodeslost, additiveGlow, touchControls, levelData, currentDifficulty, blackQuad, currentData, nohup];
            save(); // 保存存档文件到本地
         }
         else // 如果文件存在
         {
            fileStream.open(file, "read"); // 以只读模式打开文件
            _data = String(fileStream.readMultiByte(fileStream.bytesAvailable, "utf-8")); // 按utf-8编码读取并转换成字符串
            fileStream.close(); // 关闭文件
            playerData = JSON.parse(_data) as Array;
            // 接下来依次读取playerData中的各项数据
            levelReached = playerData[0];
            soundVolume = playerData[1];
            musicVolume = playerData[2];
            transitionSpeed = playerData[3];
            bgSaturation = playerData[4];
            textSize = playerData[5];
            resolution = playerData[6];
            fullscreen = playerData[7];
            antialias = playerData[8];
            kills = playerData[9];
            losses = playerData[10];
            colonized = playerData[11];
            decolonized = playerData[12];
            nodeslost = playerData[13];
            additiveGlow = playerData[14];
            touchControls = playerData[15];
            levelData = playerData[16];
            currentDifficulty = playerData[17];
            blackQuad = playerData[18];
            currentData = playerData[19];
            nohup = playerData[20];
         }
         main.start(); // 执行main.as中的start()
      }

      public static function save():void // 保存存档文件
      {
         playerData = [levelReached, soundVolume, musicVolume, transitionSpeed, bgSaturation, textSize, resolution, fullscreen, antialias, kills, losses, colonized, decolonized, nodeslost, additiveGlow, touchControls, levelData, currentDifficulty, blackQuad, currentData, nohup];
         var _data:String = JSON.stringify(playerData); // 将playerData转换为json字符串
         fileStream.open(file, "write"); // 以写入模式打开文件
         fileStream.writeUTFBytes(_data); 
         fileStream.close(); // 关闭文件
      }
   }
}
