package com.coryjthompson.libraryhelper;

import java.io.File;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;

import org.json.JSONArray;
import org.json.JSONException;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

/**
 * Original Code pulled and altered from
 * https://github.com/philipp-at-greenqloud/pluginRefreshMedia
 * 
 * @author Philipp Veit (for GreenQloud.com)
 */
public class LibraryHelper extends CordovaPlugin {

	/**
	 * Executes the request and returns PluginResult.
	 * 
	 * @param action
	 *            The action to execute.
	 * @param args
	 *            JSONArry of arguments for the plugin.
	 * @param callbackId
	 *            The callback id used when calling back into JavaScript.
	 * @return A  object with a status and message.
	 */
	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {

		try {

			if (!action.equals("saveImageToLibrary") || !action.equals("saveVideoToLibrary")) {
				return false;
			}
				
			String filePath = checkFilePath(args.getString(0));

			if (filePath.equals("")) {
				callbackContext.error("Error: filePath is empty");
				return true; // even thought results failed, the action was valid. 
			}

			File file = new File(filePath);

			Intent scanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
			scanIntent.setData(Uri.fromFile(file));

			// For more information about cordova.getContext() look here:
			// http://simonmacdonald.blogspot.com/2012/07/phonegap-android-plugins-sometimes-we.html?showComment=1342400224273#c8740511105206086350
			Context context = this.cordova.getActivity().getApplicationContext();
			context.sendBroadcast(scanIntent);
			callbackContext.success();
		} catch (JSONException e) {
			callbackContext.error("JsonException: " + e.getMessage());
		} catch (Exception e) {
			callbackContext.error("Error: " + e.getMessage());
		}

		return true;
	}

	private String checkFilePath(String filePath) {
		String returnValue = "";
		try {
			returnValue = filePath.replaceAll("^file://", "");

		} catch (Exception e) {
			Log.e("RefreshMedia", "Error with the filePath: " + e.getMessage());
			return "";
		}

		return returnValue;
	}
}
