//
//  welvuiPxShareViewController.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 14/11/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BoxSDK/BoxSDK.h>
#import "welvuAppDelegate.h"
#import "welvuVideoMakerViewController.h"

//Delegate method to return selected content

@protocol welvuiPxShareViewControllerDelegate

@end
/*
 * Class name: welvuiPxShareViewController
 * Description: To save the iPx Video
 * Extends: UIViewController
 *Delegate : UITextViewDelegate,NSURLConnectionDelegate,UIAlertViewDelegate
 */
@interface welvuiPxShareViewController : UIViewController <UITextFieldDelegate ,UITextViewDelegate ,NSURLConnectionDelegate> {
    //Defining the delegate for this controller
    id<welvuiPxShareViewControllerDelegate> delegate;
    welvuAppDelegate *appDelegate;
    IBOutlet UITextField *ipxTitle;
    IBOutlet UITextView *ipxDescription;
    IBOutlet UITextView *messagetTxtView;
    NSString *getIpxTitle;
    NSString *getIpxDescription;
    NSString *ipx_videoFileName;
    NSString *ipx_videoFileLocation;
    UIBackgroundTaskIdentifier *bti;
    IBOutlet UILabel *descLabel;
    IBOutlet UIView *shareVU;
    UIView * overlay;
}
//Assigning the property for the delegate object
@property (retain) id<shareVUContentViewControllerDelegate> delegate;
@property (nonatomic,retain) NSString *ipx_videoFileLocation;
@property (nonatomic ,retain)  NSString *ipx_videoFileName;
@property (nonatomic,retain)  NSString *getIpxDescription;
@property (nonatomic,retain) NSString *getIpxTitle;
@property (nonatomic ,retain) IBOutlet UITextField *ipxTitle;
@property (nonatomic ,retain)  IBOutlet UITextView *ipxDescription;
@property (nonatomic ,retain) IBOutlet UITextView *messagetTxtView;
//Action Methods
-(IBAction)backBtnClicked:(id)sender;
-(IBAction)shareIpxBtnClicked:(id)sender;
-(IBAction)informationBtnClicked:(id)sender;

@end
