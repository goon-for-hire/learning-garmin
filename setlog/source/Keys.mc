import Toybox.Lang;

//! Every Storage and Properties key in one place, so a typo becomes a
//! compile error instead of a value that silently never loads.
//! (:background) because the background service reads PLAN_URL.
(:background)
module Keys {

    // Application.Storage: data SetLog writes for itself.
    const SCHEMA = "schema";       // Number: the storage layout version (Module 10)
    const HISTORY = "history";     // Array: one summary per saved workout, oldest first
    const LAST_SETS = "lastSets";  // Dictionary: exercise index as a String -> [reps, kg]
    const PLAN = "plan";           // Dictionary: what the background service fetched

    // Application.Properties: settings, declared in resources/settings/properties.xml.
    const UNITS = "Units";
    const REST = "RestSeconds";
    const VIBRATE = "RestVibrate";
    const TONE = "RestTone";
    const EXPORT_URL = "ExportUrl";
    const PLAN_URL = "PlanUrl";
}
