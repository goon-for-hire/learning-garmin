import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

//! All of SetLog's menus.
//!
//! Rule of thumb: a Menu2 never pops itself. Each onSelect() decides how
//! many views to pop. (A Confirmation is the opposite: it always pops
//! itself, so its delegate must not.)
module Menus {

    //! Hold UP: the main menu.
    function pushMainMenu(workout as Workout) as Void {
        var menu = new WatchUi.Menu2({:title => Rez.Strings.MenuTitle});
        menu.addItem(new WatchUi.MenuItem(Rez.Strings.MenuExercise, Exercises.name(workout.exercise), :exercise, {}));
        menu.addItem(new WatchUi.MenuItem(Rez.Strings.MenuRest, Settings.restSeconds.toString() + " s", :rest, {}));
        menu.addItem(new WatchUi.MenuItem(Rez.Strings.MenuHistory, null, :history, {}));
        menu.addItem(new WatchUi.MenuItem(Rez.Strings.MenuSettings, null, :settings, {}));
        menu.addItem(new WatchUi.MenuItem(Rez.Strings.MenuSend, null, :send, {}));
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

    //! On-device settings. The same properties the phone app edits.
    function pushSettingsMenu() as Void {
        var menu = new WatchUi.Menu2({:title => Rez.Strings.SettingsTitle});
        menu.addItem(new WatchUi.MenuItem(Rez.Strings.SetUnits, unitsLabel(), :units, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(Rez.Strings.SetVibrate, null, :vibrate, Settings.vibrate, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(Rez.Strings.SetTone, null, :tone, Settings.tone, {}));
        WatchUi.pushView(menu, new SettingsMenuDelegate(), WatchUi.SLIDE_LEFT);
    }

    //! Saved workouts, newest first. Read-only, so the stock delegate will do:
    //! its onBack() pops the menu and its onSelect() does nothing.
    function pushHistoryMenu() as Void {
        var menu = new WatchUi.Menu2({:title => Rez.Strings.MenuHistory});
        var history = Store.history();
        if (history.size() == 0) {
            menu.addItem(new WatchUi.MenuItem(Rez.Strings.HistoryEmpty, null, :none, {}));
        }
        for (var i = history.size() - 1; i >= 0; i--) {
            menu.addItem(new WatchUi.MenuItem(dateText(history[i]), historyLine(history[i]), i, {}));
        }
        WatchUi.pushView(menu, new WatchUi.Menu2InputDelegate(), WatchUi.SLIDE_LEFT);
    }

    function unitsLabel() as ResourceId {
        var labels = [Rez.Strings.UnitsWatch, Rez.Strings.UnitsKg, Rez.Strings.UnitsLb] as Array<ResourceId>;
        var choice = Settings.unitsChoice();
        if (choice < 0 || choice >= labels.size()) {
            choice = 0;
        }
        return labels[choice];
    }

    //! "Mon 3 Nov" for a history entry.
    function dateText(entry as Dictionary) as String {
        var t = entry.get("t");
        if (t instanceof Number) {
            var info = Gregorian.info(new Time.Moment(t), Time.FORMAT_MEDIUM);
            return Lang.format("$1$ $2$ $3$", [info.day_of_week, info.day, info.month]);
        }
        return "?";
    }

    //! "12 sets · 3450 kg · 41 min" for a history entry.
    function historyLine(entry as Dictionary) as String {
        var sets = entry.get("sets");
        var kg = entry.get("kg");
        var minutes = entry.get("min");
        if (sets instanceof Number) {
            if (kg instanceof Float) {
                if (minutes instanceof Number) {
                    return Lang.format(Format.text(Rez.Strings.HistoryLine),
                        [sets, Settings.formatLoad(kg), Settings.unitLabel(), minutes]);
                }
            }
        }
        return "";
    }
}

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _workout as Workout;

    function initialize(workout as Workout) {
        Menu2InputDelegate.initialize();
        _workout = workout;
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        if (id == :exercise) {
            Menus.pushExerciseMenu(_workout);   // on top of this menu
        } else if (id == :rest) {
            RestPicker.push();
        } else if (id == :history) {
            Menus.pushHistoryMenu();
        } else if (id == :settings) {
            Menus.pushSettingsMenu();
        } else if (id == :send) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            var exporter = new Exporter();
            exporter.sendLastWorkout();
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

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        if (id == :units) {
            Settings.setUnitsChoice((Settings.unitsChoice() + 1) % 3);
            item.setSubLabel(Menus.unitsLabel());
        } else if (id == :vibrate) {
            // The system flips a ToggleMenuItem before calling onSelect().
            Settings.setVibrate((item as ToggleMenuItem).isEnabled());
        } else if (id == :tone) {
            Settings.setTone((item as ToggleMenuItem).isEnabled());
        }
        WatchUi.requestUpdate();
    }
}
