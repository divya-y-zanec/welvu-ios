//
//  SyncDataToCloud.m
//  welvu
//
//  Created by Logesh Kumaraguru on 06/03/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "SyncDataToCloud.h"
#import "welvu_user.h"
#import "welvu_images.h"
#import "welvu_topics.h"
#import "welvuContants.h"
//#import "JSON.h"
#import "welvu_sync.h"
#import "UIDeviceHardware.h"

@implementation SyncDataToCloud
@synthesize delegate,urlString;

- (id)init {
    self = [super init];
    if (self) {
        responseStr = [[NSString alloc] init];
    }
    return self;
}
/*
 * Method name: getDeviceUDID
 * Description: to get deviceUDID
 * Parameters: nil
 * return string
 * Created On: 06-feb-2013
 */
- (NSString *)getDeviceUDID {
    NSString *udid = @"";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    udid = [defaults stringForKey:@"userDeviceID"];
    return udid;
}
/*
 * Method name: startSyncOrderDataToCloud
 * Description: sync content to cloud
 * Parameters: syncType,syncOrderData,queue_guid,action_url
 * return nil
 * Created On: 06-feb-2013
 */
- (void)startSyncOrderDataToCloud:(NSInteger)syncType syncOrder:(NSDictionary *)syncOrderData
                        queueGuid:(NSString *)queue_guid actionType:(NSString *)action_type
                        actionURL:(NSString *)action_url {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        NSString *accessToken = nil;
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        
        // NSLog( @"access token %@",accessToken);
        
        welvuPlatformActionUrl = action_url;
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, welvuPlatformActionUrl];
        NSURL *requestURL = [NSURL URLWithString:urlStr];
        NSDictionary *syncContent = nil;
        NSMutableURLRequest *requestDelegate = nil;
        NSError *error;
        //SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
        NSString *jsonString =[NSJSONSerialization dataWithJSONObject:syncOrderData options:NSJSONWritingPrettyPrinted error:&error];
        
        //[jsonWriter stringWithObject:syncOrderData];
        if([syncOrderData objectForKey:HTTP_REQUEST_TOPIC_GUID]) {
            syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                           
                           [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                           [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                           action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                           [syncOrderData objectForKey:HTTP_REQUEST_TOPIC_GUID],  HTTP_REQUEST_TOPIC_GUID,
                           jsonString, HTTP_REQUEST_ORDER_KEY, nil];
        } else {
            
            syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                           
                           [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                           [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                           action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                           [syncOrderData objectForKey:HTTP_REQUEST_TOPIC_ID],  HTTP_REQUEST_TOPIC_ID,
                           jsonString, HTTP_REQUEST_ORDER_KEY, nil];
        }
        
        NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
        if(appDelegate.welvu_userModel.org_id > 0) {
            [requestDataMutable
             setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
             forKey:HTTP_REQUEST_ORGANISATION_KEY];
        }
        requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                    attachmentType:nil
                                     attachmentExt:nil
                                attachmentFileName:nil];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [connection start];
        }];
        
    } else {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        NSString *accessToken = nil;
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        
        // NSLog( @"access token %@",accessToken);
        
        welvuPlatformActionUrl = action_url;
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL, welvuPlatformActionUrl];
        NSURL *requestURL = [NSURL URLWithString:urlStr];
        NSDictionary *syncContent = nil;
        NSMutableURLRequest *requestDelegate = nil;
        
        //SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
        ///NSString *jsonString = [jsonWriter stringWithObject:syncOrderData];
        NSError *error;
         NSString *jsonString =[NSJSONSerialization dataWithJSONObject:syncOrderData options:NSJSONWritingPrettyPrinted error:&error];
        
        if([syncOrderData objectForKey:HTTP_REQUEST_TOPIC_GUID]) {
            syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                           accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                           [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                           [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                           action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                           [syncOrderData objectForKey:HTTP_REQUEST_TOPIC_GUID],  HTTP_REQUEST_TOPIC_GUID,
                           jsonString, HTTP_REQUEST_ORDER_KEY, nil];
        } else {
            
            syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                           accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                           [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                           [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                           action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                           [syncOrderData objectForKey:HTTP_REQUEST_TOPIC_ID],  HTTP_REQUEST_TOPIC_ID,
                           jsonString, HTTP_REQUEST_ORDER_KEY, nil];
        }
        
        NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
        if(appDelegate.welvu_userModel.org_id > 0) {
            [requestDataMutable
             setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
             forKey:HTTP_REQUEST_ORGANISATION_KEY];
        }
        requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                    attachmentType:nil
                                     attachmentExt:nil
                                attachmentFileName:nil];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [connection start];
        }];
        
    }
    
}
/*
 * Method name: startSyncDeletedDataToCloud
 * Description: Delete content from cloud using sync
 * Parameters: syncType,syncOrderData,queue_guid,action_url
 * return nil
 * Created On: 06-feb-2013
 */
- (void)startSyncDeletedDataToCloud:(NSInteger)syncType guid:(NSString *)object_guid actionType:(NSString *)action_type
                          actionURL:(NSString *)action_url {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        NSString *accessToken = nil;
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        
        //NSLog( @"access token %@",accessToken);
        welvuPlatformActionUrl = action_url;
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, welvuPlatformActionUrl];
        NSURL *requestURL = [NSURL URLWithString:urlStr];
        NSDictionary *syncContent = nil;
        NSMutableURLRequest *requestDelegate = nil;
        
        switch (syncType) {
            {
            case SYNC_TYPE_CONTENT_CONSTANT: {
                welvu_topics *welvu_topicsModel = [welvu_topics getTopicDetailByGUID:[appDelegate getDBPath]:object_guid];
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                               [NSNumber numberWithInt:welvu_topicsModel.specialty_id], HTTP_SPECIALTY_ID,
                               object_guid, HTTP_REQUEST_TOPIC_GUID,
                               nil];
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
            } {
            case SYNC_TYPE_TOPIC_CONSTANT: {
                welvu_topics *welvu_topicsModel = [welvu_topics getTopicDetailByGUID:[appDelegate getDBPath]:object_guid];
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                               [NSNumber numberWithInt:appDelegate.specialtyId], HTTP_SPECIALTY_ID,
                               object_guid, HTTP_REQUEST_TOPIC_GUID,
                               nil];
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
            }
            default:
                break;
        }
        
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [connection start];
        }];
        
    } else {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        NSString *accessToken = nil;
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        
        //NSLog( @"access token %@",accessToken);
        welvuPlatformActionUrl = action_url;
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL, welvuPlatformActionUrl];
        NSURL *requestURL = [NSURL URLWithString:urlStr];
        NSDictionary *syncContent = nil;
        NSMutableURLRequest *requestDelegate = nil;
        
        switch (syncType) {
            {
            case SYNC_TYPE_CONTENT_CONSTANT: {
                welvu_topics *welvu_topicsModel = [welvu_topics getTopicDetailByGUID:[appDelegate getDBPath]:object_guid];
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                               [NSNumber numberWithInt:welvu_topicsModel.specialty_id], HTTP_SPECIALTY_ID,
                               object_guid, HTTP_REQUEST_TOPIC_GUID,
                               nil];
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
            } {
            case SYNC_TYPE_TOPIC_CONSTANT: {
                welvu_topics *welvu_topicsModel = [welvu_topics getTopicDetailByGUID:[appDelegate getDBPath]:object_guid];
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                               [NSNumber numberWithInt:appDelegate.specialtyId], HTTP_SPECIALTY_ID,
                               object_guid, HTTP_REQUEST_TOPIC_GUID,
                               nil];
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
            }
            default:
                break;
        }
        
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [connection start];
        }];
        
    }
}
/*
 * Method name: startSyncDataToCloud
 * Description: Stared Syncing data to cloud
 * Parameters: syncType,syncOrderData,queue_guid,action_url
 * return nil
 * Created On: 06-feb-2013
 */
- (void)startSyncDataToCloud:(NSInteger)syncType objectId:(NSInteger)object_id
                  actionType:(NSString *)action_type actionURL:(NSString *)action_url{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        
        
        
        
        
        
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
                
                
                
                appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                
                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                NSString *accessToken = nil;
                if(appDelegate.welvu_userModel.access_token == nil) {
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                } else {
                    accessToken = appDelegate.welvu_userModel.access_token;
                }
                
                // NSLog( @"access token sync data %@",accessToken);
                welvuPlatformActionUrl = action_url;
                NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, welvuPlatformActionUrl];
                /* if([welvuPlatformActionUrl isEqualToString:@"/udidtoguid"]) {
                 NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL2, welvuPlatformActionUrl];
                 } else {
                 NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, welvuPlatformActionUrl];
                 }*/
                NSURL *requestURL = [NSURL URLWithString:urlStr];
                NSData *contentData = nil;
                NSDictionary *syncContent = nil;
                NSMutableURLRequest *requestDelegate = nil;
                NSInteger actionTypeContant;
                UIDeviceHardware *device = [[UIDeviceHardware alloc] init];
                NSString * deviceModel = [device platformString];
                NSString *currSysVeriosion = [[UIDevice currentDevice] systemVersion];
                
                switch (syncType) {
                    {
                    case SYNC_TYPE_PLATFORM_ID_CONSTANT: {
                        syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                       
                                       [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                       [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                       action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                       deviceModel, HTTP_REQUEST_DEVICE_INFO,
                                       [self getDeviceUDID], HTTP_REQUEST_DEVICE_GUID,
                                       currSysVeriosion, HTTP_REQUEST_PLATFORM_VERSION,nil];
                        
                        // NSLog(@"uidid chages");
                        
                        
                        
                        NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                        if(appDelegate.welvu_userModel.org_id > 0) {
                            [requestDataMutable
                             setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                             forKey:HTTP_REQUEST_ORGANISATION_KEY];
                        }
                        
                        
                        
                        
                        requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                                    attachmentType:nil
                                                     attachmentExt:nil
                                                attachmentFileName:nil];
                    }
                        break;
                    case SYNC_TYPE_CONTENT_CONSTANT: {
                        if([action_type isEqualToString:HTTP_REQUEST_ACTION_TYPE_CREATE]) {
                            appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                            
                            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                            
                            welvu_images *welvu_imageModel = [welvu_images getImageById:[appDelegate getDBPath] :object_id
                                                                                 userId:appDelegate.welvu_userModel.welvu_user_id];
                            
                            NSLog(@"welvu image url %@",welvu_imageModel.url);
                            NSURL *fileURL;
                            if(welvu_imageModel.url) {
                                fileURL = [[NSURL alloc] initFileURLWithPath:welvu_imageModel.url];
                            } else {
                                fileURL = [[NSBundle mainBundle] URLForResource:welvu_imageModel.url withExtension:nil];
                            }
                            NSLog(@"welvu image url %@",fileURL);
                            // NSURL *fileURL = [[NSBundle mainBundle] URLForResource:welvu_imageModel.url withExtension:nil];
                            
                            NSArray *parts = [[welvu_imageModel.url lastPathComponent] componentsSeparatedByString:@"."];
                            contentData = [[NSData alloc] initWithContentsOfURL:fileURL];
                            NSString *contentType = parts[([parts count] - 1)];
                            NSString *type = nil;
                            NSString *attachmentType = nil;
                            if([welvu_imageModel.type isEqualToString:IMAGE_VIDEO_TYPE]
                               || [welvu_imageModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE]) {
                                
                                type = IMAGE_VIDEO_TYPE;
                                if([contentType isEqualToString:HTTP_ATTACHMENT_VIDEO_EXT_MOV_KEY]) {
                                    attachmentType = HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_MOV_KEY;
                                } else if([contentType isEqualToString:HTTP_ATTACHMENT_VIDEO_EXT_KEY]){
                                    attachmentType = HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_KEY;
                                }
                            } else {
                                type = IMAGE_ASSET_TYPE;
                                attachmentType = HTTP_ATTACHMENT_IMAGE_CONTENT_TYPE_KEY;
                            }
                            
                            welvu_topics *topicModel = [welvu_topics getTopicById:[appDelegate getDBPath] :welvu_imageModel.topicId
                                                                           userId:appDelegate.welvu_userModel.welvu_user_id];
                            if(topicModel.topics_guid) {
                                
                                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                               topicModel.topics_guid, HTTP_REQUEST_TOPIC_GUID,
                                               welvu_imageModel.image_guid, HTTP_REQUEST_CONTENT_GUID,
                                               type, HTTP_RESPONSE_MEDIA_TYPE,
                                               [NSNumber numberWithInt:welvu_imageModel.orderNumber], HTTP_RESPONSE_MEDIA_ORDER, nil];
                            } else {
                                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                               [NSNumber numberWithInt:topicModel.topicId], HTTP_REQUEST_TOPIC_ID,
                                               welvu_imageModel.image_guid, HTTP_REQUEST_CONTENT_GUID,
                                               type, HTTP_RESPONSE_MEDIA_TYPE,
                                               [NSNumber numberWithInt:welvu_imageModel.orderNumber], HTTP_RESPONSE_MEDIA_ORDER, nil];
                            }
                            
                            NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                            if(appDelegate.welvu_userModel.org_id > 0) {
                                [requestDataMutable
                                 setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                                 forKey:HTTP_REQUEST_ORGANISATION_KEY];
                            }
                            
                            requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:contentData
                                                        attachmentType:attachmentType
                                                         attachmentExt:contentType
                                                    attachmentFileName:welvu_imageModel.imageDisplayName];
                        }
                    }
                        break;
                    } {
                    case SYNC_TYPE_TOPIC_CONSTANT: {
                        welvu_topics *welvu_topicsModel = [welvu_topics getTopicById:[appDelegate getDBPath] :object_id
                                                                              userId:appDelegate.welvu_userModel.welvu_user_id];
                        syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                       
                                       [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                       [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                       action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                       [NSNumber numberWithInt:welvu_topicsModel.specialty_id], HTTP_SPECIALTY_ID,
                                       welvu_topicsModel.topics_guid, HTTP_REQUEST_TOPIC_GUID,
                                       welvu_topicsModel.topicName, HTTP_RESPONSE_TITLE, nil];
                        
                        NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                        if(appDelegate.welvu_userModel.org_id > 0) {
                            [requestDataMutable
                             setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                             forKey:HTTP_REQUEST_ORGANISATION_KEY];
                        }
                        requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                                    attachmentType:nil
                                                     attachmentExt:nil
                                                attachmentFileName:nil];
                    }
                        break;
                        
                    } {
                        
                        //santhosh sep 25
                    case SYNC_TYPE_TOPIC_CHANGES_CONSTANT: {
                        welvu_topics *welvu_topicsModel = [welvu_topics getTopicById:[appDelegate getDBPath] :object_id
                                                                              userId:appDelegate.welvu_userModel.welvu_user_id];
                        syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                       
                                       [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                       [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                       action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                       [NSNumber numberWithInt:welvu_topicsModel.specialty_id], HTTP_SPECIALTY_ID,
                                       welvu_topicsModel.topics_guid, HTTP_REQUEST_TOPIC_GUID,
                                       welvu_topicsModel.topicName, HTTP_RESPONSE_TITLE, nil];
                        
                        
                        NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                        if(appDelegate.welvu_userModel.org_id > 0) {
                            [requestDataMutable
                             setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                             forKey:HTTP_REQUEST_ORGANISATION_KEY];
                        }
                        
                        
                        requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                                    attachmentType:nil
                                                     attachmentExt:nil
                                                attachmentFileName:nil];
                    }
                        break;
                    } {
                    default:
                        break;
                    }
                        
                }
                NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                    [connection start];
                }];
                
                
                
                
            });
        }
        
        
        
        else {
            appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            NSString *accessToken = nil;
            if(appDelegate.welvu_userModel.access_token == nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            } else {
                accessToken = appDelegate.welvu_userModel.access_token;
            }
            
            // NSLog( @"access token sync data %@",accessToken);
            welvuPlatformActionUrl = action_url;
            NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, welvuPlatformActionUrl];
            /* if([welvuPlatformActionUrl isEqualToString:@"/udidtoguid"]) {
             NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL2, welvuPlatformActionUrl];
             } else {
             NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, welvuPlatformActionUrl];
             }*/
            NSURL *requestURL = [NSURL URLWithString:urlStr];
            NSData *contentData = nil;
            NSDictionary *syncContent = nil;
            NSMutableURLRequest *requestDelegate = nil;
            NSInteger actionTypeContant;
            UIDeviceHardware *device = [[UIDeviceHardware alloc] init];
            NSString * deviceModel = [device platformString];
            NSString *currSysVeriosion = [[UIDevice currentDevice] systemVersion];
            
            switch (syncType) {
                {
                case SYNC_TYPE_PLATFORM_ID_CONSTANT: {
                    syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                   
                                   [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                   [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                   action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                   deviceModel, HTTP_REQUEST_DEVICE_INFO,
                                   [self getDeviceUDID], HTTP_REQUEST_DEVICE_GUID,
                                   currSysVeriosion, HTTP_REQUEST_PLATFORM_VERSION,nil];
                    
                    // NSLog(@"uidid chages");
                    
                    
                    
                    NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                    if(appDelegate.welvu_userModel.org_id > 0) {
                        [requestDataMutable
                         setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                         forKey:HTTP_REQUEST_ORGANISATION_KEY];
                    }
                    
                    
                    
                    
                    requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                                attachmentType:nil
                                                 attachmentExt:nil
                                            attachmentFileName:nil];
                }
                    break;
                case SYNC_TYPE_CONTENT_CONSTANT: {
                    if([action_type isEqualToString:HTTP_REQUEST_ACTION_TYPE_CREATE]) {
                        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                        
                        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                        
                        welvu_images *welvu_imageModel = [welvu_images getImageById:[appDelegate getDBPath] :object_id
                                                                             userId:appDelegate.welvu_userModel.welvu_user_id];
                        
                        NSLog(@"welvu image url %@",welvu_imageModel.url);
                        NSURL *fileURL;
                        if(welvu_imageModel.url) {
                            fileURL = [[NSURL alloc] initFileURLWithPath:welvu_imageModel.url];
                        } else {
                            fileURL = [[NSBundle mainBundle] URLForResource:welvu_imageModel.url withExtension:nil];
                        }
                        NSLog(@"welvu image url %@",fileURL);
                        // NSURL *fileURL = [[NSBundle mainBundle] URLForResource:welvu_imageModel.url withExtension:nil];
                        
                        NSArray *parts = [[welvu_imageModel.url lastPathComponent] componentsSeparatedByString:@"."];
                        contentData = [[NSData alloc] initWithContentsOfURL:fileURL];
                        NSString *contentType = parts[([parts count] - 1)];
                        NSString *type = nil;
                        NSString *attachmentType = nil;
                        if([welvu_imageModel.type isEqualToString:IMAGE_VIDEO_TYPE]
                           || [welvu_imageModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE]) {
                            
                            type = IMAGE_VIDEO_TYPE;
                            if([contentType isEqualToString:HTTP_ATTACHMENT_VIDEO_EXT_MOV_KEY]) {
                                attachmentType = HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_MOV_KEY;
                            } else if([contentType isEqualToString:HTTP_ATTACHMENT_VIDEO_EXT_KEY]){
                                attachmentType = HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_KEY;
                            }
                        } else {
                            type = IMAGE_ASSET_TYPE;
                            attachmentType = HTTP_ATTACHMENT_IMAGE_CONTENT_TYPE_KEY;
                        }
                        
                        welvu_topics *topicModel = [welvu_topics getTopicById:[appDelegate getDBPath] :welvu_imageModel.topicId
                                                                       userId:appDelegate.welvu_userModel.welvu_user_id];
                        if(topicModel.topics_guid) {
                            
                            syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                           [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                           action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                           topicModel.topics_guid, HTTP_REQUEST_TOPIC_GUID,
                                           welvu_imageModel.image_guid, HTTP_REQUEST_CONTENT_GUID,
                                           type, HTTP_RESPONSE_MEDIA_TYPE,
                                           [NSNumber numberWithInt:welvu_imageModel.orderNumber], HTTP_RESPONSE_MEDIA_ORDER, nil];
                        } else {
                            syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                           [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                           action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                           [NSNumber numberWithInt:topicModel.topicId], HTTP_REQUEST_TOPIC_ID,
                                           welvu_imageModel.image_guid, HTTP_REQUEST_CONTENT_GUID,
                                           type, HTTP_RESPONSE_MEDIA_TYPE,
                                           [NSNumber numberWithInt:welvu_imageModel.orderNumber], HTTP_RESPONSE_MEDIA_ORDER, nil];
                        }
                        
                        NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                        if(appDelegate.welvu_userModel.org_id > 0) {
                            [requestDataMutable
                             setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                             forKey:HTTP_REQUEST_ORGANISATION_KEY];
                        }
                        
                        requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:contentData
                                                    attachmentType:attachmentType
                                                     attachmentExt:contentType
                                                attachmentFileName:welvu_imageModel.imageDisplayName];
                    }
                }
                    break;
                } {
                case SYNC_TYPE_TOPIC_CONSTANT: {
                    welvu_topics *welvu_topicsModel = [welvu_topics getTopicById:[appDelegate getDBPath] :object_id
                                                                          userId:appDelegate.welvu_userModel.welvu_user_id];
                    syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                   
                                   [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                   [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                   action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                   [NSNumber numberWithInt:welvu_topicsModel.specialty_id], HTTP_SPECIALTY_ID,
                                   welvu_topicsModel.topics_guid, HTTP_REQUEST_TOPIC_GUID,
                                   welvu_topicsModel.topicName, HTTP_RESPONSE_TITLE, nil];
                    
                    NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                    if(appDelegate.welvu_userModel.org_id > 0) {
                        [requestDataMutable
                         setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                         forKey:HTTP_REQUEST_ORGANISATION_KEY];
                    }
                    requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                                attachmentType:nil
                                                 attachmentExt:nil
                                            attachmentFileName:nil];
                }
                    break;
                    
                } {
                    
                    //santhosh sep 25
                case SYNC_TYPE_TOPIC_CHANGES_CONSTANT: {
                    welvu_topics *welvu_topicsModel = [welvu_topics getTopicById:[appDelegate getDBPath] :object_id
                                                                          userId:appDelegate.welvu_userModel.welvu_user_id];
                    syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                   
                                   [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                   [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                   action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                   [NSNumber numberWithInt:welvu_topicsModel.specialty_id], HTTP_SPECIALTY_ID,
                                   welvu_topicsModel.topics_guid, HTTP_REQUEST_TOPIC_GUID,
                                   welvu_topicsModel.topicName, HTTP_RESPONSE_TITLE, nil];
                    
                    
                    NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                    if(appDelegate.welvu_userModel.org_id > 0) {
                        [requestDataMutable
                         setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                         forKey:HTTP_REQUEST_ORGANISATION_KEY];
                    }
                    
                    
                    requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                                attachmentType:nil
                                                 attachmentExt:nil
                                            attachmentFileName:nil];
                }
                    break;
                } {
                default:
                    break;
                }
                    
            }
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
            bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [connection start];
            }];
        }
    }
    
    
    
    
    
    
    else {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        NSString *accessToken = nil;
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        
        // NSLog( @"access token sync data %@",accessToken);
        welvuPlatformActionUrl = action_url;
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, welvuPlatformActionUrl];
        NSURL *requestURL = [NSURL URLWithString:urlStr];
        NSData *contentData = nil;
        NSDictionary *syncContent = nil;
        NSMutableURLRequest *requestDelegate = nil;
        NSInteger actionTypeContant;
        UIDeviceHardware *device = [[UIDeviceHardware alloc] init];
        NSString * deviceModel = [device platformString];
        NSString *currSysVeriosion = [[UIDevice currentDevice] systemVersion];
        
        switch (syncType) {
            {
            case SYNC_TYPE_PLATFORM_ID_CONSTANT: {
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                               deviceModel, HTTP_REQUEST_DEVICE_INFO,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_GUID,
                               currSysVeriosion, HTTP_REQUEST_PLATFORM_VERSION,nil];
                
                // NSLog(@"uidid chages");
                
                
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                
                
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
            case SYNC_TYPE_CONTENT_CONSTANT: {
                if([action_type isEqualToString:HTTP_REQUEST_ACTION_TYPE_CREATE]) {
                    welvu_images *welvu_imageModel = [welvu_images getImageById:[appDelegate getDBPath] :object_id
                                                                         userId:appDelegate.welvu_userModel.welvu_user_id];
                    
                    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:welvu_imageModel.url];
                    NSArray *parts = [[welvu_imageModel.url lastPathComponent] componentsSeparatedByString:@"."];
                    contentData = [[NSData alloc] initWithContentsOfURL:fileURL];
                    NSString *contentType = parts[([parts count] - 1)];
                    NSString *type = nil;
                    NSString *attachmentType = nil;
                    if([welvu_imageModel.type isEqualToString:IMAGE_VIDEO_TYPE]
                       || [welvu_imageModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE]) {
                        
                        type = IMAGE_VIDEO_TYPE;
                        if([contentType isEqualToString:HTTP_ATTACHMENT_VIDEO_EXT_MOV_KEY]) {
                            attachmentType = HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_MOV_KEY;
                        } else if([contentType isEqualToString:HTTP_ATTACHMENT_VIDEO_EXT_KEY]){
                            attachmentType = HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_KEY;
                        }
                    } else {
                        type = IMAGE_ASSET_TYPE;
                        attachmentType = HTTP_ATTACHMENT_IMAGE_CONTENT_TYPE_KEY;
                    }
                    
                    welvu_topics *topicModel = [welvu_topics getTopicById:[appDelegate getDBPath] :welvu_imageModel.topicId
                                                                   userId:appDelegate.welvu_userModel.welvu_user_id];
                    if(topicModel.topics_guid) {
                        
                        syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                       accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                       [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                       [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                       action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                       topicModel.topics_guid, HTTP_REQUEST_TOPIC_GUID,
                                       welvu_imageModel.image_guid, HTTP_REQUEST_CONTENT_GUID,
                                       type, HTTP_RESPONSE_MEDIA_TYPE,
                                       [NSNumber numberWithInt:welvu_imageModel.orderNumber], HTTP_RESPONSE_MEDIA_ORDER, nil];
                    } else {
                        syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                       accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                       [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                       [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                       action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                       [NSNumber numberWithInt:topicModel.topicId], HTTP_REQUEST_TOPIC_ID,
                                       welvu_imageModel.image_guid, HTTP_REQUEST_CONTENT_GUID,
                                       type, HTTP_RESPONSE_MEDIA_TYPE,
                                       [NSNumber numberWithInt:welvu_imageModel.orderNumber], HTTP_RESPONSE_MEDIA_ORDER, nil];
                    }
                    
                    NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                    if(appDelegate.welvu_userModel.org_id > 0) {
                        [requestDataMutable
                         setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                         forKey:HTTP_REQUEST_ORGANISATION_KEY];
                    }
                    
                    requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:contentData
                                                attachmentType:attachmentType
                                                 attachmentExt:contentType
                                            attachmentFileName:welvu_imageModel.imageDisplayName];
                }
            }
                break;
            } {
            case SYNC_TYPE_TOPIC_CONSTANT: {
                welvu_topics *welvu_topicsModel = [welvu_topics getTopicById:[appDelegate getDBPath] :object_id
                                                                      userId:appDelegate.welvu_userModel.welvu_user_id];
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                               [NSNumber numberWithInt:welvu_topicsModel.specialty_id], HTTP_SPECIALTY_ID,
                               welvu_topicsModel.topics_guid, HTTP_REQUEST_TOPIC_GUID,
                               welvu_topicsModel.topicName, HTTP_RESPONSE_TITLE, nil];
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
                
            } {
                
                //santhosh sep 25
            case SYNC_TYPE_TOPIC_CHANGES_CONSTANT: {
                welvu_topics *welvu_topicsModel = [welvu_topics getTopicById:[appDelegate getDBPath] :object_id
                                                                      userId:appDelegate.welvu_userModel.welvu_user_id];
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                               [NSNumber numberWithInt:welvu_topicsModel.specialty_id], HTTP_SPECIALTY_ID,
                               welvu_topicsModel.topics_guid, HTTP_REQUEST_TOPIC_GUID,
                               welvu_topicsModel.topicName, HTTP_RESPONSE_TITLE, nil];
                
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
            } {
            default:
                break;
            }
                
        }
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [connection start];
        }];
        
        
        
        
    }
}


/*
 * Method name: startSyncDataToCloud
 * Description: To start sync data to the cloud
 * Parameters: synctype,guid,objectid,action type,action url
 * return nil
 */
- (void)startSyncDataToCloud:(NSInteger)syncType guid:(NSString *) guid
                    objectId:(NSInteger)object_id actionType:(NSString *) action_type
                   actionURL:(NSString *)action_url {
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        NSString *accessToken = nil;
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        
        // NSLog( @"access token sync data %@",accessToken);
        welvuPlatformActionUrl = action_url;
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, welvuPlatformActionUrl];
        NSURL *requestURL = [NSURL URLWithString:urlStr];
        NSData *contentData = nil;
        NSDictionary *syncContent = nil;
        NSMutableURLRequest *requestDelegate = nil;
        NSInteger actionTypeContant;
        UIDeviceHardware *device = [[UIDeviceHardware alloc] init];
        NSString * deviceModel = [device platformString];
        NSString *currSysVeriosion = [[UIDevice currentDevice] systemVersion];
        
        
        
        switch (syncType) {
            {
            case SYNC_TYPE_OS_CHANGES_CONSTANT: {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *preIosVersion = [defaults objectForKey:@"previousiOSVersion"];
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                               deviceModel, HTTP_REQUEST_DEVICE_INFO,
                               guid, HTTP_REQUEST_CONTENT_GUID,
                               currSysVeriosion, HTTP_REQUEST_PLATFORM_VERSION,
                               preIosVersion, HTTP_REQUEST_OLD_PLATFORM_VERSION,
                               nil];
                // NSLog(@"os changes");
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
            case SYNC_TYPE_PLATFORM_ID_CONSTANT: {
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                               deviceModel, HTTP_REQUEST_DEVICE_INFO,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_GUID,
                               currSysVeriosion, HTTP_REQUEST_PLATFORM_VERSION,nil];
                
                // NSLog(@"uidid chages");
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
            case SYNC_TYPE_CONTENT_CONSTANT: {
                if([action_type isEqualToString:HTTP_REQUEST_ACTION_TYPE_CREATE]) {
                    welvu_images *welvu_imageModel = [welvu_images getImageById:[appDelegate getDBPath] :object_id
                                                                         userId:appDelegate.welvu_userModel.welvu_user_id];
                    
                    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:welvu_imageModel.url];
                    NSArray *parts = [[welvu_imageModel.url lastPathComponent] componentsSeparatedByString:@"."];
                    contentData = [[NSData alloc] initWithContentsOfURL:fileURL];
                    NSString *contentType = parts[([parts count] - 1)];
                    NSString *type = nil;
                    NSString *attachmentType = nil;
                    if([welvu_imageModel.type isEqualToString:IMAGE_VIDEO_TYPE]
                       || [welvu_imageModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE]) {
                        
                        type = IMAGE_VIDEO_TYPE;
                        if([contentType isEqualToString:HTTP_ATTACHMENT_VIDEO_EXT_MOV_KEY]) {
                            attachmentType = HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_MOV_KEY;
                        } else if([contentType isEqualToString:HTTP_ATTACHMENT_VIDEO_EXT_KEY]){
                            attachmentType = HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_KEY;
                        }
                    } else {
                        type = IMAGE_ASSET_TYPE;
                        attachmentType = HTTP_ATTACHMENT_IMAGE_CONTENT_TYPE_KEY;
                    }
                    
                    welvu_topics *topicModel = [welvu_topics getTopicById:[appDelegate getDBPath] :welvu_imageModel.topicId
                                                                   userId:appDelegate.welvu_userModel.welvu_user_id];
                    if(topicModel.topics_guid) {
                        
                        syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                       [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                       action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                       topicModel.topics_guid, HTTP_REQUEST_TOPIC_GUID,
                                       welvu_imageModel.image_guid, HTTP_REQUEST_CONTENT_GUID,
                                       type, HTTP_RESPONSE_MEDIA_TYPE,
                                       [NSNumber numberWithInt:welvu_imageModel.orderNumber], HTTP_RESPONSE_MEDIA_ORDER, nil];
                    } else {
                        syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                       [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                       action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                       [NSNumber numberWithInt:topicModel.topicId], HTTP_REQUEST_TOPIC_ID,
                                       welvu_imageModel.image_guid, HTTP_REQUEST_CONTENT_GUID,
                                       type, HTTP_RESPONSE_MEDIA_TYPE,
                                       [NSNumber numberWithInt:welvu_imageModel.orderNumber], HTTP_RESPONSE_MEDIA_ORDER, nil];
                    }
                    
                    NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                    if(appDelegate.welvu_userModel.org_id > 0) {
                        [requestDataMutable
                         setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                         forKey:HTTP_REQUEST_ORGANISATION_KEY];
                    }
                    
                    requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:contentData
                                                attachmentType:attachmentType
                                                 attachmentExt:contentType
                                            attachmentFileName:welvu_imageModel.imageDisplayName];
                }
            }
                break;
            } {
            case SYNC_TYPE_TOPIC_CONSTANT: {
                welvu_topics *welvu_topicsModel = [welvu_topics getTopicById:[appDelegate getDBPath] :object_id
                                                                      userId:appDelegate.welvu_userModel.welvu_user_id];
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                               [NSNumber numberWithInt:welvu_topicsModel.specialty_id], HTTP_SPECIALTY_ID,
                               welvu_topicsModel.topics_guid, HTTP_REQUEST_TOPIC_GUID,
                               welvu_topicsModel.topicName, HTTP_RESPONSE_TITLE, nil];
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
                
            }
            default:
                break;
        }
        
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [connection start];
        }];
        
    }else {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        NSString *accessToken = nil;
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        
        // NSLog( @"access token sync data %@",accessToken);
        welvuPlatformActionUrl = action_url;
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL, welvuPlatformActionUrl];
        NSURL *requestURL = [NSURL URLWithString:urlStr];
        NSData *contentData = nil;
        NSDictionary *syncContent = nil;
        NSMutableURLRequest *requestDelegate = nil;
        NSInteger actionTypeContant;
        UIDeviceHardware *device = [[UIDeviceHardware alloc] init];
        NSString * deviceModel = [device platformString];
        NSString *currSysVeriosion = [[UIDevice currentDevice] systemVersion];
        
        
        
        switch (syncType) {
            {
            case SYNC_TYPE_OS_CHANGES_CONSTANT: {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *preIosVersion = [defaults objectForKey:@"previousiOSVersion"];
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                               deviceModel, HTTP_REQUEST_DEVICE_INFO,
                               guid, HTTP_REQUEST_CONTENT_GUID,
                               currSysVeriosion, HTTP_REQUEST_PLATFORM_VERSION,
                               preIosVersion, HTTP_REQUEST_OLD_PLATFORM_VERSION,
                               nil];
                // NSLog(@"os changes");
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
            case SYNC_TYPE_PLATFORM_ID_CONSTANT: {
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                               deviceModel, HTTP_REQUEST_DEVICE_INFO,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_GUID,
                               currSysVeriosion, HTTP_REQUEST_PLATFORM_VERSION,nil];
                
                // NSLog(@"uidid chages");
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
            case SYNC_TYPE_CONTENT_CONSTANT: {
                if([action_type isEqualToString:HTTP_REQUEST_ACTION_TYPE_CREATE]) {
                    welvu_images *welvu_imageModel = [welvu_images getImageById:[appDelegate getDBPath] :object_id
                                                                         userId:appDelegate.welvu_userModel.welvu_user_id];
                    
                    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:welvu_imageModel.url];
                    NSArray *parts = [[welvu_imageModel.url lastPathComponent] componentsSeparatedByString:@"."];
                    contentData = [[NSData alloc] initWithContentsOfURL:fileURL];
                    NSString *contentType = parts[([parts count] - 1)];
                    NSString *type = nil;
                    NSString *attachmentType = nil;
                    if([welvu_imageModel.type isEqualToString:IMAGE_VIDEO_TYPE]
                       || [welvu_imageModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE]) {
                        
                        type = IMAGE_VIDEO_TYPE;
                        if([contentType isEqualToString:HTTP_ATTACHMENT_VIDEO_EXT_MOV_KEY]) {
                            attachmentType = HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_MOV_KEY;
                        } else if([contentType isEqualToString:HTTP_ATTACHMENT_VIDEO_EXT_KEY]){
                            attachmentType = HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_KEY;
                        }
                    } else {
                        type = IMAGE_ASSET_TYPE;
                        attachmentType = HTTP_ATTACHMENT_IMAGE_CONTENT_TYPE_KEY;
                    }
                    
                    welvu_topics *topicModel = [welvu_topics getTopicById:[appDelegate getDBPath] :welvu_imageModel.topicId
                                                                   userId:appDelegate.welvu_userModel.welvu_user_id];
                    if(topicModel.topics_guid) {
                        
                        syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                       accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                       [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                       [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                       action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                       topicModel.topics_guid, HTTP_REQUEST_TOPIC_GUID,
                                       welvu_imageModel.image_guid, HTTP_REQUEST_CONTENT_GUID,
                                       type, HTTP_RESPONSE_MEDIA_TYPE,
                                       [NSNumber numberWithInt:welvu_imageModel.orderNumber], HTTP_RESPONSE_MEDIA_ORDER, nil];
                    } else {
                        syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                       accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                       [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                       [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                       action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                       [NSNumber numberWithInt:topicModel.topicId], HTTP_REQUEST_TOPIC_ID,
                                       welvu_imageModel.image_guid, HTTP_REQUEST_CONTENT_GUID,
                                       type, HTTP_RESPONSE_MEDIA_TYPE,
                                       [NSNumber numberWithInt:welvu_imageModel.orderNumber], HTTP_RESPONSE_MEDIA_ORDER, nil];
                    }
                    
                    NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                    if(appDelegate.welvu_userModel.org_id > 0) {
                        [requestDataMutable
                         setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                         forKey:HTTP_REQUEST_ORGANISATION_KEY];
                    }
                    
                    requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:contentData
                                                attachmentType:attachmentType
                                                 attachmentExt:contentType
                                            attachmentFileName:welvu_imageModel.imageDisplayName];
                }
            }
                break;
            } {
            case SYNC_TYPE_TOPIC_CONSTANT: {
                welvu_topics *welvu_topicsModel = [welvu_topics getTopicById:[appDelegate getDBPath] :object_id
                                                                      userId:appDelegate.welvu_userModel.welvu_user_id];
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                               [NSNumber numberWithInt:welvu_topicsModel.specialty_id], HTTP_SPECIALTY_ID,
                               welvu_topicsModel.topics_guid, HTTP_REQUEST_TOPIC_GUID,
                               welvu_topicsModel.topicName, HTTP_RESPONSE_TITLE, nil];
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
                
            }
            default:
                break;
        }
        
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [connection start];
        }];
        
    }
}

/*
 * Method name: checkForUpdate
 * Description: Checking for update
 * Parameters: platformActionUrl
 * return nil
 * Created On: 06-feb-2013
 */
- (void)checkForUpdate:(NSString *)platformActionUrl {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        //[appDelegate refreshBoxAccessToken];
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        
        
        
        /*  NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, platformActionUrl];
         NSURL *requestURL = [NSURL URLWithString:urlStr];
         
         
         NSLog(@"get string %@",requestURL);*/
        
        NSString *OrgId = [NSString stringWithFormat:@"&organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
        NSLog(@"get OrgId %@",OrgId);
        
        
        
        
        
        NSString *getDEviceId= [NSString stringWithFormat:@"device_id=%@",[self getDeviceUDID]];
        NSLog(@"get string %@",getDEviceId);
        
        NSURL *requestURL ;
        
        if(appDelegate.welvu_userModel.org_id >0) {
            requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",PLATFORM_GET_NOTIFICATION_DATA_URL,getDEviceId ,OrgId]];
        } else {
            requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PLATFORM_GET_NOTIFICATION_DATA_URL,getDEviceId]];
        }
        NSLog(@"get string %@",requestURL);
        
        
        
        NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
        [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
        
        [request setHTTPMethod:HTTP_METHOD_GET];
        
        getNotificatioData =
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        [getNotificatioData start];
        
        
    }else {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        //[appDelegate refreshBoxAccessToken];
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        NSString *accessToken = nil;
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        
        
        welvuPlatformActionUrl = platformActionUrl;
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL, platformActionUrl];
        NSURL *requestURL = [NSURL URLWithString:urlStr];
        NSDictionary *syncContent = nil;
        
        
        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX] ) {
            
            if([BoxSDK sharedSDK].OAuth2Session.accessToken != nil) {
                appDelegate.welvu_userModel.box_access_token = [BoxSDK sharedSDK].OAuth2Session.accessToken;
                appDelegate.welvu_userModel.box_refresh_access_token= [BoxSDK sharedSDK].OAuth2Session.refreshToken;
                appDelegate.welvu_userModel.box_expires_in =  [BoxSDK sharedSDK].OAuth2Session.accessTokenExpiration;
                [welvu_user updateBoxAccessToken:[appDelegate getDBPath] :appDelegate.welvu_userModel];
            }
            
            syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                           accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                           [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                           appDelegate.welvu_userModel.box_access_token ,HTTP_RESPONSE_BOX_ACCESSTOKEN_KEY,
                           appDelegate.welvu_userModel.box_refresh_access_token ,HTTP_RESPONSE_BOX_REFRESH_ACCESSTOKEN_KEY,
                           appDelegate.welvu_userModel.box_expires_in ,HTTP_RESPONSE_BOX_EXPIRES_IN,
                           [NSNumber numberWithInteger:appDelegate.specialtyId], HTTP_SPECIALTY_ID,
                           [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID, nil];
            
        }
        
        else {
            syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                           accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                           [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                           [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID, nil];
            
        }
        
        NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
        if(appDelegate.welvu_userModel.org_id > 0) {
            [requestDataMutable
             setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
             forKey:HTTP_REQUEST_ORGANISATION_KEY];
        }
        
        
        NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                                         attachmentType:nil
                                                          attachmentExt:nil
                                                     attachmentFileName:nil];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [connection start];
        }];
        
    }
    
}
/*
 * Method name: syncNotificationToDevice
 * Description: sync notification to device
 * Parameters: platformActionUrl
 * return nil
 * Created On: 06-feb-2013
 */
- (void)syncNotificationToDevice:(NSString *)platformActionUrl notificationId:
(NSInteger) notification_id {
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    
    if( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        //[appDelegate refreshBoxAccessToken];
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        
        
        
        /*  NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, platformActionUrl];
         NSURL *requestURL = [NSURL URLWithString:urlStr];
         
         
         NSLog(@"get string %@",requestURL);*/
        
        NSString *getOrgId = [NSString stringWithFormat:@"&organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
        NSLog(@"get OrgId %@",getOrgId);
        
        
        
        
        
        NSString *getDEviceId= [NSString stringWithFormat:@"device_id=%@",[self getDeviceUDID]];
        NSLog(@"get string %@",getDEviceId);
        
        
        NSString *notificationID= [NSString stringWithFormat:@"&notification_id=%@",[NSNumber numberWithInt:notification_id]];
        
        
        NSString *parameterValues = [NSString stringWithFormat: @"%@%@%@", getDEviceId, getOrgId ,notificationID];
        
        NSLog(@"parameterValues %@",parameterValues);
        
        NSURL *requestURL ;
        
        if(appDelegate.welvu_userModel.org_id >0) {
            requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PLATFORM_READ_NOTIFICATION_DATA_URL,parameterValues]];
        } else {
            requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",PLATFORM_READ_NOTIFICATION_DATA_URL,getDEviceId,notificationID]];
        }
        NSLog(@"get string %@",requestURL);
        
        
        
        NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
        [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
        
        [request setHTTPMethod:HTTP_METHOD_GET];
        
        readNotificationData =
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        [readNotificationData start];
        
        /* appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
         appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
         NSString *accessToken = nil;
         if(appDelegate.welvu_userModel.access_token == nil) {
         NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
         accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
         } else {
         accessToken = appDelegate.welvu_userModel.access_token;
         }
         
         // NSLog( @"access token %@",accessToken);
         welvuPlatformActionUrl = platformActionUrl;
         
         NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, platformActionUrl];
         NSURL *requestURL = [NSURL URLWithString:urlStr];
         NSDictionary *syncContent = nil;
         syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
         [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
         [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
         [NSNumber numberWithInt:notification_id], HTTP_REQUEST_NOTIFICATION_ID, nil];
         
         NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
         if(appDelegate.welvu_userModel.org_id > 0) {
         [requestDataMutable
         setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
         forKey:HTTP_REQUEST_ORGANISATION_KEY];
         }
         
         NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:requestURL
         andDataDictionary:requestDataMutable attachmentData:nil
         attachmentType:nil
         attachmentExt:nil
         attachmentFileName:nil];
         
         NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
         bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
         [connection start];
         }];*/
        
    } else {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        NSString *accessToken = nil;
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        
        // NSLog( @"access token %@",accessToken);
        welvuPlatformActionUrl = platformActionUrl;
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL, platformActionUrl];
        NSURL *requestURL = [NSURL URLWithString:urlStr];
        NSDictionary *syncContent = nil;
        syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                       accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                       [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                       [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                       [NSNumber numberWithInt:notification_id], HTTP_REQUEST_NOTIFICATION_ID, nil];
        
        NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
        if(appDelegate.welvu_userModel.org_id > 0) {
            [requestDataMutable
             setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
             forKey:HTTP_REQUEST_ORGANISATION_KEY];
        }
        
        NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:requestURL
                                                      andDataDictionary:requestDataMutable attachmentData:nil
                                                         attachmentType:nil
                                                          attachmentExt:nil
                                                     attachmentFileName:nil];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [connection start];
        }];
        
    }
}
/*
 * Method name: POSTRequestWithURL
 * Description: post the data with this url
 * Parameters: attachment_fileName,attachmentType
 * return request
 * Created On: 06-feb-2013
 */
- (NSMutableURLRequest *)POSTRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) message_data
                             attachmentData:(NSData *) attachment_data
                             attachmentType:(NSString *) attachment_type
                              attachmentExt:(NSString *) attachment_ext
                         attachmentFileName:(NSString *) attachment_fileName {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:180.0];
    [request setHTTPMethod:HTTP_METHOD_POST];
    
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
        [body appendData:[[NSString stringWithFormat:@"%@\"%@\"; filename=\"%@.%@\"\r\n",HTTP_CONTENT_DISPOSITION, @"filename",attachment_fileName, attachment_ext] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@: %@\r\n\r\n",HTTP_REQUEST_CONTENT_TYPE_KEY,attachment_type] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:attachment_data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", HTTP_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    
    NSLog(@"expires in %@",appDelegate.welvu_userModel.oauth_expires_in);
    NSLog(@"current date in %@",appDelegate.welvu_userModel.oauth_currentDate);
    NSLog(@"accesstoken %@",appDelegate.welvu_userModel.access_token);
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
            
            NSLog(@"accesstoken %@",appDelegate.welvu_userModel.access_token);
            NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
            [request setValue:postLength forHTTPHeaderField:HTTP_REQUEST_CONTENT_LENGTH_KEY];
            NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token];
            [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
            // set URL
            [request setURL:url];
            
            
            
        });
    }
    else {
        // set the content-length
        NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
        [request setValue:postLength forHTTPHeaderField:HTTP_REQUEST_CONTENT_LENGTH_KEY];
        NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token];
        [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
        // set URL
        [request setURL:url];
        
    }
    return request;
    
}

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
//Did receive Response-NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.delegate syncContentToPlatformSendResponse:YES];
    [[UIApplication sharedApplication] endBackgroundTask:bti];
    bti = UIBackgroundTaskInvalid;
    
}
//didReceiveData-NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(data) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        // 1. get the top level value as a dictionary
        NSString* newStr = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
        //responseStr = [defaults  objectForKey:@"syncResponseStr"];
        responseStr = [responseStr stringByAppendingString:newStr];
        
        [defaults setObject:responseStr forKey:@"syncResponseStr"];
    }
}
/*
 * Method name: connectionDidFinishLoading
 * Description:connect finish after data loads
 * Parameters: connection
 * return nil
 * Created On: 06-feb-2013
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    welvuAppDelegate *appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    responseStr = [defaults  objectForKey:@"syncResponseStr"];
    if(responseStr) {
        NSError *error;
        NSString *guid;
        
       // SBJSON *parser = [[SBJSON alloc] init];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@", responseDictionary);
        BOOL success = false;
        /*if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_FAILED_KEY]== NSOrderedSame) &&
         ![welvuPlatformActionUrl isEqualToString:PLATFORM_GET_UPDATE_NOTIFICATIONS]) {
         success = true;
         
         [self.delegate syncResponseDicFromPlatform:success :responseDictionary];
         
         
         }
         else */
        
        NSString * responseStatus = [responseDictionary objectForKey:@"title"];
        
        if([responseStatus isEqualToString:@"Forbidden"]) {
            
            
        }
        else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]== NSOrderedSame)
                && ![welvuPlatformActionUrl isEqualToString:PLATFORM_GET_UPDATE_NOTIFICATIONS]) {
            success = true;
            if([responseDictionary objectForKey:HTTP_REQUEST_CONTENT_GUID]) {
                guid = [responseDictionary objectForKey:HTTP_REQUEST_CONTENT_GUID];
            }else if([responseDictionary objectForKey:HTTP_REQUEST_TOPIC_GUID]) {
                guid = [responseDictionary objectForKey:HTTP_REQUEST_TOPIC_GUID];
            }else if([responseDictionary objectForKey:HTTP_REQUEST_OS_GUID]) {
                guid = [responseDictionary objectForKey:HTTP_REQUEST_OS_GUID];
                NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:currSysVer forKey:@"previousiOSVersion"];
                [defaults setObject:currSysVer forKey:@"currentiOSVersion"];
                [defaults synchronize];
            }else if([responseDictionary objectForKey:HTTP_REQUEST_DEVICE_GUID]) {
                guid = [responseDictionary objectForKey:HTTP_REQUEST_DEVICE_GUID];
            }
            BOOL inserted = [welvu_sync deleteSyncedTask:[appDelegate getDBPath] guid:guid];
            
        } else if([welvuPlatformActionUrl isEqualToString:PLATFORM_GET_UPDATE_NOTIFICATIONS]){
            
            
            
            success = true;
        }
        
        [self.delegate syncContentToPlatformDidReceivedData:success :responseDictionary];
        
    }
    
    [[UIApplication sharedApplication] endBackgroundTask:bti];
    bti = UIBackgroundTaskInvalid;
}
/*
 * Method name: connection
 * Description:if connection fails whilw loading
 * Parameters: error
 * return nil
 * Created On: 06-feb-2013
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Share Content %@",error);
    [self.delegate syncContentFailedWithErrorDetails:error];
    [[UIApplication sharedApplication] endBackgroundTask:bti];
    bti = UIBackgroundTaskInvalid;
}


- (void)startSyncDeletedImageDataToCloud:(NSInteger)syncType guid:(NSString *)object_guid topicId:(NSInteger)Topic_Id  actionType:(NSString *)action_type
                               actionURL:(NSString *)action_url {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        
        
        welvu_topics *welvu_topicsModel = [welvu_topics getTopicDetailByGUID:[appDelegate getDBPath]:object_guid];
        
        
        
        NSString *accessToken = nil;
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        NSNumber *topicIdNumber = [NSNumber numberWithInteger: Topic_Id];
        
        //NSLog( @"access token %@",accessToken);
        welvuPlatformActionUrl = action_url;
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, welvuPlatformActionUrl];
        NSURL *requestURL = [NSURL URLWithString:urlStr];
        NSDictionary *syncContent = nil;
        NSMutableURLRequest *requestDelegate = nil;
        
        switch (syncType) {
            {
            case SYNC_TYPE_IMAGE_DELETE_CONSTANT: {
                
                welvu_topics *topicModel = [welvu_topics getTopicById:[appDelegate getDBPath] :Topic_Id
                                                               userId:appDelegate.welvu_userModel.welvu_user_id];
                
                welvu_images *welvu_imageModel = [welvu_images getImageById:[appDelegate getDBPath] :object_guid
                                                                     userId:appDelegate.welvu_userModel.welvu_user_id];
                if(topicModel.topics_guid) {
                    
                    syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                   [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                   action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                   topicModel.topics_guid ,HTTP_REQUEST_TOPIC_GUID ,
                                   object_guid, HTTP_REQUEST_CONTENT_GUID,
                                   nil];
                    
                } else {
                    syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                   [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                   action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                   topicIdNumber ,HTTP_REQUEST_TOPIC_ID ,
                                   object_guid, HTTP_REQUEST_CONTENT_GUID,
                                   nil];
                    
                }
                
                
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
            } {
            case SYNC_TYPE_TOPIC_DELETE_CONSTANT: {
                welvu_topics *welvu_topicsModel = [welvu_topics getTopicDetailByGUID:[appDelegate getDBPath]:object_guid];
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                               [NSNumber numberWithInt:welvu_topicsModel.specialty_id], HTTP_SPECIALTY_ID,
                               object_guid, HTTP_REQUEST_TOPIC_GUID,
                               nil];
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
            }
            default:
                break;
        }
        
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [connection start];
        }];
        
        
    }else {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        
        
        welvu_topics *welvu_topicsModel = [welvu_topics getTopicDetailByGUID:[appDelegate getDBPath]:object_guid];
        
        
        
        NSString *accessToken = nil;
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        NSNumber *topicIdNumber = [NSNumber numberWithInteger: Topic_Id];
        
        //NSLog( @"access token %@",accessToken);
        welvuPlatformActionUrl = action_url;
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL, welvuPlatformActionUrl];
        NSURL *requestURL = [NSURL URLWithString:urlStr];
        NSDictionary *syncContent = nil;
        NSMutableURLRequest *requestDelegate = nil;
        
        switch (syncType) {
            {
            case SYNC_TYPE_IMAGE_DELETE_CONSTANT: {
                
                welvu_topics *topicModel = [welvu_topics getTopicById:[appDelegate getDBPath] :Topic_Id
                                                               userId:appDelegate.welvu_userModel.welvu_user_id];
                
                welvu_images *welvu_imageModel = [welvu_images getImageById:[appDelegate getDBPath] :object_guid
                                                                     userId:appDelegate.welvu_userModel.welvu_user_id];
                if(topicModel.topics_guid) {
                    
                    syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                   [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                   [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                   action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                   topicModel.topics_guid ,HTTP_REQUEST_TOPIC_GUID ,
                                   object_guid, HTTP_REQUEST_CONTENT_GUID,
                                   nil];
                    
                } else {
                    syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                                   accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                   [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                   [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                   action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                                   topicIdNumber ,HTTP_REQUEST_TOPIC_ID ,
                                   object_guid, HTTP_REQUEST_CONTENT_GUID,
                                   nil];
                    
                }
                
                
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
            } {
            case SYNC_TYPE_TOPIC_DELETE_CONSTANT: {
                welvu_topics *welvu_topicsModel = [welvu_topics getTopicDetailByGUID:[appDelegate getDBPath]:object_guid];
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                               action_type, HTTP_REQUEST_ACTION_TYPE_KEY,
                               [NSNumber numberWithInt:welvu_topicsModel.specialty_id], HTTP_SPECIALTY_ID,
                               object_guid, HTTP_REQUEST_TOPIC_GUID,
                               nil];
                
                NSMutableDictionary *requestDataMutable = [syncContent mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                
                
                requestDelegate = [self POSTRequestWithURL:requestURL andDataDictionary:requestDataMutable attachmentData:nil
                                            attachmentType:nil
                                             attachmentExt:nil
                                        attachmentFileName:nil];
            }
                break;
            }
            default:
                break;
        }
        
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [connection start];
        }];
        
        
    }
    
    
}
@end
