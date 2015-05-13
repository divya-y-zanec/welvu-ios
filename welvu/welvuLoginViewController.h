//
//  welvuLoginViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 23/01/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface welvuLoginViewController : UIViewController <UITextFieldDelegate>{
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    NSString *welvuPlatformHostUrl;
    NSString *welvuPlatformActionUrl;
    UIBackgroundTaskIdentifier bti;
}

-(IBAction)loginBtnClicked:(id)sender;
- (NSMutableURLRequest *) POSTRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) message_data
                              attachmentData:(NSData *) attachment_data attachmentType:(NSString *) attachment_type
                          attachmentFileName:(NSString *) attachment_fileName;

@end
