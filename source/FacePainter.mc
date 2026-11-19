import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Layout approach (CIQ forums):
// - Number/vector fonts report extra whitespace in getFontHeight(); use ascent
//   for the *visible* time band, and draw time with VCENTER at screen center.
// - Metric/header text: top-anchored (no VCENTER), spaced by getFontHeight().
// - Vertically center the header block in the top band and the metrics block
//   in the bottom band so dead space isn't all piled above the time.
class FacePainter {

    private const TIME_WIDTH_RATIO = 0.70;
    private const TIME_MAX_SIZE = 108;
    private const TIME_MIN_SIZE = 48;
    private const TIME_MAX_HEIGHT = 78;
    private const TIME_FACES = [
        ["RobotoCondensedBold"],
        ["BionicBold", "RobotoCondensedBold"],
        ["RobotoCondensedRegular", "RobotoCondensedBold"],
        ["RobotoBold", "RobotoCondensedBold"],
        ["KosugiRegular", "RobotoCondensedRegular", "RobotoCondensedBold"]
    ];
    private const SIZE_SCALES = [0.58, 0.72, 0.88, 1.05];
    private const BITMAP_SIZES = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_THAI_HOT];
    private const LABEL_FONTS = [
        Graphics.FONT_XTINY,
        Graphics.FONT_TINY,
        Graphics.FONT_SMALL,
        Graphics.FONT_MEDIUM,
        Graphics.FONT_LARGE
    ];

    private const ARC_PEN = 3;
    private const OUTER_INSET = 3;
    private const INNER_INSET = 9;
    private const TICK_COUNT = 12;
    private const TICK_OUTER_INSET = 14;
    private const TICK_LENGTH = 5;
    private const TICK_PEN = 2;

    private const CARDINAL_DOT_INSET = 16;
    private const CARDINAL_DOT_RADIUS = 2;

    // Base hand lengths (scaled further by Hours/Minutes size settings).
    private const HOUR_HAND_RATIO = 0.34;
    private const MINUTE_HAND_RATIO = 0.52;
    private const HUB_RADIUS = 3;

    private const TOP_MARGIN = 24;
    private const BOTTOM_MARGIN = 28;
    private const BAND_PAD = 12;
    private const LINE_PAD = 5;

    private var _hoursFont as Graphics.FontType = Graphics.FONT_NUMBER_HOT;
    private var _minutesFont as Graphics.FontType = Graphics.FONT_NUMBER_HOT;
    private var _fontRevision as Number = -1;
    private var _bgRevision as Number = -1;
    private var _bgBitmap as WatchUi.BitmapResource or Null = null;
    private var _ticks as Array<Array<Number>> = [];
    private var _cx as Number = 140;
    private var _cy as Number = 140;
    private var _radius as Number = 140;
    private var _visualTimeHalf as Number = 28;

    function initialize() {
    }

    function layout(dc as Graphics.Dc) as Void {
        _cx = dc.getWidth() / 2;
        _cy = dc.getHeight() / 2;
        _radius = _cx < _cy ? _cx : _cy;
        _fontRevision = -1;
        _ticks = computeTicks();
    }

    function draw(dc as Graphics.Dc, isAwake as Boolean, forceDetails as Boolean) as Void {
        var bg = Settings.backgroundColor;
        dc.setColor(bg, bg);
        dc.clear();
        drawBackgroundImage(dc);

        var stats = System.getSystemStats();
        var data = DataHub.capture();
        var now = Time.now();
        var showExtras = forceDetails || isAwake;
        var mode = Settings.displayMode;
        var showDigits = mode == Settings.DISPLAY_DIGITAL || mode == Settings.DISPLAY_HYBRID;
        var showHands = mode == Settings.DISPLAY_ANALOG || mode == Settings.DISPLAY_HYBRID;

        drawChrome(dc, stats, data, now, isAwake || forceDetails);

        if (showDigits) {
            ensureFonts(dc);
            _visualTimeHalf = visualTimeHalf(dc);
        } else {
            _visualTimeHalf = 18;
        }

        var topBandBottom = _cy - _visualTimeHalf - BAND_PAD;
        var bottomBandTop = _cy + _visualTimeHalf + BAND_PAD;
        var bottomBandBottom = dc.getHeight() - BOTTOM_MARGIN;

        if (showExtras) {
            drawHeaderBlock(dc, now, data, TOP_MARGIN, topBandBottom);
        }

        if (showDigits) {
            drawTimeCentered(dc, now, isAwake || forceDetails);
        }
        if (showHands) {
            if (mode == Settings.DISPLAY_ANALOG) {
                drawCardinalDots(dc);
            }
            drawAnalogHands(dc, now);
        }

        if (showExtras) {
            drawMetricBlock(dc, stats, data, bottomBandTop, bottomBandBottom);
        }
    }

    // Prefer ascent (visible digit height) over full font height (includes whitespace).
    private function visualTimeHalf(dc as Graphics.Dc) as Number {
        var hoursA = Graphics.getFontAscent(_hoursFont);
        var minutesA = Graphics.getFontAscent(_minutesFont);
        var ascent = hoursA > minutesA ? hoursA : minutesA;
        // Ascent ≈ visible digit height; keep a little extra air around the time.
        var half = (ascent * 0.58).toNumber() + 6;
        if (half < 24) {
            return 24;
        }
        if (half > TIME_MAX_HEIGHT / 2 + 8) {
            return TIME_MAX_HEIGHT / 2 + 8;
        }
        return half;
    }

    private function drawChrome(dc as Graphics.Dc, stats as System.Stats, data as DataHub.Snapshot, now as Time.Moment, showSeconds as Boolean) as Void {
        // Style-tuned bezel weight: stealth/casual thin, military/sport bold.
        var pen = ARC_PEN;
        var style = Settings.style;
        if (style == StylePresets.STYLE_STEALTH || style == StylePresets.STYLE_CASUAL) {
            pen = 2;
        } else if (style == StylePresets.STYLE_MILITARY || style == StylePresets.STYLE_SPORT) {
            pen = 4;
        }

        if (Settings.showStepsArc) {
            var stepPct = 0.0;
            if (data.stepGoal > 0) {
                stepPct = data.steps * 100.0 / data.stepGoal;
                if (stepPct > 100.0) {
                    stepPct = 100.0;
                }
            }
            drawProgressRing(dc, _radius - OUTER_INSET, stepPct, Settings.stepsColor, pen);
        }
        // Seconds arc fills through the current minute (high-power updates once/sec).
        if (Settings.showSecondsArc && showSeconds) {
            var info = Gregorian.info(now, Time.FORMAT_SHORT);
            var sec = info.sec as Number;
            var secColor = Settings.secondsColor;
            // Sport: brief pulse flash on the seconds ring each second.
            if (style == StylePresets.STYLE_SPORT && (sec % 2) == 0) {
                secColor = Settings.accentColor;
            }
            drawProgressRing(dc, _radius - INNER_INSET, sec * 100.0 / 60.0, secColor, pen);
        }

        if (style == StylePresets.STYLE_CASUAL) {
            drawSoftCardinals(dc);
        } else if (style == StylePresets.STYLE_STEALTH) {
            drawStealthHalo(dc);
        }

        if (Settings.showTicks) {
            if (style == StylePresets.STYLE_MILITARY) {
                drawHashRing(dc);
            } else if (style == StylePresets.STYLE_SPORT) {
                drawSportMarks(dc);
            } else {
                drawTicks(dc);
            }
        }
    }

    private function drawHeaderBlock(dc as Graphics.Dc, now as Time.Moment, data as DataHub.Snapshot, bandTop as Number, bandBottom as Number) as Void {
        var lines = [] as Array<String>;
        var fonts = [] as Array<Graphics.FontType>;
        var colors = [] as Array<Number>;

        if (Settings.showDate) {
            lines.add(formatDate(now));
            fonts.add(labelFont(Settings.dateFont));
            colors.add(Settings.dateColor);
        }
        if (Settings.showWeather) {
            var weather = weatherLine(data);
            if (weather != null) {
                lines.add(weather);
                fonts.add(labelFont(Settings.weatherFont));
                colors.add(Settings.weatherColor);
            }
        }
        drawCenteredBlock(dc, lines, fonts, colors, bandTop, bandBottom);
    }

    private function drawMetricBlock(dc as Graphics.Dc, stats as System.Stats, data as DataHub.Snapshot, bandTop as Number, bandBottom as Number) as Void {
        var lines = [] as Array<String>;
        var fonts = [] as Array<Graphics.FontType>;
        var colors = [] as Array<Number>;

        if (Settings.showHr) {
            lines.add(data.heartRate != null ? "HR " + (data.heartRate as Number).toString() : "HR --");
            fonts.add(labelFont(Settings.hrFont));
            colors.add(Settings.hrColor);
        }
        if (Settings.showSteps) {
            lines.add(data.steps.toString() + " steps");
            fonts.add(labelFont(Settings.stepsFont));
            colors.add(Settings.stepsColor);
        }
        if (Settings.showCalories) {
            lines.add(data.calories.toString() + " kcal");
            fonts.add(labelFont(Settings.caloriesFont));
            colors.add(Settings.caloriesColor);
        }
        if (Settings.showBattery) {
            lines.add(batteryShort(stats));
            fonts.add(labelFont(Settings.batteryFont));
            colors.add(Settings.batteryColor);
        }
        if (Settings.showDistance) {
            lines.add(data.distanceKm.format("%.1f") + " km");
            fonts.add(labelFont(Settings.distanceFont));
            colors.add(Settings.distanceColor);
        }
        if (Settings.showSun) {
            var sun = sunLine(data);
            if (sun != null) {
                lines.add(sun);
                fonts.add(labelFont(Settings.sunFont));
                colors.add(Settings.sunColor);
            }
        }
        drawCenteredBlock(dc, lines, fonts, colors, bandTop, bandBottom);
    }

    private function labelFont(index as Number) as Graphics.FontType {
        if (index < 0 || index >= LABEL_FONTS.size()) {
            return LABEL_FONTS[0];
        }
        return LABEL_FONTS[index];
    }

    // Vertically center a list of top-anchored lines inside [bandTop, bandBottom].
    private function drawCenteredBlock(dc as Graphics.Dc, lines as Array<String>, fonts as Array<Graphics.FontType>, colors as Array<Number>, bandTop as Number, bandBottom as Number) as Void {
        var count = lines.size();
        if (count == 0 || bandBottom <= bandTop) {
            return;
        }

        var heights = [] as Array<Number>;
        var total = 0;
        for (var i = 0; i < count; i++) {
            var h = dc.getFontHeight(fonts[i]);
            heights.add(h);
            total += h;
            if (i < count - 1) {
                total += LINE_PAD;
            }
        }

        var available = bandBottom - bandTop;
        var gap = LINE_PAD;
        if (total > available && count > 1) {
            // Compress padding first; if still too tall, later lines are clipped.
            gap = 1;
            total = 0;
            for (var j = 0; j < count; j++) {
                total += heights[j];
                if (j < count - 1) {
                    total += gap;
                }
            }
        }

        var y = bandTop;
        if (total < available) {
            y = bandTop + (available - total) / 2;
        }

        for (var k = 0; k < count; k++) {
            if (y + heights[k] > bandBottom) {
                return;
            }
            dc.setColor(colors[k], Graphics.COLOR_TRANSPARENT);
            dc.drawText(_cx, y, fonts[k], lines[k], Graphics.TEXT_JUSTIFY_CENTER);
            y += heights[k] + gap;
        }
    }

    private function batteryShort(stats as System.Stats) as String {
        var label = stats.battery.toNumber().toString() + "%";
        if (!Settings.showBatteryDays || !(stats has :batteryInDays) || stats.batteryInDays == null) {
            return label;
        }
        var days = stats.batteryInDays as Float;
        if (days >= 1) {
            return label + " · " + days.toNumber().toString() + "d";
        }
        return label + " · " + (days * 24).toNumber().toString() + "h";
    }

    private function weatherLine(data as DataHub.Snapshot) as String or Null {
        if (data.temperature == null && data.humidity == null && data.windMps == null) {
            return null;
        }
        var parts = [] as Array<String>;
        if (data.temperature != null) {
            parts.add((data.temperature as Number).toString() + "°");
        }
        if (data.humidity != null) {
            parts.add((data.humidity as Number).toString() + "%rh");
        }
        if (data.windMps != null) {
            parts.add((data.windMps as Float).format("%.0f") + "m/s");
        }
        if (parts.size() == 0) {
            return null;
        }
        var line = parts[0];
        for (var i = 1; i < parts.size(); i++) {
            line = line + " · " + parts[i];
        }
        return line;
    }

    private function sunLine(data as DataHub.Snapshot) as String or Null {
        if (data.sunrise == null && data.sunset == null) {
            return null;
        }
        var rise = data.sunrise != null ? data.sunrise as String : "--";
        var set = data.sunset != null ? data.sunset as String : "--";
        return rise + " · " + set;
    }

    private function drawTimeCentered(dc as Graphics.Dc, now as Time.Moment, animate as Boolean) as Void {
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var hours = formatHours(info.hour as Number);
        var minutes = (info.min as Number).format("%02d");
        var sec = info.sec as Number;

        var drawColon = Settings.showColon;
        // Tactix / Sport / Casual: blink colon once per second while awake (common digital-face motion).
        if (drawColon && animate) {
            var style = Settings.style;
            if (style == StylePresets.STYLE_TACTIX || style == StylePresets.STYLE_SPORT || style == StylePresets.STYLE_CASUAL) {
                drawColon = (sec % 2) == 0;
            }
        }

        var hoursWidth = dc.getTextWidthInPixels(hours, _hoursFont);
        // Reserve colon slot so blinking does not shift minutes.
        var colonWidth = 0;
        if (Settings.showColon) {
            colonWidth = dc.getTextWidthInPixels(":", _hoursFont);
        } else if (Settings.style == StylePresets.STYLE_STEALTH) {
            colonWidth = 8;
        }
        var minutesWidth = dc.getTextWidthInPixels(minutes, _minutesFont);
        var x = _cx - (hoursWidth + colonWidth + minutesWidth) / 2;

        // VCENTER at screen center — recommended for number/vector fonts with whitespace.
        var vcenter = Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER;
        dc.setColor(Settings.hoursColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, _cy, _hoursFont, hours, vcenter);
        if (drawColon) {
            dc.setColor(Settings.accentColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x + hoursWidth, _cy, _hoursFont, ":", vcenter);
        } else if (Settings.style == StylePresets.STYLE_STEALTH) {
            // Quiet separator bar instead of a colon (KOI-style stealth faces).
            var barX = x + hoursWidth + colonWidth / 2;
            dc.setColor(Settings.minutesColor, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            dc.drawLine(barX, _cy - 10, barX, _cy + 10);
            dc.setPenWidth(1);
        }
        dc.setColor(Settings.minutesColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + hoursWidth + colonWidth, _cy, _minutesFont, minutes, vcenter);
    }

    private function drawAnalogHands(dc as Graphics.Dc, now as Time.Moment) as Void {
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var hour = (info.hour as Number) % 12;
        var minute = info.min as Number;

        var minuteAngle = Math.PI * 2 * minute / 60.0;
        var hourAngle = Math.PI * 2 * hour / 12.0 + minuteAngle / 12.0;

        // Hours/Minutes size settings also drive hand length + thickness.
        var hourScale = SIZE_SCALES[Settings.hoursSize];
        var minScale = SIZE_SCALES[Settings.minutesSize];
        var style = Settings.style;

        // Theme-tuned base proportions (sword / syringe / baton / arrow / pencil).
        var hourRatio = HOUR_HAND_RATIO;
        var minRatio = MINUTE_HAND_RATIO;
        var hourHalfW = 3.5;
        var minHalfW = 2.0;
        if (style == StylePresets.STYLE_MILITARY) {
            hourRatio = 0.30;
            minRatio = 0.55;
            hourHalfW = 3.0;
            minHalfW = 1.6;
        } else if (style == StylePresets.STYLE_CASUAL) {
            hourRatio = 0.36;
            minRatio = 0.50;
            hourHalfW = 2.8;
            minHalfW = 2.0;
        } else if (style == StylePresets.STYLE_SPORT) {
            hourRatio = 0.38;
            minRatio = 0.56;
            hourHalfW = 4.5;
            minHalfW = 2.6;
        } else if (style == StylePresets.STYLE_STEALTH) {
            hourRatio = 0.32;
            minRatio = 0.48;
            hourHalfW = 1.6;
            minHalfW = 1.0;
        } else {
            // Tactix — arrow hands
            hourRatio = 0.35;
            minRatio = 0.54;
            hourHalfW = 3.8;
            minHalfW = 2.2;
        }

        var hourLen = (_radius * hourRatio * hourScale).toNumber();
        var minLen = (_radius * minRatio * minScale).toNumber();
        var hourW = (hourHalfW * hourScale).toNumber();
        var minW = (minHalfW * minScale).toNumber();
        if (hourW < 1) {
            hourW = 1;
        }
        if (minW < 1) {
            minW = 1;
        }

        drawStyleHand(dc, minuteAngle, minLen, minW, false, Settings.minutesColor);
        drawStyleHand(dc, hourAngle, hourLen, hourW, true, Settings.hoursColor);

        var hub = (HUB_RADIUS * ((hourScale + minScale) * 0.5)).toNumber();
        if (hub < 2) {
            hub = 2;
        }
        dc.setColor(Settings.hoursColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(_cx, _cy, hub);
        dc.setColor(Settings.backgroundColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(_cx, _cy, hub > 2 ? hub - 2 : 1);
    }

    // Style-specific hands: Tactix arrow, Military syringe, Casual baton, Sport sword, Stealth pencil.
    // Drawn with thick strokes (fillPolygon tuple typing is awkward in Monkey C).
    private function drawStyleHand(dc as Graphics.Dc, angle as Float, length as Number, halfW as Number, isHour as Boolean, color as Number) as Void {
        var style = Settings.style;
        var sin = Math.sin(angle);
        var cos = Math.cos(angle);
        var tipX = (_cx + length * sin).toNumber();
        var tipY = (_cy - length * cos).toNumber();
        var pen = halfW * 2;
        if (pen < 1) {
            pen = 1;
        }

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        if (style == StylePresets.STYLE_STEALTH) {
            dc.setPenWidth(pen < 2 ? 1 : 2);
            dc.drawLine(_cx, _cy, tipX, tipY);
            dc.setPenWidth(1);
            return;
        }

        if (style == StylePresets.STYLE_MILITARY) {
            // Syringe / field: thick shaft, needle tip.
            var shaft = (length * 0.72).toNumber();
            var sx = (_cx + shaft * sin).toNumber();
            var sy = (_cy - shaft * cos).toNumber();
            dc.setPenWidth(pen + 1);
            dc.drawLine(_cx, _cy, sx, sy);
            dc.setPenWidth(1);
            dc.drawLine(sx, sy, tipX, tipY);
            dc.setPenWidth(1);
            return;
        }

        if (style == StylePresets.STYLE_CASUAL) {
            // Baton: even thickness + rounded tip.
            dc.setPenWidth(pen);
            dc.drawLine(_cx, _cy, tipX, tipY);
            dc.fillCircle(tipX, tipY, halfW > 2 ? halfW : 2);
            dc.setPenWidth(1);
            return;
        }

        if (style == StylePresets.STYLE_SPORT) {
            // Sword: bold shaft, even thicker near tip.
            var mid = (length * 0.55).toNumber();
            var mx = (_cx + mid * sin).toNumber();
            var my = (_cy - mid * cos).toNumber();
            dc.setPenWidth(pen);
            dc.drawLine(_cx, _cy, mx, my);
            dc.setPenWidth(pen + (isHour ? 3 : 2));
            dc.drawLine(mx, my, tipX, tipY);
            dc.setPenWidth(1);
            return;
        }

        // Tactix — arrow: tapering body + chevron tip.
        var bodyLen = length - (isHour ? 10 : 8);
        if (bodyLen < length / 2) {
            bodyLen = (length * 0.7).toNumber();
        }
        var bx = (_cx + bodyLen * sin).toNumber();
        var by = (_cy - bodyLen * cos).toNumber();
        dc.setPenWidth(pen);
        dc.drawLine(_cx, _cy, bx, by);
        // Arrowhead: two short strokes + center
        var px = cos;
        var py = sin;
        var aw = halfW + 3;
        var leftX = (bx + aw * px).toNumber();
        var leftY = (by + aw * py).toNumber();
        var rightX = (bx - aw * px).toNumber();
        var rightY = (by - aw * py).toNumber();
        dc.setPenWidth(pen > 2 ? pen - 1 : 2);
        dc.drawLine(leftX, leftY, tipX, tipY);
        dc.drawLine(rightX, rightY, tipX, tipY);
        dc.drawLine(bx, by, tipX, tipY);
        dc.setPenWidth(1);
    }

    private function drawCardinalDots(dc as Graphics.Dc) as Void {
        var r = _radius - CARDINAL_DOT_INSET;
        for (var i = 0; i < 4; i++) {
            var angle = Math.PI * 2 * i / 4.0;
            var x = (_cx + r * Math.sin(angle)).toNumber();
            var y = (_cy - r * Math.cos(angle)).toNumber();
            dc.setColor(i == 0 ? Settings.accentColor : Settings.trackColor, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x, y, CARDINAL_DOT_RADIUS);
        }
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

        var maxWidth = dc.getWidth() * TIME_WIDTH_RATIO;
        var width = widestTimeWidth(dc);
        if (largest > 0 && width > maxWidth) {
            var shrink = maxWidth / width;
            _hoursFont = timeFontFor(Settings.hoursSize, largest, shrink);
            _minutesFont = timeFontFor(Settings.minutesSize, largest, shrink);
        }

        var ascent = Graphics.getFontAscent(_hoursFont);
        var minutesA = Graphics.getFontAscent(_minutesFont);
        if (minutesA > ascent) {
            ascent = minutesA;
        }
        if (largest > 0 && ascent > TIME_MAX_HEIGHT) {
            var shrinkH = TIME_MAX_HEIGHT * 1.0 / ascent;
            _hoursFont = timeFontFor(Settings.hoursSize, largest, shrinkH);
            _minutesFont = timeFontFor(Settings.minutesSize, largest, shrinkH);
        }
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
                var wd = weekday.toUpper();
                if (wd.length() > 2) {
                    wd = wd.substring(0, 2);
                }
                return wd + " " + day.toString() + " " + month;
        }
    }

    private function fitLargestSize(dc as Graphics.Dc) as Number {
        var maxWidth = dc.getWidth() * TIME_WIDTH_RATIO;
        for (var size = TIME_MAX_SIZE; size >= TIME_MIN_SIZE; size -= 4) {
            var font = Graphics.getVectorFont({:face => TIME_FACES[Settings.timeFont], :size => size});
            if (font == null) {
                return 0;
            }
            if (dc.getTextWidthInPixels("00:00", font) <= maxWidth && Graphics.getFontAscent(font) <= TIME_MAX_HEIGHT) {
                return size;
            }
        }
        return TIME_MIN_SIZE;
    }

    private function drawBackgroundImage(dc as Graphics.Dc) as Void {
        ensureBackgroundBitmap();
        if (_bgBitmap == null) {
            return;
        }
        var bmp = _bgBitmap as WatchUi.BitmapResource;
        // Full-bleed: stretch artwork to the whole round screen.
        if (dc has :drawScaledBitmap) {
            dc.drawScaledBitmap(0, 0, dc.getWidth(), dc.getHeight(), bmp);
        } else {
            dc.drawBitmap(0, 0, bmp);
        }
    }

    private function ensureBackgroundBitmap() as Void {
        if (_bgRevision == Settings.revision) {
            return;
        }
        _bgRevision = Settings.revision;
        _bgBitmap = null;
        var id = Settings.backgroundImage;
        if (id == Settings.BG_IMAGE_BEAR) {
            _bgBitmap = WatchUi.loadResource(Rez.Drawables.BgBear) as WatchUi.BitmapResource;
        } else if (id == Settings.BG_IMAGE_WOLF) {
            _bgBitmap = WatchUi.loadResource(Rez.Drawables.BgWolf) as WatchUi.BitmapResource;
        } else if (id == Settings.BG_IMAGE_SCOPE) {
            _bgBitmap = WatchUi.loadResource(Rez.Drawables.BgScope) as WatchUi.BitmapResource;
        }
    }

    private function drawProgressRing(dc as Graphics.Dc, r as Number, percent as Float, color as Number, pen as Number) as Void {
        dc.setPenWidth(pen);
        dc.setColor(Settings.trackColor, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(_cx, _cy, r);

        var sweep = (percent * 360 / 100).toNumber();
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
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
            dc.setColor(i == 0 ? Settings.accentColor : Settings.trackColor, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(tick[0], tick[1], tick[2], tick[3]);
        }
        dc.setPenWidth(1);
    }

    // Military: dense 60-mark hash ring (field chronograph feel).
    private function drawHashRing(dc as Graphics.Dc) as Void {
        var outer = _radius - TICK_OUTER_INSET + 2;
        for (var i = 0; i < 60; i++) {
            var major = (i % 5) == 0;
            var len = major ? TICK_LENGTH + 4 : TICK_LENGTH - 1;
            var angle = Math.PI * 2 * i / 60.0;
            var sin = Math.sin(angle);
            var cos = Math.cos(angle);
            var x1 = (_cx + (outer - len) * sin).toNumber();
            var y1 = (_cy - (outer - len) * cos).toNumber();
            var x2 = (_cx + outer * sin).toNumber();
            var y2 = (_cy - outer * cos).toNumber();
            dc.setPenWidth(major ? 2 : 1);
            dc.setColor(i == 0 ? Settings.accentColor : (major ? 0x888888 : Settings.trackColor), Graphics.COLOR_TRANSPARENT);
            dc.drawLine(x1, y1, x2, y2);
        }
        dc.setPenWidth(1);
    }

    // Sport: bold cardinal wedges instead of fine ticks.
    private function drawSportMarks(dc as Graphics.Dc) as Void {
        var outer = _radius - TICK_OUTER_INSET + 2;
        var inner = outer - TICK_LENGTH - 6;
        for (var i = 0; i < 4; i++) {
            var angle = Math.PI * 2 * i / 4.0;
            var sin = Math.sin(angle);
            var cos = Math.cos(angle);
            var x1 = (_cx + inner * sin).toNumber();
            var y1 = (_cy - inner * cos).toNumber();
            var x2 = (_cx + outer * sin).toNumber();
            var y2 = (_cy - outer * cos).toNumber();
            dc.setPenWidth(i == 0 ? 5 : 3);
            dc.setColor(i == 0 ? Settings.accentColor : Settings.hoursColor, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(x1, y1, x2, y2);
        }
        dc.setPenWidth(1);
    }

    // Casual: soft cardinal dots only (no hard tick chrome).
    private function drawSoftCardinals(dc as Graphics.Dc) as Void {
        var r = _radius - CARDINAL_DOT_INSET - 2;
        for (var i = 0; i < 4; i++) {
            var angle = Math.PI * 2 * i / 4.0;
            var x = (_cx + r * Math.sin(angle)).toNumber();
            var y = (_cy - r * Math.cos(angle)).toNumber();
            dc.setColor(i == 0 ? Settings.accentColor : 0x444444, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x, y, i == 0 ? 3 : 2);
        }
    }

    // Stealth: faint outer halo, cream-on-black evening wear cue.
    private function drawStealthHalo(dc as Graphics.Dc) as Void {
        dc.setPenWidth(1);
        dc.setColor(Settings.lightBackground ? 0xDDDDDD : 0x333333, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(_cx, _cy, _radius - OUTER_INSET);
        dc.setPenWidth(1);
    }
}
