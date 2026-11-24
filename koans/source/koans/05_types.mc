import Toybox.Lang;
import Toybox.Test;

// Koans, part 5: Monkey Types. Null, narrowing, interfaces, casts, callbacks.

//! The first name longer than min characters, or null if there is none.
function firstLongerThan(names as Array<String>, min as Number) as String? {
    for (var i = 0; i < names.size(); i++) {
        if (names[i].length() > min) {
            return names[i];
        }
    }
    return null;
}

(:test)
function koan24_nullAndNarrowing(logger as Logger) as Boolean {
    var lifts = ["row", "squat", "deadlift"] as Array<String>;
    Test.assert(sameText(firstLongerThan(lifts, 4), FILL_ME_IN));
    Test.assertEqual(firstLongerThan(lifts, 10), FILL_ME_IN);

    var found = firstLongerThan(lifts, 6);
    var length = 0;
    if (found != null) {
        // In this branch the checker knows found is a String, not String or Null.
        length = found.length();
    }
    Test.assertEqual(length, FILL_ME_IN);
    return true;
}

//! A structural interface: anything with describe() as String fits, like a TypeScript interface.
typedef Describable as interface {
    function describe() as String;
};

class Plank {
    function describe() as String {
        return "plank";
    }
}

class Dip {
    function describe() as String {
        return "dip";
    }
}

function describeAll(items as Array<Describable>) as String {
    var text = "";
    for (var i = 0; i < items.size(); i++) {
        if (i > 0) {
            text += ", ";
        }
        text += items[i].describe();
    }
    return text;
}

(:test)
function koan25_interfaces(logger as Logger) as Boolean {
    // Plank and Dip share no base class. They fit Describable by their shape.
    var items = [new Plank(), new Dip()] as Array<Describable>;
    Test.assert(sameText(describeAll(items), FILL_ME_IN));
    return true;
}

(:test)
function koan26_casts(logger as Logger) as Boolean {
    // Storage, Properties and loadResource() return loosely typed values.
    // "as" only changes what the checker believes; nothing verifies it at runtime.
    var raw = { "reps" => 8, "kg" => 60.5 } as Dictionary<String, Number or Float>;
    var reps = raw["reps"] as Number;
    Test.assertEqual(reps + 1, FILL_ME_IN);
    return true;
}

class SetRecorder {
    public var last as Number = 0;

    function onSet(reps as Number) as Void {
        last = reps;
    }
}

//! A typed callback parameter: only methods taking (Number) and returning Void fit.
function notify(callback as Method(reps as Number) as Void, reps as Number) as Void {
    callback.invoke(reps);
}

(:test)
function koan27_typedCallbacks(logger as Logger) as Boolean {
    var recorder = new SetRecorder();
    notify(recorder.method(:onSet), 7);
    Test.assertEqual(recorder.last, FILL_ME_IN);
    return true;
}
