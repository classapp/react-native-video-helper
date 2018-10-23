
package com.reactlibrary;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;
import android.util.Log;
import android.net.Uri;

public class RNVideoHelperModule extends ReactContextBaseJavaModule {

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
    int trimStart = 0;
    int trimEnd = 10;

    String pathWithoutExtension = inputUri.toString().replace( ".mp4", "" );

    String trimmedFileName = String.format( "%s_trimmed.mp4", pathWithoutExtension );

    Uri outputUri = Uri.parse( trimmedFileName );

    VideoResampler resampler = new VideoResampler();
    SamplerClip clip = new SamplerClip( inputUri );
    clip.setStartTime( trimStart );
    clip.setEndTime( trimEnd );
    resampler.addSamplerClip( clip );

    // resampler.setInput( inputUri );
    resampler.setOutput( outputUri );

    // resampler.setStartTime( mTrimStart );
    // resampler.setEndTime( mTrimEnd );

    try {
      resampler.start();
    } catch ( Throwable e ) {
      e.printStackTrace();
    }

    Log.v("WARN", "hello worldwww" + outputUri);


    pm.resolve(outputUri.toString());
  }
}