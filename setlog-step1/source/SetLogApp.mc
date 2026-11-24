import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class SetLogApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    //! One Workout, shared by the view (which reads it) and the delegate
    //! (which changes it).
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var workout = new Workout();
        return [new SetLogView(workout), new SetLogDelegate(workout)];
    }
}
