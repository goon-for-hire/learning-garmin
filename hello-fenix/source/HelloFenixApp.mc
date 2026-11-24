import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! The entry point. The manifest's entry="HelloFenixApp" points here.
class HelloFenixApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
        System.println("App.initialize");
    }

    //! Called once, before the first view is created.
    function onStart(state as Dictionary?) as Void {
        System.println("App.onStart");
    }

    //! Called once, when the app is about to exit.
    function onStop(state as Dictionary?) as Void {
        System.println("App.onStop");
    }

    //! Return the first view and, optionally, the delegate that handles its input.
    function getInitialView() as [Views] or [Views, InputDelegates] {
        System.println("App.getInitialView");
        var view = new HelloFenixView();
        return [view, new HelloFenixDelegate(view)];
    }
}
