//
//  PathHandler.h
//  welvu
//
//  Created by Logesh Kumaraguru on 18/09/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathHandler : NSObject

+(NSString *) getDocumentDirPathForFile:(NSString *) fileName;
+(NSString *) getCacheDirPathForFile:(NSString *) fileName;
+(NSString *) getTempDirPathForFile:(NSString *) fileName;

@end
