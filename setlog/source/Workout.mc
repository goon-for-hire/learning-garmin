import Toybox.Activity;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.System;
import Toybox.Time;
import Toybox.Timer;
import Toybox.WatchUi;

//! The states of a workout. Module 8 draws the diagram.
enum WorkoutState {
    STATE_READY,     // not started; START begins
    STATE_LIFTING,   // a set is under way; BACK ends it
    STATE_RESTING,   // counting down to the next set
    STATE_PAUSED,    // the timer is stopped; resume, save or discard
    STATE_DONE       // saved or discarded; showing the result
}

//! One logged set: [exercise index, reps, kg].
typedef LoggedSet as [Number, Number, Float];

//! The workout model. Views read it, delegates call its methods, and only
//! its methods change it.
class Workout {

    var state as WorkoutState = STATE_READY;
    var exercise as Number = 0;
    var heartRate as Number? = null;
    var sets as Array<LoggedSet>;
    var volumeKg as Float = 0.0;
    var lastSummary as Dictionary<String, Numeric>? = null;   // set by save()

    private var _recording as Recording? = null;
    private var _timer as Timer.Timer;
    private var _startedAt as Number = 0;       // Time.now().value() at start
    private var _setStartMs as Number = 0;      // System.getTimer() values from here on
    private var _restEndMs as Number = 0;
    private var _restTotalMs as Number = 1;
    private var _pausedAtMs as Number = 0;
    private var _resumeState as WorkoutState = STATE_LIFTING;

    function initialize() {
        sets = [] as Array<LoggedSet>;

        // One timer for the whole app: it drives the rest countdown and
        // redraws the screen once a second. It lives in the model, not the
        // view, so the countdown keeps going while a menu covers the view.
        _timer = new Timer.Timer();
        _timer.start(method(:onTick), 1000, true);

        // Heart rate from the optical sensor (or a paired strap), once a second.
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE] as Array<Sensor.SensorType>);
        Sensor.enableSensorEvents(method(:onSensor));
    }

    function onSensor(info as Sensor.Info) as Void {
        heartRate = info.heartRate;
    }

    function onTick() as Void {
        if (state == STATE_RESTING) {
            if (System.getTimer() >= _restEndMs) {
                endRest();
                Alerts.restOver();
            }
        }
        WatchUi.requestUpdate();
    }

    // ------------------------------------------------------------ actions

    //! READY -> LIFTING. Starts the recording.
    function start() as Void {
        if (state != STATE_READY) {
            return;
        }
        var recording = new Recording();
        recording.start();
        _recording = recording;
        _startedAt = Time.now().value();
        sets = [] as Array<LoggedSet>;
        volumeKg = 0.0;
        lastSummary = null;
        beginSet();
    }

    //! LIFTING -> RESTING. Called with the picker's values.
    function logSet(reps as Number, kg as Float) as Void {
        if (state != STATE_LIFTING) {
            return;
        }
        sets.add([exercise, reps, kg] as LoggedSet);
        volumeKg += reps * kg;
        Store.rememberSet(exercise, reps, kg);
        var recording = _recording;
        if (recording != null) {
            recording.endSetLap(reps, kg, sets.size(), volumeKg);
        }
        _restTotalMs = Settings.restSeconds * 1000;
        _restEndMs = System.getTimer() + _restTotalMs;
        state = STATE_RESTING;
    }

    //! RESTING -> LIFTING, when the countdown ends or the user skips it.
    function endRest() as Void {
        if (state != STATE_RESTING) {
            return;
        }
        var recording = _recording;
        if (recording != null) {
            recording.endRestLap();
        }
        beginSet();
    }

    //! LIFTING or RESTING -> PAUSED. Stops the activity timer.
    function pause() as Void {
        if (state != STATE_LIFTING && state != STATE_RESTING) {
            return;
        }
        _resumeState = state;
        _pausedAtMs = System.getTimer();
        var recording = _recording;
        if (recording != null) {
            recording.stop();
        }
        state = STATE_PAUSED;
    }

    //! PAUSED -> whatever came before.
    function resume() as Void {
        if (state != STATE_PAUSED) {
            return;
        }
        var recording = _recording;
        if (recording != null) {
            recording.start();
        }
        // Move the clocks on by the length of the pause, so pausing neither
        // eats the rest nor counts as lifting time.
        var paused = System.getTimer() - _pausedAtMs;
        _setStartMs += paused;
        _restEndMs += paused;
        state = _resumeState;
    }

    //! PAUSED -> DONE, keeping the activity.
    function save() as Void {
        var recording = _recording;
        if (recording == null) {
            return;
        }
        // timerTime leaves out paused time, like the watch's own "Time" field.
        var minutes = 0;
        var info = Activity.getActivityInfo();
        if (info != null) {
            var timerMs = info.timerTime;
            if (timerMs != null) {
                minutes = timerMs / 60000;
            }
        }
        recording.save();
        _recording = null;

        var summary = {"t" => _startedAt, "sets" => sets.size(), "kg" => volumeKg,
                       "min" => minutes} as Dictionary<String, Numeric>;
        Store.addWorkout(summary);
        lastSummary = summary;
        state = STATE_DONE;
    }

    //! PAUSED -> DONE, throwing the activity away.
    function discard() as Void {
        var recording = _recording;
        if (recording != null) {
            recording.discard();
        }
        _recording = null;
        lastSummary = null;
        state = STATE_DONE;
    }

    //! The app is closing mid-workout: held BACK, a passcode lock, a crash
    //! elsewhere. A session that is never saved leaves a broken FIT file, so
    //! keep what there is.
    function saveIfActive() as Void {
        if (_recording == null) {
            return;
        }
        pause();   // does nothing if already paused
        save();
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

    // ------------------------------------------------------- questions

    function isActive() as Boolean {
        return state == STATE_LIFTING || state == STATE_RESTING || state == STATE_PAUSED;
    }

    //! The number of the set being lifted, or the next one during rest.
    function setNumber() as Number {
        return sets.size() + 1;
    }

    function setSeconds() as Number {
        return (now() - _setStartMs) / 1000;
    }

    function restSecondsLeft() as Number {
        var left = _restEndMs - now();
        if (left <= 0) {
            return 0;
        }
        return (left + 999) / 1000;   // round up, so "0:01" shows until the very end
    }

    //! How much of the rest has passed, 0.0 to 1.0, for the progress ring.
    function restFraction() as Float {
        var left = _restEndMs - now();
        if (left <= 0) {
            return 1.0;
        }
        return 1.0 - left.toFloat() / _restTotalMs;
    }

    // ------------------------------------------------------------ helpers

    private function beginSet() as Void {
        _setStartMs = System.getTimer();
        state = STATE_LIFTING;
    }

    //! The clock that set and rest times run on. It stands still while paused.
    private function now() as Number {
        if (state == STATE_PAUSED) {
            return _pausedAtMs;
        }
        return System.getTimer();
    }
}
