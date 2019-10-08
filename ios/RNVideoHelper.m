
#import "RNVideoHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "SDAVAssetExportSession.h"

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
    
    NSNumber *startT = @([options[@"startTime"] floatValue]);
    NSNumber *endT = @([options[@"endTime"] floatValue]);
    
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

    CGSize naturalSize = [videoTrack naturalSize];

    CGFloat originalBitrate = [videoTrack estimatedDataRate];
    
    CGFloat maxWidth = 720;
    CGFloat maxHeight = 720;
    CGFloat bitrate = 1300000;
    if ([options[@"quality"] isEqual: @"medium"]) {
        maxWidth = 1280;
        maxHeight = 1280;
        bitrate = 1900000;
    } else if ([options[@"quality"] isEqual: @"high"]) {
        maxWidth = 1920;
        maxHeight = 1920;
        bitrate = 2600000;
    }
    
    CGFloat originalWidth = naturalSize.width;
    CGFloat originalHeight = naturalSize.height;
    
    CGSize transformedVideoSize =
    CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
    bool videoIsPortrait = transformedVideoSize.width < transformedVideoSize.height;

    if (videoIsPortrait && (originalWidth > originalHeight)) {
        originalWidth = naturalSize.height;
        originalHeight = naturalSize.width;
    }
    
    CGFloat widthRatio = maxWidth / originalWidth;
    CGFloat heightRatio = maxHeight / originalHeight;
    CGFloat bestRatio = MIN(widthRatio, heightRatio);
    CGFloat finalRatio = bestRatio < 1 ? bestRatio : 1;
    // output
    CGFloat width = originalWidth * finalRatio;
    CGFloat height = originalHeight * finalRatio;

    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:asset];
    
    if (startT && [startT floatValue] > duration) {
        reject(@"start_time_error", @"Start time is longer than video duration", nil);
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
    
    encoder.videoSettings = @{
      AVVideoCodecKey: AVVideoCodecH264,
      AVVideoWidthKey: @(width),
      AVVideoHeightKey: @(height),
      AVVideoCompressionPropertiesKey: @{
              AVVideoAverageBitRateKey: @(bitrate > originalBitrate ? originalBitrate : bitrate),
          AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel,
        },
    };
    
    encoder.audioSettings = @{
      AVFormatIDKey: @(kAudioFormatMPEG4AAC),
      AVNumberOfChannelsKey: @1,
      AVSampleRateKey: @44100,
      AVEncoderBitRateKey: @128000,
    };
    
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.outputURL = [NSURL fileURLWithPath:
                         [NSTemporaryDirectory() stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"compressed_%@.mov", [[NSProcessInfo processInfo] globallyUniqueString]
                          ]]];
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
             reject(@"video_export_error", [NSString stringWithFormat:@"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, encoder.error.code], nil);
         }
     }];
    
}

@end
