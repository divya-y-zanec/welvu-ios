//
//  welvuTopicViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 19/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "welvuTopicVUSubViewController.h"
#import "welvu_images.h"
#import "welvuContants.h"

@class welvuTopicViewController;

//Delegate to return selected content from the selected topic
@protocol welvuTopicViewControllerDelegate
- (void) welvuTopicViewControllerDidFinish:(welvu_images *)welvu_imagesModel;
@end


//Interface to view topics in popover controller
@interface welvuTopicViewController : UIViewController <UITableViewDelegate, welvuTopicVUViewControllerDelegate> {
    //Defining the delegate for this controller
    id<welvuTopicViewControllerDelegate> delegate;
    
    //Application delegate
    welvuAppDelegate *appDelegate;
    
    //Outlet tableview object
    IBOutlet UITableView *topicTableView;
    
    //Topics array object
    NSMutableArray *welvu_topicsModels;
    
    //Patient VU array object
    NSMutableArray *welvuImagesModels;
    
    
    //Topics header and footer fading view object
    //Fade effect
    IBOutlet UIView*  _topFadingView;
    IBOutlet UIView*  _bottomFadingView;
    
    UIColor* fadeColor_;
    UIColor* baseColor_;
    
    CAGradientLayer *g1_;
    CAGradientLayer *g2_;
    
    fade_orientation fadeOrientation_;
    IBOutlet UILabel *headerLabel;
    
}
//Assigning the property for delegate object
@property (retain) id<welvuTopicViewControllerDelegate> delegate;

//Assigning the property for the outlet tableview object
@property (nonatomic, retain) IBOutlet UITableView *topicTableView;

//Assinging the property for the Topic array object
@property (nonatomic, retain) NSMutableArray *welvu_topicsModels;


//Topics header and footer fading view object
//Fade effect
@property (nonatomic, retain) UIColor* fadeColor;
@property (nonatomic, retain) UIColor* baseColor;

@property (nonatomic, retain) UIView* topFadingView;
@property (nonatomic, retain) UIView* bottomFadingView;

@property (nonatomic, retain) CAGradientLayer *g1;
@property (nonatomic, retain) CAGradientLayer *g2;

@property (nonatomic, assign) fade_orientation fadeOrientation;

//Custom method to initialize the view controller
- (id)initWithExistingImagesModel:(NSMutableArray *)welvu_imagesModels;
@end
