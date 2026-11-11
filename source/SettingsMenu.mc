import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.WatchUi;

// On-watch Customize menu; edits the same properties as the Connect IQ phone settings.
module SettingsOptions {

    function forKey(key as String) as Array<ResourceId> {
        if (key.equals(Settings.DISPLAY_MODE)) {
            return [Rez.Strings.DisplayModeDigital, Rez.Strings.DisplayModeAnalog];
        }
        if (key.equals(Settings.ACCENT_COLOR)) {
            return [Rez.Strings.ColorOlive, Rez.Strings.ColorOrange, Rez.Strings.ColorCyan, Rez.Strings.ColorWhite, Rez.Strings.ColorRed];
        }
        if (key.equals(Settings.HOURS_COLOR) || key.equals(Settings.MINUTES_COLOR)) {
            return [Rez.Strings.ColorMatchAccent, Rez.Strings.ColorWhite, Rez.Strings.ColorLightGrey, Rez.Strings.ColorOlive, Rez.Strings.ColorOrange, Rez.Strings.ColorCyan, Rez.Strings.ColorRed];
        }
        if (key.equals(Settings.TIME_FONT)) {
            return [Rez.Strings.FontCondensed, Rez.Strings.FontBold, Rez.Strings.FontRegular];
        }
        if (key.equals(Settings.HOURS_SIZE) || key.equals(Settings.MINUTES_SIZE)) {
            return [Rez.Strings.SizeSmall, Rez.Strings.SizeMedium, Rez.Strings.SizeLarge, Rez.Strings.SizeExtraLarge];
        }
        if (key.equals(Settings.DATE_FORMAT)) {
            return [Rez.Strings.DateFormat0, Rez.Strings.DateFormat1, Rez.Strings.DateFormat2, Rez.Strings.DateFormat3, Rez.Strings.DateFormat4];
        }
        return [Rez.Strings.TimeFormatSystem, Rez.Strings.TimeFormat24];
    }

    function selected(key as String) as Number {
        var options = forKey(key);
        return Settings.getIndex(key, options.size(), 0);
    }
}

class SettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => Rez.Strings.CustomizeTitle});
        addList(Settings.DISPLAY_MODE, Rez.Strings.DisplayModeTitle);
        addList(Settings.ACCENT_COLOR, Rez.Strings.AccentColorTitle);
        addList(Settings.HOURS_COLOR, Rez.Strings.HoursColorTitle);
        addList(Settings.MINUTES_COLOR, Rez.Strings.MinutesColorTitle);
        addList(Settings.TIME_FONT, Rez.Strings.TimeFontTitle);
        addList(Settings.HOURS_SIZE, Rez.Strings.HoursSizeTitle);
        addList(Settings.MINUTES_SIZE, Rez.Strings.MinutesSizeTitle);
        addToggle(Settings.SHOW_COLON, Rez.Strings.ShowColonTitle);
        addToggle(Settings.SHOW_DATE, Rez.Strings.ShowDateTitle);
        addList(Settings.DATE_FORMAT, Rez.Strings.DateFormatTitle);
        addList(Settings.TIME_FORMAT, Rez.Strings.TimeFormatTitle);
        addToggle(Settings.SHOW_BATTERY, Rez.Strings.ShowBatteryTitle);
        addToggle(Settings.SHOW_BATTERY_DAYS, Rez.Strings.ShowBatteryDaysTitle);
        addToggle(Settings.SHOW_BATTERY_ARC, Rez.Strings.ShowBatteryArcTitle);
        addToggle(Settings.SHOW_TICKS, Rez.Strings.ShowTicksTitle);
    }

    private function addList(key as String, title as ResourceId) as Void {
        var options = SettingsOptions.forKey(key);
        addItem(new WatchUi.MenuItem(title, options[SettingsOptions.selected(key)], key, null));
    }

    private function addToggle(key as String, title as ResourceId) as Void {
        addItem(new WatchUi.ToggleMenuItem(title, null, key, Settings.getFlag(key), null));
    }
}

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var key = item.getId() as String;
        if (item instanceof WatchUi.ToggleMenuItem) {
            Properties.setValue(key, item.isEnabled());
            Settings.load();
            WatchUi.requestUpdate();
            return;
        }
        WatchUi.pushView(new OptionPickerMenu(item.getLabel(), key), new OptionPickerDelegate(item, key), WatchUi.SLIDE_LEFT);
    }
}

class OptionPickerMenu extends WatchUi.Menu2 {

    function initialize(title as String, key as String) {
        Menu2.initialize({:title => title});
        var options = SettingsOptions.forKey(key);
        var current = SettingsOptions.selected(key);
        for (var i = 0; i < options.size(); i++) {
            addItem(new WatchUi.MenuItem(options[i], i == current ? "Selected" : null, i, null));
        }
    }
}

class OptionPickerDelegate extends WatchUi.Menu2InputDelegate {

    private var _parentItem as WatchUi.MenuItem;
    private var _key as String;

    function initialize(parentItem as WatchUi.MenuItem, key as String) {
        Menu2InputDelegate.initialize();
        _parentItem = parentItem;
        _key = key;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var index = item.getId() as Number;
        Properties.setValue(_key, index);
        Settings.load();
        _parentItem.setSubLabel(SettingsOptions.forKey(_key)[index]);
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        WatchUi.requestUpdate();
    }
}
