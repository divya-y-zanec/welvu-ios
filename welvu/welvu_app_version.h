//
//  welvu_app_version.h
//  welvu
//
//  Created by Logesh Kumaraguru on 10/12/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
/*
 * Class name: welvu_app_version
 * Description: Has functionality to show app version
 * Extends: NSObject
 * Delegate :nil
 */
@interface welvu_app_version : NSObject {
    NSInteger welvu_app_version_id;
    NSString *welvu_app_version_txt;
    NSInteger welvu_app_version_sequence;
    BOOL welvu_app_db_changes;
    BOOL welvu_app_db_updated;
    BOOL welvu_app_version_active;
    NSDate *welvu_app_updated_on;
    NSString *welvu_app_identifier;
    
}
//Property for the objects
@property (nonatomic, readonly) NSInteger welvu_app_version_id;
@property (nonatomic, copy) NSString *welvu_app_version_txt;
@property (nonatomic, readwrite) NSInteger welvu_app_version_sequence;
@property (nonatomic, readwrite) BOOL welvu_app_db_changes;
@property (nonatomic, readwrite) BOOL welvu_app_db_updated;
@property (nonatomic, readwrite) BOOL welvu_app_version_active;
@property (nonatomic, copy) NSDate *welvu_app_updated_on;
@property (nonatomic, copy) NSString *welvu_app_identifier;

+ (NSString *)checkCurrentVersion:(NSString *)dbPath;
+ (BOOL)updatedCurrentVersion:(NSString *)dbPath:(welvu_app_version *)welvu_app_versionModel;
/*+(BOOL) createWelvuContentTagTable:(NSString *)dbPath;
 +(BOOL) updateSpecialtyName:(NSString *)dbPath;
 +(BOOL) updateVideoContentVU:(NSString *)dbPath;
 +(BOOL) updateVideoContentVUForHeartFailure:(NSString *)dbPath;
 +(BOOL) updateContentVUForWelvu:(NSString *)dbPath;
 +(BOOL) updateContentVUForWelvu5_3:(NSString *)dbPath;
 +(BOOL) updateContentVUForWelvu5_4:(NSString *)dbPath;
 +(BOOL) updateContentVUForWelvu5_5:(NSString *)dbPath;
 +(BOOL) createWelvuUserTable:(NSString *)dbPath;*/
+ (BOOL)alterTablesForGUID:(NSString *)dbPath;
+ (BOOL)createWelVUVideoQueue:(NSString *)dbPath;
+ (BOOL)userManagementUpdate:(NSString *)dbPath;
+(BOOL) welvuUserAndContentsModification:(NSString *) dbPath;
+(BOOL) welvuOrganizationTableUpdates:(NSString *) dbPath;
+(BOOL) insertDontShowForiPX:(NSString *) dbPath;
+ (welvu_app_version *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_app_version *)welvu_app_version_model;
+(BOOL) userorgStatusUpdate:(NSString *) dbPath;
+(BOOL) alterTableForTopicListOrder:(NSString *) dbPath;

//welvu 2.1
+(BOOL) welvuIpxImagesTableUpdates:(NSString *) dbPath;
+(BOOL) welvuConfigurationCreateTable:(NSString *) dbPath;
+(BOOL) welvuOauthCreateTable:(NSString *) dbPath;
+(BOOL) welvuPinCreateTable:(NSString *) dbPath;
+(BOOL) alterUserTableForOauth:(NSString *) dbPath;
@end
