//
//  welvuSettingsGuideAnimationViewController.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 26/04/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "welvu_settings.h"
//Delegate method to return selected content
@protocol welvuSettingsGuideAnimationDelegate
- (void)welvuSettingsGuideAnimationDidFinish;
- (void)welvuSettingsGuideAnimationDidClose;
@end
/*
 * Class name: welvuSettingsGuideAnimationViewController
 * Description: To Display Animated assistance
 * Extends: UIViewController
 * Delegate : UITableViewDataSource,UITableViewDelegate
 */
@interface welvuSettingsGuideAnimationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    ////Assigning the delegate for the view
    id<welvuSettingsGuideAnimationDelegate> delegate;
     welvu_settings *currentWelvuSettings;
        IBOutlet UILabel *headerLabel;
    NSMutableArray * headers;
    NSUserDefaults *defaults;
    BOOL isAnimated;
    UISwitch *backgroundSwitch;
    welvuAppDelegate *appDelegate;
    
}
@property(nonatomic,readwrite) BOOL isAnimated;
@property(nonatomic,retain)UISwitch *backgroundSwitch;
//Assign the property for the delegate
@property(nonatomic,retain) id<welvuSettingsGuideAnimationDelegate> delegate;
- (id)initWithGuideAnimatiom:(welvu_settings *) welvu_settings ;
//Action methods
-(IBAction)doneBtnClicked:(id)sender;
-(IBAction)backBtnClicked:(id)sender;
@end
