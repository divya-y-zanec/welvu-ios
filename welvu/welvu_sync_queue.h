//
//  welvu_sync_queue.h
//  welvu
//
//  Created by Logesh Kumaraguru on 06/03/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "welvu_images.h"
#import "welvu_topics.h"
/*
 * Class name: welvu_sync_queue
 * Description: sync the content in the queue
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_sync_queue : NSObject {
    NSString *sync_queue_guid;
    NSInteger type;
    NSInteger syncFunctionalityType;
    NSInteger functionality_id;
}
//Property of the objects
@property (nonatomic, copy) NSString *sync_queue_quid;
@property (nonatomic, readwrite) NSInteger type;
@property (nonatomic, readwrite) NSInteger syncFunctionalityType;
@property (nonatomic, readwrite) NSInteger functionality_id;

//Methods
-(NSDictionary *)createTopicSyncDictionary:(welvu_topics *) welvu_topicModel;
-(NSDictionary *)createImagesSyncDictionary:(welvu_images *) welvu_imagesModel;
@end
