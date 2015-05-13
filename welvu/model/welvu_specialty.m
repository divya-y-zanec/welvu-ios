//
//  welvu_specialty.m
//  welvu
//
//  Created by Logesh Kumaraguru on 01/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_specialty.h"
#import "welvuContants.h"

@implementation welvu_specialty
@synthesize welvu_specialty_id, welvu_user_id, welvu_specialty_name, welvu_specialty_info, welvu_specialty_default,
welvu_specialty_subscribed, welvu_topic_synced, welvu_platform_id;
@synthesize product_identifier, version, created_on, last_updated, yearly_product_identifier, subscriptionStartDate,
subscriptionEndDate;

static sqlite3 *database = nil;

/*
 * Method name: initWithSpecialtyId
 * Description: Intialize the welvu_specialty model with welvu_specialty_id
 * Parameters: NSInteger
 * Return Type: id
 */
- (id)initWithSpecialtyId:(NSInteger)sId {
    self = [super init];
    if(self) {
        welvu_specialty_id = sId;
    }
    return self;
}

/*
 * Method name: getSpecialtyCount
 * Description: To Get the number of specialty
 * Parameters: NSString
 * Return Type: id
 */

+ (NSInteger)getSpecialtyCount:(NSString *)dbPath userId:(NSInteger) user_id{
    NSInteger counteImage = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select count() from %@ where %@=%d", TABLE_WELVU_SPECIALTY,
                         COLUMN_USER_ID, user_id];
		sqlite3_stmt *selectstmt;
		if(sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                counteImage = sqlite3_column_int(selectstmt, 0);
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return counteImage;
}
/*
 * Method name: getAllSpecialty
 * Description: To get all the specialties
 * Parameters: NSString
 * Return Type: NSMutableArray
 */
+ (NSMutableArray *)getAllSpecialty:(NSString *) dbPath userId:(NSInteger) user_id {
    NSMutableArray *specialtyModels = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=%d",
                         TABLE_WELVU_SPECIALTY, COLUMN_USER_ID, user_id];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if (specialtyModels == nil) {
                    specialtyModels = [[NSMutableArray alloc] init];
                }
				welvu_specialty *welvu_specialtyModel = [[welvu_specialty alloc] initWithSpecialtyId:sqlite3_column_int(selectstmt, 0)];
                welvu_specialtyModel = [self initWithStmt:selectstmt:welvu_specialtyModel];
                [specialtyModels addObject:welvu_specialtyModel];
                //[welvu_specialtyModel release];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return specialtyModels;
}

/*
 * Method name: getAllSpecialtyWithoutUserId
 * Description: To get all the specialties
 * Parameters: NSString
 * Return Type: NSMutableArray
 */
+ (NSMutableArray *)getAllSpecialtyWithoutUserId:(NSString *) dbPath {
    NSMutableArray *specialtyModels = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@",
                         TABLE_WELVU_SPECIALTY];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if (specialtyModels == nil) {
                    specialtyModels = [[NSMutableArray alloc] init];
                }
				welvu_specialty *welvu_specialtyModel = [[welvu_specialty alloc] initWithSpecialtyId:sqlite3_column_int(selectstmt, 0)];
                welvu_specialtyModel = [self initWithStmtOldVersion:selectstmt:welvu_specialtyModel];
                [specialtyModels addObject:welvu_specialtyModel];
                //[welvu_specialtyModel release];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return specialtyModels;
}

/*
 * Method name: addAllSpecialty
 * Description: To add all the specialties
 * Parameters: dbPath,welvu_specialtyArray
 * Return Type: Bool
 */
+ (BOOL)addAllSpecialty:(NSString *)dbPath:(NSMutableArray *)welvu_specialtyArray {
    BOOL specialtyAdded = false;
    char *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =@"";
        for(welvu_specialty *welvu_specialtyModel in welvu_specialtyArray) {
            NSString *isSpecialtyDefault;
            if (welvu_specialtyModel.welvu_specialty_default) {
                isSpecialtyDefault = COLUMN_CONSTANT_TRUE;
            } else {
                isSpecialtyDefault = COLUMN_CONSTANT_FALSE;
            }
            NSString *validFrom;
            NSString *validTill;
            NSString *isSpecialtySubscribed ;
            if(welvu_specialtyModel.welvu_specialty_subscribed) {
                isSpecialtySubscribed = COLUMN_CONSTANT_TRUE;
                validFrom = [dateFormatter stringFromDate:welvu_specialtyModel.subscriptionStartDate];
                validTill = [dateFormatter stringFromDate:welvu_specialtyModel.subscriptionEndDate];
            } else {
                isSpecialtySubscribed = COLUMN_CONSTANT_FALSE;
            }
            if (welvu_specialtyModel.welvu_specialty_subscribed) {
                sql = [sql stringByAppendingString:[NSString stringWithFormat:
                                                    @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@,%@) VALUES (%d,\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", %d, \"%@\", \"%@\");",
                                                    TABLE_WELVU_SPECIALTY, COLUMN_PLATFORM_SPECIALTY_ID, COLUMN_SPECIALTY_NAME, COLUMN_SPECIALTY_DEFAULT,
                                                    COLUMN_SPECIALTY_SUBSCRIBED, COLUMN_TOPICS_SYNCED, COLUMN_PRODUCT_IDENTIFIER,
                                                    COLUMN_YEARLY_PRODUCT_IDENTIFIER,
                                                    COLUMN_USER_ID, COLUMN_SUBSCRIPTION_START_DATE,COLUMN_SUBSCRIPTION_END_DATE,
                                                    welvu_specialtyModel.welvu_platform_id, welvu_specialtyModel.welvu_specialty_name,
                                                    isSpecialtyDefault, isSpecialtySubscribed, COLUMN_CONSTANT_FALSE,
                                                    welvu_specialtyModel.product_identifier, welvu_specialtyModel.yearly_product_identifier,welvu_specialtyModel.welvu_user_id, validFrom, validTill]];
            } else {
                sql = [sql stringByAppendingString:[NSString stringWithFormat:
                                                    @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@) VALUES (%d,\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", %d);",
                                                    TABLE_WELVU_SPECIALTY, COLUMN_PLATFORM_SPECIALTY_ID, COLUMN_SPECIALTY_NAME, COLUMN_SPECIALTY_DEFAULT,
                                                    COLUMN_SPECIALTY_SUBSCRIBED, COLUMN_TOPICS_SYNCED, COLUMN_PRODUCT_IDENTIFIER,COLUMN_YEARLY_PRODUCT_IDENTIFIER, COLUMN_USER_ID,                                          welvu_specialtyModel.welvu_platform_id, welvu_specialtyModel.welvu_specialty_name,
                                                    isSpecialtyDefault, isSpecialtySubscribed, COLUMN_CONSTANT_FALSE,
                                                    welvu_specialtyModel.product_identifier, welvu_specialtyModel.yearly_product_identifier, welvu_specialtyModel.welvu_user_id]];
            }
        }
        
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            specialtyAdded = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return specialtyAdded;
}
/*
 * Method name: updateAllSpecialty
 * Description: To update all the specialties
 * Parameters: dbPath,welvu_specialtyArray
 * Return Type: Bool
 */
+(BOOL) updateAllSpecialty:(NSString *)dbPath specialtyModel:(welvu_specialty *)welvu_specialtyModel
           specialtyUpdate:(BOOL) updateOnly {
    BOOL specialtyAdded = false;
    char *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =@"";
        NSString *isSpecialtyDefault;
        if(welvu_specialtyModel.welvu_specialty_default) {
            isSpecialtyDefault = COLUMN_CONSTANT_TRUE;
        } else {
            isSpecialtyDefault = COLUMN_CONSTANT_FALSE;
        }
        NSString *validFrom;
        NSString *validTill;
        NSString *isSpecialtySubscribed ;
        if(welvu_specialtyModel.welvu_specialty_subscribed) {
            isSpecialtySubscribed = COLUMN_CONSTANT_TRUE;
            validFrom = [dateFormatter stringFromDate:welvu_specialtyModel.subscriptionStartDate];
            validTill = [dateFormatter stringFromDate:welvu_specialtyModel.subscriptionEndDate];
        } else {
            isSpecialtySubscribed = COLUMN_CONSTANT_FALSE;
            validFrom = [dateFormatter stringFromDate:welvu_specialtyModel.subscriptionStartDate];
            validTill = [dateFormatter stringFromDate:welvu_specialtyModel.subscriptionEndDate];
        }
        NSString *isTopicSynced;
        if(welvu_specialtyModel.welvu_topic_synced) {
            isTopicSynced = COLUMN_CONSTANT_TRUE;
        } else {
            isTopicSynced = COLUMN_CONSTANT_FALSE;
        }
        
        if(!updateOnly) {
            if(welvu_specialtyModel.welvu_specialty_subscribed) {
                sql = [NSString stringWithFormat:
                       @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@,%@) VALUES (%d,\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", %d, \"%@\", \"%@\");",
                       TABLE_WELVU_SPECIALTY, COLUMN_PLATFORM_SPECIALTY_ID, COLUMN_SPECIALTY_NAME, COLUMN_SPECIALTY_DEFAULT,
                       COLUMN_SPECIALTY_SUBSCRIBED, COLUMN_TOPICS_SYNCED, COLUMN_PRODUCT_IDENTIFIER,
                       COLUMN_YEARLY_PRODUCT_IDENTIFIER,
                       COLUMN_USER_ID, COLUMN_SUBSCRIPTION_START_DATE,COLUMN_SUBSCRIPTION_END_DATE,
                       welvu_specialtyModel.welvu_platform_id, welvu_specialtyModel.welvu_specialty_name,
                       isSpecialtyDefault, isSpecialtySubscribed, isTopicSynced,
                       welvu_specialtyModel.product_identifier, welvu_specialtyModel.
                       yearly_product_identifier,welvu_specialtyModel.welvu_user_id, validFrom, validTill];
            } else {
                sql = [NSString stringWithFormat:
                       @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (%d,\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", %d , \"%@\", \"%@\");",
                       TABLE_WELVU_SPECIALTY, COLUMN_PLATFORM_SPECIALTY_ID, COLUMN_SPECIALTY_NAME, COLUMN_SPECIALTY_DEFAULT,
                       COLUMN_SPECIALTY_SUBSCRIBED, COLUMN_TOPICS_SYNCED, COLUMN_PRODUCT_IDENTIFIER, COLUMN_YEARLY_PRODUCT_IDENTIFIER,COLUMN_USER_ID,COLUMN_SUBSCRIPTION_START_DATE,COLUMN_SUBSCRIPTION_END_DATE,
                       welvu_specialtyModel.welvu_platform_id, welvu_specialtyModel.welvu_specialty_name,
                       isSpecialtyDefault, isSpecialtySubscribed, isTopicSynced,
                       welvu_specialtyModel.product_identifier, welvu_specialtyModel.
                       yearly_product_identifier, welvu_specialtyModel.welvu_user_id,validFrom,validTill];
            }
        } else {
            if(welvu_specialtyModel.welvu_specialty_subscribed) {
                sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\", %@=\"%@\", %@=\"%@\" where %@=%d and %@=%d",
                       TABLE_WELVU_SPECIALTY,
                       COLUMN_SPECIALTY_SUBSCRIBED, COLUMN_CONSTANT_TRUE,
                       COLUMN_SUBSCRIPTION_START_DATE, validFrom,
                       COLUMN_SUBSCRIPTION_END_DATE, validTill,
                       COLUMN_PLATFORM_SPECIALTY_ID, welvu_specialtyModel.welvu_platform_id,
                       COLUMN_USER_ID, welvu_specialtyModel.welvu_user_id];
            } else {
                sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\",%@=\"%@\",%@=\"%@\" where %@=%d and %@=%d",
                       TABLE_WELVU_SPECIALTY,
                       COLUMN_SPECIALTY_SUBSCRIBED, COLUMN_CONSTANT_FALSE,
                       COLUMN_SUBSCRIPTION_START_DATE, validFrom,
                       COLUMN_SUBSCRIPTION_END_DATE, validTill,
                       COLUMN_PLATFORM_SPECIALTY_ID, welvu_specialtyModel.welvu_platform_id,
                       COLUMN_USER_ID, welvu_specialtyModel.welvu_user_id];
            }
        }
        if(sqlite3_exec(database,
                        [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
           SQLITE_OK) {
            specialtyAdded = true;
        };
        sqlite3_close(database);
        database = nil;
        dateFormatter = nil;
    }
    return specialtyAdded;
}

/*
 * Method name: updateSyncedSpecialty
 * Description: To update synced specialty
 * Parameters: dbPath,welvu_specialtyArray
 * Return Type: Bool
 */
+ (BOOL)updateSyncedSpecialty:(NSString *)dbPath:(NSInteger)specialty_id userId:(NSInteger) user_id {
    BOOL update = false;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\" where %@=%d  and %@=%d",
                         TABLE_WELVU_SPECIALTY,
                         COLUMN_TOPICS_SYNCED, COLUMN_CONSTANT_TRUE,
                         COLUMN_PLATFORM_SPECIALTY_ID, specialty_id,
                         COLUMN_USER_ID, user_id];
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            update = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return update;
}

/*
 * Method name: updateSubscribedSpecialty
 * Description: updation of subscribed specialty
 * Parameters: NSString, NSInteger
 * Return Type: int
 */
+ (int)updateSubscribedSpecialty:(NSString *)dbPath specialtyId:(NSInteger)specialty_id
           subscriptionStartDate:(NSDate *)startDate subscriptionEndDate:(NSDate *)endDate
                          userId:(NSInteger) user_id {
    int update = 0;
    char *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
    NSString *validFrom = [dateFormatter stringFromDate:startDate];
    NSString *validTill = [dateFormatter stringFromDate:endDate];
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\", %@=\"%@\", %@=\"%@\" where %@=%d and %@=%d",
                         TABLE_WELVU_SPECIALTY,
                         COLUMN_SPECIALTY_SUBSCRIBED, COLUMN_CONSTANT_TRUE,
                         COLUMN_SUBSCRIPTION_START_DATE, validFrom,
                         COLUMN_SUBSCRIPTION_END_DATE, validTill,
                         COLUMN_PLATFORM_SPECIALTY_ID, specialty_id,
                         COLUMN_USER_ID, user_id];
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
 * Method name: getSpecialtyById
 * Description: To get specialty by Id
 * Parameters: dbPath,welvu_specialtyArray
 * Return Type: welvu_specialtyModel
 */
+ (welvu_specialty *)getSpecialtyById:(NSString *)dbPath specialtyId:(NSInteger)specialty_id  userId:(NSInteger) user_id {
    welvu_specialty *welvu_specialtyModel=nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=%d and %@=%d", TABLE_WELVU_SPECIALTY,
                         COLUMN_SPECIALTY_ID, specialty_id, COLUMN_USER_ID, user_id];
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                welvu_specialtyModel = [[welvu_specialty alloc] initWithSpecialtyId:sqlite3_column_int(selectstmt, 0)];
                welvu_specialtyModel = [self initWithStmt:selectstmt:welvu_specialtyModel];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return welvu_specialtyModel;
}

/*
 * Method name: getSpecialtyNameById
 * Description: getting specialty names by ID
 * Parameters: NSString,NSInteger
 * Return Type: NSString
 */
+ (NSString *)getSpecialtyNameById:(NSString *)dbPath:(NSInteger)specialty_id userId:(NSInteger) user_id {
    NSString *specialtyName=nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where %@=%d and %@=%d", COLUMN_SPECIALTY_NAME,
                         TABLE_WELVU_SPECIALTY, COLUMN_PLATFORM_SPECIALTY_ID, specialty_id,
                         COLUMN_USER_ID, user_id];
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                specialtyName = [NSString stringWithUTF8String
                                 :(char *)sqlite3_column_text(selectstmt, 0)];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return specialtyName;
}

+ (BOOL)deleteSpecialitiesByUserId:(NSString *)dbPath user_id: (NSInteger) userId {
    BOOL deleted = FALSE;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@=%d",
                         TABLE_WELVU_SPECIALTY, COLUMN_USER_ID, userId];
		if(sqlite3_exec(database,
                        [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
           SQLITE_OK) {
            deleted = TRUE;
        };
        sqlite3_close(database);
        database = nil;
    }
    return deleted;
}

/*
 * Method name: initWithStmt
 * Description: Intializing the welvu_specialty model object with db values
 * Parameters: sqlite3_stmt, welvu_settings
 * Return Type: welvu_settings
 */
+ (welvu_specialty *) initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_specialty *)welvu_specialtyModel {
    welvu_specialtyModel.welvu_user_id = sqlite3_column_int(selectstmt, 1);
    if(sqlite3_column_text(selectstmt, 2) != nil) {
        welvu_specialtyModel.welvu_specialty_name = [NSString stringWithUTF8String
                                                     :(char *)sqlite3_column_text(selectstmt, 2)];
    }
    if (sqlite3_column_text(selectstmt, 3) != nil) {
        welvu_specialtyModel.welvu_specialty_info = [NSString stringWithUTF8String
                                                     :(char *)sqlite3_column_text(selectstmt, 3)];
    }
    /*if([[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 4)] isEqualToString:@"True"]) {
     welvu_specialtyModel.welvu_specialty_default = TRUE;
     } else {
     welvu_specialtyModel.welvu_specialty_default = FALSE;
     }*/
    
    if ([[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 5)] isEqualToString:@"True"]) {
        welvu_specialtyModel.welvu_specialty_subscribed = TRUE;
    } else {
        welvu_specialtyModel.welvu_specialty_subscribed = FALSE;
    }
    
    if ([[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 6)] isEqualToString:@"True"]) {
        welvu_specialtyModel.welvu_topic_synced = TRUE;
    } else {
        welvu_specialtyModel.welvu_topic_synced = FALSE;
    }
    if (sqlite3_column_text(selectstmt, 10) != nil) {
        welvu_specialtyModel.product_identifier = [NSString stringWithUTF8String
                                                   :(char *)sqlite3_column_text(selectstmt, 10)];
    }
    if (sqlite3_column_text(selectstmt, 11) != nil) {
        welvu_specialtyModel.yearly_product_identifier = [NSString stringWithUTF8String
                                                          :(char *)sqlite3_column_text(selectstmt, 11)];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
    if ((char *)sqlite3_column_text(selectstmt,12) != nil) {
        welvu_specialtyModel.subscriptionStartDate =  [dateFormatter dateFromString:
                                                       [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 12)]];
    } else {
        welvu_specialtyModel.subscriptionStartDate = nil;
    }
    if ((char *)sqlite3_column_text(selectstmt,13) != nil) {
        welvu_specialtyModel.subscriptionEndDate =  [dateFormatter dateFromString:
                                                     [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 13)]];
    } else {
        welvu_specialtyModel.subscriptionEndDate = nil;
    }
    welvu_specialtyModel.welvu_platform_id = sqlite3_column_int(selectstmt, 14);
    
    
    welvu_specialtyModel.yearlySubscription = false;
    
    return welvu_specialtyModel;
}


/*
 * Method name: initWithStmt
 * Description: Intializing the welvu_specialty model object with db values
 * Parameters: sqlite3_stmt, welvu_settings
 * Return Type: welvu_settings
 */
+ (welvu_specialty *) initWithStmtOldVersion:(sqlite3_stmt *)selectstmt:(welvu_specialty *)welvu_specialtyModel {
    welvu_specialtyModel.welvu_user_id = sqlite3_column_int(selectstmt, 1);
    if(sqlite3_column_text(selectstmt, 2) != nil) {
        welvu_specialtyModel.welvu_specialty_name = [NSString stringWithUTF8String
                                                     :(char *)sqlite3_column_text(selectstmt, 2)];
    }
    if (sqlite3_column_text(selectstmt, 3) != nil) {
        welvu_specialtyModel.welvu_specialty_info = [NSString stringWithUTF8String
                                                     :(char *)sqlite3_column_text(selectstmt, 3)];
    }
    /*if([[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 4)] isEqualToString:@"True"]) {
     welvu_specialtyModel.welvu_specialty_default = TRUE;
     } else {
     welvu_specialtyModel.welvu_specialty_default = FALSE;
     }*/
    
    if ([[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 5)] isEqualToString:@"True"]) {
        welvu_specialtyModel.welvu_specialty_subscribed = TRUE;
    } else {
        welvu_specialtyModel.welvu_specialty_subscribed = FALSE;
    }
    
    if ([[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 6)] isEqualToString:@"True"]) {
        welvu_specialtyModel.welvu_topic_synced = TRUE;
    } else {
        welvu_specialtyModel.welvu_topic_synced = FALSE;
    }
    if (sqlite3_column_text(selectstmt, 10) != nil) {
        welvu_specialtyModel.product_identifier = [NSString stringWithUTF8String
                                                   :(char *)sqlite3_column_text(selectstmt, 10)];
    }
    if (sqlite3_column_text(selectstmt, 11) != nil) {
        welvu_specialtyModel.yearly_product_identifier = [NSString stringWithUTF8String
                                                          :(char *)sqlite3_column_text(selectstmt, 11)];
    }
    
    if (sqlite3_column_text(selectstmt, 12) != nil) {
        welvu_specialtyModel.subscriptionStartDate = [NSString stringWithUTF8String
                                                   :(char *)sqlite3_column_text(selectstmt, 12)];
    }
    if (sqlite3_column_text(selectstmt, 13) != nil) {
        welvu_specialtyModel.subscriptionEndDate = [NSString stringWithUTF8String
                                                          :(char *)sqlite3_column_text(selectstmt, 13)];
    }
    
  
    
    /*NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
    if ((char *)sqlite3_column_text(selectstmt,12) != nil) {
        welvu_specialtyModel.subscriptionStartDate =  [dateFormatter dateFromString:
                                                       [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 12)]];
    } else {
        welvu_specialtyModel.subscriptionStartDate = nil;
    }
    if ((char *)sqlite3_column_text(selectstmt,13) != nil) {
        welvu_specialtyModel.subscriptionEndDate =  [dateFormatter dateFromString:
                                                     [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 13)]];
    } else {
        welvu_specialtyModel.subscriptionEndDate = nil;
    }
    
    */
    
    welvu_specialtyModel.yearlySubscription = false;
    
    return welvu_specialtyModel;
}

+ (welvu_specialty *)getSpecialtymodel:(NSString *)dbPath:(NSInteger)specialty_id userId:(NSInteger) user_id {
    welvu_specialty *welvu_specialtyModel=nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=%d and %@=%d",
                         TABLE_WELVU_SPECIALTY, COLUMN_PLATFORM_SPECIALTY_ID, specialty_id,
                         COLUMN_USER_ID, user_id];
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                welvu_specialtyModel = [[welvu_specialty alloc] initWithSpecialtyId:sqlite3_column_int(selectstmt, 0)];
                welvu_specialtyModel = [self initWithStmt:selectstmt:welvu_specialtyModel];
			}            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return welvu_specialtyModel;
}


@end
