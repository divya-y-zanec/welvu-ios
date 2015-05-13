//
//  CaptureView.h
//  welvu
//
//  Created by Logesh Kumaraguru on 11/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
/*
 * Class name: CaptureView
 * Description: Interface to capture Audio and Video from the iPhone/iPad Screen
 * Extends: UIView
 * Delegate: AVCaptureAudioDataOutputSampleBufferDelegate
 */
@interface CaptureView : UIView <AVCaptureAudioDataOutputSampleBufferDelegate>{
    
    float frameRate;
    NSString *videoResolutionChoice;
    
    //video writing
	AVAssetWriter *videoWriter;
	AVAssetWriterInput *videoWriterInput;
	AVAssetWriterInputPixelBufferAdaptor *avAdaptor;
    
    //Audio recording instance
    AVAudioRecorder *audioRecorder;
    
    
    //recording state
	BOOL recording;
    BOOL recordingPaused;
    BOOL recordingAudio;
    BOOL recordingVideo;
    BOOL isExportCompleted;
    
    NSInteger audio_videoChoiceSelected;
    
    NSDate *startedAt;
    float elapsedTime;
    
    BOOL touchBeganFlag;
    BOOL continuosAnnotation;
    BOOL vuModifiedFlag;
    NSDictionary *videoCompressionProps;
}
//Property
@property (nonatomic,retain) NSDictionary *videoCompressionProps;
@property (nonatomic, retain) UIImage *currentScreen;
@property (nonatomic, retain) UIImage *annotatedCapturedScreen;
@property (assign) float frameRate;
@property (nonatomic, retain) NSString *videoResolutionChoice;
@property (nonatomic, readwrite) BOOL isExportCompleted;
@property (nonatomic, readwrite) BOOL touchBeganFlag;
@property (nonatomic, readwrite) BOOL vuModifiedFlag;

@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) IBOutlet UIView *playerView;
@property (nonatomic, retain) IBOutlet UISlider *playerSliderView;
@property (nonatomic, retain) IBOutlet UILabel *playBackTime;

//To refresh slider based video current duration
- (void)refreshPlayerSlider;

//VU Settings
- (void)modifyFrameRate:(float) fpsChoice;
- (void)modifyVideoResolutionOption:(NSInteger) choice;
- (void)modigyAudio_VideoSettings:(NSInteger) choice;
- (NSInteger)audio_videoChoiceSettings;
- (void) vuModified;

//MPView intialization and releasing
- (void)intializeVideoPreviewContent;
- (void)removeVideoPreviewContent;
- (void)releaseVideoPreviewContent;

//Recording video
- (void)startRecording:(NSString *)recordContentName;
- (void)pauseRecording;
- (void)continueRecording;
- (void)stopRecording:(NSString *)recordContentName;

//For recording Audio
- (void)startAudioRecording:(NSString *)recordContentName;
- (void)stopAudioRecording;

//Suspend recording
- (void)suspendRecording;

- (void)combineVideoAudio:(NSString *)recordContentName videoVUId:(NSInteger) videoVUId;
- (void)combineDisclaimer:(NSString *)recordContentName videoVUId:(NSInteger) videoVUId;

- (void)completeRecordingSession:(NSString *)recordContentName ;
//To check whether content recording started
- (BOOL)isRecording;
- (BOOL)isRecordingAudio;
- (BOOL)isRecordingVideo;

//To release obtained resources
- (void)cleanupWriter;

//To fetch the screen shot to retain the Annotation
- (UIImage *)getCurrentlyCapturedScreen;

@end
