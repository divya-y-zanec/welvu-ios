//
//  welvu_alerts.h
//  welvu
//
//  Created by Logesh Kumaraguru on 26/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
/*
 * Class name: welvu_alerts
 * Description: Data model for alert settings and performs persistance logic
 * Extends: NSObject
 * Delegate : nil
 */
@interface welvu_alerts : NSObject {
    NSInteger welvu_alert_id;
    NSString *welvu_alert_text;
    BOOL welvu_dont_show;
}
//Property for the objects
@property (nonatomic, readonly) NSInteger welvu_alert_id;
@property (nonatomic, copy) NSString *welvu_alert_text;
@property (nonatomic, readwrite) BOOL welvu_dont_show;

//Methods
- (id)initWithAlertsId:(NSInteger)aId;
+ (int)updateAlertConfirmation:(NSString *)dbPath:(NSString *)welvu_alertText;
+ (BOOL)canAlertShowAgain:(NSString *)dbPath:(NSString *)welvu_alertText;
+ (welvu_alerts *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_alerts *)welvu_alertsModel;
@end
