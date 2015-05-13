//
//  welvuTopicVUAnnotationViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 24/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvuTopicVUAnnotationViewController.h"
#import "welvu_topics.h"
#import "welvu_images.h"
#import "welvuContants.h"
#import "UIImage+Resize.h"
#import "welvu_alerts.h"
#import "NSFileManagerDoNotBackup.h"
#import "GAI.h"
#import "Guid.h"
#import "welvu_sync.h"



@interface welvuTopicVUAnnotationViewController () {
    BOOL isModificationSaved;
    BOOL isModified;
    int currentImage;
    int prevImage;
}
- (void)buildImageGroups;
- (void)loadImageToCanvas:(welvu_images *)welvu_imagesModel;
- (void)removeDeckImages;
- (UIImage *)getThumbnailImage:(UIImage *)originalImage;
- (UIImage *)captureAnnotation;
- (void)retainAnnotatedImage:(NSInteger)currentImageNumber;
- (void)clearAnnotationFromImage:(NSInteger)currentImageNumber;
- (void)setZoomToNormal;
@end

@implementation welvuTopicVUAnnotationViewController
@synthesize delegate,update;
@synthesize annotateBanner;
@synthesize themeLogo;
@synthesize notificationLable;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
 * Method name: initWithImageGroup
 * Description: handles in Topic naming and database
 * Parameters: NSString,NSBundle, NSInteger, NSMutableArray
 * Return Type: self
 */
- (id)initWithImageGroup:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil currentTopicId:(NSInteger) topic_Id
                  images:(NSMutableArray *)topicVUImages currentSelectedImage:(NSInteger)currentImageRow
     annotateBlankCanvas:(BOOL)isAnnotateBlankCanvas {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self themeSettingsViewControllerDidFinish];
        
        topicId = topic_Id;
        imageGallery = topicVUImages;
        isModified = false;
        isModificationSaved = false;
        if (!isAnnotateBlankCanvas) {
            // Custom initialization
            currentImage = currentImageRow;
            prevImage = currentImageRow;
        } else {
            NSDate *date = [NSDate date];
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = YEAR_MONTH_DATE_TIME_FORMAT;
            
            welvu_images * blankCanvas = [[welvu_images alloc]init];
            blankCanvas.topicId = topicId;
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
            blankCanvas.imageDisplayName = [NSString stringWithFormat:@"%@_%@",
                                            [welvu_topics getTopicNameById:appDelegate.getDBPath :topicId
                                                                    userId:appDelegate.welvu_userModel.welvu_user_id],
                                            [dateFormatter stringFromDate:date]];
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
            if (imageGallery == nil) {
                imageGallery = [[NSMutableArray alloc] initWithCapacity:1];
            }
            [imageGallery addObject:blankCanvas];
            currentImage = [imageGallery count]-1;
            prevImage = currentImage;
        }
    }
    return self;
}
/*
 * Method name: initWithSelectedImage
 * Description: Initlizing with the selected image id
 * Parameters: topic_Id,imagesId,currentTopicId
 * Return Type: self
 */

- (id)initWithSelectedImage:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil currentTopicId:(NSInteger) topic_Id
                   imagesId:(NSInteger) image_id {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        isModified = false;
        isModificationSaved = false;
        imageId = image_id;
    }
    return self;
}

#pragma mark - View lifecycle
-(void)viewWillAppear:(BOOL)animated {
    if(appDelegate.networkReachable) {
        //NSLog(@"network is there");
         appDelegate.checkOrganizationUserLicense = false;
        [appDelegate checkUserLicense];
       

        
    } else {
        //  NSLog(@"network is not there");
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if ( appDelegate.showGuideEditVU == 0) {
        [self performSelector:@selector(informationBtnClicked:)withObject:nil];
        appDelegate.showGuideEditVU = 1;
    }
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Declaring Page View Analytics
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Annotation VU - TVA"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [self themeSettingsViewControllerDidFinish];
    // self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"EditvuWithBanner.png"]];
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    welvu_images *welvu_imageModel = [welvu_images getImageById:appDelegate.getDBPath :imageId
                                                         userId:appDelegate.welvu_userModel.welvu_user_id];
    
    //Intialize the Application delegate
    topicLabel.text = [welvu_topics getTopicNameById:appDelegate.getDBPath :welvu_imageModel.topicId
                                              userId:appDelegate.welvu_userModel.welvu_user_id];
    topicLabel.font = [UIFont boldSystemFontOfSize:22.0f];
    
    [self loadImageToCanvas:welvu_imageModel];
    
    //Enable Annotation on loading the view and set the default color
    [annotationPencilBtn setSelected:true];
    [annotateView isLineDrawingEnabled:true];
    [annotateView setStrokeColor:[UIColor redColor]];
    ((UIButton *) [self.view viewWithTag:1000]).selected = true;
    
	// One finger, two taps to enable/disable annotation
	// Create gesture recognizer, notice the selector method
    enable_disableAnnotation = [[UITapGestureRecognizer alloc]
                                initWithTarget:self action:@selector(enable_disableAnnotationBtnClicked:)];
    
    // Set required taps and number of touches
    [enable_disableAnnotation setNumberOfTapsRequired:2];
    [enable_disableAnnotation setNumberOfTouchesRequired:1];
    [annotationContainer addGestureRecognizer:enable_disableAnnotation];
    
    
    //Intialize gestures
    [gestureView initializeGestureWithMasterView:annotationContainer];
    [gestureView viewModificationGestureEnable:false];
    
    
    //[self buildImageGroups];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
#pragma mark Action Methods
/*
 * Method name: informationBtnClicked
 * Description: show the guide for the user
 * Parameters: id
 * return nil
 */
- (IBAction)informationBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"Guide Button  - TVA"
                                                           label:@"Guide"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
        [annotateView annotationTextViewConditions];
        overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        overlay.alpha = 1;
        overlay.backgroundColor = [UIColor clearColor];
        
        
        UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        UIButton *overlayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [overlayCustomBtn addTarget:self action:@selector(closeOverlay:) forControlEvents:UIControlEventTouchUpInside];
        [overlayCustomBtn setFrame:CGRectMake(0, 0, 1024, 768)];
        overlayImageView.image = [UIImage imageNamed:@"EditVUOverlay.png"];
        
        [overlay addSubview:overlayImageView];
        [overlay addSubview:overlayCustomBtn];
        
        [self.view addSubview:overlay];
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_Guide %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}
/*
 * Method name: closeOverlay
 * Description: overlayclose
 * Parameters: analytics
 * return nil
 * Created On: 19-dec-2012
 */
- (IBAction)closeOverlay:(id)sender{
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"close guide overlay - TVA"
                                                           label:@"overlayclosed"
                                                           value:nil] build]];
    
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        if (overlay !=nil) {
            [overlay removeFromSuperview];
            overlay = nil;
        }
        
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_closeOverlay %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}



/*
 * Method name: save_saveAsBtnClicked
 * Description: button handling save and save as functionalities
 * Parameters: id
 * Return Type: IBAction
 */
- (IBAction)save_saveAsBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"Save Annotation - TVA"
                                                           label:@"Save"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
        [annotateView annotationTextViewConditions];
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
        BOOL isAnnotationSaved = FALSE;
        
        UIImage *image = [self captureAnnotation];
        if ( annotateView.isAnnotationStarted) {
            isModified = TRUE;
            annotateView.isAnnotationStarted = FALSE;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FILENAME_FORMAT];
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            NSString *imageName = [dateFormatter stringFromDate:[NSDate date]];
            
            NSString *fullPath = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@.%@",
                                                                   DOCUMENT_DIRECTORY,
                                                                   imageName, HTTP_ATTACHMENT_IMAGE_EXT_KEY]];
            if ([imageData writeToFile:fullPath atomically:YES]){
                NSURL *outputURL = [NSURL fileURLWithPath:fullPath];
                int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:outputURL];
                if ([((welvu_images *)[welvu_images getImageById:appDelegate.getDBPath :imageId
                                                          userId:appDelegate.welvu_userModel.welvu_user_id]).type
                     isEqualToString:IMAGE_BLANK_TYPE]) {
                    welvu_images *welvu_imagesModel = [welvu_images getImageById:appDelegate.getDBPath :imageId
                                                                          userId:appDelegate.welvu_userModel.welvu_user_id];
                    welvu_imagesModel.type = IMAGE_ALBUM_TYPE;
                    welvu_imagesModel.url = [NSString stringWithFormat:@"%@.%@",
                                             imageName, HTTP_ATTACHMENT_IMAGE_EXT_KEY];
                    //welvu_imagesModel.image_guid=[[Guid randomGuid] description];
                    
                    
                    NSInteger updated = [welvu_images updateImageWithAnnotation:appDelegate.getDBPath :welvu_imagesModel
                                                                         userId:appDelegate.welvu_userModel.welvu_user_id];
                    if (updated > 0) {
                        insertedImageId = imageId;
                        isAnnotationSaved = TRUE;
                        [imageGallery replaceObjectAtIndex:currentImage withObject:[welvu_images getImageById:appDelegate.getDBPath:imageId
                                                                                                       userId:appDelegate.welvu_userModel.welvu_user_id]];
                        [annotateView clearScreen];
                        currentImage = ([imageGallery count] - 1);
                        prevImage = currentImage;
                        [self loadImageToCanvas:[imageGallery objectAtIndex:currentImage]];
                        //Test
                        NSDictionary *blankImageAnnotated = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                             [NSNumber numberWithInt:imageId], @"imageId", nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_BLANK_IMAGE_ANNOTATED object:self userInfo:blankImageAnnotated];
                        BOOL inserted = [welvu_sync addSyncDetail:[appDelegate getDBPath] guid:welvu_imagesModel.image_guid
                                                         objectId:imageId
                                                         syncType:SYNC_TYPE_CONTENT_CONSTANT
                                                       actionType:ACTION_TYPE_CREATE_CONSTANT];
                        SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
                        [dataToCloud startSyncDataToCloud:SYNC_TYPE_CONTENT_CONSTANT objectId:imageId
                                               actionType:HTTP_REQUEST_ACTION_TYPE_CREATE
                                                actionURL:PLATFORM_SYNC_CONTENTS];
                    }
                }
                
                else{
                    welvu_images *welvu_imagesModel = [[welvu_images alloc] init];
                    welvu_imagesModel.welvu_user_id = appDelegate.welvu_userModel.welvu_user_id;
                    welvu_imagesModel.topicId = ((welvu_images *)[welvu_images getImageById:appDelegate.getDBPath :imageId
                                                                                     userId:welvu_imagesModel.welvu_user_id]).topicId;
                    welvu_imagesModel.imageDisplayName = imageName;
                    welvu_imagesModel.image_guid=[[Guid randomGuid] description];
                    
                    welvu_imagesModel.orderNumber = ([welvu_images getMaxOrderNumber:appDelegate.getDBPath
                                                                                    :welvu_imagesModel.topicId
                                                                              userId:appDelegate.welvu_userModel.welvu_user_id] + 1);
                    
                    welvu_imagesModel.type = IMAGE_ALBUM_TYPE;
                    welvu_imagesModel.url = [NSString stringWithFormat:@"%@.%@",
                                             imageName, HTTP_ATTACHMENT_IMAGE_EXT_KEY];
                    
                    insertedImageId = [welvu_images addNewImageToTopic:appDelegate.getDBPath :welvu_imagesModel
                                                                      :welvu_imagesModel.topicId];
                    if (insertedImageId > 0) {
                        isAnnotationSaved = TRUE;
                        [imageGallery addObject:[welvu_images getImageById:appDelegate.getDBPath:insertedImageId
                                                                    userId:appDelegate.welvu_userModel.welvu_user_id]];
                        [annotateView clearScreen];
                        currentImage = ([imageGallery count] - 1);
                        prevImage = currentImage;
                        [self loadImageToCanvas:[welvu_images getImageById:appDelegate.getDBPath:insertedImageId
                                                                    userId:appDelegate.welvu_userModel.welvu_user_id]];
                        //Test
                        BOOL inserted = [welvu_sync addSyncDetail:[appDelegate getDBPath] guid:welvu_imagesModel.image_guid
                                                         objectId:insertedImageId
                                                         syncType:SYNC_TYPE_CONTENT_CONSTANT
                                                       actionType:ACTION_TYPE_CREATE_CONSTANT];
                        SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
                        [dataToCloud startSyncDataToCloud:SYNC_TYPE_CONTENT_CONSTANT objectId:insertedImageId
                                               actionType:HTTP_REQUEST_ACTION_TYPE_CREATE
                                                actionURL:PLATFORM_SYNC_CONTENTS];
                    }
                }
            }
        } else if (!annotateView.isAnnotationStarted) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"ALERT_EDIT_NO_MODIFICATION_TITLE",nil)
                                  message: NSLocalizedString(@"ALERT_EDIT_NO_MODIFICATION_MSG",nil)
                                  delegate: nil
                                  cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                  otherButtonTitles:nil];
            alert.tag = 1;
            [alert show];
        }
        
        if (isAnnotationSaved) {
            
            if ([welvu_alerts canAlertShowAgain:appDelegate.getDBPath : ALERT_EDIT_ANNOTATE_SAVED_TITLE]) {
                [self.delegate welvuTopicVUAnnotationDidFinish:((welvu_images *)[welvu_images getImageById:appDelegate.getDBPath :imageId
                                                                                                    userId:appDelegate.welvu_userModel.welvu_user_id]).topicId:insertedImageId:isModified];
                
            } else {
                
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: NSLocalizedString(@"ALERT_EDIT_ANNOTATE_SAVED_TITLE",nil)
                                      message: NSLocalizedString(@"ALERT_EDIT_ANNOTATE_SAVED_MSG",nil)
                                      delegate: self
                                      cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                      otherButtonTitles:NSLocalizedString(@"DONT_SHOW_AGAIN", nil), nil];
                //alert.tag = 5;
                [alert show];
            }
            
        }
        
        
    }
    
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_Save %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}
/*
 * Method name: settingsBtnClicked
 * Description: viewsettingsintheview
 * Parameters: analytics
 * return self
 * Created On: 19-dec-2012
 */
- (IBAction)settingsBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"Settings Button - TVA"
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
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_Settings %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

/*
 * Method name: settingsMasterViewControllerDidFinish
 * Description: when settings  done this mehos will call and settings will updated
 * Parameters: nil
 * Return Type: nil
 */
- (void)settingsMasterViewControllerDidFinish {
    [self themeSettingsViewControllerDidFinish];
    //[self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SETTINGS_UPDATED object:self userInfo:nil];
}
/*
 * Method name: settingsMasterViewControllerDidCancel
 * Description: cancel in settings button will triger this method
 * Parameters: nil
 * Return Type: nil
 */
- (void)settingsMasterViewControllerDidCancel {
    [self dismissModalViewControllerAnimated:YES];
}
/*
 * Method name: logoutUser
 * Description: user log out from topic vu Annotation
 * Parameters: nil
 * return nil
 
 */
-(void)logoutUser {
    [self.delegate userLoggedOutFromTopicVUAnnotation];
}

/*
 * Method name: feedBackBtnClicked
 * Description: toviewfeebackcontent
 * Parameters: analytics
 * return nil
 * Created On: 19-dec-2012
 */
- (IBAction)feedBackBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"FeedBack Button - TVA"
                                                           label:@"Feedback"
                                                           value:nil] build]];
    
    
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:URL_FEEDBACK_FORM]];
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_Feedback %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult
                             :(MFMailComposeResult)result error:(NSError*)error {
    // NEVER REACHES THIS PLACE
    [self dismissModalViewControllerAnimated:YES];
}

/*
 * Method name: closeBtnClicked
 * Description: toclosetheview
 * Parameters: analytics
 * return self
 * Created On: 19-dec-2102
 */
- (IBAction)closeBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"Close Edit VU - TVA"
                                                           label:@"Close"
                                                           value:nil] build]];
    
    
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        if (!annotateView.isAnnotationStarted) {
            [self.delegate welvuTopicVUAnnotationDidFinish:Nil:insertedImageId:isModified];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"ALERT_EDIT_ANNOTATE_NOT_SAVED_TITLE",nil)
                                  message: NSLocalizedString(@"ALERT_EDIT_ANNOTATE_NOT_SAVED_CLOSE_MSG",nil)
                                  delegate: self
                                  cancelButtonTitle:NSLocalizedString(@"CANCEL",nil)
                                  otherButtonTitles:NSLocalizedString(@"CLOSE",nil),nil];
            alert.tag = 4;
            [alert show];
        }
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_Close %@",exception];
        
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
    }
}
/*
 * Method name: buildImageGroups
 * Description: arraingment of images in the bottom of Annotation VU
 * Parameters: nill
 * Return Type: nill
 */
- (void)buildImageGroups {
    CGRect frame;
    for (int i = 0; i < imageGallery.count; ++i) {
        welvu_images *welvu_imagesModel = [imageGallery objectAtIndex:i];
        
        UIImage *thumbnail = nil;
        
        if ([welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE]) {
            NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            UIImage *originalImage = [UIImage imageWithData:imageData];
            thumbnail = [self getThumbnailImage:originalImage];
        }else if ([welvu_imagesModel.type isEqualToString:IMAGE_BLANK_TYPE]) {
            UIImage *originalImage = [UIImage imageNamed:welvu_imagesModel.url];
            thumbnail = [self getThumbnailImage:originalImage];
        } else if ([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] && welvu_imagesModel.imageId > 0) {
            NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            thumbnail = [self getThumbnailImage:[UIImage imageWithData:imageData]];
        } else if ([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] && welvu_imagesModel.imageId == 0) {
            thumbnail = [self getThumbnailImage: welvu_imagesModel.imageData];
        }
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button.frame = CGRectMake(i* (THUMB_MINI_IMAGE_WIDTH + 10), 5,
                                  THUMB_MINI_IMAGE_WIDTH, THUMB_MINI_IMAGE_HEIGHT);
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((NSInteger)(THUMB_MINI_IMAGE_WIDTH - thumbnail.size.width)/ 2,
                                                                             (NSInteger)(THUMB_MINI_IMAGE_HEIGHT - thumbnail.size.height)/ 2, thumbnail.size.width, thumbnail.size.height)];
        imgView.image = thumbnail;
        imgView.image = [imgView.image imageWithBorderForUnselected:THUMB_MINI_IMAGE_BORDER];
        [button addSubview:imgView];
        [button addTarget:self
                   action:@selector(topicVUImagePressed:)
         forControlEvents:UIControlEventTouchUpInside];
        button.tag = (i+1);
        
        [imagesVUScrollView addSubview:button];
        
        frame = button.frame;
    }
    for (UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]) subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *imgView = (UIImageView *)subview;
            imgView.image = [imgView.image imageWithBorderForSelected:THUMB_MINI_IMAGE_BORDER];
        }
    }
    ((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]).enabled = false;
    [imagesVUScrollView setContentSize:CGSizeMake((frame.origin.x + 80), HORIZONTAL_SCROLL_HEIGHT)];
}

/*
 * Method name: topicVUImagePressed
 * Description: Selection of image thumbnail
 * Parameters: id
 * Return Type: IBAction
 */

-(IBAction)topicVUImagePressed:(id)sender {
    //declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"TopicVU Content Selected -TVA"
                                                           label:@"Select"
                                                           value:nil] build]];
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        if (currentImage != ([sender tag] - 1) && !annotateView.isAnnotationStarted) {
            [self setZoomToNormal];
            currentImage = ([sender tag] - 1);
            ((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]).enabled = true;
            ((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]).enabled = false;
            for (UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]) subviews]) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imgView = (UIImageView *)subview;
                    imgView.image = [imgView.image imageWithBorderForUnselected:THUMB_MINI_IMAGE_BORDER];
                }
            }
            for (UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]) subviews]) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imgView = (UIImageView *)subview;
                    imgView.image = [imgView.image imageWithBorderForSelected:THUMB_MINI_IMAGE_BORDER];
                }
            }
            prevImage = currentImage;
            
            [annotateView clearScreen];
            welvu_images *welvu_imagesModel = (welvu_images *) [imageGallery objectAtIndex:([sender tag] - 1)];
            [self loadImageToCanvas:welvu_imagesModel];
            
        } else if (currentImage != ([sender tag] - 1) && annotateView.isAnnotationStarted) {
            currentImage = ([sender tag] - 1);
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"ALERT_EDIT_ANNOTATE_NOT_SAVED_TITLE",nil)
                                  message: NSLocalizedString(@"ALERT_EDIT_ANNOTATE_NOT_SAVED_MSG",nil)
                                  delegate: self
                                  cancelButtonTitle:NSLocalizedString(@"CANCEL",nil)
                                  otherButtonTitles:NSLocalizedString(@"CONTINUE",nil),nil];
            alert.tag = 1;
            [alert show];
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_topicVUImagePressed %@",exception];
        
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
        
    }
}


/*
 * Method name: loadImageToCanvas
 * Description: Loding image to create VU
 * Parameters: welvu_images
 * Return Type: nill
 */
-(void)loadImageToCanvas:(welvu_images *)welvu_imagesModel {
    [annotateView annotationTextViewConditions];
    
    CGSize destinationSize = CGSizeMake(CANVAS_WIDTH, CANVAS_HEIGHT);
    if (welvu_imagesModel.retainedAnnotatedImage != nil) {
        imageView.image =[welvu_imagesModel.retainedAnnotatedImage
                          resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
    } if ([welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE]) {
        NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        imageView.image = [[[UIImage imageWithData:imageData] resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                           makeRoundCornerImage:5 :5];
    }else if([welvu_imagesModel.type isEqualToString:IMAGE_BLANK_TYPE]) {
        imageView.image =[[[UIImage imageNamed:welvu_imagesModel.url]
                           resizedImageToFitInSize:destinationSize scaleIfSmaller:YES] makeRoundCornerImage:5 :5];
    }else if([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] && welvu_imagesModel.imageId > 0) {
        NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        imageView.image = [[[UIImage imageWithData:imageData] resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                           makeRoundCornerImage:5 :5];
    } else if([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] && welvu_imagesModel.imageId == 0) {
        imageView.image = [[welvu_imagesModel.imageData resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                           makeRoundCornerImage:5 :5];
    }
    
    if([welvu_imagesModel.type isEqualToString:IMAGE_BLANK_TYPE]) {
        saveAsBtn.enabled = NO;
    } else {
        saveAsBtn.enabled = YES;
    }
}

/*
 * Method name: getThumbnailImage
 * Description: Get Thumbnail of the image for button
 * Parameters: UIImage
 * Return Type: UIImage
 */
-(UIImage *)getThumbnailImage:(UIImage *)originalImage {
    CGSize destinationSize = CGSizeMake((THUMB_MINI_IMAGE_WIDTH - 10), (THUMB_MINI_IMAGE_HEIGHT - 7));
    UIImage *thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:NO];
    return thumbnail;
}

/*
 * Method name: captureAnnotation
 * Description: Captering annotation on the image
 * Parameters: nill
 * Return Type: UIImage
 */
-(UIImage *)captureAnnotation {
    UIGraphicsBeginImageContext(annotationContainer.bounds.size);
    [annotationContainer.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/*
 * Method name: retainAnnotatedImage
 * Description: Retain the annotation on the image
 * Parameters: NSInteger
 * Return Type: nill
 */
-(void)retainAnnotatedImage:(NSInteger)currentImageNumber {
    UIGraphicsBeginImageContext(annotationContainer.bounds.size);
    [annotationContainer.layer renderInContext:UIGraphicsGetCurrentContext()];
    welvu_images *welvu_imagesModel = [imageGallery objectAtIndex:currentImage];
    welvu_imagesModel.retainedAnnotatedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [(UIButton *) [imagesVUScrollView viewWithTag:(currentImageNumber + 1)] setImage:
     [self getThumbnailImage:welvu_imagesModel.retainedAnnotatedImage] forState:UIControlStateNormal];
}

/*
 * Method name: removeDeckImages
 * Description: removing images from the bottom list(deck)
 * Parameters: nill
 * Return Type: nill
 */
-(void)removeDeckImages {
    for(UIView *subview in [imagesVUScrollView subviews]) {
        if([subview isKindOfClass:[UIButton class]]) {
            [subview removeFromSuperview];
        }
    }
}

/*
 * Method name: clearAnnotationFromImage
 * Description: To clear annotation and to resore image to orignal
 * Parameters: NSInteger
 * Return Type: nill
 */
-(void)clearAnnotationFromImage:(NSInteger)currentImageNumber {
    [annotateView annotationTextViewConditions];
    [annotateView clearScreen];
}

/*
 * Method name: gestureBtnClicked
 * Description: Toolbar controls
 * Parameters: id
 * Return Type: IBAction
 */
-(IBAction)gestureBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"Gesture Activiated-TVA"
                                                           label:@"Gesture"
                                                           value:nil] build]];
    
    
    @try {
        
        UIButton *btn = (UIButton *) sender;
        if (btn.selected) {
            btn.selected = false;
            [gestureView viewModificationGestureEnable:false];
            [swipeLeft setEnabled:true];
            [swipeRight setEnabled:true];
        } else {
            btn.selected = true;
            [gestureView viewModificationGestureEnable:true];
            [annotateView isLineDrawingEnabled:false];
            [annotationTextViewBtn setSelected:false];
            [annotationPencilBtn setSelected:false];
            [annotationArrowBtn setSelected:false];
            [annotationSquareBtn setSelected:false];
            [annotationCircleBtn setSelected:false];
            [swipeLeft setEnabled:false];
            [swipeRight setEnabled:false];
        }
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_Gesture %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}


/*
 * Method name: enable_disableAnnotationBtnClicked
 * Description: Action to Enable/Disable annotation using double tap and to Enable/Disable swipe to navigate pictures
 * Parameters: id
 * Return Type: IBAction
 */
-(IBAction)enable_disableAnnotationBtnClicked:(id)sender {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"Annotation Button Enabled/Disabled  - TVA"
                                                           label:@"EnableandDisableAnnotation"
                                                           value:nil] build]];
    
    
    
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        
        if (annotationPencilBtn.selected == true) {
            [annotationPencilBtn setSelected:false];
            [annotateView isLineDrawingEnabled:false];
            [swipeLeft setEnabled:true];
            [swipeRight setEnabled:true];
        } else {
            [annotateView setToolOption:DRAWING_TOOL_LINE];
            [annotationPencilBtn setSelected:true];
            [annotateView isLineDrawingEnabled:true];
            [gestureView viewModificationGestureEnable:false];
            [annotationArrowBtn setSelected:false];
            [annotationTextViewBtn setSelected:false];
            [annotationSquareBtn setSelected:false];
            [annotationCircleBtn setSelected:false];
            [gestureBtn setSelected:false];
            [gestureView viewModificationGestureEnable:false];
            [swipeLeft setEnabled:false];
            [swipeRight setEnabled:false];
        }
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_EnableandDisableAnnotation %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
/*
 * Method name: arrowBtnClicked
 * Description: Selecting arraow button of the toolbar
 * Parameters: id
 * Return Type: IBAction
 */
/*
 * Method name: arrowBtnClicked
 * Description: Selecting arraow button of the toolbar
 * Parameters: id
 * Return Type: IBAction
 */
-(IBAction)arrowBtnClicked:(id)sender {
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"Arrow Tool - TVA"
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
            [annotationArrowBtn setSelected:true];
            [annotateView isLineDrawingEnabled:true];
            [annotationPencilBtn setSelected:false];
            [annotationTextViewBtn setSelected:false];
            [annotationSquareBtn setSelected:false];
            [annotationCircleBtn setSelected:false];
            [gestureBtn setSelected:false];
            [swipeLeft setEnabled:false];
            [swipeRight setEnabled:false];
            [gestureView viewModificationGestureEnable:false];
        }
    }
    @catch (NSException *exception) {
        
        
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_Arrow %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}


/*
 * Method name: annotationTextBtnClicked
 * Description: anootation text button selection and enabling text editing
 * Parameters: id
 * Return Type: IBAction
 */
-(IBAction)annotationTextBtnClicked:(id)sender{
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"Text Annotation Tool - TVA"
                                                           label:@"Text"
                                                           value:nil] build]];
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        if (annotationTextViewBtn.selected == true) {
            [annotationTextViewBtn setSelected:false];
            [annotateView isLineDrawingEnabled:false];
            [swipeLeft setEnabled:true];
            [swipeRight setEnabled:true];
            
        } else {
            [annotateView setToolOption:DRAWING_TOOL_TEXTVIEW];
            [annotationTextViewBtn setSelected:true];
            [annotateView isLineDrawingEnabled:true];
            [annotationPencilBtn setSelected:false];
            [annotationSquareBtn setSelected:false];
            [annotationCircleBtn setSelected:false];
            [annotationArrowBtn setSelected:false];
            [gestureBtn setSelected:false];
            [swipeLeft setEnabled:false];
            [swipeRight setEnabled:false];
            [gestureView viewModificationGestureEnable:true];
        }
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_AnnotationText %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}


/*
 * Method name: squarebtnclicked
 * Description: On selection of square button
 * Parameters: id
 * Return Type: IBAction
 */
- (IBAction)squarebtnclicked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"Square Tool - TVA"
                                                           label:@"Square"
                                                           value:nil] build]];
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        if (annotationSquareBtn.selected == true) {
            [annotationSquareBtn setSelected:false];
            [annotateView isLineDrawingEnabled:false];
            [swipeLeft setEnabled:true];
            [swipeRight setEnabled:true];
        } else {
            [annotateView setToolOption:DRAWING_TOOL_SQUARE];
            [annotationSquareBtn setSelected:true];
            [annotateView isLineDrawingEnabled:true];
            [annotationArrowBtn setSelected:false];
            [annotationPencilBtn setSelected:false];
            [annotationTextViewBtn setSelected:false];
            [annotationCircleBtn setSelected:false];
            [gestureBtn setSelected:false];
            [swipeLeft setEnabled:false];
            [swipeRight setEnabled:false];
            [gestureView viewModificationGestureEnable:false];
        }
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_Square %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

/*
 * Method name: circlebtnclicked
 * Description: On selection of square button
 * Parameters: id
 * Return Type: IBAction
 */
- (IBAction)circlebtnclicked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    //Declaring EventTrackiing Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"Circle Tool - TVA"
                                                           label:@"Circle"
                                                           value:nil] build]];
    
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        if (annotationCircleBtn.selected == true) {
            [annotationCircleBtn setSelected:false];
            [annotateView isLineDrawingEnabled:false];
            [swipeLeft setEnabled:true];
            [swipeRight setEnabled:true];
        } else {
            [annotateView setToolOption:DRAWING_TOOL_CIRCLE];
            [annotationCircleBtn setSelected:true];
            [annotateView isLineDrawingEnabled:true];
            [annotationArrowBtn setSelected:false];
            [annotationPencilBtn setSelected:false];
            [annotationTextViewBtn setSelected:false];
            [annotationSquareBtn setSelected:false];
            [gestureBtn setSelected:false];
            [swipeLeft setEnabled:false];
            [swipeRight setEnabled:false];
            [gestureView viewModificationGestureEnable:false];
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_Circle %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}
/*
 * Method name: undoAnnotationBtnClicked
 * Description: <#description#>
 * Parameters: <#parameters#>
 * Return Type: <#value#>
 */
- (IBAction)undoAnnotationBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    
    
    //Declaring EventTrackiing Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"Undo Button - TVA"
                                                           label:@"Undo"
                                                           value:nil] build]];
    
    
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        [annotateView undoButtonClicked];
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_Undo %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
/*
 * Method name: redoAnnotationBtnClicked
 * Description: toredo the eventsin the view
 * Parameters: <#parameters#>
 * return <#value#>
 * Created On: 19-dec-2012
 */

- (IBAction)redoAnnotationBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"Redo Button - TVA"
                                                           label:@"Redo"
                                                           value:nil] build]];
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        [annotateView redoButtonClicked];
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_Redo %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
    }
}
/*
 * Method name: changeColorBtnClicked
 * Description: color change event will take palce
 * Parameters: tag
 * return ibaction
 * Created On: <#date#>
 */
- (IBAction)changeColorBtnClicked:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"Change Color -TVA"
                                                           label:@"Change Color"
                                                           value:nil] build]];
    
    
    
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        switch ([sender tag]) {
            case 1000:
                [annotateView setStrokeColor:[UIColor redColor]];
                ((UIButton *)sender).selected = true;
                ((UIButton *)[self.view viewWithTag:1001]).selected = false;
                ((UIButton *)[self.view viewWithTag:1002]).selected = false;
                ((UIButton *)[self.view viewWithTag:1003]).selected = false;
                ((UIButton *)[self.view viewWithTag:1004]).selected = false;
                break;
            case 1001:
                [annotateView setStrokeColor:[UIColor blueColor]];
                ((UIButton *)sender).selected = true;
                ((UIButton *)[self.view viewWithTag:1000]).selected = false;
                ((UIButton *)[self.view viewWithTag:1002]).selected = false;
                ((UIButton *)[self.view viewWithTag:1003]).selected = false;
                ((UIButton *)[self.view viewWithTag:1004]).selected = false;
                break;
            case 1002:
                [annotateView setStrokeColor:[UIColor yellowColor]];
                ((UIButton *)sender).selected = true;
                ((UIButton *)[self.view viewWithTag:1000]).selected = false;
                ((UIButton *)[self.view viewWithTag:1001]).selected = false;
                ((UIButton *)[self.view viewWithTag:1003]).selected = false;
                ((UIButton *)[self.view viewWithTag:1004]).selected = false;
                break;
            case 1003:
                [annotateView setStrokeColor:[UIColor blackColor]];
                ((UIButton *)sender).selected = true;
                ((UIButton *)[self.view viewWithTag:1000]).selected = false;
                ((UIButton *)[self.view viewWithTag:1001]).selected = false;
                ((UIButton *)[self.view viewWithTag:1002]).selected = false;
                ((UIButton *)[self.view viewWithTag:1004]).selected = false;
                break;
            case 1004:
                [annotateView setStrokeColor:[UIColor whiteColor]];
                ((UIButton *)sender).selected = true;
                ((UIButton *)[self.view viewWithTag:1000]).selected = false;
                ((UIButton *)[self.view viewWithTag:1001]).selected = false;
                ((UIButton *)[self.view viewWithTag:1002]).selected = false;
                ((UIButton *)[self.view viewWithTag:1003]).selected = false;
                break;
            default:
                break;
        }
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_ChangeColor %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
    }
}

/*
 * Method name: swipeImageRight
 * Description: Two finger, swipe right, To capture and retain the annotated image
 * Parameters: UISwipeGestureRecognizer
 * Return Type: nill
 */
- (void)swipeImageRight:(UISwipeGestureRecognizer *)recognizer{
    /*CGPoint point = [recognizer locationInView:[self view]];
     NSLog(@"Swipe right - start location: %f,%f", point.x, point.y);*/
    //[self retainAnnotatedImage:currentImage];
    if (currentImage > 0 && !annotateView.isAnnotationStarted) {
        [self setZoomToNormal];
        currentImage = (currentImage - 1);
        ((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]).enabled = true;
        ((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]).enabled = false;
        for (UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]) subviews]) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imgView = (UIImageView *)subview;
                imgView.image = [imgView.image imageWithBorderForUnselected:THUMB_MINI_IMAGE_BORDER];
            }
        }
        for (UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]) subviews]) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imgView = (UIImageView *)subview;
                imgView.image = [imgView.image imageWithBorderForSelected:THUMB_MINI_IMAGE_BORDER];
            }
        }
        prevImage = currentImage;
        
        [annotateView clearScreen];
        welvu_images *welvu_imagesModel = (welvu_images *) [imageGallery objectAtIndex:currentImage];
        [self loadImageToCanvas:welvu_imagesModel];
    } else if (currentImage > 0 && annotateView.isAnnotationStarted) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"ALERT_LOAD_TOPICVU_TO_PATIENTVU_TITLE",nil)
                              message: @""
                              delegate: self
                              cancelButtonTitle:NSLocalizedString(@"CANCEL",nil)
                              otherButtonTitles:NSLocalizedString(@"CONTINUE",nil),nil];
        alert.tag = 2;
        [alert show];
    }
}

/*
 * Method name: swipeImageLeft
 * Description: Two finger, swipe left,To capture and retain the annotated image
 * Parameters: UISwipeGestureRecognizer
 * Return Type: nill
 */

- (void)swipeImageLeft:(UISwipeGestureRecognizer *)recognizer {
    /*CGPoint point = [recognizer locationInView:[self view]];
     NSLog(@"Swipe left - start location: %f,%f", point.x, point.y);*/
    //[self retainAnnotatedImage:currentImage];
    if(currentImage < ([imageGallery count] - 1)  && !annotateView.isAnnotationStarted) {
        [self setZoomToNormal];
        currentImage = (currentImage + 1);
        ((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]).enabled = true;
        ((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]).enabled = false;
        for(UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]) subviews]) {
            if([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imgView = (UIImageView *)subview;
                imgView.image = [imgView.image imageWithBorderForUnselected:THUMB_MINI_IMAGE_BORDER];
            }
        }
        for(UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]) subviews]) {
            if([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imgView = (UIImageView *)subview;
                imgView.image = [imgView.image imageWithBorderForSelected:THUMB_MINI_IMAGE_BORDER];
            }
        }
        prevImage = currentImage;
        
        [annotateView clearScreen];
        welvu_images *nextWelvu_imagesModel = (welvu_images *) [imageGallery objectAtIndex:currentImage];
        [self loadImageToCanvas:nextWelvu_imagesModel];
    } else if (currentImage < ([imageGallery count] - 1) && annotateView.isAnnotationStarted) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"ALERT_EDIT_ANNOTATE_NOT_SAVED_TITLE", nil)
                              message: NSLocalizedString(@"ALERT_EDIT_ANNOTATE_NOT_SAVED_MSG", nil)
                              delegate: self
                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                              otherButtonTitles:NSLocalizedString(@"CONTINUE", nil),nil];
        alert.tag = 3;
        [alert show];
    }
}
/*
 * Method name: clearAnnotationBtnClicked
 * Description: To clear annotation from the image
 * Parameters: id
 * Return Type: IBAction
 */
- (IBAction)clearAnnotationBtnClicked:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Annotation VU- TVA"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Annotation VU- TVA"
                                                          action:@"Clear Annotation - TVA"
                                                           label:@"ClearAnnotation"
                                                           value:nil] build]];
    
    
    
    @try {
        [annotateView annotationTextViewConditions];
        
        [self clearAnnotationFromImage:currentImage];
        [self setZoomToNormal];
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@" AnnotationVU-TVA_ClearAnnotation %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}
#pragma mark UIALERTVIEW DELEGATE
/*
 * Method name: alertView
 * Description: Handling alert View
 * Parameters: UIAlertView, NSInteger
 * Return Type: nill
 */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    if ([alertView tag] == 1) {
        if (buttonIndex == 1) {
            ((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]).enabled = true;
            ((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]).enabled = false;
            for(UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]) subviews]) {
                if([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imgView = (UIImageView *)subview;
                    imgView.image = [imgView.image imageWithBorderForUnselected:THUMB_MINI_IMAGE_BORDER];
                }
            }
            for (UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]) subviews]) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imgView = (UIImageView *)subview;
                    imgView.image = [imgView.image imageWithBorderForSelected:THUMB_MINI_IMAGE_BORDER];
                }
            }
            prevImage = currentImage;
            
            [annotateView clearScreen];
            welvu_images *welvu_imagesModel = (welvu_images *) [imageGallery objectAtIndex:currentImage];
            [self loadImageToCanvas:welvu_imagesModel];
        } else {
            currentImage = prevImage;
        }
    } else if([alertView tag] == 2) {
        if (buttonIndex == 1) {
            currentImage = (currentImage - 1);
            ((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]).enabled = true;
            ((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]).enabled = false;
            for(UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]) subviews]) {
                if([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imgView = (UIImageView *)subview;
                    imgView.image = [imgView.image imageWithBorderForUnselected:THUMB_MINI_IMAGE_BORDER];
                }
            }
            for (UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]) subviews]) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imgView = (UIImageView *)subview;
                    imgView.image = [imgView.image imageWithBorderForSelected:THUMB_MINI_IMAGE_BORDER];
                }
            }
            prevImage = currentImage;
            
            [annotateView clearScreen];
            welvu_images *welvu_imagesModel = (welvu_images *) [imageGallery objectAtIndex:currentImage];
            [self loadImageToCanvas:welvu_imagesModel];
        }
    } else if ([alertView tag] == 3) {
        if (buttonIndex == 1) {
            currentImage = (currentImage + 1);
            ((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]).enabled = true;
            ((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]).enabled = false;
            for(UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(prevImage + 1)]) subviews]) {
                if([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imgView = (UIImageView *)subview;
                    imgView.image = [imgView.image imageWithBorderForUnselected:THUMB_MINI_IMAGE_BORDER];
                }
            }
            for (UIView *subview in [((UIButton *)[imagesVUScrollView viewWithTag:(currentImage + 1)]) subviews]) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imgView = (UIImageView *)subview;
                    imgView.image = [imgView.image imageWithBorderForSelected:THUMB_MINI_IMAGE_BORDER];
                }
            }
            prevImage = currentImage;
            [annotateView clearScreen];
            welvu_images *nextWelvu_imagesModel = (welvu_images *) [imageGallery objectAtIndex:currentImage];
            [self loadImageToCanvas:nextWelvu_imagesModel];
        }
    } else if ([alertView tag] == 4) {
        if (buttonIndex == 1) {
            [self.delegate welvuTopicVUAnnotationDidFinish:((welvu_images *)[welvu_images getImageById:appDelegate.getDBPath
                                                                                                      :imageId
                                                                                                userId:appDelegate.welvu_userModel.welvu_user_id])
             .topicId:insertedImageId:isModified];
        }
    } else if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_EDIT_ANNOTATE_SAVED_TITLE", nil)]) {
        if (buttonIndex == 0){
            [self.delegate welvuTopicVUAnnotationDidFinish:((welvu_images *)[welvu_images getImageById:appDelegate.getDBPath
                                                                                                      :imageId
                                                                                                userId:appDelegate.welvu_userModel.welvu_user_id])
             .topicId:insertedImageId:isModified];
        }
        if (buttonIndex == 1){
            update = [welvu_alerts updateAlertConfirmation:appDelegate.getDBPath: ALERT_EDIT_ANNOTATE_SAVED_TITLE];
            [self.delegate welvuTopicVUAnnotationDidFinish:((welvu_images *)[welvu_images getImageById:appDelegate.getDBPath
                                                                                                      :imageId
                                                                                                userId:appDelegate.welvu_userModel.welvu_user_id])
             .topicId:insertedImageId:isModified];
            
        }
    }
}

- (void)setZoomToNormal {
    [gestureView setZoomToNormal];
    imageView.frame = CGRectMake(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
}


-(void)switchToWelvuUSer {
    [self.delegate userSwitchAccountFromTopicVUAnnotation];
}

#pragma mark - UIInterfaceOrientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
        || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return YES;
    }
	return NO;
}

- (BOOL)shouldAutorotate {
    return [self shouldAutorotateToInterfaceOrientation:self.interfaceOrientation];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}


- (void)startUpViewController {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}

- (void)orientationChanged:(NSNotification *)notification {
    [self shouldAutorotate];
}


/*
 * Method name: themeSettingsViewControllerDidFinish
 * Description: To display the theme for the app
 * Parameters: nil
 * return nil
 
 */
- (void) themeSettingsViewControllerDidFinish {
    
    
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
            
            
            
        }
    } else {
        themeLogo.image = [UIImage imageNamed:@"WelvuLogoBanner.png"];
    }
    
    
    [self.view bringSubviewToFront:themeLogo];
    
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
