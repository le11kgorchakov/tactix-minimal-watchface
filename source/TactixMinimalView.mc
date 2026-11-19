import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class TactixMinimalView extends WatchUi.WatchFace {

    private var _face as FacePainter;
    private var _isAwake as Boolean = true;

    function initialize() {
        WatchFace.initialize();
        _face = new FacePainter();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        _face.layout(dc);
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        _face.draw(dc, _isAwake, false);
    }

    function onExitSleep() as Void {
        _isAwake = true;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void {
        _isAwake = false;
        WatchUi.requestUpdate();
    }
}
