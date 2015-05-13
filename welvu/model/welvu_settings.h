//
//  welvu_settings.h
//  welvu
//
//  Created by Logesh Kumaraguru on 12/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

/*
 * Class name: welvu_settings
 * Description: Data model for welvu settings
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_settings : NSObject {
    //Primary key
    NSInteger welvu_settingsId;
    NSInteger welvu_topic_list_order;
    NSInteger welvu_content_vu_spacing;
    NSInteger welvu_content_vu_style;
    BOOL welvu_content_vu_grid_layout;
    BOOL welvu_content_vu_grid_bg;
    //Audio/Video configuration
    NSInteger audio_video;
    //Frames persecond settings
    float fps;
    //Video resolution
    NSInteger videoQuality;
    //Video Quality compression settings
    NSInteger quality;
    //Email settings
    NSInteger securedSharing;
    //Subject pre text for sharing VU
    NSString *shareVUSubject;
    //Signature pre text for sharing VU
    NSString *shareVUSignature;
    NSString *phiShareVUSubject;
    NSString *phiShareVUSignature;
    NSInteger default_specialty_id;
    NSInteger welvu_blank_canvas_color;
    //Default settings
    BOOL isDefault;
    //Last active settings
    BOOL isActive;
    //Make permanent settings
    BOOL isMakePermanent;
    //JustNow settings
    BOOL isJustNow;
    //animation
    BOOL isAnimationOn;
    //vitals selection
    NSInteger weight;
    NSInteger height;
    NSInteger temperature;
    NSInteger bpsandbpd;
    NSInteger bmi;
    //theme
    NSInteger welvu_themeChange;
}
//Property of the objects
@property (nonatomic, readwrite) NSInteger welvu_themeChange;
@property (nonatomic, readonly) NSInteger welvu_settingsId;
//Settings for topic order and layout
@property (nonatomic, readwrite) NSInteger welvu_topic_list_order;
@property (nonatomic, readwrite) NSInteger welvu_content_vu_style;
@property (nonatomic, readwrite) NSInteger welvu_content_vu_spacing;
@property (nonatomic, readwrite) BOOL welvu_content_vu_grid_layout;
@property (nonatomic, readwrite) BOOL welvu_content_vu_grid_bg;
@property (nonatomic, readwrite) NSInteger audio_video;
@property (nonatomic, readwrite) float fps;
@property (nonatomic, readwrite) NSInteger quality;
@property (nonatomic, readwrite) NSInteger securedSharing;
@property (nonatomic, copy) NSString *shareVUSubject;
@property (nonatomic, copy) NSString *shareVUSignature;
@property (nonatomic, copy) NSString *phiShareVUSubject;
@property (nonatomic, copy) NSString *phiShareVUSignature;
@property (nonatomic, readwrite) NSInteger default_specialty_id;
@property (nonatomic, readwrite) NSInteger welvu_blank_canvas_color;
@property (nonatomic, readwrite)  NSInteger weight;
@property (nonatomic, readwrite) NSInteger height;
@property (nonatomic, readwrite)  NSInteger temperature;
@property (nonatomic, readwrite)  NSInteger bpsandbpd;
@property (nonatomic, readwrite)  NSInteger bmi;
@property (nonatomic, readwrite) BOOL isDefault;
@property (nonatomic, readwrite) BOOL isActive;
@property (nonatomic, readwrite) BOOL isMakePermanent;
@property (nonatomic, readwrite) BOOL isJustNow;
//Animation
@property(nonatomic,readwrite)  BOOL isAnimationOn;

//Methods
+ (int)updateCustomSettings:(NSString *)dbPath:(welvu_settings *)welvu_settingsModel;
+ (welvu_settings *)getActiveSettings:(NSString *)dbPath;
+ (welvu_settings *)restoreSettingsToDefault:(NSString *)dbPath;
+ (BOOL) logoutUserResetTable:(NSString *)dbPath;
- (id)initWithSettingsId:(NSInteger)settingsId;
+ (welvu_settings *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_settings *)welvu_settingsModel;

@end
