package ru.Mathrioshka.Sensocamera;

import android.util.Log;
import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaPlugin;
import org.apache.cordova.api.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import org.json.JSONObject;
import org.microbridge.server.AbstractServerListener;
import org.microbridge.server.Client;
import org.microbridge.server.Server;
import org.microbridge.server.ServerListener;

import java.io.IOException;

public class ADKBridge extends CordovaPlugin {
    public static int GAS_SENSOR_ID = 1;
    public static int TEMPERATURE_SENSOR_ID = 2;
    public static int PRESSURE_SENSOR_ID = 3;
    public static int HUMIDITY_SENSOR_ID = 4;
    public static int LIGHT_SENSOR_ID = 5;

    public static final String GAS = "gas";
    public static final String TEMPERATURE = "temperature";
    public static final String PRESSURE = "pressure";
    public static final String HUMIDITY = "humidity";
    public static final String LIGHT = "light";

    private int gasValue = 0;
    private int temperatureValue = 0;
    private int pressureValue = 0;
    private int humidityValue = 0;
    private int lightValue = 0;

	public static final String START = "start";
	public static final String STOP = "stop";

	public static final int STATE_STOPPED = 0;
	public static final int STATE_STARTING = 1;
	public static final int STATE_RUNNING = 2;
	public static final int STATE_FAILED_TO_START = 3;

	private int currentState = STATE_STOPPED;

	private CallbackContext callbackContext;

	Server server;
	ServerListener listener;

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException
	{
		if(action.equals(START))
		{
			this.callbackContext = callbackContext;

			if(currentState != STATE_RUNNING) setState(STATE_STARTING);
		}
		else if(action.equals(STOP))
		{

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
	public void onDestroy()
	{
		stop();
	}

	@Override
	public void onReset()
	{
		stop();
	}

	private void stop()
	{
		if(currentState == STATE_RUNNING) setState(STATE_STOPPED);
	}

	private void setState(int state)
	{
		setState(state, null);
	}

	private void setState(int state, Object data)
	{
		if(currentState == state) return;
		currentState = state;

		switch (currentState)
		{
			case STATE_STOPPED:
				server.removeListener(listener);
				server.stop();
				break;
			case STATE_STARTING:
				start();
				break;
			case STATE_RUNNING:
				break;
			case STATE_FAILED_TO_START:
				fail(currentState, (String) data);
				break;
		}
	}

	private void start()
	{
		try
		{
			server = new Server(4568);
			server.start();
		}catch (IOException e)
		{
			setState(STATE_FAILED_TO_START, "Can't start ADB server");
		}

		listener = new AbstractServerListener()
		{
			@Override
			public void onReceive(Client client, byte[] data)
			{
				if(currentState != STATE_RUNNING) return;

                int id = (data[3] & 0xff);
                int val = (data[0] & 0xff) | ((data[1] & 0xff) << 8) | ((data[2] & 0xff) << 160);

				Log.d("STATUS", "Received some data");

				win();
			}
		};

		server.addListener(listener);

		setState(STATE_RUNNING, null);
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

	private void win() {
		// Success return object
		PluginResult result = new PluginResult(PluginResult.Status.OK, getSensorsJSON());
		result.setKeepCallback(true);
		callbackContext.sendPluginResult(result);
	}

	private JSONObject getSensorsJSON()
    {
		JSONObject r = new JSONObject();
		try {
			r.put(GAS, gasValue);
			r.put(TEMPERATURE, temperatureValue);
			r.put(PRESSURE, pressureValue);
			r.put(HUMIDITY, humidityValue);
            r.put(LIGHT, lightValue);
        } catch (JSONException e) {
			e.printStackTrace();
		}
		return r;
	}
}
