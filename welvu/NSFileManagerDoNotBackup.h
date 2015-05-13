//
//  NSFileManagerDoNotBackup.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 02/03/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 * Class name: NSFileManager
 * Description: do not back the content in the deivce
 * Extends: nil
 * Delegate :nil
 */
@interface NSFileManager (DoNotBackup)

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@end
