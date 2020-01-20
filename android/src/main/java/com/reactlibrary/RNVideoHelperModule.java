
package com.reactlibrary;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import android.net.Uri;
import android.util.Log;

import java.io.File;
import java.util.UUID;

import com.reactlibrary.video.*;

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
        final long startTime = options.hasKey("startTime") ? (long) options.getDouble("startTime") : -1;
        final long endTime = options.hasKey("endTime") ? (long) options.getDouble("endTime") : -1;
        final int recBitRate = options.hasKey("bitRate") ?  options.getInt("bitRate") : -1;
    int defaultOrientation = options.hasKey("defaultOrientation") ? (int)options.getInt("defaultOrientation") : 0;

        try {
            VideoCompress.compressVideo(inputUri, outputUri, quality, startTime, endTime,recBitRate, new VideoCompress.CompressListener() {
                @Override
                public void onStart() {
                    //Start Compress
                    Log.d("INFO", "Compression started");
                }

                @Override
                public void onSuccess(File path, int width, int height, long duration) {
                    //Finish successfully
                    WritableMap map = Arguments.createMap();
                    map.putString("path", path.getPath());
                    map.putDouble("size", path.length());
                    map.putInt("width", width);
                    map.putInt("height", height);
                    map.putDouble("duration", duration);//ms
                    map.putString("mime", "video/mp4");
                    pm.resolve(map);

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