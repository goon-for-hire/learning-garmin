import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Sends the newest saved workout to the ExportUrl setting as JSON.
//! The request goes through the phone: Garmin Connect makes the actual HTTPS call.
class Exporter {

    function initialize() {
    }

    function sendLastWorkout() as Void {
        var url = Settings.exportUrl;
        if (url.length() == 0) {
            Format.toast(Format.text(Rez.Strings.NoExportUrl));
            return;
        }
        var history = Store.history();
        if (history.size() == 0) {
            Format.toast(Format.text(Rez.Strings.NothingToSend));
            return;
        }
        if (!System.getDeviceSettings().phoneConnected) {
            Format.toast(Format.text(Rez.Strings.NoPhone));
            return;
        }

        var last = history[history.size() - 1];
        // A Dictionary body plus the JSON content type: makeWebRequest() does
        // the JSON encoding itself.
        var body = {
            "app" => "SetLog",
            "startedAt" => last.get("t"),
            "sets" => last.get("sets"),
            "volumeKg" => last.get("kg"),
            "minutes" => last.get("min")
        };
        Communications.makeWebRequest(url, body as Dictionary<Object, Object>, {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON},
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        }, method(:onResponse));
        Format.toast(Format.text(Rez.Strings.Sending));
    }

    //! data is typed as widely as possible, Object or Null, because the
    //! declared type of this argument has changed between SDK versions
    //! (9.3.0 changed it again). A wider parameter accepts them all.
    function onResponse(code as Number, data as Object or Null) as Void {
        if (code >= 200 && code < 300) {
            Format.toast(Format.text(Rez.Strings.Sent));
        } else {
            // Negative codes come from the watch or the phone, not the server:
            // -104, for example, means no connection to the phone.
            Format.toast(Lang.format(Format.text(Rez.Strings.SendFailed), [code]));
        }
        WatchUi.requestUpdate();
    }
}
