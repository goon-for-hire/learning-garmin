import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Draws a greeting and a press counter.
class HelloFenixView extends WatchUi.View {

    private var _presses as Number = 0;
    private var _greeting as String = "";
    private var _hint as String = "";
    
    private var _inputText as String = "";

    private var mySettings as DeviceSettings = System.getDeviceSettings();
    private var Touchscreen as Lang.Boolean = mySettings.isTouchScreen;

    function initialize() {
        View.initialize();
        System.println("View.initialize");
    }

    //! Called before the view is first shown. Load resources here.
    function onLayout(dc as Dc) as Void {
        System.println("View.onLayout " + dc.getWidth() + "x" + dc.getHeight());
        _greeting = WatchUi.loadResource(Rez.Strings.Greeting) as String;
        _hint = WatchUi.loadResource(Rez.Strings.Hint) as String;
        
        if(Touchscreen) {
            _inputText ="Touch available";
        } else {
            _inputText = "buttons only";
        }
    }

    //! Called every time the view comes to the foreground.
    function onShow() as Void {
        System.println("View.onShow");
    }

    //! Called whenever the system (or you, via requestUpdate) wants a redraw.
    function onUpdate(dc as Dc) as Void {
        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;

        // Always paint the whole screen: the previous frame is not guaranteed to be there.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 40, Graphics.FONT_MEDIUM, _greeting,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 25, Graphics.FONT_NUMBER_MEDIUM, _presses.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, dc.getHeight()-40, Graphics.FONT_XTINY, _hint,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 40, Graphics.FONT_XTINY, _hint,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    
    }

    //! Called when the view leaves the foreground.
    function onHide() as Void {
        System.println("View.onHide");
    }

    //! Public API for the delegate. The view owns its state; the delegate asks it to change.
    function increment() as Void {
        _presses += 1;
        WatchUi.requestUpdate();
    }

    function decrement() as Void{
        _presses -=1;
        WatchUi.requestUpdate();
    }

    function reset() as Void{
        _presses = 0;
        WatchUi.requestUpdate();
    }
}
                                                                                                                           