import Toybox.Lang;
import Toybox.Test;

// Koans, part 3: functions, control flow and method references.

//! Clamp a rep count into 0..99.
function clampReps(reps as Number) as Number {
    if (reps < 0) {
        return 0;
    }
    return reps > 99 ? 99 : reps;
}

(:test)
function koan16_functions(logger as Logger) as Boolean {
    Test.assertEqual(clampReps(-3), /*K*/0/*K*/);
    Test.assertEqual(clampReps(12), /*K*/12/*K*/);
    Test.assertEqual(clampReps(150), /*K*/99/*K*/);
    return true;
}

function liftName(lift as Symbol) as String {
    switch (lift) {
        case :squat:
            return "Squat";
        case :bench:
            return "Bench press";
        default:
            return "Unknown";
    }
}

(:test)
function koan17_switch(logger as Logger) as Boolean {
    Test.assert(sameText(liftName(:bench), /*K*/"Bench press"/*K*/));
    Test.assert(sameText(liftName(:curl), /*K*/"Unknown"/*K*/));
    return true;
}

function setsFor(goal as Symbol) as Number {
    var sets = 0;
    switch (goal) {
        case :strength:
            sets += 2;
            // No break: execution falls through into the next case, as in C.
        case :hypertrophy:
            sets += 3;
            break;
        default:
            sets = 1;
    }
    return sets;
}

(:test)
function koan18_fallThrough(logger as Logger) as Boolean {
    Test.assertEqual(setsFor(:hypertrophy), /*K*/3/*K*/);
    Test.assertEqual(setsFor(:strength), /*K*/5/*K*/);
    Test.assertEqual(setsFor(:mobility), /*K*/1/*K*/);
    return true;
}

class RepCounter {
    public var count as Number = 0;

    function bump() as Void {
        count += 1;
    }
}

(:test)
function koan19_methodReferences(logger as Logger) as Boolean {
    // Monkey C has no lambdas. A callback is a bound method: an object plus a function name.
    var counter = new RepCounter();
    var callback = counter.method(:bump);
    callback.invoke();
    callback.invoke();
    Test.assertEqual(counter.count, /*K*/2/*K*/);
    return true;
}
