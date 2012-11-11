package ru.Mathrioshka.Sensocamera;

import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

public class TestPlugin extends CordovaPlugin {
	public static final String NATIVE_ACTION_STRING = "nativeAction";

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException
	{
		if (action.equals(NATIVE_ACTION_STRING)) {
			String message = args.getString(0);
			echo(message, callbackContext);
			return true;
		}

		return false;
	}

	private void echo(String message, CallbackContext callbackContext)
	{
		if (message != null && message.length() > 0) {
			callbackContext.success(message);
		} else {
			callbackContext.error("Expected one non-empty string argument.");
		}
	}
}
