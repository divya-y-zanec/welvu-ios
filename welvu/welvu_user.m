//
//  welvu_user.m
//  welvu
//
//  Created by Logesh Kumaraguru on 25/01/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_user.h"
#import "welvuContants.h"
@implementation welvu_user

@synthesize welvu_user_id, firstname, lastname, middlename, username, email, specialty, access_token,
access_token_obtained_on, current_logged_user ,box_expires_in,box_refresh_access_token,box_access_token;
@synthesize user_primary_key,org_id ,user_Org_Role , user_org_status ,isConfirmedUser;
@synthesize oauth_expires_in,oauth_refresh_token,oauth_token_type,oauth_scope ,oauth_currentDate;


static sqlite3 *database = nil;
/*
 * Method name: initWithUserId
 * Description: Intializing with user id
 * Parameters: userId
 * Return Type: self
 */

- (id)initWithUserId:(NSInteger) userId {
    self=[super init];
    if (self) {
        welvu_user_id = userId;
    }
    return self;
}

+ (welvu_user *) copy:(welvu_user *) welvuUserModel {
    welvu_user *welvu_userModel  = [[welvu_user alloc] init];
    if (welvu_userModel) {
        welvu_userModel.welvu_user_id = welvuUserModel.welvu_user_id;
        welvu_userModel.firstname = welvuUserModel.firstname;
        welvu_userModel.lastname = welvuUserModel.lastname;
        welvu_userModel.middlename = welvuUserModel.middlename;
        welvu_userModel.email = welvuUserModel.email;
        welvu_userModel.username = welvuUserModel.username;
        welvu_userModel.specialty = welvuUserModel.specialty;
        welvu_userModel.access_token = welvuUserModel.access_token;
        welvu_userModel.access_token_obtained_on = welvuUserModel.access_token_obtained_on;
        welvu_userModel.org_id = welvuUserModel.org_id;
        welvu_userModel.user_primary_key = welvuUserModel.user_primary_key;
        welvu_userModel.isConfirmedUser = welvu_userModel.isConfirmedUser;
        welvu_userModel.oauth_expires_in = welvu_userModel.oauth_expires_in;
        welvu_userModel.oauth_refresh_token = welvu_userModel.oauth_refresh_token;
        welvu_userModel.oauth_scope = welvu_userModel.oauth_scope;
        welvu_userModel.oauth_token_type = welvu_userModel.oauth_token_type;
        welvu_userModel.oauth_currentDate = welvu_userModel.oauth_currentDate;
    }
    return welvu_userModel;
}

/*
 * Method name: addWelvuUser
 * Description:insert the user to the welvu with required fields
 * Parameters: dbPath,welvu_userModel
 * Return Type: NSInteger
 */
+ (NSInteger)addWelvuUser:(NSString *)dbPath:(welvu_user *)welvu_userModel {
    NSInteger userId = 0;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        
        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
            
            
            sql = [NSString stringWithFormat:
                   @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                   TABLE_WELVU_USER, COLUMN_FIRSTNAME, COLUMN_MIDDLENAME, COLUMN_LASTNAME, COLUMN_USERNAME, COLUMN_EMAIL,COLUMN_BOX_ACCESS_TOKEN,COLUMN_BOX_REFRESH_ACCESS_TOKEN,COLUMN_BOX_EXPIRES_IN,
                   COLUMN_SPECIALTYID, COLUMN_CURRENT_LOGGED_USER, welvu_userModel.firstname, welvu_userModel.middlename,
                   welvu_userModel.lastname, welvu_userModel.username,
                   welvu_userModel.email,welvu_userModel.box_access_token,welvu_userModel.box_refresh_access_token,welvu_userModel.box_expires_in, welvu_userModel.specialty, COLUMN_CONSTANT_TRUE];
        } else {
            
            sql = [NSString stringWithFormat:
                   @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                   TABLE_WELVU_USER, COLUMN_FIRSTNAME, COLUMN_MIDDLENAME, COLUMN_LASTNAME, COLUMN_USERNAME, COLUMN_EMAIL,
                   COLUMN_SPECIALTYID, COLUMN_CURRENT_LOGGED_USER, welvu_userModel.firstname, welvu_userModel.middlename,
                   welvu_userModel.lastname, welvu_userModel.username,
                   welvu_userModel.email, welvu_userModel.specialty, COLUMN_CONSTANT_TRUE];
        }
        
        
        NSLog(@"addWelvuUser sql %@",sql);
        
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            userId = [self getLastInsertRowId:dbPath];
        };
        sqlite3_close(database);
        database = nil;
    }
    return userId;
}

/*
 * Method name: addUserWithOrganizationDetails
 * Description: Add user organizaation details
 * Parameters: NSString ,welvu_user
 * Return Type: NSInteger
 */

+ (NSInteger)addUserWithOrganizationDetails:(NSString *)dbPath:(welvu_user *)welvu_userModel {
    NSInteger userId = 0;
    NSInteger orgaID = 1;
    
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT_DB];
        
        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
            
            
            sql = [NSString stringWithFormat:
                   @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                   TABLE_WELVU_USER, COLUMN_FIRSTNAME, COLUMN_MIDDLENAME, COLUMN_LASTNAME, COLUMN_USERNAME, COLUMN_EMAIL,COLUMN_BOX_ACCESS_TOKEN,COLUMN_BOX_REFRESH_ACCESS_TOKEN,COLUMN_BOX_EXPIRES_IN,
                   COLUMN_SPECIALTYID, COLUMN_CONSTANT_FALSE, welvu_userModel.firstname, welvu_userModel.middlename,
                   welvu_userModel.lastname, welvu_userModel.username,
                   welvu_userModel.email,welvu_userModel.box_access_token,welvu_userModel.box_refresh_access_token,welvu_userModel.box_expires_in, welvu_userModel.specialty, COLUMN_CONSTANT_TRUE];
        }
        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
            if (welvu_userModel.email) {
            
            sql = [NSString stringWithFormat:
                   @"INSERT INTO %@ (%@, %@, %@, %@,%@, %@, %@, %@, %@, %@, %@ ,%@,%@,%@,%@ ,%@ ,%@,%@) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%d\", \"%d\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\",\"%@\", \"%@\" , \"%@\", \"%@\")",
                   TABLE_WELVU_USER, COLUMN_FIRSTNAME, COLUMN_MIDDLENAME, COLUMN_LASTNAME, COLUMN_USERNAME, COLUMN_EMAIL,COLUMN_ORG_ID,COLUMN_USER_PRIMARY_KEY,COLUMN_SPECIALTYID, COLUMN_CURRENT_LOGGED_USER,COLUMN_ACCESS_TOKEN,COLUMN_REFRESH_TOKEN,COLUMN_SCOPE,COLUMN_EXPIRES_IN,COLUMN_TOKEN_TYPE,HTTP_RESPONSE_CURRENTDATE_KEY,
                   COLUMN_ACCESS_TOKEN_OBTAINED_ON,COLUMN_USER_ORG_ROLE ,COLUMN_USER_ORG_Status,
                   welvu_userModel.firstname, welvu_userModel.middlename,
                   welvu_userModel.lastname, welvu_userModel.username,
                   welvu_userModel.email,welvu_userModel.org_id,welvu_userModel.welvu_user_id, welvu_userModel.specialty, COLUMN_CONSTANT_FALSE , welvu_userModel.access_token ,welvu_userModel.oauth_refresh_token,welvu_userModel.oauth_scope,welvu_userModel.oauth_expires_in,welvu_userModel.oauth_token_type, welvu_userModel.oauth_currentDate,welvu_userModel.access_token_obtained_on ,welvu_userModel.user_Org_Role ,welvu_userModel.user_org_status];
                }
            
        } else {
            
            sql = [NSString stringWithFormat:
                   @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@ ,%@,%@,%@,%@ ,%@ ,%@) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%d\", \"%d\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\" , \"%@\")",
                   TABLE_WELVU_USER, COLUMN_FIRSTNAME, COLUMN_MIDDLENAME, COLUMN_LASTNAME, COLUMN_USERNAME, COLUMN_EMAIL,COLUMN_ORG_ID,COLUMN_USER_PRIMARY_KEY,COLUMN_SPECIALTYID, COLUMN_CURRENT_LOGGED_USER,COLUMN_ACCESS_TOKEN,
                   COLUMN_ACCESS_TOKEN_OBTAINED_ON,COLUMN_USER_ORG_ROLE ,COLUMN_USER_ORG_Status,
                   welvu_userModel.firstname, welvu_userModel.middlename,
                   welvu_userModel.lastname, welvu_userModel.username,
                   welvu_userModel.email,welvu_userModel.org_id,welvu_userModel.welvu_user_id, welvu_userModel.specialty, COLUMN_CONSTANT_FALSE , welvu_userModel.access_token , welvu_userModel.access_token_obtained_on ,welvu_userModel.user_Org_Role ,welvu_userModel.user_org_status];
        }
        NSLog(@"insert org user%@",sql);
        
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            userId = [self getLastInsertRowId:dbPath];
        };
        sqlite3_close(database);
        database = nil;
    }
    return userId;
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
        NSString *sql = [NSString stringWithFormat:@"select max(%@) from %@",COLUMN_USER_ID,TABLE_WELVU_USER];
        
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
 * Method name: getLastInsertRowId
 * Description: last inserted row ID
 * Parameters: NSString, NSInteger
 * Return Type: NSInteger
 */
+ (welvu_user *)getCurrentLoggedUser:(NSString *)dbPath {
    welvu_user *welvu_userModel = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=\"%@\"", TABLE_WELVU_USER,
                         COLUMN_CURRENT_LOGGED_USER, COLUMN_CONSTANT_TRUE];
       
        sqlite3_stmt *selectstmt;
        if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                welvu_userModel = [[welvu_user alloc] initWithUserId:sqlite3_column_int(selectstmt, 0)];
                welvu_userModel = [self initWithStmt:selectstmt :welvu_userModel];
            }
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    return welvu_userModel;
}

/*
 * Method name: getUserByEmailId
 * Description: To get welvu user by email id
 * Parameters: dbPath, emailId
 * Return Type: welvu_user
 */
+ (welvu_user *)getUserByEmailId:(NSString *)dbPath emailId:(NSString *) emailId {
    welvu_user *welvu_userModel = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=\"%@\" and %@ <= 0", TABLE_WELVU_USER,
                         COLUMN_EMAIL, emailId, COLUMN_ORG_ID];
        
        NSLog(@"sql %@",sql);
        sqlite3_stmt *selectstmt;
        if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                welvu_userModel = [[welvu_user alloc] initWithUserId:sqlite3_column_int(selectstmt, 0)];
                welvu_userModel = [self initWithStmt:selectstmt :welvu_userModel];
            }
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    return welvu_userModel;
}
/*
 * Method name: getUserByEmailIdAndOrgId
 * Description: To get welvu user by email id and orgid
 * Parameters: dbPath, emailId ,orgId
 * Return Type: welvu_user
 */
+ (welvu_user *)getUserByEmailIdAndOrgId:(NSString *)dbPath emailId:(NSString *) emailId
                                   orgId:(NSInteger) orgId {
    welvu_user *welvu_userModel = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=\"%@\" and %@=%d", TABLE_WELVU_USER,
                         COLUMN_EMAIL, emailId, COLUMN_ORG_ID, orgId];
        NSLog(@"sql %@" ,sql);
        
        sqlite3_stmt *selectstmt;
        if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                welvu_userModel = [[welvu_user alloc] initWithUserId:sqlite3_column_int(selectstmt, 0)];
                welvu_userModel = [self initWithStmt:selectstmt :welvu_userModel];
            }
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    return welvu_userModel;
}
/*
 * Method name: getUserByAccessToken
 * Description: To get welvu user by Access token
 * Parameters: dbPath, accessToken
 * Return Type: welvu_user
 */
+ (welvu_user *)getUserByAccessToken:(NSString *)dbPath token:(NSString *) accessToken {
    welvu_user *welvu_userModel = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=\"%@\"", TABLE_WELVU_USER,
                         COLUMN_ACCESS_TOKEN, accessToken];
        
        sqlite3_stmt *selectstmt;
        if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                welvu_userModel = [[welvu_user alloc] initWithUserId:sqlite3_column_int(selectstmt, 0)];
                welvu_userModel = [self initWithStmt:selectstmt :welvu_userModel];
            }
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    return welvu_userModel;
}

/*
 * Method name: getAllOrgIdOfUser
 * Description: To get org id of the user
 * Parameters: dbPath, user_id
 * Return Type: NSMutableArray
 */
+ (NSMutableArray *) getAllOrgIdOfUser:(NSString *)dbPath userId:(NSInteger) user_id {
    NSMutableArray * orgIds = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where %@=%d",
                         COLUMN_ORG_ID, TABLE_WELVU_USER,
                         COLUMN_USER_PRIMARY_KEY, user_id];
        
        sqlite3_stmt *selectstmt;
        if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if(orgIds == nil) {
                    orgIds = [[NSMutableArray alloc] init];
                }
                
                [orgIds addObject:[NSNumber numberWithInteger
                                   :sqlite3_column_int(selectstmt, 0)]];
            }
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    return orgIds;
}

/*
 * Method name: updateLoggedUserAccessToken
 * Description: update the loged user access token
 * Parameters: dbPath, welvu_userModel
 * Return Type: NSInteger
 */
+ (NSInteger)updateLoggedUserAccessToken:(NSString *)dbPath:(welvu_user *)welvu_userModel {
    NSInteger update = 0;
    char *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT_DB];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        
        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
            sql = [NSString stringWithFormat:
                   @"update %@  set %@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\" where %@=\"%@\"",
                   TABLE_WELVU_USER,
                   COLUMN_FIRSTNAME, welvu_userModel.firstname,
                   COLUMN_MIDDLENAME, welvu_userModel.middlename,
                   COLUMN_LASTNAME,welvu_userModel.lastname,
                   COLUMN_USERNAME,  welvu_userModel.username,
                   COLUMN_EMAIL, welvu_userModel.email,
                   COLUMN_SPECIALTYID,  welvu_userModel.specialty,
                   COLUMN_CURRENT_LOGGED_USER, COLUMN_CONSTANT_TRUE,
                   COLUMN_ACCESS_TOKEN, welvu_userModel.access_token,
                   COLUMN_ACCESS_TOKEN_OBTAINED_ON, [dateFormatter stringFromDate: welvu_userModel.access_token_obtained_on],
                   COLUMN_BOX_ACCESS_TOKEN,welvu_userModel.box_access_token,
                   COLUMN_BOX_REFRESH_ACCESS_TOKEN,welvu_userModel.box_refresh_access_token,
                   COLUMN_BOX_EXPIRES_IN ,welvu_userModel.box_expires_in,
                   COLUMN_EMAIL, welvu_userModel.email];
        }  if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
            
                sql = [NSString stringWithFormat:
                       @"update %@  set %@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\" where %@=\"%@\" and %@= 0 ",
                       TABLE_WELVU_USER,
                       COLUMN_FIRSTNAME, welvu_userModel.firstname,
                       COLUMN_MIDDLENAME, welvu_userModel.middlename,
                       COLUMN_LASTNAME,welvu_userModel.lastname,
                       COLUMN_USERNAME,  welvu_userModel.username,
                       COLUMN_EMAIL, welvu_userModel.email,
                       COLUMN_SPECIALTYID,  welvu_userModel.specialty,
                       COLUMN_CURRENT_LOGGED_USER, COLUMN_CONSTANT_TRUE,
                       COLUMN_ACCESS_TOKEN, welvu_userModel.access_token,
                       COLUMN_ACCESS_TOKEN_OBTAINED_ON, [dateFormatter stringFromDate: welvu_userModel.access_token_obtained_on],
                       
                       COLUMN_TOKEN_TYPE,welvu_userModel.oauth_token_type,
                       COLUMN_REFRESH_TOKEN,welvu_userModel.oauth_refresh_token,
                       COLUMN_EXPIRES_IN ,welvu_userModel.oauth_expires_in,
                       COLUMN_SCOPE ,welvu_userModel.oauth_scope,
                       HTTP_RESPONSE_CURRENTDATE_KEY ,welvu_userModel.oauth_currentDate,
                       
                       COLUMN_EMAIL, welvu_userModel.email,
                       COLUMN_USER_PRIMARY_KEY ];
            
            
        }else {
            sql = [NSString stringWithFormat:
                   @"update %@  set %@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\" where %@=%d",
                   TABLE_WELVU_USER,
                   COLUMN_FIRSTNAME, welvu_userModel.firstname,
                   COLUMN_MIDDLENAME, welvu_userModel.middlename,
                   COLUMN_LASTNAME,welvu_userModel.lastname,
                   COLUMN_USERNAME,  welvu_userModel.username,
                   COLUMN_EMAIL, welvu_userModel.email,
                   COLUMN_SPECIALTYID,  welvu_userModel.specialty,
                   COLUMN_CURRENT_LOGGED_USER, COLUMN_CONSTANT_FALSE,
                   COLUMN_ACCESS_TOKEN, welvu_userModel.access_token,
                   COLUMN_ACCESS_TOKEN_OBTAINED_ON, [dateFormatter stringFromDate: welvu_userModel.access_token_obtained_on],
                   COLUMN_USER_ID, welvu_userModel.welvu_user_id];
        }
        NSLog(@"update1 %@",sql);
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
 * Method name: updateLoggedUserAccessToken
 * Description: update the orgs loged user access token
 * Parameters: dbPath, welvu_userModel
 * Return Type: NSInteger
 */
+ (NSInteger)updateLoggedorgUserAccessToken:(NSString *)dbPath:(welvu_user *)welvu_userModel {
    NSInteger update = 0;
    char *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT_DB];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        
  if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
            
            sql = [NSString stringWithFormat:
                   @"update %@  set %@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\" where %@=\"%@\" and %@ > 0 ",
                   TABLE_WELVU_USER,
                   COLUMN_FIRSTNAME, welvu_userModel.firstname,
                   COLUMN_MIDDLENAME, welvu_userModel.middlename,
                   COLUMN_LASTNAME,welvu_userModel.lastname,
                   COLUMN_USERNAME,  welvu_userModel.username,
                   COLUMN_EMAIL, welvu_userModel.email,
                   COLUMN_SPECIALTYID,  welvu_userModel.specialty,
                   COLUMN_CURRENT_LOGGED_USER, COLUMN_CONSTANT_FALSE,
                   COLUMN_ACCESS_TOKEN, welvu_userModel.access_token,
                   COLUMN_ACCESS_TOKEN_OBTAINED_ON, [dateFormatter stringFromDate: welvu_userModel.access_token_obtained_on],
                   
                   COLUMN_TOKEN_TYPE,welvu_userModel.oauth_token_type,
                   COLUMN_REFRESH_TOKEN,welvu_userModel.oauth_refresh_token,
                   COLUMN_EXPIRES_IN ,welvu_userModel.oauth_expires_in,
                   COLUMN_SCOPE ,welvu_userModel.oauth_scope,
                   HTTP_RESPONSE_CURRENTDATE_KEY ,welvu_userModel.oauth_currentDate,
                   
                   COLUMN_EMAIL, welvu_userModel.email,
                   COLUMN_USER_PRIMARY_KEY];
            
            
        }else {
            sql = [NSString stringWithFormat:
                   @"update %@  set %@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\" where %@=%d",
                   TABLE_WELVU_USER,
                   COLUMN_FIRSTNAME, welvu_userModel.firstname,
                   COLUMN_MIDDLENAME, welvu_userModel.middlename,
                   COLUMN_LASTNAME,welvu_userModel.lastname,
                   COLUMN_USERNAME,  welvu_userModel.username,
                   COLUMN_EMAIL, welvu_userModel.email,
                   COLUMN_SPECIALTYID,  welvu_userModel.specialty,
                   COLUMN_CURRENT_LOGGED_USER, COLUMN_CONSTANT_FALSE,
                   COLUMN_ACCESS_TOKEN, welvu_userModel.access_token,
                   COLUMN_ACCESS_TOKEN_OBTAINED_ON, [dateFormatter stringFromDate: welvu_userModel.access_token_obtained_on],
                   COLUMN_USER_ID, welvu_userModel.welvu_user_id];
        }
        NSLog(@"update2 %@",sql);
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
 * Method name: updateLoggedUserByOrgId
 * Description: Update current logged user bu org id
 * Parameters: dbPath, user_id ,isPrimary ,orgId
 * Return Type: NSInteger
 */
+ (NSInteger)updateLoggedUserByOrgId:(NSString *)dbPath userId:(NSInteger) user_id
                               orgId:(NSInteger) orgId isPrimary:(BOOL) isPrimary{
    
    NSInteger update = 0;
    char *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT_DB];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        if(!isPrimary) {
            sql = [NSString stringWithFormat:
                   @"update %@  set %@=\"%@\" where %@=%d and %@=%d",
                   TABLE_WELVU_USER,
                   COLUMN_CURRENT_LOGGED_USER, COLUMN_CONSTANT_TRUE,
                   COLUMN_USER_PRIMARY_KEY, user_id, COLUMN_ORG_ID, orgId];
        } else {
            sql = [NSString stringWithFormat:
                   @"update %@  set %@=\"%@\" where %@=%d",
                   TABLE_WELVU_USER,
                   COLUMN_CURRENT_LOGGED_USER, COLUMN_CONSTANT_TRUE,
                   COLUMN_USER_ID, user_id];
        }
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
 * Method name: getWelvuUserAccessToken
 * Description:Get Access Token of Welvu user
 * Parameters: dbPath
 * Return Type: NSString
 */
+ (NSString *)getWelvuUserAccessToken:(NSString *)dbPath{
    NSString *contenttag123;;
    //welvu_user *welvu_userModel = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        //select access_token from welvu_user;
        NSString *sql = [NSString stringWithFormat:@"select access_token from welvu_user"];
        // NSLog(@"sql value %@",sql);
        
        sqlite3_stmt *selectstmt;
        if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
            while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                contenttag123 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(selectstmt, 0)];
                
            }
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    return contenttag123;
}
/*
 * Method name: addWelvuUserWithAccessToken
 * Description:Insert Access Token of Welvu user DB
 * Parameters: dbPath,welvu_userModel
 * Return Type: NSInteger
 */
+ (NSInteger) addWelvuUserWithAccessToken:(NSString *)dbPath:(welvu_user *)welvu_userModel {
    NSInteger userId = 0;
    char *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT_DB];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        
        /*  sql = [NSString stringWithFormat:
         @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\",\"%@\")",
         TABLE_WELVU_USER, COLUMN_FIRSTNAME, COLUMN_MIDDLENAME, COLUMN_LASTNAME,
         COLUMN_USERNAME, COLUMN_EMAIL, COLUMN_SPECIALTYID, COLUMN_CURRENT_LOGGED_USER,
         COLUMN_ACCESS_TOKEN, COLUMN_ACCESS_TOKEN_OBTAINED_ON,
         welvu_userModel.firstname, welvu_userModel.middlename,
         welvu_userModel.lastname, welvu_userModel.username,
         welvu_userModel.email, welvu_userModel.specialty, COLUMN_CONSTANT_TRUE,
         welvu_userModel.access_token, [dateFormatter stringFromDate: welvu_userModel.access_token_obtained_on]];*/
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        
        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
            
            sql = [NSString stringWithFormat:
                   @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\",\"%@\", \"%@\", \"%@\",\"%@\")",
                   TABLE_WELVU_USER, COLUMN_FIRSTNAME, COLUMN_MIDDLENAME, COLUMN_LASTNAME,
                   
                   COLUMN_BOX_ACCESS_TOKEN,COLUMN_BOX_REFRESH_ACCESS_TOKEN,COLUMN_BOX_EXPIRES_IN,
                   COLUMN_USERNAME, COLUMN_EMAIL, COLUMN_SPECIALTYID, COLUMN_CURRENT_LOGGED_USER,
                   COLUMN_ACCESS_TOKEN, COLUMN_ACCESS_TOKEN_OBTAINED_ON,
                   welvu_userModel.firstname, welvu_userModel.middlename,
                   welvu_userModel.lastname,
                   welvu_userModel.box_access_token,welvu_userModel.box_refresh_access_token,
                   welvu_userModel.box_expires_in,
                   welvu_userModel.username,
                   welvu_userModel.email, welvu_userModel.specialty, COLUMN_CONSTANT_TRUE,
                   welvu_userModel.access_token, [dateFormatter stringFromDate: welvu_userModel.access_token_obtained_on]];
        }  if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
            
            sql = [NSString stringWithFormat:
                   @"INSERT INTO %@ (%@,%@, %@,%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (\"%@\",\"%@\", \"%@\",\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\",\"%@\", \"%@\", \"%@\",\"%@\")",
                   TABLE_WELVU_USER, COLUMN_FIRSTNAME, COLUMN_MIDDLENAME, COLUMN_LASTNAME,
                   
                   COLUMN_ACCESS_TOKEN,COLUMN_REFRESH_TOKEN,COLUMN_EXPIRES_IN,COLUMN_SCOPE,COLUMN_TOKEN_TYPE,HTTP_RESPONSE_CURRENTDATE_KEY,
                   COLUMN_USERNAME, COLUMN_EMAIL, COLUMN_SPECIALTYID, COLUMN_CURRENT_LOGGED_USER,
                   COLUMN_ACCESS_TOKEN, COLUMN_ACCESS_TOKEN_OBTAINED_ON,
                   welvu_userModel.firstname, welvu_userModel.middlename,
                   welvu_userModel.lastname,
                   welvu_userModel.access_token,welvu_userModel.oauth_refresh_token,
                   welvu_userModel.oauth_expires_in,
                   welvu_userModel.oauth_scope,welvu_userModel.oauth_token_type,
                   welvu_userModel.oauth_currentDate,
                   welvu_userModel.username,
                   welvu_userModel.email, welvu_userModel.specialty, COLUMN_CONSTANT_TRUE,
                   welvu_userModel.access_token, [dateFormatter stringFromDate: welvu_userModel.access_token_obtained_on]];
        }else {
            
            sql = [NSString stringWithFormat:
                   @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@ ) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\",\"%@\")",
                   TABLE_WELVU_USER, COLUMN_FIRSTNAME, COLUMN_MIDDLENAME, COLUMN_LASTNAME,
                   COLUMN_USERNAME, COLUMN_EMAIL, COLUMN_SPECIALTYID, COLUMN_CURRENT_LOGGED_USER,
                   COLUMN_ACCESS_TOKEN, COLUMN_ACCESS_TOKEN_OBTAINED_ON,
                   welvu_userModel.firstname, welvu_userModel.middlename,
                   welvu_userModel.lastname, welvu_userModel.username,
                   welvu_userModel.email, welvu_userModel.specialty, COLUMN_CONSTANT_TRUE,
                   welvu_userModel.access_token, [dateFormatter stringFromDate: welvu_userModel.access_token_obtained_on] ];
        }
        NSLog(@"addWelvuUser acc %@",sql);
        if(sqlite3_exec(database,
                        [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
           SQLITE_OK) {
            userId = [self getLastInsertRowId:dbPath];
        };
        sqlite3_close(database);
        database = nil;
    }
    return userId;
}

/*
 * Method name: logoutUser
 * Description:log out the user
 * Parameters: dbPath, welvu_userModel
 * Return Type: BOOL
 */

+ (BOOL) logoutUser:(NSString *)dbPath :(welvu_user *)welvu_userModel {
    BOOL update = false;
    char *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT_DB];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        sql = [NSString stringWithFormat:
               @"update %@  set %@=\"%@\" where %@=\"%@\"",
               TABLE_WELVU_USER,
               COLUMN_CURRENT_LOGGED_USER, COLUMN_CONSTANT_FALSE,
               COLUMN_EMAIL, welvu_userModel.email];
        NSLog(@"addWelvuUser %@",sql);
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
 * Method name: clearAccessandRefreshToken
 * Description:log out the user
 * Parameters: dbPath, welvu_userModel
 * Return Type: BOOL
 */

+ (BOOL) clearAccessandRefreshToken:(NSString *)dbPath  {
    BOOL update = false;
    char *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT_DB];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        sql = [NSString stringWithFormat:
               @"update %@  set %@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\"",
               TABLE_WELVU_USER,
               COLUMN_ACCESS_TOKEN, @"",
               COLUMN_REFRESH_TOKEN, @"",
               COLUMN_ACCESS_TOKEN_OBTAINED_ON, @"",
                COLUMN_CURRENT_LOGGED_USER, COLUMN_CONSTANT_FALSE];
        
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
 * Method name: initWithStmt
 * Description: statments for alerts
 * Parameters: sqlite3_stmt ,welvu_userModel
 * Return Type: welvu_user
 */
+ (welvu_user *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_user *)welvu_userModel {
    
    if (sqlite3_column_text(selectstmt, 0) != nil) {
        welvu_userModel.welvu_user_id = sqlite3_column_int(selectstmt, 0);
    }
    
    
    
    if (sqlite3_column_text(selectstmt, 1) != nil) {
        welvu_userModel.firstname = [NSString stringWithUTF8String
                                     :(char *)sqlite3_column_text(selectstmt, 1)];
    }
    
    if (sqlite3_column_text(selectstmt, 2) != nil) {
        welvu_userModel.middlename = [NSString stringWithUTF8String
                                      :(char *)sqlite3_column_text(selectstmt, 2)];
    }
    
    
    if (sqlite3_column_text(selectstmt, 3) != nil) {
        welvu_userModel.lastname = [NSString stringWithUTF8String
                                    :(char *)sqlite3_column_text(selectstmt, 3)];
    }
    
    if (sqlite3_column_text(selectstmt, 4) != nil) {
        welvu_userModel.username = [NSString stringWithUTF8String
                                    :(char *)sqlite3_column_text(selectstmt, 4)];
    }
    
    if (sqlite3_column_text(selectstmt, 5) != nil) {
        welvu_userModel.email = [NSString stringWithUTF8String
                                 :(char *)sqlite3_column_text(selectstmt, 5)];
    }
    
    if(sqlite3_column_text(selectstmt, 6) != nil) {
        welvu_userModel.specialty = [NSString stringWithUTF8String
                                     :(char *)sqlite3_column_text(selectstmt, 6)];
    }
    
    if (sqlite3_column_text(selectstmt, 7) != nil) {
        welvu_userModel.access_token = [NSString stringWithUTF8String
                                        :(char *)sqlite3_column_text(selectstmt, 7)];
    } else {
        welvu_userModel.access_token = nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT_DB];
    if ((char *)sqlite3_column_text(selectstmt,8) != nil
        && ![[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 8)]isEqualToString:@"(null)"]) {
        welvu_userModel.access_token_obtained_on =  [dateFormatter dateFromString:
                                                     [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 8)]];
    } else {
        welvu_userModel.access_token_obtained_on = nil;
    }
    
    if ([[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 9)] isEqualToString:@"True"]) {
        welvu_userModel.current_logged_user = TRUE;
    } else {
        welvu_userModel.current_logged_user = FALSE;
    }
    
    if (sqlite3_column_text(selectstmt, 10) != nil) {
        welvu_userModel.box_access_token = [NSString stringWithUTF8String
                                            :(char *)sqlite3_column_text(selectstmt, 10)];
    } else {
        welvu_userModel.box_access_token = nil;
    }
    
    if (sqlite3_column_text(selectstmt, 11) != nil) {
        welvu_userModel.box_refresh_access_token = [NSString stringWithUTF8String
                                                    :(char *)sqlite3_column_text(selectstmt, 11)];
    } else {
        welvu_userModel.box_refresh_access_token = nil;
    }
    
    if (sqlite3_column_text(selectstmt, 12) != nil) {
        welvu_userModel.box_expires_in = [NSString stringWithUTF8String
                                          :(char *)sqlite3_column_text(selectstmt, 12)];
    } else {
        welvu_userModel.box_expires_in = nil;
    }
    
    if (sqlite3_column_text(selectstmt, 13) != nil) {
        welvu_userModel.org_id = sqlite3_column_int(selectstmt, 13);
    }
    
    if (sqlite3_column_text(selectstmt, 14) != nil) {
        welvu_userModel.user_primary_key = sqlite3_column_int(selectstmt, 14);
    }
    
    if (sqlite3_column_text(selectstmt, 15) != nil) {
        welvu_userModel.user_Org_Role = [NSString stringWithUTF8String
                                         :(char *)sqlite3_column_text(selectstmt, 15)];
    }
    
    if (sqlite3_column_text(selectstmt, 16) != nil) {
        welvu_userModel.user_org_status = [NSString stringWithUTF8String
                                           :(char *)sqlite3_column_text(selectstmt, 16)];
    }
    if (sqlite3_column_text(selectstmt, 17) != nil) {
        welvu_userModel.oauth_expires_in = [NSString stringWithUTF8String
                                            :(char *)sqlite3_column_text(selectstmt, 17)];
    }
    
    if (sqlite3_column_text(selectstmt, 18) != nil) {
        welvu_userModel.oauth_refresh_token = [NSString stringWithUTF8String
                                               :(char *)sqlite3_column_text(selectstmt, 18)];
    }
    
    if (sqlite3_column_text(selectstmt, 19) != nil) {
        welvu_userModel.oauth_scope = [NSString stringWithUTF8String
                                       :(char *)sqlite3_column_text(selectstmt, 19)];
    }
    
    if (sqlite3_column_text(selectstmt, 20) != nil) {
        welvu_userModel.oauth_token_type = [NSString stringWithUTF8String
                                            :(char *)sqlite3_column_text(selectstmt, 20)];
    }
    
    if (sqlite3_column_text(selectstmt, 21) != nil) {
        welvu_userModel.oauth_currentDate = [NSString stringWithUTF8String
                                             :(char *)sqlite3_column_text(selectstmt, 21)];
    }
    return welvu_userModel;
}

/*
 * Method name: updateConfirmedLoggedUserAccessToken
 * Description:to update the access token for confirmed user
 * Parameters: dbPath,welvu_userModel
 * Return Type: NSInteger
 */
+ (NSInteger)updateConfirmedLoggedUserAccessToken:(NSString *)dbPath:(welvu_user *)welvu_userModel {
    NSInteger update = 0;
    char *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT_DB];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = nil;
        sql = [NSString stringWithFormat:
               @"update %@  set %@=\"%@\",%@=\"%@\" where %@=%d",
               TABLE_WELVU_USER,
               COLUMN_ACCESS_TOKEN, welvu_userModel.access_token,
               COLUMN_ACCESS_TOKEN_OBTAINED_ON, [dateFormatter stringFromDate: welvu_userModel.access_token_obtained_on],
               COLUMN_USER_ID, welvu_userModel.welvu_user_id];
        
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
 * Method name: updateBoxAccessToken
 * Description:to update the Box access token  for user
 * Parameters: dbPath,welvu_userModel
 * Return Type: BOOL
 */

+ (BOOL)updateBoxAccessToken:(NSString *)dbPath:(welvu_user *)welvu_userModel
{
    NSString *sql =nil;
    int update = 0;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        sql=[NSString stringWithFormat:@"UPDATE welvu_user SET box_access_token = '%@',box_refresh_access_token = '%@',box_expires_in = '%@' WHERE welvu_user_id =%d",welvu_userModel.box_access_token,welvu_userModel.box_refresh_access_token,welvu_userModel.box_expires_in,1];
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

/*
 * Method name: To get the row values of welvu_user  with org_id and user primaryId
 * Description:to update the Box access token  for user
 * Parameters: dbPath,orgID ,UserPId
 * Return Type: BOOL
 */

+ (BOOL )prymaryId:(NSString *)dbPath :(NSInteger)orgID :(NSInteger)UserPId{
    // NSInteger orgId;
    BOOL prymaryKey = false;
    NSInteger orgID1 =5;
    //welvu_user *welvu_userModel = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        //select access_token from welvu_user;
        NSString *sql = [NSString stringWithFormat:@"select * from welvu_user where org_id = %d and user_primary_id = %d", orgID, UserPId];
        //  NSLog(@"sql value %@",sql);
        
        sqlite3_stmt *selectstmt;
        if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
            
            
            while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                prymaryKey = true;
            }
            
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    return prymaryKey;
}

/*
 * Method name: getUserIdByOrgId
 * Description:To get user d by org id
 * Parameters: dbPath,orgID
 * Return Type: welvu_user
 */

+ (welvu_user *)getUserIdByOrgId:(NSString *)dbPath:(NSInteger )org_Id {
    // NSInteger orgId;
    welvu_user *welvu_userModel = nil;       //welvu_user *welvu_userModel = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        //select access_token from welvu_user;
        NSString *sql = [NSString stringWithFormat:@"select welvu_user_id from welvu_user where org_id = %d" ,org_Id];
        //  NSLog(@"sql value %@",sql);
        
        sqlite3_stmt *selectstmt;
        if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
            
            
            while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                welvu_userModel = [[welvu_user alloc] initWithUserId:sqlite3_column_int(selectstmt, 0)];
                welvu_userModel = [self initWithStmt:selectstmt :welvu_userModel];
            }
            
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    return welvu_userModel;
}

/*
 * Method name: getUserIdByOrgId
 * Description:To get user d by org id
 * Parameters: dbPath,orgID
 * Return Type: welvu_user
 */
+ (BOOL) switchAccount:(NSString *)dbPath {
    BOOL update = false;
    char *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT_DB];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        sql = [NSString stringWithFormat:@"update welvu_user set current_logged_user='false' where user_primary_id <>0"];
        
        // update welvu_user set current_logged_user="false" where user_primary_id <>0
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
+ (NSInteger)getUserCount:(NSString *)dbPath :(NSInteger)user_id {
    NSInteger max_number = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select count() from welvu_user where user_primary_id = %d or (user_primary_id != 0 AND user_primary_id in ( SELECT user_primary_id from welvu_user where welvu_user_id = %d))",user_id ,user_id ];
        
        
        /*   select count() from welvu_user where user_primary_id = 5 OR (user_primary_id != 0 AND user_primary_id in ( SELECT user_primary_id from welvu_user where welvu_user_id = 5))*/
        
        
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

+ (BOOL) logoutUserInSettings:(NSString *)dbPath :(welvu_user *)welvu_userModel {
    BOOL update = false;
    char *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT_DB];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        sql = [NSString stringWithFormat:
               @"update %@  set %@=\"%@\" where %@=\"%@\" ",
               TABLE_WELVU_USER,
               COLUMN_CURRENT_LOGGED_USER, COLUMN_CONSTANT_FALSE,
               COLUMN_EMAIL, welvu_userModel.email];
        
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
 * Method name: getAllOrgIdOfUser
 * Description: To get org id of the user
 * Parameters: dbPath, user_id
 * Return Type: NSMutableArray
 */
+ (NSMutableArray *) getAllOrgStatusOfUser:(NSString *)dbPath userId:(NSInteger) user_id {
    NSMutableArray * orgIds = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where %@=%d",
                         COLUMN_USER_ORG_Status, TABLE_WELVU_USER,
                         COLUMN_USER_PRIMARY_KEY, user_id];
        
        sqlite3_stmt *selectstmt;
        if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if(orgIds == nil) {
                    orgIds = [[NSMutableArray alloc] init];
                }
                
                [orgIds addObject:[NSNumber numberWithInteger
                                   :sqlite3_column_int(selectstmt, 0)]];
            }
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    return orgIds;
}
+(NSInteger)getOrgIdByWelvuUserId:(NSString *)dbPath :(NSInteger)userId {
    NSInteger welvuuserId = 0;
    NSInteger statusCount = 1;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select org_id from welvu_user where welvu_user_id = %d",userId];
        
        sqlite3_stmt *selectstmt;
        if(sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
            while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                welvuuserId = sqlite3_column_int(selectstmt, 0);
            }
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    return welvuuserId;
}
+ (NSInteger)getOrgUserCount:(NSString *)dbPath :(NSInteger)user_id {
    
    int count = 0;
    int userOrgStatus = 1;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK)
    {
        /*  NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM welvu_user where user_primary_id = %d " ,user_id];
         */
        NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM welvu_user where user_primary_id= %d and user_org_status = %d" ,user_id,userOrgStatus];
        NSLog(@"sql %@",sql);
        sqlite3_stmt *statement;
        
        if( sqlite3_prepare_v2(database, [sql cStringUsingEncoding:NSASCIIStringEncoding],-1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                count = sqlite3_column_int(statement, 0);
            }
        }
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return count;
}

/* NSInteger max_number = -1;
 NSInteger userOrgStatus = 1;
 if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
 NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM welvu_user where user_primary_id = %d and user_org_status = %d" ,user_id ,userOrgStatus];
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
 return max_number;}*/

+ (NSInteger)getOrgUserStatus:(NSString *)dbPath :(NSInteger)user_id {
    NSInteger welvuuserId = 0;
    NSInteger org_status =1;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        
        
        
        NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM welvu_user where user_primary_id = %d and user_org_status = %d" ,user_id ,org_status];
        
        NSLog(@"sql %@",sql);
        sqlite3_stmt *selectstmt;
        if(sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
            while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                welvuuserId = sqlite3_column_int(selectstmt, 0);
            }
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    return welvuuserId;
}
/*
 * Method name: updateUserOrgStatus
 * Description: to update the organization status for the user
 * Parameters: userid
 * return value:NSInteger
 * Created On: 17 july 2014
 */
+ (NSInteger)updateUserOrgStatus:(NSString *)dbPath :(welvu_user *)welvu_userModel {
    
    
    NSInteger orgStatus = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        sql = [NSString stringWithFormat:
               @"update %@  set %@=\"%@\",  %@=\"%@\", %@=\"%@\" where %@=\"%@\" ",
               TABLE_WELVU_USER,
               COLUMN_ORG_ID, welvu_userModel.org_id,
               COLUMN_ORG_NAME, welvu_userModel.user_Org_Role,COLUMN_USER_ORG_Status ,welvu_userModel.user_org_status ,COLUMN_USER_PRIMARY_KEY ,welvu_userModel.user_primary_key];
        NSLog(@"sql update %@ ",sql);
        
        sqlite3_stmt *selectstmt;
        if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                orgStatus = sqlite3_column_int(selectstmt, 0);
            }
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    return orgStatus;
    
}
+ (NSInteger)getPrimaryIdByUserId:(NSString *)dbPath :(NSInteger)user_id {
    NSInteger welvuPrimaryId = 0;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select user_primary_id from welvu_user where welvu_user_id = %d",user_id];
        
        sqlite3_stmt *selectstmt;
        if(sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
            while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                welvuPrimaryId = sqlite3_column_int(selectstmt, 0);
            }
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    return welvuPrimaryId;
    
}
+ (NSInteger)addUserWithoauthDetails:(NSString *)dbPath:(welvu_user *)welvu_userModel {
    
    NSInteger userId = 0;
    NSInteger orgaID = 1;
    
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT_DB];
        
        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
            
            
            sql = [NSString stringWithFormat:
                   @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                   TABLE_WELVU_USER, COLUMN_FIRSTNAME, COLUMN_MIDDLENAME, COLUMN_LASTNAME, COLUMN_USERNAME, COLUMN_EMAIL,COLUMN_BOX_ACCESS_TOKEN,COLUMN_BOX_REFRESH_ACCESS_TOKEN,COLUMN_BOX_EXPIRES_IN,
                   COLUMN_SPECIALTYID, COLUMN_CONSTANT_FALSE, welvu_userModel.firstname, welvu_userModel.middlename,
                   welvu_userModel.lastname, welvu_userModel.username,
                   welvu_userModel.email,welvu_userModel.box_access_token,welvu_userModel.box_refresh_access_token,welvu_userModel.box_expires_in, welvu_userModel.specialty, COLUMN_CONSTANT_TRUE];
        } else {
            
            sql = [NSString stringWithFormat:
                   @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@ ,%@,%@,%@,%@ ,%@ ,%@) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%d\", \"%d\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\" , \"%@\")",
                   TABLE_WELVU_USER, COLUMN_FIRSTNAME, COLUMN_MIDDLENAME, COLUMN_LASTNAME, COLUMN_USERNAME, COLUMN_EMAIL,COLUMN_ORG_ID,COLUMN_USER_PRIMARY_KEY,COLUMN_SPECIALTYID, COLUMN_CURRENT_LOGGED_USER,COLUMN_ACCESS_TOKEN,
                   COLUMN_ACCESS_TOKEN_OBTAINED_ON,COLUMN_USER_ORG_ROLE ,COLUMN_USER_ORG_Status,
                   welvu_userModel.firstname, welvu_userModel.middlename,
                   welvu_userModel.lastname, welvu_userModel.username,
                   welvu_userModel.email,welvu_userModel.org_id,welvu_userModel.welvu_user_id, welvu_userModel.specialty, COLUMN_CONSTANT_FALSE , welvu_userModel.access_token , welvu_userModel.access_token_obtained_on ,welvu_userModel.user_Org_Role ,welvu_userModel.user_org_status];
        }
        NSLog(@"sql with out det %@",sql);
        
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            userId = [self getLastInsertRowId:dbPath];
        };
        sqlite3_close(database);
        database = nil;
    }
    return userId;
    
    
}

+ (NSInteger)updateOauthLoggedUserAccessToken:(NSString *)dbPath:(welvu_user *)welvu_userModel {
    NSInteger update = 0;
    char *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT_DB];
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        
        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
            sql = [NSString stringWithFormat:
                   @"update %@  set %@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\" where %@=%d",
                   TABLE_WELVU_USER,
                   COLUMN_FIRSTNAME, welvu_userModel.firstname,
                   COLUMN_MIDDLENAME, welvu_userModel.middlename,
                   COLUMN_LASTNAME,welvu_userModel.lastname,
                   COLUMN_USERNAME,  welvu_userModel.username,
                   COLUMN_EMAIL, welvu_userModel.email,
                   COLUMN_SPECIALTYID,  welvu_userModel.specialty,
                   COLUMN_CURRENT_LOGGED_USER, COLUMN_CONSTANT_TRUE,
                   COLUMN_ACCESS_TOKEN, welvu_userModel.access_token,
                   COLUMN_ACCESS_TOKEN_OBTAINED_ON, [dateFormatter stringFromDate: welvu_userModel.access_token_obtained_on],
                   COLUMN_BOX_ACCESS_TOKEN,welvu_userModel.box_access_token,
                   COLUMN_BOX_REFRESH_ACCESS_TOKEN,welvu_userModel.box_refresh_access_token,
                   COLUMN_BOX_EXPIRES_IN ,welvu_userModel.box_expires_in,
                   COLUMN_USER_ID, welvu_userModel.welvu_user_id];
        }  if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
            
            
            sql = [NSString stringWithFormat:
                   @"update %@  set %@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\" where %@=\"%@\" ",
                   TABLE_WELVU_USER,
                   COLUMN_FIRSTNAME, welvu_userModel.firstname,
                   COLUMN_MIDDLENAME, welvu_userModel.middlename,
                   COLUMN_LASTNAME,welvu_userModel.lastname,
                   COLUMN_USERNAME,  welvu_userModel.username,
                   COLUMN_EMAIL, welvu_userModel.email,
                   COLUMN_SPECIALTYID,  welvu_userModel.specialty,
                   COLUMN_CURRENT_LOGGED_USER, COLUMN_CONSTANT_TRUE,
                   COLUMN_ACCESS_TOKEN, welvu_userModel.access_token,
                   COLUMN_ACCESS_TOKEN_OBTAINED_ON, [dateFormatter stringFromDate: welvu_userModel.access_token_obtained_on],
                   
                   COLUMN_TOKEN_TYPE,welvu_userModel.oauth_token_type,
                   COLUMN_REFRESH_TOKEN,welvu_userModel.oauth_refresh_token,
                   COLUMN_EXPIRES_IN ,welvu_userModel.oauth_expires_in,
                   COLUMN_SCOPE ,welvu_userModel.oauth_scope,
                   HTTP_RESPONSE_CURRENTDATE_KEY ,welvu_userModel.oauth_currentDate,
                   
                   COLUMN_EMAIL, welvu_userModel.email];
            NSLog(@"aouth sql %@",sql);
        }else {
            sql = [NSString stringWithFormat:
                   @"update %@  set %@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\" where %@=%d",
                   TABLE_WELVU_USER,
                   COLUMN_FIRSTNAME, welvu_userModel.firstname,
                   COLUMN_MIDDLENAME, welvu_userModel.middlename,
                   COLUMN_LASTNAME,welvu_userModel.lastname,
                   COLUMN_USERNAME,  welvu_userModel.username,
                   COLUMN_EMAIL, welvu_userModel.email,
                   COLUMN_SPECIALTYID,  welvu_userModel.specialty,
                   COLUMN_CURRENT_LOGGED_USER, COLUMN_CONSTANT_TRUE,
                   COLUMN_ACCESS_TOKEN, welvu_userModel.access_token,
                   COLUMN_ACCESS_TOKEN_OBTAINED_ON, [dateFormatter stringFromDate: welvu_userModel.access_token_obtained_on],
                   COLUMN_USER_ID, welvu_userModel.welvu_user_id];
        }
        NSLog(@"update %@",sql);
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
 * Method name: getOrganizationCountByUserId
 * Description: To Get the number of organization by user id
 * Parameters: NSString
 * Return Type: id
 */

+ (NSInteger)getOrganizationCountByUserId:(NSString *)dbPath currentLogedUserId:(NSInteger)currentLogedUserID {
    NSInteger counteImage = 0;
    NSInteger statusCount = 1;
    NSString *sql;
    
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        sql = [NSString stringWithFormat:@"select count() from %@ where %@=%d and %@=%d ", TABLE_WELVU_USER,
               COLUMN_USER_ORG_Status, statusCount,
               COLUMN_USER_PRIMARY_KEY,currentLogedUserID];
        NSLog(@"sql %@",sql);
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
@end
