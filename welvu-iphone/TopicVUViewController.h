//
//  TopicVUViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 15/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import "welvu_main_settings.h"
#import "welvuArchiveImageController.h"
#import "welvu_images.h"
#import "welvu_main_settings.h"
#import "welvuTopicVUAnnotationViewController.h"

@protocol topicVUViewControllerDelegate
- (void) topicVUViewControllerImageSelected:(welvu_images *) welvu_imagesModel;
- (void) topicVUViewControllerRemoveImageSelected:(welvu_images *) welvu_imagesModel;
- (void) topicVUViewControllerImageSelectedAll:(NSMutableArray *) welvu_imagesModels;
@end


@interface TopicVUViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPopoverControllerDelegate, welvuTopicVUAnnotationDelegate,
    UIAlertViewDelegate, welvuArchiveImageDelegate> {
    
    welvuAppDelegate *appDelegate;
    id<topicVUViewControllerDelegate>delegate;
    //Dataobtained from parent view
    NSInteger topicsId;
    BOOL retainPatientVU;
    NSMutableArray *compPatientVUImages;
    
    NSMutableArray *topicVUImages;
    
    //Is All Images From Topic Selected
    BOOL isAllTopicVUSelected;
    
    //current settings
    welvu_main_settings *currentMainSettings;
    
    //GMGridView
    GMGridView *topicVuGMGridView;
    
    //Topic label
    IBOutlet UILabel *topicLabel;
    
    ///Edit Option
    BOOL edit;
    
    IBOutlet UIButton *archiveTopicImageBtn;
    
    //Camera & Album
    UIImagePickerController *picker;
    UIPopoverController *popover;
    
    //Locally generated variable
    IBOutlet UIImageView *noimage;
    
    //Barbutton Items
    UIBarButtonItem *imagesReviewBtn;
    UIBarButtonItem *preAnnotation;
}
@property(retain)id<topicVUViewControllerDelegate>delegate;

@property (nonatomic, readwrite) NSInteger topicsId;
@property (nonatomic, retain) NSMutableArray *topicVUImages;
@property (nonatomic, retain) GMGridView *topicVuGMGridView;
@property (nonatomic, retain) IBOutlet UIImageView *noimage;

-(id)initwithTopicAndSettings:(NSInteger) topic_id:(welvu_main_settings *) current_settings
                             :(NSMutableArray *) patientVU_images;
@end
