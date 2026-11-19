import Toybox.Application.Properties;
import Toybox.Lang;

// Named visual packs. Selecting a style writes the matching property set;
// users can still fine-tune individual menus afterward.
module StylePresets {

    const STYLE_TACTIX = 0;
    const STYLE_MILITARY = 1;
    const STYLE_CASUAL = 2;
    const STYLE_SPORT = 3;
    const STYLE_STEALTH = 4;
    const COUNT = 5;

    function apply(style as Number) as Void {
        if (style < 0 || style >= COUNT) {
            style = STYLE_TACTIX;
        }
        Properties.setValue(Settings.STYLE, style);

        if (style == STYLE_MILITARY) {
            applyMilitary();
        } else if (style == STYLE_CASUAL) {
            applyCasual();
        } else if (style == STYLE_SPORT) {
            applySport();
        } else if (style == STYLE_STEALTH) {
            applyStealth();
        } else {
            applyTactix();
        }
        Settings.load();
    }

    // Distinct packs — digital look + matching analog handset (arrow / syringe / baton / sword / pencil).
    function applyTactix() as Void {
        setCommon(Settings.DISPLAY_HYBRID, 1, 4, 5, 1, 3, 3, true, 1);
        setDate(5, 0, true);
        setBattery(1, false, true);
        setSeconds(true, 4);
        setSteps(5, true);
        setFields(6, 4, 1, 2, 2);
        setChrome(true);
        setShown(true, true, true, true, true, true, true);
    }

    function applyMilitary() as Void {
        setCommon(Settings.DISPLAY_HYBRID, 0, 3, 2, 0, 3, 2, true, 1);
        setDate(3, 3, true);
        setBattery(2, false, true);
        setSeconds(true, 3);
        setSteps(3, true);
        setFields(1, 2, 2, 2, 2);
        setChrome(true);
        setShown(true, true, true, false, true, false, false);
    }

    function applyCasual() as Void {
        setCommon(Settings.DISPLAY_HYBRID, 2, 5, 1, 2, 3, 3, true, 0);
        setDate(1, 1, true);
        setBattery(1, false, true);
        setSeconds(true, 5);
        setSteps(5, false);
        setFields(6, 4, 1, 5, 4);
        setChrome(false);
        setShown(true, true, true, true, false, true, true);
    }

    function applySport() as Void {
        setCommon(Settings.DISPLAY_HYBRID, 4, 6, 4, 1, 3, 3, true, 1);
        setDate(4, 0, true);
        setBattery(1, false, true);
        setSeconds(true, 4);
        setSteps(5, true);
        setFields(6, 4, 1, 2, 2);
        setChrome(true);
        setShown(true, true, true, true, true, false, false);
    }

    function applyStealth() as Void {
        setCommon(Settings.DISPLAY_ANALOG, 3, 7, 2, 0, 3, 3, false, 1);
        setDate(7, 0, true);
        setBattery(2, false, true);
        setSeconds(true, 2);
        setSteps(2, false);
        setFields(2, 2, 2, 2, 2);
        setChrome(false);
        setShown(true, false, false, false, false, false, false);
    }

    function setCommon(
        displayMode as Number,
        accent as Number,
        hoursColor as Number,
        minutesColor as Number,
        timeFont as Number,
        hoursSize as Number,
        minutesSize as Number,
        showColon as Boolean,
        timeFormat as Number
    ) as Void {
        Properties.setValue(Settings.DISPLAY_MODE, displayMode);
        Properties.setValue(Settings.ACCENT_COLOR, accent);
        Properties.setValue(Settings.HOURS_COLOR, hoursColor);
        Properties.setValue(Settings.MINUTES_COLOR, minutesColor);
        Properties.setValue(Settings.TIME_FONT, timeFont);
        Properties.setValue(Settings.HOURS_SIZE, hoursSize);
        Properties.setValue(Settings.MINUTES_SIZE, minutesSize);
        Properties.setValue(Settings.SHOW_COLON, showColon);
        Properties.setValue(Settings.TIME_FORMAT, timeFormat);
    }

    function setDate(color as Number, format as Number, show as Boolean) as Void {
        Properties.setValue(Settings.DATE_COLOR, color);
        Properties.setValue(Settings.DATE_FORMAT, format);
        Properties.setValue(Settings.SHOW_DATE, show);
    }

    function setBattery(color as Number, days as Boolean, show as Boolean) as Void {
        Properties.setValue(Settings.BATTERY_COLOR, color);
        Properties.setValue(Settings.SHOW_BATTERY_DAYS, days);
        Properties.setValue(Settings.SHOW_BATTERY, show);
    }

    function setSeconds(show as Boolean, color as Number) as Void {
        Properties.setValue(Settings.SHOW_SECONDS_ARC, show);
        Properties.setValue(Settings.SECONDS_COLOR, color);
    }

    function setSteps(color as Number, arc as Boolean) as Void {
        Properties.setValue(Settings.STEPS_COLOR, color);
        Properties.setValue(Settings.SHOW_STEPS_ARC, arc);
    }

    function setFields(hr as Number, cal as Number, dist as Number, weather as Number, sun as Number) as Void {
        Properties.setValue(Settings.HR_COLOR, hr);
        Properties.setValue(Settings.CALORIES_COLOR, cal);
        Properties.setValue(Settings.DISTANCE_COLOR, dist);
        Properties.setValue(Settings.WEATHER_COLOR, weather);
        Properties.setValue(Settings.SUN_COLOR, sun);
    }

    function setChrome(ticks as Boolean) as Void {
        Properties.setValue(Settings.SHOW_TICKS, ticks);
    }

    function setShown(
        date as Boolean,
        hr as Boolean,
        steps as Boolean,
        calories as Boolean,
        distance as Boolean,
        weather as Boolean,
        sun as Boolean
    ) as Void {
        Properties.setValue(Settings.SHOW_DATE, date);
        Properties.setValue(Settings.SHOW_HR, hr);
        Properties.setValue(Settings.SHOW_STEPS, steps);
        Properties.setValue(Settings.SHOW_CALORIES, calories);
        Properties.setValue(Settings.SHOW_DISTANCE, distance);
        Properties.setValue(Settings.SHOW_WEATHER, weather);
        Properties.setValue(Settings.SHOW_SUN, sun);
    }
}
