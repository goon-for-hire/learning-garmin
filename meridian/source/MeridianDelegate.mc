import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Watch faces get no button input. This delegate only hears about the power budget.
class MeridianDelegate extends WatchUi.WatchFaceDelegate {

    private var _view as MeridianView;   // one-way: the view doesn't point back

    function initialize(view as MeridianView) {
        WatchFaceDelegate.initialize();
        _view = view;
    }

    function onPowerBudgetExceeded(powerInfo as WatchFacePowerInfo) as Void {
        System.println("Partial update over budget: " + powerInfo.executionTimeAverage
            + " ms average, limit " + powerInfo.executionTimeLimit + " ms");
        _view.disablePartialUpdates();
    }
}
