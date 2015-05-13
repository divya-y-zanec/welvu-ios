//
//  welvuArchiveTopicController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 22/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "welvuContants.h"

@class welvuArchiveTopicController;

//Delegate function for returning unarchived topic
@protocol welvuArchiveTopicDelegate
-(void)welvuArchiveForTopicDidFinish:(BOOL) isModified;
@end

@interface welvuArchiveTopicController : UIViewController <UITableViewDelegate> {
    //Assigning delegate for this controller
    id<welvuArchiveTopicDelegate> delegate;
    
    //Application delegate
    welvuAppDelegate *appDelegate;
    
    //Topic archive title label
    IBOutlet UILabel *topicArchive;
    
    //Outlet tableview object
    IBOutlet UITableView *topicTableView;
    
    //Topics array object
    NSMutableArray *welvu_topicsModels;
    
    
    //Topics header and footer fading view object
    //Fade effect
    IBOutlet UIView*  _topFadingView;
    IBOutlet UIView*  _bottomFadingView;
    
    UIColor* fadeColor_;
    UIColor* baseColor_;
    
    CAGradientLayer *g1_;
    CAGradientLayer *g2_;
    NSInteger counter;
    int update;
    fade_orientation fadeOrientation_;
}
//Assigning the property for delegate object
@property (retain) id<welvuArchiveTopicDelegate> delegate;

//Assigning the property for the outlet tableview object
@property (nonatomic, retain) IBOutlet UITableView *topicTableView;

//Assinging the property for the Topic array object
@property (nonatomic, retain) NSMutableArray *welvu_topicsModels;

@property(nonatomic,assign) int update;
//Topics header and footer fading view object
//Fade effect
@property (nonatomic, retain) UIColor* fadeColor;
@property (nonatomic, retain) UIColor* baseColor;

@property (nonatomic, retain) UIView* topFadingView;
@property (nonatomic, retain) UIView* bottomFadingView;

@property (nonatomic, retain) CAGradientLayer *g1;
@property (nonatomic, retain) CAGradientLayer *g2;
@property (nonatomic) NSInteger counter;


@property (nonatomic, assign) fade_orientation fadeOrientation;

@end
