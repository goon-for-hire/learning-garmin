import Toybox.Lang;
import Toybox.WatchUi;

//! The exercise list. To add one, add a string to strings.xml and its id here.
module Exercises {

    var _names as Array<String>? = null;

    function count() as Number {
        return names().size();
    }

    function name(index as Number) as String {
        var all = names();
        if (index < 0 || index >= all.size()) {
            return "?";
        }
        return all[index];
    }

    //! Loaded once, on first use, then kept.
    function names() as Array<String> {
        var cached = _names;
        if (cached != null) {
            return cached;
        }
        var ids = [Rez.Strings.ExSquat, Rez.Strings.ExBench, Rez.Strings.ExDeadlift,
                   Rez.Strings.ExPress, Rez.Strings.ExRow, Rez.Strings.ExPullUp,
                   Rez.Strings.ExDip, Rez.Strings.ExLunge] as Array<ResourceId>;
        var loaded = [] as Array<String>;
        for (var i = 0; i < ids.size(); i++) {
            loaded.add(WatchUi.loadResource(ids[i]) as String);
        }
        _names = loaded;
        return loaded;
    }
}
