
//  YouTubeUploader.m
//  YouTubeSample_iOS
//
//  Created by Manuel Carrasco Molina on 08.01.12.
//  Copyright (c) 2012 Pomcast. All rights reserved.
//

#import "YouTubeUploader.h"
#import "GDataEntryYouTubeUpload.h"
#import "GTMOAuth2ViewControllerTouch.h"


@interface YouTubeUploader (Private)

- (GDataServiceGoogleYouTube *)youTubeService;
- (BOOL)isSignedIn;
- (NSString *)signedInUsername;
- (void)runSignin:(NSString*)path;

@end

@implementation YouTubeUploader

@synthesize uploadProgressView = _uploadProgressView;
@synthesize delegate = _delegate;
@synthesize uploaderDelegate,isPrivate;

static NSString *const kKeychainItemName = @"YouTubeSample_iOS: YouTube";

#pragma mark - Public Methods

- (id)init {
    if ((self = [super init])) {
        GTMOAuth2Authentication *auth;
        auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                     clientID:CLIENT_ID
                                                                 clientSecret:CLIENT_SECRET];
        [[self youTubeService] setAuthorizer:auth];
    }
    return self;
}

- (void)logout {
    GDataServiceGoogleYouTube *service = [self youTubeService];
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    [service setAuthorizer:nil];
}
-(void)uploadVodeoFileForYouTube:(NSString *)path :(NSString *)title1 :(NSString *)Description :(NSString *)tagName :(NSString *)category
:(NSString *)youTubePrivate
{
    if (![self isSignedIn]) {
        // Sign in
        [self runSignin:path];
    }
       
if([youTubePrivate isEqualToString:@"Yes"])
{
    isPrivate=YES;
}
    else
    {
        isPrivate=NO;
    }
   
    GDataServiceGoogleYouTube *service = [self youTubeService];
    [service setYouTubeDeveloperKey:DEV_KEY];
    
    NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:kGDataServiceDefaultUser];
    
    // load the file data
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSString *filename = [path lastPathComponent];
    
    // gather all the metadata needed for the mediaGroup
    GDataMediaTitle *title = [GDataMediaTitle textConstructWithString:title1];
    GDataMediaCategory *category1 = [GDataMediaCategory mediaCategoryWithString:category];
    
    //category1.addCategory(new MediaCategory(YouTubeNamespace.DEVELOPER_TAG_SCHEME, "moregoodfoundation"));
    GDataMediaDescription *desc = [GDataMediaDescription textConstructWithString:Description];
    
    
    GDataMediaKeywords *tagname1 = [GDataMediaKeywords keywordsWithString:tagName];
    
    
    [category1 setScheme:kGDataSchemeYouTubeCategory];
   // BOOL isPrivate=YES;
    
    GDataYouTubeMediaGroup *mediaGroup = [GDataYouTubeMediaGroup mediaGroup];
    [mediaGroup setMediaTitle:title];
    [mediaGroup addMediaCategory:category1];
    [mediaGroup setIsPrivate:isPrivate];
    [mediaGroup setMediaDescription:desc];
    [mediaGroup setMediaKeywords:tagname1 ];
    
    
    
    NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:path
                                               defaultMIMEType:@"video/mov"];
    
    // create the upload entry with the mediaGroup and the file
    GDataEntryYouTubeUpload *entry;
    entry = [GDataEntryYouTubeUpload uploadEntryWithMediaGroup:mediaGroup
                                                    fileHandle:fileHandle
                                                      MIMEType:mimeType
                                                          slug:filename];
    
    [service setServiceUploadProgressSelector:@selector(ticket:hasDeliveredByteCount:ofTotalByteCount:)];
    [self.uploaderDelegate YouTubeUploaderDidFinish];
    GDataServiceTicket *ticket;
    ticket = [service fetchEntryByInsertingEntry:entry
                                      forFeedURL:url
                                        delegate:self
                               didFinishSelector:@selector(uploadTicket:finishedWithEntry:error:)];
}


- (void)uploadVideoFile:(NSString*)path {
    
    if (![self isSignedIn]) {
        // Sign in
        [self runSignin:path];
    }
    
    GDataServiceGoogleYouTube *service = [self youTubeService];
    [service setYouTubeDeveloperKey:DEV_KEY];
    
    NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:kGDataServiceDefaultUser];
    
    // load the file data
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSString *filename = [path lastPathComponent];
    
    // gather all the metadata needed for the mediaGroup
    GDataMediaTitle *title = [GDataMediaTitle textConstructWithString:[filename stringByDeletingPathExtension]];
    GDataMediaCategory *category = [GDataMediaCategory mediaCategoryWithString:@"Education"];
    
    [category setScheme:kGDataSchemeYouTubeCategory];
//BOOL isPrivate = YES;
    
    GDataYouTubeMediaGroup *mediaGroup = [GDataYouTubeMediaGroup mediaGroup];
    [mediaGroup setMediaTitle:title];
    [mediaGroup addMediaCategory:category];
    [mediaGroup setIsPrivate:isPrivate];
    
    
    NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:path
                                               defaultMIMEType:@"video/mp4"];
    
    // create the upload entry with the mediaGroup and the file
    GDataEntryYouTubeUpload *entry;
    entry = [GDataEntryYouTubeUpload uploadEntryWithMediaGroup:mediaGroup
                                                    fileHandle:fileHandle
                                                      MIMEType:mimeType
                                                          slug:filename];
    
    [service setServiceUploadProgressSelector:@selector(ticket:hasDeliveredByteCount:ofTotalByteCount:)];
    
    GDataServiceTicket *ticket;
    [self.uploaderDelegate YouTubeUploaderDidFinish];
    ticket = [service fetchEntryByInsertingEntry:entry
                                      forFeedURL:url
                                        delegate:self
                               didFinishSelector:@selector(uploadTicket:finishedWithEntry:error:)];
}

#pragma mark - Private Methods

- (BOOL)isSignedIn {
    NSString *name = [self signedInUsername];
    return (name != nil);
}

- (GDataServiceGoogleYouTube *)youTubeService {
    // A "service" object handles networking tasks.  Service objects
    // contain user authentication information as well as networking
    // state information (such as cookies and the "last modified" date for
    // fetched data.)
    
    static GDataServiceGoogleYouTube* service = nil;
    if (!service) {
        service = [[GDataServiceGoogleYouTube alloc] init];
        
        [service setShouldCacheResponseData:YES];
        [service setServiceShouldFollowNextLinks:YES];
        [service setIsServiceRetryEnabled:YES];
    }
    [service setYouTubeDeveloperKey:DEV_KEY];
    return service;
}

- (NSString *)signedInUsername {
    // Get the email address of the signed-in user
    GTMOAuth2Authentication *auth = [[self youTubeService] authorizer];
    BOOL isSignedIn = auth.canAuthorize;
    if (isSignedIn) {
        return auth.userEmail;
    } else {
        return nil;
    }
}

- (void)runSignin:(NSString*)path {
    // Show the OAuth 2 sign-in controller
    NSString *scope = [GDataServiceGoogleYouTube authorizationScope];
    
    id completionHandler = ^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
        // TODO: Check the error and don't dismiss if an error has occured.
       // NSLog(@"%@\n%@\n%@", viewController, auth, error);
        [self.delegate dismissViewControllerAnimated:YES completion:^{
            [self init];
            if ([[[self youTubeService] authorizer] canAuthorize]) {
                [self uploadVideoFile:path];
            }
        }];
    };
    
    GTMOAuth2ViewControllerTouch *viewController = [GTMOAuth2ViewControllerTouch controllerWithScope:scope
                                                                                            clientID:CLIENT_ID
                                                                                        clientSecret:CLIENT_SECRET
                                                                                    keychainItemName:kKeychainItemName
                                                                                   completionHandler:completionHandler];
    
    [self.delegate presentViewController:viewController animated:YES completion:^{
    }];
}

// progress callback

- (void)ticket:(GDataServiceTicket *)ticket hasDeliveredByteCount:(unsigned long long)numberOfBytesRead ofTotalByteCount:(unsigned long long)dataLength
{
    float progress = (float)numberOfBytesRead/dataLength;
    [_uploadProgressView setProgress:progress animated:YES];
}


// upload callback
- (void)uploadTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
               error:(NSError *)error {
    
    NSLog(@"srror message %@",error);
     NSLog(@"%@ %@", [videoEntry title], error);
    NSString *title, *message;
    
    
    if (error == nil) {
        // tell the user that the add worked
        /* title = NSLocalizedString(UPLOADED_VIDEO_TITLE, @"When the video upload succeeded ('title' in the UIAlertView).");
         message = [NSString stringWithFormat:NSLocalizedString(UPLOADED_VIDEO_MESSAGE, @"When the video upload succeeded ('message' in the UIAlertView)."), [[videoEntry title] stringValue]];*/
        //[self.uploaderDelegate YouTubeUploaderDidFinish];
    } else {
        
        
        title = NSLocalizedString(@"Message", @"When the video upload FAILED ('title' in the UIAlertView).");
        
        message = [error localizedDescription];
        
        UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView1 show];      //[_uploadProgressView setProgress:0 animated:YES];
    }
}
@end
