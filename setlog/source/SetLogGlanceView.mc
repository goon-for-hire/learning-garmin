import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

//! SetLog's line in the glance loop: the plan note if there is one,
//! otherwise how long ago the last workout was.
//! (:glance) puts this class in the small glance process. It may only use
//! (:glance) and (:background) code, and resources marked scope="glance".
(:glance)
class SetLogGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var h = dc.getHeight();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, h / 4, Graphics.FONT_GLANCE, WatchUi.loadResource(Rez.Strings.GlanceTitle) as String,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, (h * 3) / 4, Graphics.FONT_GLANCE, GlanceText.summary(),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

(:glance)
module GlanceText {

    function summary() as String {
        var note = Store.planNote();
        if (note != null) {
            return note;
        }
        var history = Store.history();
        if (history.size() == 0) {
            return WatchUi.loadResource(Rez.Strings.GlanceEmpty) as String;
        }
        var last = history[history.size() - 1];
        var t = last.get("t");
        var sets = last.get("sets");
        if (t instanceof Number) {
            if (sets instanceof Number) {
                var days = (Time.now().value() - t) / 86400;
                return Lang.format(WatchUi.loadResource(Rez.Strings.GlanceLast) as String, [days, sets]);
            }
        }
        return "";
    }
}
