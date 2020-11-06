
package com.reactnativevideohelper;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import android.net.Uri;
import android.util.Log;

import java.io.File;
import java.util.UUID;

import com.reactnativevideohelper.video.*;

public class RNVideoHelperModule extends ReactContextBaseJavaModule {

  private void sendProgress(ReactContext reactContext, float progress) {
    reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit("progress", progress);
  }

  private final ReactApplicationContext reactContext;

  public RNVideoHelperModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNVideoHelper";
  }

  @ReactMethod
  public void compress(String source, ReadableMap options, final Promise pm) {
    String inputUri = Uri.parse(source).getPath();
    File outputDir = reactContext.getCacheDir();

    final String outputUri = String.format("%s/%s.mp4", outputDir.getPath(), UUID.randomUUID().toString());

    String quality = options.hasKey("quality") ? options.getString("quality") : "";
    long startTime = options.hasKey("startTime") ? (long)options.getDouble("startTime") : -1;
    long endTime = options.hasKey("endTime") ? (long)options.getDouble("endTime") : -1;
    int defaultOrientation = options.hasKey("defaultOrientation") ? (int)options.getInt("defaultOrientation") : 0;

    try {
      VideoCompress.compressVideo(inputUri, outputUri, quality, startTime, endTime, new VideoCompress.CompressListener() {
        @Override
        public void onStart() {
          //Start Compress
          Log.d("INFO", "Compression started");
        }

        @Override
        public void onSuccess() {
          //Finish successfully
          pm.resolve(outputUri);

        }

        @Override
        public void onFail() {
          //Failed
          pm.reject("ERROR", "Failed to compress video");
        }

        @Override
        public void onProgress(float percent) {
          sendProgress(reactContext, percent/100);
        }
      }, defaultOrientation);
    } catch ( Throwable e ) {
      e.printStackTrace();
    }
  }
}