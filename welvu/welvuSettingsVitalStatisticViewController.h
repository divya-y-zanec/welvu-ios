//
//  welvuSettingsVitalStatisticViewController.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 06/11/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "welvu_settings.h"
#import "welvuAppDelegate.h"

/*
 * Protocol name: VitalStatisticViewControllerDelegate
 * Description : To show vital statistic of the patient
 */
@protocol VitalStatisticViewControllerDelegate
- (void)VitalStatisticViewControllerDidFinish;
@end

@interface welvuSettingsVitalStatisticViewController : UIViewController <UITableViewDelegate> {
    id<VitalStatisticViewControllerDelegate> delegate;
    NSMutableArray *headers;
    //Current settings
    welvu_settings *currentWelvuSettings;
    IBOutlet UILabel *headerLabel;
    IBOutlet UITableView *vitalStaticsTableView;
    NSMutableArray *tableGroup;
    welvuAppDelegate *appDelegate;
}
//Property
@property (retain)  id<VitalStatisticViewControllerDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *headers;
@property (nonatomic,retain) NSMutableArray *tableGroup;
//Acton methods
-(IBAction)doneBtnClicked:(id)sender;
-(IBAction)backBtnClicked:(id)sender;
- (id)initwithVitalSettings:(welvu_settings *) welvu_settings_model;
@end
