
#import "RNVideoHelper.h"
#import <AVFoundation/AVFoundation.h>

@implementation RNVideoHelper
{
    bool hasListeners;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"progress"];
}

// Will be called when this module's first listener is added.
-(void)startObserving {
    hasListeners = YES;
    // Set up any upstream listeners or background tasks as necessary
}

// Will be called when this module's last listener is removed, or on dealloc.
-(void)stopObserving {
    hasListeners = NO;
    // Remove upstream listeners, stop unnecessary background tasks
}

- (void)updateProgress: (float) progress
{
    if (hasListeners) { // Only send events if anyone is listening
        [self sendEventWithName:@"progress" body:@(progress)];
    }
}

RCT_EXPORT_METHOD(compress:(NSString *)source options:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
    
    NSDate *methodStart = [NSDate date];
    
    NSURL *url = [[NSURL alloc] initWithString:source];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    CMTime assetTime = [asset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
    
    NSNumber * startT = @([options[@"startTime"] floatValue]);
    NSNumber * endT = @([options[@"endTime"] floatValue]);
    
    NSString * preset = nil;
    if (!options[@"quality"] || [options[@"quality"] isEqual: @"low"]) {
        preset = AVAssetExportPreset640x480;
    } else if ([options[@"quality"] isEqual: @"medium"]) {
        preset = AVAssetExportPreset1280x720;
    } else if ([options[@"quality"] isEqual: @"high"]) {
        preset = AVAssetExportPreset1920x1080;
    } else {
        reject(@"quality_error", @"Video quality should be low, medium or high", nil);
        return;
    }
    
    AVAssetExportSession *encoder = [[AVAssetExportSession alloc] initWithAsset:asset presetName:preset];
    
    if (startT && [startT floatValue] > duration) {
        reject(@"start_time_error", @"Start time is larger than video duration", nil);
        return;
    }
    
    if (endT && [endT floatValue] > duration) {
        endT = nil;
    }
    
    if (startT || endT) {
        CMTime startTime = CMTimeMake((startT) ? [startT floatValue] : 0, 1);
        CMTime stopTime = CMTimeMake((endT) ? [endT floatValue] : duration, 1);
        CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
        encoder.timeRange = exportTimeRange;
    }
    
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.outputURL = [NSURL fileURLWithPath:
                         [NSTemporaryDirectory() stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"compressed-%d.mov",arc4random() % 1000]
                          ]
                         ];
    encoder.shouldOptimizeForNetworkUse = true;
    
    __block NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self updateProgress:encoder.progress];
    }];
    
    [encoder exportAsynchronouslyWithCompletionHandler:^
     {
         [timer invalidate];
         timer = nil;
         
         if (encoder.status == AVAssetExportSessionStatusCompleted)
         {
             NSDate *methodFinish = [NSDate date];
             NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
             NSLog(@"executionTime = %f", executionTime);
             
             NSLog(@"Video export succeeded");
             resolve(encoder.outputURL.absoluteString);
         } else {
             NSLog(@"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, encoder.error.code);
             reject(@"video_export_error", @"Video export failed", nil);
         }
     }];
    
}

@end
