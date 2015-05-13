//
//  ShareVUContentViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 28/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareVUContentHelper.h"

@class ShareVUContentViewController;

@protocol shareVUContentViewControllerDelegate
- (void)shareVUContentViewControllerStartedSharing;
- (void)shareVUContentViewControllerDidFinish;
- (void)shareVUContentViewControllerDidCancel;
@end


@interface ShareVUContentViewController : UIViewController <shareVUContentHelperDelegate,UITextFieldDelegate,UITextViewDelegate>{
    id<shareVUContentViewControllerDelegate> delegate;
    IBOutlet UITextField *recipientsTxt;
    IBOutlet UITextField *subjectTxt;
    IBOutlet UITextView *messagetTxtView;
    IBOutlet UILabel *attachmentLabel;
    
    welvu_message *welvu_messageModel;
}
@property (nonatomic, retain)  welvu_message *welvu_messageModel;

-(id)initWithAttachmentDetails:(NSString *) subject:(NSString *)signature
                              :(NSString *) videoFile_Name:(NSString *)videoFile_Location;

@property (retain) id<shareVUContentViewControllerDelegate> delegate;
@end
