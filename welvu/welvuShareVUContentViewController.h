//
//  ShareVUContentViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 28/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BoxSDK/BoxSDK.h>
#import "ShareVUContentHelper.h"
#import "ShareVUContentPlatformHelper.h"
#import "welvu_sharevu.h"

@class welvuShareVUContentViewController;

/*
 * Protocol name: shareVUContentViewControllerDelegate
 * Description : Delegate method to return selected content
 */
@protocol shareVUContentViewControllerDelegate
- (void)shareVUContentViewControllerStartedSharing;
- (void)shareVUContentViewControllerDidFinish:(BOOL) success;
- (void)shareVUContentViewControllerDidCancel;
@end

/*
 * Class name: welvuShareVUContentViewController
 * Description: To share the video content
 * Extends: UIViewController
 * Delegate : shareVUContentHelperDelegate, shareVUContentPlatformHelperDelegate,
 UITextFieldDelegate, UITextViewDelegate
 */
@interface welvuShareVUContentViewController : UIViewController <shareVUContentHelperDelegate,
shareVUContentPlatformHelperDelegate,
UITextFieldDelegate, UITextViewDelegate, BoxFolderPickerDelegate> {
    welvuAppDelegate *appDelegate;
    //Assigning the delegate to the controller
    id<shareVUContentViewControllerDelegate> delegate;
    //Textfield
    IBOutlet UITextField *recipientsTxt;
    IBOutlet UITextField *subjectTxt;
    IBOutlet UITextView *messagetTxtView;
    IBOutlet UILabel *attachmentLabel;
    IBOutlet UITextField *youtubeTitleTxt;
    IBOutlet UITextView *youtubeDescriptionTxtView;
    IBOutlet UITextField *youtubeTagTxt;
    IBOutlet UIButton *shareBtn;
    IBOutlet UIButton *boxBtn;
    welvu_sharevu *welvuShareVUModel;
    UIView *overlay;
    BOOL exportCompleted;
    IBOutlet UISegmentedControl *shareSegmentControl;
    //View
    IBOutlet UIView *mailVUView;
    IBOutlet UIView *youtubeVUView;
    //animation
    IBOutlet UIImageView *imageToMove;
    IBOutlet UIView *myView;
    IBOutlet UIImageView *animatedButton;
}
//Assigning the property for the delegate
@property (retain) id<shareVUContentViewControllerDelegate> delegate;
@property (nonatomic, retain)  welvu_sharevu *welvuShareVUModel;
#pragma mark - Box api
@property (nonatomic, readwrite, strong) BoxFolderPickerViewController *folderPicker;
//Methods
-(id)initWithAttachmentDetails:(NSString *) subject:(NSString *)signature
                              :(NSInteger) videoVUId :(BOOL) isExportCompleted;

//Button Action
-(IBAction)informationBtnClicked:(id)sender;
-(IBAction)shareContentVUBtnClicked:(id)sender;
-(IBAction)cancelSharingVUBtnClickeds:(id)sender;
-(IBAction)shareOptionSelectionSwictchChanges:(id)sender;
-(IBAction)youtubePrivacySwitchChanged:(id)sender;
-(IBAction) boxBtnClicked:(id)sender;
@end
