//
//  welvu_message.h
//  welvu
//
//  Created by Logesh Kumaraguru on 09/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * Class name: welvu_message
 * Description: Data model for message content and VU attachment
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_message : NSObject {
    NSInteger messageId;
    NSString *message_guid;
    NSString *recipients;
    NSString *subject;
    NSString *message;
    NSString *videoFileName;
    NSString *videoFileLocation;
    NSString *signature;
    NSInteger privateVideo;
    NSString *tag;
    NSString *service;
}
//Property of the objects
@property (nonatomic, readonly) NSInteger messageId;
@property (nonatomic, copy) NSString *message_guid;
@property (nonatomic, copy) NSString *recipients;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy)  NSString *message;
@property (nonatomic, copy)  NSString *videoFileName;
@property (nonatomic, copy)  NSString *videoFileLocation;
@property (nonatomic, copy)  NSString *signature;
@property (nonatomic, readwrite) NSInteger privateVideo;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *service;

//Method
- (id)initWithMessageId:(NSInteger)mId;

@end
