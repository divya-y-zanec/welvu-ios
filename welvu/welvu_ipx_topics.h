//
//  welvu_ipx_topics.h
//  welvu
//
//  Created by Divya Yadav on 23/1/15.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * Class name: welvu_ipx_images
 * Description: Data model for content of a iPx  and performs persistance logic
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_ipx_topics : NSObject {
    
    NSInteger iPxTid;
    NSInteger ipx_topic_id; //db
    NSString *ipx_topic_name;//db
    
    
}
//Property for the objects
@property (nonatomic,  readwrite) NSInteger iPxTid;
@property (nonatomic,  readwrite) NSInteger ipx_topic_id; //db
@property (nonatomic, retain)NSString *ipx_topic_name;//db
//Methods
-(id)initWithTopicObject:(welvu_ipx_topics *) welvu_topicModel;
- (id)initWithTopicId:(NSInteger)imgId;

@end
