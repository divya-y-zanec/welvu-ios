//
//  HistoryVUViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 24/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "welvuContants.h"
#import "welvu_images.h"

@protocol historyVUViewControllerDelegate
- (void)historyVUSelectedNumber:(NSInteger) historyNumber;
@end
@interface welvuHistoryVUViewController : UIViewController <UITableViewDelegate> {
    welvuAppDelegate *appDelegate;
    
    id<historyVUViewControllerDelegate> delegate;
    
    NSMutableArray *welvuHistoryModels;
    IBOutlet UITableView *historyTableView;
    
    NSInteger previousSelectedHistoryId;
    //Fade effect
    IBOutlet UIView*  _topFadingView;
    IBOutlet UIView*  _bottomFadingView;
    
    UIColor* fadeColor_;
    UIColor* baseColor_;
    
    CAGradientLayer *g1_;
    CAGradientLayer *g2_;
    
    fade_orientation fadeOrientation_;
    
    //Bar buttons
    UIBarButtonItem *reviewBtn;
}
@property (retain) id<historyVUViewControllerDelegate> delegate;

@property (nonatomic, retain) NSMutableArray *welvuHistoryModels;
@property (nonatomic, retain) IBOutlet UITableView *historyTableView;

@property (nonatomic, readwrite) NSInteger previousSelectedHistoryId;

//Fade effect
@property (nonatomic, retain) UIColor* fadeColor;
@property (nonatomic, retain) UIColor* baseColor;
@property (nonatomic, retain) CAGradientLayer *g1;
@property (nonatomic, retain) CAGradientLayer *g2;
@property (nonatomic, retain) UIView* topFadingView;
@property (nonatomic, retain) UIView* bottomFadingView;
@property (nonatomic, assign) fade_orientation fadeOrientation;

@end
