//
//  ShareContentVUHelper.m
//  welvu
//
//  Created by Logesh Kumaraguru on 28/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "ShareVUContentHelper.h"
#import "welvuiPhoneContants.h"
#import "XMLReader.h"
#import "Base64.h"

@implementation ShareVUContentHelper
@synthesize delegate;

-(id) initWithShareVuContent:(welvu_message*) welvu_message_Model {
    self = [super init];
    if(self) {
        welvu_messageModel = welvu_message_Model;
    }
    return  self;
}

-(void) shareVUContents {
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", PORTAL_HOST_URL,PORTAL_SEND_MESSAGE_ACTION_URL];
    
	NSURL *url = [NSURL URLWithString:urlStr];
    
    NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys
                                 :MAIL_ID, HTTP_EMAILID_KEY,
                                 welvu_messageModel.recipients, HTTP_RECIPIENTS_KEY,
                                 welvu_messageModel.message, HTTP_MESSAGE_KEY,
                                 welvu_messageModel.subject, HTTP_SUBJECT_KEY,nil];
    NSLog(@"%@ and %@", welvu_messageModel.videoFileLocation, welvu_messageModel.videoFileName);
    
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:welvu_messageModel.videoFileLocation];
    NSData *videoData = [[NSData alloc] initWithContentsOfURL:fileURL];
    
    NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:url andDataDictionary:messageData attachmentData:videoData
                                                     attachmentType:HTTP_ATTACHMENT_VIDEO_CONTENT_TYPE_KEY
                                                 attachmentFileName:welvu_messageModel.videoFileName];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
    [connection start];
    [connection release];
    [fileURL release];
    [videoData release];
}

- (NSMutableURLRequest *) POSTRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) message_data
                              attachmentData:(NSData *) attachment_data attachmentType:(NSString *) attachment_type
                          attachmentFileName:(NSString *) attachment_fileName {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:180.0];
    [request setHTTPMethod:HTTP_METHOD_POST];
    
    NSMutableString *loginString = (NSMutableString *)
    [@"" stringByAppendingFormat:@"%@:%@",  MAIL_ID, MAIL_PASSWORD];
    NSString *encodedLoginData = [Base64 encode:[loginString dataUsingEncoding:NSUTF8StringEncoding]];
    [request addValue:[NSString stringWithFormat:@"%@ %@",HTTP_SSL_BASIC, encodedLoginData] forHTTPHeaderField:HTTP_SSL_HEADER_KEY];
    
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
    
    if (attachment_data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", HTTP_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
        //MOdify from here
        [body appendData:[[NSString stringWithFormat:@"%@\"%@\"; filename=\"%@.%@\"\r\n",HTTP_CONTENT_DISPOSITION, attachment_fileName,attachment_fileName, HTTP_ATTACHMENT_VIDEO_EXT_KEY] dataUsingEncoding:NSUTF8StringEncoding]];
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
        NSLog(@"received authentication challenge");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:MAIL_ID
                                                                    password:MAIL_PASSWORD
                                                                 persistence:NSURLCredentialPersistenceForSession];
        NSLog(@"credential created");
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        NSLog(@"responded to authentication challenge");
    }
    else {
        NSLog(@"previous authentication failure");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Response reached");
    [self.delegate shareVUContentMailSendResponse:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Did receive data");
    if(data) {
        NSError *error;
        NSDictionary *responseDictionary = [XMLReader dictionaryForXMLData:data error:&error];
        NSLog(@"%@", responseDictionary);
        [self.delegate shareVUContentMailDidReceivedData:NO:responseDictionary];
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Share Content Did finish loading");
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Share Content %@",error);
    [self.delegate shareVUContentFailedWithError:error];
}

-(void)dealloc {
    [super dealloc];
    delegate = nil;
}

@end
