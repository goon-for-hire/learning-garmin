import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

//! A data field app is tiny: it only hands the system one DataField view.
//! Data fields take no button input (the activity owns the buttons),
//! so there is no delegate.
class ZoneRingApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new ZoneRingView()];
    }
}
