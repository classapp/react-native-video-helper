package com.reactnativevideohelper.video;

public class Sample {
    private long offset;
    private long size;

    public Sample(long offset, long size) {
        this.offset = offset;
        this.size = size;
    }

    public long getOffset() {
        return offset;
    }

    public long getSize() {
        return size;
    }
}