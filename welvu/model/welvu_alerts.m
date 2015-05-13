//
//  welvu_alerts.m
//  welvu
//
//  Created by Logesh Kumaraguru on 26/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_alerts.h"
#import "welvuContants.h"

@implementation welvu_alerts
@synthesize welvu_alert_id, welvu_alert_text, welvu_dont_show;

static sqlite3 *database = nil;
/*
 * Method name: initWithAlertsId
 * Description: alerts ID
 * Parameters: NSInteger
 * Return Type: id
 */

- (id)initWithAlertsId:(NSInteger)aId {
    self = [super init];
    if (self) {
        welvu_alert_id = aId;
    }
    return self;
}
/*
 * Method name: updateAlertConfirmation
 * Description: updation on alert conformation
 * Parameters: NSString, NSString
 * Return Type: int
 */
+ (int)updateAlertConfirmation:(NSString *)dbPath:(NSString *)welvu_alertText {
    int update = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\" where %@=\"%@\"",
                         TABLE_WELVU_ALERTS,
                         COLUMN_WELVU_ALERT_DONT_SHOW, COLUMN_CONSTANT_TRUE,
                         COLUMN_WELVU_ALERT_TEXT, welvu_alertText];
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
 * Method name: canAlertShowAgain
 * Description: redisplaying of alert
 * Parameters: NSString, NSString
 * Return Type: BOOL
 */
+ (BOOL)canAlertShowAgain:(NSString *)dbPath:(NSString *)welvu_alertText {
    BOOL canAlertShow = false;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where %@ == \"%@\"",
                         COLUMN_WELVU_ALERT_DONT_SHOW, TABLE_WELVU_ALERTS,
                         COLUMN_WELVU_ALERT_TEXT,welvu_alertText];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                              [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                              &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
				if ([[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)] isEqualToString:@"True"]) {
                    canAlertShow = TRUE;
                } else {
                    canAlertShow = FALSE;
                }
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    
    return canAlertShow;
}

/*
 * Method name: initWithStmt
 * Description: statments for alerts
 * Parameters: sqlite3_stmt
 * Return Type: welvu_alerts
 */
+ (welvu_alerts *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_alerts *)welvu_alertsModel {
    
    if (sqlite3_column_text(selectstmt, 1) != nil) {
        welvu_alertsModel.welvu_alert_text = [NSString stringWithUTF8String
                                              :(char *)sqlite3_column_text(selectstmt, 1)];
    }
    
    if ([[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 2)] isEqualToString:@"True"]) {
        welvu_alertsModel.welvu_dont_show = TRUE;
    } else {
        welvu_alertsModel.welvu_dont_show = FALSE;
    }
    
    return welvu_alertsModel;
}

@end
