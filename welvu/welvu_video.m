//
//  welvu_video.m
//  welvu
//
//  Created by Logesh Kumaraguru on 12/12/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_video.h"
#import "welvuContants.h"

@implementation welvu_video
@synthesize welvu_video_id, user_id, generic_file_name, video_file_name,
audio_file_name, av_file_name, welvu_video_type, recording_status, created_date, videoLocation;

static sqlite3 *database = nil;
/*
 * Method name: initWithId
 * Description: Intializing with primary id
 * Parameters: userId
 * Return Type: self
 */

- (id)initWithId:(NSInteger) pkId {
    self=[super init];
    if (self) {
        welvu_video_id = pkId;
    }
    return self;
}
/*
 * Method name: insertVideoQueue
 * Description:insert the video queue
 * Parameters: NSString, welvu_video
 * Return Type: NSInteger
 */
+ (NSInteger) insertVideoQueue:(NSString *)dbPath :(welvu_video *) welvuVideoModel {
    NSInteger rowId = 0;
    char *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        
        sql = [NSString stringWithFormat:
               @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", %d, %d, \"%@\", %d)",
               TABLE_WELVU_VIDEO, COLUMN_GENERIC_FILE_NAME, COLUMN_VIDEO_FILE_NAME, COLUMNE_AUDIO_FILE_NAME,
               COLUMN_AV_FILE_NAME, COLUMN_WELVU_VIDEO_TYPE, COLUMN_RECORDING_STATUS, COLUMN_CREATED_DATE, COLUMN_USER_ID,
               welvuVideoModel.generic_file_name, welvuVideoModel.video_file_name,
               welvuVideoModel.audio_file_name,welvuVideoModel.av_file_name, welvuVideoModel.welvu_video_type,
               welvuVideoModel.recording_status, [dateFormatter stringFromDate:welvuVideoModel.created_date],
               welvuVideoModel.user_id];
        
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
 * Method name: updateVideoQueueStatus
 * Description: update video queue status
 * Parameters: NSString, NSInteger
 * Return Type: int
 */
+ (int)updateVideoQueueStatus:(NSString *)dbPath videoVUId:(NSInteger)videoQueueId status:(NSInteger) status {
    int update = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=%d where %@=%d",
                         TABLE_WELVU_VIDEO,
                         COLUMN_RECORDING_STATUS, status,
                         COLUMN_WELVU_VIDEO_ID, videoQueueId];
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
 * Method name: getVideoQueueById
 * Description: To get the Video Queue
 * Parameters: dbPath, videoQueueId
 * Return Type: welvu_video
 */

+ (welvu_video *) getVideoQueueById:(NSString *)dbPath queueId:(NSInteger) videoQueueId {
    welvu_video *welvuVideoModel = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=%d",
                         TABLE_WELVU_VIDEO, COLUMN_WELVU_VIDEO_ID, videoQueueId];
        
		sqlite3_stmt *selectstmt;
		if(sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
			if(sqlite3_step(selectstmt) == SQLITE_ROW) {
                welvuVideoModel = [[welvu_video alloc] initWithId:sqlite3_column_int(selectstmt, 0)];
                welvuVideoModel = [welvu_video initWithStmt:selectstmt :welvuVideoModel];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return  welvuVideoModel;
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
                         COLUMN_WELVU_VIDEO_ID, TABLE_WELVU_VIDEO];
        
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
 * Method name: initWithStmt
 * Description: statments for alerts
 * Parameters: sqlite3_stmt ,welvuVideoModel
 * Return Type: welvu_video
 */


+ (welvu_video *) initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_video *)welvuVideoModel {
    if(sqlite3_column_text(selectstmt, 1) != nil) {
        welvuVideoModel.generic_file_name = [NSString stringWithUTF8String
                                             :(char *)sqlite3_column_text(selectstmt, 1)];
    }
    if (sqlite3_column_text(selectstmt, 2) != nil) {
        welvuVideoModel.video_file_name = [NSString stringWithUTF8String
                                           :(char *)sqlite3_column_text(selectstmt, 2)];
    }
    if (sqlite3_column_text(selectstmt, 3) != nil) {
        welvuVideoModel.audio_file_name = [NSString stringWithUTF8String
                                           :(char *)sqlite3_column_text(selectstmt, 3)];
    }
    if (sqlite3_column_text(selectstmt, 4) != nil) {
        welvuVideoModel.av_file_name = [NSString stringWithUTF8String
                                        :(char *)sqlite3_column_text(selectstmt, 4)];
    }
    welvuVideoModel.welvu_video_type = sqlite3_column_int(selectstmt, 5);
    welvuVideoModel.recording_status = sqlite3_column_int(selectstmt, 6);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
    if ((char *)sqlite3_column_text(selectstmt,7) != nil) {
        welvuVideoModel.created_date =  [dateFormatter dateFromString:
                                         [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 7)]];
    } else {
        welvuVideoModel.created_date = nil;
    }
    switch (welvuVideoModel.welvu_video_type) {
        case WELVU_AUDIO_VIDEO_VU: {
            welvuVideoModel.videoLocation = [NSString  stringWithFormat:@"%@/%@",
                                             CACHE_DIRECTORY, welvuVideoModel.av_file_name];
        }
            break;
        case WELVU_VIDEO_VU: {
            welvuVideoModel.videoLocation = [NSString  stringWithFormat:@"%@/%@",
                                             CACHE_DIRECTORY, welvuVideoModel.video_file_name];
        }
            break;
        case WELVU_AUDIO_VU: {
            welvuVideoModel.videoLocation = [NSString  stringWithFormat:@"%@/%@",
                                             CACHE_DIRECTORY, welvuVideoModel.audio_file_name];
        }
            break;
        default:
            break;
    }
    welvuVideoModel.user_id = sqlite3_column_int(selectstmt, 8);
    dateFormatter = nil;
    return welvuVideoModel;
}

@end
