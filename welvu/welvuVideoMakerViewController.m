//
//  welvuVideoMakerViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 09/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "welvuVideoMakerViewController.h"
#import "welvuTopicViewController.h"
#import "UIImage+Resize.h"
#import "welvu_images.h"
#import "welvu_alerts.h"
#import "welvu_settings.h"
#import "GAI.h"
#import "welvuShareViewController.h"
#import "welvuContants.h"
#import "welvuYouViewController.h"
#import "NSFileManagerDoNotBackup.h"
#import "ReceiptCheck.h"
#import "VerticalAlertView.h"
#import "welvu_video.h"
//IPX
#import "welvuiPxShareViewController.h"

@interface welvuVideoMakerViewController ()

@property (nonatomic) DrawingToolView * canvas;
-(void) buildImageGroups;
-(void) loadImageToCanvas:(welvu_images *)welvu_imagesModel;
-(void) removeDeckImages;
-(UIImage *) getThumbnailImage:(UIImage *) originalImage;
-(void) retainAnnotatedImage:(NSInteger) currentImageNumber;
-(void) clearAnnotationFromImage:(NSInteger) currentImageNumber;
-(void) setZoomToNormal;
-(void)textView:(UITouch*)touches:(UIEvent *)event;
//Sharing & saving
-(NSString *) getRecordContentName;
-(void) doYouWantShareToEMR_playAlert;
-(void) doYouWantShare_playAlert;
-(void) displayComposerSheet:(NSString *)path;
-(void) shareVUContentWithPath:(NSString *)path;
-(void) replayViewBtnClicked:(NSString *)path;
-(void)assitanceguidence;
@end

@implementation welvuVideoMakerViewController
@synthesize delegate,imageGallery, imagesVUScrollView;
@synthesize detailImageView = _detailImageView;
@synthesize deletedHistory,swapHistory,historyAdded,update, themeLogo,notificationLable;

int currentImage = 0;
int prevImage = 0;
BOOL didReceiveMemoryWarningFlag = false;

/*
 * Method name: initWithNibName
 * Description: display the view
 * Parameters: bundle
 * return self
 */

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
 * Method name: initWithImageGroup
 * Description: initlizae with group of images
 * Parameters: bundle ,patientVUImages ,imageCt
 * return id
 */
- (id)initWithImageGroup:(NSString *)nibNameOrNil bundle
                        :(NSBundle *)nibBundleOrNil images:(NSMutableArray *) patientVUImages imageCount:(NSInteger) imageCt {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.imageGallery =  patientVUImages;
        currentImage = 0;
        prevImage = 0;
        suspendedWhileFusingVideo = false;
        albumAddedCount = imageCt;
    }
    
    return self;
}


#pragma mark - View lifecycle
//LOAD THE VIEW
- (void)viewDidLoad {
    [super viewDidLoad];
   // DrawingToolView * smoothLineView =[[DrawingToolView alloc] initWithFrame:self.view.bounds ];
    self.canvas = annotateView;
    
    
    NSMutableArray *animatedImages = [[NSMutableArray alloc] initWithCapacity:2];
    [animatedImages addObject:[UIImage imageNamed:@"recordGreenIcon.png"]];
    [animatedImages addObject:[UIImage imageNamed:@"recordGreenIcon2.png"]];
    
    animatedButton =  [[UIImageView alloc] initWithFrame:CGRectMake(0,0,55,56)];
    //animatedButton.hidden = true;
    animatedButton.animationImages = animatedImages;
    animatedButton.animationDuration = 1;
    [recordBtn addSubview:animatedButton];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL *guideAnimation = [defaults boolForKey:@"guideAnimationOn"];
    
    if(guideAnimation)
    {
        isAnimationStarted = TRUE;
        [self flashOn:animatedButton];
    } else {
        isAnimationStarted  = FALSE;
    }
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    //Declaring Page View Analytics
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Video-Maker-PatientVU - VM"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PatientvuWithBanner.png"]];
    [self themeSettingsViewControllerDidFinish];
    imagesVUScrollView.delegate = self;
    self.topFadingView.hidden = true;
    self.bottomFadingView.hidden = true;
    //Disable Share btn by default
    shareBtn.enabled = false;
    youtubeBtn.enabled=false;
    playBtn.enabled = false;
    pauseBtn.enabled = false;
    repeatVideoBtn.selected = true;
    ipxBtn.enabled = false;
    saveBtn.enabled = false;
    //Enable Annotation on loading the view and set the default color
    [annotateView isLineDrawingEnabled:false];
    [annotateView setStrokeColor:[UIColor redColor]];
    redColorBtn.selected = true;
    // One finger, two taps to enable/disable annotation
	// Create gesture recognizer, notice the selector method
    enable_disableAnnotation = [[UITapGestureRecognizer alloc]
                                initWithTarget:self action:@selector(enable_disableAnnotationBtnClicked:)];
    
    // Set required taps and number of touches
    [enable_disableAnnotation setNumberOfTapsRequired:2];
    //[enable_disableAnnotation setNumberOfTouchesRequired:1];
    [captureView addGestureRecognizer:enable_disableAnnotation];
    
    //
    // Two finger, swipe up
	//
    swipeRight = [[UISwipeGestureRecognizer alloc]
                  initWithTarget:self action:@selector(swipeImageRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [captureView addGestureRecognizer:swipeRight];
    
	//
	// Two finger, swipe down
	//
    swipeLeft = [[UISwipeGestureRecognizer alloc]
                 initWithTarget:self action:@selector(swipeImageLeft:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [captureView addGestureRecognizer:swipeLeft];
    
    //Intialize gestures
    [gestureView initializeGestureWithMasterView:captureView];
    [gestureView viewModificationGestureEnable:false];
    gestureView.delegate = self;
    
    [self buildImageGroups];
    
    [captureView modigyAudio_VideoSettings:((welvu_settings *)appDelegate.currentWelvuSettings).audio_video];
    [captureView modifyVideoResolutionOption:((welvu_settings *)appDelegate.currentWelvuSettings).fps];
    //[captureView modifyVideoResolutionOption:30];
    //Notification when app enters background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInBackground:) name:@"AppDidEnterBackground" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:) name:@"AppDidBecomeActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onExportCompleted:) name:NOTIFY_EXPORT_COMPLETED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinished:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:captureView.moviePlayer];
    
    
    // NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OPENEMR]) {
        
        ipxBtn.hidden = YES;
        
        guideBtn.frame= CGRectMake(725, guideBtn.frame.origin.y, guideBtn.frame.size.width, guideBtn.frame.size.height);
        
        recordBtn.frame =CGRectMake(782, recordBtn.frame.origin.y, recordBtn.frame.size.width, recordBtn.frame.size.height);
        
        imageToMove.frame =CGRectMake(784, imageToMove.frame.origin.y, imageToMove.frame.size.width, imageToMove.frame.size.height);
        
        pauseBtn.frame =CGRectMake(829, pauseBtn.frame.origin.y, pauseBtn.frame.size.width, pauseBtn.frame.size.height);
        
        
        
        playBtn.frame =CGRectMake(883, playBtn.frame.origin.y, playBtn.frame.size.width, playBtn.frame.size.height);
        
        
        
        shareBtn.frame =CGRectMake(928, shareBtn.frame.origin.y, shareBtn.frame.size.width, shareBtn.frame.size.height);
        
        
    } else if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_HEV]) {
        
        
        saveBtn.hidden = NO;
        guideBtn.frame= CGRectMake(615, guideBtn.frame.origin.y, guideBtn.frame.size.width, guideBtn.frame.size.height);
        
        
        recordBtn.frame= CGRectMake(669, recordBtn.frame.origin.y, recordBtn.frame.size.width, recordBtn.frame.size.height);
        
        imageToMove.frame= CGRectMake(671, imageToMove.frame.origin.y, imageToMove.frame.size.width, imageToMove.frame.size.height);
        
        pauseBtn.frame =CGRectMake(725, pauseBtn.frame.origin.y, pauseBtn.frame.size.width, pauseBtn.frame.size.height);
        
        playBtn.frame =CGRectMake(784, playBtn.frame.origin.y, playBtn.frame.size.width, playBtn.frame.size.height);
        
        
        
        shareBtn.frame =CGRectMake(829, shareBtn.frame.origin.y, shareBtn.frame.size.width, shareBtn.frame.size.height);
        
        
        
        ipxBtn.frame =CGRectMake(883, ipxBtn.frame.origin.y, ipxBtn.frame.size.width, ipxBtn.frame.size.height);
        
        
        
        saveBtn.frame =CGRectMake(928, saveBtn.frame.origin.y, saveBtn.frame.size.width, saveBtn.frame.size.height);
    }     else if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU] || [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_EBOLAVU]) {
            //with youtube
            //ipxBtn.hidden = TRUE;
            boxBtn.hidden = TRUE;
            
            //without youtube
            /* youtubeBtn.hidden = true;
             ipxBtn.hidden = FALSE;
             boxBtn.hidden = TRUE; */
            
            //without youtube
            /* guideBtn.frame= CGRectMake(736, guideBtn.frame.origin.y, guideBtn.frame.size.width, guideBtn.frame.size.height);
             
             recordBtn.frame =CGRectMake(784, recordBtn.frame.origin.y, recordBtn.frame.size.width, recordBtn.frame.size.height);
             
             imageToMove.frame =CGRectMake(786, imageToMove.frame.origin.y, imageToMove.frame.size.width, imageToMove.frame.size.height);
             
             
             
             pauseBtn.frame =CGRectMake(839, pauseBtn.frame.origin.y, pauseBtn.frame.size.width, pauseBtn.frame.size.height);
             
             
             playBtn.frame =CGRectMake(882, playBtn.frame.origin.y, playBtn.frame.size.width, playBtn.frame.size.height);
             
             
             
             
             shareBtn.frame =CGRectMake(928, shareBtn.frame.origin.y, shareBtn.frame.size.width, shareBtn.frame.size.height);
             
             
             
             ipxBtn.frame =CGRectMake(976, ipxBtn.frame.origin.y, ipxBtn.frame.size.width, ipxBtn.frame.size.height); */
            
            //with youtube
            guideBtn.frame= CGRectMake(669, guideBtn.frame.origin.y, guideBtn.frame.size.width, guideBtn.frame.size.height);
            
            
            recordBtn.frame= CGRectMake(723, recordBtn.frame.origin.y, recordBtn.frame.size.width, recordBtn.frame.size.height);
            
            imageToMove.frame= CGRectMake(725, imageToMove.frame.origin.y, imageToMove.frame.size.width, imageToMove.frame.size.height);
            
            // 671 669
            
            pauseBtn.frame =CGRectMake(784, pauseBtn.frame.origin.y, pauseBtn.frame.size.width, pauseBtn.frame.size.height);
            
            
            
            
            playBtn.frame =CGRectMake(839, playBtn.frame.origin.y, playBtn.frame.size.width, playBtn.frame.size.height);
            
            
            shareBtn.frame =CGRectMake(882, shareBtn.frame.origin.y, shareBtn.frame.size.width, shareBtn.frame.size.height);
            
            
            
            ipxBtn.frame =CGRectMake(928, ipxBtn.frame.origin.y, ipxBtn.frame.size.width, ipxBtn.frame.size.height);
            
            
        } if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]) {
            
            ipxBtn.hidden = FALSE;
            
            guideBtn.frame= CGRectMake(669, guideBtn.frame.origin.y, guideBtn.frame.size.width, guideBtn.frame.size.height);
            
            
            recordBtn.frame= CGRectMake(723, recordBtn.frame.origin.y, recordBtn.frame.size.width, recordBtn.frame.size.height);
            
            imageToMove.frame= CGRectMake(725, imageToMove.frame.origin.y, imageToMove.frame.size.width, imageToMove.frame.size.height);
            
            // 671 669
            
            pauseBtn.frame =CGRectMake(784, pauseBtn.frame.origin.y, pauseBtn.frame.size.width, pauseBtn.frame.size.height);
            
            
            
            
            playBtn.frame =CGRectMake(839, playBtn.frame.origin.y, playBtn.frame.size.width, playBtn.frame.size.height);
            
            
            shareBtn.frame =CGRectMake(882, shareBtn.frame.origin.y, shareBtn.frame.size.width, shareBtn.frame.size.height);
            
            
            
            ipxBtn.frame =CGRectMake(928, ipxBtn.frame.origin.y, ipxBtn.frame.size.width, ipxBtn.frame.size.height);
            
            
            
            
        }
        
        else {
           // ipxBtn.hidden = false;
            boxBtn.hidden = TRUE;
        }
    }
    
    


//APPEAR THE VIEW
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(imagesVUScrollView.contentSize.width > imagesVUScrollView.frame.size.width) {
        self.bottomFadingView.hidden = false;
    } else {
        self.bottomFadingView.hidden = true;
    }
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification object:nil];
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    hostReach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    [hostReach startNotifier];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //UIView *notificationView = [[UIView alloc]initWithFrame:CGRectMake(800, 40, 200, 40)];
    
    if(appDelegate.networkReachable) {
        //NSLog(@"network is there");
        [appDelegate checkForConfirmedUser];
        appDelegate.checkOrganizationUserLicense = false;
        [appDelegate checkUserLicense];
        
        
        
    } else {
        //  NSLog(@"network is not there");
    }
    if(currentImage > -1) {
        welvu_images *welvu_imagesModel = (welvu_images *) [imageGallery objectAtIndex:currentImage];
        [self loadImageToCanvas:welvu_imagesModel];
    }
    if ( appDelegate.showGuideCreateVU == 0) {
        [self performSelector:@selector(informationBtnClicked:)withObject:nil];
        appDelegate.showGuideCreateVU = 1;
    }

    
    
}
//UN LOAD THE VIEW
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"AppDidEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"AppDidBecomeActive" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFY_EXPORT_COMPLETED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

-(void)viewDidDisappear:(BOOL)animated {
    [notificationLable setAlpha:0.0];
    [super viewDidDisappear:animated];
    if(captureView.moviePlayer != nil) {
        [captureView releaseVideoPreviewContent];
    }
}


#pragma mark Action Methods
-(void)buildImageGroups {
    CGRect frame;
    for(int i = 0; i < imageGallery.count; ++i) {
        welvu_images *welvu_imagesModel = [imageGallery objectAtIndex:i];
        
        UIImage *thumbnail = nil;
        if (welvu_imagesModel.retainedAnnotatedImageUrl != nil) {
            UIImage *originalImage = nil;
            if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.retainedAnnotatedImageUrl]) {
                NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.retainedAnnotatedImageUrl];
                originalImage = [UIImage imageWithData:imageData];
            }
            thumbnail = [self getThumbnailImage:originalImage];
        }else  if([welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE] || [welvu_imagesModel.type isEqualToString:IMAGE_PATIENT_TYPE] || [welvu_imagesModel.type isEqualToString:IMAGE_PATIENTINFO_TYPE] || [welvu_imagesModel.type isEqualToString:GRAPH_IMAGE_TYPE]||[welvu_imagesModel.type isEqualToString:VIDEO_PATIENT_TYPE]) {
            UIImage *originalImage = nil;
            
            if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
                NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
                originalImage = [UIImage imageWithData:imageData];
            } else {
                originalImage = welvu_imagesModel.imageData;
            }
            thumbnail = [self getThumbnailImage:originalImage];
        } else if([welvu_imagesModel.type isEqualToString:IMAGE_BLANK_TYPE]) {
            
            UIImage *originalImage = [UIImage imageNamed:welvu_imagesModel.url];
            thumbnail = [self getThumbnailImage:originalImage];
        } else if(([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE]
                   || [welvu_imagesModel.type isEqualToString:IMAGE_HISTORY_TYPE])
                  && welvu_imagesModel.imageId > 0) {
            UIImage *originalImage = nil;
            if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
                NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
                originalImage = [UIImage imageWithData:imageData];
            } else {
                originalImage = welvu_imagesModel.imageData;
            }
            thumbnail = [self getThumbnailImage:originalImage];
        } else if([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE]
                  && welvu_imagesModel.imageId == 0) {
            thumbnail = [self getThumbnailImage: welvu_imagesModel.imageData];
        } else if([welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_TYPE]
                  || [welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE]) {
            UIImage *originalImage = [self generateImageFromVideo:welvu_imagesModel.url :welvu_imagesModel.type];
            thumbnail =  [self getThumbnailImage: originalImage];
        }
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        NSInteger padding = 0;
        if(thumbnail.size.width < THUMB_MINI_IMAGE_WIDTH)
        {
            padding = ((THUMB_MINI_IMAGE_WIDTH - thumbnail.size.width)/ 2);
        }
        button.frame = CGRectMake(i* (THUMB_MINI_IMAGE_WIDTH + 10), 5,
                                  THUMB_MINI_IMAGE_WIDTH, THUMB_MINI_IMAGE_HEIGHT);
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((NSInteger)(THUMB_MINI_IMAGE_WIDTH - thumbnail.size.width)/ 2,
                                                                             (NSInteger)(THUMB_MINI_IMAGE_HEIGHT - thumbnail.size.height)/ 2, thumbnail.size.width, thumbnail.size.height)];
        imgView.image = thumbnail;
        imgView.image = [[imgView.image imageWithBorderForUnselected:THUMB_MINI_IMAGE_BORDER] makeRoundCornerImage:5 :5];
        [button addSubview:imgView];
        [button addTarget:self
                   action:@selector(patientVUImagePressed:)
         forControlEvents:UIControlEventTouchUpInside];
        button.tag = (i+1);
        
        [imagesVUScrollView addSubview:button];
        
        frame = button.frame;
    }
    for(UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]) subviews]) {
        if([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)subview;
            imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_MINI_IMAGE_BORDER]
                               makeRoundCornerImage:5 :5];
        }
    }
    [imagesVUScrollView setContentSize:CGSizeMake((frame.origin.x + 80), HORIZONTAL_SCROLL_HEIGHT)];
}
/*
 * Method name: patientVUImagePressed
 * Description: pressing image frompatientVU
 * Parameters: image
 * return ibaction
 * Created On: 19-dec-2012
 */
-(IBAction)patientVUImagePressed:(id)sender {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"patientVU Image"
                                                           label:@"image press in patientVU"
                                                           value:nil] build]];
    
    
    @try {
        [annotateView annotationTextViewConditions];
        [captureView vuModified];
        if(annotateView.isAnnotationStarted) {
            [self retainAnnotatedImage:currentImage];
        }
        [self setZoomToNormal];
        [captureView vuModified];
        UIButton *button = (UIButton *)sender;
        if(currentImage != ([button tag] - 1)) {
            currentImage = ([button tag] - 1);
            ((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]).enabled = true;
            ((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]).enabled = false;
            for(UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]) subviews]) {
                if([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)subview;
                    imageView.image = [[imageView.image imageWithBorderForUnselected:THUMB_MINI_IMAGE_BORDER]  makeRoundCornerImage:5 :5];
                }
            }
            for(UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]) subviews]) {
                if([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)subview;
                    imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_MINI_IMAGE_BORDER]  makeRoundCornerImage:5 :5];
                }
            }
            prevImage = currentImage;
            [annotateView clearScreen];
            welvu_images *welvu_imagesModel = (welvu_images *) [imageGallery objectAtIndex:currentImage];
            [captureView vuModified];
            [self loadImageToCanvas:welvu_imagesModel];
            [captureView vuModified];
        }
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_patientVUImage:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

-(void) checkEnableAnnotation {
    if(annotationPencilBtn.selected || annotationArrowBtn.selected || annotationCircleBtn.selected
       || annotationSquareBtn. selected || annotationTextViewBtn.selected) {
        [enable_disableAnnotation setEnabled:true];
        [swipeLeft setEnabled:false];
        [swipeRight setEnabled:false];
        [annotateView isLineDrawingEnabled:true];
    }
}

-(void)loadImageToCanvas:(welvu_images *)welvu_imagesModel {
    [captureView vuModified];
    [annotateView clearScreen];
    [annotateView annotationTextViewConditions];
    annotateView.isAnnotationStarted = false;
    CGSize destinationSize = CGSizeMake(CANVAS_WIDTH, CANVAS_HEIGHT);
    if(welvu_imagesModel.retainedAnnotatedImageUrl != nil) {
        [captureView removeVideoPreviewContent];
        playVideoBtn.selected = false;
        NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.retainedAnnotatedImageUrl];
        _detailImageView.image = [[[UIImage imageWithData:imageData] resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                  makeRoundCornerImage:5 :5];
        [self disable_enableTools:false];
        [self showVideoControl:false];
        [self checkEnableAnnotation];
    } else if([welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE] || [welvu_imagesModel.type isEqualToString:IMAGE_PATIENT_TYPE]|| [welvu_imagesModel.type isEqualToString:IMAGE_PATIENTINFO_TYPE] || [welvu_imagesModel.type isEqualToString:GRAPH_IMAGE_TYPE]||[welvu_imagesModel.type isEqualToString:VIDEO_PATIENT_TYPE])  {
        [captureView removeVideoPreviewContent];
        playVideoBtn.selected = false;
        if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            _detailImageView.image = [[[UIImage imageWithData:imageData] resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                      makeRoundCornerImage:5 :5];
        } else {
            _detailImageView.image = [[welvu_imagesModel.imageData resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                      makeRoundCornerImage:5 :5];
        }
        [self disable_enableTools:false];
        [self showVideoControl:false];
        [self checkEnableAnnotation];
    }
    
    else if([welvu_imagesModel.type isEqualToString:IMAGE_BLANK_TYPE]) {
        [captureView removeVideoPreviewContent];
        playVideoBtn.selected = false;
        _detailImageView.image =[[UIImage imageNamed:welvu_imagesModel.url]
                                 resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        [self disable_enableTools:false];
        [self showVideoControl:false];
        [self checkEnableAnnotation];
    } else if([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] && welvu_imagesModel.imageId > 0) {
        [captureView removeVideoPreviewContent];
        playVideoBtn.selected = false;
        if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            _detailImageView.image = [[[UIImage imageWithData:imageData] resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                      makeRoundCornerImage:5 :5];
        } else {
            _detailImageView.image = [[welvu_imagesModel.imageData resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                      makeRoundCornerImage:5 :5];
        }
        [self disable_enableTools:false];
        [self showVideoControl:false];
        [self checkEnableAnnotation];
    } else if([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] && welvu_imagesModel.imageId == 0) {
        [captureView removeVideoPreviewContent];
        playVideoBtn.selected = false;
        _detailImageView.image = [[welvu_imagesModel.imageData resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                  makeRoundCornerImage:5 :5];
        [self disable_enableTools:false];
        [self showVideoControl:false];
        [self checkEnableAnnotation];
    } else if([welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_TYPE]
              || [welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE]) {
        [self disable_enableTools:true];
        [annotateView isLineDrawingEnabled:false];
        [self showVideoControl:true];
        _detailImageView.image = nil;
        captureView.annotatedCapturedScreen = nil;
        if(captureView.moviePlayer == nil) {
            //  NSLog(@"Intialized Movie Player");
            [captureView intializeVideoPreviewContent];
            
        } else {
            captureView.moviePlayer.view.hidden = false;
        }
        NSURL *theContentURL;
        if(![[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            NSBundle *bundle = [NSBundle mainBundle];
            NSArray *nameAndType = [welvu_imagesModel.url componentsSeparatedByString: @"."];
            NSString *moviePath = [bundle pathForResource:[nameAndType objectAtIndex:0] ofType:[nameAndType objectAtIndex:1]];
            theContentURL = [NSURL fileURLWithPath:moviePath];
        } else {
            theContentURL = [NSURL fileURLWithPath:welvu_imagesModel.url];
        }
        [captureView.moviePlayer setUseApplicationAudioSession:NO];
        [captureView.moviePlayer setContentURL:theContentURL];
        [captureView.moviePlayer prepareToPlay];
        [captureView.moviePlayer play];
        playVideoBtn.selected = true;
        [captureView.playerSliderView setMinimumValue:0];
        [captureView.playerSliderView setValue:0];
    }
    [captureView vuModified];
}

-(void) removeDeckImages {
    [annotateView annotationTextViewConditions];
    
    for(UIView *subview in [imagesVUScrollView subviews]) {
        if([subview isKindOfClass:[UIButton class]]) {
            [subview removeFromSuperview];
        }
    }
}

/*
 * Method name: blankImagedClickedV
 * Description: to click blank image
 * Parameters: id
 * return ibaction
 * Created On: 19-dec-2012
 */
-(IBAction)blankImagedClickedV:(id)sender{
    [annotateView annotationTextViewConditions];
    if(annotateView.isAnnotationStarted) {
        [self retainAnnotatedImage:(prevImage)];
        [annotateView clearScreen];
        annotateView.hidden = true;
        [self setZoomToNormal];
    }
    [self removeDeckImages];
    //Declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"blank Image - VM"
                                                           label:@"Blank"
                                                           value:nil] build]];
    
    
    
    @try {
        [self popoverControllerDidDismissPopover:popOver];
        NSDate *date = [NSDate date];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = YEAR_MONTH_DATE_TIME_FORMAT;
        
        welvu_images * blankCanvas = [[welvu_images alloc] initWithImageId:++albumAddedCount];
        blankCanvas.imageDisplayName = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
        blankCanvas.type= IMAGE_BLANK_TYPE;
        
        switch (((welvu_settings *)appDelegate.currentWelvuSettings).welvu_blank_canvas_color) {
            case SETTING_BLANK_CANVAS_COLOR_WHITE:
                blankCanvas.url = @"blankCanvas.png";
                break;
            case SETTING_BLANK_CANVAS_COLOR_BLACK:
                blankCanvas.url = @"blankCanvasblack";
                break;
            case SETTING_BLANK_CANVAS_COLOR_GREEN:
                blankCanvas.url = @"blankCanvasGreen1";
                break;
            default:
                break;
        }
        
        currentImage = currentImage + 1;
        [imageGallery insertObject: blankCanvas atIndex:currentImage];
        [self buildImageGroups];
        [self loadImageToCanvas:blankCanvas];
        prevImage = currentImage;
        [captureView vuModified];
        [self performSelector:@selector(perFormVUModified) withObject:nil afterDelay:0.5];
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Blank:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

-(void) perFormVUModified {
    [captureView vuModified];
    annotateView.hidden = false;
}


-(void)assitanceguidence {
    //  NSLog(@"animated guidenece");
}

-(void)animatedAssitance {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL *guideAnimation = [defaults boolForKey:@"guideAnimationOn"];
    
    [defaults synchronize];
    if(appDelegate.currentWelvuSettings.isAnimationOn) {
        
        if(isAnimationStarted)
        {
            // NSLog(@"animation started");
        }
        else
        {
            isAnimationStarted = TRUE;
            [self flashOn:animatedButton];
            
            
        }
    }
    else
    {
        isAnimationStarted = FALSE;
        [self flashOff:animatedButton];
    }
}

/*
 * Method name: recordBtnClicked
 * Description: Record the annotated Video.
 * Parameters: sender
 * return IBAction
 */

-(IBAction)recordBtnClicked:(id)sender {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Record Button - VM"
                                                           label:@"Record"
                                                           value:nil] build]];
    
    
    
    
    @try {
        //[recordBtn animationDidStop:nil finished:nil];
        
        [annotateView annotationTextViewConditions];
        
        [self popoverControllerDidDismissPopover:popOver];
        if(!recordBtn.selected) {
            //k'o [self flashOn:animatedButton];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            BOOL *guideAnimation = [defaults boolForKey:@"guideAnimationOn"];
            
            [defaults synchronize];
            
            if(guideAnimation) {
                
                NSMutableArray *animatedImages = [[NSMutableArray alloc] initWithCapacity:2];
                [animatedImages addObject:[UIImage imageNamed:@"stopRedIcon.png"]];
                [animatedImages addObject:[UIImage imageNamed:@"stopRedIcon2.png"]];
                animatedButton.animationImages = animatedImages;
                [self flashOn:animatedButton];
                
            }
            
            
            //[self removeLastRecordedVideo];
            recordBtn.selected = true;
            pauseBtn.enabled = true;
            shareBtn.enabled = false;
            youtubeBtn.enabled=false;
            playBtn.enabled = false;
            settingsBtn.enabled = false;
            feedbackBtn.enabled = false;
            ipxBtn.enabled = false;
            appDelegate.recordCounter = [self createNewWelvuVideoQueue];
            welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                                  queueId:appDelegate.recordCounter];
            [[NSUserDefaults standardUserDefaults] setObject:[self getRecordContentName]
                                                      forKey:@"lastRecorded"];
            
            [captureView startRecording:welvuVideoModel.generic_file_name];
            if(!captureView.moviePlayer.view.hidden) {
                [captureView.moviePlayer play];
                playVideoBtn.selected = true;
            }
            welvuVideoModel = nil;
        } else {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            BOOL *guideAnimation = [defaults boolForKey:@"guideAnimationOn"];
            
            [defaults synchronize];
            if(guideAnimation) {
                
                NSMutableArray *animatedImages = [[NSMutableArray alloc] initWithCapacity:2];
                [animatedImages addObject:[UIImage imageNamed:@"recordGreenIcon.png"]];
                [animatedImages addObject:[UIImage imageNamed:@"recordGreenIcon2.png"]];
                animatedButton.animationImages = animatedImages;
                [self flashOn:animatedButton];
                
            }
            saveBtn.enabled = true;
            ipxBtn.enabled = true;
            shareBtn.enabled = true;
            youtubeBtn.enabled=true;
            playBtn.enabled = true;
            settingsBtn.enabled = true;
            feedbackBtn.enabled = true;
            pauseBtn.enabled = false;
            pauseBtn.selected = false;
            recordBtn.selected = false;
            welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                                  queueId:appDelegate.recordCounter];
            [captureView stopRecording:welvuVideoModel.video_file_name];
            
            [welvu_video updateVideoQueueStatus:[appDelegate getDBPath] videoVUId:welvuVideoModel.welvu_video_id
                                         status:WELVU_RECORD_STATUS_STOPED];
            
            if([captureView isRecordingAudio] && [captureView isRecordingVideo] && !suspendedWhileFusingVideo) {
                [captureView combineVideoAudio:welvuVideoModel.generic_file_name videoVUId:welvuVideoModel.welvu_video_id];
            } else if(![captureView isRecordingAudio] && [captureView isRecordingVideo]){
                [captureView combineDisclaimer:welvuVideoModel.generic_file_name videoVUId:welvuVideoModel.welvu_video_id];
            }
            [self performCombineVideo];
            
            
            if(!captureView.moviePlayer.view.hidden) {
                [captureView.moviePlayer stop];
                [captureView.moviePlayer prepareToPlay];
                playVideoBtn.selected = false;
            }
            welvuVideoModel = nil;
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Record:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
    }
    
}

-(void)removeLastRecordedVideo {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"lastRecorded"]) {
        NSString *path = [NSString  stringWithFormat:@"%@/%@AV.%@",
                          DOCUMENT_DIRECTORY,
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"lastRecorded"],HTTP_ATTACHMENT_VIDEO_EXT_KEY];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        path = [NSString  stringWithFormat:@"%@/%@V.%@",
                DOCUMENT_DIRECTORY,
                [[NSUserDefaults standardUserDefaults] objectForKey:@"lastRecorded"],HTTP_ATTACHMENT_VIDEO_EXT_KEY];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        path = [NSString  stringWithFormat:@"%@/%@A.caf",
                DOCUMENT_DIRECTORY,
                [[NSUserDefaults standardUserDefaults] objectForKey:@"lastRecorded"],HTTP_ATTACHMENT_VIDEO_EXT_KEY];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastRecorded"];
    }
}

-(void) performCombineVideo {
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(!appDelegate.isExportInProcess) {
        if(spinner != nil) {
            [spinner removeSpinner];
            spinner = nil;
        }
        captureView.isExportCompleted = false;
        appDelegate.isExportInProcess = true;
        
        if (appDelegate.currentPatientInfo == nil) {
            //[self performSelector:@selector(doYouWantShare_playAlert)];
            [self userEmailConformed];
        }else{
            [self performSelector:@selector(doYouWantShareToEMR_playAlert)];
        }
    } else {
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view];
        }
        [self performSelector:@selector(performCombineVideo) withObject:nil afterDelay:1];
    }
}

/*
 * Method name: onExportCompleted
 * Description: export completed as mail
 * Parameters: <#parameters#>
 * return ibaction
 * Created On: 19-dec-2012
 */
-(IBAction)onExportCompleted:(id)sender {
    //Declaring Event Tracking Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"on Export Completion"
                                                           label:@"export email"
                                                           value:nil] build]];
    
    
    
    
    @try {
        appDelegate.isExportInProcess = false;
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_onExportCompleted:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
/*
 * Method name: pause_continueBtnClicked
 * Description: pause continue when annotation works
 * Parameters: UIButton
 * return IBAction
 * Created On: 19-dec-2012
 */
-(IBAction)pause_continueBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Pause/Continue Button - VM"
                                                           label:@"Pause/Continue"
                                                           value:nil] build]];
    
    
    
    
    @try {
        UIButton *button = (UIButton *)sender;
        if(button.selected) {
            button.selected = false;
            [captureView continueRecording];
            if(captureView.moviePlayer == nil || captureView.moviePlayer.view.hidden == true) {
                [self disable_enableTools:false];
            } else {
                [self disable_enableTools:true];
            }
        } else {
            button.selected = true;
            [captureView pauseRecording];
            playVideoBtn.selected = false;
            [self disable_enableTools:false];
            [annotateView isLineDrawingEnabled:true];
            if(captureView.moviePlayer != nil) {
                [captureView.moviePlayer pause];
                zoomBtn.enabled = false;
            }
            
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Pause/Continue:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}



/*
 * Method name: playBtnClicked
 * Description: to play the video annotatiojn
 * Parameters: play
 * return ibaction
 * Created On: 19-dec-2012
 */
-(IBAction)playBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Play Button - VM"
                                                           label:@"Play"
                                                           value:nil] build]];
    
    
    
    @try {    NSString *path = nil;
        welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                              queueId:appDelegate.recordCounter];
        if([captureView isRecordingAudio] && [captureView isRecordingVideo]) {
            path = [NSString  stringWithFormat:@"%@/%@",
                    CACHE_DIRECTORY, welvuVideoModel.av_file_name];
        } else if(![captureView isRecordingAudio] && [captureView isRecordingVideo]) {
            path = [NSString  stringWithFormat:@"%@/%@",
                    CACHE_DIRECTORY, welvuVideoModel.video_file_name];
        }
        
        /*
         if(captureView.moviePlayer != nil) {
         [captureView.moviePlayer stop];
         playVideoBtn.selected = false;
         }
         */
        
        [self replayViewBtnClicked:path];
        welvuVideoModel = nil;
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Play:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

/*
 * Method name: shareBtnClicked
 * Description: to share the content
 * Parameters: <#parameters#>
 * return ibaction
 * Created On: 19-dec-2012
 */

-(IBAction)shareBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Share Button - VM"
                                                           label:@"Share"
                                                           value:nil] build]];
    
    
    
    @try {
             [self userEmailConformed];
        
        //[self performSelector:@selector(doYouWantShare_playAlert)];
    }
    
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Share:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

/*
 * Method name: youTubeButtonClicked
 * Description: to share the video using youtube
 * Parameters: id
 * return IBAction
 */
-(IBAction)youTubeButtonClicked:(id)sender
{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"YouTubeShare - VM"
                                                           label:@"YouTube"
                                                           value:nil] build]];
    
    
    
    BOOL validateSubscription = [self checkSubscriptionFeasibility];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger shareCount = [userDefaults integerForKey:[NSString stringWithFormat:@"Specialty_%d", appDelegate.specialtyId]];
    
    if((!validateSubscription && (shareCount < FREE_SHARE_MAX_ALLOWED))
       || validateSubscription) {
        if (appDelegate.networkReachable) {
            if(!validateSubscription) {
                shareCount++;
                [[NSUserDefaults standardUserDefaults] setInteger:shareCount forKey:[NSString stringWithFormat:@"Specialty_%d", appDelegate.specialtyId]];
            }
            NSString *path = nil;
            welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                                  queueId:appDelegate.recordCounter];
            if([captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                path = [NSString  stringWithFormat:@"%@/%@",
                        CACHE_DIRECTORY, welvuVideoModel.av_file_name];
            } else if(![captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                path = [NSString  stringWithFormat:@"%@/%@",
                        CACHE_DIRECTORY, welvuVideoModel.video_file_name];
            }
            
            welvuYouViewController *cont = [[welvuYouViewController alloc]
                                            initWithAttachmentDetails:
                                            ((welvu_settings *)appDelegate.currentWelvuSettings).phiShareVUSubject:
                                            ((welvu_settings *)appDelegate.currentWelvuSettings).phiShareVUSignature:
                                            welvuVideoModel.generic_file_name :path: captureView.isExportCompleted];
            cont.delegate = self;
            UINavigationController *cntrol = [[UINavigationController alloc]
                                              initWithRootViewController:cont];
            [cntrol setNavigationBarHidden:YES];
            cntrol.navigationBar.barStyle = UIBarStyleBlack;
            cntrol.modalPresentationStyle = UIModalPresentationFormSheet;
            cntrol.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentModalViewController:cntrol animated:YES];
            cntrol.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            cntrol.view.superview.frame = CGRectMake(
                                                     // Calcuation based on landscape orientation (width=height)
                                                     ([UIScreen mainScreen].applicationFrame.size.height/2)-(538/2),// X
                                                     ([UIScreen mainScreen].applicationFrame.size.width/2)-(520/2),// Y
                                                     538,// Width
                                                     520// Height
                                                     );
            cntrol.view.superview.backgroundColor = [UIColor clearColor];
            welvuVideoModel = nil;
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                            message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)otherButtonTitles:nil];
            
            [alert show];
        }
    }
}

-(void)canceledYoutubeSharing {
    BOOL validateSubscription = [self checkSubscriptionFeasibility];
    if(!validateSubscription) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger shareCount = [userDefaults integerForKey:
                                [NSString stringWithFormat:@"Specialty_%d", appDelegate.specialtyId  ]];
        shareCount--;
        [userDefaults setInteger:shareCount forKey:[NSString stringWithFormat:@"Specialty_%d", appDelegate.specialtyId]];
    }
}
/*
 * Method name: topicsImagePickerBtnClicked
 * Description: To pick image  from  Topics.
 * Parameters: sender
 * return :IBAction
 */
-(IBAction)topicsImagePickerBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Add VU From Topics - VM"
                                                           label:@"AddVU"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
        if(popOver == nil) {
            welvuTopicViewController *welvuTopicView = [[welvuTopicViewController alloc]
                                                        initWithExistingImagesModel:imageGallery];
            welvuTopicView.delegate = self;
            
            UINavigationController *cntrol = [[UINavigationController alloc] initWithRootViewController:welvuTopicView];
            [cntrol setNavigationBarHidden:YES];
            popOver = [[UIPopoverController alloc] initWithContentViewController:cntrol];
            popOver.delegate = self;
            popOver.popoverBackgroundViewClass = [KSCustomPopoverBackgroundView class];
            [popOver presentPopoverFromRect:((UIButton *) sender).frame
                                     inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_AddVU:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

- (void) welvuTopicViewControllerDidFinish:(welvu_images *)welvu_imagesModel {
    currentImage = currentImage + 1;
    [imageGallery insertObject: welvu_imagesModel atIndex:currentImage];
    [self removeDeckImages];
    [self buildImageGroups];
    [self retainAnnotatedImage:(prevImage)];
    [annotateView clearScreen];
    [self loadImageToCanvas:welvu_imagesModel];
    prevImage = currentImage;
    if(imagesVUScrollView.contentSize.width > imagesVUScrollView.bounds.size.width) {
        CGPoint bottomOffset = CGPointMake(imagesVUScrollView.contentSize.width - imagesVUScrollView.bounds.size.width, 0);
        [imagesVUScrollView setContentOffset:bottomOffset animated:YES];
    }
    [popOver dismissPopoverAnimated:NO];
    popOver = nil;
}
/*
 * Method name: albumButtonClicked
 * Description: To pick image  from  Photo Album.
 * Parameters: sender
 * return :IBAction
 */
-(IBAction) albumButtonClicked:(id)sender {
    //declaring Event Tracking Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Album Button - VM"
                                                           label:@"PhotoAlbum"
                                                           value:nil] build]];
    
    
    
    @try {
        
        if(popOver == nil) {
            ELCAlbumPickerViewController *albumController = [[ELCAlbumPickerViewController alloc]
                                                         initWithNibName:@"ELCAlbumPickerViewController" bundle:[NSBundle mainBundle]];
            ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
            [albumController setParent:elcPicker];
            [elcPicker setDelegate:self];
            
            popOver = [[UIPopoverController alloc]
                       initWithContentViewController:elcPicker];
            popOver.delegate = self;
            popOver.popoverBackgroundViewClass = [KSCustomPopoverBackgroundView class];
            [popOver presentPopoverFromRect:((UIButton *)sender).frame
                                     inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
            NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
            // NSLog(@"current version %@",currSysVer);
            if (currSysVer >= @"7.0") {
                //ios 8
                //[popOver setPopoverContentSize:CGSizeMake(320, 667) animated:NO];
               // [popOver setPopoverContentSize:CGSizeMake(320, 768) animated:NO];

            }
            
        }
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_PhotoAlbum:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

/*
 * Method name: logoutUser
 * Description: Log out the user from CreateVU.
 * Parameters: nil
 * return nil
 */
-(void)logoutUser {
    [self.delegate userLoggedOutFromVideoMakerController];
}

-(void)switchToWelvuUSer {
    [self.delegate userSwitchWelVUFromVideoMakerController];
}
/*
 * Method name: feedBackBtnClicked
 * Description: to navigate feedback view
 * Parameters: <#parameters#>
 * return ibaction
 * Created On: 19-dec-2012
 */
-(IBAction)feedBackBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"FeedBack Button - VM"
                                                           label:@"FeedBack"
                                                           value:nil] build]];
    
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:URL_FEEDBACK_FORM]];
        /*if ([MFMailComposeViewController canSendMail]) {
         MFMailComposeViewController *pickerMFMailComposer = [[[MFMailComposeViewController alloc] init] autorelease];
         pickerMFMailComposer.mailComposeDelegate = self;
         [pickerMFMailComposer setToRecipients:[NSArray arrayWithObject: MAIL_ID]];
         [self presentModalViewController:pickerMFMailComposer animated:YES];
         }else {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:"
         message:@"Your phone is not currently configured to send mail."
         delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
         
         [alert show];
         [alert release];
         }*/
    }
    
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Feedback:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
/*
 * Method name: settingsBtnClicked
 * Description: to view settings
 * Parameters: <#parameters#>
 * return ibaction
 * Created On: 19-dec-2012
 */
-(IBAction)settingsBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Settings Button - VM"
                                                           label:@"Settings"
                                                           value:nil] build]];
    
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        welvuSettingsMasterViewController *settingsMasterViewController = [[welvuSettingsMasterViewController alloc]                 initWithNibName:@"welvuSettingsMasterViewController" bundle:nil];
        settingsMasterViewController.delegate = self;
        UINavigationController *cntrol = [[UINavigationController alloc]
                                          initWithRootViewController:settingsMasterViewController];
        [cntrol setNavigationBarHidden:YES];
        cntrol.navigationBar.barStyle = UIBarStyleBlack;
        cntrol.modalPresentationStyle = UIModalPresentationFormSheet;
        cntrol.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:cntrol animated:YES];
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Settings:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
    }
}


-(IBAction)ipxBtnClicked:(id)sender {
    
    //Declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"iPx Button -VM"
                                                           label:@"iPx"
                                                           value:nil] build]];
    @try {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];

        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OPENEMR]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_IPX_TITLE", nil)
                                                         message:nil
                                                        delegate: self
                                               cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                               otherButtonTitles:NSLocalizedString(@"SAVE", nil),nil];
            av.delegate = self;
            [av show];        } else {
        int orgCount = [welvu_organization getOrganizationCount:[appDelegate getDBPath]];
        
        
        if(appDelegate.welvu_userModel.org_id > 0) {
            
            
            if(appDelegate.networkReachable) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_IPX_TITLE", nil)
                                                             message:nil
                                                            delegate: self
                                                   cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                   otherButtonTitles:NSLocalizedString(@"SAVE", nil),nil];
                av.delegate = self;
                [av show];
            } else {
                UIAlertView *myAlert = [[UIAlertView alloc]
                                        initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                        message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                        delegate:self
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
                [myAlert show];
                
            }

        } else {
            if(appDelegate.orgGoToWelVU) {
                UIAlertView *myAlert = [[UIAlertView alloc]
                                        initWithTitle:NSLocalizedString(@"UPGRADE_TITLE", nil)
                                        message:nil
                                        delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                        otherButtonTitles:NSLocalizedString(@"UPGRADE", nil),nil];
                myAlert.tag = 123;
                [myAlert show];
            } else {
                UIAlertView *myAlert = [[UIAlertView alloc]
                                        initWithTitle:NSLocalizedString(@"UPGRADE_TITLE", nil)
                                        message:nil
                                        delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                        otherButtonTitles:NSLocalizedString(@"UPGRADE", nil),nil];
                myAlert.tag = 123;
                [myAlert show];
            }
        }
    }
    }
        @catch (NSException *exception) {
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU - VM_ipx:%@",exception];
            [tracker send:[[GAIDictionaryBuilder
                            createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                            withFatal:NO] build]];
            
            
        }
    }

//History Commented
-(IBAction)closeBtnClicked:(id)sender {
    [annotateView annotationTextViewConditions];
    
    //Declaring Event Tracking Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Close Button - VM"
                                                           label:@"Back"
                                                           value:nil] build]];
    @try {
        imagesVUScrollView = nil;
        gestureView = nil;
        
        [self popoverControllerDidDismissPopover:popOver];
        if(![captureView isRecording]) {
            
            
            //Need to be fixed for deep copy
            for(welvu_images *welvu_imagesModel in imageGallery) {
                if(welvu_imagesModel.retainedAnnotatedImageUrl != nil) {
                    welvu_imagesModel.retainedAnnotatedImageUrl = nil;
                }
            }
            imageGallery = nil;
            
            
            
            notificationLable.hidden = YES;
            [self.delegate welvuVideoMakerViewControllerDidFinish:self];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Recording"
                                  message: @"Cannot close while recording. Please stop recording to close."
                                  delegate: nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil,nil];
            
            [alert show];
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Back:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}


//Toolbar controls


/*
 * Method name: informationBtnClicked
 * Description: to see the information about the view
 * Parameters: <#parameters#>
 * return ibaction
 * Created On: 19-dec-2012
 */
-(IBAction)informationBtnClicked:(id)sender{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Info Button- VM"
                                                           label:@"Guide"
                                                           value:nil] build]];
    
    
    
    //Declaring Event Tracking Analytics
    
    @try {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        [annotateView annotationTextViewConditions];
        if(appDelegate.welvu_userModel.org_id > 0) {
            overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            overlay.alpha = 1;
            overlay.backgroundColor = [UIColor clearColor];
            
            
            UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            UIButton *overlayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [overlayCustomBtn addTarget:self action:@selector(closeOverlay:) forControlEvents:UIControlEventTouchUpInside];
            [overlayCustomBtn setFrame:CGRectMake(0, 0, 1024, 768)];
            // overlayImageView.image = [UIImage imageNamed:@"patientVUYouTube.png"];
            overlayImageView.image = [UIImage imageNamed:@"patientvu-ipx.png"];
            
            
            [overlay addSubview:overlayImageView];
            [overlay addSubview:overlayCustomBtn];
            
            [self.view addSubview:overlay];
            
            NSLog(@"Org Id");
        } else {
            NSLog(@"welvu");
            overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            overlay.alpha = 1;
            overlay.backgroundColor = [UIColor clearColor];
            
            
            UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            UIButton *overlayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [overlayCustomBtn addTarget:self action:@selector(closeOverlay:) forControlEvents:UIControlEventTouchUpInside];
            [overlayCustomBtn setFrame:CGRectMake(0, 0, 1024, 768)];
             overlayImageView.image = [UIImage imageNamed:@"patientvu-ipx.png"];
            // overlayImageView.image = [UIImage imageNamed:@"createVUOverlayYoutube.png"];
           // overlayImageView.image = [UIImage imageNamed:@"CreateVUOverlay.png"];
            
            [overlay addSubview:overlayImageView];
            [overlay addSubview:overlayCustomBtn];
            
            [self.view addSubview:overlay];
        }
        
    } @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Guide:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
/*
 * Method name: closeOverlay
 * Description: to clode the overlay of theview
 * Parameters: <#parameters#>
 * return ibaction
 * Created On: 19-dec-2012
 */

-(IBAction)closeOverlay:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"close guide overlay- VM"
                                                           label:@"overlayclose"
                                                           value:nil] build]];
    
    
    
    //Declaring Event Tracking Analytics
    
    @try {
        
        if(overlay !=nil) {
            [overlay removeFromSuperview];
            overlay = nil;
        }
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_closeOverlay:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}


//Action to Enable/Disable annotation using double tap and to
//Enable/Disable swipe to navigate pictures
-(IBAction)enable_disableAnnotationBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Annotation Button Enabled/Disabled - VM"
                                                           label:@"EnableandDisableAnnotation"
                                                           value:nil] build]];
    
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        
        if(annotationPencilBtn.selected != true
           && (captureView.moviePlayer == nil
               || captureView.moviePlayer.view.hidden == true
               || captureView.moviePlayer.playbackState == MPMoviePlaybackStatePaused)){
               [annotateView setToolOption:DRAWING_TOOL_LINE];
               [captureView bringSubviewToFront:annotateView];
               [annotationPencilBtn setSelected:true];
               [annotateView isLineDrawingEnabled:true];
               [annotationArrowBtn setSelected:false];
               [annotationTextViewBtn setSelected:false];
               [annotationSquareBtn setSelected:false];
               [annotationCircleBtn setSelected:false];
               [zoomBtn setSelected:false];
               [swipeLeft setEnabled:false];
               [swipeRight setEnabled:false];
               [gestureView viewModificationGestureEnable:false];
           } else {
               [annotationPencilBtn setSelected:false];
               [annotateView isLineDrawingEnabled:false];
               [swipeLeft setEnabled:true];
               [swipeRight setEnabled:true];
           }
        if([(UITapGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
            captureView.touchBeganFlag = true;
            captureView.vuModifiedFlag = false;
        }
        
        if([(UITapGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
            [captureView vuModified];
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_enable_disableAnnotation:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}




/*
 * Method name: arrowBtnClicked
 * Description: when clicked to draw arrow in the view
 * Parameters: <#parameters#>
 * return ibaction
 * Created On: 19-dec-2102
 */
-(IBAction)arrowBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Arrow Tool - VM"
                                                           label:@"Arrow"
                                                           value:nil] build]];
    
    
    
    
    @try {
        [annotateView annotationTextViewConditions];
        if(annotationArrowBtn.selected == true) {
            [annotationArrowBtn setSelected:false];
            [annotateView isLineDrawingEnabled:false];
            [swipeLeft setEnabled:true];
            [swipeRight setEnabled:true];
            
        } else {
            [annotateView setToolOption:DRAWING_TOOL_ARROW];
            [captureView bringSubviewToFront:annotateView];
            [annotationArrowBtn setSelected:true];
            [annotateView isLineDrawingEnabled:true];
            [annotationPencilBtn setSelected:false];
            [annotationTextViewBtn setSelected:false];
            [annotationSquareBtn setSelected:false];
            [annotationCircleBtn setSelected:false];
            [zoomBtn setSelected:false];
            [swipeLeft setEnabled:false];
            [swipeRight setEnabled:false];
            [gestureView viewModificationGestureEnable:false];
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Arrow:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

/*
 * Method name: annotationTextBtnClicked
 * Description: when clicked to type text in the view
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2102
 */

-(IBAction)annotationTextBtnClicked:(id)sender{
    [annotateView annotationTextViewConditions];
    
    //Declaring Event Tracking Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Text Annotation Tool - VM"
                                                           label:@"Text"
                                                           value:nil] build]];
    
    
    
    @try {
        
        if(annotationTextViewBtn.selected == true) {
            [annotationTextViewBtn setSelected:false];
            [annotateView isLineDrawingEnabled:false];
            [swipeLeft setEnabled:true];
            [swipeRight setEnabled:true];
            
        } else {
            [annotateView setToolOption:DRAWING_TOOL_TEXTVIEW];
            [captureView bringSubviewToFront:annotateView];
            [annotationTextViewBtn setSelected:true];
            [annotateView isLineDrawingEnabled:true];
            [annotationPencilBtn setSelected:false];
            [annotationArrowBtn setSelected:false];
            [annotationSquareBtn setSelected:false];
            [annotationCircleBtn setSelected:false];
            [zoomBtn setSelected:false];
            [swipeLeft setEnabled:false];
            [swipeRight setEnabled:false];
            [gestureView viewModificationGestureEnable:false];
            
            
        }
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_AnnotationText:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}
/*
 * Method name: squarebtnclicked
 * Description: when clicked to draw square in the view
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2102
 */

-(IBAction)squarebtnclicked:(id)sender {
    [annotateView annotationTextViewConditions];
    
    //Declaring Event Tracking Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Square Tool - VM"
                                                           label:@"Square"
                                                           value:nil] build]];
    
    
    @try {
        
        if(annotationSquareBtn.selected == true) {
            [annotationSquareBtn setSelected:false];
            [annotateView isLineDrawingEnabled:false];
            [swipeLeft setEnabled:true];
            [swipeRight setEnabled:true];
        } else {
            [annotateView setToolOption:DRAWING_TOOL_SQUARE];
            [captureView bringSubviewToFront:annotateView];
            [annotationSquareBtn setSelected:true];
            [annotateView isLineDrawingEnabled:true];
            [annotationArrowBtn setSelected:false];
            [annotationPencilBtn setSelected:false];
            [annotationTextViewBtn setSelected:false];
            [annotationCircleBtn setSelected:false];
            [zoomBtn setSelected:false];
            [swipeLeft setEnabled:false];
            [swipeRight setEnabled:false];
            [gestureView viewModificationGestureEnable:false];
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Square:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}
/*
 * Method name: circlebtnclicked
 * Description: when clicked to Circle square in the view
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2102
 */

-(IBAction)circlebtnclicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Circle Tool - VM"
                                                           label:@"Circle"
                                                           value:nil] build]];
    
    
    
    
    
    [annotateView annotationTextViewConditions];
    
    @try {
        
        if(annotationCircleBtn.selected == true) {
            [annotationCircleBtn setSelected:false];
            [annotateView isLineDrawingEnabled:false];
            [swipeLeft setEnabled:true];
            [swipeRight setEnabled:true];
        } else {
            [annotateView setToolOption:DRAWING_TOOL_CIRCLE];
            [captureView bringSubviewToFront:annotateView];
            [annotationCircleBtn setSelected:true];
            [annotateView isLineDrawingEnabled:true];
            [annotationArrowBtn setSelected:false];
            [annotationPencilBtn setSelected:false];
            [annotationTextViewBtn setSelected:false];
            [annotationSquareBtn setSelected:false];
            [zoomBtn setSelected:false];
            [swipeLeft setEnabled:false];
            [swipeRight setEnabled:false];
            [gestureView viewModificationGestureEnable:false];
        }
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Circle:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
/*
 * Method name: undoAnnotationBtnClicked
 * Description: when clicked to  do undo   in the view
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2102
 */

-(IBAction)undoAnnotationBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Undo Button - VM"
                                                           label:@"Undo"
                                                           value:nil] build]];
    
    
    
    
    
    [annotateView annotationTextViewConditions];
    
    @try {
        
        [annotateView undoButtonClicked];
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Undo:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
    [captureView vuModified];
}
-(IBAction)redoAnnotationBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Redo Button - VM"
                                                           label:@"Redo"
                                                           value:nil] build]];
    
    
    
    
    [annotateView annotationTextViewConditions];
    
    @try {
        
        [annotateView redoButtonClicked];
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Redo:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
    [captureView vuModified];
}
/*
 * Method name: zoomBtnClicked
 * Description: when clicked to zoom the view
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2102
 */
-(IBAction)zoomBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Gesture - VM"
                                                           label:@"Gesture"
                                                           value:nil] build]];
    
    
    
    
    [annotateView annotationTextViewConditions];
    
    @try {
        
        UIButton *btn = (UIButton *) sender;
        if(btn.selected) {
            btn.selected = false;
            [captureView bringSubviewToFront:annotateView];
            [gestureView viewModificationGestureEnable:false];
            [swipeLeft setEnabled:true];
            [swipeRight setEnabled:true];
        } else {
            if([welvu_alerts canAlertShowAgain:appDelegate.getDBPath :ALERT_GESTURE_LIMITATION_TITLE]) {
                btn.selected = true;
                [captureView bringSubviewToFront:gestureView];
                [annotationPencilBtn setSelected:false];
                [annotationArrowBtn setSelected:false];
                [annotateView isLineDrawingEnabled:false];
                [annotationSquareBtn setSelected:false];
                [annotationCircleBtn setSelected:false];
                [annotationTextViewBtn setSelected:false];
                [swipeLeft setEnabled:false];
                [swipeRight setEnabled:false];
                [annotateView clearScreen];
                [gestureView viewModificationGestureEnable:true];
            } else {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: NSLocalizedString(@"ALERT_GESTURE_LIMITATION_TITLE", nil)
                                      message: NSLocalizedString(@"ALERT_GESTURE_LIMITATION_MSG", nil)
                                      delegate: self
                                      cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                      otherButtonTitles:NSLocalizedString(@"DONT_SHOW_AGAIN", nil), NSLocalizedString(@"OK", nil),nil];
                [alert show];
            }
        }
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Gesture:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
    
}
/*
 * Method name: changeColorBtnClicked
 * Description: when clicked to change the color of the view when draws
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2102
 */
-(IBAction)changeColorBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"changeColorBtn - VM"
                                                           label:@"ChangeColor"
                                                           value:nil] build]];
    
    
    
    
    [annotateView annotationTextViewConditions];
    
    @try {
        UIButton *button = (UIButton *)sender;
        switch ([button tag]) {
            case 1000:
                [annotateView setStrokeColor:[UIColor redColor]];
                ((UIButton *)sender).selected = true;
                blueColorBtn.selected = false;
                yellowColorBtn.selected = false;
                blackColorBtn.selected = false;
                whiteColorBtn.selected = false;
                break;
            case 1001:
                [annotateView setStrokeColor:[UIColor blueColor]];
                ((UIButton *)sender).selected = true;
                redColorBtn.selected = false;
                yellowColorBtn.selected = false;
                blackColorBtn.selected = false;
                whiteColorBtn.selected = false;
                break;
            case 1002:
                [annotateView setStrokeColor:[UIColor yellowColor]];
                ((UIButton *)sender).selected = true;
                redColorBtn.selected = false;
                blueColorBtn.selected = false;
                blackColorBtn.selected = false;
                whiteColorBtn.selected = false;
                break;
            case 1003:
                [annotateView setStrokeColor:[UIColor blackColor]];
                ((UIButton *)sender).selected = true;
                redColorBtn.selected = false;
                blueColorBtn.selected = false;
                yellowColorBtn.selected = false;
                whiteColorBtn.selected = false;
                break;
            case 1004:
                [annotateView setStrokeColor:[UIColor whiteColor]];
                ((UIButton *)sender).selected = true;
                redColorBtn.selected = false;
                blueColorBtn.selected = false;
                yellowColorBtn.selected = false;
                blackColorBtn.selected = false;
                break;
            default:
                break;
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_ChangeColor:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

// Two finger, swipe right
//To capture and retain the annotated image
- (void)swipeImageRight:(UISwipeGestureRecognizer *)recognizer
{
    [annotateView annotationTextViewConditions];
    
    if(currentImage > 0) {
        if(annotateView.isAnnotationStarted)
        {
            [self retainAnnotatedImage:currentImage];
        }
        [self setZoomToNormal];
        currentImage = (currentImage - 1);
        [captureView vuModified];
        
        ((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]).enabled = true;
        ((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]).enabled = false;
        for(UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]) subviews]) {
            if([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)subview;
                imageView.image = [[imageView.image imageWithBorderForUnselected:THUMB_MINI_IMAGE_BORDER]  makeRoundCornerImage:5 :5];
            }
        }
        [captureView vuModified];
        for(UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]) subviews]) {
            if([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)subview;
                imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_MINI_IMAGE_BORDER]  makeRoundCornerImage:5 :5];
            }
        }
        prevImage = currentImage;
        [captureView vuModified];
        [annotateView clearScreen];
        welvu_images *welvu_imagesModel = (welvu_images *) [imageGallery objectAtIndex:currentImage];
        [self loadImageToCanvas:welvu_imagesModel];
        [captureView vuModified];
    }
    if([recognizer state] == UIGestureRecognizerStateBegan) {
        captureView.touchBeganFlag = true;
        captureView.vuModifiedFlag = false;
    }
    
    if([recognizer state] == UIGestureRecognizerStateEnded) {
        [captureView vuModified];
    }
}

// Two finger, swipe left
//To capture and retain the annotated image
- (void)swipeImageLeft:(UISwipeGestureRecognizer *)recognizer
{
    /*CGPoint point = [recognizer locationInView:[self view]];
     NSLog(@"Swipe left - start location: %f,%f", point.x, point.y);*/
    [annotateView annotationTextViewConditions];
    
    if(currentImage < ([imageGallery count] - 1)) {
        if(annotateView.isAnnotationStarted)
        {
            [self retainAnnotatedImage:currentImage];
        }
        [self setZoomToNormal];
        currentImage = (currentImage + 1);
        [captureView vuModified];
        ((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]).enabled = true;
        ((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]).enabled = false;
        for(UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]) subviews]) {
            if([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)subview;
                imageView.image = [[imageView.image imageWithBorderForUnselected:THUMB_MINI_IMAGE_BORDER]  makeRoundCornerImage:5 :5];
            }
        }
        [captureView vuModified];
        for(UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]) subviews]) {
            if([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)subview;
                imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_MINI_IMAGE_BORDER]  makeRoundCornerImage:5 :5];
            }
        }
        prevImage = currentImage;
        [captureView vuModified];
        [annotateView clearScreen];
        welvu_images *nextWelvu_imagesModel = (welvu_images *) [imageGallery objectAtIndex:currentImage];
        [self loadImageToCanvas:nextWelvu_imagesModel];
        [captureView vuModified];
    }
    
    if([recognizer state] == UIGestureRecognizerStateBegan) {
        captureView.touchBeganFlag = true;
        captureView.vuModifiedFlag = false;
    }
    
    if([recognizer state] == UIGestureRecognizerStateEnded) {
        [captureView vuModified];
    }
}
/*
 * Method name: clearAnnotationBtnClicked
 * Description: when clicked to cclear the annotation in the view.
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2102
 */
//To clear annotation from the image
-(IBAction)clearAnnotationBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Clear Annotation - VM"
                                                           label:@"ClearAnnotation"
                                                           value:nil] build]];
    
    
    
    [annotateView annotationTextViewConditions];
    
    @try {
        [self clearAnnotationFromImage:currentImage];
        [self setZoomToNormal];
        captureView.annotatedCapturedScreen = nil;
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_ClearAnnotation:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
    [captureView vuModified];
}
/*
 * Method name: disable_enableTools
 * Description: To enable and disable  the annotation tool
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2102
 */
-(void)disable_enableTools:(BOOL)enable {
    
    
    //Declaring Event Tracking Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Disable_Enable Video Tools - VM"
                                                           label:@"Disable/Enable Tools"
                                                           value:nil] build]];
    
    
    
    
    
    [annotateView annotationTextViewConditions];
    
    @try {
        
        if(enable) {
            annotationPencilBtn.enabled = false;
            //            annotationPencilBtn.selected = false;
            annotationArrowBtn.enabled = false;
            //            annotationArrowBtn.selected = false;
            annotationTextViewBtn.enabled = false;
            //            annotationTextViewBtn.selected = false;
            annotationSquareBtn.enabled = false;
            //            annotationSquareBtn.selected = false;
            annotationCircleBtn.enabled = false;
            //            annotationCircleBtn.selected = false;
            zoomBtn.enabled = false;
            //            zoomBtn.selected = false;
            redColorBtn.enabled = false;
            blueColorBtn.enabled = false;
            yellowColorBtn.enabled = false;
            blackColorBtn.enabled = false;
            whiteColorBtn.enabled = false;
            
            [annotateView isLineDrawingEnabled:false];
        } else {
            
            annotationPencilBtn.enabled = true;
            //            annotationPencilBtn.selected = false;
            annotationArrowBtn.enabled = true;
            //            annotationArrowBtn.selected = false;
            annotationTextViewBtn.enabled = true;
            //            annotationTextViewBtn.selected = false;
            annotationSquareBtn.enabled = true;
            //            annotationSquareBtn.selected = false;
            annotationCircleBtn.enabled = true;
            //            annotationCircleBtn.selected = false;
            zoomBtn.enabled = true;
            //            zoomBtn.selected = false;
            redColorBtn.enabled = true;
            blueColorBtn.enabled = true;
            yellowColorBtn.enabled = true;
            blackColorBtn.enabled = true;
            whiteColorBtn.enabled = true;
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_Disable/EnableTools:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

-(void)showVideoControl:(BOOL)visible {
    
    
    //Declaring Event Tracking Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Show Video Control-VM"
                                                           label:@"ShowVideo"
                                                           value:nil] build]];
    
    
    
    
    @try {
        if(visible) {
            videoVUControlView.hidden = false;
        } else {
            videoVUControlView.hidden = true;
        }
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_ShowVideo:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
-(IBAction)playVideoBtnClicked:(id)sender {
    
    
    //Declaring Event Tracking Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Play Video - VM"
                                                           label:@"PlayVideo/Enable Tools"
                                                           value:nil] build]];
    
    
    
    [annotateView annotationTextViewConditions];
    
    @try {
        
        UIButton *btn = (UIButton *) sender;
        if(!btn.selected) {
            btn.selected = true;
            [captureView.moviePlayer play];
            [self disable_enableTools:true];
            [annotateView isLineDrawingEnabled:false];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(moviePlayBackDidFinished:)
                                                         name:MPMoviePlayerPlaybackDidFinishNotification
                                                       object:captureView.moviePlayer];
            //[captureView.playerSliderView setMaximumValue:captureView.moviePlayer.duration];
            //[captureView refreshPlayerSlider];
        } else {
            btn.selected = false;
            if(captureView.moviePlayer != nil) {
                [captureView.moviePlayer pause];
            }
            [self disable_enableTools:false];
            zoomBtn.enabled = false;
            [annotateView isLineDrawingEnabled:true];
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_PlayVideo:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
    }
}
-(IBAction)stopVideoBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Stop Video-VM"
                                                           label:@"StopVideo"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
        
        
        [annotateView annotationTextViewConditions];
        if(captureView.moviePlayer != nil) {
            [captureView.moviePlayer stop];
            [captureView.moviePlayer prepareToPlay];
        }
        [self disable_enableTools:false];
        [annotateView isLineDrawingEnabled:true];
        playVideoBtn.selected = false;
        [captureView.playerSliderView setValue:0];
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_StopVideo:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}
-(IBAction)repeatVideoBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Video-Maker-PatientVU - VM"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video-Maker-PatientVU - VM"
                                                          action:@"Repeat Video-VM"
                                                           label:@"RepeatVideo"
                                                           value:nil] build]];
    
    
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        UIButton *btn = (UIButton *) sender;
        if(btn.selected) {
            btn.selected = false;
        } else {
            btn.selected = true;
        }
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Video-Maker-PatientVU-VM_RepeatVideo:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
        
    }
}



-(void)moviePlayBackDidFinished:(NSNotification*)notification {
    [annotateView annotationTextViewConditions];
    
    if(repeatVideoBtn.selected) {
        playVideoBtn.selected = true;
        [captureView.moviePlayer play];
        [self disable_enableTools:true];
        //[annotateView isLineDrawingEnabled:false];
    } else {
        playVideoBtn.selected = false;
    }
}

-(UIImage *) generateImageFromVideo:(NSString *) pathString:(NSString *)pathType {
    NSURL *theContentURL;
    if([pathType isEqualToString:IMAGE_VIDEO_TYPE] && ![[NSFileManager defaultManager] fileExistsAtPath:pathString]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSArray *nameAndType = [pathString componentsSeparatedByString: @"."];
        NSString *moviePath = [bundle pathForResource:[nameAndType objectAtIndex:0] ofType:[nameAndType objectAtIndex:1]];
        theContentURL = [NSURL fileURLWithPath:moviePath];
    } else {
        theContentURL = [NSURL fileURLWithPath:pathString];
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:theContentURL options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    CGImageRef thumb = [imageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(1.0, 1.0)
                                              actualTime:NULL
                                                   error:NULL];
    
    UIImage *thumbImage = [UIImage imageWithCGImage:thumb];
    imageGenerator = nil;
    asset = nil;
    CGImageRelease(thumb);
    return thumbImage;
}

//Alertview Delegates
-(void) doYouWantShare_playAlert {
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.currentWelvuSettings = [welvu_settings getActiveSettings:appDelegate.getDBPath];
    
    if(appDelegate.networkReachable) {
        //  NSLog(@"network is there");
        [appDelegate checkForConfirmedUser];
        
    } else {
        //  NSLog(@"network is not there");
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString * accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
    
    
    if(appDelegate.welvu_userModel != nil &&
       appDelegate.welvu_userModel.access_token == nil && accessToken != nil && appDelegate.networkReachable) {
        NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                      [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                      accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,nil];
        
        NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
        if(appDelegate.welvu_userModel.org_id > 0) {
            [requestDataMutable
             setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
             forKey:HTTP_REQUEST_ORGANISATION_KEY];
        }
        
        HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                              :PLATFORM_HOST_URL :PLATFORM_CHECK_USER_CONFIRMATION:HTTP_METHOD_POST
                                              :requestDataMutable :nil];
        requestHandler.delegate = self;
        [requestHandler makeHTTPRequest];
        
    } else {
        
        BOOL validateSubscription = [self checkSubscriptionFeasibility];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger shareCount = [userDefaults integerForKey:[NSString stringWithFormat:@"Specialty_%d", appDelegate.specialtyId]];
        if((!validateSubscription && (shareCount < FREE_SHARE_MAX_ALLOWED))
           || validateSubscription) {
            NSString *message =  NSLocalizedString(@"ALERT_HIPPA_INFO_MSG", nil);
            if(appDelegate.currentWelvuSettings.securedSharing == SETTINGS_SHARE_VU_SECURED) {
                message =  NSLocalizedString(@"ALERT_HIPPA_INFO_MSG", nil);
            } else {
                message = NSLocalizedString(@"ALERT_DEFAULT_MAIL_MSG", nil);
            }
            if(!validateSubscription) {
                shareCount++;
                [[NSUserDefaults standardUserDefaults] setInteger:shareCount forKey:[NSString stringWithFormat:@"Specialty_%d", appDelegate.specialtyId]];
                /* message = [message stringByAppendingFormat:@"\n Free sharing left %d", (FREE_SHARE_MAX_ALLOWED - shareCount)];*/
            }
            if (appDelegate.networkReachable) {
                welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                                      queueId:appDelegate.recordCounter];
                
                
                if (appDelegate.currentWelvuSettings.securedSharing == SETTINGS_SHARE_VU_SECURED) {
                    if(![welvu_alerts canAlertShowAgain:appDelegate.getDBPath :ALERT_HIPAA_INFO_TITLE]) {
                        UIAlertView *alert = [[UIAlertView alloc]
                                              initWithTitle: NSLocalizedString(@"ALERT_HIPAA_INFO_TITLE", nil)
                                              message: message
                                              delegate: self
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:NSLocalizedString(@"DONT_SHOW_AGAIN", nil), NSLocalizedString(@"CONTINUE", nil),nil];
                        [alert show];
                    } else {
                        NSString *path = nil;
                        if([captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                            path = [NSString  stringWithFormat:@"%@/%@",
                                    CACHE_DIRECTORY, welvuVideoModel.av_file_name];
                        } else if(![captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                            path = [NSString  stringWithFormat:@"%@/%@",
                                    CACHE_DIRECTORY, welvuVideoModel.video_file_name];
                        }
                        [self shareVUContentWithPath:path];
                    }
                    
                } else {
                    if(![welvu_alerts canAlertShowAgain:appDelegate.getDBPath :ALERT_DEFAULT_MAIL_TITLE]) {
                        UIAlertView *alert = [[UIAlertView alloc]
                                              initWithTitle: NSLocalizedString(@"ALERT_DEFAULT_MAIL_TITLE", nil)
                                              message:message
                                              delegate: self
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:NSLocalizedString(@"DONT_SHOW_AGAIN", nil), NSLocalizedString(@"CONTINUE", nil),nil];
                        [alert show];
                    } else {
                        NSString *path = nil;
                        if([captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                            path = [NSString  stringWithFormat:@"%@/%@",
                                    CACHE_DIRECTORY, welvuVideoModel.av_file_name];
                        } else if(![captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                            path = [NSString  stringWithFormat:@"%@/%@",
                                    CACHE_DIRECTORY, welvuVideoModel.video_file_name];
                        }
                        [self shareVUContentWithPath:path];
                    }
                }
                welvuVideoModel = nil;
            }else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                                message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_MSG", nil)
                                                               delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)otherButtonTitles:nil];
                
                [alert show];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"SETTINGS_SHARE_VU_HEADER", nil)
                                  message: NSLocalizedString(@"ALERT_SHAREVU_FREE_SUBSCRIPTION_OVER_MSG", nil)
                                  delegate: nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}
-(void)userEmailConformed{
    
    if (!appDelegate.networkReachable){
        /// Create an alert if connection doesn't work
        UIAlertView *myAlert = [[UIAlertView alloc]
                                initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_SENDING_EMAIL", nil)
                                delegate:self
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil];
        [myAlert show];
    } else {
    
    NSLog(@"appDelegate.welvu_userModel.access_token %@",appDelegate.welvu_userModel.access_token);
    
        NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                      [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                      appDelegate.welvu_userModel.access_token, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                      [NSNumber numberWithInteger:appDelegate.specialtyId], HTTP_SPECIALTY_ID,nil];
        
        NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
        
        
        HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                              :PLATFORM_HOST_URL :PLATFORM_CHECK_USER_CONFIRMATION:HTTP_METHOD_POST
                                              :requestDataMutable :nil];
        requestHandler.delegate = self;
        [requestHandler makeHTTPRequest];
    

    }


}

#pragma mark Settingsviewcontroller Delegate
-(void)settingsMasterViewControllerDidFinish {
    
    [self animatedAssitance];
    
    [self themeSettingsViewControllerDidFinish];
    [captureView modigyAudio_VideoSettings:((welvu_settings *)appDelegate.currentWelvuSettings).audio_video];
    [captureView modifyVideoResolutionOption:((welvu_settings *)appDelegate.currentWelvuSettings).fps];
    //[self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SETTINGS_UPDATED object:self];
    //[self animatedAssitance];
}

-(void)settingsMasterViewControllerDidCancel {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult
                             :(MFMailComposeResult)result error:(NSError*)error {
    // NEVER REACHES THIS PLACE
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark ELCImagePickerController Delegate
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
	
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT];
    NSDictionary *dict=[info objectAtIndex:0];
    NSString *mediaType = [dict objectForKey:UIImagePickerControllerMediaType];
    welvu_images *welvu_imagesModel = [[welvu_images alloc] initWithImageId:(++albumAddedCount)];
    if([mediaType isEqualToString:@"ALAssetTypePhoto"]) {
        UIImage *anImage = [dict objectForKey:UIImagePickerControllerOriginalImage];
        NSString *imageName = [dateFormatter stringFromDate:[NSDate date]];
        
        welvu_imagesModel.imageDisplayName = imageName;
        welvu_imagesModel.type = IMAGE_ALBUM_TYPE;
        welvu_imagesModel.imageData = anImage;
        currentImage = currentImage + 1;
        [imageGallery insertObject: welvu_imagesModel atIndex:currentImage];
        [self removeDeckImages];
        [self buildImageGroups];
        [self retainAnnotatedImage:(prevImage)];
        [annotateView clearScreen];
        [self loadImageToCanvas:welvu_imagesModel];
        prevImage = currentImage;
        /* if(imagesVUScrollView.contentSize.width > imagesVUScrollView.bounds.size.width) {
         CGPoint bottomOffset = CGPointMake(imagesVUScrollView.contentSize.width - imagesVUScrollView.bounds.size.width, 0);
         [imagesVUScrollView setContentOffset:bottomOffset animated:YES];
         }*/
        
    } else if([mediaType isEqualToString:@"ALAssetTypeVideo"]){
        
        
        if(spinner == nil) {
            appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:appDelegate.splitViewController.view];
            [appDelegate.splitViewController.view bringSubviewToFront:spinner];
            //  NSLog(@"spinner on");
        }
        
        NSString* videoName = [NSString stringWithFormat:@"%@.%@", [dateFormatter stringFromDate:[NSDate date]], HTTP_ATTACHMENT_VIDEO_EXT_KEY];
        NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^ {
            
            //
            ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
            [assetLibrary assetForURL:[dict objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                NSUInteger length = [rep size];
                
                
                int offset = 0; // offset that keep tracks of chunk data
                
                //do {
                // @autoreleasepool {
                NSUInteger chunkSize = 100 * 1024;
                
                
                rep = [asset defaultRepresentation];
                
                NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath: exportPath] ;
                
                if(file == nil) {
                    [[NSFileManager defaultManager] createFileAtPath:exportPath contents:nil attributes:nil];
                    file = [NSFileHandle fileHandleForWritingAtPath:exportPath];
                }
                
                offset = 0;
                do {
                    uint8_t *buffer = malloc(chunkSize * sizeof(uint8_t));
                    NSUInteger bytesCopied = [rep getBytes:buffer fromOffset:offset length:chunkSize error:nil];
                    offset += bytesCopied;
                    NSData *data = [[NSData alloc] initWithBytes:buffer length:bytesCopied];
                    [file writeData:data];
                    data= nil;
                    free(buffer);
                    buffer = NULL;
                    
                } while (offset < length);
                
                [file closeFile];
                file = nil;
                
                
                NSURL *outputURL = [NSURL fileURLWithPath:exportPath];
                int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:outputURL];
                welvu_imagesModel.imageDisplayName = @"Album Video";
                welvu_imagesModel.type = IMAGE_VIDEO_ALBUM_TYPE;
                welvu_imagesModel.url = exportPath;
                currentImage = currentImage + 1;
                [imageGallery insertObject: welvu_imagesModel atIndex:currentImage];
                [self removeDeckImages];
                [self buildImageGroups];
                [self retainAnnotatedImage:(prevImage)];
                [annotateView clearScreen];
                [self loadImageToCanvas:welvu_imagesModel];
                prevImage = currentImage;
                
                //[self performSelectorOnMainThread:@selector(setPreviewImageInView:) withObject:welvu_imagesModel waitUntilDone:YES];
                /*if(imagesVUScrollView.contentSize.width > imagesVUScrollView.bounds.size.width) {
                 CGPoint bottomOffset = CGPointMake(imagesVUScrollView.contentSize.width - imagesVUScrollView.bounds.size.width, 0);
                 [imagesVUScrollView setContentOffset:bottomOffset animated:YES];
                 }*/
                
                //[self performSelector:@selector(setPreviewImageInView:) withObject:welvu_imagesModel afterDelay:1.0];
            } failureBlock:^(NSError *err) {
                // NSLog(@"Error: %@",[err localizedDescription]);
            }];
            dispatch_async(dispatch_get_main_queue(), ^ {
                
            });
        });
    }
    //Problem
    //[welvu_imagesModel release];
    
    [popOver dismissPopoverAnimated:NO];
    popOver = nil;
}


-(void) shareVUContentWithPath:(NSString *)path {
    [annotateView clearScreen];
    if(((welvu_settings *)appDelegate.currentWelvuSettings).securedSharing == SETTINGS_SHARE_VU_SECURED) {
        welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                              queueId:appDelegate.recordCounter];
        
        welvuShareVUContentViewController *shareVUContents = [[welvuShareVUContentViewController alloc]
                                                              initWithAttachmentDetails:
                                                              ((welvu_settings *)appDelegate.currentWelvuSettings).phiShareVUSubject:
                                                              ((welvu_settings *)appDelegate.currentWelvuSettings).phiShareVUSignature:
                                                              welvuVideoModel.welvu_video_id: captureView.isExportCompleted];
        shareVUContents.delegate = self;
        shareVUContents.modalPresentationStyle = UIModalPresentationFormSheet;
        shareVUContents.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:shareVUContents animated:YES];
        
        if(appDelegate.currentWelvuSettings.audio_video == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_EXPORT_COMPLETED
                                                                object:self];
        }
        /*if(captureView.isExportCompleted) {
         if(spinner != nil) {
         [spinner removeSpinner];
         spinner = nil;
         }
         welvuShareVUContentViewController *shareVUContents = [[[welvuShareVUContentViewController alloc]
         initWithAttachmentDetails:
         ((welvu_settings *)appDelegate.currentWelvuSettings).phiShareVUSubject:
         ((welvu_settings *)appDelegate.currentWelvuSettings).phiShareVUSignature:
         [self getRecordContentName] :path] autorelease];
         shareVUContents.delegate = self;
         shareVUContents.modalPresentationStyle = UIModalPresentationFormSheet;
         shareVUContents.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
         [self presentModalViewController:shareVUContents animated:YES];
         } else {
         if(spinner == nil) {
         spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view];
         }
         [self performSelector:@selector(shareVUContentWithPath:) withObject:path afterDelay:2];
         }*/
    } else {
        [self displayComposerSheet:path];
    }
}

-(void)shareVUContentViewControllerStartedSharing {
    /*if(spinner == nil) {
     spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view];
     [self.view bringSubviewToFront:spinner];
     }*/
    [self dismissModalViewControllerAnimated:YES];
}

-(void)shareVUContentViewControllerDidFinish:(BOOL) success {
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
    //[self dismissModalViewControllerAnimated:YES];
}

-(void)shareVUContentViewControllerDidCancel {
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
    BOOL validateSubscription = [self checkSubscriptionFeasibility];
    if(!validateSubscription) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger shareCount = [userDefaults integerForKey:
                                [NSString stringWithFormat:@"Specialty_%d", appDelegate.specialtyId  ]];
        shareCount--;
        [userDefaults setInteger:shareCount forKey:[NSString stringWithFormat:@"Specialty_%d", appDelegate.specialtyId]];
    }
    [self dismissModalViewControllerAnimated:YES];
    
}

-(void) youTubeViewControllerDidFinish {
    [self dismissModalViewControllerAnimated:YES];
}

-(void)replayViewBtnClicked:(NSString *)path {
    // [annotateView clearScreen];
    if(captureView.isExportCompleted) {
        if(spinner != nil) {
            [spinner removeSpinner];
            spinner = nil;
        }
        welvuReplayVUContentViewController* replayController = [[welvuReplayVUContentViewController alloc]
                                                                initWithMoviePath:path];
        replayController.delegate = self;
        replayController.modalPresentationStyle = UIModalPresentationFullScreen;
        replayController.modalTransitionStyle = UIModalTransitionStyleCoverVertical; //transition shouldn't matter
        [self presentModalViewController:replayController animated:YES];
    } else {
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view];
        }
        [self performSelector:@selector(replayViewBtnClicked:) withObject:path afterDelay:2];
    }
}


-(void)displayComposerSheet:(NSString *) path {
    if(captureView.isExportCompleted) {
        if(spinner != nil) {
            [spinner removeSpinner];
            spinner = nil;
        }
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        if ([MFMailComposeViewController canSendMail]) {
            picker.mailComposeDelegate = self;
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
            NSData *videoFile = [[NSData alloc] initWithContentsOfURL:fileURL];
            if(((welvu_settings *)appDelegate.currentWelvuSettings).shareVUSubject.length > 0) {
                [picker setSubject:((welvu_settings *)appDelegate.currentWelvuSettings).shareVUSubject];
            }
            NSString *message = @"";
            if(((welvu_settings *)appDelegate.currentWelvuSettings).shareVUSignature.length > 0) {
                message = [message stringByAppendingString:((welvu_settings *)appDelegate.currentWelvuSettings).shareVUSignature];
            }
            
            //message = [message stringByAppendingString:NSLocalizedString(@"SHARE_MAIL_CONFIDENTIAL_MSG_BODY", nil)];
            [picker setMessageBody:message isHTML:NO];
            [picker addAttachmentData:videoFile mimeType:@"video/mp4"
                             fileName:[NSString stringWithFormat:@"%@.%@",
                                       [self getRecordContentName],
                                       HTTP_ATTACHMENT_VIDEO_EXT_KEY]];
            [self presentModalViewController:picker animated:YES];
        }/*else {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
          message:NSLocalizedString(@"ALERT_PURCHASE_FAILED_MSG", nil)
          delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)
          otherButtonTitles:nil];
          
          [alert show];
          }*/
    } else {
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view];
        }
        [self performSelector:@selector(displayComposerSheet:) withObject:path afterDelay:2];
    }
}

-(void)replayVUContentDidFinish {
    [self dismissModalViewControllerAnimated:YES];
    [self loadImageToCanvas:[imageGallery objectAtIndex:currentImage]];
}


#pragma mark - Welvu Video queue
-(NSInteger) createNewWelvuVideoQueue {
    welvu_video *welvuVideoModel = [[welvu_video alloc] init];
    NSDate *recordDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_NAME_FORMAT];
    welvuVideoModel.generic_file_name = [NSString stringWithFormat:@"%@_%d",
                                         [dateFormatter stringFromDate:recordDate],
                                         ([welvu_video
                                           getLastInsertRowId:[appDelegate getDBPath]] + 1)];
    welvuVideoModel.recording_status = WELVU_RECORD_STATUS_STARTED;
    welvuVideoModel.created_date = [NSDate date];
    welvuVideoModel.user_id = appDelegate.welvu_userModel.welvu_user_id;
    switch (((welvu_settings *)appDelegate.currentWelvuSettings).audio_video) {
        case WELVU_AUDIO_VIDEO_VU: {
            welvuVideoModel.video_file_name = [NSString  stringWithFormat:@"%@_V.%@",
                                               welvuVideoModel.generic_file_name, HTTP_ATTACHMENT_VIDEO_EXT_KEY];
            welvuVideoModel.audio_file_name = [NSString  stringWithFormat:@"%@_A.caf",
                                               welvuVideoModel.generic_file_name];
            welvuVideoModel.av_file_name = [NSString  stringWithFormat:@"%@_AV.%@",
                                            welvuVideoModel.generic_file_name, HTTP_ATTACHMENT_VIDEO_EXT_KEY];
            welvuVideoModel.welvu_video_type = WELVU_AUDIO_VIDEO_VU;
        }
            break;
        case WELVU_VIDEO_VU: {
            welvuVideoModel.video_file_name = [NSString  stringWithFormat:@"%@_V.%@",
                                               welvuVideoModel.generic_file_name,HTTP_ATTACHMENT_VIDEO_EXT_KEY];
            welvuVideoModel.audio_file_name = @"";
            welvuVideoModel.av_file_name = @"";
            welvuVideoModel.welvu_video_type = WELVU_VIDEO_VU;
            
        }
            break;
        case WELVU_AUDIO_VU: {
            welvuVideoModel.video_file_name = @"";
            welvuVideoModel.audio_file_name = [NSString  stringWithFormat:@"%@_A.caf",
                                               welvuVideoModel.generic_file_name];
            welvuVideoModel.av_file_name = @"";
            welvuVideoModel.welvu_video_type = WELVU_AUDIO_VU;
        }
            break;
        default:
            break;
    }
    NSInteger rowId = [welvu_video insertVideoQueue:[appDelegate getDBPath] :welvuVideoModel];
    dateFormatter = nil;
    return  rowId;
}

#pragma mark - NSConnection delegates
-(void) platformDidResponseReceived:(BOOL)success:(NSString *)actionAPI {
    // NSLog(@"Response received for get USER CONFIRMATION");
}
-(void) platformDidReceivedData:(BOOL)success :(NSDictionary *)responseDictionary
                               :(NSString *)actionAPI {
    //  NSLog(@"Response received for get USER CONFIRMATION");
    
    if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame) &&[actionAPI isEqualToString:HTTP_RESPONSE_CHECK_USER_CONFIRMATION_KEY]      )  {
        
        
            [self doYouWantShare_playAlert];
        
        
        // NSLog(@"account Activated");
    }
    
    if([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] isEqualToString:HTTP_RESPONSE_FAILED_KEY]&&[actionAPI isEqualToString:HTTP_RESPONSE_CHECK_USER_CONFIRMATION_KEY] )
    {
        
        
        [[[VerticalAlertView alloc] initWithTitle: NSLocalizedString(@"ALERT_VERIFY_EMAIL_ADDRESS", nil)
                                          message:nil
                                         delegate:self
                                cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                otherButtonTitles:NSLocalizedString(@"YES", nil), nil] show];
        
        
        
        
    }
    
    if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame)
       && [actionAPI isEqualToString:HTTP_RESPONSE_SEND_USER_CONFIRMATION_KEY] )
    {
        
        UIAlertView *verifyMail=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"CONFIRM_EMAIL", nil)
                                                          message:NSLocalizedString(@"SUCCESSFULLY_SENT", nil)
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                otherButtonTitles:nil];
        [verifyMail show];
        /* [[[VerticalAlertView alloc] initWithTitle: NSLocalizedString(@"ALERT_VERIFY_EMAIL_ADDRESS", nil)
         message:nil
         delegate:self
         cancelButtonTitle:NSLocalizedString(@"ALERT_RESEND_VERIFY_EMAIL", nil)
         otherButtonTitles:NSLocalizedString(@"CANCEL", nil), nil] show];*/
        
        
        
        
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_SHARE_PLAY_TITLE", nil)]) {
        //return false;
    }
    return true;
}
#pragma mark - UIALERTVIEW delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_SAVE_VIDEO_TO_PHOTO_ALBUM", nil)]) {
        if (buttonIndex == 0 ){
            NSString *path = nil;
            welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                                  queueId:appDelegate.recordCounter];
            if([captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                path = [NSString  stringWithFormat:@"%@/%@",
                        CACHE_DIRECTORY, welvuVideoModel.av_file_name];
            } else if(![captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                path = [NSString  stringWithFormat:@"%@/%@",
                        CACHE_DIRECTORY, welvuVideoModel.video_file_name];
            }
            UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            welvuVideoModel = nil;
            
        } else {
            
        }
    }else if(alertView.tag == 123){
        
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:URL_UPGRADE]];
            
        }
        
        
        
    }else if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_IPX_TITLE", nil)]) {
        if (buttonIndex == 1 ){
            /* NSLog(@"1 %@", [alertView textFieldAtIndex:0].text);
             NSLog(@"2 %@", [alertView textFieldAtIndex:1].text);
             
             NSString *ipx_title = [alertView textFieldAtIndex:0].text;
             NSString *ipx_description = [alertView textFieldAtIndex:1].text; */
            
            welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                                  queueId:appDelegate.recordCounter];
            NSString *path = nil;
            if([captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                path = [NSString  stringWithFormat:@"%@/%@",
                        CACHE_DIRECTORY, welvuVideoModel.av_file_name];
            } else if(![captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                path = [NSString  stringWithFormat:@"%@/%@",
                        CACHE_DIRECTORY, welvuVideoModel.video_file_name];
            }
            // NSLog(@"path %@",path);
            //[self shareIpxVideoVU:path :ipx_title :ipx_description];
            /*if(spinner == nil) {
             spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view];
             }*/
            [self shareiPxwithPath:path];
            //[self shareContentVU:path];
            welvuVideoModel = nil;
            
        } else {
            
        }
    }
    
    else if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_VERIFY_EMAIL_ADDRESS", nil)]) {
        if (buttonIndex == 1 ){
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString * accessToken = appDelegate.welvu_userModel.access_token;
            // NSLog(@"Access Token =%@",accessToken);
            
            
            
            NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                          [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                          accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,nil];
            
            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
            if(appDelegate.welvu_userModel.org_id > 0) {
                [requestDataMutable
                 setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                 forKey:HTTP_REQUEST_ORGANISATION_KEY];
            }
            
            HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                  :PLATFORM_HOST_URL :PLATFORM_SEND_CONFIRMATION_EMAIL:HTTP_METHOD_POST
                                                  :requestDataMutable :nil];
            requestHandler.delegate = self;
            [requestHandler makeHTTPRequest];
            
            //   NSLog(@"Resend Activated token");
            
        }
        else
        {
            //   NSLog(@"Cancel");
        }
        
    }
    //EMR
    
    if ([alertView.title isEqualToString:NSLocalizedString(@"ALERT_PUSHING_TO_EMR", nil)]){
        NSString *path = nil;
        if (buttonIndex == 1 || buttonIndex == 2) {
            if(buttonIndex == 1)
            {
                update = [welvu_alerts updateAlertConfirmation:appDelegate.getDBPath :ALERT_PUSHING_TO_EMR];
            }
            NSString *path = nil;
            welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                                  queueId:appDelegate.recordCounter];
            if([captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                path = [NSString  stringWithFormat:@"%@/%@",
                        CACHE_DIRECTORY, welvuVideoModel.av_file_name];
            } else if(![captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                path = [NSString  stringWithFormat:@"%@/%@",
                        CACHE_DIRECTORY, welvuVideoModel.video_file_name];
            }
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"filePath %d",path]];
            
            
            [self shareContentVU:path];
            
            welvuVideoModel = nil;
            
        }  else if (buttonIndex ==3) {
            //  NSLog(@"cancel");
        }
        
    }
    //EMR
    
    if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_GESTURE_LIMITATION_TITLE", nil)]) {
        if (buttonIndex == 1 || buttonIndex == 2){
            zoomBtn.selected = true;
            [captureView bringSubviewToFront:gestureView];
            [annotationPencilBtn setSelected:false];
            [annotationArrowBtn setSelected:false];
            [annotationSquareBtn setSelected:false];
            [annotationCircleBtn setSelected:false];
            [annotationTextViewBtn setSelected:false];
            [annotateView isLineDrawingEnabled:false];
            [swipeLeft setEnabled:false];
            [swipeRight setEnabled:false];
            [annotateView clearScreen];
            [gestureView viewModificationGestureEnable:true];
            if(buttonIndex == 1) {
                update = [welvu_alerts updateAlertConfirmation:appDelegate.getDBPath:ALERT_GESTURE_LIMITATION_TITLE];
            }
        }
    }else if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_SHARE_PLAY_TITLE", nil)]) {
        if (buttonIndex == 0) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"ALERT_PHI_VIDEO_TITLE", nil)
                                  message:nil
                                  delegate: self
                                  cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                  otherButtonTitles:NSLocalizedString(@"YES", nil),nil];
            [alert show];
        } else if(buttonIndex == 1) {
            NSString *path = nil;
            welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                                  queueId:appDelegate.recordCounter];
            if([captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                path = [NSString  stringWithFormat:@"%@/%@",
                        CACHE_DIRECTORY, welvuVideoModel.av_file_name];
            } else if(![captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                path = [NSString  stringWithFormat:@"%@/%@",
                        CACHE_DIRECTORY, welvuVideoModel.video_file_name];
            }
            [self replayViewBtnClicked:path];
            welvuVideoModel = nil;
        }
    } else if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_PHI_VIDEO_TITLE", nil)]) {
        if (buttonIndex == 0) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"ALERT_SAVE_SENDEMAIL_TITLE", nil)
                                  message:nil
                                  delegate: self
                                  cancelButtonTitle:NSLocalizedString(@"SAVE", nil)
                                  otherButtonTitles:NSLocalizedString(@"SEND_EMAIL", nil),nil];
            [alert show];
        } else if(buttonIndex == 1) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"ALERT_HIPAA_INFO_TITLE", nil)
                                  message: NSLocalizedString(@"ALERT_HIPPA_INFO_MSG", nil)
                                  delegate: self
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil];
            [alert show];
        }
    } else if ([alertView.title isEqualToString:NSLocalizedString(@"ALERT_HIPAA_INFO_TITLE", nil)] ||
               [alertView.title isEqualToString:NSLocalizedString(@"ALERT_DEFAULT_MAIL_TITLE", nil)]) {
        //Actually portal sharing should come here
        
        if(buttonIndex == 1 || buttonIndex == 2) {
            
            if(buttonIndex == 1 &&
               [alertView.title isEqualToString:NSLocalizedString(@"ALERT_HIPAA_INFO_TITLE", nil)]) {
                update = [welvu_alerts updateAlertConfirmation:appDelegate.getDBPath :ALERT_HIPAA_INFO_TITLE];
            } else if (buttonIndex == 1 &&
                       [alertView.title isEqualToString:NSLocalizedString(@"ALERT_DEFAULT_MAIL_TITLE", nil)]) {
                update = [welvu_alerts updateAlertConfirmation:appDelegate.getDBPath :ALERT_DEFAULT_MAIL_TITLE];
            }
            
            NSString *path = nil;
            welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                                  queueId:appDelegate.recordCounter];
            if([captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                path = [NSString  stringWithFormat:@"%@/%@",
                        CACHE_DIRECTORY, welvuVideoModel.av_file_name];
            } else if(![captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                path = [NSString  stringWithFormat:@"%@/%@",
                        CACHE_DIRECTORY, welvuVideoModel.video_file_name];
            }
            
            
            
            if (appDelegate.networkReachable) {
                [self shareVUContentWithPath:path];
            }else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                                message:NSLocalizedString(@"ALERT_PURCHASE_FAILED_MSG", nil)
                                                               delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)otherButtonTitles:nil];
                
                [alert show];
            }
            welvuVideoModel = nil;
        } else {
            BOOL validateSubscription = [self checkSubscriptionFeasibility];
            if(!validateSubscription) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSInteger shareCount = [userDefaults integerForKey:
                                        [NSString stringWithFormat:@"Specialty_%d", appDelegate.specialtyId  ]];
                shareCount--;
                [userDefaults setInteger:shareCount forKey:[NSString stringWithFormat:@"Specialty_%d", appDelegate.specialtyId]];
            }
        }
    } else if ([alertView.title isEqualToString:NSLocalizedString(@"ALERT_SAVE_SENDEMAIL_TITLE", nil)]) {
        NSString *path = nil;
        welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                              queueId:appDelegate.recordCounter];
        if([captureView isRecordingAudio] && [captureView isRecordingVideo]) {
            path = [NSString  stringWithFormat:@"%@/%@",
                    CACHE_DIRECTORY, welvuVideoModel.av_file_name];
        } else if(![captureView isRecordingAudio] && [captureView isRecordingVideo]) {
            path = [NSString  stringWithFormat:@"%@/%@",
                    CACHE_DIRECTORY, welvuVideoModel.video_file_name];
        }
        if (buttonIndex == 0) {
            if (path != nil && UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (path)) {
                UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil);
            }
        } else if(buttonIndex == 1) {
            [self displayComposerSheet:path];
        }
        welvuVideoModel = nil;
    } else if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_MEMORY_ALERT_WARNING_HEADER", nil)]) {
        welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                              queueId:appDelegate.recordCounter];
        if([captureView isRecordingAudio] && [captureView isRecordingVideo] && !suspendedWhileFusingVideo) {
            [captureView combineVideoAudio:welvuVideoModel.generic_file_name videoVUId:welvuVideoModel.welvu_video_id];
            [self performCombineVideo];
        } else if(![captureView isRecordingAudio] && [captureView isRecordingVideo]){
            [captureView combineDisclaimer:welvuVideoModel.generic_file_name videoVUId:welvuVideoModel.welvu_video_id];
            [self performCombineVideo];
        }
        
        if(captureView.moviePlayer != nil) {
            [captureView.moviePlayer stop];
            [captureView.moviePlayer prepareToPlay];
            playVideoBtn.selected = false;
        }
        welvuVideoModel = nil;
    }
}

//Get Thumbnail of the image for button
-(UIImage *) getThumbnailImage:(UIImage *) originalImage {
    CGSize destinationSize = CGSizeMake((THUMB_MINI_IMAGE_WIDTH - 10), (THUMB_MINI_IMAGE_HEIGHT - 7));
    UIImage *thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:NO];
    return thumbnail;
}
//Retain the annotation on the image
-(void) retainAnnotatedImage:(NSInteger) currentImageNumber {
    /*UIGraphicsBeginImageContext(captureView.bounds.size);
     [captureView.layer renderInContext:UIGraphicsGetCurrentContext()];
     welvu_imagesModel.retainedAnnotatedImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();*/
    
    welvu_images *welvu_imagesModel = [imageGallery objectAtIndex:currentImageNumber];
    if(![welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_TYPE]
       && ![welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE]) {
        UIGraphicsBeginImageContext(captureView.bounds.size);
        [captureView.layer renderInContext:UIGraphicsGetCurrentContext()];
        NSArray *parts = [welvu_imagesModel.url componentsSeparatedByString:@"/"];
        NSString *filename = [parts objectAtIndex:[parts count]-1];
        NSString* outputPath = [NSString stringWithFormat:@"%@/%d%@",
                                CACHE_DIRECTORY, welvu_imagesModel.imageId, filename];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
            [[NSFileManager defaultManager] removeItemAtPath: outputPath error:NULL];
        }
        
        if([UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext()) writeToFile:outputPath atomically:YES]) {
            welvu_imagesModel.retainedAnnotatedImageUrl = [NSString stringWithFormat:@"%@/%d%@",
                                                           CACHE_DIRECTORY, welvu_imagesModel.imageId, filename];
            
            
            UIImage *originalImage = nil;
            NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.retainedAnnotatedImageUrl];
            originalImage = [UIImage imageWithData:imageData];
            UIImage *thumbnail = [self getThumbnailImage:originalImage];
            
            for(UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(currentImageNumber + 1)]) subviews]) {
                if([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)subview;
                    imageView.frame = CGRectMake((NSInteger)(THUMB_MINI_IMAGE_WIDTH - thumbnail.size.width)/ 2,
                                                 (NSInteger)(THUMB_MINI_IMAGE_HEIGHT - thumbnail.size.height)/ 2,
                                                 thumbnail.size.width, thumbnail.size.height);
                    imageView.image = [[thumbnail imageWithBorderForUnselected:THUMB_MINI_IMAGE_BORDER]  makeRoundCornerImage:5 :5];
                }
            }
        }
        UIGraphicsEndImageContext();
        NSURL* outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
        int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:outputURL];
        
    }
}
- (UIImage *)capturedViewVU
{
    /* Capture the screen shoot at native resolution */
    UIImage * customScreenShot=NULL;
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    if (scale > 1.0)
    {
        UIGraphicsBeginImageContextWithOptions(captureView.bounds.size, captureView.opaque, 0.0);
        [captureView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * screenshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGRect cropRect = CGRectMake(RETINA_DISPLAY_XAXIS ,RETINA_DISPLAY_YAXIS ,RETINA_DISPLAY_HEIGHT ,RETINA_DISPLAY_WIDTH);
        UIGraphicsBeginImageContextWithOptions(cropRect.size, captureView.opaque, 1.0f);
        [screenshot drawInRect:cropRect];
    }
    else
    {
        UIGraphicsBeginImageContextWithOptions(captureView.bounds.size, captureView.opaque, 0.0f);
        [captureView.layer renderInContext:UIGraphicsGetCurrentContext()];
        
    }
    customScreenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return customScreenShot;
}

//To clear annotation and to resore image to orignal
-(void) clearAnnotationFromImage:(NSInteger) currentImageNumber {
    welvu_images *welvu_imagesModel = [imageGallery objectAtIndex:currentImageNumber];
    welvu_imagesModel.retainedAnnotatedImageUrl = nil;
    if(![welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_TYPE]
       && ![welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE]) {
        UIImage *thumbnail;
        
        
        
        
        if([welvu_imagesModel.type isEqualToString:IMAGE_PATIENT_TYPE]) {
            // NSLog(@"pateint url %@",welvu_imagesModel.imageData);
            NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            thumbnail = [self getThumbnailImage:[UIImage imageWithData:imageData]];        }
        
        
        
        
        else if([welvu_imagesModel.type isEqualToString:VIDEO_PATIENT_TYPE]) {
            //  NSLog(@"pateint url %@",welvu_imagesModel.imageData);
            
            thumbnail = [self getThumbnailImage:welvu_imagesModel.imageData];
        }
        
        else if([welvu_imagesModel.type isEqualToString:GRAPH_IMAGE_TYPE]) {
            // NSLog(@"pateint url %@",welvu_imagesModel.imageData);
            
            thumbnail = [self getThumbnailImage:welvu_imagesModel.imageData];          }
        
        
        
        
        else if([welvu_imagesModel.type isEqualToString:IMAGE_PATIENTINFO_TYPE]) {
            // NSLog(@"pateint url %@",welvu_imagesModel.imageData);
            
            thumbnail = [self getThumbnailImage:welvu_imagesModel.imageData];        }
        
        else if([welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE]) {
            NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            thumbnail = [self getThumbnailImage:[UIImage imageWithData:imageData]];
            
            
        }
        
        else if([welvu_imagesModel.type isEqualToString:IMAGE_BLANK_TYPE]) {
            UIImage *originalImage = [UIImage imageNamed:welvu_imagesModel.url];
            thumbnail = [self getThumbnailImage:originalImage];
        }
        
        else if([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] && welvu_imagesModel.imageId > 0) {
            UIImage *originalImage = nil;
            if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
                NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
                originalImage = [UIImage imageWithData:imageData];
            } else {
                originalImage = welvu_imagesModel.imageData;
            }
            thumbnail = [self getThumbnailImage:originalImage];
        } else if([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] && welvu_imagesModel.imageId == 0) {
            thumbnail = [self getThumbnailImage: welvu_imagesModel.imageData];
        }
        
        for(UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(currentImageNumber + 1)]) subviews]) {
            if([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)subview;
                imageView.frame = CGRectMake((NSInteger)(THUMB_MINI_IMAGE_WIDTH - thumbnail.size.width)/ 2,
                                             (NSInteger)(THUMB_MINI_IMAGE_HEIGHT - thumbnail.size.height)/ 2,
                                             thumbnail.size.width, thumbnail.size.height);
                imageView.image = [[thumbnail imageWithBorderForSelected:THUMB_MINI_IMAGE_BORDER]  makeRoundCornerImage:5 :5];
            }
        }
        [self loadImageToCanvas:welvu_imagesModel];
    }
    [annotateView clearScreen];
}
//SET THE ZOOM VIEW TO NORMAL VIEW
-(void)setZoomToNormal {
    [gestureView setZoomToNormal];
    _detailImageView.frame = CGRectMake(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
}
// APP ENTER TO ACTIVE STATE
-(IBAction)appDidBecomeActive:(id)sender {
    /* id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_ANALYTICS_WELVU_KEY];
     //[tracker trackEventWithCategory:@"action" withAction:@"settngs" withLabel:@"settngs" withValue:1];
     [tracker trackEventWithCategory:@"Video-Maker-PatientVU - VM"
     withAction:@"appDidBecomeActive"
     withLabel:@"applicationactive"
     withValue:[NSNumber numberWithInt:1]];
     
     @try {*/
    if(suspendedWhileFusingVideo) {
        captureView.isExportCompleted = false;
        suspendedWhileFusingVideo = false;
        //[self performSelectorInBackground:@selector(combineVideo_Audio) withObject:nil];
        welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                              queueId:appDelegate.recordCounter];
        [captureView combineVideoAudio:welvuVideoModel.generic_file_name videoVUId:welvuVideoModel.welvu_video_id];
        [self performSelector:@selector(doYouWantShare_playAlert)];
    }
}
/* @catch (NSException *exception) {
 [tracker trackException:NO // Boolean indicates non-fatal exception.
 withDescription:@"Video-Maker-PatientVU-VM_appDidBecomeActive: %@",exception ];
 }
 }*/
//APPLICATION ENTER INTO THE BACKGROUNF STATE
-(IBAction)appHasGoneInBackground:(id)sender {
    /* id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_ANALYTICS_WELVU_KEY];
     //[tracker trackEventWithCategory:@"action" withAction:@"settngs" withLabel:@"settngs" withValue:1];
     [tracker trackEventWithCategory:@"Video-Maker-PatientVU - VM"
     withAction:@"appHasGoneInBackground"
     withLabel:@"applicationruninbg"
     withValue:[NSNumber numberWithInt:1]];
     
     @try {*/
    if(captureView.isRecording) {
        if([captureView isRecordingAudio] && [captureView isRecordingVideo]) {
            suspendedWhileFusingVideo = true;
        }
        [self performSelector:@selector(recordBtnClicked:) withObject:nil];
        
    }
}
/* @catch (NSException *exception) {
 [tracker trackException:NO // Boolean indicates non-fatal exception.
 withDescription:@"Video-Maker-PatientVU-VM_appHasGoneInBackground: %@",exception ];
 }
 }*/

//GET THE CONTENT NAME FOR RECORDED VIDEO
-(NSString *) getRecordContentName {
    welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                          queueId:appDelegate.recordCounter];
    
    return welvuVideoModel.generic_file_name;
}
//GESTURE CONTROL STARTED
-(void)gestureControlViewDidStarted {
    captureView.touchBeganFlag = true;
    captureView.vuModifiedFlag = false;
}
//GESTURE CONTROL FINSHED
-(void)gestureControlViewDidFinish {
    //  NSLog(@"Gesture Modification completed");
    [captureView vuModified];
}
//CHECK THE SUBCRIPTION FEASIBLITY FOR THE CONTENT IN INAPP PURCHASE
-(BOOL)checkSubscriptionFeasibility {
    
    NSString *accessToken = nil;
    if(appDelegate.welvu_userModel.access_token == nil) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
    } else {
        accessToken = appDelegate.welvu_userModel.access_token;
    }
    
    //  NSLog( @"access token %@",accessToken);
    //if subcription is there then bool valid will be false;
    BOOL valid = false;
    
    //BOOL valid = true;
    welvu_specialty *welvu_specialtyModel = [welvu_specialty
                                             getSpecialtyById:[appDelegate getDBPath]
                                             specialtyId:appDelegate.specialtyId
                                             userId:appDelegate.welvu_userModel.welvu_user_id];
    if(welvu_specialtyModel.welvu_specialty_subscribed) {
        
        NSDate *subscriptionStartDate = welvu_specialtyModel.subscriptionStartDate;
        NSDate *subscriptionEndDate = welvu_specialtyModel.subscriptionEndDate;
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [dateFormatter setTimeZone:gmt];
        [dateFormatter setDateFormat:SERVER_DATE_COMPARE_FORMAT];
        NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
        NSLog(@"gmt date %@" ,timeStamp);
        
        NSDate *dateFromString = [[NSDate alloc] init];
        dateFromString = [dateFormatter dateFromString:timeStamp];
        NSLog(@"dateFromString%@",dateFromString);
        
        
        NSDate *dateFromString1 = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
        
        NSLog(@"dateFromString1%@",dateFromString1);
        
        //START SUBCRIPTION DATE
        NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
        [startDateFormatter setDateFormat:SERVER_DATE_COMPARE_FORMAT];
        NSDate *startServerDate = [NSString stringWithFormat:@"%@",[startDateFormatter stringFromDate:subscriptionStartDate]];
        
        NSLog(@"startServerDate%@",startServerDate);
        
        //END SUBCRIPTION DATE
        NSDateFormatter *endDateFormatter = [[NSDateFormatter alloc] init];
        [endDateFormatter setDateFormat:SERVER_DATE_COMPARE_FORMAT];
        NSDate *endServerDate = [NSString stringWithFormat:@"%@",[endDateFormatter stringFromDate:subscriptionEndDate]];
        
        NSLog(@"endServerDate%@",endServerDate);
        
        NSComparisonResult startCompare = [startServerDate compare: dateFromString1];
        NSComparisonResult endCompare = [endServerDate compare: dateFromString1];
        
        NSComparisonResult endDateCompare = [endServerDate compare: dateFromString1];
        if(startCompare == NSOrderedAscending  && endCompare == NSOrderedSame){
            valid = true;
           
        }
        else if(startCompare == NSOrderedSame  && endCompare == NSOrderedDescending){
            valid = true;
           
        }
        
        else if (startCompare == NSOrderedAscending && endCompare == NSOrderedDescending)
        {
            valid = true;
        }  else if (endDateCompare == NSOrderedAscending ){
            if (!appDelegate.networkReachable){
                /// Create an alert if connection doesn't work
                UIAlertView *myAlert = [[UIAlertView alloc]
                                        initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                        message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                        delegate:self
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
                [myAlert show];
            } else {
                if([[NSUserDefaults standardUserDefaults] objectForKey:
                    [NSString stringWithFormat:@"Specialty_Receipt_%d",appDelegate.specialtyId]]) {
                    ReceiptCheck *checker = [[ReceiptCheck alloc] initWithReceiptHandler:
                                             [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Specialty_Receipt_%d",appDelegate.specialtyId]] specialtyId:appDelegate.specialtyId];
                    if(checker.statusCode == 0 || checker.statusCode == 21006) {
                        valid = true;
                    }
                    
                    if(checker.statusCode == 21006) {
                        welvu_specialty *specId = [welvu_specialty getSpecialtyById:[appDelegate getDBPath]
                                                                        specialtyId:appDelegate.specialtyId
                                                                             userId:appDelegate.welvu_userModel.welvu_user_id];
                        NSString *productId = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Specialty_IDentifier_%d",appDelegate.specialtyId]];
                        NSDate *subscriptionStartDate = [NSDate date];
                        NSDate *subscriptionEndDate;
                        NSString *productIdentifier;
                        if([specId.product_identifier isEqualToString:productId]) {
                            productIdentifier = specId.product_identifier;
                            subscriptionEndDate = [subscriptionStartDate dateByAddingTimeInterval:3600*24*30];
                        } else {
                            productIdentifier = specId.yearly_product_identifier;
                            subscriptionEndDate = [subscriptionStartDate dateByAddingTimeInterval:3600*24*365];
                        }
                        //NeedToCheck
                        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                        BOOL insert = [welvu_topics updateLock:[appDelegate getDBPath]
                                                     specialty:specId.welvu_specialty_id setLock:false
                                                        userId:appDelegate.welvu_userModel.welvu_user_id];
                        [[NSUserDefaults standardUserDefaults] setInteger:0
                                                                   forKey:[NSString stringWithFormat:@"Specialty_%d", specId.welvu_platform_id]];
                        if(insert) {
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
                            NSString *validFrom = [dateFormatter stringFromDate:subscriptionStartDate];
                            NSString *validTill = [dateFormatter stringFromDate:subscriptionEndDate];
                            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                            NSString *transactionRecipt = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Specialty_Receipt_%d",specId.welvu_platform_id]];
                            NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                                          accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                                          productIdentifier, HTTP_RESPONSE_PRODUCT_IDENTIFIER,
                                                          [NSNumber numberWithInteger:specId.welvu_specialty_id], HTTP_SPECIALTY_ID,
                                                          validFrom, HTTP_REQUEST_SUBSCRIPTION_START_DATE,
                                                          validTill, HTTP_REQUEST_SUBSCRIPTION_END_DATE,
                                                          transactionRecipt, HTTP_REQUEST_TRANSACTION_RECEIPT,
                                                          nil];
                            
                            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
                            if(appDelegate.welvu_userModel.org_id > 0) {
                                [requestDataMutable
                                 setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                                 forKey:HTTP_REQUEST_ORGANISATION_KEY];
                            }
                            
                            HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                                  :PLATFORM_HOST_URL:PLATFORM_SPECIALTY_SUBSCRIBED:HTTP_METHOD_POST
                                                                  :requestDataMutable :nil];
                            requestHandler.delegate = self;
                            [requestHandler makeHTTPRequest];
                            
                            update =[welvu_specialty updateSubscribedSpecialty:appDelegate.getDBPath
                                                                   specialtyId:appDelegate.specialtyId
                                                         subscriptionStartDate:subscriptionStartDate subscriptionEndDate:subscriptionEndDate userId:appDelegate.welvu_userModel.welvu_user_id];
                        }
                    }
                }
            }
        }
    }
    return valid;
        }

   

//Need to work here
- (void)didReceiveMemoryWarning {
    if(recordBtn.selected) {
        //  NSLog(@"Video Controller received memory warning");
        ipxBtn.enabled = true;
        shareBtn.enabled = true;
        youtubeBtn.enabled=true;
        playBtn.enabled = true;
        settingsBtn.enabled = true;
        feedbackBtn.enabled = true;
        pauseBtn.enabled = false;
        pauseBtn.selected = false;
        recordBtn.selected = false;
        welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                              queueId:appDelegate.recordCounter];
        [captureView stopRecording:welvuVideoModel.video_file_name];
        [welvu_video updateVideoQueueStatus:[appDelegate getDBPath] videoVUId:welvuVideoModel.welvu_video_id
                                     status:WELVU_RECORD_STATUS_STOPED];
        welvuVideoModel = nil;
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_MEMORY_ALERT_WARNING_HEADER", nil)
                                                        message:NSLocalizedString(@"ALERT_MEMORY_ALERT_WARNING_TITLE", nil)
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil)otherButtonTitles:nil];
        
        [alert show];
    }
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
//ANIMATED BUTTON OFF

- (void)flashOff:(UIView *)v
{
    [animatedButton stopAnimating];
}
//ANIMATED BUTTON OFF
- (void)flashOn:(UIView *)v
{
    [animatedButton startAnimating];
}

#pragma MARK UIInterfaceOrientation
int deviceOrientation;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    deviceOrientation = interfaceOrientation;
    // Return YES for supported orientations
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft
       || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return YES;
    }
	return NO;
}

- (BOOL)shouldAutorotate {
    return [self shouldAutorotateToInterfaceOrientation:self.interfaceOrientation];
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}


- (void)startUpViewController
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self shouldAutorotate];
}

-(void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    //[captureView setNeedsDisplay];
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    UIEdgeInsets inset = aScrollView.contentInset;
    float x = offset.x + bounds.size.width - inset.right;
    
    if (aScrollView.contentOffset.x <= 0) {
        self.bottomFadingView.hidden = true;
    }
    
    if(aScrollView.contentOffset.x <= aScrollView.contentSize.width) {
        self.bottomFadingView.hidden = false;
    }
    
    if(x >= aScrollView.contentSize.width) {
        self.topFadingView.hidden = false;
        self.bottomFadingView.hidden = true;
    }
    
    if (aScrollView.contentOffset.x <= 0) {
        self.topFadingView.hidden = true;
    }
    
    if (aScrollView.contentOffset.x > 5) {
        self.topFadingView.hidden = false;
    }
}
//ALERT SHOWING TO SHARE USING YOU TUBE
-(void) doYouWantShareToYouTube {
    if (appDelegate.networkReachable) {
        welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                              queueId:appDelegate.recordCounter];
        
        if (appDelegate.currentWelvuSettings.securedSharing == SETTINGS_SHARE_VU_SECURED) {
            if(![welvu_alerts canAlertShowAgain:appDelegate.getDBPath :ALERT_HIPAA_INFO_TITLE]) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: NSLocalizedString(@"ALERT_HIPAA_INFO_TITLE", nil)
                                      message: NSLocalizedString(@"ALERT_HIPPA_INFO_MSG", nil)
                                      delegate: self
                                      cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                      otherButtonTitles:NSLocalizedString(@"DONT_SHOW_AGAIN", nil), NSLocalizedString(@"CONTINUE", nil),nil];
                [alert show];
            } else {
                NSString *path = nil;
                if([captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                    path = [NSString  stringWithFormat:@"%@/%@",
                            CACHE_DIRECTORY, welvuVideoModel.av_file_name];
                } else if(![captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                    path = [NSString  stringWithFormat:@"%@/%@",
                            CACHE_DIRECTORY, welvuVideoModel.video_file_name];
                }
                [self shareVUContentWithPath:path];
            }
            
        } else {
            if(![welvu_alerts canAlertShowAgain:appDelegate.getDBPath :ALERT_DEFAULT_MAIL_TITLE]) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: NSLocalizedString(@"ALERT_DEFAULT_MAIL_TITLE", nil)
                                      message: NSLocalizedString(@"ALERT_DEFAULT_MAIL_MSG", nil)
                                      delegate: self
                                      cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                      otherButtonTitles:NSLocalizedString(@"DONT_SHOW_AGAIN", nil), NSLocalizedString(@"CONTINUE", nil),nil];
                [alert show];
            } else {
                NSString *path = nil;
                if([captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                    path = [NSString  stringWithFormat:@"%@/%@",
                            CACHE_DIRECTORY, welvuVideoModel.av_file_name];
                } else if(![captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                    path = [NSString  stringWithFormat:@"%@/%@",
                            CACHE_DIRECTORY, welvuVideoModel.video_file_name];
                }
                
                [self shareVUContentWithPath:path];
            }
        }
        welvuVideoModel = nil;
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                        message:NSLocalizedString(@"ALERT_PURCHASE_FAILED_MSG", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)otherButtonTitles:nil];
        
        [alert show];
    }
}
- (void)themeSettingsViewControllerDidFinish {
    
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    if(appDelegate.welvu_userModel.org_id > 0) {
        NSString *logoName = [welvu_organization getOrganizationLogoNameById:[appDelegate getDBPath] :appDelegate.welvu_userModel.org_id];
        
        if([logoName isEqualToString:@""]) {
            themeLogo.image = [UIImage imageNamed:@"WelvuLogoBanner.png"];
            
        } else {
            
            appDelegate.org_Logo = ([welvu_organization getOrganizationDetailsById
                                     :[appDelegate getDBPath]
                                     orgId:appDelegate.welvu_userModel.org_id]).orgLogoName;
            
            
            
            [themeLogo setImage:[UIImage imageWithContentsOfFile:appDelegate.org_Logo]];
            
            //  themeLogo.image = [UIImage imageWithContentsOfFile:appDelegate.org_Logo];
            
        }
    } else {
        themeLogo.image = [UIImage imageNamed:@"WelvuLogoBanner.png"];
    }
    
    [self.view bringSubviewToFront:themeLogo];
    
}

#pragma mark ShareToEMR
-(void) doYouWantShareToEMR_playAlert {
    
    BOOL validateSubscription = [self checkSubscriptionFeasibility];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger shareCount = [userDefaults integerForKey:[NSString stringWithFormat:@"Specialty_%d", appDelegate.specialtyId]];
    NSDictionary *patientID=appDelegate.currentPatientInfo;
    NSString *patientName =[patientID objectForKey:@"fname"];
    //  NSLog(@"fname %@",patientName);
    NSString *conAlertName = @"Would you like to push this video into the EMR of patient :";
    conAlertName = [conAlertName stringByAppendingString:patientName];
    //  NSLog(@"%@", conAlertName);
    if (networkReachable) {
        if(![welvu_alerts canAlertShowAgain:appDelegate.getDBPath :ALERT_PUSHING_TO_EMR]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"ALERT_PUSHING_TO_EMR", nil)
                                  message: @""
                                  delegate: self
                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                  otherButtonTitles:NSLocalizedString(@"DONT_SHOW_AGAIN", nil), NSLocalizedString(@"CONTINUE", nil),nil];
            alert.delegate = self;
            [alert show];
            
        }
        else {
            NSString *path = nil;
            welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath]
                                                                  queueId:appDelegate.recordCounter];
            if([captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                path = [NSString  stringWithFormat:@"%@/%@",
                        CACHE_DIRECTORY, welvuVideoModel.av_file_name];
            } else if(![captureView isRecordingAudio] && [captureView isRecordingVideo]) {
                path = [NSString  stringWithFormat:@"%@/%@",
                        CACHE_DIRECTORY, welvuVideoModel.video_file_name];
            }
            
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"filePath %d",path]];
            [self shareContentVU:path];
            welvuVideoModel = nil;
        }
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                        message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_MSG", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)otherButtonTitles:nil];
        
        [alert show];
        
    }
    
    
    
}

- (void) reachabilityChanged: (NSNotification* )note {
    Reachability* curReach = [note object];
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    if(netStatus == NotReachable) {
        networkReachable = false;
    } else {
        networkReachable = true;
    }
}
//EMR
- (void) shareContentVU:(NSString *) path {
    appDelegate.isEMRVUInProgress = true;
    if(captureView.isExportCompleted) {
        if(spinner != nil) {
            [spinner removeSpinner];
        }
        
        welvu_message *welvu_messageModel = [[welvu_message alloc] initWithMessageId:1];
        welvu_messageModel.videoFileName = [self getRecordContentName];
        welvu_messageModel.videoFileLocation = path;
        welvu_messageModel.service = CONSTANT_SERVICE_EMR;
        ShareVUContentPlatformHelper *shareVUContentHelper =
        [[ShareVUContentPlatformHelper alloc] initWithEMRVuContent:welvu_messageModel :PLATFORM_HOST_URL3:PLATFORM_SEND_MESSAGE_ACTION_OPENEMR_URL];
        shareVUContentHelper.delegate = self;
        [shareVUContentHelper shareEMRVUContents];
    } else {
        [self performSelector:@selector(shareContentVU:) withObject:path afterDelay:2];
    }
}

#pragma mark - ShareVUContent Platform helper Delegate
-(void)shareVUContentUploadSendResponse:(BOOL)success {
    
}

-(void)shareVUContentPlatformDidReceivedData:(BOOL) success:(NSDictionary *) responseDictionary {
    if(success) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:NOTIFY_MAIL_SENT
         object:self userInfo:responseDictionary];
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.isEMRVUInProgress = false;
    }
}

-(void)shareVUContentFailedWithErrorDetails:(NSError *)error {
    
}
/*
 * Method name: ipxBtnClicked
 * Description: To View the save iPx
 * Parameters: sender
 * return IBAction
 
 */


//INTERSYSTEM


- (void) shareiPxwithPath:(NSString *) path {
    
    if(captureView.isExportCompleted) {
        if(spinner != nil) {
            [spinner removeSpinner];
        }
        shareIpxContents = [[welvuiPxShareViewController alloc]initWithNibName:@"welvuiPxShareViewController" bundle:nil];
        shareIpxContents.ipx_videoFileName = [self getRecordContentName];
        shareIpxContents.ipx_videoFileLocation = path;
        
        shareIpxContents.delegate=self;
        
        shareIpxContents.modalPresentationStyle = UIModalPresentationFormSheet;
        shareIpxContents.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        
        
        UINavigationController *cntrol = [[UINavigationController alloc]
                                          initWithRootViewController:shareIpxContents];
        [cntrol setNavigationBarHidden:YES];
        cntrol.navigationBar.barStyle = UIBarStyleBlack;
        cntrol.modalPresentationStyle = UIModalPresentationFormSheet;
        cntrol.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:cntrol animated:YES];
        cntrol.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        cntrol.view.superview.frame = CGRectMake(
                                                 // Calcuation based on landscape orientation (width=height)
                                                 ([UIScreen mainScreen].applicationFrame.size.height/2)-(540/2),// X
                                                 ([UIScreen mainScreen].applicationFrame.size.width/2)-(502/2),// Y
                                                 540,// Width
                                                 502// Height
                                                 );        cntrol.view.contentMode = UIViewContentModeCenter;
        cntrol.view.superview.backgroundColor = [UIColor clearColor];} else {
            [self performSelector:@selector(shareiPxwithPath:) withObject:path afterDelay:2];
        }
}


//Welvu-HEV
/*
 * Method name: saveToAlbumBtnClicked
 * Description: To save the user created video into Photo Album
 * Parameters: sender
 * return IBAction
 */
- (IBAction)saveToAlbumBtnClicked:(id)sender {
    
    if(appDelegate.welvu_userModel.org_id > 0) {
        UIAlertView *AlertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"ALERT_SAVE_VIDEO_TO_PHOTO_ALBUM", nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"CONFIRM", nil),NSLocalizedString(@"CANCEL", nil), nil];
        // AlertView.tag =200;
        [AlertView show];

    }else{
        UIAlertView *myAlert = [[UIAlertView alloc]
                                initWithTitle:NSLocalizedString(@"UPGRADE_TITLE", nil)
                                message:nil
                                delegate:self
                                cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                otherButtonTitles:NSLocalizedString(@"UPGRADE", nil),nil];
        myAlert.tag = 123;
        [myAlert show];
    }
    

    
    
}
- (void)video:(NSString *) videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    if(error)
        NSLog(@"didFinishSavingWithError: %@", error);
    
}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if(popOver != nil) {
        [popOver dismissPopoverAnimated:YES];
        popOver = nil;
        popoverController = nil;
    }
}
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [self.canvas clear];
}



@end
