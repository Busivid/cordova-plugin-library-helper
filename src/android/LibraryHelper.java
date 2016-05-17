// LibraryHelper-cordova
// http://github.com/coryjthompson/LibraryHelper-cordova
package com.coryjthompson.libraryhelper;

import java.io.File;
import java.io.FileOutputStream;
import java.util.UUID;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaMetadataRetriever;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.provider.MediaStore;
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

			if (action.equals("saveImageToLibrary") || action.equals("saveVideoToLibrary")) {
				String filePath = checkFilePath(args.getString(0));
				if (filePath.equals("")) {
					callbackContext.error("Error: filePath is empty");
					return true; //even though results failed, the action was valid.
				}

				boolean results = addToPhotoLibrary(filePath);
				if(results) {
					callbackContext.success();
				} else {
					callbackContext.error("Could not add to photo library");
				}

				return true;
			}


			if(action.equals("getVideoInfo")) {
				String filePath = checkFilePath(args.getString(0));
                                if (filePath.equals("")) {
                                        callbackContext.error("Error: filePath is empty");
                                        return true; //even though results failed, the action was valid.
                                }

				JSONObject results = new JSONObject();
				results.put("duration", getVideoDurationInSeconds(filePath));
				results.put("thumbnail", getThumbnailPath(filePath));
				callbackContext.success(results);
				return true;
			}

			return false; //if we got this far, the action wasn't found.

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
			returnValue = filePath.replaceAll("^file://", "").replaceAll("^file:", "");
		} catch (Exception e) {
			Log.e("RefreshMedia", "Error with the filePath: " + e.getMessage());
			return "";
		}

		return returnValue;
	}

	private boolean addToPhotoLibrary(String filePath) {
		File file = new File(filePath);

		Intent scanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
		scanIntent.setData(Uri.fromFile(file));

		// For more information about cordova.getContext() look here:
		// http://simonmacdonald.blogspot.com/2012/07/phonegap-android-plugins-sometimes-we.html?showComment=1342400224273#c8740511105206086350
		Context context = this.cordova.getActivity().getApplicationContext();
		context.sendBroadcast(scanIntent);

		return true;
	}

	private long getVideoDurationInSeconds(String filePath) {
		Context context = this.cordova.getActivity().getApplicationContext();
		File file = new File(filePath);

		MediaMetadataRetriever retriever = new MediaMetadataRetriever();
		retriever.setDataSource(context, Uri.fromFile(file));
		String time = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
		return Long.parseLong(time)/1000;
	}

	private String getThumbnailPath(String filePath) {
		Context context = this.cordova.getActivity().getApplicationContext();
		FileOutputStream out = null;
		try {
			String randomFilePrefix = UUID.randomUUID().toString();
			File outputDir = context.getCacheDir(); // context being the Activity pointer
			File outputFile = File.createTempFile(randomFilePrefix, ".png", outputDir);
			out = new FileOutputStream(outputFile);
			Bitmap thumb = ThumbnailUtils.createVideoThumbnail(filePath, MediaStore.Images.Thumbnails.MINI_KIND);
			thumb.compress(Bitmap.CompressFormat.PNG, 100, out);// PNG is a loseless format, compress factor 100 is ignored.
			return outputFile.getAbsolutePath();
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		} finally {
			if(out != null) {
				try {
					out.close();
				} catch (Exception e) {
				}
			}
		}
	}
}
