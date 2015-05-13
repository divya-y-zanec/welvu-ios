//
//  welvu_specialty.h
//  welvu
//
//  Created by Logesh Kumaraguru on 01/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

/*
 * Class name: welvu_specialty
 * Description: Data model for specialty list
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_specialty : NSObject {
    NSInteger welvu_specialty_id;
    NSInteger welvu_user_id;
    NSString *welvu_specialty_name;
    NSString *welvu_specialty_info;
    BOOL welvu_specialty_default;
    BOOL welvu_specialty_subscribed;
    BOOL welvu_topic_synced;
    NSString *product_identifier;
    float version;
    NSDate *created_on;
    NSDate *last_updated;
    NSString *yearly_product_identifier;
    NSDate *subscriptionStartDate;
    NSDate *subscriptionEndDate;
    NSInteger welvu_platform_id;
    BOOL yearlySubscription;
}
//Property
@property (nonatomic, readonly) NSInteger welvu_specialty_id;
@property (nonatomic, readwrite) NSInteger welvu_user_id;
@property (nonatomic, copy) NSString *welvu_specialty_name;
@property (nonatomic, copy) NSString *welvu_specialty_info;
@property (nonatomic, readwrite) BOOL welvu_specialty_default;
@property (nonatomic, readwrite) BOOL welvu_specialty_subscribed;
@property (nonatomic, readwrite) BOOL welvu_topic_synced;
@property (nonatomic, copy) NSString *product_identifier;
@property (nonatomic, readwrite) float version;
@property (nonatomic, retain) NSDate *created_on;
@property (nonatomic, retain) NSDate *last_updated;
@property (nonatomic, copy) NSString *yearly_product_identifier;
@property (nonatomic, retain) NSDate *subscriptionStartDate;
@property (nonatomic, retain) NSDate *subscriptionEndDate;
@property (nonatomic, readwrite) NSInteger welvu_platform_id;
@property (nonatomic, readwrite) BOOL yearlySubscription;

//Methods
- (id)initWithSpecialtyId:(NSInteger)sId;
+ (NSInteger)getSpecialtyCount:(NSString *)dbPath userId:(NSInteger) user_id;
+ (NSMutableArray *)getAllSpecialtyWithoutUserId:(NSString *) dbPath;
+ (NSMutableArray *)getAllSpecialty:(NSString *) dbPath userId:(NSInteger) user_id;
+ (BOOL)addAllSpecialty:(NSString *)dbPath:(NSMutableArray *)welvu_specialtyArray;
+ (BOOL)updateAllSpecialty:(NSString *)dbPath specialtyModel:(welvu_specialty *)welvu_specialtyModel specialtyUpdate:(BOOL)updateOnly;
+ (BOOL)updateSyncedSpecialty:(NSString *)dbPath:(NSInteger)specialty_id userId:(NSInteger) user_id;
+ (welvu_specialty *)getSpecialtyById:(NSString *)dbPath specialtyId:(NSInteger)specialty_id  userId:(NSInteger) user_id ;
+ (NSString *)getSpecialtyNameById:(NSString *)dbPath:(NSInteger)specialty_id userId:(NSInteger) user_id;
+ (int)updateSubscribedSpecialty:(NSString *)dbPath specialtyId:(NSInteger)specialty_id
           subscriptionStartDate:(NSDate *)startDate subscriptionEndDate:(NSDate *)endDate
                          userId:(NSInteger) user_id;
+ (BOOL)deleteSpecialitiesByUserId:(NSString *)dbPath user_id: (NSInteger) userId;
+ (welvu_specialty *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_specialty *)welvu_specialtyModel;
+ (welvu_specialty *)getSpecialtymodel:(NSString *)dbPath:(NSInteger)specialty_id userId:(NSInteger) user_id;

@end
