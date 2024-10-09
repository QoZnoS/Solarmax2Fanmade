// 这是为改版制作的调试用类，在 Root.as 中实例化

package Game
{
    import Game.Entity.Node;
    import Menus.TitleMenu;
    import starling.display.Sprite;
    import starling.events.EnterFrameEvent;
    import starling.text.TextField;

    public class Debug extends Sprite
    {
        public var debug:Boolean; // debug 开启状态
        public var dt:Number; // 帧时间
        public var game:GameScene; // GameScene 接口
        public var title:TitleMenu; // TitleMenu 接口

        public var fpsCalculator:Array; // 帧率计算器
        public var debugLables:Array; // 调试显示文本
        public var nodeTagLables:Array; // 显示天体tag和战争占据状态
        public var nodeConflictLables:Array; // 显示天体战争状态
        public var nodeCaptureLables:Array; // 显示天体占据状态
        // #region 初始化
        public function Debug() // 构造函数
        {
            super();
        }

        public function init(_gameScene:GameScene, _titleMenu:TitleMenu):void // 初始化
        {
            this.game = _gameScene;
            this.title = _titleMenu;
            this.debug = false;
            debugLables = [];
            nodeTagLables = [[],[],[]];
            fpsCalculator = [0, 0, 0, 0, 0, 0, 0];
            addDebugView();
            addEventListener("enterFrame", update);
        }

        public function addDebugView():void
        {
            var _y:Number = 100;
            debugLables.push(new TextField(1000, 40, "DebugView", "Downlink12", -1, 16777215));
            debugLables.push(new TextField(1000, 40, "DebugView", "Downlink12", -1, 16777215));
            debugLables.push(new TextField(1000, 40, "DebugView", "Downlink12", -1, 16777215));
            debugLables.push(new TextField(1000, 40, "DebugView", "Downlink12", -1, 16777215));
            debugLables.push(new TextField(1000, 40, "DebugView", "Downlink12", -1, 16777215));
            debugLables.push(new TextField(1000, 40, "DebugView", "Downlink12", -1, 16777215));
            for each (var _label:TextField in debugLables)
            {
                _label.vAlign = "top";
                _label.hAlign = "left";
                _label.x = 40;
                _label.y = _y;
                _label.alpha = 1;
                _label.visible = false;
                _label.touchable = false;
                addChild(_label);
                _y += 12;
            }
        }
        // #endregion
        // #region 调试函数调用工具
        public function update(e:EnterFrameEvent):void
        {
            if (!debug)
            {
                clear_tag();
                return;
            }
            dt = e.passedTime;
            fpsCalculator[0]++; // 统计帧数
            if (fpsCalculator[0] == 6)
                fpsCalculator[0] -= 5; // 五帧一循环
            fpsCalculator[fpsCalculator[0]] = e.passedTime; // 记录帧时间
            fpsCalculator[6] = 1 / ((fpsCalculator[1] + fpsCalculator[2] + fpsCalculator[3] + fpsCalculator[4] + fpsCalculator[5]) / 5); // 计算帧率
            updateDebugLabel();
            if (game.visible)
                update_in_game();
            else
                clear_tag();
        }

        public function on_key_down(_keyCode:int):void
        {
            if (!debug)
                return;
            switch (_keyCode)
            {
                case 81: // Q 启用 Debug 模式，已移至 Root.as 中
                    break;
                case 87: // W 自由发挥
                    set_orbit_node();
                    break;
                case 69: // E 清空文本
                    clear_debug_trace();
                    break;
                case 82: // R
                    break;
                case 83: // S 
                    break;
                default:
                    break;
            }
        }

        public function startDebugMode():void
        {
            if (debug)
                debug = false;
            else
                debug = true;
            for each (var _label:TextField in debugLables)
            {
                if (_label.visible)
                    _label.visible = false;
                else
                    _label.visible = true;
            }
        }
        // #endregion
        // #region 调试函数，自动触发
        public function updateDebugLabel():void
        {
            if (game.visible)
            {
                debugLables[0].text = "FPS:" + Math.floor(fpsCalculator[6]) + " mouseXY: " + Math.floor(game.ui.debug_mouse_x) + "." + Math.floor(game.ui.debug_mouse_y);
                debugLables[1].text = game.ais.active[0].debugTrace[0];
                debugLables[2].text = game.ais.active[0].debugTrace[1];
                debugLables[3].text = game.ais.active[0].debugTrace[2];
                debugLables[4].text = game.ais.active[0].debugTrace[3];
                debugLables[5].text = game.ais.active[0].debugTrace[4];
            }
            else
            {
                debugLables[1].text = title.optionsMenu.debug;
                debugLables[2].text = "Not in game";
                debugLables[3].text = "Not in game";
                debugLables[4].text = "Not in game";
            }
        }

        public function update_in_game():void
        {
            if (game.nodes.active.length != nodeTagLables[0].length) // 重置tag
                init_tag();
            for each (var _node:Node in game.nodes.active) // 更新tag位置
            {
                nodeTagLables[0][_node.tag].x = _node.x - 30 * _node.size - 60;
                nodeTagLables[0][_node.tag].y = _node.y - 50 * _node.size - 48;
                nodeTagLables[1][_node.tag].x = _node.x;
                nodeTagLables[1][_node.tag].y = _node.y - 50 * _node.size - 50;
                nodeTagLables[2][_node.tag].x = _node.x;
                nodeTagLables[2][_node.tag].y = _node.y - 50 * _node.size - 60;
                if (_node.conflicted)
                    nodeTagLables[1][_node.tag].visible = true;
                else
                    nodeTagLables[1][_node.tag].visible = false;
                if (_node.captured)
                    nodeTagLables[2][_node.tag].visible = true;
                else
                    nodeTagLables[2][_node.tag].visible = false;
            }
        }

        public function init_game():void // 进入游戏时触发一次
        {
            init_tag();
        }

        public function init_tag():void // 重置tag
        {
            clear_tag();
            for each (var _node:Node in game.nodes.active)
            {
                _node.tag = game.nodes.active.indexOf(_node);
                var _label:TextField = new TextField(60, 48, _node.tag, "Downlink12", -1, 16777215);
                _label.vAlign = _label.hAlign = "center";
                _label.pivotX = -30;
                _label.pivotY = -24;
                _label.alpha = 1;
                _label.touchable = false;
                _label.visible = false;
                addChild(_label);
                nodeTagLables[0].push(_label);
                _label = new TextField(60, 48, "conflicted", "Downlink12", -1, 16777215);
                _label.vAlign = _label.hAlign = "center";
                _label.pivotX = -30;
                _label.pivotY = -24;
                _label.alpha = 1;
                _label.touchable = false;
                _label.visible = false;
                addChild(_label);
                nodeTagLables[1].push(_label);
                _label = new TextField(60, 48, "captured", "Downlink12", -1, 16777215);
                _label.vAlign = _label.hAlign = "center";
                _label.pivotX = -30;
                _label.pivotY = -24;
                _label.alpha = 1;
                _label.touchable = false;
                _label.visible = false;
                addChild(_label);
                nodeTagLables[2].push(_label);
            }
        }

        public function clear_tag():void
        {
            if (nodeTagLables.length == 0)
                return;
            for each (var _array:Array in nodeTagLables)
            {
                for each (var _label:TextField in _array)
                {
                    _label.visible = false;
                    removeChild(_label);
                }
            }
            nodeTagLables = [[],[],[]];
        }
        // #endregion
        // #region 调试函数，手动触发
        public function set_orbit_node():void
        {
            var _dx:Number = game.nodes.active[0].x - game.nodes.active[1].x;
            var _dy:Number = game.nodes.active[0].y - game.nodes.active[1].y;
            var _distance:Number = Math.sqrt(_dx * _dx + _dy * _dy);
            var _angle:Number = Math.atan2(_dy, _dx);
            game.nodes.active[0].orbitAngle = _angle;
            game.nodes.active[0].orbitDist = _distance;
            game.nodes.active[0].orbitSpeed = 0.1;
            game.nodes.active[0].orbitNode = game.nodes.active[1];
        }

        public function clear_debug_trace():void
        {
            game.ais.active[0].debugTrace[0] = null;
            game.ais.active[0].debugTrace[1] = null;
            game.ais.active[0].debugTrace[2] = null;
            game.ais.active[0].debugTrace[3] = null;
            game.ais.active[0].debugTrace[4] = null;
        }
        // #endregion
    }
}