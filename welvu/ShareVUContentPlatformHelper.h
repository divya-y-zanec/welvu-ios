//
//  ShareVUContentPlatformHelper.h
//  welvu
//
//  Created by Logesh Kumaraguru on 21/01/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BoxSDK/BoxSDK.h>
#import "welvu_message.h"
#import "welvu_video.h"
#import "welvu_sharevu.h"
@class ShareVUContentPlatformHelper;
/*
 * Protocol name: shareVUContentPlatformHelperDelegate
 * Description : Delegate method to return selected content
 */
@protocol shareVUContentPlatformHelperDelegate
-(void)shareVUContentUploadSendResponse:(BOOL)success;
-(void)shareVUContentPlatformDidReceivedData:(BOOL) success:(NSDictionary *) responseDictionary;
-(void)shareVUContentFailedWithErrorDetails:(NSError *)error;
@end
/*
 * Class name: ShareVUContentPlatformHelper
 * Description: <#description#>
 * Extends: NSObject
 * Delegate : nil
 */
@interface ShareVUContentPlatformHelper : NSObject {
    welvuAppDelegate *appDelegate;
    //Assigning the delegate for the object
    id<shareVUContentPlatformHelperDelegate> delegate;
    welvu_sharevu *welvuShareVUModel;
    welvu_message *welvuMessageModel;
    NSString *welvuPlatformHostUrl;
    NSString *welvuPlatformActionUrl;
    UIBackgroundTaskIdentifier bti;
     NSUserDefaults * defaults;
        NSString* responseStr;
    NSURLConnection *shareVUConnection;
}
//Assigning the property for the delegate
@property (retain) id<shareVUContentPlatformHelperDelegate> delegate;
//Methods
-(id) initWithShareVuContent:(welvu_sharevu *) welvu_shareVU_Model:(NSString *)platformHostUrl:(NSString *)platformActionUrl;
-(id) initWithEMRVuContent:(welvu_message *) welvu_MessageModel :(NSString *)platformHostUrl:(NSString *)platformActionUrl;
-(void) shareVUContents;
-(void) shareEMRVUContents;
- (NSMutableURLRequest *) POSTRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) message_data
                              attachmentData:(NSData *) attachment_data attachmentType:(NSString *) attachment_type
                          attachmentFileName:(NSString *) attachment_fileName;
@end
