//
//  HTTPDownloadFileHandler.h
//  welvu
//
//  Created by Logesh Kumaraguru on 08/02/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "welvu_download.h"
//Delegate method to return selected content
@protocol HTTPDownloadHandlerDelegate
- (void)downloadFileDidResponseReceived:(BOOL)success;
- (void)downloadFileDidReceivedData:(BOOL)success:(NSString *)fileStoredLocation;
- (void)downloadFilePercentageCompletion:(float)percentageCompletion;
- (void)downloadFilefailedWithErrorDetails:(NSError *)error;
@end

/*
 * Class name: HTTPDownloadFileHandler
 * Description: Has functionality to Download the file
 * Extends: NSObject
 * Delegate :nil
 */

@interface HTTPDownloadFileHandler : NSObject {
    welvuAppDelegate *appDelegate;
    //Defining the delegate for this controller
    id<HTTPDownloadHandlerDelegate> delegate;
    welvu_download *welvuDownloadModel;
    NSFileHandle *receivedData;
    NSInteger downloadBytes;
    float downloadPercentage;
    BOOL starting;
    //BgTask
    UIBackgroundTaskIdentifier bti;
}
//Assigning the property for the delegate object
@property (retain) id<HTTPDownloadHandlerDelegate> delegate;
- (id)initWithDownloadFileDetails:(NSString *)downloadFileHyperlink:(NSString *)downloadFileType
                                 :(double)downloadFileSize;
- (void)downloadFileContent;
@end
