//
//  ShareVUContentPlatformHelper.m
//  welvu
//
//  Created by Logesh Kumaraguru on 21/01/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "ShareVUContentPlatformHelper.h"

#import "welvuContants.h"
#import "XMLReader.h"
//#import "JSON.h"
#import "Base64.h"
#import "welvu_user.h"
@implementation ShareVUContentPlatformHelper
@synthesize delegate;
/*
 * Method name: initWithShareVuContent
 * Description: initlizing the sharevu content
 * Parameters: platformHostUrl,platformActionUrl,welvu_message_Model
 * return self
 */
-(id) initWithShareVuContent:(welvu_sharevu*) welvu_shareVU_Model:(NSString *)platformHostUrl:(NSString *)platformActionUrl {
    self = [super init];
    if(self) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        welvuShareVUModel = welvu_shareVU_Model;
        welvuPlatformHostUrl = platformHostUrl;
        welvuPlatformActionUrl = platformActionUrl;
    }
    return  self;
}

-(id) initWithEMRVuContent:(welvu_message*) welvu_MessageModel :(NSString *)platformHostUrl:(NSString *)platformActionUrl {
    self = [super init];
    if(self) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        welvuMessageModel = welvu_MessageModel;
        welvuPlatformHostUrl = platformHostUrl;
        welvuPlatformActionUrl = platformActionUrl;
    }
    return  self;
}

//To sharevu content
-(void) shareVUContents {
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", welvuPlatformHostUrl, welvuPlatformActionUrl];
    
	NSURL *url = [NSURL URLWithString:urlStr];
    NSDictionary *patientData= appDelegate.currentPatientInfo;
    NSString *patientID =[patientData objectForKey:@"pid"];
    
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    NSString *accessToken = nil;
    if(appDelegate.welvu_userModel.access_token == nil) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
    } else {
        accessToken = appDelegate.welvu_userModel.access_token;
    }
    NSLog( @"access token %@",appDelegate.welvu_userModel.access_token);
    NSLog( @"access token %@",appDelegate.oauth_accessToken);
    NSLog( @"access token %@",accessToken);
    NSDictionary *messageData = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX] &&
        ([welvuShareVUModel.sharevu_service isEqualToString:CONSTANT_SERVICE_SENDINC]
         || [welvuShareVUModel.sharevu_service isEqualToString:CONSTANT_SERVICE_BRIGHTCOVE])) {
            if([BoxSDK sharedSDK].OAuth2Session.accessToken != nil) {
                appDelegate.welvu_userModel.box_access_token = [BoxSDK sharedSDK].OAuth2Session.accessToken;
                appDelegate.welvu_userModel.box_refresh_access_token= [BoxSDK sharedSDK].OAuth2Session.refreshToken;
                appDelegate.welvu_userModel.box_expires_in =  [BoxSDK sharedSDK].OAuth2Session.accessTokenExpiration;
                [welvu_user updateBoxAccessToken:[appDelegate getDBPath] :appDelegate.welvu_userModel];
            }
            
            messageData = [NSDictionary dictionaryWithObjectsAndKeys
                           :appDelegate.welvu_userModel.box_access_token ,
                           HTTP_RESPONSE_BOX_ACCESSTOKEN_KEY,
                           appDelegate.welvu_userModel.box_refresh_access_token ,HTTP_RESPONSE_BOX_REFRESH_ACCESSTOKEN_KEY,
                           appDelegate.welvu_userModel.box_expires_in ,HTTP_RESPONSE_BOX_EXPIRES_IN,appDelegate.welvu_userModel.firstname, HTTP_REQUEST_NAME,
                           welvuShareVUModel.sharevu_recipients, HTTP_RECIPIENTS_KEY,
                           welvuShareVUModel.sharevu_msg, HTTP_DESCRIPTION_KEY,
                           welvuShareVUModel.sharevu_subject, HTTP_TITLE_KEY,
                           welvuShareVUModel.sharevu_service, HTTP_SERVICE_KEY,
                           accessToken,HTTP_RESPONSE_ACCESSTOKEN_KEY,nil];
            
        }
    
    else if( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]  || [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_HEV] &&
            ([welvuShareVUModel.sharevu_service isEqualToString:CONSTANT_SERVICE_SENDINC]
             || [welvuShareVUModel.sharevu_service isEqualToString:CONSTANT_SERVICE_BRIGHTCOVE])) {
                messageData = [NSDictionary dictionaryWithObjectsAndKeys
                               :appDelegate.welvu_userModel.firstname, HTTP_REQUEST_NAME,
                               welvuShareVUModel.sharevu_recipients, HTTP_RECIPIENTS_KEY,
                               welvuShareVUModel.sharevu_msg, HTTP_DESCRIPTION_KEY,
                               welvuShareVUModel.sharevu_subject, HTTP_TITLE_KEY,
                               welvuShareVUModel.sharevu_service, HTTP_SERVICE_KEY,
                               accessToken,HTTP_RESPONSE_ACCESSTOKEN_KEY,nil];
                
            }
    
    //OAUTH
    
    else  if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        messageData = [NSDictionary dictionaryWithObjectsAndKeys
                       :welvuShareVUModel.sharevu_recipients, HTTP_REQUEST_NAME,
                       welvuShareVUModel.sharevu_recipients, HTTP_RECIPIENTS_KEY,
                       welvuShareVUModel.sharevu_msg, HTTP_DESCRIPTION_KEY,
                       welvuShareVUModel.sharevu_subject, HTTP_TITLE_KEY,
                       welvuShareVUModel.sharevu_service, HTTP_SERVICE_KEY,nil];
        
    }
    //EMR
    else if([welvuShareVUModel.sharevu_service isEqualToString:CONSTANT_SERVICE_EMR]){
        
        messageData = [NSDictionary dictionaryWithObjectsAndKeys
                       : patientID,HTTP_PATIENT_ID,
                       accessToken,HTTP_RESPONSE_ACCESSTOKEN_KEY,
                       nil];
        
    }
    NSLog(@"message data %@",messageData);
    
    NSMutableDictionary *requestDataMutable = [messageData mutableCopy];
    if(appDelegate.welvu_userModel.org_id > 0) {
        [requestDataMutable
         setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
         forKey:HTTP_REQUEST_ORGANISATION_KEY];
    }
    
    
    
    welvu_video *welvuVideoModel = [welvu_video getVideoQueueById:[appDelegate getDBPath] queueId:welvuShareVUModel.welvu_video_id];
    
    //EMR
    
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:welvuVideoModel.videoLocation];
    
    NSData *videoData = [[NSData alloc] initWithContentsOfURL:fileURL];
    
    NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:url andDataDictionary:requestDataMutable attachmentData:videoData
                                                     attachmentType:HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_KEY
                                                 attachmentFileName:welvuVideoModel.generic_file_name];
    
    //  NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
    
    //[requestDelegate setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
    bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [connection start];
    }];
    
    
}

//Temp
//To sharevu content
-(void) shareEMRVUContents {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", welvuPlatformHostUrl, welvuPlatformActionUrl];
    
	NSURL *url = [NSURL URLWithString:urlStr];
    NSDictionary *patientData= appDelegate.currentPatientInfo;
    NSString *patientID =[patientData objectForKey:@"pid"];
    NSString *mPIID =[patientData objectForKey:@"MPIID"];
    
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    
    NSString *accessToken = nil;
    if(appDelegate.welvu_userModel.access_token == nil) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
    } else {
        accessToken = appDelegate.welvu_userModel.access_token;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    NSDictionary *messageData = nil;
    
    if( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL3, PLATFORM_SEND_MESSAGE_ACTION_OPENEMR_URL];
        
        NSURL *url = [NSURL URLWithString:urlStr];
        // NSLog(@"guid)ipx %@",guid_ipx);
        messageData = [NSDictionary dictionaryWithObjectsAndKeys
                       : patientID,HTTP_PATIENT_ID,
                       mPIID,@"MPIID",
                       [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id],HTTP_REQUEST_ORGANISATION_KEY,
                       nil];
        
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:welvuMessageModel.videoFileLocation];
        
        NSData *videoData = [[NSData alloc] initWithContentsOfURL:fileURL];
        
        NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:url andDataDictionary:messageData attachmentData:videoData
                                                         attachmentType:HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_KEY
                                                     attachmentFileName:welvuMessageModel.videoFileName];
        
        
        
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [connection start];
        }];
    }
    else {
        //  NSLog( @"access token %@",accessToken);
        
        
        
        //EMR
        if([welvuMessageModel.service isEqualToString:CONSTANT_SERVICE_EMR]){
            
            messageData = [NSDictionary dictionaryWithObjectsAndKeys
                           : patientID,HTTP_PATIENT_ID,
                           accessToken,HTTP_RESPONSE_ACCESSTOKEN_KEY,
                           nil];
        }
        
        //EMR
        
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:welvuMessageModel.videoFileLocation];
        
        NSData *videoData = [[NSData alloc] initWithContentsOfURL:fileURL];
        
        NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:url andDataDictionary:messageData attachmentData:videoData
                                                         attachmentType:HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_KEY
                                                     attachmentFileName:welvuMessageModel.videoFileName];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [connection start];
        }];
        
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
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    NSLog(@"access token %@",appDelegate.welvu_userModel.access_token);
    NSLog(@"access token %@",appDelegate.oauth_accessToken);
    
    
    
    NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
    
    NSString *contentType = [NSString stringWithFormat:@"%@; %@=%@", HTTP_REQUEST_MULTIPART_TYPE,
                             HTTP_BOUNDARY_KEY, HTTP_BOUNDARY];
    [request setValue:contentType forHTTPHeaderField:HTTP_REQUEST_CONTENT_TYPE_KEY];
    
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:HTTP_REQUEST_CONTENT_LENGTH_KEY];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    // set URL
    [request setURL:url];
    NSLog(@"request %@",request);
    
    return request;
}

#pragma mark NSurl connection delegate

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
    [self.delegate shareVUContentUploadSendResponse:YES];
    [[UIApplication sharedApplication] endBackgroundTask:bti];
    bti = UIBackgroundTaskInvalid;
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(data) {
        NSError *error;
//        SBJSON *parser = [[SBJSON alloc] init];
        // 1. get the top level value as a dictionary
        NSString* newStr = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
        NSJSONSerialization *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@", responseDictionary);
        
        NSString * responseStatus = [responseDictionary valueForKey:@"title"];
        
        if([responseStatus isEqualToString:@"Forbidden"]) {
            [self.delegate shareVUContentPlatformDidReceivedData:NO:responseDictionary];
            
        } else {
            
            if([[responseDictionary valueForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]== NSOrderedSame) {
                
                [self.delegate shareVUContentPlatformDidReceivedData:YES:responseDictionary];
            } else {
                [self.delegate shareVUContentPlatformDidReceivedData:NO:responseDictionary];
            }
        }
        
        
        
        
    }
    [[UIApplication sharedApplication] endBackgroundTask:bti];
    bti = UIBackgroundTaskInvalid;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // NSLog(@"Share Content %@",error);
    [self.delegate shareVUContentFailedWithErrorDetails:error];
    [[UIApplication sharedApplication] endBackgroundTask:bti];
    bti = UIBackgroundTaskInvalid;
}

@end
