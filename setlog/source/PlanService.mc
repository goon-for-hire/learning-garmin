import Toybox.Application;
import Toybox.Background;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;

//! The background service. The system starts it in a small separate process,
//! about every six hours (SetLogApp registers the schedule), even when SetLog
//! itself isn't open. It fetches a JSON plan from the PlanUrl setting, such as
//!     {"note": "Squat 5x5 at 100 kg"}
//! and hands the note to the app with Background.exit().
(:background)
class PlanService extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() as Void {
        var url = Application.Properties.getValue(Keys.PLAN_URL);
        if (url instanceof String) {
            if (url.length() > 0) {
                Communications.makeWebRequest(url, null, {
                    :method => Communications.HTTP_REQUEST_METHOD_GET,
                    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
                }, method(:onPlan));
                return;
            }
        }
        Background.exit({"code" => 0});
    }

    function onPlan(code as Number, data as Object or Null) as Void {
        if (code == 200) {
            if (data instanceof Dictionary) {
                var note = data.get("note");
                if (note instanceof String) {
                    // Only plain values (numbers, strings, arrays, dictionaries)
                    // can cross from the background process to the app.
                    Background.exit({"code" => code, "note" => note});
                    return;
                }
            }
        }
        Background.exit({"code" => code});
    }
}
