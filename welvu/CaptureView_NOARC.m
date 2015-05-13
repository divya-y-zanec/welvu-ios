//
//  CaptureView.m
//  welvu
//
//  Created by Logesh Kumaraguru on 11/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "CaptureView.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "welvuContants.h"
#import "UIImage+Resize.h"
#import "UIDeviceHardware.h"

/*
 * Class name: CaptureView
 * Description: Private class method declaration
 * Extends: nil
 * Delegate : nil
 */
@interface CaptureView ()
-(BOOL) setUpWriter:(NSString *)recordContentName;
-(void) recordingVideo;
-(void) writeVideoFrameAtTime:(CMTime)time;
-(void) completeRecordingSession:(NSString *)recordContentName;
-(CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image;
-(NSDictionary *) setUpAudioRecording;
@end

//Implementing the CaptureView to capture the Video and Audio from the screen
@implementation CaptureView

@synthesize frameRate, currentScreen, annotatedCapturedScreen, isExportCompleted, touchBeganFlag, vuModifiedFlag, playerView,
moviePlayer, playerSliderView, playBackTime;
@synthesize videoCompressionProps;

#pragma mark - View intialization
/*
 * Method name: initialize
 * Description: To intialize attributes to default settings
 * Parameters: nil
 * Return Type: nil
 */
- (void) initialize {
	// Initialization code
	self.clearsContextBeforeDrawing = YES;
	self.frameRate = 10.0f;
    continuosAnnotation = false;
	recording = false;
    recordingPaused = false;
    recordingAudio = true;
	startedAt = nil;
    isExportCompleted = false;
    touchBeganFlag = false;
    vuModifiedFlag = true;
    elapsedTime = 0;
    UIDeviceHardware *device = [[UIDeviceHardware alloc] init];
    NSString * deviceModel = [device platformString];
    NSLog(@"%@", deviceModel);
    if ([deviceModel rangeOfString:@"iPad2"].location!=NSNotFound
        || [deviceModel rangeOfString:@"iPad3,6"].location!=NSNotFound) { //
        //continuosAnnotation = true;
    }
    [device release];
}

/*
 * Method name: initWithCoder
 * Description: Overidden mehtod, This method is called when Capture view is mapped via nib file
 * Parameters: aDecoder
 * Return Type: self
 */
- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initialize];
	}
	return self;
}

/*
 * Method name: initWithFrame
 * Description: This method is called when Capture view is intialized with frame customization
 * Parameters: frame - hold details of the view dimension
 * Return Type: self
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

-(void) intializeVideoPreviewContent  {
    moviePlayer = [[MPMoviePlayerController alloc] init];
    [moviePlayer setAllowsAirPlay:NO];
    [moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
    [moviePlayer setEndPlaybackTime:-1];
    [moviePlayer setInitialPlaybackTime:-1];
    [moviePlayer setMovieSourceType:MPMovieSourceTypeUnknown];
    //[moviePlayer setRepeatMode:MPMovieRepeatModeNone];
    [moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
    [moviePlayer setShouldAutoplay:NO];
    [moviePlayer setUseApplicationAudioSession:NO];
    [moviePlayer.view setFrame:CGRectMake(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)];
    moviePlayer.controlStyle = MPMovieControlStyleNone;
    [playerView addSubview:moviePlayer.view];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    OSStatus propertySetError = 0;
    
    UInt32 allowMixing = kAudioSessionCategory_PlayAndRecord;
    
    propertySetError = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers,
                                                sizeof (allowMixing), &allowMixing);
}
-(void)refreshPlayerSlider {
    
    if(moviePlayer != nil && moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [playerSliderView setValue:moviePlayer.currentPlaybackTime];
        [self performSelector:@selector(refreshPlayerSlider) withObject:nil afterDelay:0.1];
    }
}

-(void) removeVideoPreviewContent {
    if(moviePlayer != nil) {
        [moviePlayer stop];
        
        moviePlayer.view.hidden = true;
        self.annotatedCapturedScreen = nil;
    }
}

-(void)releaseVideoPreviewContent {
    if(moviePlayer != nil) {
        [moviePlayer stop];
        [moviePlayer.view removeFromSuperview];
        [moviePlayer release], moviePlayer = nil;
        moviePlayer.view.hidden = true;
        self.annotatedCapturedScreen = nil;
    }
}

#pragma mark - Capture View Settings
/*
 * Method name: modifyFrameRate
 * Description: To modify and set the video frame rate
 * Parameters: float
 * Return Type: nil
 */
-(void) modifyFrameRate:(float) fpsChoice {
    self.frameRate = fpsChoice;
}

/*
 * Method name: modigyAudio_VideoSettings
 * Description: To set Audio &Video/ Audio only/ Video setting
 * Parameters: choice - integer containing the selected record settings
 * Return Type: nil
 */
-(void) modigyAudio_VideoSettings:(NSInteger) choice {
    switch (choice) {
        case 0:
            recordingAudio = true;
            recordingVideo = true;
            audio_videoChoiceSelected = 0;
            break;
        case 1:
            recordingAudio = false;
            recordingVideo = true;
            audio_videoChoiceSelected = 1;
            
            break;
        case 2:
            recordingAudio = true;
            recordingVideo = false;
            audio_videoChoiceSelected = 2;
            break;
        default:
            break;
    }
}

/*
 * Method name: audio_videoChoiceSettings
 * Description: To return current audio & video setting
 * Parameters: nil
 * Return Type: NSInteger - selected choice number
 */
-(NSInteger) audio_videoChoiceSettings{
    return audio_videoChoiceSelected;
}

#pragma mark - Capture View recording
/*
 * Method name: recordingVideo
 * Description: To capture the screen. This method will be called recursively by delay based on
 *              frame rate and the captured screen will be written as video
 * Parameters: nil
 * Return Type: nil
 */
/**
 * */
UIImage *annotatedCapturedScreen;
-(void) recordingVideo {
    
    while (recording) {
        if(!recordingPaused) {
        if(moviePlayer == nil ||  moviePlayer.view.hidden) {
            if((!touchBeganFlag && vuModifiedFlag) || continuosAnnotation) {
                vuModifiedFlag = false;
                //[self.currentScreen release], self.currentScreen = nil;
                //Capture the current screen
                UIGraphicsBeginImageContext(self.bounds.size);
                [self.layer renderInContext:UIGraphicsGetCurrentContext()];
                //start a new inner pool
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                self.currentScreen = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                //Get the content video elapsed time
                float millisElapsed = (elapsedTime + ([[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0));
                //Write the current captured frame in the specified time
                [self writeVideoFrameAtTime: CMTimeMake((int)millisElapsed, 1000)];
                [pool release];
            } else {
                 if(self.currentScreen != nil) {
                     //Get the content video elapsed time
                     float millisElapsed = (elapsedTime + ([[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0));
                     //Write the current captured frame in the specified time
                     [self writeVideoFrameAtTime: CMTimeMake((int)millisElapsed, 1000)];
                 }
            }
           
            NSDate *future = [NSDate dateWithTimeIntervalSinceNow: (1.0 / self.frameRate) ];
            [NSThread sleepUntilDate:future];
        } else if(moviePlayer != nil && [moviePlayer isPreparedToPlay] && moviePlayer.currentPlaybackTime > 0.0) {
            //[playerSliderView setValue:moviePlayer.currentPlaybackTime];
           
            CGSize destinationSize = CGSizeMake(CANVAS_WIDTH, CANVAS_HEIGHT);
            if((!touchBeganFlag && vuModifiedFlag && moviePlayer.playbackState == MPMoviePlaybackStatePaused)) {
                 NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                UIImage *singleFrameImage = [moviePlayer thumbnailImageAtTime:moviePlayer.currentPlaybackTime timeOption:MPMovieTimeOptionExact];
                
                vuModifiedFlag = false;
                UIGraphicsBeginImageContext(self.bounds.size);
                [self.layer renderInContext:UIGraphicsGetCurrentContext()];
                self.annotatedCapturedScreen = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                self.currentScreen = [singleFrameImage fuseImages:destinationSize:annotatedCapturedScreen];
                if(self.currentScreen != nil) {
                    //Get the content video elapsed time
                    float millisElapsed = (elapsedTime + ([[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0));
                    
                    [self writeVideoFrameAtTime:CMTimeMake((int)millisElapsed, 1000)];
                }
                [pool release];
                NSDate *future = [NSDate dateWithTimeIntervalSinceNow: (1.0 / self.frameRate) ];
                [NSThread sleepUntilDate:future];
            } else if(!touchBeganFlag) {
                 NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                UIImage *singleFrameImage = [moviePlayer thumbnailImageAtTime:moviePlayer.currentPlaybackTime timeOption:MPMovieTimeOptionExact];
                if(self.annotatedCapturedScreen == nil) {
                    self.currentScreen = [singleFrameImage imageResizeToFit:destinationSize];
                } else {
                    self.currentScreen = [singleFrameImage fuseImages:destinationSize:annotatedCapturedScreen];
                }
                if(self.currentScreen != nil) {
                    //Get the content video elapsed time
                    float millisElapsed = (elapsedTime + ([[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0));
                    
                    [self writeVideoFrameAtTime:CMTimeMake((int)millisElapsed, 1000)];
                }
                [pool release];
                NSDate *future = [NSDate dateWithTimeIntervalSinceNow:(1.0 / 60.0f)];
                [NSThread sleepUntilDate:future];
            }
        }
            /*dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
             dispatch_async(queue, ^ {
             
             dispatch_async(dispatch_get_main_queue(), ^ {
             NSLog(@"Back on main thread");
             });
             });*/
        }
        //recall record video at the specified framerate
        //[self performSelector:@selector(recordingVideo) withObject:nil afterDelay:(1.0 / self.frameRate)];
        
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    touchBeganFlag = true;
    vuModifiedFlag = false;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    touchBeganFlag = false;
    vuModifiedFlag = true;
}

/*
 * Method name: tempFileURL
 * Description: Location to write the VU contents
 * Parameters: recordContentName - Name of the VU content
 * Return Type: NSURL - Location of the VU content
 */
- (NSURL*) tempFileURL:(NSString *)recordContentName {
	NSString* outputPath = [NSString  stringWithFormat:@"%@/%@V.%@",
                            CACHE_DIRECTORY, recordContentName,HTTP_ATTACHMENT_VIDEO_EXT_KEY];
	NSURL* outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
	NSFileManager* fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:outputPath]) {
		NSError* error;
		if ([fileManager removeItemAtPath:outputPath error:&error] == NO) {
			NSLog(@"Could not delete old recording file at path:  %@", outputPath);
		}
	}
	return [outputURL autorelease];
}

/*
 * Method name: setUpWriter
 * Description: Setting up the writer with required configuration and buffer attributes to hold
 *              the capture image and write it using AVAssetWriterInputPixedBufferAdaptor
 * Parameters: recordContentName - Name of the VU content
 * Return Type: BOOL
 */
-(BOOL) setUpWriter:(NSString *)recordContentName {
	NSError* error = nil;
    //Intializing AVAssetWriter with required URL and video type
	videoWriter = [[AVAssetWriter alloc] initWithURL:[self tempFileURL:recordContentName] fileType:AVFileTypeMPEG4 error:&error];
	NSParameterAssert(videoWriter);
	
	//Configure video
	videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
										   [NSNumber numberWithDouble:1024*1024], AVVideoAverageBitRateKey,
										   nil ];
	// Video settings
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
								   AVVideoCodecH264, AVVideoCodecKey,
								   [NSNumber numberWithInt:CANVAS_WIDTH], AVVideoWidthKey,
								   [NSNumber numberWithInt:CANVAS_HEIGHT], AVVideoHeightKey,
								   nil];
    
	//videoCompressionProps, AVVideoCompressionPropertiesKey,
    
	videoWriterInput = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings] retain];
	
	NSParameterAssert(videoWriterInput);
	videoWriterInput.expectsMediaDataInRealTime = YES;
	NSDictionary* bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
	
	avAdaptor = [[AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput sourcePixelBufferAttributes:bufferAttributes] retain];
	
	//add input
	[videoWriter addInput:videoWriterInput];
	[videoWriter startWriting];
	[videoWriter startSessionAtSourceTime:CMTimeMake(0, 1000)];
	
	return YES;
}

/*
 * Method name: startRecording
 * Description: To start the video/audio recording in syncronized manner based on configuration
 * Parameters: recordContentName - Name of the VU content
 * Return Type: nil
 */
- (void) startRecording:(NSString *)recordContentName {
    @synchronized(self) {
		if (!recording) {
			startedAt = [[NSDate date] retain];
			recording = true;
            if(recordingVideo) {
                touchBeganFlag = false;
                vuModifiedFlag = true;
                [self setUpWriter:recordContentName];
                // [self recordingVideo];
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^ {
                    [self recordingVideo];
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        NSLog(@"Back on main thread");
                    });
                });
            }
            if(recordingAudio) {
                [self startAudioRecording:recordContentName];
            }
		}
	}
}

/*
 * Method name: pauseRecording
 * Description: Method to pause VU recording
 * Parameters: nil
 * Return Type: void
 */
- (void) pauseRecording {
    if (recording) {
        elapsedTime = elapsedTime + ([[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0);
        recordingPaused = true;
        [startedAt release];
        startedAt = nil;
        startedAt = [[NSDate date] retain];
        if(recordingAudio) {
            [audioRecorder pause];
        }
    }
}

/*
 * Method name: continueRecording
 * Description: Method to continue VU recording when paused
 * Parameters: nil
 * Return Type: void
 */
- (void) continueRecording {
    if (recordingPaused) {
        recordingPaused = false;
        startedAt = [[NSDate date] retain];
        if(recordingVideo) {
            touchBeganFlag = false;
            vuModifiedFlag = true;
        }
        if(recordingAudio) {
            [audioRecorder record];
        }
    }
}

/*
 * Method name: stopRecording
 * Description: To stop the video/audio recording and completing the recorded session based on configuration
 * Parameters: recordContentName - Name of the VU content
 * Return Type: nil
 */
- (void) stopRecording:(NSString *)recordContentName {
    @synchronized(self) {
		if (recording) {
			recording = false;
            recordingPaused = false;
            if(recordingVideo) {
                
                [self completeRecordingSession:recordContentName];
                self.annotatedCapturedScreen = nil;
            }
            if(recordingAudio) {
                [self stopAudioRecording];
            }
		}
	}
}

/*
 * Method name: suspendRecording
 * Description: To suspend the video/audio recording, when application went to background
 * Parameters: nil
 * Return Type: nil
 */
-(void) suspendRecording {
    @synchronized(self) {
        
        if(recording)  {
            recording = false;
            if(recordingVideo) {
                recordingVideo = false;
                [videoWriter finishWriting];
            }
            
            if(recordingAudio) {
                [self stopAudioRecording];
            }
            [self cleanupWriter];
        }
    }
}

/*
 * Method name: setUpAudioRecording
 * Description: Audio recording configuration and setting AVAudioSession to recording mode
 * Parameters: nil
 * Return Type: NSDictionary - Audio recording configuration
 */
-(NSDictionary *) setUpAudioRecording {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];
    return recordSettings;
}

/*
 * Method name: startAudioRecording
 * Description: Start recording audio, with configured settings in the given location
 * Parameters: recordContentName - Name of VU content
 * Return Type: nil
 */
-(void) startAudioRecording:(NSString *)recordContentName {
    //Setting up the path to save the recording audio
    NSString* outputPath = [NSString  stringWithFormat:@"%@/%@A.caf",
                            CACHE_DIRECTORY, recordContentName];
    NSURL* outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    NSLog(@"Saved path: %@", outputPath);
    
    NSError *error = nil;
    
    //Intializing the AVAudioRecorder with location to save and audio settings
    audioRecorder = [[ AVAudioRecorder alloc] initWithURL:outputURL settings:[self setUpAudioRecording] error:&error];
    
    if ([audioRecorder prepareToRecord] == YES){
        [audioRecorder record];
        NSLog(@"Started Audio Recording");
        
    }else {
        int errorCode = CFSwapInt32HostToBig ([error code]);
        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
        
    }
    [outputURL release];
}

/*
 * Method name: stopAudioRecording
 * Description: Stop audio recording and set AVAudioSession to playback mode
 * Parameters: nil
 * Return Type: nil
 */
-(void)  stopAudioRecording {
    NSLog(@"stopRecording");
    [audioRecorder stop];
    [audioRecorder release];
    audioRecorder = nil;
    //AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //[audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSLog(@"stopped");
}

/*
 * Method name: writeVideoFrameAtTime
 * Description: Write the captured image to CVPixelBufferRef and write the video frames of particular time to the video file
 *              using AVAssetWriterInputPixelBufferAdaptor and release the pixel buffer
 * Parameters: time - period at which the current capture image should written
 * Return Type: nil
 */
-(void) writeVideoFrameAtTime:(CMTime)time {
	if (![videoWriterInput isReadyForMoreMediaData]) {
		NSLog(@"Not ready for video data");
	}
	else {
		@synchronized (self) {
            CVPixelBufferRef buffer = [self pixelBufferFromCGImage:[self.currentScreen  CGImage]];
            [avAdaptor appendPixelBuffer:buffer
                    withPresentationTime:time];
            CVBufferRelease(buffer);
		}
		
	}
	
}

/*
 * Method name: completeRecordingSession
 * Description: To complete the recorded video and to release the objects intialized while video recording.
 *              Saves a copy of the recorded video to photo album.
 * Parameters: recordContentName - Name of VU content
 * Return Type: nil
 */
- (void) completeRecordingSession:(NSString *)recordContentName {
	[videoWriterInput markAsFinished];
    
	// Wait for the video
	int status = videoWriter.status;
	while (status == AVAssetWriterStatusUnknown) {
		[NSThread sleepForTimeInterval:0.5f];
		status = videoWriter.status;
	}
	
	@synchronized(self) {
		BOOL success = [videoWriter finishWriting];
		if (!success) {
			NSLog(@"finishWriting returned NO");
		}
		
		[self cleanupWriter];
        NSString* outputPath = [NSString  stringWithFormat:@"%@/%@V.%@",
                                CACHE_DIRECTORY, recordContentName,HTTP_ATTACHMENT_VIDEO_EXT_KEY];
	
		NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
		
		NSLog(@"Completed recording, file is stored at:  %@", outputPath);
		[outputURL release];
	}
}

/*
 * Method name: pixelBufferFromCGImage
 * Description: Converting the CGImage of the captured screen into ARGB CVPixelBufferRef
 * Parameters: image - Screen captured image
 * Return Type: CVPixelBufferRef - Captured image is converted into pixel buffers and returned
 */
- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                                 frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
                                                 kCGImageAlphaPremultipliedFirst);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

/*
 * Method name: combineVideoAudio
 * Description: To combine the created Audio and Video into a single VU Content using AVMutableCompositionTrack and AVAssetExportSession
 * Parameters: recordContentName - Name of VU content
 * Return Type: nil
 */
-(void)combineVideoAudio:(NSString *)recordContentName {
    NSString* audioPath = [NSString stringWithFormat:@"%@/%@A.caf",
                           CACHE_DIRECTORY, recordContentName];
	NSURL* audioURL = [[NSURL alloc] initFileURLWithPath:audioPath];
    NSString* videoPath = [NSString stringWithFormat:@"%@/%@V.%@",
                           CACHE_DIRECTORY, recordContentName,
                           HTTP_ATTACHMENT_VIDEO_EXT_KEY];
	NSURL* videoURL = [[NSURL alloc] initFileURLWithPath:videoPath];
    
    NSLog(@"SOMEDATA IS THERE ");
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audioURL options:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoURL options:nil];
    
    NSString* disclaimerPath = [[NSBundle mainBundle] pathForResource:@"disclaimerVideo" ofType:@"mp4"];
    NSURL* disclaimerURL = [[NSURL alloc] initFileURLWithPath:disclaimerPath];
    AVURLAsset* disclaimerAsset = [[AVURLAsset alloc]initWithURL:disclaimerURL options:nil];
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    [compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero,videoAsset.duration) toDuration:audioAsset.duration];
    
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, disclaimerAsset.duration) ofTrack:[[disclaimerAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:audioAsset.duration error:nil];
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc]
                                          initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    NSLog(@"dewd %@",_assetExport);
    NSString* videoName = [NSString stringWithFormat:@"export1.%@",
                           HTTP_ATTACHMENT_VIDEO_EXT_KEY];
    
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
    NSURL    *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    
    _assetExport.outputFileType = AVFileTypeMPEG4;
    NSLog(@"file type %@",_assetExport.outputFileType);
    _assetExport.outputURL = exportUrl;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    
    
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void )
     {
         
         switch (_assetExport.status)
         {
             case AVAssetExportSessionStatusCompleted: {
                 NSString* outputPath = [NSString stringWithFormat:@"%@/%@AV.%@",
                                         CACHE_DIRECTORY, recordContentName,
                                         HTTP_ATTACHMENT_VIDEO_EXT_KEY];
                 NSURL* outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
                 if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
                     [[NSFileManager defaultManager] removeItemAtPath: outputPath error:NULL];
                 }
                 
                 [[NSFileManager defaultManager] moveItemAtURL:exportUrl toURL:outputURL error:nil];
                 //export complete
                  NSLog(@"Combine AV Complete %@",outputPath);
                 int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:outputURL];
                 [outputURL release];
                 if(success) {
                     isExportCompleted = true;
                     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_EXPORT_COMPLETED
                                                                         object:self];
                 }
             }
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Export Failed");
                 NSLog(@"ExportSessionError: %@", [_assetExport.error localizedDescription]);
                 //export error (see exportSession.error)
                 [self combineVideoAudio:recordContentName];
                 break;
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Export Failed");
                 NSLog(@"ExportSessionError: %@", [_assetExport.error localizedDescription]);
                 //export cancelled
                 [self combineVideoAudio:recordContentName];
                 break;
         }
         [disclaimerAsset release];
         [disclaimerURL release];
         [audioAsset release];
         [videoAsset release];
         [_assetExport release];
         [audioURL release];
         [videoURL release];
     }];
}


/*
 * Method name: combineDisclaimer
 * Description: To combine the created Audio and Video into a single VU Content using AVMutableCompositionTrack and AVAssetExportSession
 * Parameters: recordContentName - Name of VU content
 * Return Type: nil
 */
-(void)combineDisclaimer:(NSString *)recordContentName {
  
    NSString* videoPath = @"";
    if(!recordingAudio && recordingVideo) {
        videoPath = [NSString stringWithFormat:@"%@/%@V.%@",
                           CACHE_DIRECTORY, recordContentName,
                           HTTP_ATTACHMENT_VIDEO_EXT_KEY];
    }else if(recordingAudio && recordingVideo) {
        videoPath = [NSString stringWithFormat:@"%@/%@AV.%@",
                     CACHE_DIRECTORY, recordContentName,
                     HTTP_ATTACHMENT_VIDEO_EXT_KEY];
    }
    NSString* disclaimerPath = [[NSBundle mainBundle] pathForResource:@"disclaimerVideo" ofType:@"mp4"];
	
	NSURL* videoURL = [[NSURL alloc] initFileURLWithPath:videoPath];
    NSURL* disclaimerURL = [[NSURL alloc] initFileURLWithPath:disclaimerPath];
    
    NSLog(@"SOMEDATA IS THERE %@", disclaimerPath);
   
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoURL options:nil];
    AVURLAsset* disclaimerAsset = [[AVURLAsset alloc]initWithURL:disclaimerURL options:nil];
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    //[compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero,videoAsset.duration) toDuration:audioAsset.duration];
    
    /*AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];*/
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, disclaimerAsset.duration) ofTrack:[[disclaimerAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:videoAsset.duration error:nil];
    
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc]
                                          initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    NSLog(@"dewd %@",_assetExport);
    NSString* videoName = [NSString stringWithFormat:@"export2.%@",
                           HTTP_ATTACHMENT_VIDEO_EXT_KEY];
    
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
    NSURL    *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    
    _assetExport.outputFileType = AVFileTypeMPEG4;
    NSLog(@"file type %@",_assetExport.outputFileType);
    _assetExport.outputURL = exportUrl;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    
    
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void )
     {
         
         switch (_assetExport.status)
         {
             case AVAssetExportSessionStatusCompleted: {
                 NSString* outputPath = @"";
                 if(!recordingAudio && recordingVideo) {
                     outputPath = [NSString stringWithFormat:@"%@/%@V.%@",
                                   CACHE_DIRECTORY, recordContentName,
                                   HTTP_ATTACHMENT_VIDEO_EXT_KEY];
                 }else if(recordingAudio && recordingVideo) {
                     outputPath = [NSString stringWithFormat:@"%@/%@AV.%@",
                                   CACHE_DIRECTORY, recordContentName,
                                   HTTP_ATTACHMENT_VIDEO_EXT_KEY];
                 }
                
                 NSURL* outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
                 if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
                     [[NSFileManager defaultManager] removeItemAtPath: outputPath error:NULL];
                 }
                 
                 [[NSFileManager defaultManager] moveItemAtURL:exportUrl toURL:outputURL error:nil];
                 int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:outputURL];
                 //export complete
                 [outputURL release];
                 if(success) {
                     isExportCompleted = true;
                     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_EXPORT_COMPLETED
                                                                         object:self];
                 }
             }
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Export Failed");
                 NSLog(@"ExportSessionError: %@", [_assetExport.error localizedDescription]);
                 //export error (see exportSession.error)
                 [self combineDisclaimer:recordContentName];
                 break;
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Export Failed");
                 NSLog(@"ExportSessionError: %@", [_assetExport.error localizedDescription]);
                 //export cancelled
                 [self combineDisclaimer:recordContentName];
                 break;
         }
         [disclaimerAsset release];
         [videoAsset release];
         [_assetExport release];
         [disclaimerURL release];
         [videoURL release];
     }];
}

/*
 * Method name: isRecording
 * Description: Returns VU recording status
 * Parameters: nil
 * Return Type: BOOL - recording status
 */
-(BOOL) isRecording {
    return recording;
}

/*
 * Method name: isRecordingAudio
 * Description: Returns Audio recording status
 * Parameters: nil
 * Return Type: BOOL - recording status
 */
-(BOOL) isRecordingAudio {
    return recordingAudio;
}

/*
 * Method name: isRecordingVideo
 * Description: Returns Video recording status
 * Parameters: nil
 * Return Type: BOOL - recording status
 */
-(BOOL) isRecordingVideo {
    return recordingVideo;
}


/*
 * Method name: cleanupWriter
 * Description: Releases all the AVFoundation variables intialized for creating VU Content
 * Parameters: nil
 * Return Type: nil
 */
- (void) cleanupWriter {
    elapsedTime = 0;
	[avAdaptor release];
	avAdaptor = nil;
	
	[videoWriterInput release];
	videoWriterInput = nil;
	
	[videoWriter release];
	videoWriter = nil;
	
	[startedAt release];
	startedAt = nil;
}

/*
 * Method name: getCurrentlyCapturedScreen
 * Description: Returns the currently captured screen image
 * Parameters: nil
 * Return Type: UIImage - Image of the current screen captured
 */
-(UIImage *) getCurrentlyCapturedScreen {
    return self.currentScreen;
}

- (void)dealloc {
	[super dealloc];
}

@end