//
//  welvu_ipx_images.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 25/10/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_ipx_images.h"
#import "welvuAppDelegate.h"
#import "PathHandler.h"

static sqlite3 *database = nil;
@implementation welvu_ipx_images
@synthesize iPx_images_id;
@synthesize  ipx_Specilaty_id;
@synthesize  ipx_image_display_name;
@synthesize  order_number;
@synthesize  ipx_img_type;
@synthesize  platform_video_url;
@synthesize  ipx_image_info;
@synthesize  ipx_image_active;
@synthesize  ipx_image_thumbnail;
@synthesize  version;
@synthesize  created_on;
@synthesize  last_updated;
@synthesize  is_locked;
@synthesize  image_guid;
@synthesize  organization_id;
@synthesize  platform_image_id;
@synthesize  pickedToView;
@synthesize  selected,ipx_VideoUrl,ipx_Org_VideoDetails,ipx_VideoIds;

/*
 * Method name: initWithImageId
 * Description: Intialize the welvu_ipx_images model with imageId
 * Parameters: NSString
 * Return Type: imgId
 */

- (id)initWithImageId:(NSInteger)imgId {
    self = [super init];
    if (self) {
        iPx_images_id = imgId;
    }
    return self;
    
}

-(id)init {
    selected = YES;
}

/*
 * Method name: initWithImageObject
 * Description: initilizing the image object
 * Parameters:welvu_ipxModels for the iPx
 * Return Type: id
 */

- (id)initWithImageObject:(welvu_ipx_images *) welvu_ipxModels{
    self = [super init];
    if (self) {
        
        iPx_images_id = welvu_ipxModels.iPx_images_id;
        ipx_Specilaty_id = welvu_ipxModels.ipx_Specilaty_id;
        ipx_image_display_name = welvu_ipxModels.ipx_image_display_name;
        order_number = welvu_ipxModels.order_number;
        ipx_img_type = welvu_ipxModels.ipx_img_type;
        platform_video_url = welvu_ipxModels.platform_video_url;
        ipx_image_info = welvu_ipxModels.ipx_image_info;
        ipx_image_active =  welvu_ipxModels.ipx_image_active;
        ipx_image_thumbnail = welvu_ipxModels.ipx_image_thumbnail;
        version = welvu_ipxModels.version;
        created_on = welvu_ipxModels.created_on;
        last_updated = welvu_ipxModels.last_updated;
        image_guid = welvu_ipxModels.image_guid;
        organization_id = welvu_ipxModels.organization_id;
        platform_image_id = welvu_ipxModels.platform_image_id;
        pickedToView = welvu_ipxModels.pickedToView;
        selected = welvu_ipxModels.selected;
        ipx_VideoUrl = welvu_ipxModels.ipx_VideoUrl;
        ipx_Org_VideoDetails = welvu_ipxModels.ipx_Org_VideoDetails;
        ipx_VideoIds = welvu_ipxModels.ipx_VideoIds;
       
    }
    return self;
    
}





+ (BOOL)addIpxImageFromPlatform:(NSString *)dbPath:(welvu_ipx_images *)welvuipxImages:(NSString *)type {
    BOOL inserted = false;
    char *error = nil;
    NSLog(@"welvuipxImages %@", welvuipxImages);
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        sql = [NSString stringWithFormat: @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@) VALUES (%d, %d, \"%@\", \"%@\", \"%@\",\"%@\", \"%@\", \"%@\")",
               TABLE_WELVU_IPX_IMG, COLUMN_IPXIMG_id, COLUMN_IPXSPECIALTY_ID, COLUMN_IPXIMG_TYPE, COLUMN_IPXIMG_URL, COLUMN_IPXIMG_THUMBNAIL,COLUMN_IPXIMG_ORGID, COLUMN_IPXIMG_PLATFROMID,COLUMN_IPXIMG_DISPLAY_NAME, welvuipxImages.iPx_images_id ,welvuipxImages.ipx_Specilaty_id, type ,welvuipxImages.platform_video_url,welvuipxImages.ipx_image_thumbnail,welvuipxImages.organization_id,welvuipxImages.platform_image_id, welvuipxImages.ipx_image_display_name];
        NSLog(@"sql %@", sql);
        
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            inserted = true;
            
        };
        sqlite3_close(database);
        database = nil;
    }
    return inserted;
}

/*
 * Method name: initWithStmt
 * Description: Intializing the welvu_images model object with db values
 * Parameters: sqlite3_stmt, welvu_images
 * Return Type: welvu_images
 */
+ (welvu_ipx_images *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_ipx_images *)welvuipxImages {
    
    
    welvuipxImages.iPx_images_id = sqlite3_column_int(selectstmt, 0);
    
    welvuipxImages.ipx_Specilaty_id = sqlite3_column_int(selectstmt, 1);
    
    if (sqlite3_column_text(selectstmt, 2) != nil) {
        welvuipxImages.ipx_image_display_name = [NSString stringWithUTF8String
                                       :(char *)sqlite3_column_text(selectstmt, 2)];
    }
    

    
    if (sqlite3_column_text(selectstmt, 4) != nil) {
        welvuipxImages.ipx_img_type = [NSString stringWithUTF8String
                                              :(char *)sqlite3_column_text(selectstmt, 4)];
    }
    
    
    if (sqlite3_column_text(selectstmt, 5) != nil) {
        welvuipxImages.platform_video_url = [NSString stringWithUTF8String
                                  :(char *)sqlite3_column_text(selectstmt, 5)];
       welvuipxImages.platform_video_url =  [NSString stringWithUTF8String
                                                                        :(char *)sqlite3_column_text(selectstmt, 5)];
        welvuipxImages.ipx_VideoUrl =  [NSString stringWithUTF8String
                                        :(char *)sqlite3_column_text(selectstmt, 5)];
         NSLog(@"platform_video_url %@",welvuipxImages.platform_video_url);
       
    }
    
    if (sqlite3_column_text(selectstmt, 6) != nil) {
        welvuipxImages.ipx_image_info = [NSString stringWithUTF8String
                                             :(char *)sqlite3_column_text(selectstmt, 6)];
    }
    
    
    if (sqlite3_column_text(selectstmt, 8) != nil) {
        welvuipxImages.ipx_image_thumbnail = [NSString stringWithUTF8String
                                       :(char *)sqlite3_column_text(selectstmt, 8)];
        
    }
    
    
    if (sqlite3_column_text(selectstmt, 14) != nil) {
        welvuipxImages.organization_id = [NSString stringWithUTF8String
                                        :(char *)sqlite3_column_text(selectstmt, 14)];
    }
    if (sqlite3_column_text(selectstmt, 15) != nil) {
        welvuipxImages.platform_image_id = [NSString stringWithUTF8String
                                             :(char *)sqlite3_column_text(selectstmt, 15)];
    }
    
    NSLog(@"platform_video_url %@",welvuipxImages.platform_video_url);
    return welvuipxImages;
}

+ (NSMutableArray *)getImagesIdBySpecialtyId:(NSString *)dbPath:(NSInteger)specialtyId  type:(NSString *) type{
    NSMutableArray *welvuIpxImagesArray = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ == \"%@\" and %@ == %d",
                         TABLE_WELVU_IPX_IMG, COLUMN_IPXIMG_TYPE,
                         type, COLUMN_IPXSPECIALTY_ID, specialtyId];
         NSLog(@"sql %@", sql);
        
        sqlite3_stmt *selectstmt;
        if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if (welvuIpxImagesArray == nil) {
                    welvuIpxImagesArray = [[NSMutableArray alloc] init];
                }
                welvu_ipx_images *welvuipximages = [[welvu_ipx_images alloc] initWithImageId:sqlite3_column_int(selectstmt, 0)];
                welvuipximages = [self initWithStmt:selectstmt:welvuipximages];
               NSLog(@"welvuipximages.url %@", welvuipximages.platform_video_url);
                
                [welvuIpxImagesArray addObject:welvuipximages];
                //[welvu_imagesModel release];
            }
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    NSLog(@"welvuIpxImagesArray %@", welvuIpxImagesArray);
    return welvuIpxImagesArray;
}

/*
 * Method name: getLastInsertRowId
 * Description: last inserted row ID
 * Parameters: NSString, NSInteger
 * Return Type: NSInteger
 */
+ (NSInteger)getLastInsertRowId:(NSString *)dbPath {
    NSInteger imageId = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select max(iPx_images_id) from %@",
                         TABLE_WELVU_IPX_IMG];
         NSLog(@" imageId %@", sql);
        
        sqlite3_stmt *selectstmt;
        if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                imageId = sqlite3_column_int(selectstmt, 0);
            }
            sqlite3_finalize(selectstmt);
        }
        sqlite3_close(database);
        database = nil;
    }
    NSLog(@" imageId %d", imageId);
    return imageId;
}


@end
