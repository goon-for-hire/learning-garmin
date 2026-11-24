import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

//! The user's settings, read once from Application.Properties and kept in
//! module variables so the rest of the app can read them cheaply.
//! (:glance) because onSettingsChanged() can run while the glance is showing.
(:glance)
module Settings {

    const UNITS_WATCH = 0;
    const UNITS_KG = 1;
    const UNITS_LB = 2;
    const KG_PER_LB = 0.45359237;

    var useLb as Boolean = false;
    var restSeconds as Number = 90;
    var vibrate as Boolean = true;
    var tone as Boolean = true;
    var exportUrl as String = "";

    //! Read everything again. Called at start-up and when settings change.
    function load() as Void {
        var units = unitsChoice();
        if (units == UNITS_WATCH) {
            useLb = System.getDeviceSettings().weightUnits == System.UNIT_STATUTE;
        } else {
            useLb = (units == UNITS_LB);
        }
        restSeconds = readNumber(Keys.REST, 90);
        if (restSeconds < 15) {
            restSeconds = 15;
        }
        vibrate = readBoolean(Keys.VIBRATE, true);
        tone = readBoolean(Keys.TONE, true);
        exportUrl = readString(Keys.EXPORT_URL, "");
    }

    function unitsChoice() as Number {
        return readNumber(Keys.UNITS, UNITS_WATCH);
    }

    // Setters write the property, then update the cached value.
    function setUnitsChoice(choice as Number) as Void {
        Application.Properties.setValue(Keys.UNITS, choice);
        load();
    }

    function setRestSeconds(seconds as Number) as Void {
        Application.Properties.setValue(Keys.REST, seconds);
        restSeconds = seconds;
    }

    function setVibrate(on as Boolean) as Void {
        Application.Properties.setValue(Keys.VIBRATE, on);
        vibrate = on;
    }

    function setTone(on as Boolean) as Void {
        Application.Properties.setValue(Keys.TONE, on);
        tone = on;
    }

    // ------------------------------------------------------------ weights
    // SetLog stores every weight in kg and converts only for display.

    function unitLabel() as String {
        return useLb ? "lb" : "kg";
    }

    function toDisplay(kg as Float) as Float {
        return useLb ? kg / KG_PER_LB : kg;
    }

    function toKg(display as Float) as Float {
        return useLb ? display * KG_PER_LB : display;
    }

    //! "100" or "102.5", in the user's unit.
    function formatLoad(kg as Float) as String {
        var value = toDisplay(kg);
        var nearest = (value + 0.5).toNumber();
        if ((value - nearest).abs() < 0.05) {
            return nearest.toString();
        }
        return value.format("%.1f");
    }

    // ------------------------------------------------------------ reading
    // A property can hold an unexpected type (an old version, a hand-edited
    // value in the simulator), so each reader checks before trusting it.

    function readNumber(key as String, fallback as Number) as Number {
        var value = Application.Properties.getValue(key);
        if (value instanceof Number) {
            return value;
        }
        return fallback;
    }

    function readBoolean(key as String, fallback as Boolean) as Boolean {
        var value = Application.Properties.getValue(key);
        if (value instanceof Boolean) {
            return value;
        }
        return fallback;
    }

    function readString(key as String, fallback as String) as String {
        var value = Application.Properties.getValue(key);
        if (value instanceof String) {
            return value;
        }
        return fallback;
    }
}
