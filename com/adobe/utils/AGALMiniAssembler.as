package com.adobe.utils
{
   import flash.display3D.*;
   import flash.utils.*;
   
   public class AGALMiniAssembler
   {
      
      protected static const REGEXP_OUTER_SPACES:RegExp = /^\s+|\s+$/g;
      
      private static var initialized:Boolean = false;
      
      private static const OPMAP:Dictionary = new Dictionary();
      
      private static const REGMAP:Dictionary = new Dictionary();
      
      private static const SAMPLEMAP:Dictionary = new Dictionary();
      
      private static const MAX_OPCODES:int = 2048;
      
      private static const FRAGMENT:String = "fragment";
      
      private static const VERTEX:String = "vertex";
      
      private static const SAMPLER_TYPE_SHIFT:uint = 8;
      
      private static const SAMPLER_DIM_SHIFT:uint = 12;
      
      private static const SAMPLER_SPECIAL_SHIFT:uint = 16;
      
      private static const SAMPLER_REPEAT_SHIFT:uint = 20;
      
      private static const SAMPLER_MIPMAP_SHIFT:uint = 24;
      
      private static const SAMPLER_FILTER_SHIFT:uint = 28;
      
      private static const REG_WRITE:uint = 1;
      
      private static const REG_READ:uint = 2;
      
      private static const REG_FRAG:uint = 32;
      
      private static const REG_VERT:uint = 64;
      
      private static const OP_SCALAR:uint = 1;
      
      private static const OP_SPECIAL_TEX:uint = 8;
      
      private static const OP_SPECIAL_MATRIX:uint = 16;
      
      private static const OP_FRAG_ONLY:uint = 32;
      
      private static const OP_VERT_ONLY:uint = 64;
      
      private static const OP_NO_DEST:uint = 128;
      
      private static const OP_VERSION2:uint = 256;
      
      private static const OP_INCNEST:uint = 512;
      
      private static const OP_DECNEST:uint = 1024;
      
      private static const MOV:String = "mov";
      
      private static const ADD:String = "add";
      
      private static const SUB:String = "sub";
      
      private static const MUL:String = "mul";
      
      private static const DIV:String = "div";
      
      private static const RCP:String = "rcp";
      
      private static const MIN:String = "min";
      
      private static const MAX:String = "max";
      
      private static const FRC:String = "frc";
      
      private static const SQT:String = "sqt";
      
      private static const RSQ:String = "rsq";
      
      private static const POW:String = "pow";
      
      private static const LOG:String = "log";
      
      private static const EXP:String = "exp";
      
      private static const NRM:String = "nrm";
      
      private static const SIN:String = "sin";
      
      private static const COS:String = "cos";
      
      private static const CRS:String = "crs";
      
      private static const DP3:String = "dp3";
      
      private static const DP4:String = "dp4";
      
      private static const ABS:String = "abs";
      
      private static const NEG:String = "neg";
      
      private static const SAT:String = "sat";
      
      private static const M33:String = "m33";
      
      private static const M44:String = "m44";
      
      private static const M34:String = "m34";
      
      private static const DDX:String = "ddx";
      
      private static const DDY:String = "ddy";
      
      private static const IFE:String = "ife";
      
      private static const INE:String = "ine";
      
      private static const IFG:String = "ifg";
      
      private static const IFL:String = "ifl";
      
      private static const ELS:String = "els";
      
      private static const EIF:String = "eif";
      
      private static const TED:String = "ted";
      
      private static const KIL:String = "kil";
      
      private static const TEX:String = "tex";
      
      private static const SGE:String = "sge";
      
      private static const SLT:String = "slt";
      
      private static const SGN:String = "sgn";
      
      private static const SEQ:String = "seq";
      
      private static const SNE:String = "sne";
      
      private static const VA:String = "va";
      
      private static const VC:String = "vc";
      
      private static const VT:String = "vt";
      
      private static const VO:String = "vo";
      
      private static const VI:String = "vi";
      
      private static const FC:String = "fc";
      
      private static const FT:String = "ft";
      
      private static const FS:String = "fs";
      
      private static const FO:String = "fo";
      
      private static const FD:String = "fd";
      
      private static const D2:String = "2d";
      
      private static const D3:String = "3d";
      
      private static const CUBE:String = "cube";
      
      private static const MIPNEAREST:String = "mipnearest";
      
      private static const MIPLINEAR:String = "miplinear";
      
      private static const MIPNONE:String = "mipnone";
      
      private static const NOMIP:String = "nomip";
      
      private static const NEAREST:String = "nearest";
      
      private static const LINEAR:String = "linear";
      
      private static const CENTROID:String = "centroid";
      
      private static const SINGLE:String = "single";
      
      private static const IGNORESAMPLER:String = "ignoresampler";
      
      private static const REPEAT:String = "repeat";
      
      private static const WRAP:String = "wrap";
      
      private static const CLAMP:String = "clamp";
      
      private static const RGBA:String = "rgba";
      
      private static const DXT1:String = "dxt1";
      
      private static const DXT5:String = "dxt5";
      
      private static const VIDEO:String = "video";
       
      
      private var _agalcode:ByteArray = null;
      
      private var _error:String = "";
      
      private var debugEnabled:Boolean = false;
      
      public var verbose:Boolean = false;
      
      public function AGALMiniAssembler(param1:Boolean = false)
      {
         super();
         debugEnabled = param1;
         if(!initialized)
         {
            init();
         }
      }
      
      private static function init() : void
      {
         initialized = true;
         OPMAP["mov"] = new OpCode("mov",2,0,0);
         OPMAP["add"] = new OpCode("add",3,1,0);
         OPMAP["sub"] = new OpCode("sub",3,2,0);
         OPMAP["mul"] = new OpCode("mul",3,3,0);
         OPMAP["div"] = new OpCode("div",3,4,0);
         OPMAP["rcp"] = new OpCode("rcp",2,5,0);
         OPMAP["min"] = new OpCode("min",3,6,0);
         OPMAP["max"] = new OpCode("max",3,7,0);
         OPMAP["frc"] = new OpCode("frc",2,8,0);
         OPMAP["sqt"] = new OpCode("sqt",2,9,0);
         OPMAP["rsq"] = new OpCode("rsq",2,10,0);
         OPMAP["pow"] = new OpCode("pow",3,11,0);
         OPMAP["log"] = new OpCode("log",2,12,0);
         OPMAP["exp"] = new OpCode("exp",2,13,0);
         OPMAP["nrm"] = new OpCode("nrm",2,14,0);
         OPMAP["sin"] = new OpCode("sin",2,15,0);
         OPMAP["cos"] = new OpCode("cos",2,16,0);
         OPMAP["crs"] = new OpCode("crs",3,17,0);
         OPMAP["dp3"] = new OpCode("dp3",3,18,0);
         OPMAP["dp4"] = new OpCode("dp4",3,19,0);
         OPMAP["abs"] = new OpCode("abs",2,20,0);
         OPMAP["neg"] = new OpCode("neg",2,21,0);
         OPMAP["sat"] = new OpCode("sat",2,22,0);
         OPMAP["m33"] = new OpCode("m33",3,23,16);
         OPMAP["m44"] = new OpCode("m44",3,24,16);
         OPMAP["m34"] = new OpCode("m34",3,25,16);
         OPMAP["ddx"] = new OpCode("ddx",2,26,288);
         OPMAP["ddy"] = new OpCode("ddy",2,27,288);
         OPMAP["ife"] = new OpCode("ife",2,28,897);
         OPMAP["ine"] = new OpCode("ine",2,29,897);
         OPMAP["ifg"] = new OpCode("ifg",2,30,897);
         OPMAP["ifl"] = new OpCode("ifl",2,31,897);
         OPMAP["els"] = new OpCode("els",0,32,1921);
         OPMAP["eif"] = new OpCode("eif",0,33,1409);
         OPMAP["ted"] = new OpCode("ted",3,38,296);
         OPMAP["kil"] = new OpCode("kil",1,39,160);
         OPMAP["tex"] = new OpCode("tex",3,40,40);
         OPMAP["sge"] = new OpCode("sge",3,41,0);
         OPMAP["slt"] = new OpCode("slt",3,42,0);
         OPMAP["sgn"] = new OpCode("sgn",2,43,0);
         OPMAP["seq"] = new OpCode("seq",3,44,0);
         OPMAP["sne"] = new OpCode("sne",3,45,0);
         SAMPLEMAP["rgba"] = new Sampler("rgba",8,0);
         SAMPLEMAP["dxt1"] = new Sampler("dxt1",8,1);
         SAMPLEMAP["dxt5"] = new Sampler("dxt5",8,2);
         SAMPLEMAP["video"] = new Sampler("video",8,3);
         SAMPLEMAP["2d"] = new Sampler("2d",12,0);
         SAMPLEMAP["3d"] = new Sampler("3d",12,2);
         SAMPLEMAP["cube"] = new Sampler("cube",12,1);
         SAMPLEMAP["mipnearest"] = new Sampler("mipnearest",24,1);
         SAMPLEMAP["miplinear"] = new Sampler("miplinear",24,2);
         SAMPLEMAP["mipnone"] = new Sampler("mipnone",24,0);
         SAMPLEMAP["nomip"] = new Sampler("nomip",24,0);
         SAMPLEMAP["nearest"] = new Sampler("nearest",28,0);
         SAMPLEMAP["linear"] = new Sampler("linear",28,1);
         SAMPLEMAP["centroid"] = new Sampler("centroid",16,1);
         SAMPLEMAP["single"] = new Sampler("single",16,2);
         SAMPLEMAP["ignoresampler"] = new Sampler("ignoresampler",16,4);
         SAMPLEMAP["repeat"] = new Sampler("repeat",20,1);
         SAMPLEMAP["wrap"] = new Sampler("wrap",20,1);
         SAMPLEMAP["clamp"] = new Sampler("clamp",20,0);
      }
      
      public function get error() : String
      {
         return _error;
      }
      
      public function get agalcode() : ByteArray
      {
         return _agalcode;
      }
      
      public function assemble2(param1:Context3D, param2:uint, param3:String, param4:String) : Program3D
      {
         var _loc6_:ByteArray = assemble("vertex",param3,param2);
         var _loc7_:ByteArray = assemble("fragment",param4,param2);
         var _loc5_:Program3D;
         (_loc5_ = param1.createProgram()).upload(_loc6_,_loc7_);
         return _loc5_;
      }
      
      public function assemble(param1:String, param2:String, param3:uint = 1, param4:Boolean = false) : ByteArray
      {
         var _loc42_:int = 0;
         var _loc30_:String = null;
         var _loc22_:int = 0;
         var _loc28_:int = 0;
         var _loc5_:Array = null;
         var _loc34_:Array = null;
         var _loc10_:OpCode = null;
         var _loc17_:Array = null;
         var _loc43_:Boolean = false;
         var _loc39_:* = 0;
         var _loc29_:* = 0;
         var _loc40_:int = 0;
         var _loc35_:Boolean = false;
         var _loc16_:Array = null;
         var _loc27_:Array = null;
         var _loc9_:Register = null;
         var _loc15_:Array = null;
         var _loc19_:* = 0;
         var _loc48_:* = 0;
         var _loc49_:Array = null;
         var _loc33_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc24_:* = 0;
         var _loc20_:* = 0;
         var _loc8_:int = 0;
         var _loc18_:* = 0;
         var _loc31_:* = 0;
         var _loc41_:int = 0;
         var _loc11_:Array = null;
         var _loc26_:Register = null;
         var _loc6_:Array = null;
         var _loc38_:Array = null;
         var _loc45_:* = 0;
         var _loc13_:* = 0;
         var _loc12_:Number = NaN;
         var _loc44_:Sampler = null;
         var _loc36_:String = null;
         var _loc37_:* = 0;
         var _loc14_:* = 0;
         var _loc47_:String = null;
         var _loc23_:uint = uint(getTimer());
         _agalcode = new ByteArray();
         _error = "";
         var _loc46_:Boolean = false;
         if(param1 == "fragment")
         {
            _loc46_ = true;
         }
         else if(param1 != "vertex")
         {
            _error = "ERROR: mode needs to be \"fragment\" or \"vertex\" but is \"" + param1 + "\".";
         }
         agalcode.endian = "littleEndian";
         agalcode.writeByte(160);
         agalcode.writeUnsignedInt(param3);
         agalcode.writeByte(161);
         agalcode.writeByte(_loc46_ ? 1 : 0);
         initregmap(param3,param4);
         var _loc25_:Array = param2.replace(/[\f\n\r\v]+/g,"\n").split("\n");
         var _loc21_:int = 0;
         var _loc32_:int = int(_loc25_.length);
         _loc42_ = 0;
         while(_loc42_ < _loc32_ && _error == "")
         {
            if((_loc22_ = (_loc30_ = (_loc30_ = new String(_loc25_[_loc42_])).replace(REGEXP_OUTER_SPACES,"")).search("//")) != -1)
            {
               _loc30_ = _loc30_.slice(0,_loc22_);
            }
            if((_loc28_ = _loc30_.search(/<.*>/g)) != -1)
            {
               _loc5_ = _loc30_.slice(_loc28_).match(/([\w\.\-\+]+)/gi);
               _loc30_ = _loc30_.slice(0,_loc28_);
            }
            if(!(_loc34_ = _loc30_.match(/^\w{3}/gi)))
            {
               if(_loc30_.length >= 3)
               {
                  trace("warning: bad line " + _loc42_ + ": " + _loc25_[_loc42_]);
               }
            }
            else
            {
               _loc10_ = OPMAP[_loc34_[0]];
               if(debugEnabled)
               {
                  trace(_loc10_);
               }
               if(_loc10_ == null)
               {
                  if(_loc30_.length >= 3)
                  {
                     trace("warning: bad line " + _loc42_ + ": " + _loc25_[_loc42_]);
                  }
               }
               else
               {
                  _loc30_ = _loc30_.slice(_loc30_.search(_loc10_.name) + _loc10_.name.length);
                  if(_loc10_.flags & 256 && param3 < 2)
                  {
                     _error = "error: opcode requires version 2.";
                     break;
                  }
                  if(_loc10_.flags & 64 && _loc46_)
                  {
                     _error = "error: opcode is only allowed in vertex programs.";
                     break;
                  }
                  if(_loc10_.flags & 32 && !_loc46_)
                  {
                     _error = "error: opcode is only allowed in fragment programs.";
                     break;
                  }
                  if(verbose)
                  {
                     trace("emit opcode=" + _loc10_);
                  }
                  agalcode.writeUnsignedInt(_loc10_.emitCode);
                  _loc21_++;
                  if(_loc21_ > 2048)
                  {
                     _error = "error: too many opcodes. maximum is 2048.";
                     break;
                  }
                  if(!(_loc17_ = _loc30_.match(/vc\[([vof][acostdip]?)(\d*)?(\.[xyzw](\+\d{1,3})?)?\](\.[xyzw]{1,4})?|([vof][acostdip]?)(\d*)?(\.[xyzw]{1,4})?/gi)) || _loc17_.length != _loc10_.numRegister)
                  {
                     _error = "error: wrong number of operands. found " + _loc17_.length + " but expected " + _loc10_.numRegister + ".";
                     break;
                  }
                  _loc43_ = false;
                  _loc39_ = 160;
                  _loc29_ = _loc17_.length;
                  _loc40_ = 0;
                  while(_loc40_ < _loc29_)
                  {
                     _loc35_ = false;
                     if((_loc16_ = _loc17_[_loc40_].match(/\[.*\]/gi)) && _loc16_.length > 0)
                     {
                        _loc17_[_loc40_] = _loc17_[_loc40_].replace(_loc16_[0],"0");
                        if(verbose)
                        {
                           trace("IS REL");
                        }
                        _loc35_ = true;
                     }
                     if(!(_loc27_ = _loc17_[_loc40_].match(/^\b[A-Za-z]{1,2}/gi)))
                     {
                        _error = "error: could not parse operand " + _loc40_ + " (" + _loc17_[_loc40_] + ").";
                        _loc43_ = true;
                        break;
                     }
                     _loc9_ = REGMAP[_loc27_[0]];
                     if(debugEnabled)
                     {
                        trace(_loc9_);
                     }
                     if(_loc9_ == null)
                     {
                        _error = "error: could not find register name for operand " + _loc40_ + " (" + _loc17_[_loc40_] + ").";
                        _loc43_ = true;
                        break;
                     }
                     if(_loc46_)
                     {
                        if(!(_loc9_.flags & 32))
                        {
                           _error = "error: register operand " + _loc40_ + " (" + _loc17_[_loc40_] + ") only allowed in vertex programs.";
                           _loc43_ = true;
                           break;
                        }
                        if(_loc35_)
                        {
                           _error = "error: register operand " + _loc40_ + " (" + _loc17_[_loc40_] + ") relative adressing not allowed in fragment programs.";
                           _loc43_ = true;
                           break;
                        }
                     }
                     else if(!(_loc9_.flags & 64))
                     {
                        _error = "error: register operand " + _loc40_ + " (" + _loc17_[_loc40_] + ") only allowed in fragment programs.";
                        _loc43_ = true;
                        break;
                     }
                     _loc17_[_loc40_] = _loc17_[_loc40_].slice(_loc17_[_loc40_].search(_loc9_.name) + _loc9_.name.length);
                     _loc15_ = _loc35_ ? _loc16_[0].match(/\d+/) : _loc17_[_loc40_].match(/\d+/);
                     _loc19_ = 0;
                     if(_loc15_)
                     {
                        _loc19_ = uint(_loc15_[0]);
                     }
                     if(_loc9_.range < _loc19_)
                     {
                        _error = "error: register operand " + _loc40_ + " (" + _loc17_[_loc40_] + ") index exceeds limit of " + (_loc9_.range + 1) + ".";
                        _loc43_ = true;
                        break;
                     }
                     _loc48_ = 0;
                     _loc49_ = _loc17_[_loc40_].match(/(\.[xyzw]{1,4})/);
                     _loc33_ = _loc40_ == 0 && !(_loc10_.flags & 128);
                     _loc7_ = _loc40_ == 2 && _loc10_.flags & 8;
                     _loc24_ = 0;
                     _loc20_ = 0;
                     _loc8_ = 0;
                     if(_loc33_ && _loc35_)
                     {
                        _error = "error: relative can not be destination";
                        _loc43_ = true;
                        break;
                     }
                     if(_loc49_)
                     {
                        _loc48_ = 0;
                        _loc31_ = uint(_loc49_[0].length);
                        _loc41_ = 1;
                        while(_loc41_ < _loc31_)
                        {
                           if((_loc18_ = _loc49_[0].charCodeAt(_loc41_) - "x".charCodeAt(0)) > 2)
                           {
                              _loc18_ = 3;
                           }
                           if(_loc33_)
                           {
                              _loc48_ |= 1 << _loc18_;
                           }
                           else
                           {
                              _loc48_ |= _loc18_ << (_loc41_ - 1 << 1);
                           }
                           _loc41_++;
                        }
                        if(!_loc33_)
                        {
                           while(_loc41_ <= 4)
                           {
                              _loc48_ |= _loc18_ << (_loc41_ - 1 << 1);
                              _loc41_++;
                           }
                        }
                     }
                     else
                     {
                        _loc48_ = _loc33_ ? 15 : 228;
                     }
                     if(_loc35_)
                     {
                        _loc11_ = _loc16_[0].match(/[A-Za-z]{1,2}/gi);
                        if((_loc26_ = REGMAP[_loc11_[0]]) == null)
                        {
                           _error = "error: bad index register";
                           _loc43_ = true;
                           break;
                        }
                        _loc24_ = _loc26_.emitCode;
                        if((_loc6_ = _loc16_[0].match(/(\.[xyzw]{1,1})/)).length == 0)
                        {
                           _error = "error: bad index register select";
                           _loc43_ = true;
                           break;
                        }
                        if((_loc20_ = _loc6_[0].charCodeAt(1) - "x".charCodeAt(0)) > 2)
                        {
                           _loc20_ = 3;
                        }
                        if((_loc38_ = _loc16_[0].match(/\+\d{1,3}/gi)).length > 0)
                        {
                           _loc8_ = int(_loc38_[0]);
                        }
                        if(_loc8_ < 0 || _loc8_ > 255)
                        {
                           _error = "error: index offset " + _loc8_ + " out of bounds. [0..255]";
                           _loc43_ = true;
                           break;
                        }
                        if(verbose)
                        {
                           trace("RELATIVE: type=" + _loc24_ + "==" + _loc11_[0] + " sel=" + _loc20_ + "==" + _loc6_[0] + " idx=" + _loc19_ + " offset=" + _loc8_);
                        }
                     }
                     if(verbose)
                     {
                        trace("  emit argcode=" + _loc9_ + "[" + _loc19_ + "][" + _loc48_ + "]");
                     }
                     if(_loc33_)
                     {
                        agalcode.writeShort(_loc19_);
                        agalcode.writeByte(_loc48_);
                        agalcode.writeByte(_loc9_.emitCode);
                        _loc39_ -= 32;
                     }
                     else if(_loc7_)
                     {
                        if(verbose)
                        {
                           trace("  emit sampler");
                        }
                        _loc45_ = 5;
                        _loc13_ = uint(_loc5_ == null ? 0 : _loc5_.length);
                        _loc12_ = 0;
                        _loc41_ = 0;
                        while(_loc41_ < _loc13_)
                        {
                           if(verbose)
                           {
                              trace("    opt: " + _loc5_[_loc41_]);
                           }
                           if((_loc44_ = SAMPLEMAP[_loc5_[_loc41_]]) == null)
                           {
                              _loc12_ = Number(_loc5_[_loc41_]);
                              if(verbose)
                              {
                                 trace("    bias: " + _loc12_);
                              }
                           }
                           else
                           {
                              if(_loc44_.flag != 16)
                              {
                                 _loc45_ &= ~(15 << _loc44_.flag);
                              }
                              _loc45_ |= _loc44_.mask << _loc44_.flag;
                           }
                           _loc41_++;
                        }
                        agalcode.writeShort(_loc19_);
                        agalcode.writeByte(int(_loc12_ * 8));
                        agalcode.writeByte(0);
                        agalcode.writeUnsignedInt(_loc45_);
                        if(verbose)
                        {
                           trace("    bits: " + (_loc45_ - 5));
                        }
                        _loc39_ -= 64;
                     }
                     else
                     {
                        if(_loc40_ == 0)
                        {
                           agalcode.writeUnsignedInt(0);
                           _loc39_ -= 32;
                        }
                        agalcode.writeShort(_loc19_);
                        agalcode.writeByte(_loc8_);
                        agalcode.writeByte(_loc48_);
                        agalcode.writeByte(_loc9_.emitCode);
                        agalcode.writeByte(_loc24_);
                        agalcode.writeShort(_loc35_ ? _loc20_ | 32768 : 0);
                        _loc39_ -= 64;
                     }
                     _loc40_++;
                  }
                  _loc40_ = 0;
                  while(_loc40_ < _loc39_)
                  {
                     agalcode.writeByte(0);
                     _loc40_ += 8;
                  }
                  if(_loc43_)
                  {
                     break;
                  }
               }
            }
            _loc42_++;
         }
         if(_error != "")
         {
            _error += "\n  at line " + _loc42_ + " " + _loc25_[_loc42_];
            agalcode.length = 0;
            trace(_error);
         }
         if(debugEnabled)
         {
            _loc36_ = "generated bytecode:";
            _loc37_ = agalcode.length;
            _loc14_ = 0;
            while(_loc14_ < _loc37_)
            {
               if(!(_loc14_ % 16))
               {
                  _loc36_ += "\n";
               }
               if(!(_loc14_ % 4))
               {
                  _loc36_ += " ";
               }
               if((_loc47_ = String(agalcode[_loc14_].toString(16))).length < 2)
               {
                  _loc47_ = "0" + _loc47_;
               }
               _loc36_ += _loc47_;
               _loc14_++;
            }
            trace(_loc36_);
         }
         if(verbose)
         {
            trace("AGALMiniAssembler.assemble time: " + (getTimer() - _loc23_) / 1000 + "s");
         }
         return agalcode;
      }
      
      private function initregmap(param1:uint, param2:Boolean) : void
      {
         REGMAP["va"] = new Register("va","vertex attribute",0,param2 ? 1024 : 7,66);
         REGMAP["vc"] = new Register("vc","vertex constant",1,param2 ? 1024 : (param1 == 1 ? 127 : 250),66);
         REGMAP["vt"] = new Register("vt","vertex temporary",2,param2 ? 1024 : (param1 == 1 ? 7 : 27),67);
         REGMAP["vo"] = new Register("vo","vertex output",3,param2 ? 1024 : 0,65);
         REGMAP["vi"] = new Register("vi","varying",4,param2 ? 1024 : (param1 == 1 ? 7 : 11),99);
         REGMAP["fc"] = new Register("fc","fragment constant",1,param2 ? 1024 : (param1 == 1 ? 27 : 63),34);
         REGMAP["ft"] = new Register("ft","fragment temporary",2,param2 ? 1024 : (param1 == 1 ? 7 : 27),35);
         REGMAP["fs"] = new Register("fs","texture sampler",5,param2 ? 1024 : 7,34);
         REGMAP["fo"] = new Register("fo","fragment output",3,param2 ? 1024 : (param1 == 1 ? 0 : 3),33);
         REGMAP["fd"] = new Register("fd","fragment depth output",6,param2 ? 1024 : (param1 == 1 ? -1 : 0),33);
         REGMAP["op"] = REGMAP["vo"];
         REGMAP["i"] = REGMAP["vi"];
         REGMAP["v"] = REGMAP["vi"];
         REGMAP["oc"] = REGMAP["fo"];
         REGMAP["od"] = REGMAP["fd"];
         REGMAP["fi"] = REGMAP["vi"];
      }
   }
}

class OpCode
{
    
   
   private var _emitCode:uint;
   
   private var _flags:uint;
   
   private var _name:String;
   
   private var _numRegister:uint;
   
   public function OpCode(param1:String, param2:uint, param3:uint, param4:uint)
   {
      super();
      _name = param1;
      _numRegister = param2;
      _emitCode = param3;
      _flags = param4;
   }
   
   public function get emitCode() : uint
   {
      return _emitCode;
   }
   
   public function get flags() : uint
   {
      return _flags;
   }
   
   public function get name() : String
   {
      return _name;
   }
   
   public function get numRegister() : uint
   {
      return _numRegister;
   }
   
   public function toString() : String
   {
      return "[OpCode name=\"" + _name + "\", numRegister=" + _numRegister + ", emitCode=" + _emitCode + ", flags=" + _flags + "]";
   }
}

class Register
{
    
   
   private var _emitCode:uint;
   
   private var _name:String;
   
   private var _longName:String;
   
   private var _flags:uint;
   
   private var _range:uint;
   
   public function Register(param1:String, param2:String, param3:uint, param4:uint, param5:uint)
   {
      super();
      _name = param1;
      _longName = param2;
      _emitCode = param3;
      _range = param4;
      _flags = param5;
   }
   
   public function get emitCode() : uint
   {
      return _emitCode;
   }
   
   public function get longName() : String
   {
      return _longName;
   }
   
   public function get name() : String
   {
      return _name;
   }
   
   public function get flags() : uint
   {
      return _flags;
   }
   
   public function get range() : uint
   {
      return _range;
   }
   
   public function toString() : String
   {
      return "[Register name=\"" + _name + "\", longName=\"" + _longName + "\", emitCode=" + _emitCode + ", range=" + _range + ", flags=" + _flags + "]";
   }
}

class Sampler
{
    
   
   private var _flag:uint;
   
   private var _mask:uint;
   
   private var _name:String;
   
   public function Sampler(param1:String, param2:uint, param3:uint)
   {
      super();
      _name = param1;
      _flag = param2;
      _mask = param3;
   }
   
   public function get flag() : uint
   {
      return _flag;
   }
   
   public function get mask() : uint
   {
      return _mask;
   }
   
   public function get name() : String
   {
      return _name;
   }
   
   public function toString() : String
   {
      return "[Sampler name=\"" + _name + "\", flag=\"" + _flag + "\", mask=" + mask + "]";
   }
}
