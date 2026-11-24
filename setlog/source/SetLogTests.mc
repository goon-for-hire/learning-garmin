import Toybox.Lang;
import Toybox.Test;

// Run with "Monkey C: Run Tests". (:test) code is left out of normal builds.
// These cover the pure logic: no sensors, timers or recording involved.

(:test)
function storeUpgradesVersion1Entries(logger as Logger) as Boolean {
    var v2 = Store.upgradeEntry([1767225600, 12, 3450.0] as Array<Numeric>);
    Test.assertEqual(v2["t"], 1767225600);
    Test.assertEqual(v2["sets"], 12);
    Test.assertEqual(v2["kg"], 3450.0);
    Test.assertEqual(v2["min"], 0);
    return true;
}

(:test)
function settingsConvertPounds(logger as Logger) as Boolean {
    var saved = Settings.useLb;
    Settings.useLb = true;
    var kg = Settings.toKg(100.0);
    var ok = (kg - 45.36).abs() < 0.01;
    var label = Settings.formatLoad(kg);   // back to lb for display
    Settings.useLb = saved;                // restore before asserting
    Test.assertMessage(ok, "100 lb should be about 45.36 kg");
    Test.assertEqual(label, "100");
    return true;
}

(:test)
function settingsFormatKilograms(logger as Logger) as Boolean {
    var saved = Settings.useLb;
    Settings.useLb = false;
    var whole = Settings.formatLoad(100.0);
    var half = Settings.formatLoad(102.5);
    Settings.useLb = saved;
    Test.assertEqual(whole, "100");
    Test.assertEqual(half, "102.5");
    return true;
}

(:test)
function stepFactoryMapsIndexes(logger as Logger) as Boolean {
    var kg = new StepFactory(0.0, 2.5, 121, 1);
    Test.assertEqual(kg.valueAt(41), 102.5);
    Test.assertEqual(kg.indexOf(101.0), 40);     // 100.0 is the nearest step
    Test.assertEqual(kg.indexOf(999.0), 120);    // clamped to the last item
    Test.assertEqual(kg.label(41), "102.5");
    return true;
}

(:test)
function clockFormatsSeconds(logger as Logger) as Boolean {
    Test.assertEqual(Format.clock(65), "1:05");
    Test.assertEqual(Format.clock(0), "0:00");
    Test.assertEqual(Format.clock(-3), "0:00");
    return true;
}
