//
//  welvu_topics.h
//  welvu
//
//  Created by Logesh Kumaraguru on 05/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

/*
 * Class name: welvu_topics
 * Description: Data model for topics of the specialty list
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_topics : NSObject {
    NSInteger topicId;
    NSInteger welvu_user_id;
    NSInteger specialty_id;
    NSString *topicName;
    NSString *topicInfo;
    BOOL topic_is_user_created;
    BOOL topic_active;
    NSInteger topic_hit_counter;
    NSInteger topic_default_order;
    BOOL is_synced;
    float version;
    NSDate *created_on;
    NSDate *last_updated;
    BOOL is_locked;
    NSString *topics_guid;
    //Local purpose
    NSInteger total_selected_image_count;
}

//Property
@property (nonatomic, readonly) NSInteger topicId;
@property (nonatomic, readwrite) NSInteger welvu_user_id;
@property (nonatomic, readwrite) NSInteger specialty_id;
@property (nonatomic, copy) NSString *topicName;
@property (nonatomic, copy) NSString *topicInfo;
@property (nonatomic, readwrite) BOOL topic_is_user_created;
@property (nonatomic, readwrite) BOOL topic_active;
@property (nonatomic, readwrite) NSInteger topic_hit_counter;
@property (nonatomic, readwrite) NSInteger topic_default_order;
@property (nonatomic, readwrite) BOOL is_synced;
@property (nonatomic, readwrite) float version;
@property (nonatomic, retain) NSDate *created_on;
@property (nonatomic, retain) NSDate *last_updated;
@property (nonatomic, readwrite) BOOL is_locked;
@property (nonatomic, readwrite) NSString *topics_guid;
//Local purpose
@property (nonatomic, readwrite) NSInteger total_selected_image_count;

//Method
+ (BOOL)addAllTopics:(NSString *)dbPath:(NSMutableArray *)welvu_topicsArray;
+ (NSInteger)getMaxInsertRowIdForUserTopics:(NSString *)dbPath userId:(NSInteger) user_id;
+ (NSInteger)addNewTopic:(NSString *)dbPath:(welvu_topics *)welvu_topicsModel:(NSInteger)specialty_id;
+ (BOOL)addTopicFromPlatform:(NSString *)dbPath:(welvu_topics *)welvu_topicsModel;
+ (BOOL)updateLock:(NSString *)dbPath specialty:(NSInteger)specialtyId setLock:(BOOL)is_locked  userId: (NSInteger) user_id;
+ (NSMutableArray *)getAllTopics:(NSString *)dbPath:(NSInteger)specialty_id userId:(NSInteger) userId;
+ (NSMutableArray *)getAllTopicsByDefaultOrder:(NSString *)dbPath:(NSInteger)specialty_id userId:(NSInteger) userId;
+ (NSMutableArray *)getAllTopicsByAlphabeticalOrder:(NSString *)dbPath:(NSInteger)specialty_id userId:(NSInteger) userId;
+ (NSMutableArray *)getAllTopicsByMostPopularOrder:(NSString *)dbPath:(NSInteger)specialty_id userId:(NSInteger) userId;
+ (NSInteger)getMaxTopicDefaultOrderNumber:(NSString *)dbPath userId:(NSInteger) userId;
+ (int)updateTopicHitCounter:(NSString *)dbPath: (NSInteger)topic_id  userId:(NSInteger) userId;
+ (BOOL)isTopicAlreadyExist:(NSString *)dbPath:(NSString *)topicName userId:(NSInteger) userId;
+ (welvu_topics *)getTopicById:(NSString *)dbPath:(NSInteger)topic_id userId:(NSInteger) userId;
+ (NSString *)getTopicNameById:(NSString *)dbPath:(NSInteger)topic_id userId:(NSInteger) userId;
+ (NSString *)getTopicGuidbyTopicName:(NSString *)dbPath:(NSString *)topic_Name userId:(NSInteger) userId;
+ (int)archiveTopic:(NSString *)dbPath:(NSInteger)topicId  userId:(NSInteger) userId;
+ (welvu_topics *)getTopicDetailByGUID:(NSString *)dbPath:(NSString *)topic_guid;
+ (NSInteger)getTopicIdByGUID:(NSString *)dbPath:(NSString *)topic_guid;
//NeedToCheck not updated for WelvuPlatformId
+ (NSInteger)getTopicIdWithName:(NSString *)dbPath:(NSString *)topicName;
+ (NSMutableArray *)getArchivedTopics:(NSString *)dbPath:(NSInteger)specialty_id;
+ (NSInteger)getArchivedTopicsCount:(NSString *)dbPath:(NSInteger)specialty_id;
+ (int)unarchiveTopic:(NSString *)dbPath:(NSInteger)topicId;
+ (welvu_topics *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_topics *)welvu_topicsModel;
+ (welvu_topics *)setTopicId:(welvu_topics *)welvu_topicModel:(NSInteger)topicId;
- (id)initWithTopicId:(NSInteger)tId;
- (id)setTopicIdValue:(NSInteger)tId;
//user created topics delete
//santhosh 25 sep
+ (BOOL)deleteTopicWithTopicGUID:(NSString *)dbPath:(NSString *)topicGuid;
+ (BOOL)deleteTopicWithTopicId:(NSString *)dbPath:(NSInteger)topicId user_id:(NSInteger) userId;
+ (NSMutableArray *)getAllTopicsByAlphabeticalOrderWithOutOrg:(NSString *)dbPath:(NSInteger)specialty_id userId:(NSInteger) userId;
@end
