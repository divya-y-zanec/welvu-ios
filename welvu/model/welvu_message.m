//
//  welvu_message.m
//  welvu
//
//  Created by Logesh Kumaraguru on 09/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_message.h"

@implementation welvu_message
@synthesize messageId, recipients, subject, message, videoFileName,
            videoFileLocation, signature, tag,
            privateVideo, service,
            message_guid;

/*
 * Method name: initWithMessageId
 * Description: Intialize the welvu_message model with messageId
 * Parameters: NSInteger
 * Return Type: id
 */
- (id)initWithMessageId:(NSInteger)mId{
    self = [super init];
    if (self) {
        messageId = mId;
    }
    return self;
}

@end
