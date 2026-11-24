import Toybox.Application;
import Toybox.Background;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

//! The application class. It is loaded in all three of SetLog's processes:
//! the app itself, its glance, and the background service. Hence (:background).
//!
//! The methods marked (:typecheck(false)) only do their work in the app or the
//! glance, but they refer to code that isn't in the background process, and
//! the type checker would reject that. Module 13 explains the trade-off.
(:background)
class SetLogApp extends Application.AppBase {

    // The running workout, so onStop() can save it. Typed as Object because a
    // (:background) class may not name a foreground-only type like Workout,
    // even in a member declaration.
    private var _workout as Object? = null;

    function initialize() {
        AppBase.initialize();
    }

    (:typecheck(false))
    function getInitialView() as [Views] or [Views, InputDelegates] {
        Store.migrate();          // first, before anything reads Storage
        Settings.load();
        schedulePlanFetch();
        var workout = new Workout();
        _workout = workout;
        return [new SetLogView(workout), new SetLogDelegate(workout)];
    }

    //! Called when any of SetLog's processes ends: the app, the glance or the
    //! background service. Only the app ever sets _workout, so in the other two
    //! this does nothing.
    (:typecheck(false))
    function onStop(state as Dictionary?) as Void {
        var workout = _workout;
        if (workout != null) {
            workout.saveIfActive();
        }
    }

    //! The glance in the watch's glance loop. On the fenix 8 a device app
    //! only gets one if it overrides this.
    (:typecheck(false))
    function getGlanceView() as [GlanceView] or [GlanceView, GlanceViewDelegate] or Null {
        return [new SetLogGlanceView()];
    }

    function getServiceDelegate() as [System.ServiceDelegate] {
        return [new PlanService()];
    }

    //! What PlanService passed to Background.exit(). Delivered to the app or
    //! its glance: straight away if one is running, otherwise when one next starts.
    (:typecheck(false))
    function onBackgroundData(data as PersistableType) as Void {
        if (data instanceof Dictionary) {
            if (data.get("note") != null) {
                Application.Storage.setValue(Keys.PLAN, data);
            }
        }
        WatchUi.requestUpdate();
    }

    //! The user changed settings in the phone app while SetLog was running.
    (:typecheck(false))
    function onSettingsChanged() as Void {
        Settings.load();
        WatchUi.requestUpdate();
    }

    //! Run PlanService every six hours if a plan URL is set; otherwise never.
    (:typecheck(false))
    private function schedulePlanFetch() as Void {
        var url = Application.Properties.getValue(Keys.PLAN_URL);
        if (url instanceof String && url.length() > 0) {
            if (Background.getTemporalEventRegisteredTime() == null) {
                Background.registerForTemporalEvent(new Time.Duration(6 * 3600));
            }
        } else {
            Background.deleteTemporalEvent();
        }
    }
}
