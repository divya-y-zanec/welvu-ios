//
//  welvuCacheData.m
//  welvu
//
//  Created by Divya Yadav. on 11/06/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_patient_Doc.h"
#import "PathHandler.h"
#import "welvuContants.h"

@implementation welvu_patient_Doc
static sqlite3 *database = nil;

/*
 * Method name: insertCacheData
 * Description: Insert patient data into database
 * Parameters: patientID ,path
 * Return Type: BOOL
 */

+(BOOL) insertCacheData:(NSString *)dbPath:(NSString *)patientID :(NSString *)path {
    
    BOOL cacheUpdated = false;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        
        
        NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:@"media_type"];
        
        
        sql = [NSString stringWithFormat:@"Insert into welvu_patient_Doc (patientID,patient_img_path,type)values(\'%@\',\'%@\',\'%@\')",patientID,path,type];
        
        
        if(sqlite3_exec(database,
                        [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
           SQLITE_OK) {
            cacheUpdated = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return cacheUpdated;
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
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        
        sql = @"delete from welvu_patient_Doc";
        
        if(sqlite3_exec(database,
                        [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
           SQLITE_OK) {
            deletedCacheData = true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return deletedCacheData;
}

/*
 * Method name: getPatientImages
 * Description: Get Patient Images from DB Path.
 * Parameters: dbPath
 * Return Type: Pateint Images (NSMutableArray)
 */
+(NSMutableArray *)getPatientImages:(NSString *)dbPath {
    
    NSMutableArray *patientImages= nil;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =[NSString stringWithFormat:@"select * from welvu_patient_Doc"];
        
        
        //  NSLog(@"sql = %@",sql);
        sqlite3_stmt *selectstmt;
        if(sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                if(patientImages == nil) {
                    patientImages = [[NSMutableArray alloc] init];
                }
                NSInteger imageCount = [self GetArticlesCount:dbPath];
                [patientImages addObject:[welvu_patient_Doc initWithStatementOfTypeWelVUImage:selectstmt]];
            }
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return patientImages;
    //  NSLog(@"patientImages %@",patientImages);
    
}

/*
 * Method name: initWithStatementOfTypeWelVUImage
 * Description: statments for alerts
 * Parameters: sqlite3_stmt
 * Return Type: welvu_alerts
 */
+(welvu_images *)initWithStatementOfTypeWelVUImage:(sqlite3_stmt *)selectstmt {
    welvuAppDelegate *appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    welvu_images *welvu_imagesModel = [[welvu_images alloc] initWithImageId:sqlite3_column_int(selectstmt,0)];
    welvu_imagesModel.patientImageID = sqlite3_column_int(selectstmt,0);
    welvu_imagesModel.welvu_user_id = appDelegate.welvu_userModel.welvu_user_id;
    
    
    
    if(sqlite3_column_text(selectstmt, 2) != nil) {
        welvu_imagesModel.url = [NSString stringWithUTF8String
                                 :(char *)sqlite3_column_text(selectstmt, 2)];
        // welvu_imagesModel.url = [PathHandler getCacheDirPathForFile:[NSString stringWithUTF8String
        // :(char *)sqlite3_column_text(selectstmt, 2)]];
    }
    
    
    /* if (sqlite3_column_text(selectstmt, 2) != nil) {
     if(![welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE]) {
     
     welvu_imagesModel.url = [PathHandler getCacheDirPathForFile:[NSString stringWithUTF8String
     :(char *)sqlite3_column_text(selectstmt, 2)]];
     } else {
     welvu_imagesModel.url = [NSString stringWithUTF8String
     :(char *)sqlite3_column_text(selectstmt, 2)];
     }
     }
     
     */
    
    
    
    if(sqlite3_column_text(selectstmt, 3) != nil) {
        welvu_imagesModel.type = [NSString stringWithUTF8String
                                  :(char *)sqlite3_column_text(selectstmt, 3)];
    }
    //welvu_imagesModel.type = VIDEO_PATIENT_TYPE;
    
    if ([welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE]) {
        welvu_imagesModel.type = IMAGE_PATIENT_TYPE;
    }
    else if ([welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_TYPE]){
        welvu_imagesModel.type = VIDEO_PATIENT_TYPE;
    }
    
    // welvu_imagesModel.selected = NO;
    return welvu_imagesModel;
}

/*
 * Method name: GetArticlesCount
 * Description: Count the number of patient records in db.
 * Parameters: NSString (dbpath)
 * Return Type: NSInteger
 */
+(NSInteger) GetArticlesCount:(NSString *)dbPath {
    NSInteger count = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM welvu_patient_Doc"];
        sqlite3_stmt *selectstmt;
        
        if( sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK)
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(selectstmt) == SQLITE_ROW )
            {
                count = sqlite3_column_int(selectstmt, 0);
            }
        }
        else
        {
        }
        
        // Finalize and close database.
        sqlite3_finalize(selectstmt);
        sqlite3_close(database);
    }
    
    return count;
}
@end
