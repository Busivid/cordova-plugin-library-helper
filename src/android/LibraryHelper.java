// LibraryHelper-cordova
// http://github.com/coryjthompson/LibraryHelper-cordova
package com.coryjthompson.libraryhelper;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
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
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.media.MediaMetadataRetriever;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Log;
import android.os.Environment;

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
				results.put("rotation", getExifRotation(filePath));
				callbackContext.success(results);
				return true;
			}

			if(action.equals("compressImage")) {
				String filePath = checkFilePath(args.getString(0));
				if (filePath.equals("")) {
					callbackContext.error("Error: filePath is empty");
					return true; //even though results failed, the action was valid.
				}

				int jpegCompression = args.optInt(1) > 0
						? args.optInt(1)
						: 60;

				JSONObject results = new JSONObject();
				results.put("compressedImage", compressImage(filePath, jpegCompression));
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

		try {
			MediaMetadataRetriever retriever = new MediaMetadataRetriever();
			retriever.setDataSource(context, Uri.fromFile(file));
			String hasVideo = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_HAS_VIDEO);
			String time = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);

			if(time == null || !hasVideo.equals("yes"))
				return Long.parseLong("0");
		
			double duration = Double.parseDouble(time)/1000;
			if(duration < 1 && duration > 0)
				duration = 1;

			return Math.round(duration);
		} catch (Exception e) {
			return Long.parseLong("0");
		}
	}

	private String getThumbnailPath(String filePath) {
		FileOutputStream out = null;
		try {
			File outputFile = getWritableFile("png");
			out = new FileOutputStream(outputFile);

			Bitmap thumb;
			if(isImage(filePath)) {
				BitmapFactory.Options bitmapOptions = new BitmapFactory.Options();
				bitmapOptions.inJustDecodeBounds = true;
				BitmapFactory.decodeFile(filePath, bitmapOptions);

				int rotate = getExifRotation(filePath);

				int height = -1;
				int width = -1;

				if(rotate == 90 || rotate == 270) {
					height = bitmapOptions.outWidth;
					width = bitmapOptions.outHeight;
				} else {
					height = bitmapOptions.outHeight;
					width = bitmapOptions.outWidth;
				}

				double aspectHeight = (double)180 / (double)height;
				double aspectWidth = (double)320 / (double)width;
				double aspectRatio = (aspectWidth > aspectHeight) // get min of aspectWidth and aspectHeight
						? aspectHeight
						: aspectWidth;

				int newHeight = (int)Math.round(height * aspectRatio);
				int newWidth = (int)Math.round(width * aspectRatio);
				int sampleSize = (int)Math.round(1 / aspectRatio);
				if(sampleSize%2 != 0) {
					sampleSize -= 1;
				}

				bitmapOptions = new BitmapFactory.Options();
				bitmapOptions.inJustDecodeBounds = false;
				bitmapOptions.inSampleSize =sampleSize;
				Bitmap bitmap = BitmapFactory.decodeFile(filePath, bitmapOptions);

				if (rotate != 0) {
					//rotate bitmap
					Matrix matrix = new Matrix();
					matrix.setRotate(rotate);
					bitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, false);
				}

				thumb = Bitmap.createScaledBitmap(bitmap, newWidth, newHeight, false);
			} else {
				thumb = ThumbnailUtils.createVideoThumbnail(filePath, MediaStore.Images.Thumbnails.MINI_KIND);
			}

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

	private int getExifRotation(String filePath) throws IOException {
		ExifInterface exif = new ExifInterface(filePath);
		int orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
		int rotate = 0;
		switch (orientation) {
            case ExifInterface.ORIENTATION_ROTATE_270:
                rotate = 270;
                break;
            case ExifInterface.ORIENTATION_ROTATE_180:
                rotate = 180;
                break;
            case ExifInterface.ORIENTATION_ROTATE_90:
                rotate = 90;
                break;
        }
		return rotate;
	}

	private String compressImage(String filePath, int jpegCompression) {
		FileOutputStream out = null;

		try {
			File outputFile = getWritableFile("jpg");
			out = new FileOutputStream(outputFile);

			Bitmap inputImage = BitmapFactory.decodeFile(filePath);
			int rotate = getExifRotation(filePath);

			if (rotate != 0) {
				//rotate bitmap
				Matrix matrix = new Matrix();
				matrix.setRotate(rotate);
				inputImage = Bitmap.createBitmap(inputImage, 0, 0, inputImage.getWidth(), inputImage.getHeight(), matrix, false);
			}

			inputImage.compress(Bitmap.CompressFormat.JPEG, jpegCompression, out);
			return outputFile.getAbsolutePath();

		} catch (Exception e) {
			e.printStackTrace();
			return null;
		} catch (OutOfMemoryError e) {
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

	private File getWritableFile(String ext)
	{
	    	int i = 1;
	        String state = Environment.getExternalStorageState();
	        File dataDirectory = Environment.MEDIA_MOUNTED.equals(state)
	            ? cordova.getActivity().getApplicationContext().getExternalFilesDir(null)
	            : cordova.getActivity().getApplicationContext().getFilesDir();
	
	        // Create the data directory if it doesn't exist
	        dataDirectory.mkdirs();
	        String dataPath = dataDirectory.getAbsolutePath();
	        File file;
	        do {
	            file = new File(dataPath + String.format("/capture_%05d." + ext, i));
	            i++;
	        } while (file.exists());
	
	        return file;
    	}

	private static boolean isImage(String filePath) {
		filePath = filePath.toLowerCase();
		return filePath.endsWith(".png") || filePath.endsWith(".jpg") || filePath.endsWith(".jpeg") || filePath.endsWith(".gif");
	}
}
