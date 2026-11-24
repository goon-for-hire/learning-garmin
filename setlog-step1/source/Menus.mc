import Toybox.Lang;
import Toybox.WatchUi;

//! SetLog's menus, step 1. Module 10 adds rest time, history and settings.
//!
//! Rule of thumb: a Menu2 never pops itself. Each onSelect() decides how
//! many views to pop. (A Confirmation is the opposite: it always pops
//! itself, so its delegate must not.)
module Menus {

    //! Hold UP: the main menu.
    function pushMainMenu(workout as Workout) as Void {
        var menu = new WatchUi.Menu2({:title => Rez.Strings.MenuTitle});
        menu.addItem(new WatchUi.MenuItem(Rez.Strings.MenuExercise, Exercises.name(workout.exercise), :exercise, {}));
        WatchUi.pushView(menu, new MainMenuDelegate(workout), WatchUi.SLIDE_UP);
    }

    //! The exercise list, with the current one in focus.
    function pushExerciseMenu(workout as Workout) as Void {
        var menu = new WatchUi.Menu2({:title => Rez.Strings.MenuExercise, :focus => workout.exercise});
        for (var i = 0; i < Exercises.count(); i++) {
            menu.addItem(new WatchUi.MenuItem(Exercises.name(i), null, i, {}));
        }
        WatchUi.pushView(menu, new ExerciseMenuDelegate(workout), WatchUi.SLIDE_LEFT);
    }

    //! START during a workout: the timer has stopped; what now?
    function pushPauseMenu(workout as Workout) as Void {
        var menu = new WatchUi.Menu2({:title => Rez.Strings.PausedTitle});
        menu.addItem(new WatchUi.MenuItem(Rez.Strings.Resume, null, :resume, {}));
        menu.addItem(new WatchUi.MenuItem(Rez.Strings.Save, null, :save, {}));
        menu.addItem(new WatchUi.MenuItem(Rez.Strings.Discard, null, :discard, {}));
        WatchUi.pushView(menu, new PauseMenuDelegate(workout), WatchUi.SLIDE_UP);
    }
}

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _workout as Workout;

    function initialize(workout as Workout) {
        Menu2InputDelegate.initialize();
        _workout = workout;
    }

    function onSelect(item as MenuItem) as Void {
        if (item.getId() == :exercise) {
            Menus.pushExerciseMenu(_workout);   // on top of this menu
        }
    }
}

class ExerciseMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _workout as Workout;

    function initialize(workout as Workout) {
        Menu2InputDelegate.initialize();
        _workout = workout;
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        if (id instanceof Number) {
            _workout.setExercise(id);
        }
        // Pop this list and the main menu under it: straight back to the workout.
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class PauseMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _workout as Workout;

    function initialize(workout as Workout) {
        Menu2InputDelegate.initialize();
        _workout = workout;
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        if (id == :resume) {
            _workout.resume();
        } else if (id == :save) {
            _workout.save();
        } else if (id == :discard) {
            // The menu is already gone, so the confirmation sits on the main view.
            WatchUi.pushView(new WatchUi.Confirmation(Format.text(Rez.Strings.DiscardQ)),
                new DiscardDelegate(_workout), WatchUi.SLIDE_IMMEDIATE);
        }
        WatchUi.requestUpdate();
    }
}

class DiscardDelegate extends WatchUi.ConfirmationDelegate {

    private var _workout as Workout;

    function initialize(workout as Workout) {
        ConfirmationDelegate.initialize();
        _workout = workout;
    }

    //! By the time this runs, think of the confirmation as already popped:
    //! popView() here would pop the main view, and pushView() would be
    //! undone straight away. So only change state.
    function onResponse(response as Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            _workout.discard();
        }
        WatchUi.requestUpdate();
        return true;
    }
}
