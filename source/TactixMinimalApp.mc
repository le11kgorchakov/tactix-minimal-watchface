import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TactixMinimalApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
        Settings.load();
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        return [new TactixMinimalView()];
    }

    function getSettingsView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] or Null {
        return [new SettingsMenu(), new SettingsMenuDelegate()];
    }

    function onSettingsChanged() as Void {
        Settings.load();
        WatchUi.requestUpdate();
    }
}
