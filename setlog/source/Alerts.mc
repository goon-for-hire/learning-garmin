import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;

//! Getting the user's attention when rest is over.
module Alerts {

    function restOver() as Void {
        // Respect both SetLog's settings and the watch's own sound and vibration settings.
        var device = System.getDeviceSettings();

        if (Settings.vibrate && device.vibrateOn) {
            if (Attention has :vibrate) {
                // Two pulses: 80% strength for 300 ms, a 150 ms gap, then again.
                Attention.vibrate([
                    new Attention.VibeProfile(80, 300),
                    new Attention.VibeProfile(0, 150),
                    new Attention.VibeProfile(80, 300)
                ] as Array<Attention.VibeProfile>);
            }
        }

        if (Settings.tone && device.tonesOn) {
            if (Attention has :playTone) {
                Attention.playTone(Attention.TONE_LOUD_BEEP);
            }
        }

        if (Attention has :backlight) {
            try {
                Attention.backlight(true);
            } catch (e instanceof Attention.BacklightOnTooLongException) {
                // The system limits how long an app may keep the light on. Fine.
            }
        }
    }
}
