//
//  welvu_oauth.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 08/08/14.
//  Copyright (c) 2014 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_oauth.h"
#import "welvuContants.h"

@implementation welvu_oauth

@synthesize expires_in ,refresh_token,scope,token_type ,access_token ,welvu_user_id,email_id ,current_date;
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

+ (welvu_oauth *) copy:(welvu_oauth *) welvuUserModel {
    welvu_oauth *welvu_userModel  = [[welvu_oauth alloc] init];
    if (welvu_userModel) {
        welvu_userModel.welvu_user_id = welvu_userModel.welvu_user_id;
        welvu_userModel.access_token = welvuUserModel.access_token;
        welvu_userModel.expires_in = welvu_userModel.expires_in;
        welvu_userModel.refresh_token = welvu_userModel.refresh_token;
        welvu_userModel.scope = welvu_userModel.scope;
        welvu_userModel.token_type = welvu_userModel.token_type;
        welvu_userModel.email_id = welvu_userModel.email_id;
        welvu_userModel.current_date = welvu_userModel.current_date;
    }
    return welvu_userModel;
}

/*
 * Method name: addWelvuOauthUser
 * Description:insert the user to the welvu with required fields
 * Parameters: dbPath,welvu_oauthModel
 * Return Type: NSInteger
 */
+ (NSInteger)addWelvuOauthUser:(NSString *)dbPath:(welvu_oauth *)welvu_oauthModel {
    NSInteger userId = 0;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        
        
        
        sql = [NSString stringWithFormat:
               @"INSERT INTO %@ (%@,%@, %@, %@, %@, %@ ,%@) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
               TABLE_WELVU_OAUTH_USER, COLUMN_ACCESS_TOKEN, COLUMN_EXPIRES_IN, COLUMN_REFRESH_TOKEN, COLUMN_SCOPE, COLUMN_TOKEN_TYPE,HTTP_EMAILID_KEY,HTTP_RESPONSE_CURRENTDATE_KEY,welvu_oauthModel.access_token,welvu_oauthModel.expires_in,welvu_oauthModel.refresh_token,welvu_oauthModel.scope,welvu_oauthModel.token_type,welvu_oauthModel.email_id ,welvu_oauthModel.current_date];
        NSLog(@"sql %@", sql);
        
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            userId = [self getLastInsertRowId:dbPath];
        };
        sqlite3_close(database);
        database = nil;
    }
    userId = [self getLastInsertRowId:dbPath];
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
        NSString *sql =nil;
        sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@;",TABLE_WELVU_OAUTH_USER];
         NSLog(@"sql %@", sql);
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
 * Method name: getOauthDetailsByEmailId
 * Description:get oauth model by user email id
 * Parameters: dbPath,emailId
 * Return Type: welvu_oauth model
 */
+ (welvu_oauth *)getOauthDetailsByEmailId:(NSString *)dbPath emailId:(NSString *) emailId {
    welvu_oauth *welvu_oAuthModel = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=\"%@\" ", TABLE_WELVU_OAUTH_USER,
                         COLUMN_EMAIL, emailId];
        NSLog(@"sql %@",sql);
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                welvu_oAuthModel = [[welvu_oauth alloc] initWithUserId:sqlite3_column_int(selectstmt, 0)];
                welvu_oAuthModel = [self initWithStmt:selectstmt :welvu_oAuthModel];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return welvu_oAuthModel;
}


/*
 * Method name: initWithStmt
 * Description: Intializing the welvu_images model object with db values
 * Parameters: sqlite3_stmt, welvu_images
 * Return Type: welvu_images
 */
+ (welvu_oauth *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_oauth *)welvu_oauthModel {
    welvu_oauthModel.welvu_user_id = sqlite3_column_int(selectstmt, 0);
    
    if (sqlite3_column_text(selectstmt, 1) != nil) {
        welvu_oauthModel.expires_in = [NSString stringWithUTF8String
                                       :(char *)sqlite3_column_text(selectstmt, 1)];
    }
    
    if (sqlite3_column_text(selectstmt, 2) != nil) {
        welvu_oauthModel.scope = [NSString stringWithUTF8String
                                  :(char *)sqlite3_column_text(selectstmt, 2)];
    }
    if (sqlite3_column_text(selectstmt, 3) != nil) {
        welvu_oauthModel.token_type = [NSString stringWithUTF8String
                                       :(char *)sqlite3_column_text(selectstmt, 3)];
    }
    if (sqlite3_column_text(selectstmt, 4) != nil) {
        welvu_oauthModel.access_token = [NSString stringWithUTF8String
                                         :(char *)sqlite3_column_text(selectstmt, 4)];
    }
    if (sqlite3_column_text(selectstmt, 5) != nil) {
        welvu_oauthModel.refresh_token = [NSString stringWithUTF8String
                                          :(char *)sqlite3_column_text(selectstmt, 5)];
    }
    
    if (sqlite3_column_text(selectstmt, 6) != nil) {
        welvu_oauthModel.email_id = [NSString stringWithUTF8String
                                     :(char *)sqlite3_column_text(selectstmt, 6)];
    }
    if (sqlite3_column_text(selectstmt, 7) != nil) {
        welvu_oauthModel.current_date = [NSString stringWithUTF8String
                                         :(char *)sqlite3_column_text(selectstmt, 7)];
    }
    
    
    
    return welvu_oauthModel;
}


/*
 * Method name: deleteoauthValueFromDB
 * Description: deleting the oauth model  object from db
 * Parameters: email_id
 * Return Type: BOOL
 */
+ (BOOL)deleteoauthValueFromDB:(NSString *)dbPath:(NSString *) email_id {
    BOOL oauthDeleted = FALSE;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@=\"%@\" ",
                         TABLE_WELVU_OAUTH_USER,
                         
                         COLUMN_EMAIL, email_id];
        NSLog(@"sql %@",sql);
        if(sqlite3_exec(database,
                        [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
           SQLITE_OK) {
            oauthDeleted = TRUE;
        };
        sqlite3_close(database);
        database = nil;
    }
    return oauthDeleted;
}

@end
