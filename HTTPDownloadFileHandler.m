//
//  HTTPDownloadFileHandler.m
//  welvu
//
//  Created by Logesh Kumaraguru on 08/02/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "HTTPDownloadFileHandler.h"
#import "NSFileManagerDoNotBackup.h"
#import "welvuContants.h"
#import "welvu_download.h"

@implementation HTTPDownloadFileHandler
@synthesize delegate;
/*
 * Method name: initWithDownloadFileDetails
 * Description: download files from webservice
 * Parameters: downloadFileSize,downloadFileType
 * return self
 */
- (id)initWithDownloadFileDetails:(NSString *)downloadFileHyperlink:(NSString *)downloadFileType
                                 :(double)downloadFileSize {
    self = [super init];
    if (self) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        welvuDownloadModel = [[welvu_download alloc] init];
        welvuDownloadModel.fileHyperLink = downloadFileHyperlink;
        welvuDownloadModel.fileType = downloadFileType;
        welvuDownloadModel.fileSize = downloadFileSize;
        NSURL *url = [NSURL URLWithString:welvuDownloadModel.fileHyperLink];
        NSString *archiveFileName = [url lastPathComponent];
        
        NSString* outputPath = [NSString stringWithFormat:@"%@/%@",
                                DOCUMENT_DIRECTORY, archiveFileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
            [[NSFileManager defaultManager] removeItemAtPath: outputPath error:NULL];
        }
        [[NSFileManager defaultManager] createFileAtPath:outputPath
                                                contents:nil
                                              attributes:nil];
    }
    return  self;
}
/*
 * Method name: downloadFileContent
 * Description: Download image content
 * Parameters: nil
 * return nil
 */
- (void)downloadFileContent {
   // NSLog(@"Download file from %@", welvuDownloadModel.fileHyperLink);
    NSURL *url = [NSURL URLWithString:welvuDownloadModel.fileHyperLink];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:180.0];
    //[requestDelegate setValue:@"0-1023/*" forHTTPHeaderField:@"Content-Range"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [connection start];
    }];
}
#pragma mark NSURLConnection Delegate

/*
 * Method name: connection
 * Description: didReceiveAuthenticationChallenge
 * Parameters: challenge
 * return authenticaion or not

 */
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge previousFailureCount] == 0) {
        NSLog(@"responded to authentication challenge");
    }
    else {
        NSLog(@"previous authentication failure");
    }
}
/*
 * Method name: didReceiveResponse
 * Description:get response from web service with requested url
 * Parameters: Response
 * return nil
 
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.delegate downloadFileDidResponseReceived:YES];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    NSLog(@"Response code %d", code);
    if (code >= 400) {
        [connection cancel];
        [self.delegate downloadFileDidReceivedData:NO:nil];
        bti = UIBackgroundTaskInvalid;
    }
}
/*
 * Method name: didReceiveData
 * Description:did recieve data from web service using the url
 * Parameters: data
 * return nil
 
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (data) {
        
        downloadBytes += [data length];
        downloadPercentage = (float)downloadBytes / welvuDownloadModel.fileSize;
        NSURL *url = [NSURL URLWithString:welvuDownloadModel.fileHyperLink];
        NSString *archiveFileName = [url lastPathComponent];
        
        NSString* outputPath = [NSString stringWithFormat:@"%@/%@",
                                DOCUMENT_DIRECTORY, archiveFileName];
        receivedData = [NSFileHandle fileHandleForUpdatingAtPath:outputPath];
        [receivedData seekToEndOfFile];
        [receivedData writeData:data];
        [receivedData closeFile];
        starting = false;
        [self.delegate downloadFilePercentageCompletion:downloadPercentage];
    }
}
/*
 * Method name: connectionDidFinishLoading
 * Description:connect finish after data loads
 * Parameters: connection
 * return nil
 
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSURL *url = [NSURL URLWithString:welvuDownloadModel.fileHyperLink];
    NSString *archiveFileName = [url lastPathComponent];
    
    NSString* outputPath = [NSString stringWithFormat:@"%@/%@",
                            DOCUMENT_DIRECTORY, archiveFileName];
    NSError *attributesError = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:outputPath
                                                                                    error:&attributesError];
    
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    if ([fileSizeNumber doubleValue] == welvuDownloadModel.fileSize) {
        NSURL *outputPathURL = [NSURL fileURLWithPath:outputPath];
        BOOL success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:outputPathURL];
    //YES
        [self.delegate downloadFileDidReceivedData:YES:outputPath];
        bti = UIBackgroundTaskInvalid;
    } else if ([fileSizeNumber doubleValue] < welvuDownloadModel.fileSize){
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%d-", downloadBytes];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:180.0];
        [request setValue:requestRange forHTTPHeaderField:@"Range"];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        bti = UIBackgroundTaskInvalid;
        bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [connection start];
        }];
    } else {
        [self.delegate downloadFileDidReceivedData:NO:outputPath];
        bti = UIBackgroundTaskInvalid;
    }
}
/*
 * Method name: connection
 * Description:if connection fails while loading
 * Parameters: error
 * return nil
 
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults  removeObjectForKey:@"receivedData"];
    NSLog(@"Share Content %@",error);
    [self.delegate downloadFilefailedWithErrorDetails:error];
    bti = UIBackgroundTaskInvalid;
}
@end
