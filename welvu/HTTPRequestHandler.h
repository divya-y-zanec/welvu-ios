//
//  HTTPRequestHandler.h
//  welvu
//
//  Created by Logesh Kumaraguru on 04/02/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
//Delegate method to return selected content
@protocol HTTPRequestHandlerDelegate
- (void)platformDidResponseReceived:(BOOL)success:(NSString *)actionAPI;
- (void)platformDidReceivedData:(BOOL)success:(NSDictionary *)responseDictionary:(NSString *)actionAPI;
- (void)failedWithErrorDetails:(NSError *)error:(NSString *)actionAPI;
@end

/*
 * Class name: HTTPRequestHandler
 * Description: Has functionality to request /response handler
 * Extends: NSObject
 * Delegate :nil
 */
@interface HTTPRequestHandler : NSObject {
    welvuAppDelegate *appDelegate;
    //Defining the delegate for this controller
    id<HTTPRequestHandlerDelegate> delegate;
    //Declaring the NSDictionary
    NSDictionary *requestData;
    NSDictionary *attachmentData;
    //Declaring the Nsstring
    NSString *welvuPlatformHostUrl;
    NSString *welvuPlatformActionUrl;
    NSString *methodType;
    NSString* responseStr;
    //BgTask
    UIBackgroundTaskIdentifier bti;
}
//Assigning the property for the delegate object
@property (retain) id<HTTPRequestHandlerDelegate> delegate;
@property (retain) NSString *responseStr;

- (id)initWithRequestDetails:(NSString *)platformHostUrl:(NSString *)platformActionUrl:(NSString *) medType
                            :(NSDictionary *)reqData:(NSDictionary *)atchData;
- (void)makeHTTPRequest;
- (NSMutableURLRequest *)POSTRequestWithURL:(NSString *)urlStr method:(NSString *)medType
                           andDataDictionary:(NSDictionary *)reqData
                              attachmentData:(NSDictionary *)atchData;
@end
