import Toybox.Lang;
import Toybox.WatchUi;

//! Input for the main screen, following the watch's own activity conventions:
//!
//!   START (top right)      start the workout; stop it (pause menu); resume
//!   BACK/LAP (bottom right) the set is done; skip the rest; leave when idle
//!   UP / DOWN               previous / next exercise
//!   hold UP (MENU)          the SetLog menu
//!
//! START and BACK are read as physical keys in onKey(), not as the onSelect()
//! and onBack() behaviours, because on the fenix 8 a screen tap also means
//! onSelect() and a swipe right also means onBack(). Native activities never
//! start, stop or take a lap on a touch, so SetLog doesn't either.
class SetLogDelegate extends WatchUi.BehaviorDelegate {

    private var _workout as Workout;

    function initialize(workout as Workout) {
        BehaviorDelegate.initialize();
        _workout = workout;
    }

    //! Behaviours run first. onSelect() and onBack() are not overridden, so
    //! they return false and the system calls onKey() with the real key.
    function onKey(keyEvent as KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            return startStop();
        }
        if (key == WatchUi.KEY_ESC || key == WatchUi.KEY_LAP) {
            return backLap();
        }
        return false;
    }

    //! A swipe right would close the app. Swallow it during a workout.
    function onSwipe(swipeEvent as SwipeEvent) as Boolean {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_RIGHT) {
            return _workout.isActive();
        }
        return false;
    }

    function onMenu() as Boolean {
        Menus.pushMainMenu(_workout);
        return true;
    }

    function onNextPage() as Boolean {
        _workout.changeExercise(1);
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() as Boolean {
        _workout.changeExercise(-1);
        WatchUi.requestUpdate();
        return true;
    }

    // ------------------------------------------------------------ actions

    private function startStop() as Boolean {
        switch (_workout.state) {
            case STATE_READY:
                _workout.start();
                break;
            case STATE_LIFTING:
            case STATE_RESTING:            // falls through: the same for both
                _workout.pause();
                Menus.pushPauseMenu(_workout);
                break;
            case STATE_PAUSED:
                _workout.resume();
                break;
            default:                        // STATE_DONE
                _workout.reset();
        }
        WatchUi.requestUpdate();
        return true;
    }

    private function backLap() as Boolean {
        switch (_workout.state) {
            case STATE_LIFTING:
                SetPicker.push(_workout);   // logs the set when the user accepts
                return true;
            case STATE_RESTING:
                _workout.endRest();         // skip what is left of the rest
                WatchUi.requestUpdate();
                return true;
            case STATE_PAUSED:
                Menus.pushPauseMenu(_workout);
                return true;
        }
        return false;   // READY or DONE: let BACK leave the app as usual
    }
}
