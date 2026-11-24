import Toybox.Lang;
import Toybox.WatchUi;

//! Small text helpers shared by views and menus.
module Format {

    //! "1:05" from 65 seconds.
    function clock(seconds as Number) as String {
        if (seconds < 0) {
            seconds = 0;
        }
        return (seconds / 60).format("%d") + ":" + (seconds % 60).format("%02d");
    }

    //! A string resource as a String.
    function text(id as ResourceId) as String {
        return WatchUi.loadResource(id) as String;
    }

    //! A short message at the top of the screen, where the device has toasts.
    function toast(message as String) as Void {
        if (WatchUi has :showToast) {
            WatchUi.showToast(message, null);
        }
    }
}
