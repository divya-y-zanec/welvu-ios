//
//  welvuTopicVUAnnotationViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 24/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "welvuSettingsMasterViewController.h"
#import "DrawingToolView.h"
#import "GestureControlView.h"

/*
 * Protocol name: welvuTopicVUAnnotationDelegate
 * Description: Delegate function for returning unarchived image/topic
 */
@protocol welvuTopicVUAnnotationDelegate
-(void)welvuTopicVUAnnotationDidFinish:(NSInteger) topic_id:(NSInteger) image_id:(BOOL) isModified;
-(void)userLoggedOutFromTopicVUAnnotation;
-(void)userSwitchAccountFromTopicVUAnnotation;
@end
/*
 * Class name: welvuTopicVUAnnotationViewController
 * Description: Has functionality To annotate video
 * Extends: UIViewController
 * Delegate :MFMailComposeViewControllerDelegate,UITextFieldDelegate,UIAlertViewDelegate
 */
@interface welvuTopicVUAnnotationViewController : UIViewController <UIAlertViewDelegate, SettingsMasterViewControllerDelegate, MFMailComposeViewControllerDelegate,UITextFieldDelegate,DrawingToolViewDelegate ,syncContentToPlatformHelperDelegate> {
    
    //Defining the delegate for this controller
    id<welvuTopicVUAnnotationDelegate> delegate;
    
    welvuAppDelegate *appDelegate;
    
    UIView *overlay;
    
    //Annotation container
    IBOutlet UIView *annotationContainer;
    
    //Annotation
    IBOutlet DrawingToolView *annotateView;
    
    //Gesture View
    IBOutlet GestureControlView *gestureView;
    
    //Locally generated variable
    NSInteger topicId;
    NSInteger imageId;
    NSInteger insertedImageId;
    NSMutableArray *imageGallery;
    IBOutlet UILabel *topicLabel;
    IBOutlet UIImageView *imageView;
    IBOutlet UIScrollView *imagesVUScrollView;
    //Toolbar Buttons
    IBOutlet UIButton *annotationPencilBtn;
    IBOutlet UIButton *annotationArrowBtn;
    IBOutlet UIButton *annotationTextViewBtn;
    IBOutlet UIButton *annotationSquareBtn;
    IBOutlet UIButton *annotationCircleBtn;
    IBOutlet UIButton *gestureBtn;
    IBOutlet UIBarButtonItem *saveAsBtn;
    
    //Gesture controls
    UITapGestureRecognizer *enable_disableAnnotation;
    UISwipeGestureRecognizer *swipeRight;
    UISwipeGestureRecognizer *swipeLeft;
    int update;
    
    //Theme view
    IBOutlet UIImageView *annotateBanner;
    IBOutlet UIImageView *themeLogo;
    IBOutlet UILabel *notificationLable;
}

//Assigning the property for delegate object
@property (retain) id<welvuTopicVUAnnotationDelegate> delegate;
@property (nonatomic ,retain) IBOutlet UILabel *notificationLable;
@property (nonatomic ,retain) IBOutlet UIImageView *themeLogo;
@property(nonatomic,assign) int update;
@property (nonatomic,retain) IBOutlet UIImageView *annotateBanner;

//Action methods

- (id)initWithImageGroup:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil currentTopicId:(NSInteger) topic_Id
                  images:(NSMutableArray *) topicVUImages currentSelectedImage: (NSInteger) currentImageRow annotateBlankCanvas:(BOOL) isAnnotateBlankCanvas;

-(id)initWithSelectedImage:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil currentTopicId:(NSInteger) topic_Id
                  imagesId:(NSInteger) image_id;
//Top Bar action
-(IBAction)settingsBtnClicked:(id)sender;
-(IBAction)feedBackBtnClicked:(id)sender;
-(IBAction)save_saveAsBtnClicked:(id)sender;
-(IBAction)closeBtnClicked:(id)sender;
-(IBAction)informationBtnClicked:(id)sender;
-(IBAction)closeOverlay:(id)sender;

- (void)themeSettingsViewControllerDidFinish ;

//Tools button
-(IBAction)gestureBtnClicked:(id)sender;
-(IBAction)enable_disableAnnotationBtnClicked:(id)sender;
-(IBAction)arrowBtnClicked:(id)sender;
-(IBAction)annotationTextBtnClicked:(id)sender;
-(IBAction)circlebtnclicked:(id)sender;
-(IBAction)squarebtnclicked:(id)sender;
-(IBAction)undoAnnotationBtnClicked:(id)sender;
-(IBAction)redoAnnotationBtnClicked:(id)sender;
-(IBAction)changeColorBtnClicked:(id)sender;
-(IBAction)clearAnnotationBtnClicked:(id)sender;
@end
