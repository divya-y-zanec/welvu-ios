//
//  VideoSettingsViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 25/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "welvu_settings.h"
#import "welvuAppDelegate.h"
//Delegate method to return selected content
@protocol VideoSettingsViewControllerDelegate
- (void)videoSettingsViewControllerDidFinish;
-(void)videoSettingsViewControllerDidClose;
@end
/*
 * Class name: welvuLayoutSettingsViewController
 * Description: to show Layout in the settngs of the view
 * Extends: UIViewController
 *Delegate : UITableViewDelegate
 */
@interface welvuVideoSettingsViewController : UIViewController <UITableViewDelegate> {
    //Assigning the delegate for the view controller
    id<VideoSettingsViewControllerDelegate> delegate;
   
    IBOutlet UILabel *headerLabel;
    IBOutlet UITableView *videoSettingsTableView;
    
    NSMutableArray *tableGroup;
    NSMutableArray *headers;
    welvu_settings *currentWelvuSettings;
    welvuAppDelegate *appDelegate;
    
}
//Assigning the Property for the Delegate
@property (retain) id<VideoSettingsViewControllerDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *tableGroup;
@property (nonatomic,retain) NSMutableArray *headers;

-(id) initWithVideoSettings:(welvu_settings *) welvu_settings_model;
//Action methods
-(IBAction)doneBtnClicked:(id)sender;
-(IBAction)backBtnClicked:(id)sender;
@end
