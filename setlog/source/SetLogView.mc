import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

const ACCENT = 0xFF5500;

//! SetLog's main screen. It draws whatever state the workout is in and
//! never changes the workout itself.
class SetLogView extends WatchUi.View {

    private var _workout as Workout;

    // A small cache for the "Last: 8 × 100 kg" line, which needs a Storage
    // read. It only changes when the exercise or the number of sets changes.
    private var _lastKey as Number = -1;
    private var _lastText as String? = null;

    function initialize(workout as Workout) {
        View.initialize();
        _workout = workout;
    }

    //! Coming back from a menu (units may have changed): rebuild the cache.
    function onShow() as Void {
        _lastKey = -1;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var cx = dc.getWidth() / 2;
        var h = dc.getHeight();

        switch (_workout.state) {
            case STATE_READY:
                drawReady(dc, cx, h);
                break;
            case STATE_LIFTING:
                drawLifting(dc, cx, h);
                break;
            case STATE_RESTING:
                drawResting(dc, cx, h);
                break;
            case STATE_PAUSED:
                drawPaused(dc, cx, h);
                break;
            default:
                drawDone(dc, cx, h);
        }
    }

    // ------------------------------------------------------------ states

    private function drawReady(dc as Dc, cx as Number, h as Number) as Void {
        line(dc, cx, h * 20 / 100, Graphics.FONT_XTINY, Graphics.COLOR_LT_GRAY, Format.text(Rez.Strings.ChangeHint));
        line(dc, cx, h * 38 / 100, Graphics.FONT_MEDIUM, Graphics.COLOR_WHITE, Exercises.name(_workout.exercise));
        var plan = Store.planNote();
        if (plan != null) {
            line(dc, cx, h * 53 / 100, Graphics.FONT_XTINY, Graphics.COLOR_LT_GRAY, plan);
        }
        line(dc, cx, h * 68 / 100, Graphics.FONT_SMALL, ACCENT, Format.text(Rez.Strings.ReadyHint));
        drawHeartRate(dc, cx, h * 84 / 100);
    }

    private function drawLifting(dc as Dc, cx as Number, h as Number) as Void {
        line(dc, cx, h * 15 / 100, Graphics.FONT_SMALL, ACCENT,
            Lang.format(Format.text(Rez.Strings.SetLabel), [_workout.setNumber()]));
        line(dc, cx, h * 30 / 100, Graphics.FONT_MEDIUM, Graphics.COLOR_WHITE, Exercises.name(_workout.exercise));
        line(dc, cx, h * 50 / 100, Graphics.FONT_NUMBER_MEDIUM, Graphics.COLOR_WHITE,
            Format.clock(_workout.setSeconds()));
        var last = lastSetText();
        if (last != null) {
            line(dc, cx, h * 67 / 100, Graphics.FONT_XTINY, Graphics.COLOR_LT_GRAY, last);
        }
        line(dc, cx, h * 77 / 100, Graphics.FONT_XTINY, Graphics.COLOR_LT_GRAY, Format.text(Rez.Strings.LiftHint));
        drawHeartRate(dc, cx, h * 88 / 100);
    }

    private function drawResting(dc as Dc, cx as Number, h as Number) as Void {
        // The ring from Module 5 fills up as the rest runs out.
        drawProgressRing(dc, cx, h / 2, cx - 6, 8, _workout.restFraction(), Graphics.COLOR_DK_GRAY, ACCENT);
        line(dc, cx, h * 24 / 100, Graphics.FONT_SMALL, ACCENT, Format.text(Rez.Strings.RestLabel));
        line(dc, cx, h * 46 / 100, Graphics.FONT_NUMBER_HOT, Graphics.COLOR_WHITE,
            Format.clock(_workout.restSecondsLeft()));
        line(dc, cx, h * 67 / 100, Graphics.FONT_XTINY, Graphics.COLOR_LT_GRAY,
            Lang.format(Format.text(Rez.Strings.NextLabel), [Exercises.name(_workout.exercise), _workout.setNumber()]));
        drawHeartRate(dc, cx, h * 79 / 100);
    }

    private function drawPaused(dc as Dc, cx as Number, h as Number) as Void {
        line(dc, cx, h * 30 / 100, Graphics.FONT_MEDIUM, ACCENT, Format.text(Rez.Strings.PausedLabel));
        line(dc, cx, h * 48 / 100, Graphics.FONT_SMALL, Graphics.COLOR_WHITE,
            totalsText(_workout.sets.size(), _workout.volumeKg));
        line(dc, cx, h * 66 / 100, Graphics.FONT_XTINY, Graphics.COLOR_LT_GRAY, Format.text(Rez.Strings.PausedHint));
    }

    private function drawDone(dc as Dc, cx as Number, h as Number) as Void {
        var summary = _workout.lastSummary;
        if (summary == null) {
            line(dc, cx, h * 42 / 100, Graphics.FONT_MEDIUM, Graphics.COLOR_LT_GRAY,
                Format.text(Rez.Strings.DiscardedLabel));
        } else {
            var sets = summary["sets"] as Number;
            var kg = (summary["kg"] as Numeric).toFloat();
            var minutes = summary["min"] as Number;
            line(dc, cx, h * 28 / 100, Graphics.FONT_MEDIUM, ACCENT, Format.text(Rez.Strings.SavedLabel));
            line(dc, cx, h * 45 / 100, Graphics.FONT_SMALL, Graphics.COLOR_WHITE, totalsText(sets, kg));
            line(dc, cx, h * 58 / 100, Graphics.FONT_SMALL, Graphics.COLOR_WHITE,
                Lang.format(Format.text(Rez.Strings.MinutesLabel), [minutes]));
        }
        line(dc, cx, h * 74 / 100, Graphics.FONT_XTINY, Graphics.COLOR_LT_GRAY, Format.text(Rez.Strings.DoneHint));
    }

    // ----------------------------------------------------------- helpers

    private function drawHeartRate(dc as Dc, cx as Number, y as Number) as Void {
        var hr = _workout.heartRate;
        var shown = "--";
        if (hr != null) {
            shown = hr.toString();
        }
        line(dc, cx, y, Graphics.FONT_XTINY, Graphics.COLOR_RED, Lang.format(Format.text(Rez.Strings.HrLabel), [shown]));
    }

    private function totalsText(sets as Number, kg as Float) as String {
        return Lang.format(Format.text(Rez.Strings.TotalsLabel), [sets, Settings.formatLoad(kg), Settings.unitLabel()]);
    }

    private function lastSetText() as String? {
        var key = _workout.exercise * 1000 + _workout.sets.size();
        if (key != _lastKey) {
            _lastKey = key;
            _lastText = null;
            var last = Store.lastSet(_workout.exercise);
            if (last != null) {
                _lastText = Lang.format(Format.text(Rez.Strings.LastLabel),
                    [last[0], Settings.formatLoad(last[1].toFloat()), Settings.unitLabel()]);
            }
        }
        return _lastText;
    }

    //! One line of centred text.
    private function line(dc as Dc, x as Number, y as Number, font as FontType, color as ColorType, text as String) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
