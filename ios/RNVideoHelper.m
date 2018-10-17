
#import "RNVideoHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "SDAVAssetExportSession.h"

@implementation RNVideoHelper

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()


RCT_EXPORT_METHOD(compress:(NSString *)source options:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
    
    resolve(source);
    
//    NSURL *url = [[NSURL alloc] initWithString:source];
//
//    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
//
//    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:asset];
//    encoder.outputFileType = AVFileTypeMPEG4;
//    encoder.outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"lowerBitRate-%d.mov",arc4random() % 1000]]];
//    encoder.videoSettings = @
//    {
//    AVVideoCodecKey: AVVideoCodecH264,
//    AVVideoWidthKey: @1920,
//    AVVideoHeightKey: @1080,
//    AVVideoCompressionPropertiesKey: @
//        {
//        AVVideoAverageBitRateKey: @6000000,
//        AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
//        },
//    };
//    encoder.audioSettings = @
//    {
//    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
//    AVNumberOfChannelsKey: @2,
//    AVSampleRateKey: @44100,
//    AVEncoderBitRateKey: @128000,
//    };
//
//    [encoder exportAsynchronouslyWithCompletionHandler:^
//    {
//        if (encoder.status == AVAssetExportSessionStatusCompleted)
//        {
//            NSLog(@"Video export succeeded");
//        }
//        else if (encoder.status == AVAssetExportSessionStatusCancelled)
//        {
//            NSLog(@"Video export cancelled");
//        }
//        else
//        {
//            NSLog(@"Video export failed with error: %@ (%d)", encoder.error.localizedDescription, encoder.error.code);
//        }
//    }];
//
//    __block bool audioFinished = false;
//    __block bool videoFinished = false;
//
//    NSURL *url = [[NSURL alloc] initWithString:source];
//
//    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
//
//    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:nil];
//
//    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
//    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
//
//    NSDictionary<NSString *,id> *videoReaderSettings = @{
//        (NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32ARGB)
//    };
//
//    CGFloat videoHeight = [videoTrack naturalSize].height;
//    CGFloat videoWidth = [videoTrack naturalSize].width;
//
////    NSDictionary<NSString *,id> *videoSettings  =  @{
////        (NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32ARGB),
////        AVVideoCompressionPropertiesKey:AVVideoAverageBitRateKey,
//////        (NSString *)AVVideoCodecKey:AVVideoCodecH264,
//////        (NSString *)AVVideoHeightKey: @(videoHeight),
//////        (NSString *)AVVideoWidthKey: @(videoWidth)
////    };
//
//    NSDictionary *videoCleanApertureSettings = @{
//     AVVideoCleanApertureWidthKey: [NSNumber numberWithInt:320],
//     AVVideoCleanApertureHeightKey: [NSNumber numberWithInt:480],
//     AVVideoCleanApertureHorizontalOffsetKey: [NSNumber numberWithInt:10],
//     AVVideoCleanApertureVerticalOffsetKey: [NSNumber numberWithInt:10]
//    };
//
//    NSDictionary *videoCleanApertureSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                [NSNumber numberWithInt:320], AVVideoCleanApertureWidthKey,
//                                                [NSNumber numberWithInt:480], AVVideoCleanApertureHeightKey,
//                                                [NSNumber numberWithInt:10], AVVideoCleanApertureHorizontalOffsetKey,
//                                                [NSNumber numberWithInt:10], AVVideoCleanApertureVerticalOffsetKey,
//                                                nil];
//
//
//    NSDictionary *videoAspectRatioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                              [NSNumber numberWithInt:3], AVVideoPixelAspectRatioHorizontalSpacingKey,
//                                              [NSNumber numberWithInt:3],AVVideoPixelAspectRatioVerticalSpacingKey,
//                                              nil];
//
//
//
//    NSDictionary *codecSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   [NSNumber numberWithInt:960000], AVVideoAverageBitRateKey,
//                                   [NSNumber numberWithInt:1],AVVideoMaxKeyFrameIntervalKey,
//                                   videoCleanApertureSettings, AVVideoCleanApertureKey,
//                                   //videoAspectRatioSettings, AVVideoPixelAspectRatioKey,
//                                   //AVVideoProfileLevelH264Main30, AVVideoProfileLevelKey,
//                                   nil];
//
//
//
//    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   AVVideoCodecH264, AVVideoCodecKey,
//                                   codecSettings,AVVideoCompressionPropertiesKey,
//                                   [NSNumber numberWithInt:320], AVVideoWidthKey,
//                                   [NSNumber numberWithInt:480], AVVideoHeightKey,
//                                   nil];
//
//    AVAssetReaderTrackOutput *assetReaderVideoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:videoReaderSettings];
//
//    AVAssetReaderTrackOutput *assetReaderAudioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
//
//    if ([reader canAddOutput:assetReaderVideoOutput]) {
//        [reader addOutput:assetReaderVideoOutput];
//    } else {
//        reject(@"Couldn't add video output reader", nil, nil);
//    }
//
//    AVAssetWriterInput *audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:nil];
//    AVAssetWriterInput *videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
//
//    videoInput.transform = videoTrack.preferredTransform;
//
//    dispatch_queue_t videoInputQueue = dispatch_queue_create("videoQueue", nil);
//    dispatch_queue_t audioInputQueue = dispatch_queue_create("audioQueue", nil);
//
//    NSURL *outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mp4"]];
//
//    AVAssetWriter* writer = [AVAssetWriter assetWriterWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:nil];
//
//
//    writer.shouldOptimizeForNetworkUse = true;
//    [writer addInput:videoInput];
//    [writer addInput:audioInput];
//
//    [writer startWriting];
//    [reader startReading];
//    [writer startSessionAtSourceTime:kCMTimeZero];
//
//
//    [audioInput requestMediaDataWhenReadyOnQueue:audioInputQueue usingBlock:^{
//        while(audioInput.isReadyForMoreMediaData){
//            CMSampleBufferRef sample = [assetReaderAudioOutput copyNextSampleBuffer];
//            if (sample != nil){
//                [audioInput appendSampleBuffer:sample];
//            }else{
//                [audioInput markAsFinished];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    audioFinished = true;
//                    if (!videoFinished) return;
//                    [writer finishWritingWithCompletionHandler:^{
//                        resolve(writer.outputURL);
//                    }];
//                    [reader cancelReading];
//                });
//            }
//        }
//    }];
//
//    [videoInput requestMediaDataWhenReadyOnQueue:videoInputQueue usingBlock:^{
//        while(videoInput.isReadyForMoreMediaData){
//            CMSampleBufferRef sample = [assetReaderVideoOutput copyNextSampleBuffer];
//            if (sample != nil){
//                [videoInput appendSampleBuffer:sample];
//            }else{
//                [videoInput markAsFinished];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    videoFinished = true;
//                    if (!audioFinished) return;
//                    [writer finishWritingWithCompletionHandler:^{
//                        resolve(writer.outputURL);
//                    }];
//                    [reader cancelReading];
//                });
//            }
//        }
//    }];
//

}

RCT_EXPORT_METHOD(trim:(NSString *)source options:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
    resolve(source);
}

@end

//
//
//func compressFile(urlToCompress: URL, outputURL: URL, completion:@escaping (URL)->Void){
//    //video file to make the asset
//
//    var audioFinished = false
//    var videoFinished = false
//
//
//
//    let asset = AVAsset(url: urlToCompress);
//
//    //create asset reader
//    do{
//        assetReader = try AVAssetReader(asset: asset)
//    } catch{
//        assetReader = nil
//    }
//
//    guard let reader = assetReader else{
//        fatalError("Could not initalize asset reader probably failed its try catch")
//    }
//
//    let videoTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first!
//    let audioTrack = asset.tracks(withMediaType: AVMediaTypeAudio).first!
//
//    let videoReaderSettings: [String:Any] =  [kCVPixelBufferPixelFormatTypeKey as String!:kCVPixelFormatType_32ARGB ]
//
//    // ADJUST BIT RATE OF VIDEO HERE
//
//    let videoSettings:[String:Any] = [
//                                      AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey:self.bitrate],
//                                      AVVideoCodecKey: AVVideoCodecH264,
//                                      AVVideoHeightKey: videoTrack.naturalSize.height,
//                                      AVVideoWidthKey: videoTrack.naturalSize.width
//                                      ]
//
//
//    let assetReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
//    let assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
//
//
//    if reader.canAdd(assetReaderVideoOutput){
//        reader.add(assetReaderVideoOutput)
//    }else{
//        fatalError("Couldn't add video output reader")
//    }
//
//    if reader.canAdd(assetReaderAudioOutput){
//        reader.add(assetReaderAudioOutput)
//    }else{
//        fatalError("Couldn't add audio output reader")
//    }
//
//    let audioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: nil)
//    let videoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
//    videoInput.transform = videoTrack.preferredTransform
//    //we need to add samples to the video input
//
//    let videoInputQueue = DispatchQueue(label: "videoQueue")
//    let audioInputQueue = DispatchQueue(label: "audioQueue")
//
//    do{
//        assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileTypeQuickTimeMovie)
//    }catch{
//        assetWriter = nil
//    }
//    guard let writer = assetWriter else{
//        fatalError("assetWriter was nil")
//    }
//
//    writer.shouldOptimizeForNetworkUse = true
//    writer.add(videoInput)
//    writer.add(audioInput)
//
//
//    writer.startWriting()
//    reader.startReading()
//    writer.startSession(atSourceTime: kCMTimeZero)
//
//
//    let closeWriter:()->Void = {
//        if (audioFinished && videoFinished){
//            self.assetWriter?.finishWriting(completionHandler: {
//
//                self.checkFileSize(sizeUrl: (self.assetWriter?.outputURL)!, message: "The file size of the compressed file is: ")
//
//                completion((self.assetWriter?.outputURL)!)
//
//            })
//
//            self.assetReader?.cancelReading()
//
//        }
//    }
//
//
//    audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
//        while(audioInput.isReadyForMoreMediaData){
//            let sample = assetReaderAudioOutput.copyNextSampleBuffer()
//            if (sample != nil){
//                audioInput.append(sample!)
//            }else{
//                audioInput.markAsFinished()
//                DispatchQueue.main.async {
//                    audioFinished = true
//                    closeWriter()
//                }
//                break;
//            }
//        }
//    }
//
//    videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
//        //request data here
//
//        while(videoInput.isReadyForMoreMediaData){
//            let sample = assetReaderVideoOutput.copyNextSampleBuffer()
//            if (sample != nil){
//                videoInput.append(sample!)
//            }else{
//                videoInput.markAsFinished()
//                DispatchQueue.main.async {
//                    videoFinished = true
//                    closeWriter()
//                }
//                break;
//            }
//        }
//
//    }
//
//
//}
//
//func checkFileSize(sizeUrl: URL, message:String){
//    let data = NSData(contentsOf: sizeUrl)!
//    print(message, (Double(data.length) / 1048576.0), " mb")
//    }
