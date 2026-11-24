import Toybox.Lang;
import Toybox.Test;

// Koans, part 4: classes, inheritance, has, enums and statics.

class WorkoutSet {
    public var reps as Number;
    public var kg as Float;

    function initialize(reps as Number, kg as Float) {
        self.reps = reps;
        self.kg = kg;
    }

    function volume() as Float {
        return reps * kg;
    }
}

class BodyweightSet extends WorkoutSet {

    function initialize(reps as Number) {
        // Call the parent's initialize explicitly, by class name.
        WorkoutSet.initialize(reps, 0.0);
    }

    //! Override: for bodyweight work, count the reps as the volume.
    function volume() as Float {
        return reps.toFloat();
    }
}

(:test)
function koan20_objects(logger as Logger) as Boolean {
    var squat = new WorkoutSet(5, 100.0);
    Test.assertEqual(squat.volume(), FILL_ME_IN);

    // == on objects compares identity, not contents.
    var a = new WorkoutSet(5, 80.0);
    var b = new WorkoutSet(5, 80.0);
    Test.assertEqual(a == b, FILL_ME_IN);
    Test.assertEqual(a == a, FILL_ME_IN);
    return true;
}

(:test)
function koan21_inheritance(logger as Logger) as Boolean {
    var pullUps = new BodyweightSet(12);
    Test.assertEqual(pullUps.volume(), FILL_ME_IN);
    Test.assertEqual(pullUps.kg, FILL_ME_IN);
    Test.assertEqual(pullUps instanceof WorkoutSet, FILL_ME_IN);
    return true;
}

(:test)
function koan22_has(logger as Logger) as Boolean {
    // "has" asks at runtime whether an object or module has a member with that name.
    // On real watches it's how you check for optional APIs.
    var squat = new WorkoutSet(5, 100.0);
    Test.assertEqual(squat has :volume, FILL_ME_IN);
    Test.assertEqual(squat has :rest, FILL_ME_IN);
    Test.assertEqual(Toybox has :ActivityRecording, FILL_ME_IN);
    return true;
}

enum Lift {
    LIFT_SQUAT,
    LIFT_BENCH,
    LIFT_DEADLIFT
}

class Plates {
    //! Static: called on the class, no instance needed.
    static function perSide(totalKg as Float, barKg as Float) as Float {
        return (totalKg - barKg) / 2;
    }
}

(:test)
function koan23_enumsAndStatics(logger as Logger) as Boolean {
    // Enum members are Numbers, counting from 0 unless you assign values.
    Test.assertEqual(LIFT_DEADLIFT, FILL_ME_IN);
    Test.assertEqual(Plates.perSide(100.0, 20.0), FILL_ME_IN);
    return true;
}
