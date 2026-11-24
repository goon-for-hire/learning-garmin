import Toybox.Activity;
import Toybox.FitContributor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.UserProfile;
import Toybox.WatchUi;

// FIT developer field ids. They must match the ids in fit_contributions.xml.
// Keep them the same from version to version so charts stay comparable.
const ZONE_FIELD_ID = 0;
const HARD_FIELD_ID = 1;

//! Zone 4 and up counts as "hard" time.
const HARD_ZONE = 4.0;

//! Heart rate, a continuous zone value, a gauge, and time spent in zone 4+.
//!
//! The rule for data fields: compute() works, onUpdate() draws.
//! They run independently, so compute() only stores results in members
//! and onUpdate() only reads them.
class ZoneRingView extends WatchUi.DataField {

    // Results from compute(), read by onUpdate().
    private var _hr as Number? = null;
    private var _zone as Float = 0.0;
    private var _zones as Array<Number>? = null;

    // Time in zone 4 or higher, measured with the activity timer.
    private var _hardMs as Number = 0;
    private var _lastTimerMs as Number = 0;

    // FIT developer fields: one value per record (a chart) and one per session (a summary).
    private var _zoneField as FitContributor.Field;
    private var _hardField as FitContributor.Field;

    // The screen size, to tell a full-screen field from a smaller one.
    private var _screenW as Number;
    private var _screenH as Number;

    function initialize() {
        DataField.initialize();
        var screen = System.getDeviceSettings();
        _screenW = screen.screenWidth;
        _screenH = screen.screenHeight;
        _zoneField = createField("hr_zone", ZONE_FIELD_ID, FitContributor.DATA_TYPE_FLOAT,
            {:mesgType => FitContributor.MESG_TYPE_RECORD, :units => "zone"});
        _hardField = createField("zone4_minutes", HARD_FIELD_ID, FitContributor.DATA_TYPE_FLOAT,
            {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "min"});
        _hardField.setData(0.0);
        loadZones();
    }

    //! Zones belong to the sport of the activity this field is running in
    //! (running zones in a run, cycling zones on a ride, otherwise the generic set).
    private function loadZones() as Void {
        _zones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
    }

    // ---------------------------------------------------------------- data

    //! Called about once a second, whether or not the field is on screen.
    function compute(info as Activity.Info) as Void {
        var hr = info.currentHeartRate;   // null until the sensor has a reading
        var zones = _zones;               // local copy so the type checker can narrow it
        var zone = 0.0;
        if (hr != null) {
            if (zones != null) {
                zone = ZoneMath.zoneValue(hr, zones);
            }
        }
        _hr = hr;
        _zone = zone;
        _zoneField.setData(zone);   // written to the FIT file at the next record

        // timerTime stands still while the timer is stopped or paused,
        // so paused time never counts. A big jump (the field was added
        // mid-activity, or the timer was reset) is ignored.
        var timerMs = info.timerTime;
        if (timerMs != null) {
            var delta = timerMs - _lastTimerMs;
            if (delta > 0 && delta < 5000 && zone >= HARD_ZONE) {
                _hardMs += delta;
                _hardField.setData(_hardMs / 60000.0);
            }
            _lastTimerMs = timerMs;
        }
    }

    //! The activity timer events. A data field never sees the buttons, but it
    //! does hear what they did.
    function onTimerStart() as Void {
        loadZones();
    }

    function onTimerReset() as Void {
        _hardMs = 0;
        _lastTimerMs = 0;
        _hardField.setData(0.0);
    }

    // -------------------------------------------------------------- drawing

    // No onLayout() here. The same field can sit in several slots at once (the
    // simulator fills every slot of a layout with it), and the system calls
    // onLayout() then onUpdate() for each slot in turn. So onUpdate() takes its
    // size from dc every time instead of keeping it in members.
    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();

        // The watch decides the background colour (black or white, set by the user).
        var bg = getBackgroundColor();
        var fg = Graphics.COLOR_WHITE;
        if (bg == Graphics.COLOR_WHITE) {
            fg = Graphics.COLOR_BLACK;
        }
        dc.setColor(fg, bg);
        dc.clear();

        if (w == _screenW && h == _screenH) {
            drawGauge(dc, w, h, fg, bg);
        } else {
            drawBar(dc, w, h, fg);
        }
    }

    //! Full screen: a 270-degree gauge in five zone colours, a marker,
    //! and the numbers in the middle.
    private function drawGauge(dc as Dc, w as Number, h as Number, fg as ColorType, bg as ColorType) as Void {
        var cx = w / 2;
        var cy = h / 2;
        var pen = 12;
        var r = cx - pen;

        // drawArc() measures degrees from 3 o'clock, counter-clockwise.
        // The gauge starts at 225 degrees (about 7:30) and runs clockwise for
        // 270 degrees to 315 degrees (about 4:30): 54 degrees per zone.
        dc.setPenWidth(pen);
        for (var z = 0; z < 5; z++) {
            var start = 225 - z * 54 - 1;          // 1-degree gap each side
            var finish = 225 - (z + 1) * 54 + 1;
            dc.setColor(ZoneMath.COLORS[z], Graphics.COLOR_TRANSPARENT);
            dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, wrapDegrees(start), wrapDegrees(finish));
        }

        // The marker uses clock angles (0 = 12 o'clock, clockwise), like the
        // watch-face hands. 7:30 is 225 degrees clockwise from 12.
        if (_hr != null) {
            var clockDeg = 225 + 270 * ZoneMath.gaugeFraction(_zone);
            var p = clockPoint(cx, cy, r, Math.toRadians(clockDeg));
            dc.setColor(fg, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(p[0], p[1], pen / 2 + 4);
            dc.setColor(bg, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            dc.drawCircle(p[0], p[1], pen / 2 + 4);
        }

        // Numbers, stacked using the fonts' own heights.
        var bigFont = Graphics.FONT_NUMBER_HOT;
        var bigH = dc.getFontHeight(bigFont);
        var smallH = dc.getFontHeight(Graphics.FONT_SMALL);
        var hrY = cy - smallH / 2;

        dc.setColor(fg, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, hrY, bigFont, hrText(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(ZoneMath.colorFor(_zone), Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, hrY + bigH / 2, Graphics.FONT_SMALL, zoneText(), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(fg, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, hrY + bigH / 2 + smallH, Graphics.FONT_XTINY,
            "Z4+ " + ZoneMath.minutesText(_hardMs), Graphics.TEXT_JUSTIFY_CENTER);
    }

    //! Any smaller field: zone label, heart rate, and a five-segment bar.
    private function drawBar(dc as Dc, w as Number, h as Number, fg as ColorType) as Void {
        // On a round screen the bezel cuts into fields at the top and bottom.
        // Obscurity flags say which edges are cut. Only valid inside onUpdate().
        var flags = getObscurityFlags();
        var topCut = (flags & OBSCURE_TOP) != 0;
        var bottomCut = (flags & OBSCURE_BOTTOM) != 0;

        var top = 2;
        if (topCut) {
            top = h / 6;
        }
        var barH = 6;
        if (h >= 90) {
            barH = 10;
        }
        var barW = (w * 3) / 4;
        var gapBelow = 6;
        if (bottomCut) {
            barW = w / 2;
            gapBelow = h / 5;
        }
        var barX = (w - barW) / 2;
        var barY = h - barH - gapBelow;

        // Zone label at the top, in the zone's colour.
        var labelFont = Graphics.FONT_XTINY;
        dc.setColor(ZoneMath.colorFor(_zone), Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, top, labelFont, zoneText(), Graphics.TEXT_JUSTIFY_CENTER);

        // Heart rate in the biggest number font that fits between label and bar.
        var numberTop = top + dc.getFontHeight(labelFont);
        var font = pickNumberFont(dc, barY - numberTop - 8);
        dc.setColor(fg, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, (numberTop + barY - 8) / 2, font, hrText(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Five coloured segments...
        var segW = barW / 5;
        for (var z = 0; z < 5; z++) {
            dc.setColor(ZoneMath.COLORS[z], Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(barX + z * segW + 1, barY, segW - 2, barH);
        }

        // ...and a triangle pointing at where you are now.
        if (_hr != null) {
            var mx = barX + (barW * ZoneMath.gaugeFraction(_zone)).toNumber();
            dc.setColor(fg, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon([[mx - 5, barY - 8], [mx + 5, barY - 8], [mx, barY - 1]] as Array<Point2D>);
        }
    }

    // -------------------------------------------------------------- helpers

    //! The biggest number font whose line height fits in `space` pixels.
    private function pickNumberFont(dc as Dc, space as Number) as FontType {
        var fonts = [Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_MEDIUM,
                     Graphics.FONT_NUMBER_MILD, Graphics.FONT_SMALL] as Array<FontType>;
        for (var i = 0; i < fonts.size() - 1; i++) {
            if (dc.getFontHeight(fonts[i]) <= space) {
                return fonts[i];
            }
        }
        return fonts[fonts.size() - 1];
    }

    private function hrText() as String {
        var hr = _hr;
        if (hr == null) {
            return "--";
        }
        return hr.toString();
    }

    private function zoneText() as String {
        if (_hr == null) {
            return "Z-";
        }
        return "Z" + _zone.format("%.1f");
    }

    //! Any angle into 0..359. (In Monkey C, -44 % 360 is -44, not 316.)
    private function wrapDegrees(deg as Number) as Number {
        return ((deg % 360) + 360) % 360;
    }
}
