import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class TactixMinimalView extends WatchUi.WatchFace {

    private const ROW_OFFSET = 64;
    private const ROW_OFFSET_EXTRA_LARGE = 80;
    private const TIME_WIDTH_RATIO = 0.8;
    // Keeps the time clear of the 3 and 9 o'clock ticks.
    private const TIME_MAX_WIDTH_RATIO = 0.86;
    private const TIME_MAX_SIZE = 130;
    private const TIME_MIN_SIZE = 60;
    private const TIME_FACES = [
        ["RobotoCondensedBold"],
        ["BionicBold", "RobotoCondensedBold"],
        ["RobotoCondensedRegular", "RobotoCondensedBold"]
    ];
    private const SIZE_SCALES = [0.62, 0.8, 1.0, 1.25];
    private const BITMAP_SIZES = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_THAI_HOT, Graphics.FONT_NUMBER_THAI_HOT];

    private const ARC_PEN = 4;
    private const ARC_INSET = 3;
    private const TRACK_COLOR = 0x555555;
    private const TICK_COUNT = 12;
    private const TICK_OUTER_INSET = 10;
    private const TICK_LENGTH = 7;
    private const TICK_PEN = 2;

    private const BATTERY_WIDTH = 22;
    private const BATTERY_HEIGHT = 12;
    private const BATTERY_NUB = 3;
    private const BATTERY_INSET = 3;
    private const BATTERY_GAP = 6;

    private const CENTER = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

    private var _hoursFont as Graphics.FontType = Graphics.FONT_NUMBER_THAI_HOT;
    private var _minutesFont as Graphics.FontType = Graphics.FONT_NUMBER_THAI_HOT;
    private var _fontRevision as Number = -1;
    private var _rowOffset as Number = ROW_OFFSET;
    private var _ticks as Array<Array<Number>> = [];
    private var _cx as Number = 140;
    private var _cy as Number = 140;
    private var _radius as Number = 140;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        _cx = dc.getWidth() / 2;
        _cy = dc.getHeight() / 2;
        _radius = _cx < _cy ? _cx : _cy;
        _fontRevision = -1;
        _ticks = computeTicks();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var stats = System.getSystemStats();
        if (Settings.showBatteryArc) {
            drawBatteryArc(dc, stats.battery);
        }
        if (Settings.showTicks) {
            drawTicks(dc);
        }

        var now = Time.now();
        dc.setColor(Settings.accentColor, Graphics.COLOR_TRANSPARENT);
        ensureFonts(dc);
        dc.drawText(_cx, _cy - _rowOffset, Graphics.FONT_MEDIUM, formatDate(now), CENTER);

        drawTime(dc, now);
        drawBatteryRow(dc, stats);
    }

    // Updates are minute-based in both modes; waking only forces a fresh frame.
    function onExitSleep() as Void {
        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void {
        WatchUi.requestUpdate();
    }


    // Hours and minutes may use different sizes, so they share the taller font's baseline.
    private function drawTime(dc as Graphics.Dc, now as Time.Moment) as Void {
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var hours = formatHours(info.hour as Number);
        var minutes = (info.min as Number).format("%02d");

        var hoursWidth = dc.getTextWidthInPixels(hours, _hoursFont);
        var colonWidth = Settings.showColon ? dc.getTextWidthInPixels(":", _hoursFont) : 0;
        var minutesWidth = dc.getTextWidthInPixels(minutes, _minutesFont);
        var x = _cx - (hoursWidth + colonWidth + minutesWidth) / 2;

        var tallFont = dc.getFontHeight(_hoursFont) >= dc.getFontHeight(_minutesFont) ? _hoursFont : _minutesFont;
        var baseline = _cy - dc.getFontHeight(tallFont) / 2 + Graphics.getFontAscent(tallFont);
        var hoursTop = baseline - Graphics.getFontAscent(_hoursFont);

        dc.setColor(Settings.hoursColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, hoursTop, _hoursFont, hours, Graphics.TEXT_JUSTIFY_LEFT);
        if (Settings.showColon) {
            dc.drawText(x + hoursWidth, hoursTop, _hoursFont, ":", Graphics.TEXT_JUSTIFY_LEFT);
        }

        dc.setColor(Settings.minutesColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + hoursWidth + colonWidth, baseline - Graphics.getFontAscent(_minutesFont), _minutesFont, minutes, Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function formatHours(hour as Number) as String {
        if (Settings.timeFormat != Settings.TIME_FORMAT_SYSTEM || System.getDeviceSettings().is24Hour) {
            return hour.format("%02d");
        }
        hour = hour % 12;
        return (hour == 0 ? 12 : hour).toString();
    }

    private function ensureFonts(dc as Graphics.Dc) as Void {
        if (_fontRevision == Settings.revision) {
            return;
        }
        _fontRevision = Settings.revision;
        var largest = (Graphics has :getVectorFont) ? fitLargestSize(dc) : 0;
        _hoursFont = timeFontFor(Settings.hoursSize, largest, 1.0);
        _minutesFont = timeFontFor(Settings.minutesSize, largest, 1.0);

        var maxWidth = dc.getWidth() * TIME_MAX_WIDTH_RATIO;
        var width = widestTimeWidth(dc);
        if (largest > 0 && width > maxWidth) {
            var shrink = maxWidth / width;
            _hoursFont = timeFontFor(Settings.hoursSize, largest, shrink);
            _minutesFont = timeFontFor(Settings.minutesSize, largest, shrink);
        }

        var extraLarge = Settings.hoursSize == Settings.SIZE_EXTRA_LARGE || Settings.minutesSize == Settings.SIZE_EXTRA_LARGE;
        _rowOffset = extraLarge ? ROW_OFFSET_EXTRA_LARGE : ROW_OFFSET;
    }

    private function widestTimeWidth(dc as Graphics.Dc) as Number {
        var colon = Settings.showColon ? dc.getTextWidthInPixels(":", _hoursFont) : 0;
        return dc.getTextWidthInPixels("00", _hoursFont) + colon + dc.getTextWidthInPixels("00", _minutesFont);
    }

    private function timeFontFor(size as Number, largest as Number, shrink as Float) as Graphics.FontType {
        if (largest > 0) {
            var font = Graphics.getVectorFont({:face => TIME_FACES[Settings.timeFont], :size => (largest * SIZE_SCALES[size] * shrink).toNumber()});
            if (font != null) {
                return font;
            }
        }
        return BITMAP_SIZES[size];
    }

    private function formatDate(now as Time.Moment) as String {
        var medium = Gregorian.info(now, Time.FORMAT_MEDIUM);
        var weekday = medium.day_of_week as String;
        var month = medium.month as String;
        var day = medium.day as Number;

        switch (Settings.dateFormat) {
            case 1:
                var long = Gregorian.info(now, Time.FORMAT_LONG);
                return (long.day_of_week as String) + ", " + month + " " + day;
            case 2:
                return day.format("%02d") + " / " + month.toUpper();
            case 3:
                var short = Gregorian.info(now, Time.FORMAT_SHORT);
                return Lang.format("$1$-$2$-$3$", [
                    short.year,
                    (short.month as Number).format("%02d"),
                    day.format("%02d")
                ]);
            case 4:
                var numeric = Gregorian.info(now, Time.FORMAT_SHORT);
                return Lang.format("$1$/$2$/$3$", [
                    (numeric.month as Number).format("%02d"),
                    day.format("%02d"),
                    ((numeric.year as Number) % 100).format("%02d")
                ]);
            default:
                return weekday.toUpper() + " · " + month.toUpper() + " " + day;
        }
    }

    // Largest size where "00:00" in the chosen face fits; 0 means use bitmap fonts.
    private function fitLargestSize(dc as Graphics.Dc) as Number {
        var maxWidth = dc.getWidth() * TIME_WIDTH_RATIO;
        for (var size = TIME_MAX_SIZE; size >= TIME_MIN_SIZE; size -= 4) {
            var font = Graphics.getVectorFont({:face => TIME_FACES[Settings.timeFont], :size => size});
            if (font == null) {
                return 0;
            }
            if (dc.getTextWidthInPixels("00:00", font) <= maxWidth) {
                return size;
            }
        }
        return TIME_MIN_SIZE;
    }


    private function batteryLabel(stats as System.Stats) as String {
        var label = stats.battery.toNumber() + "%";
        if (!Settings.showBatteryDays || !(stats has :batteryInDays) || stats.batteryInDays == null) {
            return label;
        }
        var days = stats.batteryInDays as Float;
        var remaining = days >= 1 ? days.toNumber() + "d" : (days * 24).toNumber() + "h";
        return label + " (" + remaining + ")";
    }

    private function drawBatteryRow(dc as Graphics.Dc, stats as System.Stats) as Void {
        var label = batteryLabel(stats);
        var font = Graphics.FONT_SMALL;
        var iconWidth = BATTERY_WIDTH + BATTERY_NUB;
        var labelWidth = dc.getTextWidthInPixels(label, font);
        var x = _cx - (iconWidth + BATTERY_GAP + labelWidth) / 2;
        var y = _cy + _rowOffset;

        drawBatteryIcon(dc, x, y, stats.battery);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + iconWidth + BATTERY_GAP, y, font, label, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawBatteryIcon(dc as Graphics.Dc, x as Number, y as Number, percent as Float) as Void {
        var top = y - BATTERY_HEIGHT / 2;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRectangle(x, top, BATTERY_WIDTH, BATTERY_HEIGHT);
        dc.setPenWidth(1);
        dc.fillRectangle(x + BATTERY_WIDTH, y - BATTERY_NUB, BATTERY_NUB, BATTERY_NUB * 2);

        var fill = ((BATTERY_WIDTH - 2 * BATTERY_INSET) * percent / 100).toNumber();
        if (fill > 0) {
            dc.setColor(Settings.accentColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x + BATTERY_INSET, top + BATTERY_INSET, fill, BATTERY_HEIGHT - 2 * BATTERY_INSET);
        }
    }

    // Track around the bezel, filled clockwise from 12 o'clock by charge level.
    private function drawBatteryArc(dc as Graphics.Dc, percent as Float) as Void {
        var r = _radius - ARC_INSET;
        dc.setPenWidth(ARC_PEN);
        dc.setColor(TRACK_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(_cx, _cy, r);

        var sweep = (percent * 360 / 100).toNumber();
        dc.setColor(Settings.accentColor, Graphics.COLOR_TRANSPARENT);
        if (sweep >= 360) {
            dc.drawCircle(_cx, _cy, r);
        } else if (sweep > 0) {
            dc.drawArc(_cx, _cy, r, Graphics.ARC_CLOCKWISE, 90, (450 - sweep) % 360);
        }
        dc.setPenWidth(1);
    }


    private function computeTicks() as Array<Array<Number>> {
        var ticks = [] as Array<Array<Number>>;
        var outer = _radius - TICK_OUTER_INSET;
        var inner = outer - TICK_LENGTH;
        for (var i = 0; i < TICK_COUNT; i++) {
            var angle = Math.PI * 2 * i / TICK_COUNT;
            var sin = Math.sin(angle);
            var cos = Math.cos(angle);
            ticks.add([
                (_cx + inner * sin).toNumber(), (_cy - inner * cos).toNumber(),
                (_cx + outer * sin).toNumber(), (_cy - outer * cos).toNumber()
            ]);
        }
        return ticks;
    }

    private function drawTicks(dc as Graphics.Dc) as Void {
        dc.setPenWidth(TICK_PEN);
        for (var i = 0; i < _ticks.size(); i++) {
            var tick = _ticks[i];
            dc.setColor(i == 0 ? Settings.accentColor : TRACK_COLOR, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(tick[0], tick[1], tick[2], tick[3]);
        }
        dc.setPenWidth(1);
    }
}
