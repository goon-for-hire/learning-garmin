import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Turns button presses (and taps) into calls on the view.
class HelloFenixDelegate extends WatchUi.BehaviorDelegate {

    // The delegate points at the view. The view does NOT point back,
    // so there is no reference cycle (Module 4 explains why that matters).
    private var _view as HelloFenixView;

    function initialize(view as HelloFenixView) {
        BehaviorDelegate.initialize();
        _view = view;
    }
    
    //down button
    function onNextPage() as Boolean {
        _view.decrement();
        return true;
    }

    //up button
    function onPreviousPage() as Boolean {
        _view.reset();
        return true;
    }

    //! START/STOP button (top right). On touch watches a tap usually maps here too.
    function onSelect() as Boolean {
        System.println("Delegate.onSelect");
        _view.increment();
        return true; // true = handled, the system does nothing else
    }

    //! Hold UP (middle left): the "menu" behaviour.
    function onMenu() as Boolean {
        System.println("Delegate.onMenu");
        return false; // false = not handled, the system applies its default
    }
}
