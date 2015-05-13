//
//  welvu_topics.m
//  welvu
//
//  Created by Logesh Kumaraguru on 05/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_topics.h"
#import "welvuContants.h"
@implementation welvu_topics

static sqlite3 *database = nil;

@synthesize topicId, welvu_user_id, specialty_id, topicInfo, topicName, topic_is_user_created, topic_active, topic_hit_counter;
@synthesize total_selected_image_count, topic_default_order;
@synthesize is_synced, version, created_on, last_updated, is_locked, topics_guid;


/*
 * Method name: initWithTopicId
 * Description: Intialize the welvu_topics model with topicId
 * Parameters: NSInteger
 * Return Type: self
 */
- (id)initWithTopicId:(NSInteger) tId{
    self = [super init];
    if (self) {
        topicId = tId;
    }
    return self;
}

/*
 * Method name: setTopicIdValue
 * Description: To set Id for private topicId variable
 * Parameters: NSInteger
 * Return Type: self
 */
- (id)setTopicIdValue:(NSInteger)tId {
    topicId = tId;
    return self;
}

/*
 * Method name: setTopicIdValue
 * Description: To set Id for private topicId variable
 * Parameters: NSInteger
 * Return Type: self
 */
+ (welvu_topics *)setTopicId:(welvu_topics *)welvu_topicModel:(NSInteger)topicId {
    welvu_topicModel = [welvu_topicModel setTopicIdValue:topicId];
    return  welvu_topicModel;
}

+ (NSInteger)getMaxInsertRowIdForUserTopics:(NSString *)dbPath userId:(NSInteger) user_id{
    
    NSInteger topicId = (LOCAL_TOPIC_CONTENT_ID_START_RANGE + 1);
    NSInteger max_number = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select max(%@) from %@ where %@=%d and %@=\"%@\"",
                         COLUMN_TOPIC_ID, TABLE_WELVU_TOPICS, COLUMN_USER_ID, user_id,
                         COLUMN_TOPIC_IS_USER_CREATED, COLUMN_CONSTANT_TRUE];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                max_number = sqlite3_column_int(selectstmt, 0);
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    if(max_number > 0) {
        topicId = (max_number + 1);
    }
    return topicId;
}
/*
 * Method name: addNewTopic
 * Description: Insert a user created new topic to welvu_topic
 * Parameters: NSString, welvu_topics, NSInteger
 * Return Type: NSInteger
 */
+ (NSInteger)addNewTopic:(NSString *)dbPath:(welvu_topics *)welvu_topicsModel:(NSInteger)specialty_id {
    NSInteger maxtopicId = [self getMaxInsertRowIdForUserTopics:dbPath userId:welvu_topicsModel.welvu_user_id];
    NSInteger topicId = 0;
    char *error = nil;
    NSInteger topic_max_orderNumber =  ([self getMaxTopicDefaultOrderNumber:dbPath
                                                                     userId:welvu_topicsModel.welvu_user_id] + 1);
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = nil;
        NSString *is_locked ;
        if (welvu_topicsModel.is_locked) {
            is_locked = COLUMN_CONSTANT_TRUE;
        } else {
            is_locked = COLUMN_CONSTANT_FALSE;
        }
        
        NSString *isUserCreated = nil;
        if (welvu_topicsModel.topic_is_user_created) {
            isUserCreated = COLUMN_CONSTANT_TRUE;
        } else {
            isUserCreated = COLUMN_CONSTANT_FALSE;
        }
        
        sql = [NSString stringWithFormat:
               @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (%d, %d, \"%@\", \"%@\", \"%@\", %d, \"%@\", %d, \"%@\", %d)",
               TABLE_WELVU_TOPICS, COLUMN_TOPIC_ID, COLUMN_TOPIC_SPECIALTY_ID, COLUMN_TOPIC_NAME, COLUMN_TOPIC_IS_USER_CREATED, COLUMN_TOPIC_ACTIVE,COLUMN_TOPIC_HIT_COUNT, COLUMN_IS_LOCKED, COLUMN_USER_ID, COLUMN_TOPIC_GUID, COLUMN_TOPIC_DEFAULTORDER, maxtopicId, specialty_id, welvu_topicsModel.topicName,
               isUserCreated, COLUMN_CONSTANT_TRUE, -1, is_locked, welvu_topicsModel.welvu_user_id,
               welvu_topicsModel.topics_guid, topic_max_orderNumber];
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            topicId = maxtopicId;
        };
        sqlite3_close(database);
        database = nil;
    }
    return topicId;
}
/*
 * Method name: addTopicFromPlatform
 * Description: Insert topics from platform
 * Parameters: dbPath, welvu_topicsModel
 * Return Type: BOOL
 */
+ (BOOL)addTopicFromPlatform:(NSString *)dbPath:(welvu_topics *)welvu_topicsModel {
    BOOL inserted = false;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *isTopicUserCreated;
        if (welvu_topicsModel.topic_is_user_created) {
            isTopicUserCreated = COLUMN_CONSTANT_TRUE;
        } else {
            isTopicUserCreated = COLUMN_CONSTANT_FALSE;
        }
        
        NSString *isTopicActive ;
        if (welvu_topicsModel.topic_active) {
            isTopicActive = COLUMN_CONSTANT_TRUE;
        } else {
            isTopicActive = COLUMN_CONSTANT_FALSE;
        }
        
        NSString *is_locked ;
        if (welvu_topicsModel.is_locked) {
            is_locked = COLUMN_CONSTANT_TRUE;
        } else {
            is_locked = COLUMN_CONSTANT_FALSE;
        }
        
        
        NSString *sql =[NSString stringWithFormat:
                        @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (%d, %d, \"%@\", \"%@\", \"%@\", %d,\"%@\", %d, \"%@\", %d);",
                        TABLE_WELVU_TOPICS, COLUMN_TOPIC_ID, COLUMN_TOPIC_SPECIALTY_ID, COLUMN_TOPIC_NAME,COLUMN_TOPIC_IS_USER_CREATED, COLUMN_TOPIC_ACTIVE,COLUMN_TOPIC_DEFAULTORDER,
                        COLUMN_TOPIC_INFO, COLUMN_TOPIC_HIT_COUNT, COLUMN_IS_LOCKED, COLUMN_USER_ID,
                        welvu_topicsModel.topicId, welvu_topicsModel.specialty_id,
                        welvu_topicsModel.topicName, isTopicUserCreated,
                        isTopicActive, welvu_topicsModel.topic_default_order,
                        welvu_topicsModel.topicInfo, welvu_topicsModel.topic_hit_counter, is_locked, welvu_topicsModel.welvu_user_id];
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
 * Method name: updateLock
 * Description: update lock for topics
 * Parameters: dbPath, specialtyId,is_locked
 * Return Type: BOOL
 */
+ (BOOL)updateLock:(NSString *)dbPath specialty:(NSInteger)specialtyId setLock:(BOOL)is_locked userId: (NSInteger) user_id {
    BOOL inserted = false;
    char *error = nil;
    NSString *islocked ;
    if (is_locked) {
        islocked = COLUMN_CONSTANT_TRUE;
    } else {
        islocked = COLUMN_CONSTANT_FALSE;
    }
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\" where  %@=\"%@\" and %@=%d and %@ > %d and %@=%d",
                         TABLE_WELVU_TOPICS,
                         COLUMN_IS_LOCKED, islocked,
                         COLUMN_TOPIC_IS_USER_CREATED, COLUMN_CONSTANT_FALSE,
                         COLUMN_SPECIALTY_ID, specialtyId,
                         COLUMN_TOPIC_DEFAULTORDER, 3,
                         COLUMN_USER_ID, user_id];
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
 * Method name: getAllTopics
 * Description: Get all the topics from the db
 * Parameters: NSString, NSInteger
 * Return Type: NSMutableArray
 */
+ (NSMutableArray *)getAllTopics:(NSString *)dbPath:(NSInteger)specialty_id userId:(NSInteger) userId{
    NSMutableArray *topicsModels = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=\"%@\" and %@=%d and %@=%d",
                         TABLE_WELVU_TOPICS, COLUMN_TOPIC_ACTIVE, COLUMN_CONSTANT_TRUE,
                         COLUMN_TOPIC_SPECIALTY_ID, specialty_id,
                         COLUMN_USER_ID, userId];
        
         // NSLog(@"sql %@",sql);
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if (topicsModels == nil) {
                    topicsModels = [[NSMutableArray alloc] init];
                }
				welvu_topics *welvu_topicsModel = [[welvu_topics alloc] initWithTopicId:sqlite3_column_int(selectstmt, 0)];
                welvu_topicsModel = [self initWithStmt:selectstmt:welvu_topicsModel];
                [topicsModels addObject:welvu_topicsModel];
            }
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return topicsModels;
}

/*
 * Method name: getAllTopicsByAlphabeticalOrder
 * Description: Get all the topics in alphabetical order
 * Parameters: NSString, NSInteger
 * Return Type: NSMutableArray
 */
+ (NSMutableArray *)getAllTopicsByAlphabeticalOrder:(NSString *)dbPath:(NSInteger)specialty_id userId:(NSInteger) userId{
    NSMutableArray *topicsModels = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
    
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=\"%@\" and %@=%d and %@=%d order by %@ COLLATE NOCASE asc",
                         TABLE_WELVU_TOPICS, COLUMN_TOPIC_ACTIVE, COLUMN_CONSTANT_TRUE,
                         COLUMN_TOPIC_SPECIALTY_ID, specialty_id,
                         COLUMN_USER_ID, userId, COLUMN_TOPIC_NAME];
        //NSLog(@"sql %@",sql);
		sqlite3_stmt *selectstmt;
		if(sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if (topicsModels == nil) {
                    topicsModels = [[NSMutableArray alloc] init];
                }
				welvu_topics *welvu_topicsModel = [[welvu_topics alloc] initWithTopicId:sqlite3_column_int(selectstmt, 0)];
                welvu_topicsModel = [self initWithStmt:selectstmt:welvu_topicsModel];
                [topicsModels addObject:welvu_topicsModel];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return topicsModels;
}

/*
 * Method name: getAllTopicsByAlphabeticalOrder
 * Description: Get all the topics in alphabetical order
 * Parameters: NSString, NSInteger
 * Return Type: NSMutableArray
 */
+ (NSMutableArray *)getAllTopicsByDefaultOrder:(NSString *)dbPath:(NSInteger)specialty_id userId:(NSInteger) userId{
    NSMutableArray *topicsModels = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=\"%@\" and %@=%d and %@=%d order by %@ asc",
                         TABLE_WELVU_TOPICS, COLUMN_TOPIC_ACTIVE, COLUMN_CONSTANT_TRUE,
                         COLUMN_TOPIC_SPECIALTY_ID, specialty_id,
                         COLUMN_USER_ID, userId, COLUMN_TOPIC_DEFAULTORDER];
         // NSLog(@"sql %@",sql);
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if (topicsModels == nil) {
                    topicsModels = [[NSMutableArray alloc] init];
                }
				welvu_topics *welvu_topicsModel = [[welvu_topics alloc] initWithTopicId:sqlite3_column_int(selectstmt, 0)];
                welvu_topicsModel = [self initWithStmt:selectstmt:welvu_topicsModel];
                [topicsModels addObject:welvu_topicsModel];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return topicsModels;
}

/*
 * Method name: getAllTopicsByMostPopularOrder
 * Description: Get all the topics in most popular order
 * Parameters: NSString, NSInteger
 * Return Type: NSMutableArray
 */
+ (NSMutableArray *)getAllTopicsByMostPopularOrder:(NSString *)dbPath:(NSInteger)specialty_id userId:(NSInteger) userId{
    NSMutableArray *topicsModels = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=\"%@\" and %@=%d and %@=%d order by %@ desc",
                         TABLE_WELVU_TOPICS, COLUMN_TOPIC_ACTIVE, COLUMN_CONSTANT_TRUE,
                         COLUMN_TOPIC_SPECIALTY_ID, specialty_id, COLUMN_USER_ID, userId,
                         COLUMN_TOPIC_HIT_COUNT];
        //  NSLog(@"sql %@",sql);
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if (topicsModels == nil) {
                    topicsModels = [[NSMutableArray alloc] init];
                }
				welvu_topics *welvu_topicsModel = [[welvu_topics alloc] initWithTopicId:sqlite3_column_int(selectstmt, 0)];
                welvu_topicsModel = [self initWithStmt:selectstmt:welvu_topicsModel];
                [topicsModels addObject:welvu_topicsModel];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return topicsModels;
}

/*
 * Method name: getMaxTopicDefaultOrderNumber
 * Description: To get maximum number in the DB from topics
 * Parameters: dbPath,
 * Return Type: NSInteger
 */
+ (NSInteger)getMaxTopicDefaultOrderNumber:(NSString *)dbPath userId:(NSInteger) userId{
    NSInteger max_number = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select max(%@) from %@ where %@=%d",
                         COLUMN_TOPIC_DEFAULTORDER, TABLE_WELVU_TOPICS, COLUMN_USER_ID, userId];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
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
 * Method name: updateTopicHitCounter
 * Description: Update user topic hit count in db
 * Parameters: NSString, NSInteger
 * Return Type: int
 */
+ (int)updateTopicHitCounter:(NSString *)dbPath: (NSInteger)topic_id userId:(NSInteger) userId {
    int update = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=%@+%d where %@=%d and %@=%d",
                         TABLE_WELVU_TOPICS,
                         COLUMN_TOPIC_HIT_COUNT, COLUMN_TOPIC_HIT_COUNT, 1,
                         COLUMN_TOPIC_ID, topic_id,
                         COLUMN_USER_ID, userId];
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
 * Method name: isTopicAlreadyExist
 * Description: Check whether topic with topic name already exist or not
 * Parameters: NSString, NSString
 * Return Type: BOOL
 */
+ (BOOL)isTopicAlreadyExist:(NSString *)dbPath:(NSString *)topicName userId:(NSInteger) userId {
    BOOL isTopicExist = false;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=%d and %@=\"%@\" COLLATE NOCASE", TABLE_WELVU_TOPICS,
                         COLUMN_USER_ID, userId,
                         COLUMN_TOPIC_NAME, topicName];
        
		sqlite3_stmt *selectstmt;
		if(sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                isTopicExist = true;
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return isTopicExist;
}
/*
 * Method name: getTopicById
 * Description: Get the topic from topic id
 * Parameters: dbPath, topic_id
 * Return Type: welvu_topicsModel
 */
+ (welvu_topics *)getTopicById:(NSString *)dbPath:(NSInteger)topic_id userId:(NSInteger) userId {
    welvu_topics *welvu_topicsModel = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=%d and %@=%d",
                         TABLE_WELVU_TOPICS, COLUMN_TOPIC_ID, topic_id, COLUMN_USER_ID, userId];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                welvu_topicsModel = [[welvu_topics alloc] initWithTopicId:sqlite3_column_int(selectstmt, 0)];
                welvu_topicsModel = [self initWithStmt:selectstmt:welvu_topicsModel];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return welvu_topicsModel;
}



/*
 * Method name: getTopicNameById
 * Description: Get topic name using topicId from db
 * Parameters: NSString, NSInteger
 * Return Type: NSString
 */
+ (NSString *)getTopicNameById:(NSString *)dbPath:(NSInteger)topic_id  userId:(NSInteger) userId {
    NSString *topicName = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where %@=%d and %@=%d",
                         COLUMN_TOPIC_NAME, TABLE_WELVU_TOPICS, COLUMN_TOPIC_ID, topic_id,
                         COLUMN_USER_ID, userId];
        
		sqlite3_stmt *selectstmt;
		if(sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                topicName = [NSString stringWithUTF8String
                             :(char *)sqlite3_column_text(selectstmt, 0)];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return topicName;
}

/*
 * Method name: getTopicGuidbyTopicName
 * Description: Get topicGuid by topic name
 * Parameters: dbPath, topic_Name ,userId
 * Return Type: NSString
 */

+ (NSString *)getTopicGuidbyTopicName:(NSString *)dbPath:(NSString *)topic_Name userId:(NSInteger) userId {
    // NSLog(@"topic name %@",topic_Name);
    NSString * topic_guid = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where %@=\"%@\" and %@=%d",
                         COLUMN_TOPIC_GUID, TABLE_WELVU_TOPICS, COLUMN_TOPIC_NAME, topic_Name,
                         COLUMN_USER_ID, userId];
        
        // NSLog(@"sql %@",sql);
        
        // select topics_guid from welvu_topics where topic_name = 'dasdad'
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                
                topic_guid = [NSString stringWithUTF8String
                              :(char *)sqlite3_column_text(selectstmt, 0)];
                
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return topic_guid;
}

/*
 * Method name: archiveTopic
 * Description: Archive selected topic in db
 * Parameters: NSString, NSInteger
 * Return Type: int
 */
+ (int)archiveTopic:(NSString *)dbPath:(NSInteger)topicId  userId:(NSInteger) userId {
    int update = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\" where %@=%d  and %@=%d",
                         TABLE_WELVU_TOPICS,
                         COLUMN_TOPIC_ACTIVE, COLUMN_CONSTANT_FALSE,
                         COLUMN_TOPIC_ID, topicId,
                         COLUMN_USER_ID, userId];
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
 * Method name: deleteTopicWithTopicGUID
 * Description: delete topic by giving topic guid
 * Parameters: dbPath, topicGuid
 * Return Type: BOOL
 */
+ (BOOL)deleteTopicWithTopicGUID:(NSString *)dbPath:(NSString *)topicGuid {
    
    BOOL historyDeleted = FALSE;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@=\"%@\"",
                         TABLE_WELVU_TOPICS,
                         COLUMN_TOPIC_GUID, topicGuid];
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
 * Method name: deleteTopicWithTopicId
 * Description: delete topic by giving topic id
 * Parameters: dbPath, topicGuid
 * Return Type: BOOL
 */
+ (BOOL)deleteTopicWithTopicId:(NSString *)dbPath:(NSInteger)topicId user_id:(NSInteger) userId {
    
    BOOL historyDeleted = FALSE;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@=%d and %@=%d",
                         TABLE_WELVU_TOPICS,
                         COLUMN_TOPIC_ID, topicId, COLUMN_USER_ID, userId];
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

#pragma mark - Fetch detail without userid
/*
 * Method name: getTopicDetailByGUID
 * Description: Get the topic from topic id
 * Parameters: dbPath, topic_id
 * Return Type: welvu_topicsModel
 */
+ (welvu_topics *)getTopicDetailByGUID:(NSString *)dbPath:(NSString *)topic_guid  {
    welvu_topics *welvu_topicsModel = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=\"%@\"",
                         TABLE_WELVU_TOPICS, COLUMN_TOPIC_GUID, topic_guid];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                welvu_topicsModel = [[welvu_topics alloc] initWithTopicId:sqlite3_column_int(selectstmt, 0)];
                welvu_topicsModel = [self initWithStmt:selectstmt:welvu_topicsModel];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return welvu_topicsModel;
}

/*
 * Method name: getTopicIdByGUID
 * Description: Get the topic id by guid
 * Parameters: dbPath, topic_id
 * Return Type: welvu_topicsModel
 */
+ (NSInteger)getTopicIdByGUID:(NSString *)dbPath:(NSString *)topic_guid {
    NSInteger topicId = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where %@=\"%@\"",
                         COLUMN_TOPIC_ID, TABLE_WELVU_TOPICS, COLUMN_TOPIC_GUID, topic_guid];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                topicId = sqlite3_column_int(selectstmt, 0);
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return topicId;
}

/*
 * Method name: initWithStmt
 * Description: Intializing the welvu_topics model object with db values
 * Parameters: sqlite3_stmt, welvu_topics
 * Return Type: welvu_topics
 */
+ (welvu_topics *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_topics *)welvu_topicsModel {
    welvu_topicsModel.welvu_user_id = sqlite3_column_int(selectstmt, 1);
    welvu_topicsModel.specialty_id = sqlite3_column_int(selectstmt, 2);
    
    if(sqlite3_column_text(selectstmt, 3) != nil) {
        welvu_topicsModel.topicName = [NSString stringWithUTF8String
                                       :(char *)sqlite3_column_text(selectstmt, 3)];
    }
    if(sqlite3_column_text(selectstmt, 4) != nil) {
        welvu_topicsModel.topicInfo = [NSString stringWithUTF8String
                                       :(char *)sqlite3_column_text(selectstmt, 4)];
    }
    if(sqlite3_column_text(selectstmt, 5) != nil &&
       [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 5)] isEqualToString:@"True"]) {
        welvu_topicsModel.topic_is_user_created = TRUE;
    } else {
        welvu_topicsModel.topic_is_user_created = FALSE;
    }
    
    if(sqlite3_column_text(selectstmt, 6) != nil &&
       [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 6)] isEqualToString:@"True"]) {
        welvu_topicsModel.topic_active = TRUE;
    } else {
        welvu_topicsModel.topic_active = FALSE;
    }
    
    welvu_topicsModel.topic_hit_counter = sqlite3_column_int(selectstmt, 7);
    
    if(sqlite3_column_text(selectstmt, 13) != nil &&
       [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 13)] isEqualToString:@"True"]) {
        welvu_topicsModel.is_locked = TRUE;
    } else {
        welvu_topicsModel.is_locked = FALSE;
    }
    
    if(sqlite3_column_text(selectstmt, 14) != nil) {
        welvu_topicsModel.topics_guid = [NSString stringWithUTF8String
                                         :(char *)sqlite3_column_text(selectstmt, 14)];
    } else {
        welvu_topicsModel.topics_guid = nil;
    }
    
    return welvu_topicsModel;
}

#pragma mark - NeedToCheck not updated for WelvuPlatformId

/*
 * Method name: getTopicIdWithName
 * Description: Get the topic id with the topic name from db
 * Parameters: NSString, NSString
 * Return Type: NSInteger
 */
+ (NSInteger)getTopicIdWithName:(NSString *)dbPath:(NSString *)topicName {
    NSInteger topicId = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=\"%@\" COLLATE NOCASE",TABLE_WELVU_TOPICS, COLUMN_TOPIC_NAME, topicName];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                topicId = sqlite3_column_int(selectstmt, 0);
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return topicId;
}

/*
 * Method name: unarchiveTopic
 * Description: Unarchive selected topic in db
 * Parameters: NSString, NSInteger
 * Return Type: int
 */
+ (int)unarchiveTopic:(NSString *)dbPath:(NSInteger)topicId {
    int update = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\" where %@=%d",
                         TABLE_WELVU_TOPICS,
                         COLUMN_TOPIC_ACTIVE, COLUMN_CONSTANT_TRUE,
                         COLUMN_TOPIC_ID, topicId];
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
 * Method name: getArchivedTopics
 * Description: Get archived topics from the db
 * Parameters: NSString, NSInteger
 * Return Type: NSMutableArray
 */
+ (NSMutableArray *)getArchivedTopics:(NSString *)dbPath:(NSInteger)specialty_id {
    NSMutableArray *topicsModels = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=\"%@\" and %@=%d",
                         TABLE_WELVU_TOPICS, COLUMN_TOPIC_ACTIVE, COLUMN_CONSTANT_FALSE,
                         COLUMN_TOPIC_SPECIALTY_ID, specialty_id];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if (topicsModels == nil) {
                    topicsModels = [[NSMutableArray alloc] init];
                }
				welvu_topics *welvu_topicsModel = [[welvu_topics alloc] initWithTopicId:sqlite3_column_int(selectstmt, 0)];
                welvu_topicsModel = [self initWithStmt:selectstmt:welvu_topicsModel];
                [topicsModels addObject:welvu_topicsModel];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return topicsModels;
}

/*
 * Method name: getArchivedTopicsCount
 * Description: Get archived topic count from db
 * Parameters: NSString, NSInteger
 * Return Type: NSInteger
 */
+ (NSInteger)getArchivedTopicsCount:(NSString *)dbPath:(NSInteger)specialty_id {
    NSInteger countArchivedContents = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select count(*) from %@ where %@=\"%@\" and %@=%d",
                         TABLE_WELVU_TOPICS, COLUMN_TOPIC_ACTIVE, COLUMN_CONSTANT_FALSE,
                         COLUMN_TOPIC_SPECIALTY_ID, specialty_id];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                countArchivedContents = sqlite3_column_int(selectstmt, 0);
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return countArchivedContents;
}

/*
 * Method name: addAllTopics
 * Description: Add all topics
 * Parameters: dbPath, welvu_topicsArray
 * Return Type: BOOL
 */
//Not Used //DoNotUse
+ (BOOL)addAllTopics:(NSString *)dbPath:(NSMutableArray *)welvu_topicsArray {
    BOOL inserted = false;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =@"";
        for (welvu_topics *welvu_topicsModel in welvu_topicsArray) {
            NSString *isTopicUserCreated;
            if (welvu_topicsModel.topic_is_user_created) {
                isTopicUserCreated = COLUMN_CONSTANT_TRUE;
            } else {
                isTopicUserCreated = COLUMN_CONSTANT_FALSE;
            }
            
            NSString *isTopicActive ;
            if (welvu_topicsModel.topic_active) {
                isTopicActive = COLUMN_CONSTANT_TRUE;
            } else {
                isTopicActive = COLUMN_CONSTANT_FALSE;
            }
            sql = [sql stringByAppendingString:[NSString stringWithFormat:
                                                @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@) VALUES (%d, %d, \"%@\", \"%@\", \"%@\", %d,\"%@\", %d );",
                                                TABLE_WELVU_TOPICS, COLUMN_TOPIC_ID,COLUMN_TOPIC_SPECIALTY_ID, COLUMN_TOPIC_NAME,COLUMN_TOPIC_IS_USER_CREATED, COLUMN_TOPIC_ACTIVE,COLUMN_TOPIC_DEFAULTORDER,
                                                COLUMN_TOPIC_INFO, COLUMN_TOPIC_HIT_COUNT,
                                                welvu_topicsModel.topicId, welvu_topicsModel.specialty_id,
                                                welvu_topicsModel.topicName, isTopicUserCreated,
                                                isTopicActive, welvu_topicsModel.topic_default_order,
                                                welvu_topicsModel.topicInfo, welvu_topicsModel.topic_hit_counter]];
        }
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

@end
