import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

const ACCENT = 0xFF5500;

//! SetLog's main screen, step 1. It draws whatever state the workout is in
//! and never changes the workout itself.
class SetLogView extends WatchUi.View {

    private var _workout as Workout;

    function initialize(workout as Workout) {
        View.initialize();
        _workout = workout;
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

    private function drawReady(dc as Dc, cx as Number, h as Number) as Void {
        line(dc, cx, h * 20 / 100, Graphics.FONT_XTINY, Graphics.COLOR_LT_GRAY, Format.text(Rez.Strings.ChangeHint));
        line(dc, cx, h * 40 / 100, Graphics.FONT_MEDIUM, Graphics.COLOR_WHITE, Exercises.name(_workout.exercise));
        line(dc, cx, h * 65 / 100, Graphics.FONT_SMALL, ACCENT, Format.text(Rez.Strings.ReadyHint));
    }

    private function drawLifting(dc as Dc, cx as Number, h as Number) as Void {
        line(dc, cx, h * 25 / 100, Graphics.FONT_SMALL, ACCENT,
            Lang.format(Format.text(Rez.Strings.SetLabel), [_workout.setNumber()]));
        line(dc, cx, h * 45 / 100, Graphics.FONT_MEDIUM, Graphics.COLOR_WHITE, Exercises.name(_workout.exercise));
        line(dc, cx, h * 70 / 100, Graphics.FONT_XTINY, Graphics.COLOR_LT_GRAY, Format.text(Rez.Strings.LiftHint));
    }

    private function drawResting(dc as Dc, cx as Number, h as Number) as Void {
        line(dc, cx, h * 30 / 100, Graphics.FONT_MEDIUM, ACCENT, Format.text(Rez.Strings.RestLabel));
        line(dc, cx, h * 52 / 100, Graphics.FONT_XTINY, Graphics.COLOR_LT_GRAY,
            Lang.format(Format.text(Rez.Strings.NextLabel), [Exercises.name(_workout.exercise), _workout.setNumber()]));
        line(dc, cx, h * 68 / 100, Graphics.FONT_XTINY, Graphics.COLOR_LT_GRAY, totalsText(_workout.sets.size(), _workout.volumeKg));
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
            line(dc, cx, h * 30 / 100, Graphics.FONT_MEDIUM, ACCENT, Format.text(Rez.Strings.SavedLabel));
            line(dc, cx, h * 50 / 100, Graphics.FONT_SMALL, Graphics.COLOR_WHITE, totalsText(sets, kg));
        }
        line(dc, cx, h * 72 / 100, Graphics.FONT_XTINY, Graphics.COLOR_LT_GRAY, Format.text(Rez.Strings.DoneHint));
    }

    //! "5 sets · 2150 kg". Module 10 adds pounds.
    private function totalsText(sets as Number, kg as Float) as String {
        return Lang.format(Format.text(Rez.Strings.TotalsLabel), [sets, kg.format("%.0f"), "kg"]);
    }

    //! One line of centred text.
    private function line(dc as Dc, x as Number, y as Number, font as FontType, color as ColorType, text as String) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
