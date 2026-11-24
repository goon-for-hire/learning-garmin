import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;

//! Four pages of drawing experiments: palette, clock geometry, progress ring, fonts.
class PlaygroundView extends WatchUi.View {

    private const PAGE_COUNT = 4;

    private var _page as Number = 0;
    private var _arcFont as VectorFont? = null;

    // Hand shapes around (0, 0), pointing straight up. Negative y is up on screen.
    private var _hourHand as Array<Point2D> = [[-6, 14], [-5, -70], [5, -70], [6, 14]] as Array<Point2D>;
    private var _minuteHand as Array<Point2D> = [[-4, 16], [-3, -112], [3, -112], [4, 16]] as Array<Point2D>;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Vector fonts aren't on every device, so this may stay null.
        _arcFont = Graphics.getVectorFont({ :face => "RobotoCondensedBold", :size => 22 });
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        switch (_page) {
            case 0:
                drawPalette(dc);
                break;
            case 1:
                drawClockGeometry(dc);
                break;
            case 2:
                drawRing(dc, 0.65);
                break;
            default:
                drawFonts(dc);
        }
    }

    function nextPage() as Void {
        _page = (_page + 1) % PAGE_COUNT;
        WatchUi.requestUpdate();
    }

    function previousPage() as Void {
        _page = (_page + PAGE_COUNT - 1) % PAGE_COUNT;
        WatchUi.requestUpdate();
    }

    //! All 64 colours a MIP screen can show: every channel is 0x00, 0x55, 0xAA or 0xFF.
    private function drawPalette(dc as Dc) as Void {
        var levels = [0x00, 0x55, 0xAA, 0xFF] as Array<Number>;
        var size = 24;
        var x0 = (dc.getWidth() - 8 * size) / 2;
        var y0 = (dc.getHeight() - 8 * size) / 2;
        for (var i = 0; i < 64; i++) {
            var red = levels[(i >> 4) & 3];
            var green = levels[(i >> 2) & 3];
            var blue = levels[i & 3];
            dc.setColor((red << 16) | (green << 8) | blue, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x0 + (i % 8) * size, y0 + (i / 8) * size, size - 2, size - 2);
        }
    }

    //! Tick marks with trigonometry, hands with a rotation matrix.
    private function drawClockGeometry(dc as Dc) as Void {
        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;
        var outer = cx - 4;

        for (var i = 0; i < 60; i++) {
            var angle = i * Math.PI / 30;   // 6 degrees per tick, clockwise from 12 o'clock
            var isHour = i % 5 == 0;
            var start = clockPoint(cx, cy, isHour ? outer - 16 : outer - 7, angle);
            var end = clockPoint(cx, cy, outer, angle);
            dc.setPenWidth(isHour ? 3 : 1);
            dc.setColor(isHour ? Graphics.COLOR_WHITE : Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(start[0], start[1], end[0], end[1]);
        }

        var clock = System.getClockTime();
        var minuteAngle = clock.min * Math.PI / 30;
        var hourAngle = ((clock.hour % 12) + clock.min / 60.0) * Math.PI / 6;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(rotatePoints(_hourHand, hourAngle, cx, cy));
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(rotatePoints(_minuteHand, minuteAngle, cx, cy));
        dc.fillCircle(cx, cy, 6);
    }

    //! A progress ring, a number in the middle, and text that follows the bezel.
    private function drawRing(dc as Dc, fraction as Float) as Void {
        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;
        var r = cx - 10;
        drawProgressRing(dc, cx, cy, r, 12, fraction, Graphics.COLOR_DK_GRAY, Graphics.COLOR_GREEN);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy, Graphics.FONT_NUMBER_MEDIUM, (fraction * 100).toNumber().toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Copy the member into a local: the checker narrows locals, not members.
        var font = _arcFont;
        if (font != null) {
            dc.drawRadialText(cx, cy, font, "PROGRESS", Graphics.TEXT_JUSTIFY_CENTER,
                90, r - 26, Graphics.RADIAL_TEXT_DIRECTION_CLOCKWISE);
        }
    }

    //! System font specimen with each font's height in pixels on this device.
    private function drawFonts(dc as Dc) as Void {
        var fonts = [Graphics.FONT_XTINY, Graphics.FONT_TINY, Graphics.FONT_SMALL,
            Graphics.FONT_MEDIUM] as Array<FontDefinition>;
        var names = ["XTINY", "TINY", "SMALL", "MEDIUM"] as Array<String>;
        var cx = dc.getWidth() / 2;
        var y = 36;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < fonts.size(); i++) {
            dc.drawText(cx, y, fonts[i], names[i] + " " + dc.getFontHeight(fonts[i]) + "px",
                Graphics.TEXT_JUSTIFY_CENTER);
            y += dc.getFontHeight(fonts[i]) + 2;
        }
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, y, Graphics.FONT_NUMBER_MEDIUM, "12:34", Graphics.TEXT_JUSTIFY_CENTER);
    }
}
