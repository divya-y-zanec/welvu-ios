//
//  LayoutSettingsViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 25/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "welvu_settings.h"
#import "GMGridView.h"
//Delegate method to return selected content
@protocol LayoutSettingsViewControllerDelegate
- (void)layoutSettingsViewControllerDidFinish;
-(void)layoutSettingsViewControllerDidClose;
@end
/*
 * Class name: welvuLayoutSettingsViewController
 * Description: to show Layout in the settngs of the view
 * Extends: UIViewController
 *Delegate : UITableViewDelegate
 */
@interface welvuLayoutSettingsViewController : UIViewController <UITableViewDelegate> {
    //Assigning the delegate for the view
    id<LayoutSettingsViewControllerDelegate> delegate;
    NSMutableArray *headers;
    
    //Current settings
    welvu_settings *currentWelvuSettings;
    IBOutlet UILabel *headerLabel;
    IBOutlet UITableView *layoutTableView;
    
     __gm_weak GMGridView *topicVuGMGridView;
    NSMutableArray *topicVUImages;

    
}
//Assigning the Propert for the delegate 
@property (retain) id<LayoutSettingsViewControllerDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *headers;
@property (nonatomic, weak) GMGridView *topicVuGMGridView;
@property (nonatomic,retain) NSMutableArray *topicVUImages;

- (id)initWithLayoutSettings:(welvu_settings *) welvu_settings ;


- (void)sortStyleSegmentedControlChanged:(UISegmentedControl *)control;
- (void)layoutSpacingSliderChanged:(UISlider *)control;
- (void)debugGridLayoutSwitchChanged:(UISwitch *)control;
- (void)debugGridBackgroundSwitchChanged:(UISwitch *)control;

//Action Methods
-(IBAction)doneBtnClicked:(id)sender;
-(IBAction)backBtnClicked:(id)sender;
@end
