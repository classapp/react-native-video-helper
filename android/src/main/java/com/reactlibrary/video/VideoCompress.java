package com.reactlibrary.video;

import android.os.AsyncTask;

import java.io.File;

public class VideoCompress {
    private static final String TAG = VideoCompress.class.getSimpleName();

    public static VideoCompressTask compressVideo(String srcPath, String destPath, String quality, long startTime, long endTime, CompressListener listener) {
        int finalQuality = MediaController.COMPRESS_QUALITY_LOW;

        if (quality.equals("high")) {
            finalQuality = MediaController.COMPRESS_QUALITY_HIGH;
        } else if (quality.equals("medium")) {
            finalQuality = MediaController.COMPRESS_QUALITY_MEDIUM;
        }

        VideoCompressTask task = new VideoCompressTask(listener, finalQuality, startTime, endTime);
        task.execute(srcPath, destPath);
        return task;
    }

    private static class VideoCompressTask extends AsyncTask<String, Float, Boolean> {
        private CompressListener mListener;
        private int mQuality;
        private long mStartTime;
        private long mEndTime;
        private File mOutFile;

        public VideoCompressTask(CompressListener listener, int quality, long startTime, long endTime) {
            mListener = listener;
            mQuality = quality;
            mStartTime = startTime;
            mEndTime = endTime;
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            if (mListener != null) {
                mListener.onStart();
            }
        }

        @Override
        protected Boolean doInBackground(String... paths) {
            mOutFile = new File(paths[1]);
            return MediaController.getInstance().convertVideo(paths[0], paths[1], mQuality, mStartTime, mEndTime, new MediaController.CompressProgressListener() {
                @Override
                public void onProgress(float percent) {
                    publishProgress(percent);
                }
            });
        }

        @Override
        protected void onProgressUpdate(Float... percent) {
            super.onProgressUpdate(percent);
            if (mListener != null) {
                mListener.onProgress(percent[0]);
            }
        }

        @Override
        protected void onPostExecute(Boolean result) {
            super.onPostExecute(result);
            if (mListener != null) {
                if (result) {
                    final int width = MediaController.getInstance().resultWidth;
                    final int height = MediaController.getInstance().resultHeight;
                    mListener.onSuccess(mOutFile, width, height, (mEndTime - mStartTime)*1000);
                } else {
                    mListener.onFail();
                }
            }
        }
    }

    public interface CompressListener {
        void onStart();

        void onSuccess(File file, int width, int height, long duration);

        void onFail();

        void onProgress(float percent);
    }
}
