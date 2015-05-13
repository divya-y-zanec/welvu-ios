//
//  welvu_image.m
//  welvu
//
//  Created by Logesh Kumaraguru on 05/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_images.h"
#import "welvuContants.h"
#import "PathHandler.h"
@implementation welvu_images

static sqlite3 *database = nil;

@synthesize imageId, topicId, imageDisplayName, orderNumber, selected;
@synthesize type, url, imageInfo, imageData,retainedAnnotatedImage, retainedAnnotatedImageUrl, pickedToView;
@synthesize welvu_user_id,patientImageID, image_active, image_thumbnail, is_synced, version, created_on, last_updated, is_locked, image_guid, welvu_platform_id;

@synthesize boxId, boxUrl;

/*
 * Method name: initWithImageId
 * Description: Intialize the welvu_images model with imageId
 * Parameters: NSInteger
 * Return Type: id
 */

- (id)initWithImageId:(NSInteger)imgId{
    self = [super init];
    if (self) {
        imageId = imgId;
    }
    return self;
}
/*
 * Method name: DefaultImagesOrderNumberByTopicId
 * Description: Default image order
 * Parameters: dbPath,topicId
 * Return Type: int
 */

+ (int)defaultImagesOrderNumberByTopicId:(NSString *)dbPath:(NSInteger)topicId:
(NSInteger)imagesId: (NSInteger)orderNumber {
    int update = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=%d where %@=%d and %@=%d",
                         TABLE_WELVU_IMAGES,
                         COLUMN_ORDER_NUMBER, orderNumber,
                         COLUMN_TOPIC_ID, topicId,
                         COLUMN_IMAGE_ID,imagesId];
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
 * Method name: initWithImageObject
 * Description: initilizing the image object
 * Parameters: dbPathwelvu_imageModeltopicId
 * Return Type: id
 */
- (id)initWithImageObject:(welvu_images *) welvu_imageModel{
    self = [super init];
    if (self) {
        imageId = welvu_imageModel.imageId;
        welvu_user_id = welvu_imageModel.welvu_user_id;
        topicId = welvu_imageModel.topicId;
        imageDisplayName = welvu_imageModel.imageDisplayName;
        orderNumber = welvu_imageModel.orderNumber;
        type = welvu_imageModel.type;
        url = welvu_imageModel.url;
        imageInfo = welvu_imageModel.imageInfo;
        image_active = welvu_imageModel.image_active;
        image_thumbnail = welvu_imageModel.image_thumbnail;
        is_synced = welvu_imageModel.is_synced;
        version = welvu_imageModel.version;
        created_on = welvu_imageModel.created_on;
        last_updated = welvu_imageModel.last_updated;
        is_locked = welvu_imageModel.is_locked;
        imageData = welvu_imageModel.imageData;
        retainedAnnotatedImage =  welvu_imageModel.retainedAnnotatedImage;
        retainedAnnotatedImageUrl = welvu_imageModel.retainedAnnotatedImageUrl;
        selected = welvu_imageModel.selected;
        //pickedToView =  welvu_imageModel.pickedToView;
        patientImageID= welvu_imageModel.patientImageID;
        //Box Images
        boxId = welvu_imageModel.boxId;
        boxUrl = welvu_imageModel.boxUrl;
        
    }
    return self;
    
}

/*
 * Method name: getMaxOrderNumber
 * Description: getting maximum order number
 * Parameters: NSString, NSInteger
 * Return Type: NSInteger
 */
+ (NSInteger)getMaxOrderNumber:(NSString *)dbPath:(NSInteger)topicId userId:(NSInteger) user_id {
    NSInteger max_number = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select max(order_number) from %@ where %@ = %d and %@ = \"%@\" and %@=%d",
                         TABLE_WELVU_IMAGES, COLUMN_TOPIC_ID, topicId,
                         COLUMN_IMAGE_ACTIVE, COLUMN_CONSTANT_TRUE,
                         COLUMN_USER_ID, user_id];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                max_number = sqlite3_column_int(selectstmt, 0);
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return max_number;
}

/*
 * Method name: getLastInsertRowId
 * Description: last inserted row ID
 * Parameters: NSString, NSInteger
 * Return Type: NSInteger
 */
+ (NSInteger)getMaxInsertRowIdForUserImages:(NSString *)dbPath userId:(NSInteger) user_id{
    
    /*NSInteger imageId = (LOCAL_IMAGE_CONTENT_ID_START_RANGE + 1);
     if ([[NSUserDefaults standardUserDefaults] integerForKey:@"USER_IMAGE_ID"]) {
     imageId = [[NSUserDefaults standardUserDefaults] integerForKey:@"USER_IMAGE_ID"];
     }
     [[NSUserDefaults standardUserDefaults] setInteger:(imageId + 1) forKey:@"USER_IMAGE_ID"];*/
    
    NSInteger imageId = (LOCAL_IMAGE_CONTENT_ID_START_RANGE + 1);
    NSInteger max_number = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select max(%@) from %@ where %@=%d and %@!=\"NUL\"",
                         COLUMN_IMAGE_ID, TABLE_WELVU_IMAGES, COLUMN_USER_ID, user_id, COLUMN_IMAGE_GUID];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                max_number = sqlite3_column_int(selectstmt, 0);
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    if(max_number > 0) {
        imageId = (max_number + 1);
    }
    
    return imageId;
}

/*
 * Method name: getImageById
 * Description: to get image id
 * Parameters: NSString
 * Return Type: welvu_images
 */
+ (welvu_images *)getImageById:(NSString *)dbPath:(NSInteger)image_id userId:(NSInteger) user_id {
    welvu_images *welvu_imagesModel = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=%d and %@=%d",TABLE_WELVU_IMAGES, COLUMN_IMAGE_ID,
                         image_id, COLUMN_USER_ID, user_id];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                
				welvu_imagesModel = [[welvu_images alloc] initWithImageId:sqlite3_column_int(selectstmt, 0)];
                welvu_imagesModel = [self initWithStmt:selectstmt:welvu_imagesModel];
                welvu_imagesModel.selected = YES;
            }
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return welvu_imagesModel;
}

/*
 * Method name: getImageByGuid
 * Description: to get image by Guid
 * Parameters: NSString
 * Return Type: welvu_images
 */
+ (welvu_images *)getImageByGuid:(NSString *)dbPath:(NSString *)image_guid {
    welvu_images *welvu_imagesModel = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=\"%@\"",TABLE_WELVU_IMAGES, COLUMN_IMAGE_GUID,
                         image_guid];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                
				welvu_imagesModel = [[welvu_images alloc] initWithImageId:sqlite3_column_int(selectstmt, 0)];
                welvu_imagesModel = [self initWithStmt:selectstmt:welvu_imagesModel];
                welvu_imagesModel.selected = YES;
            }
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return welvu_imagesModel;
    
}
/*
 * Method name: getImageByBoxPlatormId
 * Description: to get image by BoxId
 * Parameters: NSString ,double
 * Return Type: welvu_images
 */
+ (welvu_images *)getImageByBoxPlatormId:(NSString *)dbPath:(double )platformId user:(NSInteger) userId {
    welvu_images *welvu_imagesModel = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=%f and %@=%d",
                         TABLE_WELVU_IMAGES, COLUMN_PLATFORM_IMAGE_ID, platformId,
                         COLUMN_USER_ID, userId];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			if (sqlite3_step(selectstmt) == SQLITE_ROW) {
                
				welvu_imagesModel = [[welvu_images alloc] initWithImageId:sqlite3_column_int(selectstmt, 0)];
                welvu_imagesModel = [self initWithStmt:selectstmt:welvu_imagesModel];
                welvu_imagesModel.selected = YES;
            }
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return welvu_imagesModel;
    
}


/*
 * Method name: addNewImageToTopic
 * Description: adding image to new topic
 * Parameters: NSString
 * Return Type: NSInteger
 */
+ (NSInteger)addNewImageToTopic:(NSString *)dbPath:(welvu_images *)welvu_imagesModel:(NSInteger) topicId {
    welvuAppDelegate* appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    welvu_imagesModel.welvu_user_id = appDelegate.welvu_userModel.welvu_user_id;
    NSInteger row_id = [self getMaxInsertRowIdForUserImages:dbPath userId:appDelegate.welvu_userModel.welvu_user_id];
    NSInteger imageAddedId = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        if(welvu_imagesModel.welvu_platform_id > 0) {
            sql = [NSString stringWithFormat:
                   @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (%d, %d, \"%@\", %d, \"%@\", \"%@\",\"%@\", %d, \"%@\", %f)",
                   TABLE_WELVU_IMAGES, COLUMN_IMAGE_ID, COLUMN_TOPIC_ID, COLUMN_IMAGE_DISPLAY_NAME,
                   COLUMN_ORDER_NUMBER, COLUMN_TYPE, COLUMN_URL, COLUMN_IMAGE_ACTIVE, COLUMN_USER_ID, COLUMN_IMAGE_GUID, COLUMN_PLATFORM_IMAGE_ID, row_id,
                   topicId, welvu_imagesModel.imageDisplayName,
                   welvu_imagesModel.orderNumber, welvu_imagesModel.type,
                   welvu_imagesModel.url, COLUMN_CONSTANT_TRUE, welvu_imagesModel.welvu_user_id,
                   welvu_imagesModel.image_guid, welvu_imagesModel.welvu_platform_id];
        } else {
            sql = [NSString stringWithFormat:
                   @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (%d, %d, \"%@\", %d, \"%@\", \"%@\",\"%@\", %d, \"%@\")",
                   TABLE_WELVU_IMAGES, COLUMN_IMAGE_ID, COLUMN_TOPIC_ID, COLUMN_IMAGE_DISPLAY_NAME,
                   COLUMN_ORDER_NUMBER, COLUMN_TYPE, COLUMN_URL, COLUMN_IMAGE_ACTIVE, COLUMN_USER_ID, COLUMN_IMAGE_GUID, row_id,
                   topicId, welvu_imagesModel.imageDisplayName,
                   welvu_imagesModel.orderNumber, welvu_imagesModel.type,
                   welvu_imagesModel.url, COLUMN_CONSTANT_TRUE, welvu_imagesModel.welvu_user_id,
                   welvu_imagesModel.image_guid];
        }
        if (sqlite3_exec(database,
                         [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
            SQLITE_OK) {
            imageAddedId = row_id;
        };
        sqlite3_close(database);
        database = nil;
    }
    return imageAddedId;
}

/*
 * Method name: addNewImageToTopic
 * Description: adding image to new topic
 * Parameters: NSString
 * Return Type: NSInteger
 */
+ (BOOL)addImageToTopicFromPlatform:(NSString *)dbPath:(welvu_images *)welvu_imagesModel:(NSInteger)topicId {
    BOOL inserted = false;
    char *error = nil;
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql =nil;
        sql = [NSString stringWithFormat:
               @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@, %@) VALUES (%d, %d, \"%@\", %d, \"%@\", \"%@\",\"%@\", %d)",
               TABLE_WELVU_IMAGES, COLUMN_IMAGE_ID, COLUMN_TOPIC_ID, COLUMN_IMAGE_DISPLAY_NAME, COLUMN_ORDER_NUMBER,
               COLUMN_TYPE, COLUMN_URL, COLUMN_IMAGE_ACTIVE, COLUMN_USER_ID,
               welvu_imagesModel.imageId,topicId,
               welvu_imagesModel.imageDisplayName, welvu_imagesModel.orderNumber, welvu_imagesModel.type,
               welvu_imagesModel.url, COLUMN_CONSTANT_TRUE, welvu_imagesModel.welvu_user_id];
        
        
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
 * Method name: updateImageWithAnnotation
 * Description: adding annotation to image
 * Parameters: NSString
 * Return Type: NSInteger
 */
+ (NSInteger)updateImageWithAnnotation:(NSString *)dbPath:(welvu_images *)welvu_imagesModel
                                userId:(NSInteger) user_id{
    int update = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\", %@=\"%@\", %@=\"%@\" where %@=%d and %@=%d",
                         TABLE_WELVU_IMAGES,
                         COLUMN_IMAGE_DISPLAY_NAME, welvu_imagesModel.imageDisplayName,
                         COLUMN_TYPE, welvu_imagesModel.type,
                         COLUMN_URL, welvu_imagesModel.url,
                         COLUMN_IMAGE_ID, welvu_imagesModel.imageId,
                         COLUMN_USER_ID, user_id];
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
 * Method name: updateImagesOrderNumberByTopicId
 * Description: adding image order by topic id
 * Parameters: NSString, NSInteger
 * Return Type: int
 */
+ (int)updateImagesOrderNumberByTopicId:(NSString *)dbPath:(NSInteger)topicId:
(NSInteger)imagesId: (NSInteger)orderNumber userId:(NSInteger) user_id{
    int update = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=%d where %@=%d and %@=%d and %@=%d",
                         TABLE_WELVU_IMAGES,
                         COLUMN_ORDER_NUMBER, orderNumber,
                         COLUMN_TOPIC_ID, topicId,
                         COLUMN_IMAGE_ID,imagesId,
                         COLUMN_USER_ID, user_id];
        //Update welvu_images set order_number=1 where topic_id=73 and images_id=100200;
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
 * Method name: deleteImageFromTopic
 * Description: delete image from topic
 * Parameters: NSString, NSInteger
 * Return Type: boolean
 */
+ (BOOL)deleteImageFromTopic:(NSString *)dbPath:(NSInteger)welvu_image_id userId:(NSInteger) user_id {
    BOOL imageDeleted = FALSE;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@=%d and %@=%d",
                         TABLE_WELVU_IMAGES,
                         COLUMN_IMAGE_ID, welvu_image_id,
                         COLUMN_USER_ID, user_id];
		if(sqlite3_exec(database,
                        [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
           SQLITE_OK) {
            imageDeleted = TRUE;
        };
        sqlite3_close(database);
        database = nil;
    }
    return imageDeleted;
}
/*
 * Method name: deleteImageFromTopicByGuid
 * Description: Delete image by topic using guid
 * Parameters: NSString, NSInteger
 * Return Type: BOOL
 */

+ (BOOL)deleteImageFromTopicByGuid:(NSString *)dbPath:(NSString *) image_guid {
    BOOL imageDeleted = FALSE;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@=\"%@\"",
                         TABLE_WELVU_IMAGES,
                         COLUMN_IMAGE_GUID, image_guid];
		if(sqlite3_exec(database,
                        [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
           SQLITE_OK) {
            imageDeleted = TRUE;
        };
        sqlite3_close(database);
        database = nil;
    }
    return imageDeleted;
}

/*
 * Method name: getImagesByTopicId
 * Description: array for images by topic id
 * Parameters: NSString
 * Return Type: NSMutableArray
 */
+ (NSMutableArray *)getImagesByTopicId:(NSString *)dbPath:(NSInteger)topicId  userId:(NSInteger) user_id{
    NSMutableArray *welvu_imagesModels = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ == %d and %@ == \"%@\" and %@ != \"%@\" and %@=%d order by %@",
                         TABLE_WELVU_IMAGES, COLUMN_TOPIC_ID,
                         topicId, COLUMN_IMAGE_ACTIVE, COLUMN_CONSTANT_TRUE,
                         COLUMN_TYPE, IMAGE_HISTORY_TYPE,
                         COLUMN_USER_ID, user_id, COLUMN_ORDER_NUMBER];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if (welvu_imagesModels == nil) {
                    welvu_imagesModels = [[NSMutableArray alloc] init];
                }
				welvu_images *welvu_imagesModel = [[welvu_images alloc] initWithImageId:sqlite3_column_int(selectstmt, 0)];
                welvu_imagesModel = [self initWithStmt:selectstmt:welvu_imagesModel];
                //welvu_imagesModel.selected = YES;
                [welvu_imagesModels addObject:welvu_imagesModel];
                //[welvu_imagesModel release];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return welvu_imagesModels;
}
/*
 * Method name: getImagesIdByTopicId
 * Description: getting image id by sending topic id
 * Parameters: dbPath, topicId
 * Return Type: NSMutableArray
 */
+ (NSMutableArray *)getImagesIdByTopicId:(NSString *)dbPath:(NSInteger)topicId  userId:(NSInteger) user_id{
    NSMutableArray *welvu_imagesId = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ == %d and %@ == \"%@\" and %@ != \"%@\" and %@=%d order by %@",
                         TABLE_WELVU_IMAGES, COLUMN_TOPIC_ID,
                         topicId, COLUMN_IMAGE_ACTIVE, COLUMN_CONSTANT_TRUE,
                         COLUMN_TYPE, IMAGE_HISTORY_TYPE,COLUMN_USER_ID, user_id,
                         COLUMN_ORDER_NUMBER];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if (welvu_imagesId == nil) {
                    welvu_imagesId = [[NSMutableArray alloc] init];
                }
				welvu_images *welvu_imagesModel = [[welvu_images alloc] initWithImageId:sqlite3_column_int(selectstmt, 0)];
                //welvu_imagesModel.selected = YES;
                [welvu_imagesId addObject:welvu_imagesModel];
                //[welvu_imagesModel release];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return welvu_imagesId;
}

/*
 * Method name: getImageCount
 * Description: to get image count
 * Parameters: dbPath,topicId
 * Return Type: NSInteger
 */
+ (NSInteger)getImageCount:(NSString *)dbPath:(NSInteger)topicId  userId:(NSInteger) user_id{
    NSInteger counteImage = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select count() from %@ where %@ == %d and %@ == \"%@\" and %@=%d",TABLE_WELVU_IMAGES,
                         COLUMN_TOPIC_ID, topicId,
                         COLUMN_IMAGE_ACTIVE, COLUMN_CONSTANT_TRUE,
                         COLUMN_USER_ID, user_id];
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                counteImage = sqlite3_column_int(selectstmt, 0);
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return counteImage;
}

/*
 * Method name: initWithStmt
 * Description: Intializing the welvu_images model object with db values
 * Parameters: sqlite3_stmt, welvu_images
 * Return Type: welvu_images
 */
+ (welvu_images *)initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_images *)welvu_imagesModel {
    welvu_imagesModel.welvu_user_id = sqlite3_column_int(selectstmt, 1);
    welvu_imagesModel.topicId = sqlite3_column_int(selectstmt, 2);
    if (sqlite3_column_text(selectstmt, 3) != nil) {
        welvu_imagesModel.imageDisplayName = [NSString stringWithUTF8String
                                              :(char *)sqlite3_column_text(selectstmt, 3)];
    }
    
    welvu_imagesModel.orderNumber = sqlite3_column_int(selectstmt, 4);
    
    if (sqlite3_column_text(selectstmt, 5) != nil) {
        welvu_imagesModel.type = [NSString stringWithUTF8String
                                  :(char *)sqlite3_column_text(selectstmt, 5)];
    }
    
    if (sqlite3_column_text(selectstmt, 6) != nil) {
        if(![welvu_imagesModel.type isEqualToString:IMAGE_BLANK_TYPE]) {
            welvu_imagesModel.url = [PathHandler getDocumentDirPathForFile:[NSString stringWithUTF8String
                                                                            :(char *)sqlite3_column_text(selectstmt, 6)]];
        } else {
            welvu_imagesModel.url = [NSString stringWithUTF8String
                                     :(char *)sqlite3_column_text(selectstmt, 6)];
        }
    }
    
    if (sqlite3_column_text(selectstmt, 7) != nil) {
        welvu_imagesModel.imageInfo = [NSString stringWithUTF8String
                                       :(char *)sqlite3_column_text(selectstmt, 7)];
    }
    
    /*if([[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 14)] isEqualToString:@"True"]) {
     welvu_imagesModel.is_locked = TRUE;
     } else {
     welvu_imagesModel.is_locked = FALSE;
     }*/
    
    
    if (sqlite3_column_text(selectstmt, 15) != nil) {
        welvu_imagesModel.image_guid = [NSString stringWithUTF8String
                                        :(char *)sqlite3_column_text(selectstmt, 15)];
    }
    
    welvu_imagesModel.welvu_platform_id = sqlite3_column_double(selectstmt, 16);
    
    welvu_imagesModel.selected = NO;
    
    return welvu_imagesModel;
}

#pragma  mark - No need to be changed
+ (BOOL) updateImagesUrlLastComponentPath: (NSString *) dbPath {
    NSMutableArray *welvu_imagesModels = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@",
                         TABLE_WELVU_IMAGES];
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if (welvu_imagesModels == nil) {
                    welvu_imagesModels = [[NSMutableArray alloc] init];
                }
				welvu_images *welvu_imagesModel = [[welvu_images alloc] initWithImageId:sqlite3_column_int(selectstmt, 0)];
                welvu_imagesModel.url = [NSString stringWithUTF8String
                                         :(char *)sqlite3_column_text(selectstmt, 6)];
                //welvu_imagesModel.selected = YES;
                [welvu_imagesModels addObject:welvu_imagesModel];
                //[welvu_imagesModel release];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        char *error = nil;
        for(welvu_images *welvu_imagesMod in welvu_imagesModels) {
            welvu_imagesMod.url = [welvu_imagesMod.url lastPathComponent];
            
            NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\" where %@=%d",
                             TABLE_WELVU_IMAGES,
                             COLUMN_URL, welvu_imagesMod.url,
                             COLUMN_IMAGE_ID,welvu_imagesMod.imageId];
            if(sqlite3_exec(database,
                            [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
               SQLITE_OK) {
                //NSLog(@"Updated Image contents %d", welvu_imagesMod.imageId);
            }else {
                NSLog(@"Update Image Error %@", error);
            }
        }
    }
    return true;
}

/*
 * Method name: getLastInsertRowId
 * Description: last inserted row ID
 * Parameters: NSString, NSInteger
 * Return Type: NSInteger
 */
+ (NSInteger)getLastInsertRowId:(NSString *)dbPath:(NSInteger)topic_id {
    NSInteger imageId = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select max(images_id) from %@ where %@=%d ",
                         TABLE_WELVU_IMAGES, COLUMN_TOPIC_ID, topic_id];
        
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
    return imageId;
}

/*
 * Method name: deactivateImageFromTopic
 * Description: deactivating image from the topic
 * Parameters: NSString, NSInteger
 * Return Type: int
 */
+ (int)deactivateImageFromTopic:(NSString *)dbPath:(NSInteger)welvu_image_id {
    int update = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\" where %@=%d",
                         TABLE_WELVU_IMAGES,
                         COLUMN_IMAGE_ACTIVE, COLUMN_CONSTANT_FALSE,
                         COLUMN_IMAGE_ID,
                         welvu_image_id];
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
 * Method name: archiveImageByTopicId
 * Description: archive image from topic
 * Parameters: NSString, NSInteger
 * Return Type: int
 */
+ (int)archiveImageByTopicId:(NSString *)dbPath: (NSInteger)topic_id {
    int update = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=\"%@\" where %@=%d",
                         TABLE_WELVU_IMAGES,
                         COLUMN_IMAGE_ACTIVE, COLUMN_CONSTANT_FALSE,
                         COLUMN_TOPIC_ID,
                         topic_id];
        if (sqlite3_exec(database,
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
 * Method name: unarchiveImageByTopicId
 * Description: reviving images from topic id
 * Parameters: NSString, NSInteger
 * Return Type: int
 */
+ (int)unarchiveImageByTopicId:(NSString *)dbPath:(NSInteger)image_id:(NSInteger)topic_id:(NSInteger) orderNumber {
    int update = 0;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"Update %@ set %@=%d, %@=%d, %@=\"%@\" where %@=%d",
                         TABLE_WELVU_IMAGES,
                         COLUMN_TOPIC_ID, topic_id,
                         COLUMN_ORDER_NUMBER, orderNumber,
                         COLUMN_IMAGE_ACTIVE, COLUMN_CONSTANT_TRUE,
                         COLUMN_IMAGE_ID,
                         image_id];
        if (sqlite3_exec(database,
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
 * Method name: getArchivedImage
 * Description: array for getting archived images
 * Parameters: NSString
 * Return Type: NSMutableArray
 */
+ (NSMutableArray *)getArchivedImage:(NSString *)dbPath {
    NSMutableArray *welvu_imagesModels = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ == \"%@\"",TABLE_WELVU_IMAGES,
                         COLUMN_IMAGE_ACTIVE, COLUMN_CONSTANT_FALSE];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                if (welvu_imagesModels == nil) {
                    welvu_imagesModels = [[NSMutableArray alloc] init];
                }
				welvu_images *welvu_imagesModel = [[welvu_images alloc] initWithImageId:sqlite3_column_int(selectstmt, 0)];
                welvu_imagesModel = [self initWithStmt:selectstmt:welvu_imagesModel];
                [welvu_imagesModels addObject:welvu_imagesModel];
                //[welvu_imagesModel release];
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return welvu_imagesModels;
}
/*
 * Method name: deleteImageFromTopic
 * Description: delete image from topic
 * Parameters: NSString, NSInteger
 * Return Type: boolean
 */
+ (BOOL)deleteImagesFromTopic:(NSString *)dbPath:(NSInteger)welvu_topic_id userId:(NSInteger) user_id {
    BOOL imageDeleted = FALSE;
    char *error = nil;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@=%d and %@=%d",
                         TABLE_WELVU_IMAGES,
                         COLUMN_TOPIC_ID, welvu_topic_id,
                         COLUMN_USER_ID, user_id];
		if(sqlite3_exec(database,
                        [sql cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, &error) ==
           SQLITE_OK) {
            imageDeleted = TRUE;
        };
        sqlite3_close(database);
        database = nil;
    }
    return imageDeleted;
}

/*
 * Method name: getArchiveImageCount
 * Description: Get count of archived images
 * Parameters: NSString
 * Return Type: NSInteger
 */
+ (NSInteger)getArchiveImageCount:(NSString *)dbPath {
    NSInteger counteArchivedImage = 0;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"select count() from %@ where %@ == \"%@\"",
                         TABLE_WELVU_IMAGES,
                         COLUMN_IMAGE_ACTIVE, COLUMN_CONSTANT_FALSE];
        
		sqlite3_stmt *selectstmt;
		if (sqlite3_prepare_v2(database,
                               [sql cStringUsingEncoding:NSASCIIStringEncoding], -1,
                               &selectstmt, NULL) == SQLITE_OK) {
			while (sqlite3_step(selectstmt) == SQLITE_ROW) {
                counteArchivedImage = sqlite3_column_int(selectstmt, 0);
			}
            sqlite3_finalize(selectstmt);
		}
        sqlite3_close(database);
        database = nil;
    }
    return counteArchivedImage;
}
@end
