import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class PlaygroundApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new PlaygroundView();
        return [view, new PlaygroundDelegate(view)];
    }
}

//! UP and DOWN (or swipes) flip pages; START also goes forward.
class PlaygroundDelegate extends WatchUi.BehaviorDelegate {

    private var _view as PlaygroundView;

    function initialize(view as PlaygroundView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onNextPage() as Boolean {
        _view.nextPage();
        return true;
    }

    function onPreviousPage() as Boolean {
        _view.previousPage();
        return true;
    }

    function onSelect() as Boolean {
        _view.nextPage();
        return true;
    }
}
