//
//  PathHandler.m
//  welvu
//
//  Created by Logesh Kumaraguru on 18/09/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "PathHandler.h"
#import "welvuContants.h"

@implementation PathHandler


+(NSString *) getDocumentDirPathForFile:(NSString *) fileName {
    return [NSString stringWithFormat:@"%@/%@", DOCUMENT_DIRECTORY, fileName];
}


+(NSString *) getCacheDirPathForFile:(NSString *) fileName {
    return [NSString stringWithFormat:@"%@/%@", CACHE_DIRECTORY, fileName];
}


+(NSString *) getTempDirPathForFile:(NSString *) fileName {
    return [NSString stringWithFormat:@"%@/%@", TEMP_DIRECTORY, fileName];
}
@end
