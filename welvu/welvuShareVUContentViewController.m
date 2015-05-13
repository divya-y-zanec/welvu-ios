//
//  ShareVUContentViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 28/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvuShareVUContentViewController.h"
#import "welvuContants.h"
#import "welvu_sharevu.h"
#import "welvu_video.h"
#import "welvu_message.h"
#import "GAI.h"
#import "WelVUMapsLink.h"
#import "WSLActionSheetAutoDismiss.h"
#import "WSLAlertViewAutoDismiss.h"

@interface welvuShareVUContentViewController()
-(void) completedSharingVUContent:(BOOL)success:(NSDictionary *)responseDictionary:(NSError *)error;
-(BOOL) validateRecipients: (NSString *) recipients;
-(BOOL) validateSubject: (NSString *) subject;
-(BOOL) validateEmail: (NSString *) candidate;
@end

@implementation welvuShareVUContentViewController
@synthesize delegate, welvuShareVUModel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelSharingVUBtnClickeds:)
                                                 name:@"shareView"  object: nil];

    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    //Declaring Page View Analytics
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Share VU - SV"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    // Do any additional setup after loading the view from its nib.
    //welvu_messageModel.privateVideo = CONSTANT_SERVICE_YOUTUBE_PRIVATE;
    
    subjectTxt.text = welvuShareVUModel.sharevu_subject;
    
    NSString *message = @"\n\n";
    
    if(appDelegate.mapLinks != nil && [appDelegate.mapLinks count] > 0) {
        message = [message stringByAppendingString:NSLocalizedString(@"CHECK_THE_LOCATION_LINK", nil)];
        for (WelVUMapsLink *mapLink in appDelegate.mapLinks) {
            message = [message stringByAppendingString:
                       [NSString stringWithFormat:@"%@: %@ \n", mapLink.placeName,
                        mapLink.mapLink]];
        }
        message = [message stringByAppendingString:@"\n"];
    }
    
    if(welvuShareVUModel.signature != nil) {
        message = [message stringByAppendingString:welvuShareVUModel.signature];
    }
    
    //message = [message stringByAppendingFormat:NSLocalizedString(@"SHARE_MAIL_CONFIDENTIAL_MSG_BODY", nil)];
    messagetTxtView.text = message;
    
    welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath] queueId:welvuShareVUModel.welvu_video_id];
    attachmentLabel.text = [NSString stringWithFormat:@"%@.%@", welvuVideoModel.generic_file_name,
                            HTTP_ATTACHMENT_VIDEO_EXT_KEY];
    
    recipientsTxt.delegate = self;
    messagetTxtView.delegate = self;
    subjectTxt.delegate = self;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        boxBtn.hidden = false;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onExportCompleted:) name:NOTIFY_EXPORT_COMPLETED object:nil];
    welvuVideoModel = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Action Methods
/*
 * Method name: informationBtnClicked
 * Description: the guide for the view
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2012
 */

-(IBAction)informationBtnClicked:(id)sender{
    //Declaring Event Tracking Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Share VU - SV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Share VU - SV"
                    
                                                          action:@"Guide Button  - SV"
                                                           label:@"Guide"
                                                           value:nil] build]];
    
    
    @try {
        
        overlay = [[UIView alloc] initWithFrame:[self.view frame]];
        overlay.alpha = 1;
        overlay.backgroundColor = [UIColor clearColor];
        
        
        UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:[self.view frame]];
        UIButton *overlayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [overlayCustomBtn addTarget:self action:@selector(closeOverlay:) forControlEvents:UIControlEventTouchUpInside];
        [overlayCustomBtn setFrame:[self.view frame]];
        overlayImageView.image = [UIImage imageNamed:@"ShareVUOverlay.png"];
        
        [overlay addSubview:overlayImageView];
        [overlay addSubview:overlayCustomBtn];
        
        [self.view addSubview:overlay];
        
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ShareVU-SV_Guide:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
//Hide/Close the overlay i.e Help
-(IBAction)closeOverlay:(id)sender
{
    //Declaring Event Tracking Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Share VU - SV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Share VU - SV"
                    
                                                          action:@"closing Overlay - SV"
                                                           label:@"close"
                                                           value:nil] build]];
    
    
    @try {
        
        if(overlay !=nil) {
            [overlay removeFromSuperview];
            overlay = nil;
        }
        
    }
    
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ShareVU_closeOverlay:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

-(IBAction)shareOptionSelectionSwictchChanges:(id)sender {
    if(shareSegmentControl.selectedSegmentIndex == 2) {
        youtubeVUView.hidden = false;
        mailVUView.hidden = true;
    } else if(shareSegmentControl.selectedSegmentIndex == 0 || shareSegmentControl.selectedSegmentIndex == 1) {
        youtubeVUView.hidden = true;
        mailVUView.hidden = false;
    }
}
//Share the video as Private/Public
-(IBAction)youtubePrivacySwitchChanged:(id)sender {
    UISwitch *switchValue = sender;
    if (switchValue.on){
        //  welvu_messageModel.privateVideo = CONSTANT_SERVICE_YOUTUBE_PRIVATE;
    }
    else{
        //  welvu_messageModel.privateVideo = CONSTANT_SERVICE_YOUTUBE_PUBLIC;
    }
}

/*
 * Method name: initWithAttachmentDetails
 * Description: share the content
 * Parameters: subject,videofilename,filelocation,signatore,subject
 * return Self
 * Created On: 19-dec-2012
 */
-(id)initWithAttachmentDetails:(NSString *) subject:(NSString *)signature
                              :(NSInteger) videoVUId :(BOOL) isExportCompleted {
    self = [super initWithNibName:@"welvuShareVUContentViewController" bundle:nil];
    if (self) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        exportCompleted = isExportCompleted;
        welvuShareVUModel = [[welvu_sharevu alloc] init];
        if(subject != nil)
            welvuShareVUModel.sharevu_subject = subject;
        if(signature != nil) {
            welvuShareVUModel.signature = signature;
        }
        welvuShareVUModel.sharevu_service = CONSTANT_SERVICE_BRIGHTCOVE;
        welvuShareVUModel.welvu_video_id = videoVUId;
        welvuShareVUModel.created_date = [NSDate date];
        welvuShareVUModel.user_id = appDelegate.welvu_userModel.welvu_user_id;
        while (welvuShareVUModel.welvu_sharevu_id == 0) {
            welvuShareVUModel.welvu_sharevu_id = [welvu_sharevu insertShareVUQueue:[appDelegate getDBPath]
                                                                                  :welvuShareVUModel];
        }
    }
    return self;
}
/*
 * Method name: shareContentVUBtnClicked
 * Description: share the content
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2012
 */
-(IBAction)shareContentVUBtnClicked:(id)sender {
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    //Declaring Event Tracking Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Share VU - SV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Share VU - SV"
                    
                                                          action:@"Share Button - SV"
                                                           label:@"Share"
                                                           value:nil] build]];
    
    
    @try {
        
        if(shareSegmentControl.selectedSegmentIndex == 0 || shareSegmentControl.selectedSegmentIndex == 1) {
            BOOL validateRecipientsFlag = [self validateRecipients:recipientsTxt.text];
            BOOL validateSubjectFlag = [self validateSubject:subjectTxt.text];
            
            if(validateRecipientsFlag && validateSubjectFlag) {
                [self.delegate shareVUContentViewControllerStartedSharing];
                [self shareContentVU];
                [shareBtn.layer removeAnimationForKey:@"shareVUAnimation"];
                
            } else {
                NSString *errorReport = @"";
                errorReport = [errorReport stringByAppendingString:NSLocalizedString(@"ALERT_SHAREVU_PLEASE_ENTER_MSG", nil)];
                if(!validateRecipientsFlag) {
                    errorReport = [errorReport stringByAppendingString:NSLocalizedString(@"ALERT_SHAREVU_ERROR_RECIPIENTS_MSG", nil)];
                }
                
                if(!validateSubjectFlag) {
                    if(!validateRecipientsFlag) {
                        errorReport = [errorReport stringByAppendingString:NSLocalizedString(@"ALERT_SHAREVU_AND_MSG", nil)];
                    }
                    errorReport = [errorReport stringByAppendingString:NSLocalizedString(@"ALERT_SHAREVU_ERROR_SUBJECT_MSG", nil)];
                }
                
                WSLAlertViewAutoDismiss* alert = [[WSLAlertViewAutoDismiss alloc]
                                      initWithTitle: NSLocalizedString(@"ALERT_SHAREVU_ERROR_TITLE", nil)
                                      message: errorReport
                                      delegate: self
                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                      otherButtonTitles:nil];
                [alert show];
            }
        } else  if(shareSegmentControl.selectedSegmentIndex == 2) {
            BOOL validateTitleFlag = [self validateSubject:youtubeTitleTxt.text];
            if(validateTitleFlag) {
                [self.delegate shareVUContentViewControllerStartedSharing];
                [self shareContentVU];
            } else {
                NSString *errorReport = @"";
                errorReport = [errorReport stringByAppendingString:NSLocalizedString(@"ALERT_SHAREVU_PLEASE_ENTER_MSG", nil)];
                errorReport = [errorReport stringByAppendingString:NSLocalizedString(@"ALERT_YOUTUBE_ERROR_TITLE_MSG", nil)];
                WSLAlertViewAutoDismiss* alert = [[WSLAlertViewAutoDismiss alloc]
                                      initWithTitle: NSLocalizedString(@"ALERT_SHAREVU_ERROR_TITLE", nil)
                                      message: errorReport
                                      delegate: self
                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ShareVU-SV_Share: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}
/*
 * Method name: onExportCompleted
 * Description: export to email
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2012
 */
-(IBAction)onExportCompleted:(id)sender {
    //Declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Share VU - SV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Share VU - SV"
                    
                                                          action:@"Export Completion -SV"
                                                           label:@"Export Mail"
                                                           value:nil] build]];
    
    @try {
        
        exportCompleted = true;
        // [self.delegate shareVUContentViewControllerDidFinish];
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ShareVU-SV_ExportCompletion-SV: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
//If Export Completed then Video share to brightcove
-(void)shareContentVU {
    if(exportCompleted) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NOTIFY_EXPORT_COMPLETED object:nil];
        welvuShareVUModel.sharevu_recipients = recipientsTxt.text;
        welvuShareVUModel.sharevu_subject = subjectTxt.text;
        welvuShareVUModel.sharevu_msg = messagetTxtView.text;
        [welvu_sharevu updateShareVUQueue:[appDelegate getDBPath] :welvuShareVUModel];
        
        
        ShareVUContentPlatformHelper *shareVUContentPlatformHelper = nil;
        
        if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
            
            shareVUContentPlatformHelper =
            [[ShareVUContentPlatformHelper alloc] initWithShareVuContent:welvuShareVUModel
                                                                        :PLATFORM_HOST_URL
                                                                        :PLATFORM_SHARE_BOX_VIDEO];
        } else if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU])  {
            
            shareVUContentPlatformHelper =
            [[ShareVUContentPlatformHelper alloc] initWithShareVuContent:welvuShareVUModel
                                                                        :PLATFORM_HOST_URL1
                                                                        :PLATFORM_SEND_MESSAGE_ACTION_URL];
        }
        
        else {
            shareVUContentPlatformHelper =
            [[ShareVUContentPlatformHelper alloc] initWithShareVuContent:welvuShareVUModel
                                                                        :PLATFORM_HOST_URL
                                                                        :PLATFORM_SEND_MESSAGE_ACTION_URL];
        }
        shareVUContentPlatformHelper.delegate = self;
        [shareVUContentPlatformHelper shareVUContents];
        
    } else {
        [self performSelector:@selector(shareContentVU) withObject:nil afterDelay:1];
    }
}

/*
 * Method name: cancelSharingVUBtnClickeds
 * Description: To Cancel the share vu
 * Parameters: id
 * return nil
 * Created On: 19-dec-2012
 */
-(IBAction)cancelSharingVUBtnClickeds:(id)sender {
    //Declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Share VU - SV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Share VU - SV"
                    
                                                          action:@"Cancel Button  - SV"
                                                           label:@"CancelSharing"
                                                           value:nil] build]];
    
    
    @try {
        [shareBtn.layer removeAnimationForKey:@"shareVUAnimation"];
        [welvu_sharevu updateShareVUStatus:[appDelegate getDBPath] shareVUId:welvuShareVUModel.welvu_sharevu_id
                                    status:WELVU_SHAREVU_CANCELLED];
        [self.delegate shareVUContentViewControllerDidCancel];
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ShareVU-SV_CancelSharing:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}
-(void) completedSharingVUContent:(BOOL)success:(NSDictionary *)responseDictionary :(NSError *)error {
    [self.delegate shareVUContentViewControllerDidFinish:success];
}

//ShareVu Content Helper class delegate methods
-(void)shareVUContentMailSendResponse:(BOOL)success {
    [self completedSharingVUContent:YES:nil:nil];
}

-(void)shareVUContentMailDidReceivedData:(BOOL)success:(NSDictionary *)responseDictionary {
    
    [self completedSharingVUContent:NO:responseDictionary:nil];
}

-(void)shareVUContentFailedWithError:(NSError *)error {
    [self completedSharingVUContent:NO:nil:error];
}

#pragma mark - ShareVU Content Platform Delegate
//ShareVu Content Platform Helper class delegate methods
-(void)shareVUContentUploadSendResponse:(BOOL)success {
    [self completedSharingVUContent:success:nil:nil];
}

-(void)shareVUContentPlatformDidReceivedData:(BOOL)success:(NSDictionary *)responseDictionary {
    
    // NSLog(@"response dic %@",responseDictionary);
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self completedSharingVUContent:success:responseDictionary:nil];
    [welvu_sharevu updateShareVUStatus:[appDelegate getDBPath] shareVUId:welvuShareVUModel.welvu_sharevu_id
                                status:WELVU_SHAREVU_COMPLETED];
    NSString *statusMessage = [responseDictionary objectForKey:@"msg"];
    
    // [appDelegate emailSentNotificationLabel :statusMessage];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:NOTIFY_MAIL_SENT
     object:self userInfo:responseDictionary];
    
}

-(void)shareVUContentFailedWithErrorDetails:(NSError *)error {
    [self completedSharingVUContent:NO:nil:error];
}

//Validation for recipient WHom Going to share
-(BOOL) validateRecipients: (NSString *) recipients {
    BOOL recipientValid = false;
    NSArray* recipientsArray = [recipients componentsSeparatedByString: @","];
    for(NSString *recipient in recipientsArray) {
        NSString * tempRecipient = [recipient stringByTrimmingCharactersInSet:
                                    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(![self validateEmail:tempRecipient]) {
            recipientValid = false;
            return recipientValid;
        } else {
            recipientValid = true;
        }
    }
    return recipientValid;
}
//To Valide the subject which we share
-(BOOL)validateSubject:(NSString *)subject {
    BOOL subjectValid = false;
    subject = [subject stringByTrimmingCharactersInSet:
               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([subject length] > 0) {
        subjectValid = true;
    }
    return subjectValid;
}
//Validate the email id to share the video content
- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}
#pragma mark UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == recipientsTxt)
        [subjectTxt becomeFirstResponder];
    else if (textField == subjectTxt)
        [messagetTxtView becomeFirstResponder];
    return NO;
}
/*
 - (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
 if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
 return YES;
 }
 [recipientsTxt becomeFirstResponder];
 return NO;
 }
 */

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void)spinLayer:(CALayer *)inLayer duration:(CFTimeInterval)inDuration
        direction:(int)direction
{
    imageToMove.hidden=NO;
    
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration = inDuration;
    fullRotation.repeatCount = 10000;
    //fullRotation.removedOnCompletion = YES;
    [inLayer addAnimation:fullRotation forKey:@"shareVUAnimation"];
}

#pragma mark - box integration
-(IBAction) boxBtnClicked:(id)sender {
    if ([BoxSDK sharedSDK].OAuth2Session.isAuthorized)
    {
        // in order to avoid a short lag, jump immediatly to the file picker if we are already authorized
        [self presentBoxFolderPicker];
    }
    else
    {
        BoxFolderBlock success = ^(BoxFolder * folder) {
            [self presentBoxFolderPicker];
        };
        BoxAPIJSONFailureBlock failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary){
            [self boxError:error];
        };
        // try sending a hearbeat
        [[BoxSDK sharedSDK].foldersManager folderInfoWithID:BoxAPIFolderIDRoot
                                             requestBuilder:nil
                                                    success:success
                                                    failure:failure];
    }
}
- (void)presentBoxFolderPicker {
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                       NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
                       NSString *thumbnailPath = [basePath stringByAppendingPathComponent:@"BOX"];
                       
                       self.folderPicker = [[BoxSDK sharedSDK]
                                            folderPickerWithRootFolderID:BoxAPIFolderIDRoot
                                            thumbnailsEnabled:YES
                                            cachedThumbnailsPath:thumbnailPath
                                            fileSelectionEnabled:YES];
                       
                       
                       self.folderPicker.delegate = self;
                       
                       UINavigationController *controller = [[BoxFolderPickerNavigationController alloc] initWithRootViewController:self.folderPicker];
                       controller.modalPresentationStyle = UIModalPresentationFormSheet;
                       
                       [self presentViewController:controller animated:YES completion:nil];
                   });
}

- (void)boxError:(NSError*)error {
    if (error.code == BoxSDKOAuth2ErrorAccessTokenExpiredOperationReachedMaxReenqueueLimit) {
        // Launch the picker again if for some reason the OAuth2 session cannot be refreshed.
        // this will bring the login screen which will be followed by the file picker itself
        [self presentBoxFolderPicker];
        return;
    }
    else if (error.code == BoxSDKOAuth2ErrorAccessTokenExpired) {
        // This error code appears as part of the re-authentication process and should be ignored
        return;
    }
    else {
        // we really failed, let the user know
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            WSLAlertViewAutoDismiss* alert = [[WSLAlertViewAutoDismiss alloc] initWithTitle:@"Box"
                                                            message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    }
}

- (void)folderPickerController:(BoxFolderPickerViewController *)controller didSelectBoxItem:(BoxItem *)item {
    [self dismissViewControllerAnimated:YES completion:^{
        
        BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
        BoxSharedObjectBuilder *sharedBuilder = [[BoxSharedObjectBuilder alloc] init];
        sharedBuilder.access = BoxAPISharedObjectAccessOpen;
        builder.sharedLink = sharedBuilder;
        [[BoxSDK sharedSDK].filesManager editFileWithID:item.modelID requestBuilder:builder success:^(BoxFile *file) {
            NSString *sharedUrl = [[file sharedLink] objectForKey:BoxAPIObjectKeyURL];
            if(![sharedUrl isKindOfClass:[NSNull class]]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    /* Do UI work here */
                    // Get a reference to the system pasteboard
                    UIPasteboard* lPasteBoard = [UIPasteboard generalPasteboard];
                    
                    // Update the system pasteboard with my string
                    lPasteBoard.string = [NSString stringWithFormat:@"%@: %@\n\n", file.name, sharedUrl];
                    
                    // Paste the pasteboard contents at current cursor location
                    
                    NSRange currentRange = [messagetTxtView selectedRange];
                    NSRange newRange = NSMakeRange((currentRange.location + 10), 40);
                    [messagetTxtView setSelectedRange:newRange];
                    
                    [messagetTxtView paste:self];
                    
                    lPasteBoard = nil;
                });
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary) {
            
        }];
        
    }];
    
}
- (void)folderPickerControllerDidCancel:(BoxFolderPickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIInterfaceOrientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortrait &&
            interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
@end
