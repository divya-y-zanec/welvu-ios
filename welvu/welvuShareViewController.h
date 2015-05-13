//
//  welvuShareViewController.h
//  welvu
//
//  Created by Divya Yadav. on 31/12/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "welvuSettingsMasterViewController.h"
#import "GMGridView.h"
#import "welvu_images.h"
#import "welvu_settings.h"
#import "welvuTopicVUAnnotationViewController.h"
#import "welvuArchiveImageController.h"
#import "ELCImagePickerController.h"
//Delegate method to return selected content
@protocol welvuShareViewDelegate
-(void)shareChoiceSelected: (NSInteger)tagid;
@end
/*
 * Class name: welvuShareViewController
 * Description:To share the content
 * Extends: UIViewController
 * Delegate :nil
 */
@interface welvuShareViewController : UIViewController {
    //Assigning the delegate for the view controller
    id<welvuShareViewDelegate> delegate;
    
}
//Assigning the property for the delegate
@property (retain) id<welvuShareViewDelegate> delegate;
//Action Methods
-(IBAction)shareBtnSelected:(id)sender;
@end
