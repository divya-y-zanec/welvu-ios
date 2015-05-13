//
//  welvu_organization.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 23/01/14.
//  Copyright (c) 2014 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "welvuAppDelegate.h"

/*
 * Class name: welvu_organization
 * Description: Data model for Welvu Organization
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_organization : NSObject {
    
    //dbValue
    NSInteger orgId;
    NSString *orgName;
    NSString *orgLogoName;
    NSString *product_Type;
    NSString * org_Status;
}
@property (nonatomic ,retain)  NSString * org_Status;
@property (nonatomic ,retain)  NSString *product_Type;
//Property of the objects
@property (nonatomic,retain)  NSString *orgName;
@property (nonatomic ,retain)  NSString *orgLogoName;
@property (nonatomic ,readwrite)  NSInteger orgId;

//Methods
- (id)initWithOrgId:(NSInteger) org_Id;
+ (BOOL)addOrganizationUser:(NSString *)dbPath:(welvu_organization *)welvu_organizationModel;
+ (BOOL)updateOrganizationDetails:(NSString *)dbPath:(welvu_organization *)welvu_organizationModel;
+ (welvu_organization *)initWithStmt:(sqlite3_stmt *)selectstmt
                                    :(welvu_organization *)welvuOrganizationDetails;
+ (NSMutableArray *)getOrganizationDetails:(NSString *)dbPath;
+ (welvu_organization *)getOrganizationDetailsById:(NSString *)dbPath orgId:(NSInteger) orgId;
+ (NSInteger)getMaxInsertRowId:(NSString *)dbPath;
+(NSString *)getOrganizationDetailsByOrgStatus :(NSString *)dbPath :(NSInteger)orgId;
+(NSString *)getOrganizationNameById :(NSString *)dbPath :(NSInteger)orgId;
+ (NSInteger)getOrganizationCount:(NSString *)dbPath;
+ (NSInteger)getOrganizationCountByUserId:(NSString *)dbPath ;
+(NSString *)getOrganizationLogoNameById :(NSString *)dbPath :(NSInteger)orgId;



@end
