//
//  welvuTopicVUView.h
//  welvu
//
//  Created by Divya Yadav. on 19/12/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "welvuSettingsMasterViewController.h"
#import "GMGridView.h"
#import "welvu_images.h"
#import "welvu_settings.h"
#import "welvuTopicVUAnnotationViewController.h"
#import "welvuArchiveImageController.h"
#import "ELCImagePickerController.h"
#import "AccordionView.h"
#import "welvuDetailViewControllerIpad.h"
//#import "M13ProgressViewPie.h"

@class welvuTopicVUviewController;
/*
 * Protocol name: welvuMasterViewControllerDelegate
 * Description: Delegate function for master view controller
 */
@protocol welvuTopicVUViewDelegate <NSObject>

-(void)topicVUViewControllerRemoveImageSelected:(welvu_images *)welvu_imagesModel;
/*- (void) topicVUViewControllerImageSelected:(welvu_images *) welvu_imagesModel;
- (void) topicVUViewControllerImageSelectedWithPosition:(welvu_images *) welvu_imagesModel:(CGPoint) droppedPositon;
- (void) topicVUViewControllerImageSelectedAll:(NSMutableArray *) welvu_imagesModels;
- (void) topicVuViewControllerRefreshTableData;
-(void)showPresentViewController:(UIViewController*)viewController;*/
@end
/*
 * Class name: welvuTopicVUviewController
 * Description: Has functionality to display the image content
 * Extends: UIView
 * Delegate :UIAlertViewDelegate,
 UIPopoverControllerDelegate, UINavigationControllerDelegate,UIScrollViewDelegate
 */
@interface welvuTopicVUviewController : UIView <AccordionViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPopoverControllerDelegate,UIAlertViewDelegate ,welvuArchiveImageDelegate,ELCImagePickerControllerDelegate, UIScrollViewDelegate ,syncContentToPlatformHelperDelegate>
{
    //Assigning the delegate to the controller
    id<welvuTopicVUViewDelegate>delegate;
    welvuDetailViewControllerIpad *detailViewController;
  
    welvuAppDelegate *appDelegate;
 
    //Dataobtained from parent view
    NSInteger topicsId;
    BOOL retainPatientVU;
 
    NSMutableArray *topicVUImages;
    NSMutableArray *compPatientVUImages;

    //Is All Images From Topic Selected
    BOOL isAllTopicVUSelected;
    
    //Edit Option
    BOOL edit;
    
    //GMGridView
    __gm_weak GMGridView *topicVuGMGridView;
    
    //Topic label
    IBOutlet UILabel *topicLabel;
       //Barbutton Items
    UIBarButtonItem *imagesReviewBtn;
    IBOutlet UIButton *preAnnotation;
    IBOutlet UIButton *deleteBtn;
    IBOutlet UIButton *albumBtn;
   
    //Camera & Album
    UIImagePickerController *picker;
    UIPopoverController *popover;
    
    //Locally generated variable
    IBOutlet UIView *viewGrid;
    IBOutlet UIImageView *noimage;
    
    //Fade effect
    IBOutlet UIView*  _topFadingView;
    IBOutlet UIView*  _bottomFadingView;
     BOOL gridViewGenerated;
    
    BOOL accordianScrolViewGenerated;
    int updated;
    int update;
    //spinner
        ProcessingSpinnerView *spinner;
    //santhosh   20-mar-2013
    NSMutableDictionary *dictionaryArray;
   
IBOutlet UILabel *noContentAvailable;
}

@property (nonatomic ,retain)  IBOutlet UILabel *noContentAvailable;
@property(nonatomic,assign)int updated;
@property(nonatomic,assign) int update;
@property(nonatomic,readwrite)BOOL accordianScrolViewGenerated;
@property(nonatomic, retain) welvuMasterViewController *parentController;
//set property for the assigned delegate
@property (retain) id<welvuTopicVUViewDelegate> delegate;
@property (nonatomic, readwrite) NSInteger topicsId;
@property (nonatomic, retain) NSMutableArray *topicVUImages;
@property (nonatomic, weak) GMGridView *topicVuGMGridView;
@property (nonatomic, retain) IBOutlet UIImageView *noimage;
@property(nonatomic,readwrite) BOOL gridViewGenerated;

//Fade effect
@property (nonatomic, retain) UIView* topFadingView;
@property (nonatomic, retain) UIView* bottomFadingView;

@property (nonatomic, retain) ProcessingSpinnerView *spinner;

-(void)intializeSettings;
-(id)initwithTopic:(NSInteger) topic_id
                  :(NSMutableArray *) patientVU_images;
-(UIImage *)generateImageFromVideo:(NSString *) pathString:(NSString *)pathType;

-(void)intializeGMGridViews ;
-(void)loadMainVU :(NSInteger) topic_id
                  :(NSMutableArray *) patientVU_images;



-(void)updateTopicContents:(NSInteger) imageId;
-(void)editVUFinished:(NSInteger) imageId;
//Action methods

-(IBAction)reviewContentBtnClicked:(id)sender;
-(IBAction)archiveBtnClicked:(id)sender;
-(IBAction)blankImageBtnOnClicked:(id)sender;
-(IBAction)selectAllImagesBtnClicked:(id)sender;
-(IBAction)editBtnClicked:(id)sender;
-(IBAction) camButtonClicked:(id)sender;
-(IBAction) albumButtonClicked:(id)sender;
-(IBAction)backBtnClicked:(id)sender;
-(IBAction) deleteSelectedBtnOnClicked:(id)sender ;

- (void)syncContentToPlatformDidReceivedData:(BOOL)success :(NSDictionary *)responseDictionary;
@end


