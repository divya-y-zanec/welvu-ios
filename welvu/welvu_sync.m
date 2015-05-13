//
//  welvu_sync.m
//  welvu
//
//  Created by Logesh Kumaraguru on 13/03/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_sync.h"
#import "welvuContants.h"
@implementation welvu_sync
@synthesize sync_id, guid, object_id, sync_type, action_type, sync_completed;

static sqlite3 *database = nil;

/*
 * Method name: initWithSyncId
 * Description:initlizing with sync id
 * Parameters: syncId
 * Return Type: self
 */
- (id)initWithSyncId:(NSInteger)syncId {
    self = [super init];
    if (self) {
        sync_id = syncId;
    }
    return self;
}
/*
 * Method name: addSyncDetail
 * Description:Adding the sync details to DB
 * Parameters: dbPath,guid etc
 * Return Type: Bool
 */

+ (BOOL)addSyncDetail:(NSString *)dbPath guid:(NSString *)guid objectId:(NSInteger)object_id
             syncType:(NSInteger)sync_type actionType:(NSInteger)action_type {
    BOOL inserted = false;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        NSString *is_locked ;
        if(action_type != ACTION_TYPE_DELETE_CONSTANT) {
            sql = [NSString stringWithFormat:
                   @"INSERT INTO %@ (%@, %@, %@, %@, %@) VALUES (\"%@\", %d, %d, %d,  \"%@\")",
                   TABLE_WELVU_SYNC, COLUMN_SYNC_GUID, COLUMN_SYNC_OBJECT_ID, COLUMN_SYNC_TYPE, COLUMN_ACTION_TYPE, COLUMN_SYNC_COMPLETED,
                   guid, object_id, sync_type, action_type, COLUMN_CONSTANT_FALSE];
        } else {
            sql = [NSString stringWithFormat:
                   @"delete from %@ where %@=\"%@\";INSERT INTO %@ (%@, %@, %@, %@, %@) VALUES (\"%@\", %d, %d, %d, \"%@\")",
                   TABLE_WELVU_SYNC, COLUMN_SYNC_GUID, guid,
                   TABLE_WELVU_SYNC, COLUMN_SYNC_GUID, COLUMN_SYNC_OBJECT_ID, COLUMN_SYNC_TYPE, COLUMN_ACTION_TYPE, COLUMN_SYNC_COMPLETED,
                   guid, object_id, sync_type, action_type, COLUMN_CONSTANT_FALSE];
            
        }
        // NSLog(@"sql %@",sql);
        
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            inserted = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return inserted;
}
/*
 * Method name: getSyncList
 * Description:Getting  sync list from DB
 * Parameters: dbPath
 * Return Type: syncModels
 */
+ (NSMutableArray *)getSyncList:(NSString *)dbPath {
    NSMutableArray *syncModels = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ order by %@", TABLE_WELVU_SYNC, COLUMN_SYNC_TYPE];
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if (syncModels == nil) {
                    syncModels = [[NSMutableArray alloc] init];
                }
				welvu_sync *welvuSyncModel = [[welvu_sync alloc] initWithSyncId:sqlite3_column_int(selectstmt, 0)];
                welvuSyncModel = [self initWithStmt:selectstmt:welvuSyncModel];
                [syncModels addObject:welvuSyncModel];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return syncModels;
}

/*
 * Method name: getSyncCount
 * Description:To get the number of sync count
 * Parameters: dbPath
 * Return Type: NSInteger
 */
+ (NSInteger)getSyncCount:(NSString *)dbPath {
    
    NSInteger syncCount = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select count(%@) from %@ where %@!=%d and %@!=%d",COLUMN_WELVU_SYNC_ID,
                         TABLE_WELVU_SYNC, COLUMN_SYNC_TYPE, SYNC_TYPE_PLATFORM_ID_CONSTANT, COLUMN_SYNC_TYPE, SYNC_TYPE_OS_CHANGES_CONSTANT];
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			if (sqlite3_step(selectstmt) == SQLITE_ROW) {
                
                syncCount = sqlite3_column_int(selectstmt, 0);
				
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return syncCount;
}

/*
 * Method name: deleteSyncedTask
 * Description:Delete the sync task
 * Parameters: dbPath,guid
 * Return Type: Bool
 */
+ (BOOL)deleteSyncedTask:(NSString *)dbPath guid:(NSString *)guid {
    BOOL deleted = false;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        NSString *is_locked ;
        sql = [NSString stringWithFormat:
               @"delete from %@ where %@=\"%@\"",
               TABLE_WELVU_SYNC, COLUMN_SYNC_GUID, guid];
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            deleted = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return deleted;
}

/*
 * Method name: initWithStmt
 * Description: statments for alerts
 * Parameters: sqlite3_stmt ,welvu_syncModel
 * Return Type: welvu_sync
 */

+ (welvu_sync *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_sync *)welvu_syncModel {
    if (sqlite3_column_text(selectstmt, 1) != nil) {
        welvu_syncModel.guid = [NSString stringWithUTF8String
                                :(char *)sqlite3_column_text(selectstmt, 1)];
    }
    welvu_syncModel.object_id = sqlite3_column_int(selectstmt, 2);
    welvu_syncModel.sync_type = sqlite3_column_int(selectstmt, 3);
    welvu_syncModel.action_type = sqlite3_column_int(selectstmt, 4);
    if (sqlite3_column_text(selectstmt, 5) != nil &&
        [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 5)] isEqualToString:COLUMN_CONSTANT_TRUE]) {
        welvu_syncModel.sync_completed = TRUE;
    } else {
        welvu_syncModel.sync_completed = FALSE;
    }
    return welvu_syncModel;
}
@end
