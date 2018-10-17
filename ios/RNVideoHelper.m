
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
    
    NSURL *url = [[NSURL alloc] initWithString:source];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:asset];
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.outputURL = [NSURL fileURLWithPath:
                         [NSTemporaryDirectory() stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"lowerBitRate-%d.mov",arc4random() % 1000]
                          ]
                        ];
    
    encoder.videoSettings = @{
      AVVideoCodecKey: AVVideoCodecH264,
      AVVideoWidthKey: options[@"width"],
      AVVideoHeightKey: options[@"height"],
      AVVideoCompressionPropertiesKey: @{
              AVVideoAverageBitRateKey: options[@"bitrate"],
              AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
              },
      };
    
    if (!options[@"removeAudio"]) {
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
             resolve(encoder.outputURL.absoluteString);
             NSLog(@"Video export succeeded");
         }
         else if (encoder.status == AVAssetExportSessionStatusCancelled)
         {
             NSLog(@"Video export cancelled");
             reject(@"Video export cancelled", nil, nil);
         }
         else
         {
             NSLog(@"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, encoder.error.code);
             reject(@"Video export failed", nil, nil);
         }
     }];
}


RCT_EXPORT_METHOD(trim:(NSString *)source options:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
    resolve(source);
}

@end
