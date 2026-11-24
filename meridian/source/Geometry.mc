import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! Rotate a shape clockwise by angle (radians) around the origin, then move it to (cx, cy).
//!
//! The shape is defined around (0, 0) pointing straight up (negative y is up on screen).
//! Screen y grows downwards, so the standard rotation matrix
//!     x' = x cos a - y sin a
//!     y' = x sin a + y cos a
//! turns things clockwise on screen, which is what clock hands do.
function rotatePoints(points as Array<Point2D>, angle as Numeric, cx as Numeric, cy as Numeric) as Array<Point2D> {
    var cos = Math.cos(angle);
    var sin = Math.sin(angle);
    var result = [] as Array<Point2D>;
    for (var i = 0; i < points.size(); i++) {
        var x = points[i][0];
        var y = points[i][1];
        result.add([cx + x * cos - y * sin, cy + x * sin + y * cos] as Point2D);
    }
    return result;
}

//! A point at distance r from (cx, cy), at a clock angle in radians (0 = 12 o'clock, clockwise).
function clockPoint(cx as Numeric, cy as Numeric, r as Numeric, angle as Numeric) as Point2D {
    return [cx + r * Math.sin(angle), cy - r * Math.cos(angle)] as Point2D;
}

//! Draw a ring that fills clockwise from 12 o'clock. fraction runs from 0.0 to 1.0.
function drawProgressRing(dc as Dc, cx as Number, cy as Number, r as Number, width as Number,
        fraction as Float, track as ColorType, fill as ColorType) as Void {
    dc.setPenWidth(width);
    dc.setColor(track, Graphics.COLOR_TRANSPARENT);
    dc.drawCircle(cx, cy, r);

    var sweep = (360 * fraction).toNumber();
    dc.setColor(fill, Graphics.COLOR_TRANSPARENT);
    if (sweep >= 360) {
        dc.drawCircle(cx, cy, r);
    } else if (sweep > 0) {
        // drawArc angles: 0 = 3 o'clock, 90 = 12 o'clock. Equal start and end would draw a
        // full circle, which is why sweep == 0 is skipped above.
        dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, 90, (450 - sweep) % 360);
    }
}
