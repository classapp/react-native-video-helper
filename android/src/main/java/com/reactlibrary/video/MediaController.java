package com.rnvideohelper.video;

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

@SuppressLint("NewApi")
public class MediaController {
    static final int COMPRESS_QUALITY_HIGH = 1;
    static final int COMPRESS_QUALITY_MEDIUM = 2;
    static final int COMPRESS_QUALITY_LOW = 3;

    public static File cachedFile;
    public String path;

    public final static String MIME_TYPE = "video/mp4";
    private final static int PROCESSOR_TYPE_OTHER = 0;
    private final static int PROCESSOR_TYPE_QCOM = 1;
    private final static int PROCESSOR_TYPE_INTEL = 2;
    private final static int PROCESSOR_TYPE_MTK = 3;
    private final static int PROCESSOR_TYPE_SEC = 4;
    private final static int PROCESSOR_TYPE_TI = 5;
    private final Object videoConvertSync = new Object();

    private boolean cancelCurrentVideoConversion = false;

    private static volatile MediaController Instance = null;
    private boolean videoConvertFirstWrite = true;
    private int DEFAULT_ORIENTATION = 0;

    interface CompressProgressListener {
        void onProgress(float percent);
    }

    public void SetDefaultOrientation (int DEFAULT_ORIENTATION) {
        this.DEFAULT_ORIENTATION = DEFAULT_ORIENTATION;
    }

    public static MediaController getInstance() {
        MediaController localInstance = Instance;
        if (localInstance == null) {
            synchronized (MediaController.class) {
                localInstance = Instance;
                if (localInstance == null) {
                    Instance = localInstance = new MediaController();
                }
            }
        }
        return localInstance;
    }


    @SuppressLint("NewApi")
    public static MediaCodecInfo selectCodec(String mimeType) {
        int numCodecs = MediaCodecList.getCodecCount();
        MediaCodecInfo lastCodecInfo = null;
        for (int i = 0; i < numCodecs; i++) {
            MediaCodecInfo codecInfo = MediaCodecList.getCodecInfoAt(i);
            if (!codecInfo.isEncoder()) {
                continue;
            }
            String[] types = codecInfo.getSupportedTypes();
            for (String type : types) {
                if (type.equalsIgnoreCase(mimeType)) {
                    lastCodecInfo = codecInfo;
                    String name = lastCodecInfo.getName();
                    if (name != null) {
                        if (!name.equals("OMX.SEC.avc.enc")) {
                            return lastCodecInfo;
                        } else if (name.equals("OMX.SEC.AVC.Encoder")) {
                            return lastCodecInfo;
                        }
                    }
                }
            }
        }
        return lastCodecInfo;
    }

    private static boolean isRecognizedFormat(int colorFormat) {
        switch (colorFormat) {
            case MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Planar:
            case MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420PackedPlanar:
            case MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420SemiPlanar:
            case MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420PackedSemiPlanar:
            case MediaCodecInfo.CodecCapabilities.COLOR_TI_FormatYUV420PackedSemiPlanar:
                return true;
            default:
                return false;
        }
    }

    @SuppressLint("NewApi")
    public static int selectColorFormat(MediaCodecInfo codecInfo, String mimeType) {
        MediaCodecInfo.CodecCapabilities capabilities = codecInfo.getCapabilitiesForType(mimeType);
        int lastColorFormat = 0;
        for (int i = 0; i < capabilities.colorFormats.length; i++) {
            int colorFormat = capabilities.colorFormats[i];
            if (isRecognizedFormat(colorFormat)) {
                lastColorFormat = colorFormat;
                if (!(codecInfo.getName().equals("OMX.SEC.AVC.Encoder") && colorFormat == 19)) {
                    return colorFormat;
                }
            }
        }
        return lastColorFormat;
    }

    public static int findTrack(MediaExtractor extractor, boolean audio) {
        int numTracks = extractor.getTrackCount();
        for (int i = 0; i < numTracks; i++) {
            MediaFormat format = extractor.getTrackFormat(i);
            String mime = format.getString(MediaFormat.KEY_MIME);
            if (audio) {
                if (mime.startsWith("audio/")) {
                    return i;
                }
            } else {
                if (mime.startsWith("video/")) {
                    return i;
                }
            }
        }
        return -5;
    }

    private void didWriteData(final VideoEditedInfo videoEditedInfo, final File file, final boolean last, final long lastFrameTimestamp, long availableSize, final boolean error, final float progress) {
        final boolean firstWrite = videoEditedInfo.videoConvertFirstWrite;
        if (firstWrite) {
            videoEditedInfo.videoConvertFirstWrite = false;
        }
    }

    private static class VideoConvertRunnable implements Runnable {

        private VideoEditedInfo videInfo;

        private VideoConvertRunnable(VideoEditedInfo videInfo) {
            this.videInfo = videInfo;
        }

        @Override
        public void run() {
            MediaController.getInstance().convertVideo(videInfo);
        }

        public static void runConversion(final VideoEditedInfo obj) {
            new Thread(() -> {
                try {
                    VideoConvertRunnable wrapper = new VideoConvertRunnable(obj);
                    Thread th = new Thread(wrapper, "VideoConvertRunnable");
                    th.start();
                    th.join();
                } catch (Exception e) {
                    FileLog.e(e);
                }
            }).start();
        }
    }

    private boolean convertVideo(final String sourcePath, String destinationPath, int quality, long startT, long endT, CompressProgressListener listener) {
        String videoPath = videoInfo.originalPath;
        long startTime = videoInfo.startTime;
        long avatarStartTime = videoInfo.avatarStartTime;
        long endTime = videoInfo.endTime;
        int resultWidth = videoInfo.resultWidth;
        int resultHeight = videoInfo.resultHeight;
        int rotationValue = videoInfo.rotationValue;
        int originalWidth = videoInfo.originalWidth;
        int originalHeight = videoInfo.originalHeight;
        int framerate = videoInfo.framerate;
        int bitrate = videoInfo.bitrate;
        int originalBitrate = videoInfo.originalBitrate;

        boolean isSecret = true;
        final File cacheFile = new File(destinationPath);
        if (cacheFile.exists()) {
            cacheFile.delete();
        }
        
        if (BuildVars.LOGS_ENABLED) {
            FileLog.d("begin convert " + videoPath + " startTime = " + startTime + " avatarStartTime = " + avatarStartTime + " endTime " + endTime + " rWidth = " + resultWidth + " rHeight = " + resultHeight + " rotation = " + rotationValue + " oWidth = " + originalWidth + " oHeight = " + originalHeight + " framerate = " + framerate + " bitrate = " + bitrate + " originalBitrate = " + originalBitrate);
        }

        if (videoPath == null) {
            videoPath = "";
        }

        long duration;
        if (startTime > 0 && endTime > 0) {
            duration = endTime - startTime;
        } else if (endTime > 0) {
            duration = endTime;
        } else if (startTime > 0) {
            duration = videoInfo.originalDuration - startTime;
        } else {
            duration = videoInfo.originalDuration;
        }

        if (framerate == 0) {
            framerate = 25;
        }/* else if (framerate > 59) {
            framerate = 59;
        }*/

        if (rotationValue == 90 || rotationValue == 270) {
            int temp = resultHeight;
            resultHeight = resultWidth;
            resultWidth = temp;
        }

        boolean needCompress = true;

        long time = System.currentTimeMillis();

        VideoConvertorListener callback = new VideoConvertorListener() {

            private long lastAvailableSize = 0;

            @Override
            public boolean checkConversionCanceled() {
                return videoInfo.canceled;
            }

            @Override
            public void didWriteData(long availableSize, float progress) {
                if (videoInfo.canceled) {
                    return;
                }
                if (availableSize < 0) {
                    availableSize = cacheFile.length();
                }

                if (!videoInfo.needUpdateProgress && lastAvailableSize == availableSize) {
                    return;
                }

                lastAvailableSize = availableSize;
                MediaController.this.didWriteData(videInfo, cacheFile, false, 0, availableSize, false, progress);
            }
        };

        videoInfo.videoConvertFirstWrite = true;

        MediaCodecVideoConvertor videoConvertor = new MediaCodecVideoConvertor();
        boolean error = videoConvertor.convertVideo(videoPath, cacheFile,
                rotationValue, isSecret,
                resultWidth, resultHeight,
                framerate, bitrate, originalBitrate,
                startTime, endTime, avatarStartTime,
                needCompress, duration,
                videoInfo.filterState,
                videoInfo.paintPath,
                videoInfo.mediaEntities,
                videoInfo.isPhoto,
                videoInfo.cropState,
                callback);


        boolean canceled = videoInfo.canceled;
        if (!canceled) {
            synchronized (videoConvertSync) {
                canceled = videoInfo.canceled;
            }
        }

        if (BuildVars.LOGS_ENABLED) {
            FileLog.d("time=" + (System.currentTimeMillis() - time) + " canceled=" + canceled);
        }

        didWriteData(videInfo, cacheFile, true, videoConvertor.getLastFrameTimestamp(), cacheFile.length(), error || canceled, 1f);

        return true;
    }

    public static int getVideoBitrate(String path) {
        MediaMetadataRetriever retriever = new MediaMetadataRetriever();
        int bitrate = 0;
        try {
            retriever.setDataSource(path);
            bitrate = Integer.parseInt(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITRATE));
        } catch (Exception e) {
            FileLog.e(e);
        }

        retriever.release();
        return bitrate;
    }

    public static int makeVideoBitrate(int originalHeight, int originalWidth, int originalBitrate, int height, int width) {
        float compressFactor;
        float minCompressFactor;
        int maxBitrate;
        if (Math.min(height, width) >= 1080) {
            maxBitrate = 6800_000;
            compressFactor = 1f;
            minCompressFactor = 1f;
        } else if (Math.min(height, width) >= 720) {
            maxBitrate = 2621_440;
            compressFactor = 1f;
            minCompressFactor = 1f;
        } else if (Math.min(height, width) >= 480) {
            maxBitrate = 1000_000;
            compressFactor = 0.8f;
            minCompressFactor = 0.9f;
        } else {
            maxBitrate = 750_000;
            compressFactor = 0.6f;
            minCompressFactor = 0.7f;
        }
        int remeasuredBitrate = (int) (originalBitrate / (Math.min(originalHeight / (float) (height), originalWidth / (float) (width))));
        remeasuredBitrate *= compressFactor;
        int minBitrate = (int) (getVideoBitrateWithFactor(minCompressFactor) / (1280f * 720f / (width * height)));
        if (originalBitrate < minBitrate) {
            return remeasuredBitrate;
        }
        if (remeasuredBitrate > maxBitrate) {
            return maxBitrate;
        }
        return Math.max(remeasuredBitrate, minBitrate);
    }

    private static int getVideoBitrateWithFactor(float f) {
        return (int) (f * 2000f * 1000f * 1.13f);
    }

    public interface VideoConvertorListener {
        boolean checkConversionCanceled();
        void didWriteData(long availableSize, float progress);
    }
}