//
//  welvu_sync.h
//  welvu
//
//  Created by Logesh Kumaraguru on 13/03/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
/*
 * Class name: welvu_sync
 * Description: Data model for syncing
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_sync : NSObject {
    NSInteger sync_id;
    NSString *guid;
    NSInteger object_id;
    NSInteger sync_type;
    NSInteger action_type;
    BOOL sync_completed;
}
//Property
@property (nonatomic, readonly) NSInteger sync_id;
@property (nonatomic, copy) NSString *guid;
@property (nonatomic, readwrite) NSInteger object_id;
@property (nonatomic, readwrite) NSInteger sync_type;
@property (nonatomic, readwrite) NSInteger action_type;
@property (nonatomic, readwrite) BOOL sync_completed;

//Methods
- (id)initWithSyncId:(NSInteger)syncId;
+ (BOOL)addSyncDetail:(NSString *)dbPath guid:(NSString *)guid objectId:(NSInteger)object_id
             syncType:(NSInteger)sync_type
           actionType:(NSInteger)action_type;
+ (NSMutableArray *)getSyncList:(NSString *)dbPath;
+ (NSInteger)getSyncCount:(NSString *)dbPath;
+ (BOOL)deleteSyncedTask:(NSString *)dbPath guid:(NSString *)guid;
+ (welvu_sync *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_sync *)welvu_syncModel;
@end
