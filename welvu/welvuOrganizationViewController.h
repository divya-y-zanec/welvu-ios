//
//  welvuOrganizationViewController.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 23/01/14.
//  Copyright (c) 2014 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "welvuAppDelegate.h"
#import <sqlite3.h>
#import "welvuSettingsMasterViewController.h"
#import "welvu_user.h"
#import "welvu_organization.h"
#import "HTTPRequestHandler.h"
#import "welvuContants.h"

//Delegate method to return selected content
@protocol welvuOrganizationViewControllerDelegate
-(void)welvuOrganizationViewControllerDidFinish;
-(void)userLoggedOutFromOrganizationViewController;
@end

/*
 * Class name: welvuOrganizationViewController
 * Description:User can view their organizaton details
 * Extends: UIViewController
 * Delegate :UITableViewDelegate
 */
@interface welvuOrganizationViewController : UIViewController<UITableViewDelegate,
UITableViewDataSource ,SettingsMasterViewControllerDelegate, HTTPRequestHandlerDelegate > {
    //Defining the delegate for this controller
    id<welvuOrganizationViewControllerDelegate> delegate;
    welvuAppDelegate *appDelegate;
    IBOutlet UITableView *organnizationsListTable;
    NSMutableArray *welvu_OrganizationArray;
    NSMutableArray * matchDataArray;
    IBOutlet UIImageView *themeLogo;
    welvuSettingsMasterViewController *masterView;
    NSMutableArray *specialtyTypes;
    //Recording animation text
    ProcessingSpinnerView *spinner;
    //Fadding
    UIColor* fadeColor_;
    UIColor* baseColor_;
    CAGradientLayer *g1_;
    CAGradientLayer *g2_;
    CAGradientLayer *g3_;
    CAGradientLayer *g4_;
    CAGradientLayer *g9_;
    IBOutlet UIView *patientTopFaddingView;
    IBOutlet UIView *patientBottomFaddingView; UIColor* fadeColor;
    UIColor* baseColor;
    fade_orientation fadeOrientation;
    UIView *overlay;
    
    NSURLConnection *getSpecialty;
    NSURLConnection *getOrganization;
    
    NSURLConnection *authorize;
    NSString *responseStr;
    NSInteger organizationCount;
    BOOL orgCountPin;
    welvu_user *welvu_userModel;
    welvu_organization *welvu_organizationModel;
    
    int indexRow;

}
@property (nonatomic ,readwrite)int indexRow;

@property (nonatomic,retain)welvu_organization *welvu_organizationModel;

//Fadding
@property (nonatomic, assign) fade_orientation fadeOrientation;
@property (nonatomic ,retain)  IBOutlet UIView *patientTopFaddingView;
@property (nonatomic ,retain)  IBOutlet UIView *patientBottomFaddingView;
@property (nonatomic, retain) CAGradientLayer *g1;
@property (nonatomic, retain) CAGradientLayer *g2;
@property (nonatomic, retain) CAGradientLayer *g3;
@property (nonatomic, retain) CAGradientLayer *g4;
@property (nonatomic, retain) CAGradientLayer *g9;
@property (nonatomic, retain) UIColor* fadeColor;
@property (nonatomic, retain) UIColor* baseColor;
//Assigning the property for the delegate object
@property (retain) id<welvuOrganizationViewControllerDelegate> delegate;
@property (retain,nonatomic) IBOutlet UIImageView *themeLogo;
@property (nonatomic,retain) NSMutableArray *matchDataArray;
@property (nonatomic,retain)IBOutlet UITableView *organnizationsListTable;
@property (nonatomic,retain) NSMutableArray *welvu_OrganizationArray;
//Action Methods
-(IBAction)settingBtnClicked:(id)sender;
-(IBAction)skipToWelVUBtnClicked:(id)sender;
-(IBAction)goButtonClicked:(id)sender;
-(IBAction)orgSyncBtnClicked:(id)sender;
-(IBAction)informationBtnClicked:(id)sender;
-(void)organizationDetailedList;


@end
