//
//  welvu_app_version.m
//  welvu
//
//  Created by Logesh Kumaraguru on 10/12/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_app_version.h"
#import "welvu_specialty.h"
#import "welvuContants.h"

@implementation welvu_app_version
@synthesize welvu_app_version_id, welvu_app_version_txt, welvu_app_version_sequence,
welvu_app_db_changes, welvu_app_db_updated, welvu_app_version_active, welvu_app_updated_on,
welvu_app_identifier;

static sqlite3 *database = nil;
/*
 * Method name: checkCurrentVersion
 * Description: toCheck current version of the app
 * Parameters: dbPath
 * Return Type: NSString
 */
+ (NSString *)checkCurrentVersion:(NSString *)dbPath {
    NSString *appVersion = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where  %@=\"%@\"",
                         COLUMN_WELVU_APP_VERSION_TXT, TABLE_WELVU_APP_VERSION,
                         COLUMN_WELVU_APP_VERSION_ACTIVE, COLUMN_CONSTANT_TRUE];
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                if(sqlite3_column_text(selectstmt, 0) != nil) {
                    appVersion = [NSString stringWithUTF8String
                                  :(char *)sqlite3_column_text(selectstmt, 0)];
                }
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return appVersion;
}

/*
 * Method name: updatedCurrentVersion
 * Description: To check wheather its updated version
 * Parameters: dbPath,welvu_app_versionModel
 * Return Type: Bool
 */
+ (BOOL)updatedCurrentVersion:(NSString *)dbPath:(welvu_app_version *)welvu_app_versionModel {
    BOOL versionUpdated = false;
    char *error = nil;
    
    int update = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\"",
                         TABLE_WELVU_APP_VERSION,
                         COLUMN_WELVU_APP_VERSION_ACTIVE, COLUMN_CONSTANT_FALSE];
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            update = 1;
        };
        sqlite3_close(database);
        database = nil;
    }
    
    error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT];
        NSString *updatedOn = (NSString *)[dateFormatter stringFromDate:welvu_app_versionModel.welvu_app_updated_on];
        sql = [NSString stringWithFormat:
               @"INSERT INTO %@ (%@, %@, %@, %@) VALUES (\"%@\", %d, \"%@\", \"%@\")",
               TABLE_WELVU_APP_VERSION,COLUMN_WELVU_APP_VERSION_TXT, COLUMN_WELVU_APP_VERSION_SEQUENCE,
               COLUMN_WELVU_APP_VERSION_ACTIVE, COLUMN_WELVU_APP_UPDATED_ON,
               welvu_app_versionModel.welvu_app_version_txt,
               welvu_app_versionModel.welvu_app_version_sequence,
               (welvu_app_versionModel.welvu_app_version_active == true ?
                COLUMN_CONSTANT_TRUE:COLUMN_CONSTANT_FALSE), updatedOn];
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            versionUpdated = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return versionUpdated;
}
/*
 * Method name: alterTablesForGUID
 * Description: alter the db table for Globally unique identifier
 * Parameters: dbPath
 * Return Type: Bool
 */

+ (BOOL)alterTablesForGUID:(NSString *)dbPath {
    BOOL updateContent = false;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        sql = @"Alter table welvu_images ADD image_guid VARCHAR(100);Alter table welvu_topics ADD topics_guid VARCHAR(100);CREATE TABLE welvu_sync (sync_id integer  PRIMARY KEY AUTOINCREMENT DEFAULT NULL, guid Varchar(100) DEFAULT NULL, sync_type integer, action_type integer, sync_completed Boolean DEFAULT False);";
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            updateContent = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return updateContent;
}

/*
 * Method name: createWelVUVideoQueue
 * Description: create the table welvu_video to queue the viedo created by user.
 * Parameters: dbPath
 * Return Type: Bool
 */

+ (BOOL)createWelVUVideoQueue:(NSString *)dbPath {
    BOOL createTable = false;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        sql = @"CREATE TABLE welvu_video (welvu_video_id integer  PRIMARY KEY AUTOINCREMENT DEFAULT NULL, generic_file_name Varchar(200) DEFAULT NULL, video_file_name Varchar(200), audio_file_name Varchar(200) DEFAULT NULL, av_file_name Varchar(200) DEFAULT NULL, welvu_video_type integer, recording_status integer DEFAULT NULL, created_date DateTime  DEFAULT NULL, welvu_user_id integer); CREATE TABLE welvu_sharevu (welvu_sharevu_id integer  PRIMARY KEY AUTOINCREMENT DEFAULT NULL, sharevu_subject Varchar(1000), sharevu_recipients Varchar(500) DEFAULT NULL, sharevu_msg Varchar(5000) DEFAULT NULL, welvu_video_id integer, sharevu_service Varchar(100) DEFAULT NULL, signature Varchar(1000), created_date DateTime  DEFAULT NULL, sharevu_status integer DEFAULT 0, welvu_user_id integer);";
        //Alter table welvu_specialty ADD welvu_platform_id INTEGER;
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            createTable = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return createTable;
    
}


/*
 * Method name: userManagementUpdate
 * Description:user management update.
 * Parameters: dbPath
 * Return Type: Bool
 */

+ (BOOL)userManagementUpdate:(NSString *)dbPath {
    BOOL createTable = false;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        sql =  @"CREATE TABLE welvu_specialty_temp(welvu_specialty_id INTEGER  PRIMARY KEY DEFAULT NULL,welvu_user_id integer DEFAULT NULL,welvu_specialty_name VARCHAR(100) NOT NULL,welvu_specialty_info VARCHAR(1000),welvu_specialty_default BOOLEAN,welvu_specialty_subscribed BOOLEAN,topics_synced Boolean  DEFAULT NULL,version FLOAT  DEFAULT NULL,created_on DateTime DEFAULT NULL,last_updated DateTime DEFAULT NULL,product_identifier VARCHAR(200) DEFAULT NULL,yearly_product_identifier VARCHAR(200) DEFAULT NULL,subscriptionStartDate DateTime DEFAULT NULL,subscriptionEndDate DateTime DEFAULT NULL,welvu_platform_id integer,FOREIGN KEY(welvu_user_id) REFERENCES welvu_user(welvu_user_id));CREATE TABLE welvu_topics_temp (topic_id INTEGER DEFAULT NULL,welvu_user_id integer DEFAULT NULL, welvu_specialty_id INTEGER NOT NULL, topic_name VARCHAR(50) NOT NULL, topic_info VARCHAR(500), topic_is_user_created Boolean DEFAULT 0, topic_active Boolean DEFAULT 1,        topic_hit_count integer DEFAULT 1, topic_default_order integer, is_synced Boolean DEFAULT NULL, version FLOAT  DEFAULT NULL,        created_on DateTime DEFAULT NULL, last_updated DateTime DEFAULT NULL, is_locked Boolean DEFAULT NULL, topics_guid VARCHAR(100), FOREIGN KEY(welvu_specialty_id) REFERENCES welvu_specialty(welvu_specialty_id), FOREIGN KEY(welvu_user_id) REFERENCES welvu_user(welvu_user_id)); insert into welvu_topics_temp select * from welvu_topics; CREATE TABLE welvu_images_temp ( images_id INTEGER DEFAULT NULL, welvu_user_id integer default NULL, topic_id INTEGER,         image_display_name VARCHAR(50), order_number INTEGER DEFAULT NULL, type VARCHAR(50), url VARCHAR(250) DEFAULT NULL,        image_info VARCHAR(100), image_active  BOOLEAN, image_thumbnail VARCHAR(100) DEFAULT NULL, is_synced BOOLEAN DEFAULT NULL,         version FLOAT  DEFAULT NULL, created_on DateTime DEFAULT NULL, last_updated DateTime DEFAULT NULL, is_locked Boolean DEFAULT NULL, image_guid VARCHAR(100), FOREIGN KEY(topic_id) REFERENCES welvu_topics(topic_id), FOREIGN KEY(welvu_user_id) REFERENCES welvu_user(welvu_user_id)); insert into welvu_images_temp select * from welvu_images;";
        //Alter table welvu_specialty ADD welvu_platform_id INTEGER;
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            createTable = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    if(createTable) {
        BOOL updateSpecialtyTemp = [self updateSpecialtyTempTable:dbPath];
        
        if(updateSpecialtyTemp) {
            BOOL tableRenamed = [self renameTableSpecialtyTemp:dbPath];
            if(!tableRenamed) {
                createTable = false;
            }
        } else {
            
            createTable = false;
        }
    }
    return createTable;
    
}

/*
 * Method name: updateSpecialtyTempTable
 * Description:Update Specialty for user management table
 * Parameters: dbPath
 * Return Type: Bool
 */
+(BOOL)updateSpecialtyTempTable:(NSString *) dbPath {
    NSMutableArray *welvu_specialtyArray = [welvu_specialty getAllSpecialtyWithoutUserId:dbPath];
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
            NSString *isTopicSynced = COLUMN_CONSTANT_FALSE;
            if(welvu_specialtyModel.welvu_topic_synced) {
                isTopicSynced = COLUMN_CONSTANT_TRUE;
            }
            if (welvu_specialtyModel.welvu_specialty_subscribed) {
                sql = [sql stringByAppendingString:[NSString stringWithFormat:
                                                    @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@,%@) VALUES (%d,\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", %d, \"%@\", \"%@\");",
                                                    @"welvu_specialty_temp", COLUMN_PLATFORM_SPECIALTY_ID, COLUMN_SPECIALTY_NAME, COLUMN_SPECIALTY_DEFAULT,
                                                    COLUMN_SPECIALTY_SUBSCRIBED, COLUMN_TOPICS_SYNCED, COLUMN_PRODUCT_IDENTIFIER,
                                                    COLUMN_YEARLY_PRODUCT_IDENTIFIER,
                                                    COLUMN_USER_ID, COLUMN_SUBSCRIPTION_START_DATE,COLUMN_SUBSCRIPTION_END_DATE,
                                                    welvu_specialtyModel.welvu_specialty_id, welvu_specialtyModel.welvu_specialty_name,
                                                    isSpecialtyDefault, isSpecialtySubscribed, isTopicSynced,
                                                    welvu_specialtyModel.product_identifier, welvu_specialtyModel.yearly_product_identifier,welvu_specialtyModel.welvu_user_id, validFrom, validTill]];
            } else {
                sql = [sql stringByAppendingString:[NSString stringWithFormat:
                                                    @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@) VALUES (%d,\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", %d);",
                                                    @"welvu_specialty_temp", COLUMN_PLATFORM_SPECIALTY_ID, COLUMN_SPECIALTY_NAME, COLUMN_SPECIALTY_DEFAULT,
                                                    COLUMN_SPECIALTY_SUBSCRIBED, COLUMN_TOPICS_SYNCED, COLUMN_PRODUCT_IDENTIFIER,COLUMN_YEARLY_PRODUCT_IDENTIFIER, COLUMN_USER_ID,                                          welvu_specialtyModel.welvu_specialty_id,
                                                    welvu_specialtyModel.welvu_specialty_name,
                                                    isSpecialtyDefault, isSpecialtySubscribed, isTopicSynced,
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
 * Method name: renameTableSpecialtyTemp
 * Description:Rename Specialty table name for user management table
 * Parameters: dbPath
 * Return Type: Bool
 */
+(BOOL) renameTableSpecialtyTemp:(NSString *) dbPath {
    BOOL createTable = false;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        sql =  @"DROP TABLE IF EXISTS welvu_specialty;ALTER TABLE welvu_specialty_temp RENAME TO welvu_specialty;DROP TABLE IF EXISTS welvu_topics;ALTER TABLE welvu_topics_temp RENAME TO welvu_topics;DROP TABLE IF EXISTS welvu_images;ALTER TABLE welvu_images_temp RENAME TO welvu_images; ";
        //Alter table welvu_specialty ADD welvu_platform_id INTEGER;
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            createTable = true;
        };
        sqlite3_close(database);
        database = nil;
    }
}

+(BOOL) welvuUserAndContentsModification:(NSString *) dbPath {
    BOOL tableModified = false;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        //ALTER table welvu_user ADD box_access_token VARCHAR(200);
        sql =  @"ALTER table welvu_user ADD box_access_token VARCHAR(200);ALTER table welvu_user ADD box_refresh_access_token VARCHAR(200);ALTER table welvu_user ADD box_expires_in VARCHAR(200); CREATE TABLE welvu_images_temp (images_id INTEGER DEFAULT NULL, welvu_user_id integer default NULL, topic_id INTEGER,         image_display_name VARCHAR(50), order_number INTEGER DEFAULT NULL, type VARCHAR(50), url VARCHAR(250) DEFAULT NULL, image_info VARCHAR(100), image_active  BOOLEAN, image_thumbnail VARCHAR(100) DEFAULT NULL, is_synced BOOLEAN DEFAULT NULL, version FLOAT  DEFAULT NULL, created_on DateTime DEFAULT NULL, last_updated DateTime DEFAULT NULL, is_locked Boolean DEFAULT NULL, image_guid VARCHAR(100), welvu_platform_id Double, FOREIGN KEY(topic_id) REFERENCES welvu_topics(topic_id), FOREIGN KEY(welvu_user_id) REFERENCES welvu_user(welvu_user_id)); insert into welvu_images_temp (images_id, welvu_user_id, topic_id, image_display_name, order_number, type, url, image_info, image_active, image_thumbnail, is_synced, version, created_on, last_updated, is_locked, image_guid) select images_id, welvu_user_id, topic_id, image_display_name, order_number, type, url, image_info, image_active, image_thumbnail, is_synced, version, created_on, last_updated, is_locked, image_guid from welvu_images;DROP TABLE IF EXISTS welvu_images;ALTER TABLE welvu_images_temp RENAME TO welvu_images;";
        //Alter table welvu_specialty ADD welvu_platform_id INTEGER;
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            tableModified = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    
    return tableModified;
}
/*
 * Method name: welvuOrganizationTableUpdates
 * Description:Update the welvu organization Table  when user logged in.
 * Parameters: dbPath
 * Return Type: Bool
 */

+(BOOL) welvuOrganizationTableUpdates:(NSString *) dbPath {
    BOOL tableModified = false;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        //ALTER table welvu_user ADD box_access_token VARCHAR(200);
        sql =  @"ALTER table welvu_user ADD org_id integer DEFAULT 0; ALTER table welvu_user ADD user_primary_id integer DEFAULT 0;ALTER table welvu_user ADD user_org_role Varchar DEFAULT NULL;ALTER table welvu_user ADD user_org_status Varchar DEFAULT NULL;CREATE TABLE welvu_organization (org_id integer DEFAULT NULL, org_name Varchar(255) DEFAULT NULL, org_logo_name Varchar DEFAULT NULL ,product_Type Varchar(255) DEFAULT NULL,org_Status Varchar(255) DEFAULT NULL);";
        //Alter table welvu_specialty ADD welvu_platform_id INTEGER;
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            tableModified = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return tableModified;
    
}
/*
 * Method name: insertDontShowForiPX
 * Description: donot show the alert for the iPx.if user tap donot shown again.
 * Parameters: dbPath
 * Return Type: Bool
 */

+(BOOL) insertDontShowForiPX:(NSString *) dbPath {
    BOOL tableModified = false;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        sql =  @"insert into welvu_alerts(welvu_alert_text, welvu_dont_show) values(\"ALERT_PUSHING_TO_IPX\", \"FALSE\");insert into welvu_alerts(welvu_alert_text, welvu_dont_show) values(\"ALERT_DELETING_MY_VIDEOS_FROM_IPX\", \"FALSE\");insert into welvu_alerts(welvu_alert_text, welvu_dont_show) values(\"ALERT_DELETING_SHARED_VIDEOS_FROM_IPX\", \"FALSE\"); ";
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            tableModified = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return tableModified;
}

+(BOOL) alterTableForTopicListOrder:(NSString *) dbPath {
    NSString *sql =nil;
    int update = 0;
    char *error = nil;
    int topicOrder =2;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        //sql=[NSString stringWithFormat:@"UPDATE welvu_settings set welvu_topic_list_order = 2 WHERE isActive = 'true' "];
        
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=\"%d\" where %@=\"%@\"",
                         TABLE_WELVU_VIDEO_SETTINGS,
                         COLUMN_TOPIC_LIST_ORDER, SETTINGS_VIDEO_OPTION ,COLUMN_IS_ACTIVE ,COLUMN_CONSTANT_TRUE];
        
        
        NSLog(@"sql %@" ,sql);
        // UPDATE welvu_contenttag SET welvu_tagnames = 'santhosh,' WHERE welvu_contentid = '55'
        if(sqlite3_exec(database,
                        [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
           SQLITE_OK) {
            update = 1;
        };
        sqlite3_close(database);
        database = nil;
    }
    return update;
    
}

+(BOOL) welvuIpxImagesTableUpdates:(NSString *) dbPath{

    BOOL tableCreated = false;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        //ALTER table welvu_user ADD box_access_token VARCHAR(200);
        sql =  @"CREATE TABLE welvu_iPx_images ( iPx_images_id INTEGER DEFAULT NULL, ipx_Specilaty_id INTEGER,         ipx_image_display_name VARCHAR(50), order_number INTEGER DEFAULT NULL, ipx_img_type VARCHAR(50), platform_video_url VARCHAR(250) DEFAULT NULL,        ipx_image_info VARCHAR(100), ipx_image_active  BOOLEAN, ipx_image_thumbnail VARCHAR(100) DEFAULT NULL, version FLOAT  DEFAULT NULL, created_on DateTime DEFAULT NULL, last_updated DateTime DEFAULT NULL, is_locked Boolean DEFAULT NULL, image_guid VARCHAR(100), organization_id VARCHAR(100),platform_image_id VARCHAR(100));";
        //Alter table welvu_specialty ADD welvu_platform_id INTEGER;
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            tableCreated = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    
    return tableCreated;


}

+(BOOL) welvuConfigurationCreateTable:(NSString *) dbPath{
    
    BOOL tableCreated = false;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        //ALTER table welvu_user ADD box_access_token VARCHAR(200);
        sql =  @"CREATE TABLE welvu_configuration ( configuration_id INTEGER DEFAULT NULL, welvu_user_id INTEGER, org_id INTEGER DEFAULT NULL, config_adapter VARCHAR(100), config_key VARCHAR(100), config_value VARCHAR(250) DEFAULT NULL);";
        //Alter table welvu_specialty ADD welvu_platform_id INTEGER;
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            tableCreated = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    
    return tableCreated;
    
    
}
+(BOOL) welvuOauthCreateTable:(NSString *) dbPath{
    
    BOOL tableCreated = false;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        //ALTER table welvu_user ADD box_access_token VARCHAR(200);
        sql =  @"CREATE TABLE welvu_oauth ( welvu_user_id INTEGER DEFAULT NULL,expires_in VARCHAR(200),scope VARCHAR(200),token_type VARCHAR(200),access_token VARCHAR(200),refresh_token VARCHAR(200),email VARCHAR(200),current_date VARCHAR(200));";
        //Alter table welvu_specialty ADD welvu_platform_id INTEGER;
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            tableCreated = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    
    return tableCreated;
    
    
}
+(BOOL) welvuPinCreateTable:(NSString *) dbPath{
    
    BOOL tableCreated = false;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        //ALTER table welvu_user ADD box_access_token VARCHAR(200);
        sql =  @"CREATE TABLE welvu_pin ( pin_id INTEGER DEFAULT NULL,welvu_user_id INTEGER DEFAULT NULL, welvu_pin VARCHAR(100));";
        //Alter table welvu_specialty ADD welvu_platform_id INTEGER;
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            tableCreated = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    
    return tableCreated;
    
    
}
+(BOOL) alterUserTableForOauth:(NSString *) dbPath{
    BOOL updateContent = false;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        sql = @"Alter table welvu_user ADD expires_in DateTime  DEFAULT NULL;Alter table welvu_user ADD refresh_token VARCHAR(100);Alter table welvu_user ADD scope VARCHAR(100);Alter table welvu_user ADD token_type VARCHAR(100);Alter table welvu_user ADD current_date DateTime  DEFAULT NULL;";
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            updateContent = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return updateContent;
}



/*
+(BOOL) userorgStatusUpdate:(NSString *) dbPath {
    
    BOOL tableModified = false;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        sql = @"insert into welvu_organization(product_Type, org_Status) values(\"ALERT_PUSHING_TO_IPX\", \"FALSE\");insert into welvu_alerts(welvu_alert_text, welvu_dont_show) values(\"ALERT_DELETING_MY_VIDEOS_FROM_IPX\", \"FALSE\");insert into welvu_alerts(welvu_alert_text, welvu_dont_show) values(\"ALERT_DELETING_SHARED_VIDEOS_FROM_IPX\", \"FALSE\"); ";
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            tableModified = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return tableModified;
}*/
/*
 * Method name: initWithStmt
 * Description: Intializing the welvu_app_version model object with db values
 * Parameters: sqlite3_stmt, welvu_app_version
 * Return Type: welvu_app_version
 */

+ (welvu_app_version *)initWithStmt:(sqlite3_stmt *)
                         selectstmt:(welvu_app_version *)welvu_app_version_model {
    
    return welvu_app_version_model;
}
@end
