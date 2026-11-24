import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! A picker column that counts in steps: item i shows first + i * step.
//! getValue() returns the index, so onAccept() receives indexes and asks
//! the factory what they mean.
class StepFactory extends WatchUi.PickerFactory {

    private var _first as Float;
    private var _step as Float;
    private var _count as Number;
    private var _decimals as Number;

    function initialize(first as Float, step as Float, count as Number, decimals as Number) {
        PickerFactory.initialize();
        _first = first;
        _step = step;
        _count = count;
        _decimals = decimals;
    }

    function getSize() as Number {
        return _count;
    }

    function getValue(index as Number) as Object? {
        return index;
    }

    function getDrawable(index as Number, selected as Boolean) as Drawable? {
        var color = Graphics.COLOR_LT_GRAY;
        if (selected) {
            color = Graphics.COLOR_WHITE;
        }
        return new WatchUi.Text({
            :text => label(index),
            :color => color,
            :font => Graphics.FONT_NUMBER_MILD,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_CENTER
        });
    }

    function valueAt(index as Number) as Float {
        return _first + index * _step;
    }

    function label(index as Number) as String {
        var value = valueAt(index);
        if (_decimals == 0) {
            return value.toNumber().toString();
        }
        return value.format("%." + _decimals + "f");
    }

    //! The item nearest to a value, for the picker's :defaults.
    function indexOf(value as Float) as Number {
        var i = ((value - _first) / _step + 0.5).toNumber();
        if (i < 0) {
            return 0;
        }
        if (i >= _count) {
            return _count - 1;
        }
        return i;
    }
}

//! A centred line of text for a picker title or separator.
function pickerText(text as String, font as FontType) as WatchUi.Text {
    return new WatchUi.Text({
        :text => text,
        :color => Graphics.COLOR_WHITE,
        :font => font,
        :locX => WatchUi.LAYOUT_HALIGN_CENTER,
        :locY => WatchUi.LAYOUT_VALIGN_BOTTOM
    });
}

//! BACK at the end of a set: one picker, two columns, reps × load.
//! Step 1 works in kg and always starts on 8 × 20 kg. Module 10 remembers
//! the last set and adds pounds.
module SetPicker {

    function push(workout as Workout) as Void {
        var reps = new StepFactory(0.0, 1.0, 51, 0);           // 0 to 50
        var load = new StepFactory(0.0, 2.5, 121, 1);          // 0 to 300 kg
        var defaults = [8, 0, load.indexOf(20.0)] as Array<Number>;

        var title = Lang.format(Format.text(Rez.Strings.PickerTitle), ["kg"]);
        var picker = new WatchUi.Picker({
            :title => pickerText(title, Graphics.FONT_SMALL),
            :pattern => [reps, pickerText("×", Graphics.FONT_MEDIUM), load] as Array<PickerFactory or Drawable>,
            :defaults => defaults
        });
        WatchUi.pushView(picker, new SetPickerDelegate(workout, reps, load), WatchUi.SLIDE_UP);
    }
}

class SetPickerDelegate extends WatchUi.PickerDelegate {

    private var _workout as Workout;
    private var _reps as StepFactory;
    private var _load as StepFactory;

    function initialize(workout as Workout, reps as StepFactory, load as StepFactory) {
        PickerDelegate.initialize();
        _workout = workout;
        _reps = reps;
        _load = load;
    }

    //! values has one entry per column: [reps index, null for the "×", load index].
    function onAccept(values as Array) as Boolean {
        var repsIndex = values[0];
        var loadIndex = values[2];
        WatchUi.popView(WatchUi.SLIDE_DOWN);   // a Picker never pops itself
        if (repsIndex instanceof Number) {
            if (loadIndex instanceof Number) {
                var reps = _reps.valueAt(repsIndex).toNumber();
                var kg = _load.valueAt(loadIndex);
                _workout.logSet(reps, kg);
                Format.toast(Lang.format(Format.text(Rez.Strings.SetLogged), [_workout.sets.size()]));
            }
        }
        return true;
    }

    //! BACK in the picker: nothing logged, the set carries on.
    function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
