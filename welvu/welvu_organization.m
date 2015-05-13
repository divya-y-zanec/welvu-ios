//
//  welvu_organization.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 23/01/14.
//  Copyright (c) 2014 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_organization.h"
#import "welvuAppDelegate.h"
#import "welvuContants.h"
#import "PathHandler.h"
static sqlite3 *database = nil;


@implementation welvu_organization
@synthesize orgId,orgLogoName,orgName ,product_Type,org_Status;

/*
 * Method name: initWithOrgId
 * Description: Intializing with Organization id
 * Parameters: org_Id
 * Return Type: self
 */

- (id)initWithOrgId:(NSInteger) org_Id {
    self=[super init];
    if (self) {
        orgId = org_Id;
    }
    return self;
}

/*
 * Method name: addOrganizationUser
 * Description: Insert the user Organization details
 * Parameters: dbPath ,welvu_organizationModel
 * Return Type: BOOL
 */
+ (BOOL)addOrganizationUser:(NSString *)dbPath:(welvu_organization *)welvu_organizationModel {
    
    
    BOOL inserted = false;
    char *error = nil;
    NSString *sql =nil;
    
    sql = [NSString stringWithFormat: @"INSERT into %@ (%@, %@, %@ ,%@ ,%@) VALUES (\"%d\", \"%@\",\"%@\" ,\"%@\" ,\"%@\")",
           TABLE_WELVU_ORGANIZATION, COLUMN_ORG_ID, COLUMN_ORG_NAME, COLUMN_ORG_LOGO_NAME,COLUMN_ORG_PRODUCT_TYPE ,COLUMN_ORG_Status ,
           welvu_organizationModel.orgId, welvu_organizationModel.orgName,
           welvu_organizationModel.orgLogoName ,welvu_organizationModel.product_Type ,welvu_organizationModel.org_Status];
    
    
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

+ (BOOL)updateOrganizationDetails:(NSString *)dbPath:(welvu_organization *)welvu_organizationModel {
    BOOL inserted = false;
    char *error = nil;
    NSString *sql =nil;
    
    sql = [NSString stringWithFormat: @"Update %@ set %@=\"%@\",%@=\"%@\", %@=\"%@\" , %@=\"%@\" where %@=%d",
           TABLE_WELVU_ORGANIZATION,
           COLUMN_ORG_NAME, welvu_organizationModel.orgName,
           COLUMN_ORG_LOGO_NAME, welvu_organizationModel.orgLogoName,
           COLUMN_ORG_PRODUCT_TYPE, welvu_organizationModel.product_Type,
           COLUMN_ORG_Status, welvu_organizationModel.org_Status,
           COLUMN_ORG_ID, welvu_organizationModel.orgId
                       ];
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
 * Method name: getMaxInsertRowId
 * Description: To get Max  org Id from welvu organization
 * Parameters: dbPath
 * Return Type: NSInteger
 */
+ (NSInteger)getMaxInsertRowId:(NSString *)dbPath {
    
    NSInteger imageId = (LOCAL_IMAGE_CONTENT_ID_START_RANGE + 1);
    NSInteger max_number = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select max(%@) from %@",
                         COLUMN_ORG_ID, TABLE_WELVU_ORGANIZATION];
        
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

/*
 * Method name: getOrganizationDetails
 * Description: To get Organization details
 * Parameters: dbPath
 * Return Type: NSMutableArray
 */
+ (NSMutableArray *)getOrganizationDetails:(NSString *)dbPath {
    
    welvuAppDelegate* appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *organizationModel = nil;
    
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        
        NSString *sql = [NSString stringWithFormat:@"select org_Status from welvu_organization"];
        
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if (organizationModel == nil) {
                    organizationModel = [[NSMutableArray alloc] init];
                }
				welvu_organization *welvu_OrganizationModel = [[welvu_organization alloc] initWithOrgId:sqlite3_column_int(selectstmt, 0)];
                welvu_OrganizationModel = [self initWithStmt:selectstmt:welvu_OrganizationModel];
                [organizationModel addObject:welvu_OrganizationModel];
            }
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    
    return organizationModel;
}

/*
 * Method name: getOrganizationDetailsById
 * Description: To get Organization details by Org id
 * Parameters: dbPath ,orgId
 * Return Type: welvu_organization
 */
+ (welvu_organization *)getOrganizationDetailsById:(NSString *)dbPath orgId:(NSInteger) orgId {
    
    welvu_organization *organizationModel = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=%d", TABLE_WELVU_ORGANIZATION, COLUMN_ORG_ID, orgId];
         NSLog(@"getOrganizationDetailsById  %@",sql);
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			if (sqlite3_step(selectstmt) == SQLITE_ROW) {
                
				organizationModel = [[welvu_organization alloc] initWithOrgId:sqlite3_column_int(selectstmt, 0)];
                organizationModel = [self initWithStmt:selectstmt:organizationModel];
            }
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return organizationModel;
}
/*
 * Method name: initWithStmt
 * Description: statments for alerts
 * Parameters: sqlite3_stmt ,welvu_userModel
 * Return Type: welvu_user
 */


+ (welvu_organization *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_organization *)welvuOrganizationDetails {
    
    welvuAppDelegate * appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    welvuOrganizationDetails.orgId = sqlite3_column_int(selectstmt, 0);
    
    if (sqlite3_column_text(selectstmt, 1) != nil) {
        welvuOrganizationDetails.orgName = [NSString stringWithUTF8String
                                            :(char *)sqlite3_column_text(selectstmt, 1)];
    }
    
    
    if (sqlite3_column_text(selectstmt, 2) != nil) {
        /* welvuOrganizationDetails.orgLogoName = [NSString stringWithUTF8String
         :(char *)sqlite3_column_text(selectstmt,2 )];*/
        
        welvuOrganizationDetails.orgLogoName = [PathHandler getDocumentDirPathForFile:[NSString stringWithUTF8String
                                                                                       :(char *)sqlite3_column_text(selectstmt, 2)]];
        
    }
    
    if (sqlite3_column_text(selectstmt, 3) != nil) {
        welvuOrganizationDetails.product_Type = [NSString stringWithUTF8String
                                            :(char *)sqlite3_column_text(selectstmt, 3)];
    }
    if (sqlite3_column_text(selectstmt, 4) != nil) {
        welvuOrganizationDetails.org_Status = [NSString stringWithUTF8String
                                                 :(char *)sqlite3_column_text(selectstmt, 4)];
    }
    
    return welvuOrganizationDetails;
}

//NSString *sql = [NSString stringWithFormat:@"select org_Status from %@ where %@=%d", TABLE_WELVU_ORGANIZATION, COLUMN_ORG_ID, orgId];

+(NSString *)getOrganizationDetailsByOrgStatus :(NSString *)dbPath :(NSInteger)orgId{
    
    NSString *specialtyName=nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
       NSString *sql = [NSString stringWithFormat:@"select org_Status from %@ where %@=%d", TABLE_WELVU_ORGANIZATION, COLUMN_ORG_ID, orgId];
        
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

+(NSString *)getOrganizationNameById :(NSString *)dbPath :(NSInteger)orgId{
    
    NSString *orgName=nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select org_name from %@ where %@=%d", TABLE_WELVU_ORGANIZATION, COLUMN_ORG_ID, orgId];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                orgName = [NSString stringWithUTF8String
                                 :(char *)sqlite3_column_text(selectstmt, 0)];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return orgName;
    
}

/*
 * Method name: getOrganizationCount
 * Description: To Get the number of organization
 * Parameters: NSString
 * Return Type: id
 */

+ (NSInteger)getOrganizationCount:(NSString *)dbPath {
    NSInteger counteImage = 0;
    NSInteger statusCount = 1;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select count() from %@ where %@=%d", TABLE_WELVU_ORGANIZATION,
                         COLUMN_ORG_Status, statusCount];
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

/*
 * Method name: getOrganizationCountByUserId
 * Description: To Get the number of organization by user id
 * Parameters: NSString
 * Return Type: id
 */

+ (NSInteger)getOrganizationCountByUserId:(NSString *)dbPath {
    NSInteger counteImage = 0;
    NSInteger statusCount = 1;
    welvu_user *welvuUser = [[welvu_user alloc]init];
    welvuUser = [welvu_user getCurrentLoggedUser:dbPath];
    NSString *sql = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        sql = [NSString stringWithFormat:@"select count() from %@ where %@=%d and %@=%d ", TABLE_WELVU_ORGANIZATION,
                         COLUMN_ORG_Status, statusCount,
                         COLUMN_USER_PRIMARY_KEY,welvuUser.welvu_user_id];
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

+(NSString *)getOrganizationLogoNameById :(NSString *)dbPath :(NSInteger)orgId {
    NSString *orgName=nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select org_logo_name from %@ where %@=%d", TABLE_WELVU_ORGANIZATION, COLUMN_ORG_ID, orgId];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                orgName = [NSString stringWithUTF8String
                           :(char *)sqlite3_column_text(selectstmt, 0)];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return orgName;
    
}
@end
