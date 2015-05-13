//
//  welvu_sharevu.m
//  welvu
//
//  Created by Logesh Kumaraguru on 13/12/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_sharevu.h"
#import "welvuContants.h"

@implementation welvu_sharevu
@synthesize welvu_sharevu_id, welvu_video_id, user_id, sharevu_msg, sharevu_recipients,
sharevu_subject, sharevu_service, signature, created_date, shareVUStatus;
static sqlite3 *database = nil;

/*
 * Method name: initWithId
 * Description: Intializing with  id
 * Parameters: pkId
 * Return Type: self
 */

- (id)initWithId:(NSInteger) pkId {
    self=[super init];
    if (self) {
        welvu_sharevu_id = pkId;
    }
    return self;
}

/*
 * Method name: insertShareVUQueue
 * Description:insert the sharevu queue
 * Parameters: NSString, welvu_sharevu
 * Return Type: NSInteger
 */
+ (NSInteger) insertShareVUQueue:(NSString *)dbPath :(welvu_sharevu *) welvuShareVUModel {
    NSInteger rowId = 0;
    char *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        
        sql = [NSString stringWithFormat:
               @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@) VALUES ( \"%@\", %d, \"%@\", \"%@\", \"%@\", %d)",
               TABLE_WELVU_SHAREVU, COLUMN_SHARE_VU_SUBJECT, COLUMN_WELVU_VIDEO_ID,
               COLUMN_SHAREVU_SERVICE, COLUMN_SIGNATURE, COLUMN_CREATED_DATE, COLUMN_USER_ID,
               welvuShareVUModel.sharevu_subject, welvuShareVUModel.welvu_video_id,
               welvuShareVUModel.sharevu_service, welvuShareVUModel.signature,
               [dateFormatter stringFromDate:welvuShareVUModel.created_date],
               welvuShareVUModel.user_id];
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            rowId = [self getLastInsertRowId:dbPath];
        };
        sqlite3_close(database);
        database = nil;
    }
    dateFormatter = nil;
    return rowId;
}
/*
 * Method name: updateShareVUQueue
 * Description:To update the shareVU Queue.
 * Parameters: dbPath, welvuShareVUModel
 * Return Type: NSInteger
 */
+ (NSInteger) updateShareVUQueue:(NSString *)dbPath :(welvu_sharevu *) welvuShareVUModel {
    int update = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\",%@=\"%@\",%@=\"%@\" where %@=%d",
                         TABLE_WELVU_SHAREVU,
                         COLUMN_SHARE_VU_SUBJECT, welvuShareVUModel.sharevu_subject,
                         COLUMN_SHAREVU_RECIPIENTS, welvuShareVUModel.sharevu_recipients,
                         COLUMN_SHAREVU_MSG, welvuShareVUModel.sharevu_msg,
                         COLUMN_WELVU_SHAREVU_ID, welvuShareVUModel.welvu_sharevu_id];
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            update = 1;
        };
        sqlite3_close(database);
        database = nil;
    }
    return update;
}
/*
 * Method name: updateShareVUStatus
 * Description:To update the status of shareVU.
 * Parameters: dbPath, welvuShareVUModel ,shareVUId ,status
 * Return Type: NSInteger
 */
+ (NSInteger) updateShareVUStatus:(NSString *)dbPath shareVUId:(NSInteger *) shareVUId
                           status:(NSInteger) status {
    int update = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=%d where %@=%d",
                         TABLE_WELVU_SHAREVU,
                         COLUMN_SHAREVU_STATUS, status,
                         COLUMN_WELVU_SHAREVU_ID, shareVUId];
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            update = 1;
        };
        sqlite3_close(database);
        database = nil;
    }
    return update;
}

/*
 * Method name: getLastInsertRowId
 * Description: last inserted row ID
 * Parameters: NSString, NSInteger
 * Return Type: NSInteger
 */
+ (NSInteger)getLastInsertRowId:(NSString *)dbPath {
    NSInteger imageId = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select max(%@) from %@",
                         COLUMN_WELVU_SHAREVU_ID, TABLE_WELVU_SHAREVU];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                imageId = sqlite3_column_int(selectstmt, 0);
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return imageId;
}
/*
 * Method name: getShareVUQueueById
 * Description: To get the shareVU queue by Id
 * Parameters: dbPath, shareQueueId
 * Return Type: welvu_sharevu
 */
+ (welvu_sharevu *) getShareVUQueueById:(NSString *)dbPath queueId:(NSInteger) shareQueueId {
    welvu_sharevu *welvuShareVUModel = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=%d",
                         TABLE_WELVU_SHAREVU, COLUMN_WELVU_SHAREVU_ID, shareQueueId];
        
		sqlite3_stmt *selectstmt;
		if(sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
			if(sqlite3_step(selectstmt) == SQLITE_ROW) {
                welvuShareVUModel = [[welvu_sharevu alloc] initWithId:sqlite3_column_int(selectstmt, 0)];
                welvuShareVUModel = [welvu_sharevu initWithStmt:selectstmt :welvuShareVUModel];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return  welvuShareVUModel;
}
/*
 * Method name: getShareVUQueueByStatus
 * Description: To get the shareVU queue by Status of the message
 * Parameters: dbPath, status
 * Return Type: BOOL
 */

+ (BOOL) getShareVUQueueByStatus:(NSString *)dbPath status:(NSInteger) status {
    BOOL statusFlag = false;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=%d",
                         TABLE_WELVU_SHAREVU, COLUMN_SHAREVU_STATUS, status];
        
		sqlite3_stmt *selectstmt;
		if(sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
			if(sqlite3_step(selectstmt) == SQLITE_ROW) {
                statusFlag = true;
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return statusFlag;
}
/*
 * Method name: initWithStmt
 * Description: statments for alerts
 * Parameters: sqlite3_stmt ,welvuShareVU
 * Return Type: welvu_sharevu
 */

+ (welvu_sharevu *) initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_sharevu *)welvuShareVU {
    if(sqlite3_column_text(selectstmt, 1) != nil) {
        welvuShareVU.sharevu_subject = [NSString stringWithUTF8String
                                        :(char *)sqlite3_column_text(selectstmt, 1)];
    }
    if (sqlite3_column_text(selectstmt, 2) != nil) {
        welvuShareVU.sharevu_recipients = [NSString stringWithUTF8String
                                           :(char *)sqlite3_column_text(selectstmt, 2)];
    }
    if (sqlite3_column_text(selectstmt, 3) != nil) {
        welvuShareVU.sharevu_msg = [NSString stringWithUTF8String
                                    :(char *)sqlite3_column_text(selectstmt, 3)];
    }
    
    welvuShareVU.welvu_video_id = sqlite3_column_int(selectstmt, 4);
    if (sqlite3_column_text(selectstmt, 5) != nil) {
        welvuShareVU.sharevu_service = [NSString stringWithUTF8String
                                        :(char *)sqlite3_column_text(selectstmt, 5)];
    }
    
    if (sqlite3_column_text(selectstmt, 6) != nil) {
        welvuShareVU.signature = [NSString stringWithUTF8String
                                  :(char *)sqlite3_column_text(selectstmt, 6)];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
    if ((char *)sqlite3_column_text(selectstmt,7) != nil) {
        welvuShareVU.created_date =  [dateFormatter dateFromString:
                                      [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 7)]];
    } else {
        welvuShareVU.created_date = nil;
    }
    
    welvuShareVU.user_id = sqlite3_column_int(selectstmt, 8);
    
    dateFormatter = nil;
    
    return welvuShareVU;
}
@end
