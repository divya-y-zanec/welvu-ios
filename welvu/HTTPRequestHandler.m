//
//  HTTPRequestHandler.m
//  welvu
//
//  Created by Logesh Kumaraguru on 04/02/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "HTTPRequestHandler.h"
#import "welvuContants.h"
#import "XMLReader.h"
#import "Base64.h"
//#import "JSON.h"
#import "welvu_user.h"
@implementation HTTPRequestHandler
@synthesize delegate, responseStr;


/*
 * Method name: initWithRequestDetails
 * Description: request details to initlize
 * Parameters: platformHostUrl,platformActionUrl
 * Return Type: id
 */

- (id)initWithRequestDetails:(NSString *)platformHostUrl:(NSString *)platformActionUrl:(NSString *) medType
                            :(NSDictionary *)reqData:(NSDictionary *)atchData {
    self = [super init];
    if (self) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        welvuPlatformHostUrl = platformHostUrl;
        welvuPlatformActionUrl = platformActionUrl;
        requestData = reqData;
        attachmentData = atchData;
        methodType = medType;
        responseStr = [[NSString alloc] init];
    }
    return  self;
}

/*
 * Method name: makeHTTPRequest
 * Description: <#description#>
 * Parameters: <#parameters#>
 * Return Type: <#value#>
 */

- (void)makeHTTPRequest {
    
    
    
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
            
            
            NSString *urlStr = [NSString stringWithFormat:@"%@%@", welvuPlatformHostUrl, welvuPlatformActionUrl];
            
            
            NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:urlStr method:methodType andDataDictionary:requestData attachmentData:attachmentData];
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
            [connection start];
            
            
            
        });
    }
    else {
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", welvuPlatformHostUrl, welvuPlatformActionUrl];
    
    
    NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:urlStr method:methodType andDataDictionary:requestData attachmentData:attachmentData];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
    [connection start];
    }
}
/*
 * Method name: POSTRequestWithURL
 * Description: post the request with the required url
 * Parameters: urlStr,atchData
 * Return Type: nil
 */
- (NSMutableURLRequest *)POSTRequestWithURL:(NSString *)urlStr method:(NSString *)medType
                           andDataDictionary:(NSDictionary *)reqData
                              attachmentData:(NSDictionary *)atchData{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:180.0];
    if ([medType isEqualToString:HTTP_METHOD_GET]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        
       

        NSInteger index = 0;
        urlStr = [urlStr stringByAppendingString:@"?"];
        // add params (all params are strings)
        for (NSString *param in reqData) {
            index++;
            urlStr = [urlStr stringByAppendingFormat:@"%@=%@",param,[reqData objectForKey:param]];
            if (index < [reqData count]) {
                urlStr = [urlStr stringByAppendingString:@"&"];
            }
        }
        NSURL *url = [NSURL fileURLWithPath:urlStr];
      // NSURL *url = [NSURL URLWithString:urlStr];
        NSLog(@"url %@",url);
        if( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
            NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
            
            
            [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
            
                 }

    }
   
    [request setHTTPMethod:medType];

    
        
    
    
    if ([medType isEqualToString:HTTP_METHOD_POST]) {
        
        NSString *contentType = [NSString stringWithFormat:@"%@; %@=%@", HTTP_REQUEST_MULTIPART_TYPE,
                                 HTTP_BOUNDARY_KEY, HTTP_BOUNDARY];
        [request setValue:contentType forHTTPHeaderField:HTTP_REQUEST_CONTENT_TYPE_KEY];
        
        // post body
        NSMutableData *body = [NSMutableData data];
        
        // add params (all params are strings)
        for (NSString *param in reqData) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", HTTP_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\"%@\"\r\n\r\n", HTTP_CONTENT_DISPOSITION,param] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n", [reqData objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", HTTP_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
        
        /*
         for(NSString *param in atchData) {
         NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:[reqData objectForKey:param]];
         NSData *videoData = [[NSData alloc] initWithContentsOfURL:fileURL];
         
         [body appendData:[[NSString stringWithFormat:@"--%@\r\n", HTTP_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
         //MOdify from here
         [body appendData:[[NSString stringWithFormat:@"%@\"%@\"; filename=\"%@.%@\"\r\n",HTTP_CONTENT_DISPOSITION, @"filename",attachment_fileName , HTTP_ATTACHMENT_VIDEO_EXT_KEY] dataUsingEncoding:NSUTF8StringEncoding]];
         [body appendData:[[NSString stringWithFormat:@"%@: %@\r\n\r\n",HTTP_REQUEST_CONTENT_TYPE_KEY,attachment_type] dataUsingEncoding:NSUTF8StringEncoding]];
         [body appendData:attachment_data];
         [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
         }
         */
        // setting the body of the post to the reqeust
        [request setHTTPBody:body];
        
        // set the content-length
        if( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
            NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
            
            
            [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
            
        }

        
        NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
        [request setValue:postLength forHTTPHeaderField:HTTP_REQUEST_CONTENT_LENGTH_KEY];
    }
    // set URL
    [request setURL:url];
    
    
    return request;
}
#pragma mark NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge previousFailureCount] == 0) {
        NSLog(@"responded to authentication challenge");
    }
    else {
        NSLog(@"previous authentication failure");
    }
}
/*
 * Method name: didReceiveResponse
 * Description:get response from web service with requested url
 * Parameters: Response
 * return nil
 
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.delegate platformDidResponseReceived:YES:welvuPlatformActionUrl];
}
/*
 * Method name: didReceiveData
 * Description:did recieve data from web service using the url
 * Parameters: data
 * return nil
 
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (data) {
        // 1. get the top level value as a dictionary
        NSString* newStr = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
        responseStr = [responseStr stringByAppendingString:newStr];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:responseStr forKey:@"responseStr"];
    }
}
/*
 * Method name: connectionDidFinishLoading
 * Description:connect finish after data loads
 * Parameters: connection
 * return nil
 
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    responseStr = [defaults  objectForKey:@"responseStr"];
    if ([responseStr length] > 1) {
        NSError *error;
        
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        [self.delegate platformDidReceivedData:YES:responseDictionary:welvuPlatformActionUrl];
    }
    [defaults  removeObjectForKey:@"responseStr"];
}
/*
 * Method name: connection
 * Description:if connection fails while loading
 * Parameters: error
 * return nil
 
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults  removeObjectForKey:@"responseStr"];
    NSLog(@"Share Content %@",error);
    [self.delegate failedWithErrorDetails:error:welvuPlatformActionUrl];
}
@end
