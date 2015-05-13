//
//  welvu_vu_history.m
//  welvu
//
//  Created by Logesh Kumaraguru on 12/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_history.h"
#import "welvuContants.h"

static sqlite3 *database = nil;

@implementation welvu_history
@synthesize welvu_vu_history_id, specialty_id, images_id, history_number, createdDate;


/*
 * Method name: initWithHistoryId
 * Description: Intialize the welvu_history model with welvu_history_id
 * Parameters: NSInteger
 * Return Type: self
 */
- (id)initWithHistoryId:(NSInteger)hId {
    self = [super init];
    if (self) {
        welvu_vu_history_id = hId;
    }
    return  self;
}

/*
 * Method name: isHistoryNumberExist
 * Description: Check the history with that number exist
 * Parameters: NSString, NSInteger
 * Return Type: BOOL
 */
+ (BOOL)isHistoryNumberExist:(NSString *)dbPath:(NSInteger)specialty_id:(NSInteger)history_number {
    BOOL isHistoryNumber = false;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where  %@=%d and %@=%d",
                         COLUMN_HISTORY_NUMBER, TABLE_WELVU_VU_HISTORY,
                         COLUMN_TOPIC_SPECIALTY_ID, specialty_id,
                         COLUMN_HISTORY_NUMBER, history_number];
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                isHistoryNumber = true;
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return isHistoryNumber;
}

/*
 * Method name: getHistoryByHistoryNumber
 * Description: Get History array by history number from db
 * Parameters: NSString, NSInteger
 * Return Type: NSMutableArray
 */
+ (NSMutableArray *)getHistoryByHistoryNumber:(NSString *)dbPath:(NSInteger)specialty_id:(NSInteger) history_number {
    NSMutableArray *welvu_vu_histories = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ = %d and %@ = %d",TABLE_WELVU_VU_HISTORY,
                         COLUMN_TOPIC_SPECIALTY_ID, specialty_id,
                         COLUMN_HISTORY_NUMBER, history_number];
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if(welvu_vu_histories == nil) {
                    welvu_vu_histories = [[NSMutableArray alloc] init];
                }
				welvu_history *welvu_vu_historyModel = [[welvu_history alloc]
                                                        initWithHistoryId:sqlite3_column_int(selectstmt, 0)];
                welvu_vu_historyModel = [welvu_history
                                         initWithStmt:selectstmt :welvu_vu_historyModel];
                [welvu_vu_histories addObject:welvu_vu_historyModel];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return welvu_vu_histories;
}

/*
 * Method name: getFirstHistoryByHistoryNumber
 * Description: Get History array of the first history from db
 * Parameters: NSString, NSInteger
 * Return Type: NSMutableArray
 */
+ (welvu_history *) getFirstHistoryByHistoryNumber:(NSString *)dbPath:(NSInteger) specialty_id:(NSInteger) history_number {
    welvu_history *welvu_vu_historyModel = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ = %d and %@ = %d",TABLE_WELVU_VU_HISTORY,
                         COLUMN_TOPIC_SPECIALTY_ID, specialty_id,
                         COLUMN_HISTORY_NUMBER, history_number];
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                
				welvu_vu_historyModel = [[welvu_history alloc]
                                         initWithHistoryId:sqlite3_column_int(selectstmt, 0)];
                welvu_vu_historyModel = [welvu_history
                                         initWithStmt:selectstmt :welvu_vu_historyModel];
                break;
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return welvu_vu_historyModel;
}

/*
 * Method name: createHistoryVU
 * Description: Creates history for the VU the content in db
 * Parameters: NSString, NSInteger
 * Return Type: BOOL
 */
+ (BOOL)createHistoryVU:(NSString *)dbPath:(NSInteger)specialty_id:(NSInteger)historyNumber:(NSInteger) image_id:(NSDate *)created_date {
    BOOL historyInserted = false;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT_DB];
        sql = [NSString stringWithFormat:
               @"INSERT INTO %@ (%@, %@, %@, %@) VALUES (%d, %d, %d, \"%@\")",
               TABLE_WELVU_VU_HISTORY, COLUMN_HISTORY_NUMBER, COLUMN_TOPIC_SPECIALTY_ID,
               COLUMN_IMAGE_ID, COLUMN_CREATED_DATE,
               historyNumber, specialty_id, image_id, (NSString *)[dateFormatter stringFromDate:created_date]];
        if(sqlite3_exec(database,
                        [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
           SQLITE_OK) {
            historyInserted = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return historyInserted;
}

/*
 * Method name: getMaxHistoryNumber
 * Description: Get the max history number from the db
 * Parameters: NSString
 * Return Type: NSInteger
 */
+ (NSInteger)getMaxHistoryNumber:(NSString *)dbPath:(NSInteger)specialty_id {
    NSInteger max_number = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select count from %@ where %@ == %d", COLUMN_HISTORY_NUMBER,
                         TABLE_WELVU_VU_HISTORY, COLUMN_TOPIC_SPECIALTY_ID, specialty_id];
		sqlite3_stmt *selectstmt;
		if(sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                max_number = sqlite3_column_int(selectstmt, 0);
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return max_number;
}

/*
 * Method name: deleteHistoryWithImageId
 * Description: Delete the History row having imageId
 * Parameters: NSString, NSInteger
 * Return Type: BOOL
 */
+ (BOOL)deleteHistoryWithImageId:(NSString *)dbPath:(NSInteger)imageId {
    BOOL historyDeleted = FALSE;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@=%d",
                         TABLE_WELVU_VU_HISTORY,
                         COLUMN_IMAGE_ID, imageId];
		if(sqlite3_exec(database,
                        [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
           SQLITE_OK) {
            historyDeleted = TRUE;
        };
        sqlite3_close(database);
        database = nil;
    }
    return historyDeleted;
}

/*
 * Method name: deleteOldHistoryVU
 * Description: Delete the old History from db
 * Parameters: NSString, NSInteger
 * Return Type: BOOL
 */
+ (BOOL)deleteOldHistoryVU:(NSString *)dbPath:(NSInteger)specialty_id:(NSInteger)historyNumber {
    BOOL historyDeleted = FALSE;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ =  %d and %@ = %d",
                         TABLE_WELVU_VU_HISTORY, COLUMN_TOPIC_SPECIALTY_ID, specialty_id,
                         COLUMN_HISTORY_NUMBER, historyNumber];
		if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            historyDeleted = TRUE;
        };
        sqlite3_close(database);
        database = nil;
    }
    return historyDeleted;
}

/*
 * Method name: swapOldHistoryVU
 * Description: Swap the History Number with new History number
 * Parameters: NSString, NSInteger
 * Return Type: int
 */
+ (int)swapOldHistoryVU:(NSString *)dbPath:(NSInteger)specialty_id:(NSInteger)from:(NSInteger)to {
    int update = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=%d where %@ =  %d and %@ = %d",
                         TABLE_WELVU_VU_HISTORY,
                         COLUMN_HISTORY_NUMBER, to,
                         COLUMN_TOPIC_SPECIALTY_ID, specialty_id,
                         COLUMN_HISTORY_NUMBER, from];
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
 * Method name: initWithStmt
 * Description: Intializing the welvu_history model object with db values
 * Parameters: sqlite3_stmt, welvu_topics
 * Return Type: welvu_history
 */
+ (welvu_history *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_history *)welvu_vu_historyModel {
    welvu_vu_historyModel.specialty_id = sqlite3_column_int(selectstmt, 2);
    welvu_vu_historyModel.images_id = sqlite3_column_int(selectstmt, 3);
    welvu_vu_historyModel.history_number = sqlite3_column_int(selectstmt, 4);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT_DB];
    if ((char *)sqlite3_column_text(selectstmt,5) != nil) {
        welvu_vu_historyModel.createdDate =  [dateFormatter dateFromString:
                                              [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 5)]];
    } else {
        welvu_vu_historyModel.createdDate = nil;
    }
    return welvu_vu_historyModel;
}

@end
