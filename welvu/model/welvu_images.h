//
//  welvu_image.h
//  welvu
//
//  Created by Logesh Kumaraguru on 05/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


/*
 * Class name: welvu_images
 * Description: Data model for content of a topic and performs persistance logic
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_images : NSObject {
    NSInteger imageId; //db
    NSInteger patientImageID;
    NSInteger welvu_user_id;
    NSInteger topicId; //db
    NSString *imageDisplayName; //db
    NSInteger orderNumber; //db
    NSString *type; //db
    NSString *url; //db
    NSString *imageInfo;//db
    BOOL image_active;
    NSString *image_thumbnail;
    BOOL is_synced;
    float version;
    NSDate *created_on;
    NSDate *last_updated;
    BOOL is_locked;
    NSString *image_guid;
    double welvu_platform_id;
    UIImage *imageData;
    UIImage *retainedAnnotatedImage;
    NSString *retainedAnnotatedImageUrl;
    BOOL selected;
    BOOL pickedToView;
    
    //Box Images
    NSString *boxId;
    NSString *boxUrl;
}
//Property For the objectt
@property (nonatomic, readwrite) NSInteger imageId;
@property (nonatomic, readwrite) NSInteger patientImageID;
@property (nonatomic, readwrite)  NSInteger welvu_user_id;
@property (nonatomic, readwrite)  NSInteger topicId;
@property (nonatomic, copy) NSString *imageDisplayName;
@property (nonatomic, readwrite) NSInteger orderNumber;
@property (nonatomic, readwrite)BOOL selected;
@property (nonatomic, readwrite)BOOL pickedToView;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *imageInfo;
@property (nonatomic, readwrite)BOOL image_active;
@property (nonatomic, copy) NSString *image_thumbnail;
@property (nonatomic, readwrite) BOOL is_synced;
@property (nonatomic, readwrite) float version;
@property (nonatomic, retain) NSDate *created_on;
@property (nonatomic, retain) NSDate *last_updated;
@property (nonatomic, readwrite) BOOL is_locked;
@property (nonatomic, readwrite) NSString *image_guid;
@property (nonatomic, copy) UIImage *imageData;
@property (nonatomic, copy) UIImage *retainedAnnotatedImage;
@property (nonatomic, copy) NSString *retainedAnnotatedImageUrl;
@property (nonatomic, readwrite) double welvu_platform_id;

//Box Images
@property (nonatomic, retain) NSString *boxId;
@property (nonatomic, retain) NSString *boxUrl;

//Methods
-(id)initWithImageId:(NSInteger) imgId;
-(id)initWithImageObject:(welvu_images *) welvu_imageModel;
-(id)initWithImageObjectWithId:(welvu_images *) welvu_imageModel imgId:(NSInteger) imgId;

+(NSInteger) addNewImageToTopic:(NSString *)dbPath: (welvu_images *)welvu_imagesModel:(NSInteger) topicId;
+(BOOL) addImageToTopicFromPlatform:(NSString *)dbPath: (welvu_images *)welvu_imagesModel:(NSInteger) topicId;
+ (welvu_images *) getImageByGuid:(NSString *)dbPath: (NSString *) image_guid;
+ (welvu_images *)getImageByBoxPlatormId:(NSString *)dbPath:(double )platformId user:(NSInteger) userId;
+(BOOL) deleteImageFromTopicByGuid:(NSString *)dbPath:(NSString *)image_guid;

+(NSInteger) getMaxInsertRowIdForUserImages:(NSString *)dbPath  userId:(NSInteger) user_id;
+ (NSInteger)getMaxOrderNumber:(NSString *)dbPath:(NSInteger)topicId userId:(NSInteger) user_id;
+ (welvu_images *)getImageById:(NSString *)dbPath:(NSInteger)image_id userId:(NSInteger) user_id;
+(NSInteger) updateImageWithAnnotation:(NSString *)dbPath: (welvu_images *)welvu_imagesModel userId:(NSInteger) user_id;
+ (int)updateImagesOrderNumberByTopicId:(NSString *)dbPath:(NSInteger)topicId:
(NSInteger)imagesId: (NSInteger)orderNumber userId:(NSInteger) user_id;
+(BOOL) deleteImageFromTopic:(NSString *)dbPath:(NSInteger)welvu_image_id userId:(NSInteger) user_id;

+(NSMutableArray *) getImagesByTopicId:(NSString *)dbPath:(NSInteger) topicId  userId:(NSInteger) user_id;
+(NSMutableArray *) getImagesIdByTopicId:(NSString *)dbPath:(NSInteger) topicId  userId:(NSInteger) user_id;
+(NSInteger) getImageCount:(NSString *)dbPath:(NSInteger) topicId  userId:(NSInteger) user_id;
+ (BOOL)deleteImagesFromTopic:(NSString *)dbPath:(NSInteger)welvu_topic_id userId:(NSInteger) user_id ;

+(welvu_images *) initWithStmt:(sqlite3_stmt *)selectstmt:(welvu_images *)welvu_imagesModel;

//No need to changed
+ (BOOL) updateImagesUrlLastComponentPath: (NSString *) dbPath;
+(NSInteger) getLastInsertRowId:(NSString *)dbPath:(NSInteger) topic_id;
+(int) deactivateImageFromTopic:(NSString *) dbPath: (NSInteger) welvu_image_id;
+(int) archiveImageByTopicId:(NSString *) dbPath: (NSInteger) topic_id;
+(int) unarchiveImageByTopicId:(NSString *) dbPath:(NSInteger) image_id:(NSInteger) topic_id:(NSInteger) orderNumber;
+(NSMutableArray *) getArchivedImage:(NSString *)dbPath;
+(NSInteger) getArchiveImageCount:(NSString *)dbPath;
@end