//
//  welvu_contenttag.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 08/11/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_contenttag.h"

@interface welvu_contenttag ()

@end

@implementation welvu_contenttag
static sqlite3 *database = nil;

@synthesize welvu_contentid,welvu_tagnames;

/*
 * Method name: updatecontenttag
 * Description: Update the content tag for the video
 * Parameters: dbPath ,welvu_contentid ,welvu_tagnames
 * Return Type: Bool
 */
+ (BOOL)updatecontenttag:(NSString *)dbPath:(NSInteger)welvu_contentid:(NSMutableArray*) welvu_tagnames {
    NSString *sql =nil;
    int update = 0;
    char *error = nil;
    NSMutableString *tagname=[[NSMutableString alloc]init ];
    for (int i=0; i<welvu_tagnames.count; i++) {
        NSString *temp =[[welvu_tagnames objectAtIndex:i]stringByAppendingString:@"," ];
        // NSString *temp=[welvu_tagnames objectAtIndex:i];
        [tagname appendString:temp];
        
    }
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        sql=[NSString stringWithFormat:@"UPDATE welvu_contenttag SET welvu_tagnames = '%@' WHERE welvu_contentid =%d",tagname,welvu_contentid];
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
 * Method name: insertcontenttag
 * Description: insert the content tag for the video
 * Parameters: dbPath ,welvu_contentid ,welvu_tagnames
 * Return Type: Bool
 */

+ (BOOL)insertcontenttag:(NSString *)dbPath:(NSInteger)welvu_contentid:(NSMutableArray*) welvu_tagnames {
   NSMutableString *tagname=[[NSMutableString alloc] init ];
    
    
	for (int i=0; i< welvu_tagnames.count; i++) {
        NSString *temp = nil;
        if (i > 0) {
            temp = [@"," stringByAppendingString:[welvu_tagnames objectAtIndex:i]];
        } else {
            temp = [welvu_tagnames objectAtIndex:i];
        }
        
        
        [tagname appendString:temp];
        
    }
    
    BOOL tagnameinserted = false;
    char *error = nil;
    NSString *sql =nil;
    
    if (![welvu_contenttag reterievetagname:dbPath :welvu_contentid]) {
        sql = [NSString stringWithFormat: @"INSERT into welvu_contenttag (welvu_contentid, welvu_tagnames) VALUES (\"%d\", \"%@\")",welvu_contentid, tagname];
        
    }
    
    else {
        sql=[NSString stringWithFormat:@"UPDATE welvu_contenttag SET welvu_tagnames = '%@' WHERE welvu_contentid =%d",tagname,welvu_contentid];
        
    }
 
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        if (sqlite3_exec(database,
                        [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
           SQLITE_OK) {
            tagnameinserted=true;
        };
        sqlite3_close(database);
        database = nil;
    }
    return tagnameinserted;
}

/*
 * Method name: reterievetagname
 * Description: Reterieve the tag name for the video
 * Parameters: dbPath ,previousSelectedId
 * Return Type: Bool
 */
+ (BOOL)reterievetagname:(NSString *)dbPath:(NSInteger) previousSelectedId {
    
   // NSLog(@"previous id %d",previousSelectedId);
    //NSLog(welvu_tagnames);
    BOOL canAlertShow = false;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from welvu_contenttag where welvu_contentid ='%d'",previousSelectedId];
        
       
        sqlite3_stmt *selectstmt;
        if (sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
            while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                 canAlertShow = TRUE;
            }
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    
    return canAlertShow;
}

/*
 -(id)initwithtagid:(NSString*)welvu_tagnames1234; {
 [super init];
 tagname = welvu_tagnames1234;
 return self;
 }*/

- (id)initWithImageId:(NSString*) welvu_tagnames1{
    self = [super init];
    welvu_tagnames = welvu_tagnames1;
    return self;
}

/*
 * Method name: reterievetagnamefromdb
 * Description: Reterieve the tag name  DB
 * Parameters: dbPath ,welvu_contentid
 * Return Type: Bool
 */
+ (NSMutableString *) reterievetagnamefromdb:(NSString *)dbPath:(NSInteger)welvu_contentid
{
    NSString *contenttag123=nil;

    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from welvu_contenttag where welvu_contentid =%d",welvu_contentid];
        
       
        sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                
                // contenttag123 = [[welvu_contenttag alloc] initWithImageId:sqlite3_column_int(selectstmt, 0)];
                
                contenttag123 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(selectstmt, 1)];
                // welvuDetailViewController.sam=totalField;
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
  
    
    return contenttag123;
}

+ (BOOL)checkdatabase:(NSString *)dbPath:(NSInteger)previousSelectedId:(NSMutableArray*)welvu_tagnames {
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from welvu_contenttag  where welvu_contentid=%d",previousSelectedId];
      
        sqlite3_stmt *selectstmt;
        
        if (sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                
                NSString *contenttag123 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(selectstmt, 0)];
                
                if (contenttag123==nil){
                    [self insertcontenttag:dbPath :previousSelectedId :welvu_tagnames];
                    // BOOL createtag = [welvu_contenttag insertcontenttag:appDelegate.getDBPath :previousSelectedId :_toRecipients];
                }
                else
                {
                    [self updatecontenttag:dbPath :previousSelectedId :welvu_tagnames];
                    // BOOL updatetag=[welvu_contenttag updatecontenttag:appDelegate.getDBPath :previousSelectedId :_toRecipients];
                    
                }
            }
        }
        
    }
    return YES;
}

@end
