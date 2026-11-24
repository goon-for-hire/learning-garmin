import Toybox.Lang;
import Toybox.Time;

//! The states of a workout. Module 8 has the table.
enum WorkoutState {
    STATE_READY,     // not started; START begins
    STATE_LIFTING,   // a set is under way; BACK ends it
    STATE_RESTING,   // between sets
    STATE_PAUSED,    // the timer is stopped; resume, save or discard
    STATE_DONE       // saved or discarded; showing the result
}

//! One logged set: [exercise index, reps, kg].
typedef LoggedSet as [Number, Number, Float];

//! The workout model, step 1: the state machine and the list of sets.
//! Module 10 adds storage, Module 11 timers and heart rate, Module 12 recording.
class Workout {

    var state as WorkoutState = STATE_READY;
    var exercise as Number = 0;
    var sets as Array<LoggedSet>;
    var volumeKg as Float = 0.0;
    var lastSummary as Dictionary<String, Numeric>? = null;   // set by save()

    private var _startedAt as Number = 0;
    private var _resumeState as WorkoutState = STATE_LIFTING;

    function initialize() {
        sets = [] as Array<LoggedSet>;
    }

    //! READY -> LIFTING.
    function start() as Void {
        if (state != STATE_READY) {
            return;
        }
        _startedAt = Time.now().value();
        sets = [] as Array<LoggedSet>;
        volumeKg = 0.0;
        lastSummary = null;
        state = STATE_LIFTING;
    }

    //! LIFTING -> RESTING. Called with the picker's values.
    function logSet(reps as Number, kg as Float) as Void {
        if (state != STATE_LIFTING) {
            return;
        }
        sets.add([exercise, reps, kg] as LoggedSet);
        volumeKg += reps * kg;
        state = STATE_RESTING;
    }

    //! RESTING -> LIFTING. In step 1 only BACK ends a rest; Module 11 adds the countdown.
    function endRest() as Void {
        if (state == STATE_RESTING) {
            state = STATE_LIFTING;
        }
    }

    //! LIFTING or RESTING -> PAUSED.
    function pause() as Void {
        if (state != STATE_LIFTING && state != STATE_RESTING) {
            return;
        }
        _resumeState = state;
        state = STATE_PAUSED;
    }

    //! PAUSED -> whatever came before.
    function resume() as Void {
        if (state == STATE_PAUSED) {
            state = _resumeState;
        }
    }

    //! PAUSED -> DONE, keeping the result.
    function save() as Void {
        if (state != STATE_PAUSED) {
            return;
        }
        var minutes = (Time.now().value() - _startedAt) / 60;
        lastSummary = {"t" => _startedAt, "sets" => sets.size(), "kg" => volumeKg,
                       "min" => minutes} as Dictionary<String, Numeric>;
        state = STATE_DONE;
    }

    //! PAUSED -> DONE, throwing it away.
    function discard() as Void {
        lastSummary = null;
        state = STATE_DONE;
    }

    //! DONE -> READY, for another workout.
    function reset() as Void {
        if (state != STATE_DONE) {
            return;
        }
        sets = [] as Array<LoggedSet>;
        volumeKg = 0.0;
        lastSummary = null;
        state = STATE_READY;
    }

    //! Step through the exercise list (UP/DOWN). Not while paused or done.
    function changeExercise(step as Number) as Void {
        if (state == STATE_PAUSED || state == STATE_DONE) {
            return;
        }
        var n = Exercises.count();
        exercise = (exercise + step + n) % n;
    }

    function setExercise(index as Number) as Void {
        if (index >= 0 && index < Exercises.count()) {
            exercise = index;
        }
    }

    function isActive() as Boolean {
        return state == STATE_LIFTING || state == STATE_RESTING || state == STATE_PAUSED;
    }

    //! The number of the set being lifted, or the next one during rest.
    function setNumber() as Number {
        return sets.size() + 1;
    }
}
