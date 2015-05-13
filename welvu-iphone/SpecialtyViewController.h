//
//  welvuDetailViewController.h
//  welvu
//
//  Created by Divya yadav on 27/09/12.
//  Copyright (c) 2012 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "welvuiPhoneContants.h"
#import "welvu_specialty.h"
//#import "specialtyViewController.h"
@protocol welvuViewControllerDelegate
//@class specialtyViewController;

@end
@interface specialtyViewController : UIViewController <UINavigationControllerDelegate,
UIPopoverControllerDelegate, UIAlertViewDelegate,welvuViewControllerDelegate> {
    id<welvuViewControllerDelegate> delegate;

    BOOL isShowingLandscapeView;
    
        NSInteger specialtyId;
    NSInteger selectedIndexRow;
    
    //Application delegate
    welvuAppDelegate *appDelegate;
    
    //Outlet tableview object
    IBOutlet UITableView *specialtyTableView;
    
    //Topics array object
    NSMutableArray *welvu_specialtyModels;
    
    
    //Topics header and footer fading view object
    //Fade effect
    IBOutlet UIView*  _topFadingView;
    IBOutlet UIView*  _bottomFadingView;
    
    UIColor* fadeColor_;
    UIColor* baseColor_;
    
    CAGradientLayer *g1_;
    CAGradientLayer *g2_;
    
    fade_orientation fadeOrientation_;
    
}


@property(nonatomic,retain) id<welvuViewControllerDelegate> delegate;

//Assigning the property for the outlet tableview object
@property (nonatomic, retain) IBOutlet UITableView *specialtyTableView;

//Assinging the property for the Topic array object
@property (nonatomic, retain) NSMutableArray *welvu_specialtyModels;

//Topics header and footer fading view object
//Fade effect
@property (nonatomic, retain) UIColor* fadeColor;
@property (nonatomic, retain) UIColor* baseColor;
//@property(atomic,retain) NSInteger specialtyId;
@property (nonatomic, retain) UIView* topFadingView;
@property (nonatomic, retain) UIView* bottomFadingView;

@property (nonatomic, retain) CAGradientLayer *g1;
@property (nonatomic, retain) CAGradientLayer *g2;

@property (nonatomic, assign) fade_orientation fadeOrientation;
-(IBAction)selectBtnClicked:(id)sender;

@end
