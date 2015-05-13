//
//  welvu_download.h
//  welvu
//
//  Created by Logesh Kumaraguru on 08/02/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 * Class name: welvu_download
 * Description: Data model for download content
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_download : NSObject {
    NSString *fileHyperLink;
    NSString *fileType;
    double fileSize;
}

//Property
@property (nonatomic, retain) NSString *fileHyperLink;
@property (nonatomic, retain) NSString *fileType;
@property (nonatomic, readwrite) double fileSize;
@end
