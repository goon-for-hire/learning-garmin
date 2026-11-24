import Toybox.Lang;
import Toybox.WatchUi;

//! The label for the current accent colour.
function accentLabel() as ResourceId {
    var names = [Rez.Strings.Orange, Rez.Strings.Green, Rez.Strings.Blue, Rez.Strings.Yellow] as Array<ResourceId>;
    var index = MeridianSettings.accents.indexOf(MeridianSettings.accent);
    return names[index < 0 ? 0 : index];
}

//! On-device settings, built in code so items can show live values.
class MeridianSettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({ :title => Rez.Strings.SettingsTitle });
        addItem(new WatchUi.MenuItem(Rez.Strings.AccentTitle, accentLabel(), :accent, {}));
        addItem(new WatchUi.ToggleMenuItem(Rez.Strings.SecondsTitle, null, :seconds,
            MeridianSettings.showSeconds, {}));
    }
}

class MeridianSettingsDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        if (id == :accent) {
            MeridianSettings.nextAccent();
            item.setSubLabel(accentLabel());
        } else if (id == :seconds) {
            // The system flips a ToggleMenuItem before calling onSelect().
            MeridianSettings.setShowSeconds((item as ToggleMenuItem).isEnabled());
        }
        WatchUi.requestUpdate();
    }
}
