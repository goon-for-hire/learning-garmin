import Toybox.Lang;

//! Pure heart-rate-zone arithmetic. Nothing here touches the screen or the
//! sensors, so the unit tests in ZoneMathTests.mc can check all of it.
module ZoneMath {

    //! One colour per zone, Z1 to Z5. Every value is in the fenix 8's
    //! 64-colour palette (channels 00, 55, AA or FF).
    const COLORS = [0xAAAAAA, 0x00AAFF, 0x00AA00, 0xFF5500, 0xFF0000] as Array<Number>;

    //! Turn a heart rate into a continuous zone value: 3.4 means
    //! "40% of the way through zone 3". Below zone 1 the value runs from
    //! 0.0 to 1.0; at or above the top of zone 5 it stops at 5.99.
    //!
    //! zones is what UserProfile.getHeartRateZones() returns:
    //! [zone 1 min, zone 1 max, zone 2 max, zone 3 max, zone 4 max, zone 5 max]
    function zoneValue(hr as Number, zones as Array<Number>) as Float {
        if (hr <= 0 || zones.size() < 6) {
            return 0.0;
        }
        var lowest = zones[0];
        if (hr < lowest) {
            if (lowest <= 0) {
                return 0.0;
            }
            return hr.toFloat() / lowest;
        }
        // Zone i runs from zones[i - 1] up to (not including) zones[i].
        for (var i = 1; i < 6; i++) {
            var top = zones[i];
            if (hr < top) {
                var bottom = zones[i - 1];
                var span = top - bottom;
                if (span <= 0) {
                    return i.toFloat();   // a broken profile; don't divide by zero
                }
                return i + (hr - bottom).toFloat() / span;
            }
        }
        return 5.99;
    }

    //! Where a zone value sits along a gauge that starts at zone 1 and ends
    //! at the top of zone 5, from 0.0 to 1.0.
    function gaugeFraction(zone as Float) as Float {
        var f = (zone - 1.0) / 5.0;
        if (f < 0.0) {
            return 0.0;
        }
        if (f > 1.0) {
            return 1.0;
        }
        return f;
    }

    //! The colour for a zone value. Below zone 1 uses the zone 1 grey.
    function colorFor(zone as Float) as Number {
        var i = zone.toNumber();   // 3.4 -> 3 (toNumber() drops the fraction)
        if (i < 1) {
            i = 1;
        }
        if (i > 5) {
            i = 5;
        }
        return COLORS[i - 1];
    }

    //! "12:05" from milliseconds.
    function minutesText(ms as Number) as String {
        var seconds = ms / 1000;
        return (seconds / 60).format("%d") + ":" + (seconds % 60).format("%02d");
    }
}
