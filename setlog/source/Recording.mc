import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.FitContributor;
import Toybox.Lang;

// FIT developer field ids. They match resources/fit/fit_contributions.xml.
const FIELD_REPS = 0;
const FIELD_LOAD = 1;
const FIELD_SETS = 2;
const FIELD_VOLUME = 3;

//! One recorded activity: the FIT session plus SetLog's developer fields.
//!
//! Laps alternate. Each set gets a lap with its reps and load filled in;
//! the rest after it gets a lap with zeros. Garmin Connect's laps table
//! then reads set, rest, set, rest...
class Recording {

    private var _session as ActivityRecording.Session;
    private var _reps as FitContributor.Field;
    private var _load as FitContributor.Field;
    private var _sets as FitContributor.Field;
    private var _volume as FitContributor.Field;

    function initialize() {
        // Strength training as Garmin defines it: Activity.SPORT_TRAINING with
        // the strength sub-sport. Fields must be created before start().
        _session = ActivityRecording.createSession({
            :name => "SetLog",
            :sport => Activity.SPORT_TRAINING,
            :subSport => Activity.SUB_SPORT_STRENGTH_TRAINING
        });
        _reps = _session.createField("reps", FIELD_REPS, FitContributor.DATA_TYPE_UINT16,
            {:mesgType => FitContributor.MESG_TYPE_LAP, :units => "reps"});
        _load = _session.createField("load", FIELD_LOAD, FitContributor.DATA_TYPE_FLOAT,
            {:mesgType => FitContributor.MESG_TYPE_LAP, :units => "kg"});
        _sets = _session.createField("sets", FIELD_SETS, FitContributor.DATA_TYPE_UINT16,
            {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "sets"});
        _volume = _session.createField("volume", FIELD_VOLUME, FitContributor.DATA_TYPE_FLOAT,
            {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "kg"});
        clearLapFields();
        _sets.setData(0);
        _volume.setData(0.0);
    }

    //! Start or restart the activity timer.
    function start() as Void {
        _session.start();
    }

    //! Stop the activity timer (the "paused" state on the watch).
    function stop() as Void {
        if (_session.isRecording()) {
            _session.stop();
        }
    }

    //! End the current set's lap with what was lifted, and start a rest lap.
    function endSetLap(reps as Number, kg as Float, totalSets as Number, totalKg as Float) as Void {
        _reps.setData(reps);
        _load.setData(kg);
        _sets.setData(totalSets);      // session fields: written once, at save
        _volume.setData(totalKg);
        _session.addLap();             // the lap message is written now, with reps and load
        clearLapFields();              // so the rest lap carries zeros
    }

    //! End the rest lap. The next set's lap begins.
    function endRestLap() as Void {
        _session.addLap();
    }

    function save() as Void {
        stop();
        _session.save();
    }

    function discard() as Void {
        stop();
        _session.discard();
    }

    private function clearLapFields() as Void {
        _reps.setData(0);
        _load.setData(0.0);
    }
}
