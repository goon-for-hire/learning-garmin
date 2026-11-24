import Toybox.Lang;
import Toybox.Test;

// Koans, part 1: numbers, strings and symbols.
// Replace each FILL_ME_IN with the value that makes the test pass,
// then run "Monkey C: Run Tests". Work top to bottom.

(:test)
function koan01_integerDivision(logger as Logger) as Boolean {
    // Number / Number stays a Number: the fraction is dropped.
    Test.assertEqual(7 / 2, /*K*/3/*K*/);
    return true;
}

(:test)
function koan02_mixedArithmetic(logger as Logger) as Boolean {
    // One Float operand makes the whole expression a Float.
    Test.assertEqual(7 / 2.0, /*K*/3.5/*K*/);
    return true;
}

(:test)
function koan03_modulo(logger as Logger) as Boolean {
    Test.assertEqual(17 % 5, /*K*/2/*K*/);
    return true;
}

(:test)
function koan04_longs(logger as Logger) as Boolean {
    // Number is 32-bit. A trailing l makes a 64-bit Long.
    var big = 2147483647l + 1;
    Test.assertEqual(big, /*K*/2147483648l/*K*/);
    return true;
}

(:test)
function koan05_stringBuilding(logger as Logger) as Boolean {
    // + with a String on the left converts the right side to text.
    var label = "Set " + 3 + " of " + 5;
    Test.assert(sameText(label, /*K*/"Set 3 of 5"/*K*/));
    return true;
}

(:test)
function koan06_formatting(logger as Logger) as Boolean {
    var minutes = 7;
    var seconds = 5;
    var clock = minutes.format("%d") + ":" + seconds.format("%02d");
    Test.assert(sameText(clock, /*K*/"7:05"/*K*/));

    // Lang.format fills $1$, $2$ ... from an array.
    var line = Lang.format("$1$ x $2$ kg", [5, 80]);
    Test.assert(sameText(line, /*K*/"5 x 80 kg"/*K*/));
    return true;
}

(:test)
function koan07_stringMethods(logger as Logger) as Boolean {
    var name = "bench press";
    Test.assertEqual(name.length(), /*K*/11/*K*/);
    Test.assertEqual(name.find("press"), /*K*/6/*K*/);
    Test.assert(sameText(name.substring(0, 5), /*K*/"bench"/*K*/));
    Test.assert(sameText(name.toUpper(), /*K*/"BENCH PRESS"/*K*/));
    return true;
}

(:test)
function koan08_parsing(logger as Logger) as Boolean {
    // toNumber() returns null when the text isn't a number. Hence the "or Null" in its type.
    Test.assertEqual("42".toNumber(), /*K*/42/*K*/);
    Test.assertEqual("forty-two".toNumber(), /*K*/null/*K*/);
    return true;
}

(:test)
function koan09_symbols(logger as Logger) as Boolean {
    // A Symbol is a compile-time name. Two mentions of the same name are the same value.
    var a = :squat;
    var b = :squat;
    Test.assertEqual(a == b, /*K*/true/*K*/);
    Test.assertEqual(:squat == :bench, /*K*/false/*K*/);
    return true;
}
