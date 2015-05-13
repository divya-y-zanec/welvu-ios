//
//  TopicSortSettingsViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 25/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "welvu_settings.h"
#import "welvuAppDelegate.h"
//Delegate method to return selected content
@protocol TopicSettingsViewControllerDelegate
- (void)topicSettingsViewControllerDidFinish;
-(void)topicSettingsViewControllerDidClose;
@end
/*
 * Class name: welvuTopicSortSettingsViewController
 * Description: To show the TopicVU List Order in settings
 * Extends: UIViewController
 * Delegate : UITableViewDelegate
 */
@interface welvuTopicSortSettingsViewController : UIViewController <UITableViewDelegate> {
    //Assign the Delegate for the view controller
    id<TopicSettingsViewControllerDelegate> delegate;
    NSMutableArray *headers;
    
    //Current settings
    welvu_settings *currentWelvuSettings;
    IBOutlet UILabel *headerLabel;
    IBOutlet UITableView *topicSortTableView;
    welvuAppDelegate *appdelegate;

}
//Assign the property for the delegate
@property (retain) id<TopicSettingsViewControllerDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *headers;

- (id)initWithTopicSortSettings:(welvu_settings *)welvu_settings;
//Acton methods
-(IBAction)doneBtnClicked:(id)sender;
-(IBAction)backBtnClicked:(id)sender;
@end
