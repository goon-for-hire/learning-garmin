import Toybox.Lang;
import Toybox.Test;

// Run with "Monkey C: Run Tests". (:test) code is left out of normal builds.
// The zones are made-up round numbers so every expected value is exact.

(:test)
function zoneValueInsideZones(logger as Logger) as Boolean {
    var zones = [100, 120, 140, 160, 180, 200] as Array<Number>;
    Test.assertEqual(ZoneMath.zoneValue(100, zones), 1.0);    // bottom of zone 1
    Test.assertEqual(ZoneMath.zoneValue(125, zones), 2.25);   // a quarter into zone 2
    Test.assertEqual(ZoneMath.zoneValue(170, zones), 4.5);    // halfway through zone 4
    return true;
}

(:test)
function zoneValueOutsideZones(logger as Logger) as Boolean {
    var zones = [100, 120, 140, 160, 180, 200] as Array<Number>;
    Test.assertEqual(ZoneMath.zoneValue(50, zones), 0.5);     // below zone 1
    Test.assertEqual(ZoneMath.zoneValue(250, zones), 5.99);   // above max HR
    Test.assertEqual(ZoneMath.zoneValue(0, zones), 0.0);      // no reading
    Test.assertEqual(ZoneMath.zoneValue(150, [100, 120] as Array<Number>), 0.0);   // bad profile
    return true;
}

(:test)
function gaugeAndColours(logger as Logger) as Boolean {
    Test.assertEqual(ZoneMath.gaugeFraction(0.5), 0.0);
    Test.assertEqual(ZoneMath.gaugeFraction(3.5), 0.5);
    Test.assertEqual(ZoneMath.colorFor(4.2), 0xFF5500);
    Test.assertEqual(ZoneMath.colorFor(0.3), 0xAAAAAA);
    Test.assertEqual(ZoneMath.minutesText(725000), "12:05");
    return true;
}
