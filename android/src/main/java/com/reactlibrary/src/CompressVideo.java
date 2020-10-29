package com.rnvideohelper.src;

import android.os.AsyncTask;


public class CompressVideo {
    /* Listener interface */
    public interface CompressListener {
        void onStart();
        void onSuccess();
        void onFail();
        void onProgress(float percent);
    }

    private static final String TAG = CompressVideo.class.getSimpleName();

    public static VideoCompressTask compressVideo(String srcPath, String destPath, String quality, long startTime, long endTime, CompressListener listener) {
        int qualityCasted = FFMPEG.COMPRESS_QUALITY_LOW;

        if (quality.equals("high")) {
            qualityCasted = FFMPEG.COMPRESS_QUALITY_HIGH;
        } else if (quality.equals("medium")) {
            qualityCasted = FFMPEG.COMPRESS_QUALITY_MEDIUM;
        }

        VideoCompressTask task = new VideoCompressTask(listener, qualityCasted, startTime, endTime);
        task.execute(srcPath, destPath);
        return task;
    }

    /* Instance of AsyncTask(Android) callback to onProgress */
    private static class VideoCompressTask extends AsyncTask<String, Float, Boolean> {
        private CompressListener listener;
        private int quality;
        private long startTime;
        private long endTime;

        public VideoCompressTask(CompressListener listener, int quality, long startTime, long endTime) {
            this.listener = listener;
            this.quality = quality;
            this.startTime = startTime;
            this.endTime = endTime;
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            if (this.listener != null) { 
                this.listener.onStart();
            }
        }

        @Override
        protected Boolean doInBackground(String... paths) {
            FFMPEG provider = new FFMPEG(new FFMPEG.CompressProgressListener() {
                @Override
                public void onProgress(float percent) {
                    publishProgress(percent);
                }
            });

            provider.setTrim(this.startTime, this.endTime);
            provider.convert(paths[0], paths[1], this.quality);

            return true;
        }

        @Override
        protected void onProgressUpdate(Float... percent) {
            super.onProgressUpdate(percent);
            if (this.listener != null) {
                this.listener.onProgress(percent[0]);
            }
        }

        @Override
        protected void onPostExecute(Boolean result) {
            super.onPostExecute(result);
            if (this.listener != null) {
                if (result) {
                    this.listener.onSuccess();
                } else {
                    this.listener.onFail();
                }
            }
        }
    }
}
