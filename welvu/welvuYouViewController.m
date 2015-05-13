//
//  welvuYouViewController.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 08/01/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "welvuYouViewController.h"
#import "welvuContants.h"
#import "welvu_message.h"
#import "GAI.h"
@implementation welvuYouViewController

@synthesize youTubeUploader = _youTubeUploader;
@synthesize youYubeVideo,youTubeCategory,youTubeSwitvhValue,delegate,togglePrivate;


/*
 * Method name: initWithAttachmentDetails
 * Description: It contain the Details of the video to share to you tube
 * Parameters: subject ,video file location,filename, export completed
 * return self
 */
-(id)initWithAttachmentDetails:(NSString *) subject:(NSString *)signature
                              :(NSString *) videoFile_Name:(NSString *)videoFile_Location
                              :(BOOL) isExportCompleted {
    self = [super initWithNibName:@"ViewController" bundle:nil];
    if (self) {
        self.youTubeUploader = [[YouTubeUploader alloc] init];
        self.youTubeUploader.delegate = self;
        self.youTubeUploader.uploaderDelegate = self;
        exportCompleted = isExportCompleted;
        welvu_messageModel = [[welvu_message alloc] initWithMessageId:1];
        if(subject != nil)
            welvu_messageModel.subject = subject;
        if(signature != nil)
            welvu_messageModel.signature = signature;
        welvu_messageModel.videoFileName = videoFile_Name;
        welvu_messageModel.videoFileLocation = videoFile_Location;
    }
    return self;
}

/*
 * Method name: upload
 * Description: share  the video using you tube
 * Parameters: id
 * return nil
 */
- (IBAction)upload:(id)sender {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"YouTubeVU - YU"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"YouTubeVU - YU"
                                                          action:@"Upload Button - YV"
                                                           label:@"UploadVideo"
                                                           value:nil] build]];
    
    
    
    if(exportCompleted)
    {
        @try {
            
            // NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            // firstName = [defaults objectForKey:@"Public"];
            if(togglePrivate==nil)
            {
                togglePrivate=@"Yes";
            }
            
            youTubeCategory = @"Education";
            youTubeDescription=Description.text;
            youTubeName=youName.text;
            youTubeTagName=tagName.text;
            
             BOOL validateName = [self validateTextField:youName.text :200];
            if(validateName)
            {
                
                self.youTubeUploader.uploadProgressView = uploadProgressView;
                /* [self.youTubeUploader uploadVodeoFileForYouTube:welvu_messageModel.videoFileLocation :youTubeName :youTubeDescription :youTubeTagName :youTubeCategory];*/
                [self.youTubeUploader uploadVodeoFileForYouTube:welvu_messageModel.videoFileLocation :youTubeName :youTubeDescription :youTubeTagName :youTubeCategory:togglePrivate];
            }
            else{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Message"
                                                             message:@"Please enter the Title"
                                                            delegate:self cancelButtonTitle:nil
                                                   otherButtonTitles:@"Ok", nil];
                [alert show];
            }
        }
        @catch (NSException *exception) {
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            NSString * description = [NSString stringWithFormat:@"YouTubeVU-YU_UploadVideo: %@",exception];
            [tracker send:[[GAIDictionaryBuilder
                            createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                            withFatal:NO] build]];
            
        }
    } else {
        preparingToUploadLabel.hidden = false;
        [self performSelector:@selector(upload:) withObject:nil afterDelay:1];
    }
}

-(BOOL)validateTextField:(NSString *)textField:(NSInteger) allowedLength {
    BOOL textFieldValid = false;
    textField = [textField stringByTrimmingCharactersInSet:
                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([textField length] > 0) {
        textFieldValid = true;
    }
    return textFieldValid;
}
/*
 * Method name: userSetOnOff
 * Description: It shows the videos share to you tube is private or public
 * Parameters: id
 * return nil
 */
-(IBAction)userSetOnOff:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"YouTubeVU - YU"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"YouTubeVU - YU"
                                                          action:@"Private/public Switch - YU"
                                                           label:@"Private/Public"
                                                           value:nil] build]];
    
    
    
    @try {
        
        UISwitch *switchValue = sender;
        if (switchValue.on){
            //ios 7
            [switchValue setOnTintColor:[UIColor colorWithRed:0/255.0 green:71/255.0 blue:109/255.0 alpha:1.0]];
            youTubeSwitvhValue=@"Private";
            togglePrivate=@"Yes";
            // NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            // [defaults setObject:youTubeSwitvhValue forKey:@"Private"];
        }
        else{
            [switchValue setOnTintColor:[UIColor colorWithRed:0/255.0 green:71/255.0 blue:109/255.0 alpha:1.0]];
            youTubeSwitvhValue=@"Public";
            togglePrivate=@"No";
            //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //[defaults setObject:youTubeSwitvhValue forKey:@"Public"];
            
        }
        
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"YouTubeVU-YU_Private/publicSwitch: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
    }
}
/*
 * Method name: logout
 * Description: Signing out from the you tube
 * Parameters: id
 * return nil
 */
- (IBAction)logout:(id)sender {
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"YouTubeVU - YU"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"YouTubeVU - YU"
                                                          action:@"Logout Button - YV"
                                                           label:@"ChangeUser"
                                                           value:nil] build]];
    
    
    
    @try {
        [self.youTubeUploader logout];
        [self performSelector:@selector(upload:) withObject:nil afterDelay:1];
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"YouTubeVU-YU_ChangeUser: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
    }
}
/*
 * Method name: categoryselect
 * Description: Select the category as educationfor the shared video
 * Parameters: id
 * return nil
 */
-(IBAction)categoryselect:(id)sender
{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"YouTubeVU - YU"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"YouTubeVU - YU"
                                                          action:@"categoryselect"
                                                           label:@"category in picker"
                                                           value:nil] build]];
    
    
    @try {
        categoryTitle =[[NSMutableArray alloc]initWithObjects:@"Education",nil];
        if(youtubePickerView == nil) {
            youtubePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(50, 200, 460, 200)];
            [self.view addSubview:youtubePickerView];
            youtubePickerView.delegate = self;
        }
        
        
        youtubePickerView.showsSelectionIndicator = YES;
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"YouTubeVU_categoryinpicker: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}
#pragma mark UIPickerView Delegate
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = [categoryTitle count];
    return numRows;
}// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //Education
    // category.text=[titlearray objectAtIndex:row];
    category.text=@"Education";
    pickerView.hidden=YES;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [categoryTitle objectAtIndex:row];
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    CGFloat componentWidth = 0.0;
    componentWidth = 320.0;
    return componentWidth;}




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
    [inLayer addAnimation:fullRotation forKey:@"patientVUAnimation"];
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self spinLayer:imageToMove.layer duration:3.0
    //direction:5];
    /* CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
     pulseAnimation.duration = .5;
     pulseAnimation.toValue = [NSNumber numberWithFloat:1.1];
     pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
     pulseAnimation.autoreverses = YES;
     pulseAnimation.repeatCount = FLT_MAX;
     [shareAnimation.layer addAnimation:pulseAnimation forKey:@"youTubeAnnoataion"];*/
    
    
    //Declaring Page View Analytics
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"YouTubeVU - YU"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    category.enabled=YES;
    category.text=@"Education";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onExportCompleted:)
                                                 name:NOTIFY_EXPORT_COMPLETED object:nil];
    tagName.delegate = self;
    Description.delegate = self;
    youName.delegate = self;
}
- (void)viewDidUnload
{
    uploadProgressView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.superview.frame = CGRectMake(
                                           // Calcuation based on landscape orientation (width=height)
                                           ([UIScreen mainScreen].applicationFrame.size.height/2)-(538/2),// X
                                           ([UIScreen mainScreen].applicationFrame.size.width/2)-(520/2),// Y
                                           538,// Width
                                           520// Height
                                           );
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark Action Methods
/*
 * Method name: informationBtnClicked
 * Description: show the guide for the user
 * Parameters: id
 * return nil
 */
-(IBAction)informationBtnClicked:(id)sender{
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"YouTubeVU - YU"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"YouTubeVU - YU"
                                                          action:@"Guide Button - YU"
                                                           label:@"Guide"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
        overlay = [[UIView alloc] initWithFrame:[self.parentViewController.view frame]];
        overlay.alpha = 1;
        overlay.backgroundColor = [UIColor clearColor];
        
        
        UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:[self.parentViewController.view frame]];
        UIButton *overlayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [overlayCustomBtn addTarget:self action:@selector(closeOverlay:) forControlEvents:UIControlEventTouchUpInside];
        [overlayCustomBtn setFrame:[self.parentViewController.view frame]];
        overlayImageView.image = [UIImage imageWithContentsOfFile:YOUTUBE_OVERLAY_IMAGE_PNG];
        
        [overlay addSubview:overlayImageView];
        [overlay addSubview:overlayCustomBtn];
        
        [self.parentViewController.view addSubview:overlay];
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"YouTubeVU-YU_Guide: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

/*
 * Method name: closeOverlay
 * Description: to close the overlay
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2012
 */
-(IBAction)closeOverlay:(id)sender
{
    //Declaring Event Tracking Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"YouTubeVU - YU"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"YouTubeVU - YU"
                                                          action:@"closeOverlay- YU"
                                                           label:@"overlayclosed"
                                                           value:nil] build]];
    
    
    @try {
        
        
        if(overlay !=nil) {
            [overlay removeFromSuperview];
            overlay = nil;
        }
        
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"YouTubeVU-YU_closeOverlay: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

/*
 * Method name: cancelSharingVUBtnClickeds
 * Description: cancel tou tube sharing
 * Parameters: id
 * return nil
 */
-(IBAction)cancelSharingVUBtnClickeds:(id)sender {
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"YouTubeVU - YU"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"YouTubeVU - YU"
                                                          action:@"Cancel ShareVU - YU"
                                                           label:@"Cancel"
                                                           value:nil] build]];
    
    
    
    @try {
        [shareAnimation.layer removeAnimationForKey:@"youTubeAnnoataion"];
        [self.delegate canceledYoutubeSharing];
        [self dismissModalViewControllerAnimated:YES];
        
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"YouTubeVU-YU_Cancel: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
        
    }
}
/*
 * Method name: YouTubeUploaderDidFinish
 * Description: after you tube shares sucessfully it will dismiss the view
 * Parameters: nil
 * return nil
 */
-(void)YouTubeUploaderDidFinish {
    [self dismissModalViewControllerAnimated:YES];
}
/*
 * Method name: onExportCompleted
 * Description: export to email
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2012
 */
-(IBAction)onExportCompleted:(id)sender {
    exportCompleted = true;
}

-(IBAction)guide:(id)sender
{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"YouTubeVU - YU"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"YouTubeVU - YU"
                                                          action:@"Guide Button - YU"
                                                           label:@"Guide"
                                                           value:nil] build]];
    
    
    
    @try {
        
        [self dismissModalViewControllerAnimated:YES];
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"YouTubeVU-YU_Guide: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

#pragma MARK UIInterfaceOrientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}
#pragma mark UITextField DELEGATE
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == youName)
        [Description becomeFirstResponder];
    else if (textField == Description)
        [Description resignFirstResponder];
    else if (textField == tagName)
        [tagName resignFirstResponder];
    return NO;

}
/*
- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    [tagName becomeFirstResponder];
    return NO;
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
@end
