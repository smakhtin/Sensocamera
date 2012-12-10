package ru.Mathrioshka.Sensocamera;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaInterface;
import org.apache.cordova.api.CordovaPlugin;
import org.apache.cordova.api.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class MagneticField extends CordovaPlugin implements SensorEventListener{
    public static final String ACTION_START = "start";
    private static final String ACTION_STOP = "stop";

    public static final int STATE_STOPPED = 0;
    public static final int STATE_STARTING = 1;
    public static final int STATE_RUNNING = 2;
    public static final int STATE_FAILED = 3;

    private float xValue = 0;
    private float yValue = 0;
    private float zValue = 0;

    private SensorManager sensorManager;

    private CallbackContext callbackContext;

    private int currentState = STATE_STOPPED;
    private int accuracy = SensorManager.SENSOR_STATUS_UNRELIABLE;

    public MagneticField()
    {

    }


    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        sensorManager = (SensorManager) cordova.getActivity().getSystemService(Context.SENSOR_SERVICE);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals(ACTION_START)){
            this.callbackContext = callbackContext;
            if(currentState != STATE_RUNNING){
                start();
            }
        }
        else if(action.equals(ACTION_STOP)) {
            if(currentState == STATE_RUNNING) {
                stop();
            }
        }
        else {
            return false;
        }

        PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT, "");
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);

        return true;
    }

    @Override
    public void onDestroy() {
        stop();
    }

    @Override
    public void onReset() {
        stop();
    }

    private void start() {
        if(currentState != STATE_RUNNING) setState(STATE_STARTING);
    }

    private void stop() {
        setState(STATE_STOPPED);
    }

    private void setState(int state) {
        setState(state, null);
    }

    private void setState(int state, Object data) {
        if(currentState == state) return;

        currentState = state;

        switch (currentState){
            case STATE_STOPPED:
                sensorManager.unregisterListener(this);
                accuracy = SensorManager.SENSOR_STATUS_UNRELIABLE;
                break;
            case STATE_STARTING:
                try {
                    Sensor sensor = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);
                    sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_UI);
                }
                catch (NullPointerException e) {
                    setState(STATE_FAILED, "Can't find Magnetic Field sensor");
                }
                break;
            case STATE_RUNNING:
                break;
            case STATE_FAILED:
                fail(currentState, (String) data);
                break;
        }
    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        if(event.sensor.getType() != Sensor.TYPE_MAGNETIC_FIELD) return;
        if(currentState == STATE_STOPPED) return;

        setState(STATE_RUNNING);

        if(accuracy >= SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM) {
            xValue = event.values[0];
            yValue = event.values[1];
            zValue = event.values[2];

            win();
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {
        if(sensor.getType() != Sensor.TYPE_MAGNETIC_FIELD) return;
        if(currentState == STATE_STOPPED) return;

        this.accuracy = accuracy;
    }

    private void win() {
        PluginResult result = new PluginResult(PluginResult.Status.OK, getMagneticFieldJSON());
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
    }

    private void fail(int code, String message)
    {
        // Error object
        JSONObject errorObj = new JSONObject();
        try {
            errorObj.put("code", code);
            errorObj.put("message", message);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        PluginResult err = new PluginResult(PluginResult.Status.ERROR, errorObj);
        err.setKeepCallback(true);
        callbackContext.sendPluginResult(err);
    }

    private JSONObject getMagneticFieldJSON() {
        JSONObject r = new JSONObject();
        try {
            r.put("x", xValue);
            r.put("y", yValue);
            r.put("z", zValue);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return r;
    }
}
