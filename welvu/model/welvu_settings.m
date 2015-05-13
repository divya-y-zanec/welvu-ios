NSInteger tempDataSettings;
//
//  welvu_settings.m
//  welvu
//
//  Created by Logesh Kumaraguru on 12/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_settings.h"
#import "welvuContants.h"

@implementation welvu_settings
@synthesize welvu_settingsId;
@synthesize welvu_topic_list_order, welvu_content_vu_spacing, welvu_content_vu_style, welvu_content_vu_grid_layout,
welvu_content_vu_grid_bg;
@synthesize audio_video, fps, quality, securedSharing, shareVUSubject, shareVUSignature,
phiShareVUSubject, phiShareVUSignature, isActive, isDefault, isMakePermanent, isJustNow;

@synthesize default_specialty_id;
@synthesize welvu_blank_canvas_color,isAnimationOn ;
@synthesize weight,height,temperature,bmi,bpsandbpd ,welvu_themeChange;
//Theme

static sqlite3 *database = nil;

/*
 * Method name: initWithSettingsId
 * Description: Intialize the model with welvu_settingsId
 * Parameters: NSInteger
 * Return Type: self
 */

- (id)initWithSettingsId:(NSInteger) settingsId {
    
    self = [super init];
    if (self) {
        welvu_settingsId = settingsId;
    }
    return self;
}

/*
 * Method name: updateCustomSettings
 * Description: Update the custom settings with new configuration
 * Parameters: NSString
 * Return Type: int
 */
+ (int)updateCustomSettings:(NSString *)dbPath:(welvu_settings *)welvu_settingsModel {
    int update = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *shareVUSub = (welvu_settingsModel.shareVUSubject.length > 0) ?
        welvu_settingsModel.shareVUSubject:@"";
        NSString *shareVUSig = (welvu_settingsModel.shareVUSignature.length > 0) ?
        welvu_settingsModel.shareVUSignature:@"";
        NSString *phiShareVUSub = (welvu_settingsModel.phiShareVUSubject.length > 0) ?
        welvu_settingsModel.phiShareVUSubject:@"";
        NSString *phiShareVUSig = (welvu_settingsModel.phiShareVUSignature.length > 0) ?
        welvu_settingsModel.phiShareVUSignature:@"";
        
        NSString *sql =
        [NSString stringWithFormat:
         @"Update %@ set %@=%d, %@=%d, %@=%d, %@=%d, %@=%d, %@=%d, %@=%f, %@=%d, %@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\",%@=\"%@\", %@=%d, %@=%d , %@=%d ,%@=%d ,%@=%d ,%@=%d,%@=%d ,%@=%d where %@=%d",
         TABLE_WELVU_VIDEO_SETTINGS,
         COLUMN_TOPIC_LIST_ORDER, welvu_settingsModel.welvu_topic_list_order,
         COLUMN_WELVU_CONTENT_VU_SPACING, welvu_settingsModel.welvu_content_vu_spacing,
         COLUMN_WELVU_CONTENT_VU_STYLE, welvu_settingsModel.welvu_content_vu_style,
         COLUMN_WELVU_CONTENT_VU_LAYOUT_GRID, welvu_settingsModel.welvu_content_vu_grid_layout,
         COLUMN_WELVU_CONTENT_VU_GRID_BG, welvu_settingsModel.welvu_content_vu_grid_bg,
         COLUMN_AUDIO_VIDEO, welvu_settingsModel.audio_video,
         COLUMN_FPS, welvu_settingsModel.fps,
         COLUMN_QUALITY, 0,
         COLUMN_SHAREVU_SUBJECT, shareVUSub,
         COLUMN_SHAREVU_SIGNATURE, shareVUSig,
         COLUMN_PHI_SHAREVU_SUBJECT, phiShareVUSub,
         COLUMN_PHI_SHAREVU_SIGNATURE, phiShareVUSig,
         COLUMN_IS_ACTIVE, COLUMN_CONSTANT_TRUE,
         COLUMN_BLANK_CANVAS_COLOR, welvu_settingsModel.welvu_blank_canvas_color,
         COLUMN_SECURED_SHARING, welvu_settingsModel.securedSharing,COLUMN_WEIGHT,welvu_settingsModel.weight,COLUMN_Height,welvu_settingsModel.height,COLUMN_TEMPERATURE,welvu_settingsModel.temperature,COLUMN_BPSANDBPD,welvu_settingsModel.bpsandbpd,COLUMN_BMI,welvu_settingsModel.bmi,COLUMN_SETTINGS_THEME_CHANGE,welvu_settingsModel.welvu_themeChange,
         COLUMN_SETTINGS_ID, 2];
        
        // NSLog(@"sql %@",sql);
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            update = 1;
            sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\" where %@=%d",
                   TABLE_WELVU_VIDEO_SETTINGS,
                   COLUMN_IS_ACTIVE, COLUMN_CONSTANT_FALSE,
                   COLUMN_SETTINGS_ID, 1];
            // NSLog(@"sql %@",sql);
            if(sqlite3_exec(database,
                            [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
               SQLITE_OK) {
                
                update = 1;
            }
        };
        sqlite3_close(database);
        database = nil;
    }
    return update;
}

/*
 * Method name: getActiveSettings
 * Description: Get Last active settings
 * Parameters: NSString
 * Return Type: welvu_settings
 */
+ (welvu_settings *)getActiveSettings:(NSString *)dbPath {
    welvu_settings *welvu_settingsModel = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ == \"%@\"",
                         TABLE_WELVU_VIDEO_SETTINGS,COLUMN_IS_ACTIVE, COLUMN_CONSTANT_TRUE];
        //  NSLog(@"sql %@",sql);
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
				welvu_settingsModel = [[welvu_settings alloc] initWithSettingsId:sqlite3_column_int(selectstmt, 0)];
                welvu_settingsModel = [self initWithStmt:selectstmt:welvu_settingsModel];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                
                if ([defaults  boolForKey:@"guideAnimationOn"]){
                    welvu_settingsModel.isAnimationOn=TRUE;
                    
                    //    NSLog(@"animation on");
                }
                else{
                    welvu_settingsModel.isAnimationOn=FALSE;
                    // NSLog(@"animation off");
                    
                }
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return welvu_settingsModel;
}

/*
 * Method name: restoreSettingsToDefault
 * Description: Restore settings to default value
 * Parameters: NSString
 * Return Type: welvu_settings
 */
+ (welvu_settings *)restoreSettingsToDefault:(NSString *)dbPath {
    welvu_settings *welvu_settingsModel = nil;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\" where %@=%d",
                         TABLE_WELVU_VIDEO_SETTINGS,
                         COLUMN_IS_ACTIVE, COLUMN_CONSTANT_TRUE,
                         COLUMN_SETTINGS_ID, 1];
        //  NSLog(@"sql %@",sql);
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\" where %@=%d",
                   TABLE_WELVU_VIDEO_SETTINGS,
                   COLUMN_IS_ACTIVE, COLUMN_CONSTANT_FALSE,
                   COLUMN_SETTINGS_ID, 2];
            // NSLog(@"sql %@",sql);
            if (sqlite3_exec(database,
                             [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
                SQLITE_OK) {
                welvu_settingsModel = [self getActiveSettings:dbPath];
            }
        };
        sqlite3_close(database);
        database = nil;
    }
    return welvu_settingsModel;
}

/*
 * Method name: logoutUserResetTable
 * Description: Logout the use and Restore settings to default value
 * Parameters: NSString
 * Return Type: BOOL
 */

+ (BOOL) logoutUserResetTable:(NSString *)dbPath {
    BOOL resetCompleted = false;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@;delete from %@;",
                         TABLE_WELVU_IMAGES, TABLE_WELVU_TOPICS];
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			if (sqlite3_step(selectstmt) == SQLITE_ROW) {
				resetCompleted = true;
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    [self restoreSettingsToDefault:dbPath];
    return resetCompleted;
}

/*
 * Method name: initWithStmt
 * Description: Intializing the welvu_settings model object with db values
 * Parameters: sqlite3_stmt, welvu_settings
 * Return Type: welvu_settings
 */
+ (welvu_settings *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_settings *)welvu_settingsModel {
    
    welvu_settingsModel.welvu_topic_list_order = sqlite3_column_int(selectstmt, 1);
    welvu_settingsModel.welvu_content_vu_spacing = sqlite3_column_int(selectstmt, 2);
    welvu_settingsModel.welvu_content_vu_style = sqlite3_column_int(selectstmt, 3);
    
    if ([[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 4)] isEqualToString:COLUMN_CONSTANT_TRUE] ||
        sqlite3_column_int(selectstmt, 4) == 1) {
        welvu_settingsModel.welvu_content_vu_grid_layout = TRUE;
    } else {
        welvu_settingsModel.welvu_content_vu_grid_layout = FALSE;
    }
    
    if ([[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 5)] isEqualToString:COLUMN_CONSTANT_TRUE] ||
        sqlite3_column_int(selectstmt, 5) == 1) {
        welvu_settingsModel.welvu_content_vu_grid_bg = TRUE;
    } else {
        welvu_settingsModel.welvu_content_vu_grid_bg = FALSE;
    }
    
    welvu_settingsModel.audio_video = sqlite3_column_int(selectstmt, 6);
    welvu_settingsModel.fps = sqlite3_column_double(selectstmt, 7);
    welvu_settingsModel.quality = sqlite3_column_int(selectstmt, 8);
    
    
    if (sqlite3_column_text(selectstmt, 9) != nil
        && ![[NSString stringWithUTF8String
              :(char *)sqlite3_column_text(selectstmt, 9)] isEqualToString:@"NUL"]) {
        welvu_settingsModel.shareVUSubject = [NSString stringWithUTF8String
                                              :(char *)sqlite3_column_text(selectstmt, 9)];
    }
    
    if (sqlite3_column_text(selectstmt, 10) != nil
        && ![[NSString stringWithUTF8String
              :(char *)sqlite3_column_text(selectstmt, 10)] isEqualToString:@"NUL"]) {
        welvu_settingsModel.shareVUSignature = [NSString stringWithUTF8String
                                                :(char *)sqlite3_column_text(selectstmt, 10)];
    }
    
    if (sqlite3_column_text(selectstmt, 11) != nil
        && ![[NSString stringWithUTF8String
              :(char *)sqlite3_column_text(selectstmt, 11)] isEqualToString:@"NUL"]) {
        welvu_settingsModel.phiShareVUSubject = [NSString stringWithUTF8String
                                                 :(char *)sqlite3_column_text(selectstmt, 11)];
    }
    
    if (sqlite3_column_text(selectstmt, 12) != nil
        && ![[NSString stringWithUTF8String
              :(char *)sqlite3_column_text(selectstmt, 12)] isEqualToString:@"NUL"]) {
        welvu_settingsModel.phiShareVUSignature = [NSString stringWithUTF8String
                                                   :(char *)sqlite3_column_text(selectstmt, 12)];
    }
    welvu_settingsModel.default_specialty_id =  sqlite3_column_int(selectstmt, 12);
    
    if ([[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 14)] isEqualToString:COLUMN_CONSTANT_TRUE] ||
        sqlite3_column_int(selectstmt, 14) == 1) {
        welvu_settingsModel.isDefault = TRUE;
    } else {
        welvu_settingsModel.isDefault = FALSE;
    }
    
    if ([[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 15)] isEqualToString:COLUMN_CONSTANT_TRUE] ||
        sqlite3_column_int(selectstmt, 15) == 1) {
        welvu_settingsModel.isActive = TRUE;
    } else {
        welvu_settingsModel.isActive = FALSE;
    }
    
    welvu_settingsModel.welvu_blank_canvas_color = sqlite3_column_int(selectstmt, 16);
    
    welvu_settingsModel.securedSharing = sqlite3_column_int(selectstmt, 17);
    welvu_settingsModel.isJustNow = FALSE;
    welvu_settingsModel.isMakePermanent = TRUE;
    
    
    welvu_settingsModel.weight = sqlite3_column_int(selectstmt,18);
    
    welvu_settingsModel.height= sqlite3_column_int(selectstmt,19);
    welvu_settingsModel.temperature = sqlite3_column_int(selectstmt,20);
    welvu_settingsModel.bpsandbpd = sqlite3_column_int(selectstmt,21);
    welvu_settingsModel.bmi = sqlite3_column_int(selectstmt,22);
    
    welvu_settingsModel.welvu_themeChange = sqlite3_column_int(selectstmt, 23);
    
    
    return welvu_settingsModel;
}

@end
