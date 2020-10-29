package com.rnvideohelper.src;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaCodecList;
import android.media.MediaExtractor;
import android.media.MediaFormat;
import android.media.MediaMetadataRetriever;
import android.os.Build;
import android.util.Log;

import java.io.File;
import java.nio.ByteBuffer;

import com.arthenica.mobileffmpeg.*;
import com.arthenica.mobileffmpeg.Config;

@SuppressLint("NewApi")
public class FFMPEG {

    interface CompressProgressListener {
        void onProgress(float percent);
    }

    private FFmpeg ffmpeg = null;
    private CompressProgressListener listener = null;
    private long startTime = 0;
    private long endTime = 0;

    /* Quality params */
    static final int COMPRESS_QUALITY_HIGH = 0;
    static final int COMPRESS_QUALITY_MEDIUM = 1;
    static final int COMPRESS_QUALITY_LOW = 2;

    private final float [] QUALITY_HIGH = { 1920, 1080, 10};
    private final float [] QUALITY_MEDIUM = { 1280, 1280, 5};
    private final float [] QUALITY_LOW = { 720, 720, 1};
    private final float [][] QUALITY = { QUALITY_HIGH, QUALITY_MEDIUM, QUALITY_LOW };

    /* Other params */
    private int DEFAULT_ORIENTATION = 0;

    /**/
    public FFMPEG (CompressProgressListener listener) {
        this.listener = listener;
        this.endTime = Long.valueOf(-1);
        this.startTime = Long.valueOf(-1);
    }

    public void setTrim(long startTime, long endTime) {
        this.startTime = startTime;
        this.endTime = endTime;
    }

    public void convert(final String inputPath, final String outputPath, final int quality) {
        try {
            String qualityCasted = "";
            String dimentions = "";
            String[] trim = { "", "" };
            
            MediaMetadataRetriever retriever = new MediaMetadataRetriever();
            retriever.setDataSource(inputPath);

            qualityCasted = " -b:v " + String.valueOf(QUALITY[quality][2]) + "M";

            /* <--- Calculate and prepare dimentions --> */
            float originalWidth = Integer.valueOf(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH));
            float originalHeight = Integer.valueOf(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT));

            // float maxWidth = QUALITY[quality][0];
            // float maxHeight = QUALITY[quality][1];

            // float widthRatio = maxWidth / originalWidth;
            // float heightRatio = maxHeight / originalHeight;
            // float bestRatio = Math.min(widthRatio, heightRatio);
            // float finalRatio = bestRatio < 1 ? bestRatio : 1;

            // // output
            // // width and height must be multiples of 2
            // int resultWidth = 2 * (Math.round((originalWidth * finalRatio)/2));
            // int resultHeight = 2 * (Math.round((originalHeight * finalRatio)/2));
            
            dimentions = " -s " + String.valueOf((int)originalWidth) + "x" + String.valueOf((int)originalHeight);

            // Log.i(Config.TAG, "Frame collection" + String.valueOf(originalWidth) + String.valueOf(originalHeight));

            /* Prepare and validate trimmer command */
            float duration = (float)(Long.valueOf(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)) / (float)1000L);

            if ((float)this.startTime > duration) {
                throw new RuntimeException("Start time is longer than video duration");
            }

            if ((int)this.endTime < 0 || this.endTime < this.startTime) {
                throw new RuntimeException("End time is invalid");
            }

            if(startTime >= 0 && endTime > 0) {
                trim[0]  = " -ss " + this.convertLongIntToTimestamp(this.startTime) + " ";
                trim[1]  = " -to " + this.convertLongIntToTimestamp(this.endTime) + " ";
            }

            Config.resetStatistics();
            Config.enableStatisticsCallback(new StatisticsCallback() {
                public void apply(Statistics newStatistics) {
                    int currentTime = newStatistics.getTime() / 1000;
                    listener.onProgress(((float)currentTime / (float)(endTime - startTime)) * (float)100L);
                }
            });

            String command = " -i " + inputPath + trim[0] + qualityCasted + " -c:a copy " + trim[1] + outputPath;
            int rc = FFmpeg.execute(command);

            if (rc == 0) {
                Log.i(Config.TAG, "Command execution completed successfully.");
            } else if (rc == 255) {
                Log.i(Config.TAG, "Command execution cancelled by user.");
            } else {
                Log.i(Config.TAG, String.format("Command execution failed with rc=%d and the output below.", rc));
                Config.printLastCommandOutput(Log.INFO);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String convertLongIntToTimestamp(long duration) {     
        Log.i("ClassAppInfo", String.valueOf(duration));   
        int h = (int)((float)duration / (float)3600L);
        int m = (int)(((float)duration - (float)h * 3600L) / (float)60L);
        float s = (float)duration - ((float)h * (float)3600L + (float)m * (float)60L);
        
        String fh = "";
        String fm = "";
        String fs = "";

        if(h < 10) fh = "0" + String.valueOf((int)h);
        else fh = String.valueOf(h);
        if(m < 10) fm = "0" + String.valueOf((int)m);
        else fm = String.valueOf(m);
        if(s < 10) fs = "0" + String.valueOf((int)s);
        else fs = String.valueOf((int)s);
        
        Log.i("ClassAppInfo", fh + ":" +fm + ":" + fs);

        return fh + ":" +fm + ":" + fs;
    }

}