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
			server = new Server(4568); //Use the same port number used in ADK Main Board firmware
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

	private JSONObject getSensorsJSON() {
		JSONObject r = new JSONObject();
//		try {
//			r.put("x", this.x);
//			r.put("y", this.y);
//			r.put("z", this.z);
//			r.put("timestamp", this.timestamp);
//		} catch (JSONException e) {
//			e.printStackTrace();
//		}
		return r;
	}
}
