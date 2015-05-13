//
//  SettingsMasterViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 25/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BoxSDK/BoxSDK.h>
#import "welvuTopicSortSettingsViewController.h"
#import "welvuLayoutSettingsViewController.h"
#import "welvuVideoSettingsViewController.h"
#import "welvuEmailSettingsViewController.h"
#import "welvuBlankCanvasColorSettingsViewController.h"
#import "welvuSettingsGuideAnimationViewController.h"

#import "welvu_settings.h"
#import "welvuSettingsThemeViewController.h"
#import "welvuSettingsVitalStatisticViewController.h"
#import "ProcessingSpinnerView.h"


//Delegate method to return selected content
@protocol SettingsMasterViewControllerDelegate
- (void)logoutUser;
- (void)settingsMasterViewControllerDidFinish;
- (void)settingsMasterViewControllerDidCancel;
-(void)switchToWelvuUSer;
@end
/*
 * Class name: welvuSettingsMasterViewController
 * Description: to show Settings of the view
 * Extends: UIViewController
 *Delegate : UITableViewDelegate
 */

@interface welvuSettingsMasterViewController : UIViewController <UITableViewDelegate, LayoutSettingsViewControllerDelegate, VideoSettingsViewControllerDelegate, EmailSettingsViewControllerDelegate,
TopicSettingsViewControllerDelegate, BlankSettingsViewControllerDelegate,welvuSettingsGuideAnimationDelegate ,ThemeSettingsViewControllerDelegate ,VitalStatisticViewControllerDelegate, UIAlertViewDelegate> {
    
    welvuAppDelegate *appDelegate;
    //Assigning the delegate for the view
    id<SettingsMasterViewControllerDelegate> delegate;
    
    IBOutlet UILabel *headerLabel;
    IBOutlet UITableView *settingsTableView;
    
    UIView *overlay;
    UISwitch *control;
    
    NSMutableArray *headers;
    welvuSettingsGuideAnimationViewController *guideanimation;
    welvu_settings *currentWelvuSettings;
    
    IBOutlet UILabel *displayVersion;
    
    ProcessingSpinnerView *spinner;
    IBOutlet UIButton *logOutBtn;
    IBOutlet UIButton *switchWelVUBtn;
    NSString *orgVUController;
    
}
@property (nonatomic ,retain) NSString *orgVUController;
@property (nonatomic ,retain) IBOutlet UIButton *switchWelVUBtn;

@property (nonatomic ,retain)  IBOutlet UILabel *displayVersion;
//Assigning the Property for the delegate
@property (retain) id<SettingsMasterViewControllerDelegate> delegate;

@property (nonatomic,retain) NSMutableArray *headers;
@property (nonatomic, retain) welvu_settings *currentWelvuSettings;
//Action Methods
-(IBAction)doneBtnClicked:(id)sender;
-(IBAction)cancelBtnClicked:(id)sender;
-(IBAction)informationBtnClicked:(id)sender;
-(IBAction)closeOverlay:(id)sender;
-(IBAction)logoutBtnClicked:(id)sender;
-(IBAction)skipToWelVUBtnClicked:(id)sender;
@end
