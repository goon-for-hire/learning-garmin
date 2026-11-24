import Toybox.Lang;
import Toybox.Test;

// Koans, part 2: arrays, dictionaries and tuples.

(:test)
function koan10_arrays(logger as Logger) as Boolean {
    // "as Array<Number>" makes a typed container: the checker rejects non-Numbers.
    var reps = [8, 8, 6] as Array<Number>;
    reps.add(5);
    Test.assertEqual(reps.size(), /*K*/4/*K*/);
    Test.assertEqual(reps[3], /*K*/5/*K*/);
    Test.assertEqual(reps.indexOf(6), /*K*/2/*K*/);
    Test.assertEqual(reps.indexOf(12), /*K*/-1/*K*/);
    return true;
}

(:test)
function koan11_loops(logger as Logger) as Boolean {
    var reps = [8, 8, 6, 5] as Array<Number>;
    var total = 0;
    for (var i = 0; i < reps.size(); i++) {
        total += reps[i];
    }
    Test.assertEqual(total, /*K*/27/*K*/);
    return true;
}

(:test)
function koan12_arraysAreReferences(logger as Logger) as Boolean {
    var a = [1, 2] as Array<Number>;
    var b = a;   // copies the reference, not the array
    b.add(3);
    Test.assertEqual(a.size(), /*K*/3/*K*/);
    return true;
}

(:test)
function koan13_slices(logger as Logger) as Boolean {
    // slice(start, end) copies [start, end): the end index is excluded.
    var weights = [10, 20, 30, 40] as Array<Number>;
    var middle = weights.slice(1, 3);
    Test.assertEqual(middle.size(), /*K*/2/*K*/);
    Test.assertEqual(middle[0], /*K*/20/*K*/);
    return true;
}

(:test)
function koan14_dictionaries(logger as Logger) as Boolean {
    var best = { "squat" => 120, "bench" => 85 } as Dictionary<String, Number>;
    best["deadlift"] = 160;
    Test.assertEqual(best.size(), /*K*/3/*K*/);
    Test.assertEqual(best.hasKey("bench"), /*K*/true/*K*/);
    // A missing key gives null, not an error.
    Test.assertEqual(best["row"], /*K*/null/*K*/);
    best.remove("squat");
    Test.assertEqual(best.size(), /*K*/2/*K*/);

    // Symbols make cheap, typo-proof keys. The API uses them for options.
    var options = { :reps => 5, :kg => 80.0 };
    Test.assertEqual(options[:reps], /*K*/5/*K*/);
    return true;
}

(:test)
function koan15_tuples(logger as Logger) as Boolean {
    // A tuple (System 7+) has a fixed length and a type per position.
    var set = [5, "squat"] as [Number, String];
    Test.assertEqual(set[0], /*K*/5/*K*/);
    Test.assert(sameText(set[1], /*K*/"squat"/*K*/));
    return true;
}
