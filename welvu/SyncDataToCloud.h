//
//  SyncDataToCloud.h
//  welvu
//
//  Created by Logesh Kumaraguru on 06/03/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
//Delegate method to return selected content
@protocol syncContentToPlatformHelperDelegate
- (void)syncContentToPlatformSendResponse:(BOOL)success;
- (void)syncContentToPlatformDidReceivedData:(BOOL) success:(NSDictionary *) responseDictionary;
- (void)syncResponseDicFromPlatform:(BOOL)success:(NSDictionary *)responseDictionary;
- (void)syncContentFailedWithErrorDetails:(NSError *)error;
@end
@class welvuAppDelegate;
/*
 * Class name: SyncDataToCloud
 * Description: Has functionality to perform sync data to cloud
 * Extends: NSObject
 * Delegate :nil
 */
@interface SyncDataToCloud : NSObject {
    //Defining the delegate for this controller
    id<syncContentToPlatformHelperDelegate> delegate;
    welvuAppDelegate *appDelegate;
    
    //Declaring NSString
    NSString *welvuPlatformHostUrl;
    NSString *welvuPlatformActionUrl;
    NSString *responseStr;
    //Background Task
    UIBackgroundTaskIdentifier bti;
    NSData *attachmentData;
    NSURLConnection *getNotificatioData;
    NSURLConnection *readNotificationData;
    NSString *urlString;
    
}
@property (nonatomic ,retain)  NSString *urlString;
@property (retain) NSString *responseStr;
//Assigning the property for the delegate object
@property (retain) id<syncContentToPlatformHelperDelegate> delegate;
- (id)init;
- (void)startSyncOrderDataToCloud:(NSInteger)syncType syncOrder:(NSDictionary *)syncOrderData
                        queueGuid:(NSString *)queue_guid actionType:(NSString *)action_type
                        actionURL:(NSString *)action_url;
- (void)startSyncDataToCloud:(NSInteger)syncType objectId:(NSInteger)object_id actionType:(NSString *) action_type actionURL:(NSString *)action_url;

- (void)startSyncDataToCloud:(NSInteger)syncType guid:(NSString *) guid objectId:(NSInteger)object_id actionType:(NSString *) action_type actionURL:(NSString *)action_url;

- (void)startSyncDeletedDataToCloud:(NSInteger)syncType guid:(NSString *)object_guid actionType:(NSString *)action_type
                          actionURL:(NSString *)action_url;
- (void)checkForUpdate:(NSString *)platformActionUrl;
- (void)syncNotificationToDevice:(NSString *)platformActionUrl notificationId:(NSInteger) notification_id;
//-(id) initWithShareVuContent:(NSString *) platformHostUrl actionURL:(NSString *)platformActionUrl;
- (NSMutableURLRequest *)POSTRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) message_data
                             attachmentData:(NSData *)attachment_data attachmentType:(NSString *) attachment_type
                         attachmentFileName:(NSString *)attachment_fileName;

- (void)startSyncDeletedImageDataToCloud:(NSInteger)syncType guid:(NSString *)object_guid topicId:(NSInteger)Topic_Id  actionType:(NSString *)action_type
                               actionURL:(NSString *)action_url;

@end
