import Toybox.Application;
import Toybox.Lang;

//! Everything SetLog keeps in Application.Storage.
//! (:glance) because the glance shows the newest workout.
(:glance)
module Store {

    //! Bump this whenever the layout of stored data changes, and teach
    //! migrate() how to get from the old layout to the new one.
    const SCHEMA_VERSION = 2;
    const MAX_HISTORY = 20;

    //! Bring stored data up to SCHEMA_VERSION. Called once, at start-up,
    //! before anything else reads Storage.
    function migrate() as Void {
        var version = Application.Storage.getValue(Keys.SCHEMA);
        if (version == null) {
            // No version number: either nothing is stored yet (a new install,
            // which is already current) or the data came from version 1,
            // which stored history but no version.
            if (Application.Storage.getValue(Keys.HISTORY) == null) {
                version = SCHEMA_VERSION;
            } else {
                version = 1;
            }
        }
        if (version == 1) {
            // Version 1 kept each workout as [time, sets, kg].
            var old = Application.Storage.getValue(Keys.HISTORY) as Array<Array<Numeric>>?;
            var upgraded = [] as Array<Dictionary<String, Numeric>>;
            if (old != null) {
                for (var i = 0; i < old.size(); i++) {
                    upgraded.add(upgradeEntry(old[i]));
                }
            }
            Application.Storage.setValue(Keys.HISTORY, upgraded as Application.PropertyValueType);
            version = 2;
        }
        Application.Storage.setValue(Keys.SCHEMA, version);
    }

    //! Version 2 keeps each workout as a Dictionary, so later versions can
    //! add fields without breaking anything that reads the old ones.
    function upgradeEntry(v1 as Array<Numeric>) as Dictionary<String, Numeric> {
        return {"t" => v1[0], "sets" => v1[1], "kg" => v1[2], "min" => 0} as Dictionary<String, Numeric>;
    }

    // ------------------------------------------------------------ history

    //! Saved workouts, oldest first. Each is {"t", "sets", "kg", "min"}.
    function history() as Array<Dictionary> {
        var stored = Application.Storage.getValue(Keys.HISTORY);
        if (stored instanceof Array) {
            return stored as Array<Dictionary>;
        }
        return [] as Array<Dictionary>;
    }

    function addWorkout(entry as Dictionary<String, Numeric>) as Void {
        var all = history();
        all.add(entry as Dictionary);
        if (all.size() > MAX_HISTORY) {
            all = all.slice(all.size() - MAX_HISTORY, null);
        }
        Application.Storage.setValue(Keys.HISTORY, all as Application.PropertyValueType);
    }

    // ------------------------------------------------- the last set per lift

    //! [reps, kg] of the last set logged for an exercise, or null.
    function lastSet(exercise as Number) as Array<Numeric>? {
        var all = Application.Storage.getValue(Keys.LAST_SETS);
        if (all instanceof Dictionary) {
            var entry = all.get(exercise.toString());
            if (entry instanceof Array) {
                return entry as Array<Numeric>;
            }
        }
        return null;
    }

    function rememberSet(exercise as Number, reps as Number, kg as Float) as Void {
        var stored = Application.Storage.getValue(Keys.LAST_SETS);
        var all = {} as Dictionary<String, Array<Numeric>>;
        if (stored instanceof Dictionary) {
            all = stored as Dictionary<String, Array<Numeric>>;
        }
        all.put(exercise.toString(), [reps, kg] as Array<Numeric>);
        Application.Storage.setValue(Keys.LAST_SETS, all as Application.PropertyValueType);
    }

    // ---------------------------------------------------------- the plan

    //! The note the background service last fetched, or null.
    function planNote() as String? {
        var plan = Application.Storage.getValue(Keys.PLAN);
        if (plan instanceof Dictionary) {
            var note = plan.get("note");
            if (note instanceof String) {
                return note;
            }
        }
        return null;
    }
}
