//
//  welvu_sharevu.h
//  welvu
//
//  Created by Logesh Kumaraguru on 13/12/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
/*
 * Class name: welvu_sharevu
 * Description: Data model for ShareVu
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_sharevu : NSObject  {
    NSInteger welvu_sharevu_id;
    NSInteger user_id;
    NSString *sharevu_subject;
    NSString *sharevu_recipients;
    NSString *sharevu_msg;
    NSInteger welvu_video_id;
    NSString *sharevu_service;
    NSString *signature;
    NSDate *created_date;
    NSInteger *shareVUStatus;
}
//Property of the objects
@property (nonatomic, readwrite) NSInteger welvu_sharevu_id;
@property (nonatomic, readwrite) NSInteger user_id;
@property (nonatomic, copy) NSString *sharevu_subject;
@property (nonatomic, copy) NSString *sharevu_recipients;
@property (nonatomic, copy) NSString *sharevu_msg;
@property (nonatomic, readwrite) NSInteger welvu_video_id;
@property (nonatomic, readwrite) NSString *sharevu_service;
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, retain) NSDate *created_date;
@property (nonatomic, readwrite) NSInteger *shareVUStatus;

//Methods
+ (NSInteger) insertShareVUQueue:(NSString *)dbPath :(welvu_sharevu *) welvuShareVUModel;
+ (NSInteger) updateShareVUQueue:(NSString *)dbPath :(welvu_sharevu *) welvuShareVUModel;
+ (NSInteger) updateShareVUStatus:(NSString *)dbPath shareVUId:(NSInteger *) shareVUId
                           status:(NSInteger) status;
+ (NSInteger)getLastInsertRowId:(NSString *)dbPath;
+ (welvu_sharevu *) getShareVUQueueById:(NSString *)dbPath queueId:(NSInteger) shareQueueId;
+ (BOOL) getShareVUQueueByStatus:(NSString *)dbPath status:(NSInteger) status;
- (id)initWithId:(NSInteger) pkId;
+ (welvu_sharevu *) initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_sharevu *)welvuShareVU;
@end
