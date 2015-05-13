//
//  welvuLoginViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 23/01/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "welvuLoginViewController.h"
#import "welvuContants.h"
#import "JSON.h"
#import "Base64.h"
#import "welvuSpecialtyViewController.h"
@interface welvuLoginViewController ()

@end

@implementation welvuLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        welvuPlatformHostUrl = PLATFORM_HOST_URL;
        welvuPlatformActionUrl = PLATFORM_SEND_AUTHENTICATION_ACTION_URL;
    }
    return self;
}


-(IBAction)loginBtnClicked:(id)sender {
    welvuPlatformHostUrl = PLATFORM_HOST_URL;
    welvuPlatformActionUrl = PLATFORM_SEND_AUTHENTICATION_ACTION_URL;
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", welvuPlatformHostUrl, welvuPlatformActionUrl];
    
	NSURL *url = [NSURL URLWithString:urlStr];
    
    NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                 username.text, HTTP_REQUEST_USER_NAME,
                                 password.text, HTTP_PASSWORD_KEY,nil];
    
    
    
    
    NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:url andDataDictionary:messageData attachmentData:nil
                                                     attachmentType:nil
                                                 attachmentFileName:nil];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
    bti = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [connection start];
    }];
    
    
    [connection release];
}

- (NSMutableURLRequest *) POSTRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) message_data
                              attachmentData:(NSData *) attachment_data attachmentType:(NSString *) attachment_type
                          attachmentFileName:(NSString *) attachment_fileName {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:180.0];
    [request setHTTPMethod:HTTP_METHOD_POST];
    
    NSString *contentType = [NSString stringWithFormat:@"%@; %@=%@", HTTP_REQUEST_MULTIPART_TYPE,
                             HTTP_BOUNDARY_KEY, HTTP_BOUNDARY];
    [request setValue:contentType forHTTPHeaderField:HTTP_REQUEST_CONTENT_TYPE_KEY];
    
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in message_data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", HTTP_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\"%@\"\r\n\r\n", HTTP_CONTENT_DISPOSITION,param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [message_data objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (attachment_data != nil) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", HTTP_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
        //MOdify from here
        [body appendData:[[NSString stringWithFormat:@"%@\"%@\"; filename=\"%@.%@\"\r\n",HTTP_CONTENT_DISPOSITION, @"filename",attachment_fileName, HTTP_ATTACHMENT_VIDEO_EXT_KEY] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@: %@\r\n\r\n",HTTP_REQUEST_CONTENT_TYPE_KEY,attachment_type] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:attachment_data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", HTTP_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:HTTP_REQUEST_CONTENT_LENGTH_KEY];
    
    // set URL
    [request setURL:url];
    
    
    return request;
}



// NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge previousFailureCount] == 0) {
        /*NSLog(@"received authentication challenge");
         NSURLCredential *newCredential = [NSURLCredential credentialWithUser:MAIL_ID
         password:MAIL_PASSWORD
         persistence:NSURLCredentialPersistenceForSession];
         NSLog(@"credential created");
         [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];*/
        NSLog(@"responded to authentication challenge");
    }
    else {
        NSLog(@"previous authentication failure");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Response reached %@", response);
    [[UIApplication sharedApplication] endBackgroundTask:bti];
    bti = UIBackgroundTaskInvalid;
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Did receive data");
    if(data) {
        NSError *error;
        SBJSON *parser = [[[SBJSON alloc] init] autorelease];
        // 1. get the top level value as a dictionary
        NSString* newStr = [[[NSString alloc] initWithData:data
                                                  encoding:NSUTF8StringEncoding] autorelease];
        NSDictionary *responseDictionary = [parser objectWithString:newStr error:&error];
        NSLog(@"%@", responseDictionary);
        [[UIApplication sharedApplication] endBackgroundTask:bti];
        bti = UIBackgroundTaskInvalid;
        if([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] isEqualToString:@"Success"]) {
            welvuSpecialtyViewController *specialtyViewCont = [[welvuSpecialtyViewController alloc]initWithNibName:@"welvuSpecialtyViewController" bundle:nil];
            //specialtyViewCont.delegate = self;
            specialtyViewCont.modalPresentationStyle = UIModalPresentationFullScreen;
            specialtyViewCont.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentModalViewController:specialtyViewCont animated:NO];
            [specialtyViewCont release];
            [self dismissModalViewControllerAnimated:NO];
        }
    }
   
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Content Did finish loading");
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@" Content %@",error);
    [[UIApplication sharedApplication] endBackgroundTask:bti];
    bti = UIBackgroundTaskInvalid;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
