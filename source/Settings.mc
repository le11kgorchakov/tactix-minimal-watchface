import Toybox.Application.Properties;
import Toybox.Lang;

// Cached user settings; reloaded only when settings change, never per frame.
module Settings {

    const STYLE = "Style";
    const DISPLAY_MODE = "DisplayMode";
    const ACCENT_COLOR = "AccentColor";
    const HOURS_COLOR = "HoursColor";
    const MINUTES_COLOR = "MinutesColor";
    const TIME_FONT = "TimeFont";
    const HOURS_SIZE = "HoursSize";
    const MINUTES_SIZE = "MinutesSize";
    const SHOW_COLON = "ShowColon";
    const TIME_FORMAT = "TimeFormat";

    const SHOW_DATE = "ShowDate";
    const DATE_COLOR = "DateColor";
    const DATE_FORMAT = "DateFormat";
    const DATE_FONT = "DateFont";

    const SHOW_BATTERY = "ShowBattery";
    const BATTERY_COLOR = "BatteryColor";
    const BATTERY_FONT = "BatteryFont";
    const SHOW_BATTERY_DAYS = "ShowBatteryDays";

    const SHOW_SECONDS_ARC = "ShowSecondsArc";
    const SECONDS_COLOR = "SecondsColor";

    const SHOW_STEPS = "ShowSteps";
    const STEPS_COLOR = "StepsColor";
    const STEPS_FONT = "StepsFont";
    const SHOW_STEPS_ARC = "ShowStepsArc";

    const SHOW_HR = "ShowHr";
    const HR_COLOR = "HrColor";
    const HR_FONT = "HrFont";

    const SHOW_CALORIES = "ShowCalories";
    const CALORIES_COLOR = "CaloriesColor";
    const CALORIES_FONT = "CaloriesFont";

    const SHOW_DISTANCE = "ShowDistance";
    const DISTANCE_COLOR = "DistanceColor";
    const DISTANCE_FONT = "DistanceFont";

    const SHOW_WEATHER = "ShowWeather";
    const WEATHER_COLOR = "WeatherColor";
    const WEATHER_FONT = "WeatherFont";

    const SHOW_SUN = "ShowSun";
    const SUN_COLOR = "SunColor";
    const SUN_FONT = "SunFont";

    const SHOW_TICKS = "ShowTicks";
    const BACKGROUND_COLOR = "BackgroundColor";
    const BACKGROUND_IMAGE = "BackgroundImage";

    // Olive, Orange, Cyan, White, Red, Blue, Yellow, Purple, Green, Black
    const ACCENT_COLORS = [
        0x55AA00, 0xFF5500, 0x00FFFF, 0xFFFFFF, 0xFF0000,
        0x3388FF, 0xFFD400, 0xAA66FF, 0x22CC66, 0x111111
    ];
    // -1 match accent, then palette (append-only so existing indices stay valid)
    const FIELD_COLORS = [
        -1, 0xFFFFFF, 0xAAAAAA, 0x55AA00, 0xFF5500, 0x00FFFF, 0xFF0000, 0xE8E0D0,
        0x3388FF, 0xFFD400, 0xAA66FF, 0x22CC66, 0x111111, 0x003366, 0xFF66AA, 0xFFAA33
    ];

    const DISPLAY_DIGITAL = 0;
    const DISPLAY_ANALOG = 1;
    const DISPLAY_HYBRID = 2;
    const FONT_COUNT = 5;
    // Label fonts: 0 Compact, 1 Standard, 2 Comfortable, 3 Large, 4 Extra Large
    const TEXT_FONT_COUNT = 5;
    const TEXT_FONT_COMPACT = 0;
    const TEXT_FONT_STANDARD = 1;
    const SIZE_COUNT = 4;
    const SIZE_LARGE = 2;
    const SIZE_EXTRA_LARGE = 3;
    const DATE_FORMAT_COUNT = 5;
    const TIME_FORMAT_SYSTEM = 0;
    const STYLE_COUNT = 5;
    const BG_BLACK = 0;
    const BG_WHITE = 1;
    const BG_IMAGE_NONE = 0;
    const BG_IMAGE_BEAR = 1;
    const BG_IMAGE_WOLF = 2;
    const BG_IMAGE_SCOPE = 3;
    const BG_IMAGE_COUNT = 4;

    var style as Number = 0;
    var displayMode as Number = DISPLAY_DIGITAL;
    var accentColor as Number = 0xFF5500;
    var hoursColor as Number = 0xFFFFFF;
    var minutesColor as Number = 0xFFFFFF;
    var timeFont as Number = 0;
    var hoursSize as Number = SIZE_EXTRA_LARGE;
    var minutesSize as Number = SIZE_EXTRA_LARGE;
    var showColon as Boolean = true;
    var timeFormat as Number = 1;

    var showDate as Boolean = true;
    var dateColor as Number = 0x00FFFF;
    var dateFormat as Number = 0;
    var dateFont as Number = TEXT_FONT_STANDARD;

    var showBattery as Boolean = true;
    var batteryColor as Number = 0xFFFFFF;
    var batteryFont as Number = TEXT_FONT_COMPACT;
    var showBatteryDays as Boolean = false;

    var showSecondsArc as Boolean = true;
    var secondsColor as Number = 0xFF5500;

    var showSteps as Boolean = true;
    var stepsColor as Number = 0x00FFFF;
    var stepsFont as Number = TEXT_FONT_COMPACT;
    var showStepsArc as Boolean = true;

    var showHr as Boolean = true;
    var hrColor as Number = 0xFF0000;
    var hrFont as Number = TEXT_FONT_COMPACT;

    var showCalories as Boolean = true;
    var caloriesColor as Number = 0xFF5500;
    var caloriesFont as Number = TEXT_FONT_COMPACT;

    var showDistance as Boolean = true;
    var distanceColor as Number = 0xFFFFFF;
    var distanceFont as Number = TEXT_FONT_COMPACT;

    var showWeather as Boolean = true;
    var weatherColor as Number = 0xAAAAAA;
    var weatherFont as Number = TEXT_FONT_COMPACT;

    var showSun as Boolean = true;
    var sunColor as Number = 0xAAAAAA;
    var sunFont as Number = TEXT_FONT_COMPACT;

    var showTicks as Boolean = true;
    var backgroundColorIndex as Number = BG_BLACK;
    var backgroundColor as Number = 0x000000;
    var lightBackground as Boolean = false;
    var backgroundImage as Number = BG_IMAGE_NONE;
    var trackColor as Number = 0x555555;

    var revision as Number = 0;

    function load() as Void {
        style = getIndex(STYLE, STYLE_COUNT, 0);
        displayMode = getIndex(DISPLAY_MODE, 3, DISPLAY_DIGITAL);
        accentColor = ACCENT_COLORS[getIndex(ACCENT_COLOR, ACCENT_COLORS.size(), 1)];
        hoursColor = fieldColor(HOURS_COLOR);
        minutesColor = fieldColor(MINUTES_COLOR);
        timeFont = getIndex(TIME_FONT, FONT_COUNT, 0);
        hoursSize = getIndex(HOURS_SIZE, SIZE_COUNT, SIZE_EXTRA_LARGE);
        minutesSize = getIndex(MINUTES_SIZE, SIZE_COUNT, SIZE_EXTRA_LARGE);
        showColon = getFlag(SHOW_COLON, true);
        timeFormat = getIndex(TIME_FORMAT, 2, 1);

        showDate = getFlag(SHOW_DATE, true);
        dateColor = fieldColor(DATE_COLOR);
        dateFormat = getIndex(DATE_FORMAT, DATE_FORMAT_COUNT, 0);
        dateFont = getIndex(DATE_FONT, TEXT_FONT_COUNT, TEXT_FONT_STANDARD);

        showBattery = getFlag(SHOW_BATTERY, true);
        batteryColor = fieldColor(BATTERY_COLOR);
        batteryFont = getIndex(BATTERY_FONT, TEXT_FONT_COUNT, TEXT_FONT_COMPACT);
        showBatteryDays = getFlag(SHOW_BATTERY_DAYS, false);

        showSecondsArc = getFlag(SHOW_SECONDS_ARC, true);
        secondsColor = fieldColor(SECONDS_COLOR);

        showSteps = getFlag(SHOW_STEPS, true);
        stepsColor = fieldColor(STEPS_COLOR);
        stepsFont = getIndex(STEPS_FONT, TEXT_FONT_COUNT, TEXT_FONT_COMPACT);
        showStepsArc = getFlag(SHOW_STEPS_ARC, true);

        showHr = getFlag(SHOW_HR, true);
        hrColor = fieldColor(HR_COLOR);
        hrFont = getIndex(HR_FONT, TEXT_FONT_COUNT, TEXT_FONT_COMPACT);

        showCalories = getFlag(SHOW_CALORIES, true);
        caloriesColor = fieldColor(CALORIES_COLOR);
        caloriesFont = getIndex(CALORIES_FONT, TEXT_FONT_COUNT, TEXT_FONT_COMPACT);

        showDistance = getFlag(SHOW_DISTANCE, true);
        distanceColor = fieldColor(DISTANCE_COLOR);
        distanceFont = getIndex(DISTANCE_FONT, TEXT_FONT_COUNT, TEXT_FONT_COMPACT);

        showWeather = getFlag(SHOW_WEATHER, true);
        weatherColor = fieldColor(WEATHER_COLOR);
        weatherFont = getIndex(WEATHER_FONT, TEXT_FONT_COUNT, TEXT_FONT_COMPACT);

        showSun = getFlag(SHOW_SUN, true);
        sunColor = fieldColor(SUN_COLOR);
        sunFont = getIndex(SUN_FONT, TEXT_FONT_COUNT, TEXT_FONT_COMPACT);

        showTicks = getFlag(SHOW_TICKS, true);
        backgroundColorIndex = getIndex(BACKGROUND_COLOR, 2, BG_BLACK);
        lightBackground = backgroundColorIndex == BG_WHITE;
        backgroundColor = lightBackground ? 0xFFFFFF : 0x000000;
        trackColor = lightBackground ? 0xCCCCCC : 0x555555;
        backgroundImage = getIndex(BACKGROUND_IMAGE, BG_IMAGE_COUNT, BG_IMAGE_NONE);
        revision++;
    }

    function isTextFontKey(key as String) as Boolean {
        return key.equals(DATE_FONT)
            || key.equals(BATTERY_FONT)
            || key.equals(STEPS_FONT)
            || key.equals(HR_FONT)
            || key.equals(CALORIES_FONT)
            || key.equals(DISTANCE_FONT)
            || key.equals(WEATHER_FONT)
            || key.equals(SUN_FONT);
    }

    function fieldColor(key as String) as Number {
        var color = FIELD_COLORS[getIndex(key, FIELD_COLORS.size(), 1)];
        return color < 0 ? accentColor : color;
    }

    function getIndex(key as String, count as Number, fallback as Number) as Number {
        var value = Properties.getValue(key);
        return (value instanceof Number && value >= 0 && value < count) ? value : fallback;
    }

    function getFlag(key as String, fallback as Boolean) as Boolean {
        var value = Properties.getValue(key);
        return value instanceof Boolean ? value : fallback;
    }
}
