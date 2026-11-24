import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class MeridianApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        MeridianSettings.load();
        var view = new MeridianView();
        return [view, new MeridianDelegate(view)];
    }

    //! On-device settings: hold UP on the watch face, then Watch Face > Customize.
    //! In the simulator: Settings > Trigger App Settings.
    function getSettingsView() as [Views, InputDelegates] or Null {
        return [new MeridianSettingsMenu(), new MeridianSettingsDelegate()];
    }

    //! Phone settings arrived (Connect IQ app). Re-read and redraw.
    function onSettingsChanged() as Void {
        MeridianSettings.load();
        WatchUi.requestUpdate();
    }
}
