//
//  welvu_contenttag.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 08/11/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "welvu_images.h"
/*
 * Class name: welvu_contenttag
 * Description: Has functionality to show content tag
 * Extends: NSObject
 * Delegate :nil
 */
@interface welvu_contenttag : NSObject {
    NSInteger *welvu_contentid;
    // NSMutableArray *welvu_tagnames;
    NSString *welvu_tagnames;
    
}
//Property of the objects
@property (nonatomic,retain) NSString *welvu_tagnames;
@property (nonatomic,readonly) NSInteger *welvu_contentid;
//Methods
+ (BOOL)insertcontenttag:(NSString *)dbPath:(NSInteger)welvu_contentid:(NSMutableArray*)welvu_tagnames;
+ (BOOL)updatecontenttag:(NSString *)dbPath:(NSInteger)welvu_contentid:(NSMutableArray*)welvu_tagnames;
+ (BOOL)reterievetagname:(NSString *)dbPath:(NSInteger) previousSelectedId;
- (id)initWithImageId:(NSString*) welvu_tagnames;
+ (NSMutableString *)reterievetagnamefromdb:(NSString *)dbPath:(NSInteger)welvu_contentid;
+ (BOOL)checkdatabase:(NSString *)dbPath:(NSInteger)previousSelectedId:(NSMutableArray*)welvu_tagnames;

@end
