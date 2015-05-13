//
//  NSFileManagerDoNotBackup.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 02/03/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "NSFileManagerDoNotBackup.h"
#include <sys/xattr.h>

@implementation NSFileManager (DoNotBackup)
/*
 * Method name: addSkipBackupAttributeToItemAtURL
 * Description:to delete the backup content form cache memory
 * Parameters: URL
 * return Bool
 */
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    if (&NSURLIsExcludedFromBackupKey == nil) { // iOS <= 5.0.1
        const char* filePath = [[URL path] fileSystemRepresentation];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    } else { // iOS >= 5.1
        return [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
}

@end
