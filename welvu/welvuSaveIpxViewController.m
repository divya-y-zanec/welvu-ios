//
//  welvuSaveIpxViewController.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 26/10/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "welvuSaveIpxViewController.h"
#import "welvuContants.h"
#import "HTTPRequestHandler.h"
#import "SyncDataToCloud.h"
//#import "SBJSON.h"
//#import "JSON.h"
#import "welvu_message.h"
#import "Guid.h"
#import "GAI.h"
#import "WSLActionSheetAutoDismiss.h"
#import "WSLAlertViewAutoDismiss.h"

@interface welvuSaveIpxViewController ()

@end

@implementation welvuSaveIpxViewController
@synthesize delegate;
@synthesize ipx_description,ipx_title,videoidipx;
@synthesize ipxidvideo;
@synthesize ipx_videoId ,boxMediaTab,boxVideoId ,boxDescription ,boxTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        ipx_description = [[NSMutableArray alloc]init];
        ipx_title = [[NSMutableArray alloc]init];
        ipx_videoId = [[NSMutableArray alloc]init];
        ipxvideo = [[NSMutableArray alloc]init];
    }
    return self;
}

/*
 * Method name: initWithShareVuContent
 * Description: Initlizing the share Vu Contents
 * Parameters: welvu_message_Model,platformHostUrl,platformActionUrl
 * return id
 */
-(id) initWithShareVuContent:(welvu_message*) welvu_message_Model:(NSString *)platformHostUrl:(NSString *)platformActionUrl {
    self = [super initWithNibName:@"welvuSaveIpxViewController" bundle:nil];
    
    if(self) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        welvu_messageModel = welvu_message_Model;
        welvuPlatformHostUrl = platformHostUrl;
        welvuPlatformActionUrl = platformActionUrl;
    }
    return  self;
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"ShareiPx VU - iPx"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        boxButton.hidden = false;
    }
    
}

-(void)viewDidUnload {
    
}

#pragma mark Action Methods

/*
 * Method name: informationBtnClicked
 * Description: show the guide for the user
 * Parameters: id
 * return nil
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
        overlayImageView.image = [UIImage imageNamed:@"iPx-shrevu.png"];
        
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
/*
 * Method name: closeOverlay
 * Description: hide /close the guide for the user
 * Parameters: id
 * return nil
 */
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


/*
 * Method name: shareBtnClicked
 * Description: To share the iPx Videos
 * Parameters: id
 * return IBAction
 */
-(IBAction)shareBtnClicked:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"ShareiPx VU - iPx"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ShareiPx VU - iPx"
                                                          action:@"shareBtnClicked"
                                                           label:@"share"
                                                           value:nil] build]];
    
    @try {
        
        
        if(appDelegate.networkReachable) {
            //   NSLog(@"videoidipx %@",ipx_videoId);
            BOOL validateRecipientsFlag = [self validateRecipients:recipientsTxt.text];
            
            
            if(validateRecipientsFlag)
            {
                //   NSLog(@"proper mail id");
                [self shareipxContent];
                
            } else {
                NSString *errorReport = @"";
                errorReport = [errorReport stringByAppendingString:NSLocalizedString(@"ALERT_SHAREVU_PLEASE_ENTER_MSG", nil)];
                if(!validateRecipientsFlag) {
                    errorReport = [errorReport stringByAppendingString:NSLocalizedString(@"ALERT_SHAREVU_ERROR_RECIPIENTS_MSG", nil)];
                }
                WSLAlertViewAutoDismiss* alert = [[WSLAlertViewAutoDismiss alloc]
                                      initWithTitle: NSLocalizedString(@"ALERT_SHAREVU_ERROR_TITLE", nil)
                                      message: errorReport
                                      delegate: self
                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                      otherButtonTitles:nil];
                [alert show];
            }
            
            
        } else {
            WSLAlertViewAutoDismiss* myAlert = [[WSLAlertViewAutoDismiss alloc]
                                    initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                    message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                    delegate:self
                                    cancelButtonTitle:@"Ok"
                                    otherButtonTitles:nil];
            [myAlert show];
        }
        
    }@catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ShareiPx VU - iPx_Share:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}


/*
 * Method name: cancelBtnClicked
 * Description: To remove the objects
 * Parameters: id
 * return IBAction
 */
-(IBAction)cancelBtnClicked:(id)sender {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"ShareiPx VU - iPx"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ShareiPx VU - iPx"
                                                          action:@"cancelBtnClicked"
                                                           label:@"Cancel"
                                                           value:nil] build]];
    @try {
        
        
        [self.delegate welvuShareIpxVideoDidCancel];
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ShareiPx VU - iPx_Cancel:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
    
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

/*
 * Method name: shareipxContent
 * Description: to share the ipx content to email
 * Parameters: nil
 * return nil
 */
-(void)shareipxContent {
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        if([BoxSDK sharedSDK].OAuth2Session.accessToken != nil) {
            appDelegate.welvu_userModel.box_access_token = [BoxSDK sharedSDK].OAuth2Session.accessToken;
            appDelegate.welvu_userModel.box_refresh_access_token= [BoxSDK sharedSDK].OAuth2Session.refreshToken;
            appDelegate.welvu_userModel.box_expires_in =  [BoxSDK sharedSDK].OAuth2Session.accessTokenExpiration;
            [welvu_user updateBoxAccessToken:[appDelegate getDBPath] :appDelegate.welvu_userModel];
        }
        
        NSString *accessToken = nil;
        HTTPRequestHandler *requestHandler = nil;
        
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        
        
        boxTitle= titleTxt.text;
        boxDescription = descriptionTxtView.text;
        NSString *emailid = recipientsTxt.text;
        
        
        NSJSONSerialization *parser = [[NSJSONSerialization alloc] init];
       // NSString*jsonString = [videoidipx JSONRepresentation];
         NSError *error;
        NSString*jsonString =[NSJSONSerialization dataWithJSONObject:videoidipx options:NSJSONWritingPrettyPrinted error:&error];
        
        
        
        
        //  NSLog( @"access token %@",accessToken);
        NSDictionary *requestData = nil;
        
        
        
        requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                        accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                        boxTitle,@"title",
                        boxDescription,@"description",
                        emailid,@"recipients",
                        boxVideoId,@"videoids",
                        nil];
        
        NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
        
        if(appDelegate.welvu_userModel.org_id > 0) {
            [requestDataMutable
             setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
             forKey:HTTP_REQUEST_ORGANISATION_KEY];
            
        }
        
        
        [requestDataMutable setObject:accessToken forKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        [requestDataMutable setObject: [[NSBundle mainBundle] bundleIdentifier] forKey:HTTP_REQUEST_APP_IDENTIFIER_KEY];
        [requestDataMutable setObject: appDelegate.welvu_userModel.box_access_token forKey:HTTP_RESPONSE_BOX_ACCESSTOKEN_KEY];
        [requestDataMutable setObject: appDelegate.welvu_userModel.box_refresh_access_token forKey:HTTP_RESPONSE_BOX_REFRESH_ACCESSTOKEN_KEY];
        [requestDataMutable setObject: appDelegate.welvu_userModel.box_expires_in forKey:HTTP_RESPONSE_BOX_EXPIRES_IN];
        
        if (boxMediaTab == 100) {
            requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                              :PLATFORM_HOST_URL :PLATFORM_SHARE_BOX_IPX:HTTP_METHOD_POST
                              :requestDataMutable :nil];
        } else {
            requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                              :PLATFORM_HOST_URL :PLATFORM_SHARE_BOX_LIBRARY:HTTP_METHOD_POST
                              :requestDataMutable :nil];
        }
        
        
        
        requestHandler.delegate = self;
        [requestHandler makeHTTPRequest];
        [self.delegate welvuShareIPXVideoDidFinish:YES];
        
        
    }  else if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
            
            
            NSString *ipx_title = titleTxt.text;
            NSString *ipx_description = descriptionTxtView.text;
            NSString *emailid = recipientsTxt.text;
            ipxidvideo= [ipx_videoId componentsJoinedByString:@","];
        NSError *error;
        
       // NSString*jsonString =[NSJSONSerialization dataWithJSONObject:videoidipx options:NSJSONWritingPrettyPrinted error:&error];
        
            
            NSString *accessToken = nil;
            HTTPRequestHandler *requestHandler = nil;
            
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            if(appDelegate.welvu_userModel.access_token == nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            } else {
                accessToken = appDelegate.welvu_userModel.access_token;
            }
            
            
            NSMutableURLRequest *requestDelegate = nil;
            NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
            NSDictionary *requestData = nil;
            
            
            
            NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_SEND_MESSAGE_ACTION_URL];
            
            NSURL *url = [NSURL URLWithString:urlStr];
            // NSLog(@"guid)ipx %@",guid_ipx);
            requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                                        ipx_title,@"title",
                            ipx_description,@"description",
                            emailid,@"recipients",
                            ipxidvideo,@"videoids",
                            [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id],HTTP_REQUEST_ORGANISATION_KEY,
                            nil];
            
            
            requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:requestData attachmentData:nil
                                         attachmentType:nil
                                     attachmentFileName:nil];
            
            shareipcVideo= [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
            
            [shareipcVideo start];
            
            [self.delegate welvuShareIPXVideoDidFinish:YES];
            
           }
              else {
        
        
        NSString *ipx_title = titleTxt.text;
        NSString *ipx_description = descriptionTxtView.text;
        NSString *emailid = recipientsTxt.text;
        ipxidvideo= [ipx_videoId componentsJoinedByString:@","];
       
        //NSString*jsonString = [videoidipx JSONRepresentation];
        NSError *error = nil;
        
        NSString*jsonString = [NSJSONSerialization dataWithJSONObject:videoidipx options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *accessToken = nil;
        HTTPRequestHandler *requestHandler = nil;
        
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        
        
        //  NSLog( @"access token %@",accessToken);
        NSDictionary *requestData = nil;
        
        
        requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                                ipx_title,@"title",
                        ipx_description,@"description",
                        emailid,@"recipients",
                        ipxidvideo,@"videoids",
                        nil];
        
        NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
        
        if(appDelegate.welvu_userModel.org_id > 0) {
            [requestDataMutable
             setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
             forKey:HTTP_REQUEST_ORGANISATION_KEY];
            
            requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                              :PLATFORM_HOST_URL :PLATFORM_SEND_MESSAGE_ACTION_URL:HTTP_METHOD_POST
                              :requestDataMutable :nil];
            
            requestHandler.delegate = self;
            [requestHandler makeHTTPRequest];
            [self.delegate welvuShareIPXVideoDidFinish:YES];
        }
        
    }
    
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
                    
                    NSRange currentRange = [descriptionTxtView selectedRange];
                    NSRange newRange = NSMakeRange((currentRange.location + 10), 40);
                    [descriptionTxtView setSelectedRange:newRange];
                    
                    [descriptionTxtView paste:self];
                    
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
#pragma mark UITextField Degegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == recipientsTxt)
        [titleTxt becomeFirstResponder];
    else if (textField == titleTxt)
        [descriptionTxtView becomeFirstResponder];
    else if (textField == descriptionTxtView)
        [descriptionTxtView resignFirstResponder];
    return NO;
}

#pragma mark NSURL CONNECTION DELEGATE
-(void) platformDidResponseReceived:(BOOL)success:(NSString *)actionAPI {
    
}

-(void) platformDidReceivedData:(BOOL)success :(NSDictionary *)responseDictionary
                               :(NSString *)actionAPI {
    
    //  NSLog(@"response dic %@",responseDictionary);
    [[NSNotificationCenter defaultCenter]
     postNotificationName:NOTIFY_MAIL_SENT
     object:self userInfo:responseDictionary];
    
    // [self dismissModalViewControllerAnimated:YES];
    
}

-(void)failedWithErrorDetails:(NSError *)error:(NSString *)actionAPI {
    // NSLog(@"Failed to get Specialty %@", error);
    
}

/*
 * Method name: POSTRequestWithURL
 * Description: Get the data and post with request url toplatform
 * Parameters: ur,Filename,file type etc
 * return request
 */
- (NSMutableURLRequest *) POSTRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) message_data
                              attachmentData:(NSData *) attachment_data attachmentType:(NSString *) attachment_type
                          attachmentFileName:(NSString *) attachment_fileName {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:180.0];
    [request setHTTPMethod:HTTP_METHOD_POST];
    
    /*NSMutableString *loginString = (NSMutableString *)
     [@"" stringByAppendingFormat:@"%@:%@",  MAIL_ID, MAIL_PASSWORD];
     NSString *encodedLoginData = [Base64 encode:[loginString dataUsingEncoding:NSUTF8StringEncoding]];
     [request addValue:[NSString stringWithFormat:@"%@ %@",HTTP_SSL_BASIC, encodedLoginData] forHTTPHeaderField:HTTP_SSL_HEADER_KEY];*/
    
    NSString *contentType = [NSString stringWithFormat:@"%@; %@=%@", HTTP_REQUEST_MULTIPART_TYPE,
                             HTTP_BOUNDARY_KEY, HTTP_BOUNDARY];
    [request setValue:contentType forHTTPHeaderField:HTTP_REQUEST_CONTENT_TYPE_KEY];
    
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in message_data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", HTTP_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\"%@\"\r\n\r\n", HTTP_CONTENT_DISPOSITION,param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [message_data objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (attachment_data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", HTTP_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
        //MOdify from here
        [body appendData:[[NSString stringWithFormat:@"%@\"%@\"; filename=\"%@.%@\"\r\n",HTTP_CONTENT_DISPOSITION, @"filename",attachment_fileName, HTTP_ATTACHMENT_VIDEO_EXT_KEY] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@: %@\r\n\r\n",HTTP_REQUEST_CONTENT_TYPE_KEY,attachment_type] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:attachment_data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", HTTP_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    
    NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:HTTP_REQUEST_CONTENT_LENGTH_KEY];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    
    
    
    
    
    // set URL
    [request setURL:url];
    
    
    return request;
}

#pragma mark NSURL Connection Delegate
- (void)connection:(NSURLConnection *) theConnection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *) challenge
{
#pragma unused(theConnection, challenge)
    
    NSLog(@"In Will send function");
    
    NSLog(@"%@", challenge.protectionSpace);
    
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

// NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge previousFailureCount] == 0) {
        // NSLog(@"responded to authentication challenge");
    }
    else {
        // NSLog(@"previous authentication failure");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //[self.delegate shareVUContentUploadSendResponse:YES];
    [[UIApplication sharedApplication] endBackgroundTask:bti];
    bti = UIBackgroundTaskInvalid;
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(data) {
        NSError *error = nil;
        // 1. get the top level value as a dictionary
        NSString* newStr = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[newStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@", responseDictionary);
        NSString * responseStatus = [responseDictionary objectForKey:@"title"];
        
        if([responseStatus isEqualToString:@"Forbidden"]) {
            
            
        }
        else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame) &&(connection = shareipcVideo) )  {
            
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:NOTIFY_MAIL_SENT
             object:self userInfo:responseDictionary];
        }
        
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // NSLog(@"Share Content %@",error);
    [[UIApplication sharedApplication] endBackgroundTask:bti];
    bti = UIBackgroundTaskInvalid;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
