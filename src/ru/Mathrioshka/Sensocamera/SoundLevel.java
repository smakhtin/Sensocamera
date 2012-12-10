package ru.Mathrioshka.Sensocamera;

import android.media.MediaRecorder;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaInterface;
import org.apache.cordova.api.CordovaPlugin;
import org.apache.cordova.api.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.Timer;

public class SoundLevel extends CordovaPlugin{
    public static final String ACTION_START = "start";
    private static final String ACTION_STOP = "stop";

    public static final int STATE_STOPPED = 0;
    public static final int STATE_STARTING = 1;
    public static final int STATE_RUNNING = 2;
    public static final int STATE_FAILED = 3;

    private double soundLevel = 0;

    private CallbackContext callbackContext;

    private int currentState = STATE_STOPPED;

    private MediaRecorder mediaRecorder;

    Timer timer = new Timer();
    GetAudioLevelTask getAudioLevelTask = new GetAudioLevelTask(this);

    public SoundLevel() {

    }

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if(action.equals(ACTION_START)) {
            this.callbackContext = callbackContext;
            start();
        }
        else if(action.equals(ACTION_STOP)) {
            stop();
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

        currentState= state;

        switch (currentState){
            case STATE_STOPPED:
                mediaRecorder.stop();
                mediaRecorder.release();
                mediaRecorder = null;

                timer.cancel();
                timer.purge();
                break;
            case STATE_STARTING:
                try {
                    mediaRecorder = new MediaRecorder();
                    mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
                    mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
                    mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
                    mediaRecorder.setOutputFile("/dev/null");
                    mediaRecorder.prepare();
                    mediaRecorder.start();

                    timer.schedule(getAudioLevelTask, 0, 1000);
                } catch (IOException e) {
                    e.printStackTrace();
                    setState(STATE_FAILED);
                }
                break;
            case STATE_FAILED:
                fail(currentState, (String) data);
                break;
        }
    }

    public void getAmplitude() {
        soundLevel = mediaRecorder.getMaxAmplitude()/2700.0;
        win();
    }

    private void win() {
        if(currentState == STATE_STARTING) setState(STATE_RUNNING);
        PluginResult result = new PluginResult(PluginResult.Status.OK, getMagneticFieldJSON());
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
    }

    private void fail(int currentState, String message) {
        JSONObject errorObj = new JSONObject();
        try {
            errorObj.put("code", currentState);
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
            r.put("value", soundLevel);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return r;
    }
}
