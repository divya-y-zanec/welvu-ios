//
//  welvu_ipx_topics.h
//  welvu
//
//  Created by Divya Yadav on 23/1/15.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "welvu_ipx_topics.h"
#import "welvuAppDelegate.h"

static sqlite3 *database = nil;
@implementation welvu_ipx_topics
@synthesize ipx_topic_id,ipx_topic_name, iPxTid;

/*
 * Method name: initWithImageId
 * Description: Intialize the welvu_ipx_images model with imageId
 * Parameters: NSString
 * Return Type: imgId
 */

- (id)initWithTopicId:(NSInteger)topicId {
    self = [super init];
    if (self) {
        ipx_topic_id = topicId;
    }
    return self;
    
}

-(id)init {
    
}

/*
 * Method name: initWithImageObject
 * Description: initilizing the image object
 * Parameters:welvu_ipxModels for the iPx
 * Return Type: id
 */

-(id)initWithTopicObject:(welvu_ipx_topics *) welvu_topicModel{
    self = [super init];
    if (self) {
       
        ipx_topic_id = welvu_topicModel.ipx_topic_id;
        ipx_topic_name = welvu_topicModel.ipx_topic_name;
    }
    return self;
    
}

@end
