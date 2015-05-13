//
//  welvu_video.h
//  welvu
//
//  Created by Logesh Kumaraguru on 12/12/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

/*
 * Class name: welvu_video
 * Description: Data model for syncing
 * Extends: NSObject
 * Delegate: nil
 */

@interface welvu_video : NSObject {
    NSInteger welvu_video_id;
    NSInteger user_id;
    NSString *generic_file_name;
    NSString *video_file_name;
    NSString *audio_file_name;
    NSString *av_file_name;
    NSInteger welvu_video_type;
    NSInteger recording_status;
    NSDate *created_date;
    NSString *videoLocation;
}

//Property of the objects
@property (nonatomic, readonly) NSInteger welvu_video_id;
@property (nonatomic, readwrite) NSInteger user_id;
@property (nonatomic, copy) NSString *generic_file_name;
@property (nonatomic, copy) NSString *video_file_name;
@property (nonatomic, copy) NSString *audio_file_name;
@property (nonatomic, copy) NSString *av_file_name;
@property (nonatomic, readwrite) NSInteger welvu_video_type;
@property (nonatomic, readwrite) NSInteger recording_status;
@property (nonatomic, retain) NSDate *created_date;
@property (nonatomic, copy) NSString *videoLocation;

//Methods
+ (NSInteger) insertVideoQueue:(NSString *)dbPath :(welvu_video *) welvuVideoModel;
+ (int) updateVideoQueueStatus:(NSString *)dbPath videoVUId:(NSInteger)videoQueueId status:(NSInteger) status;
+ (welvu_video *) getVideoQueueById:(NSString *)dbPath queueId:(NSInteger) videoQueueId;
+ (NSInteger)getLastInsertRowId:(NSString *)dbPath;

- (id)initWithId:(NSInteger) pkId;
+ (welvu_video *) initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_video *)welvuVideoModel;
@end
