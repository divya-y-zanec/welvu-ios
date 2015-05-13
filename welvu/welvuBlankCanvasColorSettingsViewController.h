//
//  welvuBlankCanvasColorSettingsViewController.h
//  welvu
//
//  Created by Divya Yadav. on 06/11/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "welvu_settings.h"
//Delegate method to return selected content
@protocol BlankSettingsViewControllerDelegate
- (void)blankSettingsViewControllerDidFinish;
-(void)blankSettingsViewControllerDidClose;
@end
/*
 * Class name: welvuBlankCanvasColorSettingsViewController
 * Description: To Display the blank canvas color 
 * Extends: UIViewController
 * Delegate : UITableViewDelegate
 */
@interface welvuBlankCanvasColorSettingsViewController : UIViewController<UITableViewDelegate> {
    //Assign the delegate for the view
    id<BlankSettingsViewControllerDelegate> delegate;
    NSMutableArray *headers;
    welvu_settings *currentWelvuSettings;
    IBOutlet UILabel *headerLabel;
    IBOutlet UITableView *blankTableView;
    welvuAppDelegate *appDelegate;
}
//Assign the Property for the delegate 
@property(retain) id<BlankSettingsViewControllerDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *headers;
- (id)initWithBlankCanvasColorSettings:(welvu_settings *)welvu_settings;
//Action methods
-(IBAction)doneBtnClicked:(id)sender;
-(IBAction)backBtnClicked:(id)sender;
@end
