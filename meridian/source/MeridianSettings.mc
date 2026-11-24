import Toybox.Application;
import Toybox.Lang;

//! One place that owns the face's settings. Everything else reads these variables,
//! so drawing never touches Properties (which is slower) during an update.
module MeridianSettings {

    //! The accent colours on offer. All four sit on the 64-colour MIP grid.
    var accents as Array<Number> = [0xFF5500, 0x00FF00, 0x00AAFF, 0xFFAA00] as Array<Number>;

    var accent as Number = 0xFF5500;
    var showSeconds as Boolean = true;

    //! Read the stored values. Call at start-up and whenever settings change.
    function load() as Void {
        accent = Application.Properties.getValue("AccentColor") as Number;
        showSeconds = Application.Properties.getValue("ShowSeconds") as Boolean;
    }

    //! Step to the next accent colour and persist it.
    function nextAccent() as Void {
        var index = accents.indexOf(accent);   // -1 if the stored colour isn't in the list
        accent = accents[(index + 1) % accents.size()];
        Application.Properties.setValue("AccentColor", accent);
    }

    function setShowSeconds(value as Boolean) as Void {
        showSeconds = value;
        Application.Properties.setValue("ShowSeconds", value);
    }
}
