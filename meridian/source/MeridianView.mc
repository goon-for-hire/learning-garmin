import Toybox.ActivityMonitor;
import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

//! An analog face with a step ring, date, battery, heart rate and a seconds window.
//!
//! Power states on a MIP watch:
//!   awake (about 10 s after a wrist raise): onUpdate() every second
//!   asleep: onUpdate() at the top of each minute, onPartialUpdate() for the other 59 seconds
class MeridianView extends WatchUi.WatchFace {

    private var _cx as Number = 0;
    private var _cy as Number = 0;
    private var _awake as Boolean = true;
    private var _partialAllowed as Boolean = true;
    private var _heartRate as String = "--";

    // Values gathered once per onUpdate(). Partial updates only draw, never fetch.
    private var _dateText as String = "";
    private var _batteryText as String = "";
    private var _stepFraction as Float = 0.0;

    // The seconds window, at 3 o'clock: x, y, width, height.
    private var _secX as Number = 0;
    private var _secY as Number = 0;
    private var _secW as Number = 0;
    private var _secH as Number = 0;

    // Hand outlines around (0, 0), pointing straight up.
    private var _hourHand as Array<Point2D> = [[-7, 16], [-5, -66], [5, -66], [7, 16]] as Array<Point2D>;
    private var _minuteHand as Array<Point2D> = [[-5, 18], [-3, -104], [3, -104], [5, 18]] as Array<Point2D>;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        _cx = dc.getWidth() / 2;
        _cy = dc.getHeight() / 2;
        var size = dc.getTextDimensions("88", Graphics.FONT_TINY);
        _secW = size[0] + 6;
        _secH = size[1];
        _secX = _cx + 62;
        _secY = _cy - _secH / 2;
    }

    function onShow() as Void {
        subscribeHeartRate();
    }

    function onHide() as Void {
        if (Toybox has :Complications) {
            Complications.unsubscribeFromAllUpdates();
        }
    }

    //! Full redraw. Every second while awake, once a minute while asleep.
    function onUpdate(dc as Dc) as Void {
        dc.clearClip();
        refreshData();
        drawFace(dc);
        // Asleep without partial updates, seconds would freeze for a minute, so hide them.
        if (MeridianSettings.showSeconds && (_awake || _partialAllowed)) {
            drawSeconds(dc);
        }
    }

    //! Asleep only: redraw just the seconds window. Must stay inside the power budget.
    function onPartialUpdate(dc as Dc) as Void {
        if (!MeridianSettings.showSeconds || !_partialAllowed) {
            return;
        }
        // Repaint the whole face, but the clip means only the window's pixels change.
        // The hands ignore seconds, so the window always matches the rest of the screen.
        dc.setClip(_secX, _secY, _secW, _secH);
        drawFace(dc);
        drawSeconds(dc);
        dc.clearClip();
    }

    function onExitSleep() as Void {
        _awake = true;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void {
        _awake = false;
        WatchUi.requestUpdate();
    }

    //! Called by the delegate when partial updates cost too much. The system stops calling
    //! onPartialUpdate() anyway; this keeps onUpdate() from drawing seconds that would freeze.
    function disablePartialUpdates() as Void {
        _partialAllowed = false;
    }

    //! The heart-rate complication pushes new values to onComplicationChanged().
    function onComplicationChanged(id as Complications.Id) as Void {
        try {
            var value = Complications.getComplication(id).value;
            if (value != null) {
                _heartRate = value.toString();
            } else {
                _heartRate = "--";
            }
        } catch (e instanceof Complications.ComplicationNotFoundException) {
            _heartRate = "--";
        }
    }

    private function subscribeHeartRate() as Void {
        if (Toybox has :Complications) {
            Complications.registerComplicationChangeCallback(method(:onComplicationChanged));
            try {
                Complications.subscribeToUpdates(new Complications.Id(Complications.COMPLICATION_TYPE_HEART_RATE));
            } catch (e) {
                _heartRate = "--";
            }
        }
    }

    //! Fetch everything the face shows. Runs at most once a second, never in a partial update.
    private function refreshData() as Void {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        _dateText = Lang.format("$1$ $2$", [today.day_of_week, today.day]).toUpper();
        _batteryText = System.getSystemStats().battery.format("%.0f") + "%";
        _stepFraction = stepFraction();
    }

    private function drawFace(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        var accent = MeridianSettings.accent;

        // Step progress around the bezel.
        drawProgressRing(dc, _cx, _cy, _cx - 6, 6, _stepFraction, Graphics.COLOR_DK_GRAY, accent);

        // Twelve hour ticks; the quarters are longer.
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        for (var i = 0; i < 12; i++) {
            var angle = i * Math.PI / 6;
            var outer = clockPoint(_cx, _cy, _cx - 16, angle);
            var inner = clockPoint(_cx, _cy, _cx - (i % 3 == 0 ? 34 : 26), angle);
            dc.drawLine(inner[0], inner[1], outer[0], outer[1]);
        }

        // Date at the top, battery at 9 o'clock, heart rate at the bottom.
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx, _cy - 72, Graphics.FONT_TINY, _dateText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(_cx - 62, _cy, Graphics.FONT_TINY, _batteryText,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(_cx, _cy + 72, Graphics.FONT_TINY, "HR " + _heartRate,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Hands. The minute hand deliberately ignores seconds: see onPartialUpdate().
        var clock = System.getClockTime();
        var minuteAngle = clock.min * Math.PI / 30;
        var hourAngle = ((clock.hour % 12) + clock.min / 60.0) * Math.PI / 6;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(rotatePoints(_hourHand, hourAngle, _cx, _cy));
        dc.fillPolygon(rotatePoints(_minuteHand, minuteAngle, _cx, _cy));
        dc.setColor(accent, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(_cx, _cy, 7);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(_cx, _cy, 3);
    }

    private function drawSeconds(dc as Dc) as Void {
        dc.setColor(MeridianSettings.accent, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_secX + _secW / 2, _cy, Graphics.FONT_TINY,
            System.getClockTime().sec.format("%02d"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    //! Today's steps as a fraction of the goal, capped at 1.0.
    //! Nested ifs keep the null narrowing obvious to the type checker.
    private function stepFraction() as Float {
        var info = ActivityMonitor.getInfo();
        var steps = info.steps;
        var goal = info.stepGoal;
        if (steps != null) {
            if (goal != null) {
                if (goal > 0) {
                    var fraction = steps.toFloat() / goal;
                    return fraction > 1.0 ? 1.0 : fraction;
                }
            }
        }
        return 0.0;
    }
}
