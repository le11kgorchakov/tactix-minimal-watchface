import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Weather;

// Snapshot of optional live metrics for the Full layout.
module DataHub {

    class Snapshot {
        var steps as Number = 0;
        var stepGoal as Number = 10000;
        var calories as Number = 0;
        var distanceKm as Float = 0.0;
        var heartRate as Number or Null = null;
        var temperature as Number or Null = null;
        var humidity as Number or Null = null;
        var windMps as Float or Null = null;
        var locationName as String or Null = null;
        var sunrise as String or Null = null;
        var sunset as String or Null = null;
    }

    function capture() as Snapshot {
        var snap = new Snapshot();
        var info = ActivityMonitor.getInfo();
        if (info != null) {
            if (info.steps != null) {
                snap.steps = info.steps as Number;
            }
            if (info.stepGoal != null && (info.stepGoal as Number) > 0) {
                snap.stepGoal = info.stepGoal as Number;
            }
            if (info.calories != null) {
                snap.calories = info.calories as Number;
            }
            if (info.distance != null) {
                snap.distanceKm = (info.distance as Number) / 100000.0;
            }
        }

        snap.heartRate = readHeartRate();
        readWeather(snap);
        return snap;
    }

    function readHeartRate() as Number or Null {
        var activity = Activity.getActivityInfo();
        if (activity != null && activity.currentHeartRate != null) {
            return activity.currentHeartRate as Number;
        }
        if (!(Toybox has :SensorHistory) || !(SensorHistory has :getHeartRateHistory)) {
            return null;
        }
        var sample = SensorHistory.getHeartRateHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
        var next = sample.next();
        if (next == null || next.data == null) {
            return null;
        }
        return next.data as Number;
    }

    function readWeather(snap as Snapshot) as Void {
        if (!(Toybox has :Weather) || !(Weather has :getCurrentConditions)) {
            return;
        }
        var conditions = Weather.getCurrentConditions();
        if (conditions == null) {
            return;
        }
        if (conditions.temperature != null) {
            snap.temperature = (conditions.temperature as Float).toNumber();
        }
        if (conditions.relativeHumidity != null) {
            snap.humidity = conditions.relativeHumidity as Number;
        }
        if (conditions.windSpeed != null) {
            snap.windMps = conditions.windSpeed as Float;
        }
        if (conditions.observationLocationName != null) {
            snap.locationName = conditions.observationLocationName as String;
        }

        if (!(Weather has :getSunrise) || !(Weather has :getSunset) || conditions.observationLocationPosition == null) {
            return;
        }
        var loc = conditions.observationLocationPosition;
        var today = Time.today();
        var rise = Weather.getSunrise(loc, today);
        var set = Weather.getSunset(loc, today);
        if (rise != null) {
            snap.sunrise = formatClock(rise as Time.Moment);
        }
        if (set != null) {
            snap.sunset = formatClock(set as Time.Moment);
        }
    }

    function formatClock(moment as Time.Moment) as String {
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        var hour = info.hour as Number;
        var min = (info.min as Number).format("%02d");
        if (System.getDeviceSettings().is24Hour) {
            return hour.format("%02d") + ":" + min;
        }
        var suffix = hour >= 12 ? "P" : "A";
        hour = hour % 12;
        if (hour == 0) {
            hour = 12;
        }
        return hour.toString() + ":" + min + suffix;
    }
}
