import Toybox.Lang;
import Toybox.Test;

// Koans, part 6: exceptions and memory.

class InvalidRepsException extends Lang.Exception {
    private var _text as String;

    function initialize(text as String) {
        Exception.initialize();
        _text = text;
    }

    function getErrorMessage() as String? {
        return _text;
    }
}

function parseReps(text as String) as Number {
    var value = text.toNumber();
    if (value instanceof Number) {
        if (value >= 0) {
            return value;
        }
    }
    throw new InvalidRepsException("not a rep count: " + text);
}

(:test)
function koan28_exceptions(logger as Logger) as Boolean {
    Test.assertEqual(parseReps("8"), FILL_ME_IN);

    var message = "";
    try {
        parseReps("eight");
    } catch (e instanceof InvalidRepsException) {
        var m = e.getErrorMessage();
        if (m != null) {
            message = m;
        }
    } finally {
        logger.debug("finally always runs");
    }
    Test.assert(sameText(message, FILL_ME_IN));
    return true;
}

(:test)
function koan29_weakReferences(logger as Logger) as Boolean {
    // Memory is reference-counted: an object is freed the moment its last
    // strong reference disappears. A weak reference doesn't count.
    var strong = new WorkoutSet(5, 100.0) as WorkoutSet?;
    var ref = (strong as WorkoutSet).weak();
    Test.assertEqual(ref.stillAlive(), FILL_ME_IN);

    strong = null;   // the only strong reference is gone, so the object is freed here
    Test.assertEqual(ref.stillAlive(), FILL_ME_IN);
    Test.assertEqual(ref.get(), FILL_ME_IN);
    return true;
}
