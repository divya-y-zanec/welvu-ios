//
//  welvu_configuration.h
//  welvu
//
//  Created by Divya Yadav. on 03/09/14.
//  Copyright (c) 2014 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "welvuContants.h"
#import <sqlite3.h>
#import "welvuAppDelegate.h"

@interface welvu_configuration : NSObject{
    NSInteger welvu_configuration_id;
    NSInteger welvu_user_id;
    NSInteger orgId;
    NSString *welvu_configuration_adapter;
    NSString *welvu_configuration_key;
    NSString *welvu_configuration_value;
    
}
@property (nonatomic, readwrite) NSInteger welvu_configuration_id;
@property (nonatomic, readwrite) NSInteger welvu_user_id;
@property (nonatomic, readwrite) NSInteger orgId;
@property (nonatomic, retain) NSString *welvu_configuration_adapter;
@property (nonatomic, retain) NSString *welvu_configuration_key;
@property (nonatomic, retain) NSString *welvu_configuration_value;

+ (BOOL)addConfiguration:(NSString *)dbPath:(welvu_configuration *)welvu_configurationModel;
//+(welvu_configuration *)getYoutubeConfigurationForOrgId:(NSString *)dbPath:(NSInteger)orgId;
//+(welvu_configuration *)getBoxConfigurationForOrgId:(NSString *)dbPath:(NSInteger)orgId;
+(NSMutableArray *)getYoutubeConfigurationForOrgId:(NSString *)dbPath organizationId:(NSInteger)orgId adapterType:(NSString *)adapter;
+(BOOL) deleteCacheData:(NSString *)dbPath;
+(BOOL) updateOrgConfigDetails:(NSString *)dbPath:(welvu_configuration *)welvu_configurationModel ;
+(NSInteger) getConfigurationForInsertUpdate:(NSString *)dbPath :(welvu_configuration *)welvu_configurationModel;
@end
