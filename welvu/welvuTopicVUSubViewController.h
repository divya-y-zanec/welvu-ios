//
//  welvuTopicVUViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 19/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "welvu_topics.h"
#import "welvu_images.h"
#import "welvuContants.h"
@class welvuTopicVUSubViewController;

//Delegate method to return selected content
@protocol welvuTopicVUViewControllerDelegate
- (void)welvuTopicVUViewControllerDidFinish:(welvu_images *)welvu_imagesModel;
@end

//To populate topic images in popover controller
@interface welvuTopicVUSubViewController : UIViewController <UIScrollViewDelegate> {
    
    //Defining the delegate for this controller
    id<welvuTopicVUViewControllerDelegate> delegate;
    
    //Application delegate
    welvuAppDelegate *appDelegate;
    
    //Defining object to store information about selected topic
    welvu_topics *welvu_topicModel;
    
    //Defining topic images array object
    NSMutableArray *topicVUImages;
    
    //PatientVU images array object
    NSMutableArray *welvuImagesModel;
    
    //Outlet image object for no image available
    IBOutlet UIImageView *noimage;
    
    //Outlet tableview object
    IBOutlet UIScrollView *topicVuScrollView;
    IBOutlet UILabel *topicLabel;
    
    //Fade effect
    IBOutlet UIView*  _topFadingView;
    IBOutlet UIView*  _bottomFadingView;
    
    UIColor* fadeColor_;
    UIColor* baseColor_;
    
    CAGradientLayer *g1_;
    CAGradientLayer *g2_;
    
    fade_orientation fadeOrientation_;
}
//Assigning the property for delegate object
@property (retain) id<welvuTopicVUViewControllerDelegate> delegate;

//Assinging the property for the Topic images array object
@property (nonatomic, retain) NSMutableArray *topicVUImages;

//Topics header and footer fading view object
//Fade effect
@property (nonatomic, retain) UIColor* fadeColor;
@property (nonatomic, retain) UIColor* baseColor;

@property (nonatomic, retain) UIView* topFadingView;
@property (nonatomic, retain) UIView* bottomFadingView;

@property (nonatomic, retain) CAGradientLayer *g1;
@property (nonatomic, retain) CAGradientLayer *g2;

@property (nonatomic, assign) fade_orientation fadeOrientation;

//Custom intialization of controller with selected topic information
- (id)initWithWelvuTopic:(welvu_topics *)topic_model:(NSMutableArray *)welvu_imagesModel;
- (IBAction)backBtnClicked:(id)sender;
@end
