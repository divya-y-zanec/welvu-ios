//
//  ShareContentVUHelper.h
//  welvu
//
//  Created by Logesh Kumaraguru on 28/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "welvu_message.h"
@class ShareVUContentHelper;
//Delegate method to return selected content
@protocol shareVUContentHelperDelegate
-(void)shareVUContentMailSendResponse:(BOOL)success;
-(void)shareVUContentMailDidReceivedData:(BOOL) success:(NSDictionary *) responseDictionary;
-(void)shareVUContentFailedWithError:(NSError *)error;
@end
/*
 * Class name: ShareVUContentHelper
 * Description:To share the content using this object
 * Extends: NSObject
 * Delegate :NSURLConnectionDelegate
 */
@interface ShareVUContentHelper : NSObject <NSURLConnectionDelegate> {
    //Assigning the delegate for the view
    id<shareVUContentHelperDelegate> delegate;
    welvu_message *welvu_messageModel;
    UIBackgroundTaskIdentifier bti;
}
//Assigning the property for the delegate
@property (retain) id<shareVUContentHelperDelegate> delegate;
//Methods
-(id) initWithShareVuContent:(welvu_message*) welvu_message_Model;
-(void) shareVUContents;
- (NSMutableURLRequest *) POSTRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) message_data
                              attachmentData:(NSData *) attachment_data attachmentType:(NSString *) attachment_type
                          attachmentFileName:(NSString *) attachment_fileName;
@end
