//
//  welvu_ipx_images.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 25/10/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * Class name: welvu_ipx_images
 * Description: Data model for content of a iPx  and performs persistance logic
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_ipx_images : NSObject {
    
    NSInteger iPx_images_id;
    NSInteger ipx_Specilaty_id;
    NSString *ipx_image_display_name;
    NSInteger order_number;
    NSString *ipx_img_type;
    NSString *platform_video_url;
    NSString *ipx_image_info;
    NSString *ipx_image_active;
    NSString *ipx_image_thumbnail;
    NSString *version;
    NSString *created_on;
    NSString *last_updated;
    NSString *is_locked;
    NSString *image_guid;
    NSString *organization_id;
    NSString *platform_image_id;
    BOOL pickedToView;
    BOOL selected;
    NSString *ipx_VideoUrl; //db
    NSArray *ipx_Org_VideoDetails;
    NSString *ipx_VideoIds;

    
    
}
//Property for the objects
@property (nonatomic, readwrite) NSInteger iPx_images_id;
@property (nonatomic, readwrite) NSInteger ipx_Specilaty_id;
@property (nonatomic, retain) NSString *ipx_image_display_name;
@property (nonatomic, readwrite) NSInteger order_number;
@property (nonatomic, retain) NSString *ipx_img_type;
@property (nonatomic, retain) NSString *platform_video_url;
@property (nonatomic, retain) NSString *ipx_image_info;
@property (nonatomic, retain) NSString *ipx_image_active;
@property (nonatomic, retain) NSString *ipx_image_thumbnail;
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSString *created_on;
@property (nonatomic, retain) NSString *last_updated;
@property (nonatomic, retain) NSString *is_locked;
@property (nonatomic, retain) NSString *image_guid;
@property (nonatomic, retain) NSString *organization_id;
@property (nonatomic, retain) NSString *platform_image_id;
@property (nonatomic, retain) NSString *ipx_VideoUrl;
@property (nonatomic, retain) NSArray *ipx_Org_VideoDetails;
@property (nonatomic, retain) NSString *ipx_VideoIds;
@property (nonatomic, readwrite) BOOL pickedToView;
@property (nonatomic, readwrite) BOOL selected;
//Methods
- (id)initWithImageId:(NSInteger)imgId ;
- (id)initWithImageObject:(welvu_ipx_images *) welvu_ipxModels;
+ (BOOL)addIpxImageFromPlatform:(NSString *)dbPath:(welvu_ipx_images *)welvuipxImages:(NSString *)type;
+ (welvu_ipx_images *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_ipx_images *)welvuipxImages;
+ (NSMutableArray *)getImagesIdBySpecialtyId:(NSString *)dbPath:(NSInteger)specialtyId  type:(NSString *) type;
+ (NSInteger)getLastInsertRowId:(NSString *)dbPath;
@end
