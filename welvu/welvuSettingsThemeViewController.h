//
//  welvuSettingsThemeViewController.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 03/09/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "welvu_settings.h"
#import "welvuAppDelegate.h"
//Delegate method to return selected content
@protocol ThemeSettingsViewControllerDelegate
- (void)themeSettingsViewControllerDidFinish;
@end
/*
 * Class name: welvuTopicSortSettingsViewController
 * Description: To show the TopicVU List Order in settings
 * Extends: UIViewController
 * Delegate : UITableViewDelegate
 */
@interface welvuSettingsThemeViewController : UIViewController <UITableViewDelegate> {
    //Assign the Delegate for the view controller
    id<ThemeSettingsViewControllerDelegate> delegate;
    NSMutableArray *headers;
    
    //Current settings
    welvu_settings *currentWelvuSettings;
    IBOutlet UILabel *headerLabel;
    IBOutlet UITableView *topicSortTableView;
    welvuAppDelegate *appDelegate;
}
//Assign the property for the delegate
@property (retain) id<ThemeSettingsViewControllerDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *headers;

- (id)initWithThemeSettings:(welvu_settings *) welvu_settings ;
//Acton methods
-(IBAction)doneBtnClicked:(id)sender;
-(IBAction)backBtnClicked:(id)sender;
@end
