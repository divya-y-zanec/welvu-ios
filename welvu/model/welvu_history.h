//
//  welvu_vu_history.h
//  welvu
//
//  Created by Logesh Kumaraguru on 12/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "welvu_images.h"

/*
 * Class name: welvu_history
 * Description: Data model for last five patient vu content as History
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_history : NSObject  {
    
    //Declaring Integer values
    NSInteger welvu_vu_history_id;
    NSInteger specialty_id;
    NSInteger images_id;
    NSInteger history_number;
    NSDate *createdDate;
}
//Properties
@property (nonatomic, readonly) NSInteger welvu_vu_history_id;
@property (nonatomic, readwrite) NSInteger specialty_id;
@property (nonatomic, readwrite) NSInteger images_id;
@property (nonatomic, readwrite) NSInteger history_number;
@property (nonatomic, copy) NSDate *createdDate;
//Methods
- (id)initWithHistoryId:(NSInteger)hId;
+ (BOOL)isHistoryNumberExist:(NSString *)dbPath:(NSInteger)specialty_id:(NSInteger)history_number;
+ (NSMutableArray *)getHistoryByHistoryNumber:(NSString *)dbPath:(NSInteger)specialty_id:(NSInteger) history_number;
+ (welvu_history *)getFirstHistoryByHistoryNumber:(NSString *)dbPath:(NSInteger)specialty_id:(NSInteger) history_number;
+ (BOOL)createHistoryVU:(NSString *)dbPath:(NSInteger)specialty_id:(NSInteger)historyNumber:(NSInteger) image_id:(NSDate *)created_date;
+ (NSInteger)getMaxHistoryNumber:(NSString *)dbPath:(NSInteger)specialty_id;
+ (BOOL)deleteHistoryWithImageId:(NSString *)dbPath:(NSInteger)imageId;
+ (BOOL)deleteOldHistoryVU:(NSString *)dbPath:(NSInteger)specialty_id:(NSInteger)historyNumber;
+ (int)swapOldHistoryVU:(NSString *)dbPath:(NSInteger)specialty_id:(NSInteger)from:(NSInteger)to;
+ (welvu_history *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_history *)welvu_vu_historyModel;
@end
