//
//  welvuCacheData.h
//  welvu
//
//  Created by Divya Yadav. on 11/06/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "welvu_images.h"

/*
 * Class name: welvu_patient_Doc
 * Description: insert,delete,get Patient Doc  from db
 * Extends: NSObject
 * Delegate : nil
 */
@interface welvu_patient_Doc: NSObject {
    //detail about image path
    NSString *imagePath;
}
//Property
@property (nonatomic, retain) NSString *imagePath;
//Methods
+(BOOL) insertCacheData:(NSString *)dbPath:(NSInteger)patientID :(NSString *)path;
+(BOOL) deleteCacheData:(NSString *)dbPath;
+(NSMutableArray *)getPatientImages:(NSString *)dbPath;
+(NSInteger) GetArticlesCount:(NSString *)dbPath;
+(welvu_images *)initWithStatementOfTypeWelVUImage:(sqlite3_stmt *)selectstmt
                                                  :(welvu_patient_Doc *)welvu_patient_Model;

@end
