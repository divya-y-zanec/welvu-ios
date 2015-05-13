//
//  WelVUMapsLink.h
//  welvu
//
//  Created by Logesh Kumaraguru on 21/03/14.
//  Copyright (c) 2014 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WelVUMapsLink : NSObject {
    NSInteger imageId;
    NSString *mapLink;
    NSString *placeName;
}
@property (nonatomic, readwrite) NSInteger imageId;
@property (nonatomic, copy) NSString *mapLink;
@property (nonatomic, copy) NSString *placeName;
@end
