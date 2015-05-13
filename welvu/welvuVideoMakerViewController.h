//
//  welvuVideoMakerViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 09/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MessageUI.h>
#import <CoreGraphics/CoreGraphics.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "welvuSettingsMasterViewController.h"
#import "CaptureView.h"
#import "DrawingToolView.h"
#import "ProcessingSpinnerView.h"
#import "welvuTopicViewController.h"
#import "welvuShareVUContentViewController.h"
#import "welvuReplayVUContentViewController.h"
#import "GestureControlView.h"
#import "welvu_settings.h"
#import "welvu_history.h"
#import "welvu_specialty.h"
#import "KSCustomPopoverBackgroundView.h"
#import "welvuShareViewController.h"
#import "welvuYouViewController.h"
#import "welvuiPxShareViewController.h"
//EMR
#import "Reachability.h"
#import "ELCAlbumPickerViewController.h"
@class SyncDataToCloud;
@class welvuMasterViewController;
@class welvuVideoMakerViewController;
@class welvuiPxShareViewController;
/*
 * Protocol name: welvuVideoMakerViewControllerDelegate
 * Description: Delegate function for returning welvu video
 */
@protocol welvuVideoMakerViewControllerDelegate
- (void)welvuVideoMakerViewControllerDidFinish:(welvuVideoMakerViewController*)welvuVideoMakerView;
- (void)userLoggedOutFromVideoMakerController;
-(void)userSwitchWelVUFromVideoMakerController;
@end
/*
 * Class name: welvuVideoMakerViewController
 * Description: Has functionality FOR CREATEVU
 * Extends: UIViewController
 * Delegate :UIAlertViewDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate,  MFMailComposeViewControllerDelegate,UITextFieldDelegate,UIScrollViewDelegate
 */
@interface welvuVideoMakerViewController : UIViewController <UIAlertViewDelegate,
UIPopoverControllerDelegate, UINavigationControllerDelegate,
MFMailComposeViewControllerDelegate, welvuTopicViewControllerDelegate,
shareVUContentViewControllerDelegate, SettingsMasterViewControllerDelegate,
replayVUContentDelegate, UIScrollViewDelegate, GestureControlViewrDelegate,
welvuShareViewDelegate,ELCImagePickerControllerDelegate,UITextFieldDelegate,welvuYouViewControllerDelegate,
shareVUContentPlatformHelperDelegate> {
    welvuAppDelegate *appDelegate;
    id <welvuVideoMakerViewControllerDelegate> delegate;
    BOOL suspendedWhileFusingVideo;
    //Annotation
    IBOutlet DrawingToolView *annotateView;
    //Video Maker
    IBOutlet CaptureView *captureView;
    //Gesture View
    IBOutlet GestureControlView *gestureView;
    UIView *overlay;
    //Locally generated variable
    NSMutableArray *imageGallery;
    IBOutlet UIScrollView *imagesVUScrollView;
    IBOutlet UIImageView *themeLogo;
    
    UILabel *notificationLable;
    //Topbar Buttons
    IBOutlet UIButton *shareBtn;
    IBOutlet UIButton *playBtn;
    IBOutlet UIButton *pauseBtn;
    IBOutlet UIButton *recordBtn;
    IBOutlet UIButton *settingsBtn;
    IBOutlet UIButton *feedbackBtn;
    IBOutlet UIButton *youtubeBtn;
    IBOutlet UIButton *guideBtn;
    //Toolbar Buttons
    IBOutlet UIButton *annotationPencilBtn;
    IBOutlet UIButton *annotationArrowBtn;
    IBOutlet UIButton *annotationTextViewBtn;
    IBOutlet UIButton *annotationSquareBtn;
    IBOutlet UIButton *annotationCircleBtn;
    IBOutlet UIButton *annotationClearBtn;
    IBOutlet UIButton *zoomBtn;
    IBOutlet UIButton *redColorBtn;
    IBOutlet UIButton *blueColorBtn;
    IBOutlet UIButton *yellowColorBtn;
    IBOutlet UIButton *blackColorBtn;
    IBOutlet UIButton *whiteColorBtn;
    
    //Video VU player controls
    IBOutlet UIView *videoVUControlView;
    IBOutlet UIButton *playVideoBtn;
    IBOutlet UIButton *stopVideoBtn;
    IBOutlet UIButton *repeatVideoBtn;
    
    //Recording animation text
    ProcessingSpinnerView *spinner;
    
    //Settings popOver
    UIPopoverController *popOver;
    //BOOL justNow;
    
    CABasicAnimation *pulseAnimation;
    //Gesture controls
    UITapGestureRecognizer *enable_disableAnnotation;
    UISwipeGestureRecognizer *swipeRight;
    UISwipeGestureRecognizer *swipeLeft;
    
    //Fade effect
    IBOutlet UIView *_topFadingView;
    IBOutlet UIView *_bottomFadingView;
    BOOL deletedHistory;
    BOOL swapHistory;
    BOOL historyAdded;
    int update;
    
    
    NSInteger albumAddedCount;
    
    //animation
    IBOutlet UIImageView *imageToMove;
    IBOutlet UIView *myView;
    
    IBOutlet UIImageView *animatedButton;
    IBOutlet UIImageView *animatedButtonStop;
    BOOL isAnimationStarted;
    welvu_user *welvuUserModel;
    
    //EMR
    BOOL networkReachable;
    Reachability *internetReach;
    Reachability *hostReach;
    
    //IPX
    welvuiPxShareViewController *shareIpxContents;
    IBOutlet UIButton *ipxBtn;
    
    //HEV
    IBOutlet UIButton *saveBtn;;
    IBOutlet UIButton *boxBtn;
    
}
@property (nonatomic,assign) int update;
@property (nonatomic,assign) BOOL deletedHistory;
@property (nonatomic,assign) BOOL swapHistory;
@property (nonatomic,assign) BOOL historyAdded;
@property (strong,nonatomic) IBOutlet UIImageView *themeLogo;
@property (strong,nonatomic) UILabel *notificationLable;
//Assigning the property for the delegate object
@property (retain) id <welvuVideoMakerViewControllerDelegate> delegate;

//Annotation
@property (strong, nonatomic) IBOutlet UIImageView *detailImageView;

//Grouping Images and ScrollView
@property (nonatomic, retain) NSMutableArray *imageGallery;
@property (nonatomic, retain) IBOutlet UIScrollView *imagesVUScrollView;

//Fade effect
@property (nonatomic, retain) UIView *topFadingView;
@property (nonatomic, retain) UIView *bottomFadingView;

- (id)initWithImageGroup:(NSString *)nibNameOrNil
                  bundle:(NSBundle *)nibBundleOrNil images:(NSMutableArray *)patientVUImages
              imageCount:(NSInteger) imageCt;

//Top Bar action
- (IBAction)settingsBtnClicked:(id)sender;
- (IBAction)feedBackBtnClicked:(id)sender;
- (IBAction)recordBtnClicked:(id)sender;
- (IBAction)playBtnClicked:(id)sender;
- (IBAction)topicsImagePickerBtnClicked:(id)sender;
- (IBAction)blankImagedClickedV:(id)sender;
- (IBAction)recordBtnClicked:(id)sender;
- (IBAction)pause_continueBtnClicked:(id)sender;
- (IBAction)shareBtnClicked:(id)sender;
- (IBAction)closeBtnClicked:(id)sender;
- (IBAction)informationBtnClicked:(id)sender;
- (IBAction)closeOverlay:(id)sender;

//Tools action buttons
- (IBAction)zoomBtnClicked:(id)sender;
- (IBAction)enable_disableAnnotationBtnClicked:(id)sender;
- (IBAction)annotationTextBtnClicked:(id)sender;
- (IBAction)arrowBtnClicked:(id)sender;
- (IBAction)circlebtnclicked:(id)sender;
- (IBAction)squarebtnclicked:(id)sender;
- (IBAction)undoAnnotationBtnClicked:(id)sender;
- (IBAction)redoAnnotationBtnClicked:(id)sender;
- (IBAction)changeColorBtnClicked:(id)sender;
- (IBAction)clearAnnotationBtnClicked:(id)sender;
- (void)disable_enableTools:(BOOL)enable;
//Video VU player controls
- (void)showVideoControl:(BOOL)visible;
- (IBAction)playVideoBtnClicked:(id)sender;
- (IBAction)stopVideoBtnClicked:(id)sender;
- (IBAction)repeatVideoBtnClicked:(id)sender;
- (IBAction)youTubeButtonClicked:(id)sender;
- (IBAction)albumButtonClicked:(id)sender;

- (UIImage *)generateImageFromVideo:(NSString *)pathString:(NSString *)pathType;

- (IBAction)screenShotBtnClicked:(id)sender;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)animatedAssitance;
- (void)assitanceguidence;

//EMR
- (void) shareContentVU:(NSString *) path;

//IPX
-(IBAction)ipxBtnClicked:(id)sender;
-(void)shareiPxwithPath :(NSString *) path;


//HEV
- (IBAction)saveToAlbumBtnClicked:(id)sender;
@end
