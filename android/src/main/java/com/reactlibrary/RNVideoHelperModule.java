
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
import java.util.UUID;
import javax.annotation.Nullable;

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
  public void compress(String source, ReadableMap options, Promise pm) {
    Uri inputUri = Uri.parse(source);

    int initialBitRate = MediaHelper.GetBitRate(inputUri);
    int initialDuration = MediaHelper.GetDuration(inputUri);
    int initialWidth = MediaHelper.GetWidth(inputUri);
    int initialHeight = MediaHelper.GetHeight(inputUri);

    String pathWithoutExtension = inputUri.toString().replace( ".mp4", "" );

    String trimmedFileName = String.format( "%s_%s.mp4", pathWithoutExtension, UUID.randomUUID().toString() );

    Uri outputUri = Uri.parse( trimmedFileName );

    try {
      VideoResampler resampler = new VideoResampler(new VideoResampler.CompressProgressListener() {
        @Override
        public void onProgress(float progress) {
          sendProgress(reactContext, progress);
        }
      });
      SamplerClip clip = new SamplerClip( inputUri );

      if (options.hasKey("startTime") || options.hasKey("endTime")) {
        clip.setStartTime( options.hasKey("startTime") ? options.getInt("startTime") : 0 );
        clip.setEndTime( options.hasKey("endTime") ? options.getInt("endTime") : initialDuration );
      }

      resampler.addSamplerClip( clip );

      resampler.setOutput( outputUri );

      resampler.setOutputResolution(
        options.hasKey("width") ? options.getInt("width") : initialWidth,
        options.hasKey("height") ? options.getInt("height") : initialHeight
      );
      resampler.setOutputBitRate( options.hasKey("bitrate") ? options.getInt("bitrate") : initialBitRate );


      resampler.start();
    } catch ( Throwable e ) {
      e.printStackTrace();
    }

    pm.resolve(outputUri.toString());
  }
}