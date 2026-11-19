import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

module SettingsOptions {

    const COLOR_KEYS = [
        Settings.ACCENT_COLOR,
        Settings.HOURS_COLOR,
        Settings.MINUTES_COLOR,
        Settings.DATE_COLOR,
        Settings.BATTERY_COLOR,
        Settings.SECONDS_COLOR,
        Settings.STEPS_COLOR,
        Settings.HR_COLOR,
        Settings.CALORIES_COLOR,
        Settings.DISTANCE_COLOR,
        Settings.WEATHER_COLOR,
        Settings.SUN_COLOR
    ];

    function forKey(key as String) as Array<ResourceId> {
        if (key.equals(Settings.STYLE)) {
            return [Rez.Strings.StyleTactix, Rez.Strings.StyleMilitary, Rez.Strings.StyleCasual, Rez.Strings.StyleSport, Rez.Strings.StyleStealth];
        }
        if (key.equals(Settings.DISPLAY_MODE)) {
            return [Rez.Strings.DisplayModeDigital, Rez.Strings.DisplayModeAnalog, Rez.Strings.DisplayModeHybrid];
        }
        if (key.equals(Settings.TIME_FONT)) {
            return [
                Rez.Strings.FontCondensed,
                Rez.Strings.FontBold,
                Rez.Strings.FontRegular,
                Rez.Strings.FontRoboto,
                Rez.Strings.FontKosugi
            ];
        }
        if (Settings.isTextFontKey(key)) {
            return [
                Rez.Strings.TextFontCompact,
                Rez.Strings.TextFontStandard,
                Rez.Strings.TextFontComfortable,
                Rez.Strings.TextFontLarge,
                Rez.Strings.TextFontExtraLarge
            ];
        }
        if (key.equals(Settings.HOURS_SIZE) || key.equals(Settings.MINUTES_SIZE)) {
            return [Rez.Strings.SizeSmall, Rez.Strings.SizeMedium, Rez.Strings.SizeLarge, Rez.Strings.SizeExtraLarge];
        }
        if (key.equals(Settings.DATE_FORMAT)) {
            return [Rez.Strings.DateFormat0, Rez.Strings.DateFormat1, Rez.Strings.DateFormat2, Rez.Strings.DateFormat3, Rez.Strings.DateFormat4];
        }
        if (key.equals(Settings.TIME_FORMAT)) {
            return [Rez.Strings.TimeFormatSystem, Rez.Strings.TimeFormat24];
        }
        if (isColorKey(key)) {
            if (key.equals(Settings.ACCENT_COLOR)) {
                return [
                    Rez.Strings.ColorOlive, Rez.Strings.ColorOrange, Rez.Strings.ColorCyan, Rez.Strings.ColorWhite, Rez.Strings.ColorRed,
                    Rez.Strings.ColorBlue, Rez.Strings.ColorYellow, Rez.Strings.ColorPurple, Rez.Strings.ColorGreen, Rez.Strings.ColorBlack
                ];
            }
            return [
                Rez.Strings.ColorMatchAccent,
                Rez.Strings.ColorWhite,
                Rez.Strings.ColorLightGrey,
                Rez.Strings.ColorOlive,
                Rez.Strings.ColorOrange,
                Rez.Strings.ColorCyan,
                Rez.Strings.ColorRed,
                Rez.Strings.ColorCream,
                Rez.Strings.ColorBlue,
                Rez.Strings.ColorYellow,
                Rez.Strings.ColorPurple,
                Rez.Strings.ColorGreen,
                Rez.Strings.ColorBlack,
                Rez.Strings.ColorNavy,
                Rez.Strings.ColorPink,
                Rez.Strings.ColorAmber
            ];
        }
        if (key.equals(Settings.BACKGROUND_COLOR)) {
            return [Rez.Strings.BgBlack, Rez.Strings.BgWhite];
        }
        if (key.equals(Settings.BACKGROUND_IMAGE)) {
            return [Rez.Strings.BgImageNone, Rez.Strings.BgImageBear, Rez.Strings.BgImageWolf, Rez.Strings.BgImageScope];
        }
        return [] as Array<ResourceId>;
    }

    function selected(key as String) as Number {
        var options = forKey(key);
        if (options.size() == 0) {
            return 0;
        }
        return Settings.getIndex(key, options.size(), 0);
    }

    function isColorKey(key as String) as Boolean {
        for (var i = 0; i < COLOR_KEYS.size(); i++) {
            if (key.equals(COLOR_KEYS[i])) {
                return true;
            }
        }
        return false;
    }

    function swatchColor(key as String, index as Number) as Number {
        if (key.equals(Settings.ACCENT_COLOR)) {
            return Settings.ACCENT_COLORS[index];
        }
        var color = Settings.FIELD_COLORS[index];
        return color < 0 ? Settings.accentColor : color;
    }

    function shortLabel(key as String, index as Number) as String {
        if (key.equals(Settings.STYLE)) {
            if (index == 1) {
                return "MIL";
            }
            if (index == 2) {
                return "CAS";
            }
            if (index == 3) {
                return "SPT";
            }
            if (index == 4) {
                return "STL";
            }
            return "TAC";
        }
        if (key.equals(Settings.DISPLAY_MODE)) {
            if (index == 1) {
                return "ANA";
            }
            if (index == 2) {
                return "HYB";
            }
            return "DIG";
        }
        if (key.equals(Settings.TIME_FONT)) {
            if (index == 1) {
                return "BLD";
            }
            if (index == 2) {
                return "REG";
            }
            if (index == 3) {
                return "RBT";
            }
            if (index == 4) {
                return "KSG";
            }
            return "CND";
        }
        if (Settings.isTextFontKey(key)) {
            if (index == 1) {
                return "Std";
            }
            if (index == 2) {
                return "Med";
            }
            if (index == 3) {
                return "Lrg";
            }
            if (index == 4) {
                return "XL";
            }
            return "Cmp";
        }
        if (key.equals(Settings.HOURS_SIZE) || key.equals(Settings.MINUTES_SIZE)) {
            if (index == 0) {
                return "S";
            }
            if (index == 1) {
                return "M";
            }
            if (index == 2) {
                return "L";
            }
            return "XL";
        }
        if (key.equals(Settings.DATE_FORMAT)) {
            if (index == 1) {
                return "Long";
            }
            if (index == 2) {
                return "DD";
            }
            if (index == 3) {
                return "ISO";
            }
            if (index == 4) {
                return "US";
            }
            return "Short";
        }
        if (key.equals(Settings.TIME_FORMAT)) {
            return index == 0 ? "Sys" : "24h";
        }
        if (key.equals(Settings.BACKGROUND_COLOR)) {
            return index == 0 ? "BLK" : "WHT";
        }
        if (key.equals(Settings.BACKGROUND_IMAGE)) {
            if (index == 1) {
                return "BEAR";
            }
            if (index == 2) {
                return "WOLF";
            }
            if (index == 3) {
                return "SCP";
            }
            return "OFF";
        }
        return index.toString();
    }
}

class SettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => Rez.Strings.CustomizeTitle});
        var styleOptions = SettingsOptions.forKey(Settings.STYLE);
        addItem(new WatchUi.MenuItem(Rez.Strings.StyleTitle, styleOptions[SettingsOptions.selected(Settings.STYLE)], Settings.STYLE, null));
        addItem(new WatchUi.MenuItem(Rez.Strings.TimeMenuTitle, null, :time, null));
        addItem(new WatchUi.MenuItem(Rez.Strings.DateMenuTitle, null, :date, null));
        addItem(new WatchUi.MenuItem(Rez.Strings.BatteryMenuTitle, null, :battery, null));
        addItem(new WatchUi.MenuItem(Rez.Strings.StepsMenuTitle, null, :steps, null));
        addItem(new WatchUi.MenuItem(Rez.Strings.HrMenuTitle, null, :hr, null));
        addItem(new WatchUi.MenuItem(Rez.Strings.CaloriesMenuTitle, null, :calories, null));
        addItem(new WatchUi.MenuItem(Rez.Strings.DistanceMenuTitle, null, :distance, null));
        addItem(new WatchUi.MenuItem(Rez.Strings.WeatherMenuTitle, null, :weather, null));
        addItem(new WatchUi.MenuItem(Rez.Strings.SunMenuTitle, null, :sun, null));
        addItem(new WatchUi.MenuItem(Rez.Strings.ChromeMenuTitle, null, :chrome, null));
    }
}

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id instanceof String && (id as String).equals(Settings.STYLE)) {
            var view = new OptionPickerView(item.getLabel(), Settings.STYLE);
            WatchUi.pushView(view, new OptionPickerDelegate(item, Settings.STYLE, view), WatchUi.SLIDE_LEFT);
            return;
        }
        if (id == :time) {
            push(new TimeSettingsMenu(), new PropertyMenuDelegate());
        } else if (id == :date) {
            push(new FieldSettingsMenu(Rez.Strings.DateMenuTitle, Settings.SHOW_DATE, Settings.DATE_COLOR, Settings.DATE_FORMAT, Settings.DATE_FONT), new PropertyMenuDelegate());
        } else if (id == :battery) {
            push(new BatterySettingsMenu(), new PropertyMenuDelegate());
        } else if (id == :steps) {
            push(new StepsSettingsMenu(), new PropertyMenuDelegate());
        } else if (id == :hr) {
            push(new FieldSettingsMenu(Rez.Strings.HrMenuTitle, Settings.SHOW_HR, Settings.HR_COLOR, null, Settings.HR_FONT), new PropertyMenuDelegate());
        } else if (id == :calories) {
            push(new FieldSettingsMenu(Rez.Strings.CaloriesMenuTitle, Settings.SHOW_CALORIES, Settings.CALORIES_COLOR, null, Settings.CALORIES_FONT), new PropertyMenuDelegate());
        } else if (id == :distance) {
            push(new FieldSettingsMenu(Rez.Strings.DistanceMenuTitle, Settings.SHOW_DISTANCE, Settings.DISTANCE_COLOR, null, Settings.DISTANCE_FONT), new PropertyMenuDelegate());
        } else if (id == :weather) {
            push(new FieldSettingsMenu(Rez.Strings.WeatherMenuTitle, Settings.SHOW_WEATHER, Settings.WEATHER_COLOR, null, Settings.WEATHER_FONT), new PropertyMenuDelegate());
        } else if (id == :sun) {
            push(new FieldSettingsMenu(Rez.Strings.SunMenuTitle, Settings.SHOW_SUN, Settings.SUN_COLOR, null, Settings.SUN_FONT), new PropertyMenuDelegate());
        } else if (id == :chrome) {
            push(new ChromeSettingsMenu(), new PropertyMenuDelegate());
        }
    }

    private function push(menu as WatchUi.Menu2, delegate as WatchUi.Menu2InputDelegate) as Void {
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_LEFT);
    }
}

class TimeSettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => Rez.Strings.TimeMenuTitle});
        MenuHelpers.addList(self, Settings.DISPLAY_MODE, Rez.Strings.DisplayModeTitle);
        MenuHelpers.addList(self, Settings.HOURS_COLOR, Rez.Strings.HoursColorTitle);
        MenuHelpers.addList(self, Settings.MINUTES_COLOR, Rez.Strings.MinutesColorTitle);
        MenuHelpers.addList(self, Settings.TIME_FONT, Rez.Strings.TimeFontTitle);
        MenuHelpers.addList(self, Settings.HOURS_SIZE, Rez.Strings.HoursSizeTitle);
        MenuHelpers.addList(self, Settings.MINUTES_SIZE, Rez.Strings.MinutesSizeTitle);
        MenuHelpers.addToggle(self, Settings.SHOW_COLON, Rez.Strings.ShowColonTitle, true);
        MenuHelpers.addList(self, Settings.TIME_FORMAT, Rez.Strings.TimeFormatTitle);
    }
}

class FieldSettingsMenu extends WatchUi.Menu2 {

    function initialize(title as ResourceId, showKey as String, colorKey as String, formatKey as String or Null, fontKey as String) {
        Menu2.initialize({:title => title});
        MenuHelpers.addToggle(self, showKey, Rez.Strings.ShowTitle, true);
        MenuHelpers.addList(self, colorKey, Rez.Strings.ColorTitle);
        MenuHelpers.addList(self, fontKey, Rez.Strings.FontTitle);
        if (formatKey != null) {
            MenuHelpers.addList(self, formatKey as String, Rez.Strings.DateFormatTitle);
        }
    }
}

class BatterySettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => Rez.Strings.BatteryMenuTitle});
        MenuHelpers.addToggle(self, Settings.SHOW_BATTERY, Rez.Strings.ShowTitle, true);
        MenuHelpers.addList(self, Settings.BATTERY_COLOR, Rez.Strings.ColorTitle);
        MenuHelpers.addList(self, Settings.BATTERY_FONT, Rez.Strings.FontTitle);
        MenuHelpers.addToggle(self, Settings.SHOW_BATTERY_DAYS, Rez.Strings.ShowBatteryDaysTitle, false);
    }
}

class StepsSettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => Rez.Strings.StepsMenuTitle});
        MenuHelpers.addToggle(self, Settings.SHOW_STEPS, Rez.Strings.ShowTitle, true);
        MenuHelpers.addList(self, Settings.STEPS_COLOR, Rez.Strings.ColorTitle);
        MenuHelpers.addList(self, Settings.STEPS_FONT, Rez.Strings.FontTitle);
        MenuHelpers.addToggle(self, Settings.SHOW_STEPS_ARC, Rez.Strings.ShowStepsArcTitle, true);
    }
}

class ChromeSettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => Rez.Strings.ChromeMenuTitle});
        MenuHelpers.addList(self, Settings.BACKGROUND_COLOR, Rez.Strings.BackgroundColorTitle);
        MenuHelpers.addList(self, Settings.BACKGROUND_IMAGE, Rez.Strings.BackgroundImageTitle);
        MenuHelpers.addList(self, Settings.ACCENT_COLOR, Rez.Strings.AccentColorTitle);
        MenuHelpers.addToggle(self, Settings.SHOW_SECONDS_ARC, Rez.Strings.ShowSecondsArcTitle, true);
        MenuHelpers.addList(self, Settings.SECONDS_COLOR, Rez.Strings.SecondsColorTitle);
        MenuHelpers.addToggle(self, Settings.SHOW_TICKS, Rez.Strings.ShowTicksTitle, true);
    }
}

module MenuHelpers {

    function addList(menu as WatchUi.Menu2, key as String, title as ResourceId) as Void {
        var options = SettingsOptions.forKey(key);
        menu.addItem(new WatchUi.MenuItem(title, options[SettingsOptions.selected(key)], key, null));
    }

    function addToggle(menu as WatchUi.Menu2, key as String, title as ResourceId, fallback as Boolean) as Void {
        menu.addItem(new WatchUi.ToggleMenuItem(title, null, key, Settings.getFlag(key, fallback), null));
    }
}

class PropertyMenuDelegate extends WatchUi.Menu2InputDelegate {

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
        var view = new OptionPickerView(item.getLabel(), key);
        WatchUi.pushView(view, new OptionPickerDelegate(item, key, view), WatchUi.SLIDE_LEFT);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

class OptionPickerView extends WatchUi.View {

    private const RAIL_X = 22;
    private const DOT_RADIUS = 7;
    private const SELECTED_RING = 10;
    private const ROW_GAP = 28;
    private const LABEL_FONT = Graphics.FONT_XTINY;

    private var _title as String;
    private var _key as String;
    private var _face as FacePainter;
    private var _index as Number;
    private var _count as Number;
    private var _isColor as Boolean;

    function initialize(title as String, key as String) {
        View.initialize();
        _title = title;
        _key = key;
        _face = new FacePainter();
        _count = SettingsOptions.forKey(key).size();
        _index = SettingsOptions.selected(key);
        _isColor = SettingsOptions.isColorKey(key);
    }

    function onLayout(dc as Graphics.Dc) as Void {
        _face.layout(dc);
    }

    function onShow() as Void {
        applyPreview();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        _face.draw(dc, true, true);
        drawRail(dc);
        // Title sits at the bottom so it does not cover date / weather in the live preview.
        var titleY = dc.getHeight() - 28;
        var titleW = dc.getTextWidthInPixels(_title, Graphics.FONT_TINY) + 16;
        var titleX = dc.getWidth() / 2;
        dc.setColor(0x000000, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(titleX - titleW / 2, titleY - 2, titleW, 20, 4);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(titleX, titleY, Graphics.FONT_TINY, _title, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function index() as Number {
        return _index;
    }

    function move(delta as Number) as Void {
        _index = (_index + delta + _count) % _count;
        applyPreview();
        WatchUi.requestUpdate();
    }

    private function applyPreview() as Void {
        if (_key.equals(Settings.STYLE)) {
            StylePresets.apply(_index);
            return;
        }
        Properties.setValue(_key, _index);
        Settings.load();
    }

    private function drawRail(dc as Graphics.Dc) as Void {
        var height = dc.getHeight();
        var total = (_count - 1) * ROW_GAP;
        var startY = (height - total) / 2;

        for (var i = 0; i < _count; i++) {
            var y = startY + i * ROW_GAP;
            var selected = i == _index;
            if (_isColor) {
                drawColorDot(dc, RAIL_X, y, SettingsOptions.swatchColor(_key, i), selected);
            } else {
                drawLabelDot(dc, RAIL_X, y, SettingsOptions.shortLabel(_key, i), selected);
            }
        }
    }

    private function drawColorDot(dc as Graphics.Dc, x as Number, y as Number, color as Number, selected as Boolean) as Void {
        if (selected) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x, y, SELECTED_RING);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x, y, SELECTED_RING - 2);
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, DOT_RADIUS);
        if (color == 0xFFFFFF || color == 0xAAAAAA) {
            dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(1);
            dc.drawCircle(x, y, DOT_RADIUS);
        }
    }

    private function drawLabelDot(dc as Graphics.Dc, x as Number, y as Number, label as String, selected as Boolean) as Void {
        var w = dc.getTextWidthInPixels(label, LABEL_FONT) + 10;
        if (w < 28) {
            w = 28;
        }
        var h = 16;
        var left = x - 4;
        if (selected) {
            dc.setColor(Settings.accentColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(left - 2, y - h / 2 - 2, w + 4, h + 4, 4);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(left, y - h / 2, w, h, 3);
        } else {
            dc.setColor(0x333333, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(left, y - h / 2, w, h, 3);
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(left + w / 2, y, LABEL_FONT, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

class OptionPickerDelegate extends WatchUi.BehaviorDelegate {

    private var _parentItem as WatchUi.MenuItem;
    private var _key as String;
    private var _original as Number;
    private var _view as OptionPickerView;

    function initialize(parentItem as WatchUi.MenuItem, key as String, view as OptionPickerView) {
        BehaviorDelegate.initialize();
        _parentItem = parentItem;
        _key = key;
        _original = SettingsOptions.selected(key);
        _view = view;
    }

    function onNextPage() as Boolean {
        _view.move(1);
        return true;
    }

    function onPreviousPage() as Boolean {
        _view.move(-1);
        return true;
    }

    function onSelect() as Boolean {
        _parentItem.setSubLabel(SettingsOptions.forKey(_key)[_view.index()]);
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() as Boolean {
        if (_key.equals(Settings.STYLE)) {
            StylePresets.apply(_original);
        } else {
            Properties.setValue(_key, _original);
            Settings.load();
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        WatchUi.requestUpdate();
        return true;
    }
}
