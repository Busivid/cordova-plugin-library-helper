// LibraryHelper-cordova
package com.busivid.cordova.libraryhelper;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Iterator;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;

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
import android.os.Build;

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
	 *            JSONArray of arguments for the plugin.
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

				JSONObject results = getVideoInfo(filePath);
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

	private JSONObject getVideoInfo(String filePath) {
		Context context = this.cordova.getActivity().getApplicationContext();
		File file = new File(filePath);

		double duration = 0;
		long fileSize = file.length();
		float frameRate = 0;
		int height = 0;
		int width = 0;

		try {
			if (isImage(filePath)) {
				BitmapFactory.Options bitmapOptions = new BitmapFactory.Options();
				bitmapOptions.inJustDecodeBounds = true;
				BitmapFactory.decodeFile(filePath, bitmapOptions);
				height = bitmapOptions.outHeight;
				width = bitmapOptions.outWidth;
			} else {
				MediaMetadataRetriever retriever = new MediaMetadataRetriever();
				retriever.setDataSource(context, Uri.fromFile(file));

				boolean hasVideo = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_HAS_VIDEO).equals("yes");
				String time = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
				if (time != null && hasVideo)
					duration = Math.ceil(Double.parseDouble(time) / 1000);

				height = Integer.parseInt(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT));
				width = Integer.parseInt(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH));

				if (android.os.Build.VERSION.SDK_INT >= 23)
					frameRate = Float.parseFloat(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CAPTURE_FRAMERATE));
			}
		} catch (Exception e) {
		}

		JSONObject videoInfo = new JSONObject();
		try {
			videoInfo.put("duration", duration);
			videoInfo.put("fileSize", fileSize);
			videoInfo.put("frameRate", frameRate);
			videoInfo.put("height", height);
			// videoInfo.put("image", ); // frame size jpg
			videoInfo.put("rotation", getExifRotation(filePath));
			videoInfo.put("thumbnail", getThumbnailPath(filePath));
			videoInfo.put("width", width);
		} catch (Exception e) {
			// Do Nothing
		}

		return videoInfo;
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

	private File getWritableFile(String ext) {
		int i = 1;
		File dataDirectory = cordova.getActivity().getApplicationContext().getFilesDir();

		//hack for galaxy camera 2.
		if (Build.MODEL.equals("EK-GC200") && Build.MANUFACTURER.equals("samsung") && new File("/storage/extSdCard/").canRead()) {
			dataDirectory = new File("/storage/extSdCard/.com.buzzcard.brandingtool/");
		}

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
