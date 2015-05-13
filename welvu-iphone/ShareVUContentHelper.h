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

@protocol shareVUContentHelperDelegate
-(void) shareVUContentMailSendResponse:(BOOL)success;
-(void) shareVUContentMailDidReceivedData:(BOOL) success:(NSDictionary *) responseDictionary;
-(void) shareVUContentFailedWithError:(NSError *)error;
@end

@interface ShareVUContentHelper : NSObject <NSURLConnectionDelegate> {
    id<shareVUContentHelperDelegate> delegate;
    welvu_message *welvu_messageModel;
}

@property (retain) id<shareVUContentHelperDelegate> delegate;
-(id) initWithShareVuContent:(welvu_message*) welvu_message_Model;
-(void) shareVUContents;
- (NSMutableURLRequest *) POSTRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) message_data
                              attachmentData:(NSData *) attachment_data attachmentType:(NSString *) attachment_type
                          attachmentFileName:(NSString *) attachment_fileName;
@end
