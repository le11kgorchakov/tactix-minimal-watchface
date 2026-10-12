import Toybox.Application.Properties;
import Toybox.Lang;

// Cached user settings; reloaded only when settings change, never per frame.
module Settings {

    const ACCENT_COLOR = "AccentColor";
    const HOURS_COLOR = "HoursColor";
    const MINUTES_COLOR = "MinutesColor";
    const TIME_FONT = "TimeFont";
    const HOURS_SIZE = "HoursSize";
    const MINUTES_SIZE = "MinutesSize";
    const SHOW_COLON = "ShowColon";
    const DATE_FORMAT = "DateFormat";
    const TIME_FORMAT = "TimeFormat";
    const SHOW_BATTERY_DAYS = "ShowBatteryDays";
    const SHOW_BATTERY_ARC = "ShowBatteryArc";
    const SHOW_TICKS = "ShowTicks";

    // MIP-friendly values from the 64-color palette; -1 means "match accent".
    const ACCENT_COLORS = [0x55AA00, 0xFF5500, 0x00FFFF, 0xFFFFFF, 0xFF0000];
    const DIGIT_COLORS = [-1, 0xFFFFFF, 0xAAAAAA, 0x55AA00, 0xFF5500, 0x00FFFF, 0xFF0000];

    const FONT_COUNT = 3;
    const SIZE_COUNT = 4;
    const SIZE_LARGE = 2;
    const SIZE_EXTRA_LARGE = 3;
    const DATE_FORMAT_COUNT = 5;
    const TIME_FORMAT_SYSTEM = 0;

    var accentColor as Number = 0xFF5500;
    var hoursColor as Number = 0xFFFFFF;
    var minutesColor as Number = 0xFFFFFF;
    var timeFont as Number = 0;
    var hoursSize as Number = SIZE_LARGE;
    var minutesSize as Number = SIZE_LARGE;
    var showColon as Boolean = true;
    var dateFormat as Number = 0;
    var timeFormat as Number = 1;
    var showBatteryDays as Boolean = true;
    var showBatteryArc as Boolean = true;
    var showTicks as Boolean = true;

    // Bumped on every load so views can rebuild derived state (fonts) lazily.
    var revision as Number = 0;

    function load() as Void {
        accentColor = ACCENT_COLORS[getIndex(ACCENT_COLOR, ACCENT_COLORS.size(), 1)];
        hoursColor = digitColor(HOURS_COLOR);
        minutesColor = digitColor(MINUTES_COLOR);
        timeFont = getIndex(TIME_FONT, FONT_COUNT, 0);
        hoursSize = getIndex(HOURS_SIZE, SIZE_COUNT, SIZE_LARGE);
        minutesSize = getIndex(MINUTES_SIZE, SIZE_COUNT, SIZE_LARGE);
        showColon = getFlag(SHOW_COLON);
        dateFormat = getIndex(DATE_FORMAT, DATE_FORMAT_COUNT, 0);
        timeFormat = getIndex(TIME_FORMAT, 2, 1);
        showBatteryDays = getFlag(SHOW_BATTERY_DAYS);
        showBatteryArc = getFlag(SHOW_BATTERY_ARC);
        showTicks = getFlag(SHOW_TICKS);
        revision++;
    }

    function digitColor(key as String) as Number {
        var color = DIGIT_COLORS[getIndex(key, DIGIT_COLORS.size(), 1)];
        return color < 0 ? accentColor : color;
    }

    function getIndex(key as String, count as Number, fallback as Number) as Number {
        var value = Properties.getValue(key);
        return (value instanceof Number && value >= 0 && value < count) ? value : fallback;
    }

    function getFlag(key as String) as Boolean {
        var value = Properties.getValue(key);
        return value instanceof Boolean ? value : true;
    }
}
