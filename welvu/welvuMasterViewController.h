//
//  welvuMasterViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 15/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "welvuSpecialtyViewController.h"
#import "welvuTopicVUviewController.h"
#import "welvuArchiveTopicController.h"
#import "welvuHistoryVUViewController.h"
#import "welvuSettingsMasterViewController.h"
#import "welvuContants.h"
#import "welvu_topics.h"
#import "AccordionView.h"
#import "AccordianButton.h"
#import "welvuTopicVUviewController.h"
#import "welvu_user.h"
#import "welvuRegistrationViewController.h"
#import "InAppPurchaseManager.h"
#import "SyncDataToCloud.h"
#import "welvuOrganizationViewController.h"
@class welvuVideoMakerViewController;
@class welvuTopicVUView;
@class welvuDetailViewControllerIpad;
/*
 * Protocol name: welvuMasterViewControllerDelegate
 * Description: Delegate function for master view controller
 */
@protocol welvuMasterViewControllerDelegate
@end
/*
 * Class name: welvuMasterViewController
 * Description: Has functionality to display the topics
 * Extends: UIViewController
 * Delegate :UIAlertViewDelegate,
 UIPopoverControllerDelegate, UINavigationControllerDelegate,
 MFMailComposeViewControllerDelegate,UIImagePickerControllerDelegate,UIScrollViewDelegate
 */
@interface welvuMasterViewController : UIViewController <UITableViewDelegate, UIAlertViewDelegate,
UIGestureRecognizerDelegate, UIPopoverControllerDelegate, SettingsMasterViewControllerDelegate, specialtyViewControllerDelegate,
welvuArchiveTopicDelegate, historyVUViewControllerDelegate, MFMailComposeViewControllerDelegate,welvuMasterViewControllerDelegate,UIPopoverControllerDelegate, welvuTopicVUViewDelegate,UIScrollViewDelegate,AccordionViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, welvuTopicVUAnnotationDelegate, welvuRegistrationViewControllerDelegate,InAppPurchaseManagerDelegate,welvuVideoMakerViewControllerDelegate ,syncContentToPlatformHelperDelegate ,welvuOrganizationViewControllerDelegate> {
    welvuSpecialtyViewController *welvuSpecialty;
    welvu_topics *welvu_topicUserModel;
    welvuAppDelegate *appDelegate;
    //Defining the delegate for this controller
    id<welvuMasterViewControllerDelegate>delegate;
    NSMutableArray *welvu_topicsModels;
    IBOutlet UITableView *topicTableView;
    NSInteger previousSelectedTopicId;
    AccordionView *accordion;
    welvuTopicVUviewController * welvuTopicVUView ;
    NSInteger getTopicCount;
    //Specialty Label
    IBOutlet UILabel *specialtyLabel;
    ProcessingSpinnerView *spinner;
    IBOutlet UIScrollView *myScroll;
     InAppPurchaseManager *inApp;
    //Fade effect
    UIImagePickerController *  picker;
    IBOutlet UIView*  _topFadingView;
    IBOutlet UIView*  _bottomFadingView;
    IBOutlet UIView* accordionContainer;
    UIColor* fadeColor_;
    UIColor* baseColor_;
    CAGradientLayer *g1_;
    CAGradientLayer *g2_;

    fade_orientation fadeOrientation_;
    //Bar buttons
    UIBarButtonItem *reviewBtn;
    UIBarButtonItem *historyVUBtn;
    UIActivityIndicatorView *activityIndicator;
    NSString *tetTopicCount;
    BOOL topicListGenerated;
    int update;
    BOOL isAlreadyCalled;
    BOOL yearlySubscription;
    
    //EMR
    IBOutlet UIView* eMRContainer;
    IBOutlet UIView *specialtyContainer;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *graphInfoBtn;
    IBOutlet UIButton *patientInfo;
    IBOutlet UIView* patientImageContainer;
    __gm_weak GMGridView *oemrPatientGMGridView;
    NSMutableArray *oEMRPatientImages;
        NSInteger patientImgTobeRemoved;
     BOOL gridViewGenerated;
        NSMutableArray *compPatientVUImages;
    
    IBOutlet UIButton *syncTopicBtn;
    
    UIView * closePatchoverlay;
}
@property (nonatomic,retain) welvuSpecialtyViewController *welvuSpecialty;
@property (nonatomic ,retain)  ProcessingSpinnerView *spinner;
@property(nonatomic,copy) NSString *tetTopicCount;
@property(nonatomic,readwrite) NSInteger getTopicCount;
@property (nonatomic, retain) AccordionView *accordion;
@property(nonatomic,assign)int update;
@property(nonatomic,retain) IBOutlet UIScrollView *myScroll;
@property(nonatomic,readwrite) BOOL scrolViewGenerated;
//Assigning the property for the delegate
@property(nonatomic,retain)    id<welvuMasterViewControllerDelegate>delegate;
@property (nonatomic, retain) IBOutlet UITableView *topicTableView;
@property (nonatomic, readwrite) NSInteger previousSelectedTopicId;
@property (nonatomic, copy) NSMutableArray *welvu_topicsModels;
@property (strong, nonatomic) welvuDetailViewControllerIpad *detailViewController;
@property (strong, nonatomic) welvuVideoMakerViewController *videomaker;
//Fade effect
@property (nonatomic, retain) UIColor* fadeColor;
@property (nonatomic, retain) UIColor* baseColor;
@property (nonatomic, retain) UIView* topFadingView;
@property (nonatomic, retain) CAGradientLayer *g1;
@property (nonatomic, retain) CAGradientLayer *g2;
@property (nonatomic, retain) UIView* bottomFadingView;
@property (nonatomic, assign) fade_orientation fadeOrientation;

//EMR
 @property (nonatomic, retain) UIView* eMRContainer;
@property (nonatomic, retain) UIView *specialtyContainer;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) UIButton *graphInfoBtn;
@property (nonatomic, retain) UIButton *patientInfo;
@property (nonatomic, weak) GMGridView *oemrPatientGMGridView;
@property (nonatomic, retain)NSMutableArray *oEMRPatientImages;
@property(nonatomic,readwrite) BOOL gridViewGenerated;
@property (nonatomic, retain) NSMutableArray *compPatientVUImages;

- (void) settingsUpdate;
- (void) reloadTableData;
- (void) refreshTableData;
- (void) orientationChanged:(NSNotification *)notification;
- (void) accordionScrollViewDidScroll:(UIScrollView *)aScrollView;


//Action methods
-(IBAction)specialtyBtnClicked:(id)sender;
-(IBAction)historyBtnClicked:(id)sender;
-(IBAction)settingBtnClicked:(id)sender;
-(IBAction)reviewTopicBtnClicked:(id)sender;
-(IBAction)feedBackBtnClicked:(id)sender;
-(IBAction)startSyncBtnClicked:(id)sender;

//EMR
-(void)intializeGMGridViews;
//user info
-(IBAction)userInfoBtnClicked:(id)sender;
-(IBAction)graphBTnClicked:(id)sender;
-(IBAction)selectAllPatientInfo:(id)sender;
-(void)showAccordian;
- (void) logoutUser;
-(void) topicDownloadFromBoxFinished:(BOOL)isChanged;
-(void) topicDownloadFromBoxDidFinished:(BOOL)isChanged;
-(void)switchToWelvuUSer;
- (void)syncContentToPlatformDidReceivedData:(BOOL)success :(NSDictionary *)responseDictionary;
- (void)addOrganizationUserDetails;
-(void) reloadAccordianTableData ;
-(void)removepatchinIos8;
-(void)closePatchForIos8 ;
@end
