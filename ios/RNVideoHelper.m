
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
    
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize dimensions = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
    
    CMTime assetTime = [asset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
    
    NSNumber * startT = @([options[@"startTime"] floatValue]);
    NSNumber * endT = @([options[@"endTime"] floatValue]);
    bool removeAudio = [options[@"removeAudio"] intValue] == 1;
    
    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:asset];

    if (startT && [startT floatValue] > duration) {
        reject(@"Start time is larger than video duration", nil, nil);
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
                          [NSString stringWithFormat:@"lowerBitRate-%d.mov",arc4random() % 1000]
                          ]
                         ];
    encoder.shouldOptimizeForNetworkUse = true;

    encoder.videoSettings = @{
                              AVVideoCodecKey: AVVideoCodecH264,
                              AVVideoWidthKey: (options[@"width"]) ? options[@"width"] : @(dimensions.width),
                              AVVideoHeightKey: options[@"height"] ? options[@"height"] : @(dimensions.height),
                              AVVideoCompressionPropertiesKey: @{
                                      AVVideoAverageBitRateKey: (options[@"bitrate"]) ? options[@"bitrate"] : @([track estimatedDataRate]),
                                      AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel,
                                      },
                              };

    if (!removeAudio) {
        encoder.audioSettings = @{
                                  AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                  AVNumberOfChannelsKey: @2,
                                  AVSampleRateKey: @44100,
                                  AVEncoderBitRateKey: @96000,
                                };
    }
    
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
             reject(@"Video export failed", nil, nil);
         }
     }];

}

@end
