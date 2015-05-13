//
//  welvuiPxShareViewController.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 14/11/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "welvuiPxShareViewController.h"
#import "welvuContants.h"
#import "Guid.h"
//#import "SBJSON.h"
#import "XMLReader.h"
//#import "JSON.h"
#import "Base64.h"
#import "GAI.h"
//#import "WSLActionSheetAutoDismiss.h"
//#import "WSLAlertViewAutoDismiss.h"

@interface welvuiPxShareViewController ()

@end

@implementation welvuiPxShareViewController
@synthesize ipxDescription,ipxTitle ,getIpxDescription,getIpxTitle ,ipx_videoFileLocation,ipx_videoFileName, messagetTxtView;

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

#pragma mark view Life cycle
-(void)viewWillDisappear:(BOOL)animated {
    //[self removeOauthRefreshToken];
}
- (void)viewWillAppear:(BOOL)animated
{
 
    [super viewWillAppear:animated];
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    // NSLog(@"current version %@",currSysVer);
    NSArray *arr = [currSysVer componentsSeparatedByString:@"."];
    NSString *versionValue = [arr objectAtIndex:0];
    // NSLog(@"Version Value %@",versionValue);
    if([versionValue isEqualToString: @"7"]) {
        // NSLog(@"ios 7 above");
        
    } else {
        // NSLog(@"ios 7 below");
    }
    self.view.superview.frame = CGRectMake(
                                           // Calcuation based on landscape orientation (width=height)
                                           ([UIScreen mainScreen].applicationFrame.size.height/2)-(350/2),// X
                                           ([UIScreen mainScreen].applicationFrame.size.width/2)-(300/2),// Y
                                           350,// Width
                                           300// Height
                                           );
    
    
    
}

- (void)viewDidLoad  {
    [super viewDidLoad];
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"SaveiPx VU-SIV"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

#pragma mark Action methods
/*
 * Method name: informationBtnClicked
 * Description: show the guide for the user
 * Parameters: nil
 * return nil
 
 */
-(IBAction)informationBtnClicked:(id)sender{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"SaveiPx VU-SIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SaveiPx VU-SIV"
                                                          action:@"Guide Button - SIV"
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
    overlayImageView.image = [UIImage imageWithContentsOfFile:SAVE_IPX_PNG];
    
    [overlay addSubview:overlayImageView];
    [overlay addSubview:overlayCustomBtn];
    
    // [self.view addSubview:overlay];
    
    [self.parentViewController.view addSubview:overlay];
    
    } @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"SaveiPx VU-SIV_Guide %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}
/*
 * Method name: closeOverlay
 * Description: Hide the guide for the user
 * Parameters: nil
 * return nil
 
 */
-(IBAction)closeOverlay:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"SaveiPx VU-SIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SaveiPx VU-SIV"
                                                          action:@"Close Overlay - SIV"
                                                           label:@"Close"
                                                           value:nil] build]];
    
    
    @try {

    if(overlay !=nil) {
        [overlay removeFromSuperview];
        overlay = nil;
    }
    
}
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"SaveiPx VU-SIV_Clode %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}
/*
 * Method name: backBtnClicked
 * Description: to navigate to previous view.
 * Parameters: nil
 * return value :IBAction
 */

-(IBAction)backBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"SaveiPx VU-SIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SaveiPx VU-SIV"
                                                          action:@"SaveiPx VU-SIV"
                                                           label:@"Cancel"
                                                           value:nil] build]];
    
    
    @try {
        //[shareVU removeFromSuperview];
        //[self.view removeFromSuperview];
        // [self dismissViewControllerAnimated:YES completion:nil];
        [self dismissModalViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"SaveiPx VU-SIV_Cancel:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

/*
 * Method name: shareIpxBtnClicked
 * Description: To navigate to previous view.
 * Parameters: nil
 * return value :IBAction
 */
-(IBAction)shareIpxBtnClicked:(id)sender {
    
    //Declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"SaveiPx VU-SIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SaveiPx VU-SIV"
                                                          action:@"SaveiPx Button - SIV"
                                                           label:@"SaveiPx"
                                                           value:nil] build]];
    @try {
        
        
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        getIpxTitle=ipxTitle.text;
        getIpxDescription = ipxDescription.text;
        
        
        
        if ([ipxTitle.text isEqualToString:@""] ||[ipxDescription.text isEqualToString:@""]) {
            
           UIAlertView* myAlertView = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Please Enter Title/Description" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [myAlertView show];
        } else {
            
            // NSLog(@"title %@",getIpxTitle);
            // NSLog(@"description %@",getIpxDescription);
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
            
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            
            NSString *accessToken = nil;
            if(appDelegate.welvu_userModel.access_token == nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            } else {
                accessToken = appDelegate.welvu_userModel.access_token;
            }
            
            // NSLog( @"access token %@",accessToken);
            NSDictionary *messageData = nil;
            
            NSInteger descriptionLength = [ipxDescription.text length];
            if(descriptionLength >250){
                
                 UIAlertView* myAlertView = [[UIAlertView alloc]initWithTitle:@"Message"
                                                                     message:@"Description Should not exceed 250 Character"
                                                                    delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [myAlertView show];
                
            } else {
                
                // NSLog( @"access token %@",accessToken);
                NSString *Title =ipxTitle.text;
                NSString *Description =ipxDescription.text;
                NSString *guid_ipx =[Guid randomGuid];
                
                
                NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:ipx_videoFileLocation];
                
                NSData *videoData = [[NSData alloc] initWithContentsOfURL:fileURL];
                
                
                
                // NSData* videoData = [ipx_videoFileLocation dataUsingEncoding:NSUTF8StringEncoding];
                
                
                NSMutableURLRequest *requestDelegate = nil;
                if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
                    NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL, PLATFORM_BOX_ADD_IPX];
                    
                    NSURL *url = [NSURL URLWithString:urlStr];
                    
                    if([BoxSDK sharedSDK].OAuth2Session.accessToken != nil) {
                        appDelegate.welvu_userModel.box_access_token = [BoxSDK sharedSDK].OAuth2Session.accessToken;
                        appDelegate.welvu_userModel.box_refresh_access_token= [BoxSDK sharedSDK].OAuth2Session.refreshToken;
                        appDelegate.welvu_userModel.box_expires_in =  [BoxSDK sharedSDK].OAuth2Session.accessTokenExpiration;
                        [welvu_user updateBoxAccessToken:[appDelegate getDBPath] :appDelegate.welvu_userModel];
                    }
                    
                    messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                   [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                   appDelegate.welvu_userModel.box_access_token ,HTTP_RESPONSE_BOX_ACCESSTOKEN_KEY,
                                   appDelegate.welvu_userModel.box_refresh_access_token ,HTTP_RESPONSE_BOX_REFRESH_ACCESSTOKEN_KEY,
                                   appDelegate.welvu_userModel.box_expires_in  ,HTTP_RESPONSE_BOX_EXPIRES_IN,
                                   Title, @"title",
                                   Description,@"description",
                                   guid_ipx,@"ipx_guid",
                                   nil];
                    
                    
                    
                    requestDelegate = [self POSTRequestWithURL:url andDataDictionary:messageData attachmentData:videoData
                                                attachmentType:HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_KEY
                                            attachmentFileName:ipx_videoFileName];
                    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                    bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                        [connection start];
                    }];
                    
                }
                
                
              else  if( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
                  
                  appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                  appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                  
                  NSLog(@"expires in %@",appDelegate.welvu_userModel.oauth_expires_in);
                  NSLog(@"current date in %@",appDelegate.welvu_userModel.oauth_currentDate);
                  
                  //date comparision start
                  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                  NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                  [dateFormatter setTimeZone:gmt];
                  [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
                  NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
                  
                  NSDate *dateFromString = [[NSDate alloc] init];
                  dateFromString = [dateFormatter dateFromString:timeStamp];
                  
                  
                  
                  NSDate *currentGmtDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
                  NSLog(@"currentGmtDate%@",currentGmtDate);
                  
                  
                  
                  NSDate *expiresdatefromstring = [[NSDate alloc] init];
                  expiresdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_expires_in];
                  
                  
                  NSDate *oauth_expiresIn = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:expiresdatefromstring]];
                  NSLog(@"oauth_expiresIn%@",oauth_expiresIn);
                  
                  //currentdb date
                  
                  NSDate *currentdatefromstring = [[NSDate alloc] init];
                  currentdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_currentDate];
                  
                  
                  // NSLog(@"dateFromString%@",dateFromString);
                  NSDate *oauth_currenrDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:currentdatefromstring]];
                  
                  NSLog(@"oauth_currenrDate%@",oauth_currenrDate);
                  
                  
                  NSComparisonResult startCompare = [oauth_expiresIn compare: currentGmtDate];
                  NSComparisonResult endCompare = [oauth_currenrDate compare: currentGmtDate];
                  NSLog(@"startcompare %d",startCompare);
                  NSLog(@"end compare %d",endCompare);
                  
                  if(startCompare == NSOrderedAscending  && endCompare == NSOrderedAscending){
                      
                      
                      [appDelegate oauthRefreshAccessToken];
                      
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          
                          NSDictionary *messageData = nil;
                          NSMutableURLRequest *requestDelegate = nil;

                          
                          NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_ADD_INFORMATION_PRESCRIPTION];
                          
                          NSURL *url = [NSURL URLWithString:urlStr];
                          // NSLog(@"guid)ipx %@",guid_ipx);
                          messageData = [NSDictionary dictionaryWithObjectsAndKeys
                                         :Title, @"title", Description,@"description",
                                         guid_ipx,@"ipx_guid",nil];
                          
                          requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:messageData attachmentData:videoData
                                                       attachmentType:HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_KEY
                                                   attachmentFileName:ipx_videoFileName];
                          
                          NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                          bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                              [connection start];
                          }];

                          
                          
                      });
                  }
                  

                  else {
                  
                  NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_ADD_INFORMATION_PRESCRIPTION];
                  
                  NSURL *url = [NSURL URLWithString:urlStr];
                  // NSLog(@"guid)ipx %@",guid_ipx);
                  messageData = [NSDictionary dictionaryWithObjectsAndKeys
                                 :Title, @"title", Description,@"description",
                                 guid_ipx,@"ipx_guid",nil];
                  
                  requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:messageData attachmentData:videoData
                                               attachmentType:HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_KEY
                                           attachmentFileName:ipx_videoFileName];
                  
                  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                  bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                      [connection start];
                  }];
                }
              }
                else {
                    NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL, PLATFORM_ADD_INFORMATION_PRESCRIPTION];
                    
                    NSURL *url = [NSURL URLWithString:urlStr];
                    // NSLog(@"guid)ipx %@",guid_ipx);
                    messageData = [NSDictionary dictionaryWithObjectsAndKeys
                                   :Title, @"title", Description,@"description",
                                   guid_ipx,@"ipx_guid", accessToken,@"accesstoken",nil];
                    
                    requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:messageData attachmentData:videoData
                                                 attachmentType:HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_KEY
                                             attachmentFileName:ipx_videoFileName];
                    
                    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                    bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                        [connection start];
                    }];
                }
                
                
             
                [self dismissModalViewControllerAnimated:YES];
                appDelegate.isIPXInProgress = true;
                UIAlertView* alert = [[UIAlertView alloc]
                                      initWithTitle: NSLocalizedString(@"ALERT_SAVE_IPX_PLATFORM", nil)
                                      message:nil
                                      delegate: nil
                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                      otherButtonTitles:nil];
                alert.delegate =self;
                [alert show];
                
            }
        }
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"SaveiPx VU-SIV_Save:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
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
        NSError *error;
       // SBJSON *parser = [[SBJSON alloc] init];
        // 1. get the top level value as a dictionary
        NSString* newStr = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
         NSLog(@"%@", responseDictionary);
        
        NSString * responseStatus = [responseDictionary objectForKey:@"title"];
        
        if([responseStatus isEqualToString:@"Forbidden"]) {
            
            
        }
       else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame)
           && [responseDictionary objectForKey:HTTP_RESPONSE_IPX_GUID_KEY]) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:NOTIFY_MAIL_SENT
             object:self userInfo:responseDictionary];
            
            appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.isIPXInProgress = false;
            
        }
        [[UIApplication sharedApplication] endBackgroundTask:bti];
        bti = UIBackgroundTaskInvalid;
        
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // NSLog(@"Share Content %@",error);
    [[UIApplication sharedApplication] endBackgroundTask:bti];
    bti = UIBackgroundTaskInvalid;
}

#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_SAVE_IPX_PLATFORM", nil)]) {
        if (buttonIndex == 0 ){
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}
#pragma mark UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == ipxTitle)
        [ipxDescription becomeFirstResponder];
    else if (textField == ipxDescription)
        [ipxDescription resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
