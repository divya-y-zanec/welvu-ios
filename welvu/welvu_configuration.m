//
//  welvu_configuration.m
//  welvu
//
//  Created by Divya Yadav. on 03/09/14.
//  Copyright (c) 2014 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_configuration.h"
#import "welvuContants.h"

@implementation welvu_configuration
@synthesize welvu_configuration_id,welvu_configuration_adapter, welvu_configuration_key, welvu_configuration_value,welvu_user_id,orgId;
static sqlite3 *database = nil;

+ (BOOL)addConfiguration:(NSString *)dbPath:(welvu_configuration *)welvu_configurationModel {
    
    
    BOOL inserted = false;
    char *error = nil;
    NSString *sql =nil;
    NSInteger row_id = [self getMaxInsertRowIdForUserImages:dbPath];
    
    sql = [NSString stringWithFormat: @"INSERT into %@ (%@, %@, %@ , %@,%@ ,%@) VALUES (\"%d\", \"%d\",\"%d\" ,\"%@\" ,\"%@\",\"%@\")",
           TABLE_WELVU_CONFIGURATION,COLUMN_CONFIG_ID, COLUMN_USER_ID,
           COLUMN_ORG_ID,COLUMN_CONFIG_ADAPTER ,COLUMN_CONFIG_KEY ,COLUMN_CONFIG_VAlue,
           row_id, welvu_configurationModel.welvu_user_id,
           welvu_configurationModel.orgId ,welvu_configurationModel.welvu_configuration_adapter,welvu_configurationModel.welvu_configuration_key, welvu_configurationModel.welvu_configuration_value];
    
    NSLog(@"insert org %@",sql);
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            inserted =  true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return inserted;
    
}
/*
 * Method name: updateOrganizationDetails
 * Description: Update the user Organization details
 * Parameters: dbPath ,welvu_organizationModel
 * Return Type: BOOL
 */

+ (BOOL)updateOrgConfigDetails:(NSString *)dbPath:(welvu_configuration *)welvu_configurationModel {
    BOOL inserted = false;
    char *error = nil;
    NSString *sql =nil;
    
    sql = [NSString stringWithFormat: @"Update %@ set %@=\"%@\" where %@=%d and %@=%d, %@=\"%@\", %@=\"%@\"",
           TABLE_WELVU_CONFIGURATION,
           COLUMN_CONFIG_VAlue, welvu_configurationModel.welvu_configuration_value,
           COLUMN_USER_ID,welvu_configurationModel.welvu_user_id,
           COLUMN_ORG_ID, welvu_configurationModel.orgId,
           COLUMN_CONFIG_ADAPTER,welvu_configurationModel.welvu_configuration_adapter,
           COLUMN_CONFIG_KEY,welvu_configurationModel.welvu_configuration_key];
    NSLog(@"update org %@",sql);
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            inserted =  true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return inserted;
    
}
/*
 * Method name: getLastInsertRowId
 * Description: last inserted row ID
 * Parameters: NSString, NSInteger
 * Return Type: NSInteger
 */
+ (NSInteger)getMaxInsertRowIdForUserImages:(NSString *)dbPath{
    
    /*NSInteger imageId = (LOCAL_IMAGE_CONTENT_ID_START_RANGE + 1);
     if ([[NSUserDefaults standardUserDefaults] integerForKey:@"USER_IMAGE_ID"]) {
     imageId = [[NSUserDefaults standardUserDefaults] integerForKey:@"USER_IMAGE_ID"];
     }
     [[NSUserDefaults standardUserDefaults] setInteger:(imageId + 1) forKey:@"USER_IMAGE_ID"];*/
    
    NSInteger imageId = (LOCAL_IMAGE_CONTENT_ID_START_RANGE + 1);
    NSInteger max_number = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select max(%@) from %@",
                         COLUMN_CONFIG_ID, TABLE_WELVU_CONFIGURATION, COLUMN_USER_ID];
        
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
        imageId = (max_number + 1);
    }
    
    return imageId;
}

+(NSMutableArray *)getYoutubeConfigurationForOrgId:(NSString *)dbPath organizationId:(NSInteger)orgId adapterType:(NSString *)adapter{
    welvu_configuration *welvuConfigurationModel = nil;
    NSMutableArray *welvuConfigurationArray;
    NSString *contenttag123;
    NSString *sql =nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@= %d and %@= \"%@\" ", TABLE_WELVU_CONFIGURATION,
                         COLUMN_ORG_ID, orgId,COLUMN_CONFIG_ADAPTER, adapter ];
         NSLog(@"get config %@",sql);
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if (welvuConfigurationArray == nil) {
                    welvuConfigurationArray = [[NSMutableArray alloc] init];
                }
				welvu_configuration *welvuConfigurationModel = [[welvu_configuration alloc] initWithConfigId:sqlite3_column_int(selectstmt, 0)];
                welvuConfigurationModel = [self initWithStmt:selectstmt:welvuConfigurationModel];
                [welvuConfigurationArray addObject:welvuConfigurationModel];
                //[welvu_specialtyModel release];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return welvuConfigurationArray;


}

/*
 * Method name: initWithSpecialtyId
 * Description: Intialize the welvu_specialty model with welvu_specialty_id
 * Parameters: NSInteger
 * Return Type: id
 */
- (id)initWithConfigId:(NSInteger)sId {
    self = [super init];
    if(self) {
        welvu_configuration_id = sId;
    }
    return self;
}

/*
 * Method name: initWithStmt
 * Description: statments for alerts
 * Parameters: sqlite3_stmt ,welvu_userModel
 * Return Type: welvu_user
 */


+ (welvu_configuration *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_configuration *)welvuonfigDetails {
    
    welvuAppDelegate * appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    welvuonfigDetails.welvu_configuration_id = sqlite3_column_int(selectstmt, 0);
    
    if (sqlite3_column_text(selectstmt, 1) != nil) {
        welvuonfigDetails.welvu_user_id = sqlite3_column_int(selectstmt, 1);
    }
    
    
    if (sqlite3_column_text(selectstmt, 2) != nil) {
        /* welvuOrganizationDetails.orgLogoName = [NSString stringWithUTF8String
         :(char *)sqlite3_column_text(selectstmt,2 )];*/
        
        welvuonfigDetails.orgId = sqlite3_column_int(selectstmt, 2);
        
    }
    
    if (sqlite3_column_text(selectstmt, 3) != nil) {
        welvuonfigDetails.welvu_configuration_adapter = [NSString stringWithUTF8String
                                                 :(char *)sqlite3_column_text(selectstmt, 3)];
    }
    if (sqlite3_column_text(selectstmt, 4) != nil) {
        welvuonfigDetails.welvu_configuration_key = [NSString stringWithUTF8String
                                               :(char *)sqlite3_column_text(selectstmt, 4)];
    }
    if (sqlite3_column_text(selectstmt, 5) != nil) {
        welvuonfigDetails.welvu_configuration_value = [NSString stringWithUTF8String
                                                     :(char *)sqlite3_column_text(selectstmt, 5)];
    }
    
    return welvuonfigDetails;
}


+(NSInteger) getConfigurationForInsertUpdate:(NSString *)dbPath :(welvu_configuration *)welvu_configurationModel {
    welvu_configuration *welvuConfigurationModel ;
    NSInteger select = 0;
    
    NSString *sql =nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql1 = [NSString stringWithFormat:@"select * from %@ where %@= %d and %@= %d and %@= \"%@\" and %@= \"%@\" ",
                          TABLE_WELVU_CONFIGURATION,
                          COLUMN_USER_ID,welvu_configurationModel.welvu_user_id,
                          COLUMN_ORG_ID,welvu_configurationModel.orgId,
                          COLUMN_CONFIG_ADAPTER, welvu_configurationModel.welvu_configuration_adapter,
                          COLUMN_CONFIG_KEY, welvu_configurationModel.welvu_configuration_key];
        NSLog(@"get config %@",sql1);
        
        sqlite3_stmt *selectstmt;
        if (sqlite3_prepare_v2(database,
                               [sql1 cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
            NSLog(@"selectstmt, SQLITE_ROW %d %d", sqlite3_step(selectstmt), SQLITE_ROW);
            while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                NSLog(@" i am in");
                select = 1;
            }
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    
    
    
    NSLog(@" i am in select %d",select);
    return select;
    
    
}

/*
 * Method name: deleteCacheData
 * Description: Delete the data of patients form db path.
 * Parameters: dbPath
 * Return Type: BOOL
 */
+(BOOL) deleteCacheData:(NSString *)dbPath {
    BOOL deletedCacheData = false;
    char *error = nil;
    NSString *sql =nil;
    
    sql = [NSString stringWithFormat: @"delete from %@", TABLE_WELVU_CONFIGURATION];
    
    NSLog(@"delete from %@",sql);
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            deletedCacheData =  true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return deletedCacheData;
}


@end
