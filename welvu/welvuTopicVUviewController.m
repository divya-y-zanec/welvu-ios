//
//  welvuTopicVUView.m
//  welvu
//
//  Created by Divya Yadav. on 19/12/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//


#import "GMGridView.h"
#import "GMGridViewLayoutStrategies.h"
#import "AccordionView.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "welvuSettingsMasterViewController.h"
#import "welvu_images.h"
#import "welvu_settings.h"
#import "welvuTopicVUAnnotationViewController.h"
#import "welvuArchiveImageController.h"
#import "ELCImagePickerController.h"
#import "AccordionView.h"
#import "ELCAlbumPickerController.h"
#import "GAI.h"
#import "welvu_alerts.h"
#import "welvu_history.h"
#import "UIImage+Resize.h"
#import "welvuContants.h"
#import "welvuMasterViewController.h"
#import "welvuTopicVUviewController.h"
#import "NSFileManagerDoNotBackup.h"
#import "SyncDataToCloud.h"
#import "Guid.h"
#import "welvu_sync.h"
#import "UIDeviceHardware.h"
//#import "SBJSON.h"
#import "welvuContants.h"
#import "PathHandler.h"
#import "ELCAlbumPickerViewController.h"
#define NUMBER_ITEMS_ON_LOAD 250
#define NUMBER_ITEMS_ON_LOAD2 30

@interface welvuTopicVUviewController () <GMGridViewDataSource, GMGridViewSortingDelegate,
GMGridViewActionDelegate> {
    NSInteger _lastDeleteItemIndexAsked;
    CGPoint droppedPositon;
}
//-(void)showPresentViewController:(UIViewController *)viewController;
//-(void) initializeView;
-(void)intializeGMGridViews;
-(void)loadVU;
-(void) removeTopicVuImages;
-(void) updateOrderTopicVUImages;
@end
@implementation welvuTopicVUviewController;

@synthesize parentController;
@synthesize delegate;
@synthesize topicVuGMGridView, topicsId, topicVUImages, noimage;
@synthesize topFadingView = _topFadingView;
@synthesize bottomFadingView = _bottomFadingView;
@synthesize gridViewGenerated,update;
@synthesize accordianScrolViewGenerated,updated, spinner ,noContentAvailable;
__gm_weak GMGridView *_gmGridView;
__gm_weak NSMutableArray *_currentData;
NSInteger _lastDeleteItemIndexAsked ;
/*
 - (id)initWithCoder:(NSCoder *)aDecoder {
 if ((self = [super initWithCoder:aDecoder])) {
 [[NSBundle mainBundle] loadNibNamed:@"welvuTopicVUView" owner:self options:nil];
 }
 return self;
 }
 */

/*
 * Method name: intializeSettings
 * Description: initlize the grid view,bg  style for the view
 * Parameters: <#parameters#>
 * return <#value#>
 */
-(void)intializeSettings {
    self.topicVuGMGridView.itemSpacing = ((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_spacing;
    [self.topicVuGMGridView layoutSubviewsWithAnimation:GMGridViewItemAnimationFade];
    
    self.topicVuGMGridView.style = ((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_style;
    
    switch (((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_grid_layout) {
        case SETTINGS_CONTENT_VU_GRID_BG_NONE:
            [self.topicVuGMGridView reloadData];
            break;
        case SETTINGS_CONTENT_VU_GRID_BG:
            [self.topicVuGMGridView reloadData];
            break;
        default:
            break;
    }
    
    switch (((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_grid_bg) {
        case SETTINGS_CONTENT_VU_GRID_BG_NONE:
            self.topicVuGMGridView.backgroundColor = [UIColor clearColor];
            break;
        case SETTINGS_CONTENT_VU_GRID_BG:
            self.topicVuGMGridView.backgroundColor = [UIColor lightGrayColor];
            break;
        default:
            break;
    }
}

/*
 * Method name: initwithTopic
 * Description: Initlize with topic with topicid and images
 * Parameters: topic_id,patientVU_images
 * return id
 */
-(id)initwithTopic:(NSInteger) topic_id:(NSMutableArray *) patientVU_images {
    //self = [super initWithNibName:@"welvuTopicVUView" bundle:nil];
    if (self) {
        // Custom initialization
        //self.navigationItem.hidesBackButton = YES;
        gridViewGenerated=TRUE;
        
        
        
        
        topicsId = topic_id;
        compPatientVUImages = patientVU_images;
        retainPatientVU = TRUE;
        // [self loadMainVU];
        gridViewGenerated=FALSE;
        // scrolViewGenerated=FALSE;
        [self intializeSettings];
        [self loadVU];
        [self intializeGMGridViews];
        
        
        if(appDelegate.imageId <= 0) {
            preAnnotation.enabled = false;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearedAllPatientVU:) name:NOTIFY_CLEARALL_PATIENTVU object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removedContentFromPatientVU:) name:NOTIFY_REMOVED_FROM_PATIENTVU object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopEditShaking:)name:NOTIFY_TAP_FROM_DETAILVU
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(intializeSettings) name:NOTIFY_SETTINGS_UPDATED object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setLastSelectedId:) name:NOTIFY_LAST_SELECTED_IMAGE_ID object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setLastSelectedId1:) name:@"annoatationviewcancel" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeTopicVUObserver:) name:@"removeTopicVUObserver" object:nil];
        //STM
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectedAllTopicImages:)
                                                     name:@"tempSelectedAll"
                                                   object:nil];
    }
    return self;
}
//Remove  observer for notification
-(void) removeTopicVUObserver:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFY_CLEARALL_PATIENTVU object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFY_REMOVED_FROM_PATIENTVU object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFY_TAP_FROM_DETAILVU
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFY_SETTINGS_UPDATED object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFY_LAST_SELECTED_IMAGE_ID object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"annoatationviewcancel" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"removeTopicVUObserver" object:nil];
    //STM
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"tempSelectedAll"
                                                  object:nil];
}
//select all images from topic
//STM
-(void)selectedAllTopicImages:(NSNotification *)notification {
    NSDictionary *theData = [notification userInfo];
    NSNumber *currentTopicId=[theData objectForKey:@"topicId"];
    if([currentTopicId integerValue] == topicsId) {
        [self performSelector:@selector(selectAllImagesBtnClicked:) withObject:nil];
    }
}

- (void) stopEditShaking:(NSNotification *)notification {
    deleteBtn.selected = FALSE;
    self.topicVuGMGridView.editing = FALSE;
}
//Search images from group
-(NSInteger) searchImageGroups:(NSInteger) imgId:(NSMutableArray *) imagesArray {
    
    for(int i=0; i < imagesArray.count; i++) {
        welvu_images *img = [imagesArray objectAtIndex:i];
        if(img.imageId == imgId) {
            return i;
        }
    }
    return -1;
}

-(void)loadMainVU :(NSInteger) topic_id
                  :(NSMutableArray *) patientVU_images
{
    
    if(appDelegate.imageId > LOCAL_IMAGE_CONTENT_ID_START_RANGE){
        preAnnotation.enabled=true;
    } else {
        preAnnotation.enabled=false;
    }
    
    //scrolViewGenerated=TRUE;
    /*  NSLog(@"the images %@",patientVU_images);
     NSLog(@"topicid %d",topic_id);
     topicsId = topic_id;
     compPatientVUImages = patientVU_images;
     retainPatientVU = TRUE;*/
}
- (void)setLastSelectedId1:(NSNotification *)notification {
    if(appDelegate.imageId <= 0) {
        preAnnotation.enabled = true;
    } else {
        preAnnotation.enabled = false;
    }
}

- (void)setLastSelectedId:(NSNotification *)notification {
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    welvu_images *welvu_imagesModel = [welvu_images getImageById
                                       :[appDelegate getDBPath]
                                       :appDelegate.imageId
                                       userId:appDelegate.welvu_userModel.welvu_user_id];
    
    
    if((appDelegate.imageId >= LOCAL_TEMP_CONTENT_ID_START_RANGE)
       && (appDelegate.imageId < LOCAL_IMAGE_CONTENT_ID_START_RANGE)
       || ([welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_TYPE]
           || [welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE])) {
           preAnnotation.enabled = false;
           
       } else {
           preAnnotation.enabled = true;
       }
    
    if(welvu_imagesModel.imageId<=0)
    {
        preAnnotation.enabled = false;
        
    }
}
//Remove the image/video content from patientvu
- (void) removedContentFromPatientVU:(NSNotification *)notification {
    NSInteger index = [self searchImageGroups:((welvu_images *)[notification.userInfo objectForKey:TABLE_WELVU_IMAGES]).imageId :topicVUImages];
    if(index > -1) {
        welvu_images *welvu_imagesModel = [topicVUImages objectAtIndex:index];
        if(welvu_imagesModel.selected) {
            NSInteger index = [self searchImageGroups:welvu_imagesModel.imageId :topicVUImages];
            welvu_imagesModel.selected = NO;
            GMGridViewCell *cell = (GMGridViewCell *)[self.topicVuGMGridView cellForItemAtIndex:index];
            for(UIView *subview in [cell.contentView subviews]) {
                if([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)subview;
                    imageView.image = [[imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER]
                                       makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                    
                }
            }
            cell.isSelected = FALSE;
        }
    }
}

-(void)loadVU {
    [self bringSubviewToFront:_bottomFadingView];
    [self bringSubviewToFront:_topFadingView];
    gridViewGenerated=TRUE;
    isAllTopicVUSelected = FALSE;
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    // topicLabel.text = [welvu_topics getTopicNameById:appDelegate.getDBPath :topicsId];
    topicVUImages = [welvu_images getImagesByTopicId:appDelegate.getDBPath :topicsId
                                              userId:appDelegate.welvu_userModel.welvu_user_id];
    for(welvu_images *welvu_imagesModel in topicVUImages) {
        if([self searchImageGroups:welvu_imagesModel.imageId
                                  :compPatientVUImages] > -1) {
            welvu_imagesModel.selected = TRUE;
        } else  {
            welvu_imagesModel.selected = FALSE;
        }
    }
    
    //to hide delete button when admin slide is there
    for(welvu_images *welvu_imagesModel in topicVUImages) {
        
        if([welvu_imagesModel.type isEqualToString:IMAGE_BLANK_TYPE] || [welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] ||  [welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE] ) {
            deleteBtn.enabled = YES;
        } else {
             deleteBtn.enabled = NO;
        }
    }
    
    [self.topicVuGMGridView reloadData];
    
    if([topicVUImages count] == 0) {
        noContentAvailable.hidden = FALSE;
    } else {
        noContentAvailable.hidden = TRUE;
    }
    
    if(topicVUImages != nil && !retainPatientVU) {
        appDelegate.ispatientVUContent = TRUE;
        
        /*patientVUImages = [topicVUImages mutableCopy];
         [patientVuGMGridView reloadData];*/
        
    } else if(topicVUImages == nil && !retainPatientVU) {
        appDelegate.ispatientVUContent = FALSE;
        /*if(patientVUImages != nil) {
         [patientVUImages release], patientVUImages = nil;
         }
         
         patientVUImages = [[NSMutableArray alloc] init];
         
         [patientVuGMGridView reloadData];*/
    }
    
    isAllTopicVUSelected = FALSE;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//Intializing GridViews
//////////////////////////////////////////////////////////
-(void)intializeGMGridViews {
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    GMGridView *topicVuGMGrid = [[GMGridView alloc] initWithFrame:CGRectMake(0, 40, 268, 280)];
    
    //self.topicVuGMGridView.autoresizesSubviews = NO;
    topicVuGMGrid.clipsToBounds = YES;
    //topicVuGMGrid.backgroundColor = [UIColor redColor];
    [self addSubview:topicVuGMGrid];
    self.topicVuGMGridView = topicVuGMGrid;
    self.topicVuGMGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    self.topicVuGMGridView.style = GMGridViewStylePush;
    self.topicVuGMGridView.itemSpacing =((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_spacing;
    
    
    self.topicVuGMGridView.minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    self.topicVuGMGridView.centerGrid = NO;
    self.topicVuGMGridView.enableEditOnLongPress = NO;
    self.topicVuGMGridView.disableEditOnEmptySpaceTap = YES;
    self.topicVuGMGridView.delegate = self;
    self.topicVuGMGridView.actionDelegate = self;
    self.topicVuGMGridView.sortingDelegate = self;
    self.topicVuGMGridView.dataSource = self;
    self.topicVuGMGridView.mainSuperView = appDelegate.splitViewController.view;
}



/*Required*/
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [topicVUImages count];
}

/*Required*/
- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    
    if (!INTERFACE_IS_PHONE)
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            if(((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_grid_layout) {
                
                return CGSizeMake(THUMB_BUTTON_GRID_WIDTH, THUMB_BUTTON_GRID_HEIGHT);
                
            } else {
                
                return CGSizeMake(THUMB_BUTTON_WIDTH, THUMB_BUTTON_HEIGHT);
                
            }
        }
        else
        {
            if(((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_grid_layout) {
                
                return CGSizeMake(THUMB_BUTTON_GRID_WIDTH, THUMB_BUTTON_GRID_HEIGHT);
                
            } else {
                
                return CGSizeMake(THUMB_BUTTON_WIDTH, THUMB_BUTTON_HEIGHT);
                
            }
        }
    }
    return CGSizeMake(THUMB_BUTTON_WIDTH, THUMB_BUTTON_HEIGHT);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:
                   [[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    CGSize destinationSize;
    if(((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_grid_layout) {
        
        destinationSize = CGSizeMake(THUMB_IMAGE_GRID_WIDTH, THUMB_IMAGE_GRID_HEIGHT);
        
    } else {
        
        destinationSize = CGSizeMake(THUMB_IMAGE_WIDTH, THUMB_IMAGE_HEIGHT);
        
    }
    if (!cell)
    {
        
        cell = [[GMGridViewCell alloc] init];
        /* cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
         cell.deleteButtonOffset = CGPointMake(-15, -15);*/
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 8;
        view.contentMode = UIViewContentModeCenter;
        cell.contentView = view;
        
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImage *thumbnail = nil;
    
    welvu_images *welvu_imagesModel = [topicVUImages objectAtIndex:index];
    
    if([welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE]
       || [welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_TYPE]) {
        cell.deleteButtonOffset = CGPointMake(-500, -500);
    } else {
        cell.deleteButtonIcon = [UIImage imageNamed:@"ContCloseButton.png"];
        cell.deleteButtonOffset = CGPointMake(0, 0);
    }
    
    
    if([welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE]) {
        // NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        UIImage *originalImage = [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
    } else if(([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE]
               ||[welvu_imagesModel.type isEqualToString:IMAGE_HISTORY_TYPE])&& welvu_imagesModel.imageId > 0) {
        // NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        UIImage *originalImage = [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
    } else if([welvu_imagesModel.type isEqualToString:IMAGE_BLANK_TYPE]) {
        UIImage *originalImage = [UIImage imageNamed:welvu_imagesModel.url];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
    }else if([welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_TYPE]
             || [welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE]) {
        UIImage *originalImage = [self generateImageFromVideo:welvu_imagesModel.url :welvu_imagesModel.type];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
    }
    if(welvu_imagesModel.selected) {
        cell.isSelected = TRUE;
        thumbnail  = [thumbnail imageWithBorderForSelected:THUMB_IMAGE_BORDER];
        //cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"imageBackground1.png"]];
    } else {
        cell.isSelected = FALSE;
        thumbnail  = [thumbnail imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
        
        
        //  cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"imageBackground3.png"]];
    }
    thumbnail = [thumbnail makeRoundCornerImage:5 :5 ];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = thumbnail;
    [cell.contentView addSubview:imageView];
    cell.indexTag = welvu_imagesModel.imageId;
    return cell;
    
}

- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    
    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {
    [topicVuGMGridView reloadData];
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    GMGridViewCell *cell = (GMGridViewCell *)[gridView cellForItemAtIndex:position];
    if(!cell.isSelected   && !edit) {
        for(UIView *subview in [cell.contentView subviews]) {
            if([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)subview;
                imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                
            }
        }
        cell.isSelected = TRUE;
        welvu_images *welvu_imagesModel = [topicVUImages objectAtIndex:position];
        welvu_imagesModel.selected = YES;
        // [self.delegate topicVUViewControllerImageSelected:welvu_imagesModel];
        
        /*  NSData *imageData = UIImagePNGRepresentation(welvu_imagesModel.imageData);
         NSDictionary *jsonObject=[NSJSONSerialization
         JSONObjectWithData:imageData
         options:NSJSONReadingMutableLeaves
         error:nil];*/
        
        NSDictionary *imageDetailsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                welvu_imagesModel, @"welvu_imagesModel", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_IMAGE_SELECTED object:self userInfo:imageDetailsDictionary];
        appDelegate.ispatientVUContent = TRUE;
        
    } else if(cell.isSelected && !edit){
        
        for(UIView *subview in [cell.contentView subviews]) {
            if([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)subview;
                imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                
            }
            
            cell.isSelected = FALSE;
            welvu_images *welvu_imagesModel = [topicVUImages objectAtIndex:position];
            welvu_imagesModel.selected = NO;
            //[self.delegate topicVUViewControllerRemoveImageSelected:welvu_imagesModel];
            
            NSDictionary *imageDetailsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                    welvu_imagesModel, @"welvu_ImageRemoved", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_IMAGE_REMOVED object:self userInfo:imageDetailsDictionary];
        }
    }/* else if (edit) {
      //Image annotation part
      welvuTopicVUAnnotationViewController *welvuTopicVUAnnotation = [[welvuTopicVUAnnotationViewController alloc]
      initWithImageGroup:@"welvuTopicVUAnnotationViewController" bundle:nil
      currentTopicId:topicsId
      images:topicVUImages currentSelectedImage:position annotateBlankCanvas:false];
      welvuTopicVUAnnotation.delegate = self;
      welvuTopicVUAnnotation.modalPresentationStyle = UIModalPresentationFullScreen;
      welvuTopicVUAnnotation.modalTransitionStyle = UIModalTransitionStyleCoverVertical; //transition shouldn't matter
      [self presentModalViewController:welvuTopicVUAnnotation animated:YES];
      [welvuTopicVUAnnotation release];
      }*/
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    
    if(gridView == self.topicVuGMGridView) {
        deleteBtn.selected=NO;
      

    }
}

- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];

    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    _lastDeleteItemIndexAsked = index;
    if([((welvu_images *)[topicVUImages objectAtIndex:_lastDeleteItemIndexAsked]).type isEqualToString:IMAGE_ASSET_TYPE]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"ALERT_TOPIC_VU_TITLE", nil)
                              message: NSLocalizedString(@"ALERT_TOPIC_VU_ARCHIVE_MSG", nil)
                              delegate: self
                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                              otherButtonTitles:NSLocalizedString(@"ARCHIVE", nil),nil];
        [alert show];
    } else {
        
        if([welvu_alerts canAlertShowAgain:appDelegate.getDBPath :ALERT_TOPIC_VU_TITLE]){
            
            
            // [self.delegate topicVUViewControllerRemoveImageSelected:(welvu_images *)[topicVUImages objectAtIndex
            // :_lastDeleteItemIndexAsked]];
            /* NSDictionary *imageDetailsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
             (welvu_images *)[topicVUImages objectAtIndex
             :_lastDeleteItemIndexAsked], @"welvu_RemoveSelectImage", nil];*/
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_REMOVE_SELECTED_IMAGE object:self userInfo:(welvu_images *)[topicVUImages objectAtIndex:_lastDeleteItemIndexAsked]];
            
            
            [welvu_history deleteHistoryWithImageId:appDelegate.getDBPath:((welvu_images *)[topicVUImages objectAtIndex
                                                                                            :_lastDeleteItemIndexAsked]).imageId];
            BOOL inserted = [welvu_sync addSyncDetail:[appDelegate getDBPath] guid:((welvu_images *)[topicVUImages objectAtIndex
                                                                                                     :_lastDeleteItemIndexAsked]).image_guid
                                             objectId:((welvu_images *)[topicVUImages objectAtIndex
                                                                        :_lastDeleteItemIndexAsked]).imageId
                                             syncType:SYNC_TYPE_TOPIC_DELETE_CONSTANT
                                           actionType:ACTION_TYPE_DELETE_CONSTANT];
            
            BOOL deleted = [welvu_images deleteImageFromTopic:appDelegate.getDBPath
                                                             :((welvu_images *)[topicVUImages objectAtIndex
                                                                                :_lastDeleteItemIndexAsked]).imageId
                                                       userId:appDelegate.welvu_userModel.welvu_user_id];
            if(deleted) {
                SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
               /* [dataToCloud startSyncDeletedDataToCloud:SYNC_TYPE_CONTENT_CONSTANT guid:((welvu_images *)
                                                                                          [topicVUImages objectAtIndex
                                                                                           :_lastDeleteItemIndexAsked]).image_guid
                                              actionType:HTTP_REQUEST_ACTION_TYPE_DELETE actionURL:PLATFORM_SYNC_CONTENTS];*/
                
                [dataToCloud startSyncDeletedImageDataToCloud:SYNC_TYPE_IMAGE_DELETE_CONSTANT guid:((welvu_images *)
                                                                                               [topicVUImages objectAtIndex
                                                                                                :_lastDeleteItemIndexAsked]).image_guid topicId:topicsId actionType:HTTP_REQUEST_ACTION_TYPE_DELETE actionURL:PLATFORM_SYNC_CONTENTS];
                if ([[NSFileManager defaultManager] fileExistsAtPath:((welvu_images *)[topicVUImages objectAtIndex
                                                                                       :_lastDeleteItemIndexAsked]).url]) {
                    [[NSFileManager defaultManager] removeItemAtPath: ((welvu_images *)[topicVUImages objectAtIndex
                                                                                        :_lastDeleteItemIndexAsked]).url error:NULL];
                    /* NSLog(@"Deleted Content from %@", ((welvu_images *)[topicVUImages objectAtIndex
                     :_lastDeleteItemIndexAsked]).url);*/
                }
              //  [topicVUImages removeObjectAtIndex:_lastDeleteItemIndexAsked];
               // [self.topicVuGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
                
                
                NSNumber *topicIdNumber = [NSNumber numberWithInteger: topicsId];
                NSNumber *imageIdNumber = [NSNumber numberWithInteger: ((welvu_images *)[topicVUImages objectAtIndex                                                                                         :_lastDeleteItemIndexAsked]).imageId];
                [topicVUImages removeObjectAtIndex:_lastDeleteItemIndexAsked];
                [self.topicVuGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
                NSDictionary *lastSelectedImageInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                       topicIdNumber, @"currentTopicId",imageIdNumber,
                                                       @"imageId", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteImageFromTopic" object:self userInfo:lastSelectedImageInfo];
                if([topicVUImages count] == 0) {
                    noContentAvailable.hidden = FALSE;
                    deleteBtn.selected = FALSE;
                    deleteBtn.enabled = NO;
                } else {
                    noContentAvailable.hidden = TRUE;
                }
                for(welvu_images *welvu_imagesModel in topicVUImages) {
                    
                    if([welvu_imagesModel.type isEqualToString:IMAGE_BLANK_TYPE] || [welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] || [welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE] ) {
                        deleteBtn.enabled = YES;
                    } else {
                        deleteBtn.enabled = NO;
                    }
                }
                
                
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"ALERT_TOPIC_VU_TITLE", nil)
                                  message: NSLocalizedString(@"ALERT_TOPIC_VU_ARCHIVE_DELETE_MSG", nil)
                                  delegate: self
                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                  otherButtonTitles:NSLocalizedString(@"DONT_SHOW_AGAIN", nil),
                                  NSLocalizedString(@"DELETE", nil),nil];
            
            [alert show];
        }
        
    }
    
    
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewSortingDelegate
//////////////////////////////////////////////////////////////
/*Required*/
- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor colorWithRed:0.94f green:0.67f blue:0.14f alpha:1.0f];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     }
                     completion:nil
     ];
}



-(void)GMGridView:(GMGridView *)gridView didMovingCell:(GMGridViewCell *)cell {
    
    droppedPositon = CGPointMake(cell.frame.origin.x, cell.frame.origin.y);
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil
     ];
    if(gridView == self.topicVuGMGridView) {
        [self updateOrderTopicVUImages];
    }
    
    if(droppedPositon.x > 300) {
        if(!cell.isSelected   && !edit) {
            for(UIView *subview in [cell.contentView subviews]) {
                if([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)subview;
                    imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                    imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                    
                }
            }
            cell.isSelected = TRUE;
            welvu_images *welvu_imagesModel = [topicVUImages objectAtIndex:[self searchImageGroups:cell.indexTag :topicVUImages]];
            welvu_imagesModel.selected = YES;
            //[self.delegate topicVUViewControllerImageSelectedWithPosition:welvu_imagesModel:droppedPositon];
            NSNumber *positionX = [NSNumber numberWithFloat:droppedPositon.x];
            NSNumber *positionY = [NSNumber numberWithFloat:droppedPositon.y];
            NSDictionary *imageDetailsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                    welvu_imagesModel, @"welvu_imagesModel", positionX,
                                                    @"positionX",positionY, @"positionY", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"imageSelectedWithPosition" object:self userInfo:imageDetailsDictionary];
            
            
            appDelegate.ispatientVUContent = TRUE;
            
            
        }
        
        
        
        
        
    }
    droppedPositon = CGPointZero;
    
}
- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    welvu_images *object = [topicVUImages objectAtIndex:oldIndex];
    [topicVUImages removeObject:object];
    [topicVUImages insertObject: object atIndex:newIndex];
    
    
    
    
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    [topicVUImages exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}


/*Required*/
- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return YES;
}

-(void)accordion:(AccordionView *)accordion didChangeSelection:(NSIndexSet *)selection {
    
}


-(void) removeTopicVuImages {
    if(topicVUImages != nil) {
        topicVUImages = nil;
    }
}

-(void) updateOrderTopicVUImages {
    NSInteger orderNumber = 1;
    dictionaryArray = [[NSMutableDictionary alloc] init];
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    welvu_topics *welvu_topicsModel = [welvu_topics getTopicById:[appDelegate getDBPath] :topicsId
                                                          userId:appDelegate.welvu_userModel.welvu_user_id];
    if(welvu_topicsModel.topic_is_user_created)
    {
        [dictionaryArray setValue:welvu_topicsModel.topics_guid forKey:HTTP_REQUEST_TOPIC_GUID];
    } else {
        [dictionaryArray setValue:[NSNumber numberWithInt:welvu_topicsModel.topicId] forKey:HTTP_REQUEST_TOPIC_ID];
    }
    NSMutableArray *arrayContent = [[NSMutableArray alloc] init];
    for(welvu_images *welvu_imagesModel in topicVUImages) {
        welvu_imagesModel.orderNumber = orderNumber;
        
        updated = [welvu_images updateImagesOrderNumberByTopicId:appDelegate.getDBPath
                                                                :welvu_imagesModel.topicId
                                                                :welvu_imagesModel.imageId :orderNumber
                                                          userId:appDelegate.welvu_userModel.welvu_user_id];
        
        
        NSMutableDictionary *dictionaryContents = [[NSMutableDictionary alloc] init];
        
        //one condition
        if(welvu_imagesModel.image_guid)
        {
            
            [dictionaryContents setValue:welvu_imagesModel.image_guid forKey:HTTP_REQUEST_CONTENT_GUID];
        }
        else
            
        {
            [dictionaryContents setValue:[NSNumber numberWithInt:welvu_imagesModel.imageId] forKey:HTTP_REQUEST_CONTENT_ID];
            
        }
        [dictionaryContents setValue:[NSNumber numberWithInt:welvu_imagesModel.orderNumber] forKey:HTTP_REQUEST_ORDER_NUMBER_KEY];
        [arrayContent addObject:dictionaryContents];
        
        
        orderNumber++;
    }
    [dictionaryArray setObject:arrayContent forKey:HTTP_REQUEST_MEDIA_ORDER_DETAILS_KEY];
    
    SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
    [dataToCloud startSyncOrderDataToCloud:0 syncOrder:dictionaryArray queueGuid:nil
                                actionType:HTTP_REQUEST_ACTION_TYPE_UPDATE actionURL:PLATFORM_SEND_SYNC_ORDER_ACTION_URL];
}


-(IBAction)reviewContentBtnClicked:(id)sender {
    [self popoverControllerDidDismissPopover:popover];
    welvuArchiveImageController *welvuArchiveImage = [[welvuArchiveImageController alloc]
                                                      initWithTopicId:topicsId];
    welvuArchiveImage.delegate = self;
    // [self.navigationController pushViewController:welvuArchiveImage animated:NO];
    edit = FALSE;
    preAnnotation.selected = FALSE;
}

-(void)welvuArchiveImageDidFinish:(BOOL)isModified {
    if(isModified) {
        [self removeTopicVuImages];
        [self loadVU];
    }
}
//Delete image from vu
-(IBAction) deleteSelectedBtnOnClicked:(id)sender {
    //declaring event tracking analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"TopicVU - TV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"TopicVU - TV"
                                                          action:@"Delete Button  -TV"
                                                           label:@"Delete"
                                                           value:nil] build]];

    @try {
        
        
        if(((UIButton *) sender).selected) {
            ((UIButton *) sender).selected = false;
            self.topicVuGMGridView.editing = false;
        } else {
            ((UIButton *) sender).selected = true;
            self.topicVuGMGridView.editing = true;
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"TopicVU-TV_Delete: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];

        
    }
}
#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    
    
    if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_TOPIC_VU_TITLE", nil)]) {
        if (buttonIndex == 1) {
            //delete btn
            update = [welvu_alerts updateAlertConfirmation:appDelegate.getDBPath :ALERT_TOPIC_VU_TITLE];
            
            
            // [self.delegate topicVUViewControllerRemoveImageSelected:(welvu_images *)[topicVUImages objectAtIndex :_lastDeleteItemIndexAsked]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_REMOVE_SELECTED_IMAGE object:self userInfo:(welvu_images *)[topicVUImages objectAtIndex:_lastDeleteItemIndexAsked]];
            
            BOOL inserted = [welvu_sync addSyncDetail:[appDelegate getDBPath] guid:((welvu_images *)[topicVUImages objectAtIndex
                                                                                                     :_lastDeleteItemIndexAsked]).image_guid
                                             objectId:((welvu_images *)[topicVUImages objectAtIndex
                                                                        :_lastDeleteItemIndexAsked]).imageId
                                             syncType:SYNC_TYPE_TOPIC_DELETE_CONSTANT
                                           actionType:ACTION_TYPE_DELETE_CONSTANT];
            
            
            
            [welvu_history deleteHistoryWithImageId:appDelegate.getDBPath:((welvu_images *)[topicVUImages objectAtIndex
                                                                                            :_lastDeleteItemIndexAsked]).imageId];
            BOOL deleted = [welvu_images deleteImageFromTopic:appDelegate.getDBPath
                                                             :((welvu_images *)[topicVUImages objectAtIndex
                                                                                :_lastDeleteItemIndexAsked]).imageId
                                                       userId:appDelegate.welvu_userModel.welvu_user_id];
            /* NSLog(@"Deleted Item %@, %d",((welvu_images *)[topicVUImages objectAtIndex
             :_lastDeleteItemIndexAsked]).image_guid,
             ((welvu_images *)[topicVUImages objectAtIndex:_lastDeleteItemIndexAsked]).imageId);*/
            if(deleted) {
                SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
              /*  [dataToCloud startSyncDeletedDataToCloud:SYNC_TYPE_CONTENT_CONSTANT
                                                    guid:((welvu_images *)[topicVUImages objectAtIndex
                                                                           :_lastDeleteItemIndexAsked]).image_guid
                                              actionType:HTTP_REQUEST_ACTION_TYPE_DELETE
                                               actionURL:PLATFORM_SYNC_CONTENTS];
                
                */
                if ([[NSFileManager defaultManager] fileExistsAtPath:((welvu_images *)[topicVUImages objectAtIndex
                                                                                       :_lastDeleteItemIndexAsked]).url]) {
                    [[NSFileManager defaultManager] removeItemAtPath: ((welvu_images *)[topicVUImages objectAtIndex
                                                                                        :_lastDeleteItemIndexAsked]).url error:NULL];
                    NSLog(@"Deleted Content from %@", ((welvu_images *)[topicVUImages objectAtIndex
                                                                        :_lastDeleteItemIndexAsked]).url);
                }
                NSNumber *topicIdNumber = [NSNumber numberWithInteger: topicsId];
                NSNumber *imageIdNumber = [NSNumber numberWithInteger: ((welvu_images *)[topicVUImages objectAtIndex                                                                                         :_lastDeleteItemIndexAsked]).imageId];
                [topicVUImages removeObjectAtIndex:_lastDeleteItemIndexAsked];
                [self.topicVuGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
                NSDictionary *lastSelectedImageInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                       topicIdNumber, @"currentTopicId",imageIdNumber,
                                                       @"imageId", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteImageFromTopic" object:self userInfo:lastSelectedImageInfo];
            
                NSLog(@"topicvuImages %d" ,[topicVUImages count]);
                if([topicVUImages count] == 0) {
                    noContentAvailable.hidden = FALSE;
                    deleteBtn.selected = FALSE;
                    deleteBtn.enabled = NO;
                } else {
                    noContentAvailable.hidden = TRUE;
                }
                for(welvu_images *welvu_imagesModel in topicVUImages) {
                    
                   if([welvu_imagesModel.type isEqualToString:IMAGE_BLANK_TYPE] || [welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] || [welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE] ) {
                        deleteBtn.enabled = YES;
                    } else {
                        deleteBtn.enabled = NO;
                    }
                }
                
            }
            
            //archive
            /*int update = [welvu_images deactivateImageFromTopic
             :appDelegate.getDBPath:((welvu_images *)[topicVUImages objectAtIndex:_lastDeleteItemIndexAsked]).imageId];
             if(update > 0) {
             [topicVUImages removeObjectAtIndex:_lastDeleteItemIndexAsked];
             [self.topicVuGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
             }
             [imagesReviewBtn setEnabled:TRUE];*/
        } else if(buttonIndex == 2) {
          
         /*   NSNumber *topicIdNumber = [NSNumber numberWithInteger: topicsId];
            NSNumber *imageIdNumber = [NSNumber numberWithInteger: ((welvu_images *)[topicVUImages objectAtIndex                                                                                         :_lastDeleteItemIndexAsked]).imageId];
            
            
            NSDictionary *lastSelectedImageInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                   topicIdNumber, @"currentTopicId",imageIdNumber,
                                                   @"imageId", nil];
            
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_REMOVE_SELECTED_IMAGE object:self userInfo:lastSelectedImageInfo];
            */
            
           
            
            // [self.delegate topicVUViewControllerRemoveImageSelected:(welvu_images *)[topicVUImages objectAtIndex:_lastDeleteItemIndexAsked]];
            [welvu_history deleteHistoryWithImageId:appDelegate.getDBPath:((welvu_images *)[topicVUImages objectAtIndex
                                                                                            :_lastDeleteItemIndexAsked]).imageId];
            
            BOOL deleted = [welvu_images deleteImageFromTopic:appDelegate.getDBPath
                                                             :((welvu_images *)[topicVUImages objectAtIndex
                                                                                :_lastDeleteItemIndexAsked]).imageId
                                                       userId:appDelegate.welvu_userModel.welvu_user_id];
            /* NSLog(@"Deleted Item %@, %d",((welvu_images *)[topicVUImages objectAtIndex
             :_lastDeleteItemIndexAsked]).image_guid,
             ((welvu_images *)[topicVUImages objectAtIndex:_lastDeleteItemIndexAsked]).imageId);*/
            if(deleted) {
                SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
                
                [dataToCloud startSyncDeletedImageDataToCloud:SYNC_TYPE_IMAGE_DELETE_CONSTANT guid:((welvu_images *)
                                                                                               [topicVUImages objectAtIndex
                                                                                                :_lastDeleteItemIndexAsked]).image_guid topicId:topicsId actionType:HTTP_REQUEST_ACTION_TYPE_DELETE actionURL:PLATFORM_SYNC_CONTENTS];
                
             /*   [dataToCloud startSyncDeletedDataToCloud:SYNC_TYPE_CONTENT_CONSTANT guid:((welvu_images *)
                                                                                          [topicVUImages objectAtIndex
                                                                                           :_lastDeleteItemIndexAsked]).image_guid
                                              actionType:HTTP_REQUEST_ACTION_TYPE_DELETE actionURL:PLATFORM_SYNC_CONTENTS];
                
                
                */
                
                
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:((welvu_images *)[topicVUImages objectAtIndex
                                                                                       :_lastDeleteItemIndexAsked]).url]) {
                    [[NSFileManager defaultManager] removeItemAtPath: ((welvu_images *)[topicVUImages objectAtIndex
                                                                                        :_lastDeleteItemIndexAsked]).url error:NULL];
                    /* NSLog(@"Deleted Content from %@", ((welvu_images *)[topicVUImages objectAtIndex
                     :_lastDeleteItemIndexAsked]).url)*/;
                }
                NSNumber *topicIdNumber = [NSNumber numberWithInteger: topicsId];
                NSNumber *imageIdNumber = [NSNumber numberWithInteger: ((welvu_images *)[topicVUImages objectAtIndex                                                                                         :_lastDeleteItemIndexAsked]).imageId];
                [topicVUImages removeObjectAtIndex:_lastDeleteItemIndexAsked];
                [self.topicVuGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
                NSDictionary *lastSelectedImageInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                       topicIdNumber, @"currentTopicId",imageIdNumber,
                                                       @"imageId", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteImageFromTopic" object:self userInfo:lastSelectedImageInfo];
                
                NSLog(@"topicvuImages %d" ,[topicVUImages count]);
                
                
                if([topicVUImages count] == 0) {
                    noContentAvailable.hidden = FALSE;
                    deleteBtn.selected = FALSE;
                    deleteBtn.enabled = NO;
                } else {
                    noContentAvailable.hidden = TRUE;
                }
                for(welvu_images *welvu_imagesModel in topicVUImages) {
                    
                   if([welvu_imagesModel.type isEqualToString:IMAGE_BLANK_TYPE] || [welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] || [welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE] ) {
                        deleteBtn.enabled = YES;
                    } else {
                        deleteBtn.enabled = NO;
                    }
                }
            }
        }
        //cancel
        else if(buttonIndex == 3){
            
            
            
        }
        
    }else  if(alertView.tag = 10000) {
        [appDelegate startSyncProcess];
    }
    if([topicVUImages count] == 0) {
        noContentAvailable.hidden = FALSE;
    }
    
}


-(IBAction)archiveBtnClicked:(id)sender {
    [self popoverControllerDidDismissPopover:popover];
    UIBarButtonItem *btn  = (UIBarButtonItem *) sender;
    if(btn.tag == 1) {
        btn.tag = 2;
        //self.topicVuGMGridView.editing = YES;
        edit = FALSE;
        preAnnotation.selected = FALSE;
    } else {
        btn.tag = 1;
        //self.topicVuGMGridView.editing = NO;
    }
    
}
//Get Blank image from canvas to topics
-(IBAction)blankImageBtnOnClicked:(id)sender{
    
    /*[self popoverControllerDidDismissPopover:popover];
     welvuTopicVUAnnotationViewController *welvuTopicVUAnnotation = [[welvuTopicVUAnnotationViewController alloc]
     initWithImageGroup:@"welvuTopicVUAnnotationViewController" bundle:nil
     currentTopicId:topicsId
     images:[topicVUImages mutableCopy] currentSelectedImage:0
     annotateBlankCanvas:true];
     welvuTopicVUAnnotation.delegate = self;
     welvuTopicVUAnnotation.modalPresentationStyle = UIModalPresentationFullScreen;
     welvuTopicVUAnnotation.modalTransitionStyle = UIModalTransitionStyleCoverVertical; //transition shouldn't matter
     [self presentModalViewController:welvuTopicVUAnnotation animated:YES];
     [welvuTopicVUAnnotation release];
     edit = FALSE;
     preAnnotation.image = [UIImage imageNamed:@"annotationoff.png"];
     preAnnotation.tag = 3;
     self.topicVuGMGridView.editing = NO;*/
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"TopicVU - TV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"TopicVU - TV"
                                                          action:@"BlankButton -TV"
                                                           label:@"BlankImage"
                                                           value:nil] build]];

    
    @try {
        
        NSDate *date = [NSDate date];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = YEAR_MONTH_DATE_TIME_FILENAME_FORMAT;
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
        welvu_images * blankCanvas = [[welvu_images alloc]init];
        blankCanvas.imageDisplayName = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
        blankCanvas.type= IMAGE_BLANK_TYPE;
        blankCanvas.orderNumber = ([welvu_images getMaxOrderNumber:appDelegate.getDBPath :topicsId
                                                            userId:appDelegate.welvu_userModel.welvu_user_id] + 1);
        blankCanvas.welvu_user_id = appDelegate.welvu_userModel.welvu_user_id;
        blankCanvas.image_guid =  [[Guid randomGuid] description];
        switch (((welvu_settings *)appDelegate.currentWelvuSettings).welvu_blank_canvas_color) {
            case SETTING_BLANK_CANVAS_COLOR_WHITE:
                blankCanvas.url = @"blankCanvas.png";
                break;
            case SETTING_BLANK_CANVAS_COLOR_BLACK:
                blankCanvas.url = @"blankCanvasblack.png";
                break;
            case SETTING_BLANK_CANVAS_COLOR_GREEN:
                blankCanvas.url = @"blankCanvasGreen1.png";
                break;
            default:
                break;
        }
        
        
        NSInteger imageId = [welvu_images addNewImageToTopic:appDelegate.getDBPath :blankCanvas:topicsId];
        if(imageId > 0) {
            welvu_images *welvu_imagesMod = [welvu_images getImageById:appDelegate.getDBPath :imageId
                                                                userId:appDelegate.welvu_userModel.welvu_user_id];
            welvu_imagesMod.selected = false;
            if(topicVUImages == nil) {
                topicVUImages  = [[NSMutableArray alloc] init];
            }
            [topicVUImages addObject:welvu_imagesMod];
            [self.topicVuGMGridView insertObjectAtIndex:[topicVUImages count] - 1
                                          withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
            NSNumber *topicIdNumber = [NSNumber numberWithInteger: topicsId];
            NSNumber *imageIdNumber = [NSNumber numberWithInteger: ((welvu_images *)[topicVUImages objectAtIndex                                                                                         :(topicVUImages.count - 1)]).imageId];
            NSDictionary *lastSelectedImageInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                   topicIdNumber, @"currentTopicId",imageIdNumber,
                                                   @"imageId", nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"albumButtonSelected" object:self userInfo:lastSelectedImageInfo];
            
            //[welvu_imagesMod release];
            // noimage.hidden = TRUE;
            // CGSize destinationSize = CGSizeMake(200, 135);
            
            // UIImage *originalImage = [UIImage imageWithData:];
            /*  = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
             UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
             // thumbnail  = [thumbnail imageWithBorderForSelected:THUMB_IMAGE_BORDER];
             imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
             imageView.contentMode = UIViewContentModeCenter;
             imageView.image = thumbnail;
             */
            /*SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
             [dataToCloud startSyncDataToCloud:SYNC_TYPE_CONTENT_CONSTANT objectId:imageId
             actionType:HTTP_REQUEST_ACTION_TYPE_CREATE actionURL:PLATFORM_SYNC_CONTENTS];*/
        }
        self.topicVuGMGridView.editing = NO;
        deleteBtn.selected = FALSE;
        deleteBtn.enabled = YES;
        noContentAvailable.hidden = true;
    }
    @catch (NSException *exception) {

        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"TopicVU-TV_BlankImage: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];

        
    }
}
//Select all images from topic
-(IBAction)selectAllImagesBtnClicked:(id)sender {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"TopicVU - TV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"TopicVU - TV"
                                                          action:@"SelectAllButton -TV"
                                                           label:@"Selectall"
                                                           value:nil] build]];
    
    @try {
        
        [self popoverControllerDidDismissPopover:popover];
        edit = FALSE;
        deleteBtn.selected = FALSE;
        preAnnotation.selected = FALSE;
        self.topicVuGMGridView.editing = NO;
        if([topicVUImages count] > 0) {
            for(welvu_images *welvu_imagesModel in topicVUImages) {
                if(!welvu_imagesModel.selected) {
                    NSInteger index = [self searchImageGroups:welvu_imagesModel.imageId :topicVUImages];
                    welvu_imagesModel.selected = YES;
                    GMGridViewCell *cell = (GMGridViewCell *)[self.topicVuGMGridView cellForItemAtIndex:index];
                    if(!cell.isSelected) {
                        for(UIView *subview in [cell.contentView subviews]) {
                            if([subview isKindOfClass:[UIImageView class]]) {
                                UIImageView *imageView = (UIImageView *)subview;
                                imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                                imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                            }
                        }
                        cell.isSelected = TRUE;
                    }
                }
            }
            // [self.delegate topicVUViewControllerImageSelectedAll:[topicVUImages mutableCopy]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_IMAGE_SELECTEDALL object:self userInfo:[topicVUImages mutableCopy]];
        }
    }
    @catch (NSException *exception) {

        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"TopicVU-TV_Selectall: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        

        
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    // aScrollView.scrollEnabled=FALSE;
    //  scrolViewGenerated=FALSE;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scrolViewDisabled" object:nil];
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    if (aScrollView.contentOffset.y <= 0) {
        self.bottomFadingView.hidden = false;
    }
    
    if(aScrollView.contentOffset.y >= 5) {
        self.topFadingView.hidden = false;
        self.bottomFadingView.hidden = false;
    }
    
    float reload_distance = 10;
    if(y > h - reload_distance) {
        self.topFadingView.hidden = false;
        self.bottomFadingView.hidden = true;
    }
    
    if (aScrollView.contentOffset.y <= 0) {
        self.topFadingView.hidden = true;
    }
}

//Edit the image and annotate it and save it
-(IBAction)editBtnClicked:(id)sender {
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"TopicVU - TV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"TopicVU - TV"
                                                          action:@"EditButton -TV"
                                                           label:@"Edit"
                                                           value:nil] build]];

    
    @try {
        
     
        deleteBtn.selected = FALSE;
        
        /* NSInteger indexValue = [self searchImageGroups:appDelegate.imageId :topicVUImages];
         if(indexValue > -1) {
         welvu_images *welvu_imagesModel = [topicVUImages objectAtIndex:indexValue];
         if(welvu_imagesModel.type != IMAGE_VIDEO_ALBUM_TYPE
         || welvu_imagesModel.type != IMAGE_VIDEO_TYPE) {
         NSNumber *topicIdNumber = [NSNumber numberWithInteger: topicsId];
         NSNumber *imageIdNumber = [NSNumber numberWithInteger: appDelegate.imageId];
         NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
         topicIdNumber, @"currentTopicId",imageIdNumber,
         @"imageId", nil];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:@"annotationVU" object:self userInfo:dic];
         self.topicVuGMGridView.editing = NO;
         }
         }*/
        
        NSNumber *topicIdNumber = [NSNumber numberWithInteger: topicsId];
        NSNumber *imageIdNumber = [NSNumber numberWithInteger: appDelegate.imageId];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                             topicIdNumber, @"currentTopicId",imageIdNumber,
                             @"imageId", nil];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"annotationVU" object:self userInfo:dic];
        self.topicVuGMGridView.editing = NO;
    }
    @catch (NSException *exception) {

        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"TopicVU-TV_Edit: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        

        
    }
}
//if edit finish then save the image content in topic
-(void)editVUFinished:(NSInteger) imageId {
    deleteBtn.enabled = YES;
    preAnnotation.selected = FALSE;
    edit = FALSE;
    //[self loadVU];
    NSInteger index = [self searchImageGroups:imageId :topicVUImages];
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    welvu_images* welvu_imagesModel = [welvu_images getImageById:appDelegate.getDBPath :imageId
                                                          userId:appDelegate.welvu_userModel.welvu_user_id];
    if(index > -1) {
        ((welvu_images *) [topicVUImages objectAtIndex:index]).type = welvu_imagesModel.type;
        ((welvu_images *) [topicVUImages objectAtIndex:index]).url = welvu_imagesModel.url;
    } else if(welvu_imagesModel.topicId == topicsId) {
        welvu_imagesModel.selected = FALSE;
        [topicVUImages addObject:welvu_imagesModel];
    }
    [self.topicVuGMGridView reloadData];
    [self.topicVuGMGridView scrollToObjectAtIndex:([topicVUImages count] - 1)
                                 atScrollPosition:GMGridViewScrollPositionBottom animated:YES];
    edit = FALSE;
}

//Camera & Album
-(IBAction) camButtonClicked:(id)sender {
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"TopicVU - TV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"TopicVU - TV"
                                                          action:@"CameraButton -TV"
                                                           label:@"Camera"
                                                           value:nil] build]];
    

    @try {
        deleteBtn.selected = FALSE;
        [self popoverControllerDidDismissPopover:popover];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"camButtonClicked" object:self ];
        self.topicVuGMGridView.editing = NO;
        preAnnotation.selected = FALSE;
        
        
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"TopicVU-TV_Camera: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];

        
    }
}
-(void)updateTopicContents:(NSInteger) imageId {
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    if(topicVUImages == nil) {
        topicVUImages  = [[NSMutableArray alloc] init];
    }
    welvu_images *imagesModel = [welvu_images getImageById:appDelegate.getDBPath :imageId
                                                    userId:appDelegate.welvu_userModel.welvu_user_id];
    imagesModel.pickedToView = false;
    imagesModel.selected = false;
    [topicVUImages addObject:imagesModel];
    [self.topicVuGMGridView insertObjectAtIndex:[topicVUImages count] - 1
                                  withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
    
    //[welvu_imagesMod release];
    noContentAvailable.hidden = TRUE;
    deleteBtn.enabled = YES;
    
}
//get images/video content from photo album
-(IBAction) albumButtonClicked:(id)sender {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"TopicVU - TV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"TopicVU - TV"
                                                          action:@"AlbumButton -TV"
                                                           label:@"PhotoAlbum"
                                                           value:nil] build]];
    

    
    @try {
        //albumBtn.selected =TRUE;
        deleteBtn.selected=FALSE;
        if(popover == nil) {
            ELCAlbumPickerViewController *albumController = [[ELCAlbumPickerViewController alloc]
                                                         initWithNibName:@"ELCAlbumPickerViewController" bundle:[NSBundle mainBundle]];
            ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
            [albumController setParent:elcPicker];
            [elcPicker setDelegate:self];
            
            popover = [[UIPopoverController alloc]
                       initWithContentViewController:elcPicker];
            popover.delegate = self;
            
            popover.popoverBackgroundViewClass = [KSCustomPopoverBackgroundView class];
            [popover presentPopoverFromRect:((UIButton *)sender).frame
                                     inView:self permittedArrowDirections:UIPopoverArrowDirectionLeft animated:NO];
            
            
            /* [popover presentPopoverFromRect:CGRectMake(0, 0, 0, 0) inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];*/
            [popover setPopoverContentSize:CGSizeMake(320, 768) animated:NO];
            // [popover setPopoverContentSize:[[UIScreen mainScreen] bounds].size animated:YES];         [elcPicker release];
            self.topicVuGMGridView.editing = NO;
            preAnnotation.selected = FALSE;
            albumBtn.selected = true;
        }
    }
    @catch (NSException *exception) {

        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"TopicVU-TV_PhotoAlbum: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        

        
    }
}

#pragma mark ELCImagePickerController Delegate
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
	appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FILENAME_FORMAT];
    NSDictionary *dict=[info objectAtIndex:0];
    NSString *mediaType = [dict objectForKey:UIImagePickerControllerMediaType];
    NSString *imageName = [dateFormatter stringFromDate:[NSDate date]];
    if([mediaType isEqualToString:@"ALAssetTypePhoto"]) {
        UIImage *anImage = [dict objectForKey:UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImageJPEGRepresentation(anImage, 1.0);
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        
        NSString  *pickedImagePath = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@.%@", path,
                                                                       imageName, HTTP_ATTACHMENT_IMAGE_EXT_KEY]];
        if([imageData writeToFile:pickedImagePath atomically:YES]){
            welvu_images *welvu_imagesModel = [[welvu_images alloc] init];
            welvu_imagesModel.topicId = topicsId;
            welvu_imagesModel.imageDisplayName = imageName;
            welvu_imagesModel.orderNumber = ([welvu_images getMaxOrderNumber:appDelegate.getDBPath :topicsId
                                                                      userId:appDelegate.welvu_userModel.welvu_user_id] + 1);
            welvu_imagesModel.type = IMAGE_ALBUM_TYPE;
            welvu_imagesModel.url = [NSString stringWithFormat:@"%@.%@", imageName,
                                     HTTP_ATTACHMENT_IMAGE_EXT_KEY];
            welvu_imagesModel.image_guid =  [[Guid randomGuid] description];
            NSURL *outputURL = [NSURL fileURLWithPath:pickedImagePath];
            int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:outputURL];
            
            //YES 1
            NSInteger imageId = [welvu_images addNewImageToTopic:appDelegate.getDBPath :welvu_imagesModel:topicsId];
            if(imageId > 0) {
                welvu_images *welvu_imagesMod = [welvu_images getImageById:[appDelegate getDBPath] :imageId
                                                                    userId:appDelegate.welvu_userModel.welvu_user_id];
                welvu_imagesMod.pickedToView = false;
                welvu_imagesMod.selected = false;
                if(topicVUImages == nil) {
                    topicVUImages  = [[NSMutableArray alloc] init];
                }
                [topicVUImages addObject:welvu_imagesMod];
                [topicVuGMGridView insertObjectAtIndex:[topicVUImages count] - 1
                                         withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
                
                noContentAvailable.hidden = TRUE;
                BOOL inserted = [welvu_sync addSyncDetail:[appDelegate getDBPath] guid:welvu_imagesMod.image_guid
                                                 objectId:imageId
                                                 syncType:SYNC_TYPE_CONTENT_CONSTANT
                                               actionType:ACTION_TYPE_CREATE_CONSTANT];
                NSNumber *topicIdNumber = [NSNumber numberWithInteger: topicsId];
                NSNumber *imageIdNumber = [NSNumber numberWithInteger: ((welvu_images *)[topicVUImages objectAtIndex                                                                                         :(topicVUImages.count - 1)]).imageId];
                NSDictionary *lastSelectedImageInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                       topicIdNumber, @"currentTopicId",imageIdNumber,
                                                       @"imageId", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"albumButtonSelected" object:self userInfo:lastSelectedImageInfo];
                
                SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
                dataToCloud.delegate = self;
                [dataToCloud startSyncDataToCloud:SYNC_TYPE_CONTENT_CONSTANT objectId:imageId
                                       actionType:HTTP_REQUEST_ACTION_TYPE_CREATE actionURL:PLATFORM_SYNC_CONTENTS];
            }
        }
    } else if([mediaType isEqualToString:@"ALAssetTypeVideo"]){
        
        if(spinner == nil) {
            appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:appDelegate.splitViewController.view];
            [appDelegate.splitViewController.view bringSubviewToFront:spinner];
            //  NSLog(@"spinner on");
        }
        
        NSString* videoName = [NSString stringWithFormat:@"%@.%@", [dateFormatter stringFromDate:[NSDate date]],
                               HTTP_ATTACHMENT_VIDEO_EXT_KEY];
        NSString *exportPath = [DOCUMENT_DIRECTORY stringByAppendingPathComponent:videoName];
        
        
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^ {
            
            //
            ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
            [assetLibrary assetForURL:[dict objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                NSUInteger length = [rep size];
                
                
                int offset = 0; // offset that keep tracks of chunk data
                
                //do {
                // @autoreleasepool {
                NSUInteger chunkSize = 100 * 1024;
                
                
                rep = [asset defaultRepresentation];
                
                NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath: exportPath] ;
                
                if(file == nil) {
                    [[NSFileManager defaultManager] createFileAtPath:exportPath contents:nil attributes:nil];
                    file = [NSFileHandle fileHandleForWritingAtPath:exportPath];
                }
                
                offset = 0;
                do {
                    uint8_t *buffer = malloc(chunkSize * sizeof(uint8_t));
                    NSUInteger bytesCopied = [rep getBytes:buffer fromOffset:offset length:chunkSize error:nil];
                    offset += bytesCopied;
                    NSData *data = [[NSData alloc] initWithBytes:buffer length:bytesCopied];
                    [file writeData:data];
                    data= nil;
                    free(buffer);
                    buffer = NULL;
                    
                } while (offset < length);
                
                [file closeFile];
                file = nil;
                if(spinner != nil) {
                    [spinner removeSpinner];
                    spinner = nil;
                    //  NSLog(@"spinner off");
                }
                
                //} while (1);
                //
                
                
                
                welvu_images *welvu_imagesModel = [[welvu_images alloc] init];
                welvu_imagesModel.imageDisplayName = imageName;
                welvu_imagesModel.orderNumber = ([welvu_images getMaxOrderNumber:appDelegate.getDBPath :topicsId
                                                                          userId:appDelegate.welvu_userModel.welvu_user_id] + 1);
                welvu_imagesModel.type = IMAGE_VIDEO_ALBUM_TYPE;
                welvu_imagesModel.url = videoName;
                welvu_imagesModel.image_guid =  [[Guid randomGuid] description];
                NSURL *outputURL = [NSURL fileURLWithPath:exportPath];
                int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:outputURL]; // YES 1
                NSInteger videoId = [welvu_images addNewImageToTopic:appDelegate.getDBPath :welvu_imagesModel:topicsId];
                if(videoId > 0) {
                    welvu_images *welvu_imagesMod =  [welvu_images getImageById:[appDelegate getDBPath] :videoId
                                                                         userId:appDelegate.welvu_userModel.welvu_user_id];
                    welvu_imagesMod.pickedToView = false;
                    welvu_imagesMod.selected = false;
                    if(topicVUImages == nil) {
                        topicVUImages  = [[NSMutableArray alloc] init];
                    }
                    [topicVUImages addObject:welvu_imagesMod];
                    [topicVuGMGridView insertObjectAtIndex:[topicVUImages count] - 1
                                             withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
                    noContentAvailable.hidden = TRUE;
                    BOOL inserted = [welvu_sync addSyncDetail:[appDelegate getDBPath] guid:welvu_imagesMod.image_guid
                                                     objectId:videoId
                                                     syncType:SYNC_TYPE_CONTENT_CONSTANT
                                                   actionType:ACTION_TYPE_CREATE_CONSTANT];
                    NSNumber *topicIdNumber = [NSNumber numberWithInteger: topicsId];
                    NSNumber *imageIdNumber = [NSNumber numberWithInteger: ((welvu_images *)[topicVUImages objectAtIndex                                                                                         :(topicVUImages.count -1)]).imageId];
                    NSDictionary *lastSelectedImageInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                           topicIdNumber, @"currentTopicId",imageIdNumber,
                                                           @"imageId", nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"albumButtonSelected" object:self userInfo:lastSelectedImageInfo];
                    
                    SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
                    [dataToCloud startSyncDataToCloud:SYNC_TYPE_CONTENT_CONSTANT objectId:videoId
                                           actionType:HTTP_REQUEST_ACTION_TYPE_CREATE actionURL:PLATFORM_SYNC_CONTENTS];
                }
            } failureBlock:^(NSError *err) {
                //  NSLog(@"Error: %@",[err localizedDescription]);
                
                
            }];
            //
            dispatch_async(dispatch_get_main_queue(), ^ {
            });
        });
        
        
        
        
    }
    [popover dismissPopoverAnimated:NO];
    popover = nil;
    albumBtn.selected = false;
    deleteBtn.enabled = YES;
    noContentAvailable.hidden = true;

}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    
	//[self dismissModalViewControllerAnimated:YES];
    [popover dismissPopoverAnimated:NO];
    popover = nil;
     albumBtn.selected = false;
}
//Clear all images as border with images unselected in topic vu
-(void)clearedAllPatientVU:(NSNotification *)notification {
    
    if([topicVUImages count] > 0) {
        for(welvu_images *welvu_imagesModel in topicVUImages) {
            if(welvu_imagesModel.selected) {
                NSInteger index = [self searchImageGroups:welvu_imagesModel.imageId :topicVUImages];
                welvu_imagesModel.selected = NO;
                GMGridViewCell *cell = (GMGridViewCell *)[self.topicVuGMGridView cellForItemAtIndex:index];
                if(cell.isSelected) {
                    
                    for(UIView *subview in [cell.contentView subviews]) {
                        if([subview isKindOfClass:[UIImageView class]]) {
                            UIImageView *imageView = (UIImageView *)subview;
                            imageView.image = [ [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER]
                                               makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                            
                        }
                    }
                    cell.isSelected = FALSE;
                }
            }
        }
    }
}
#pragma mark UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *) Picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FILENAME_FORMAT];
    UIImage *anImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(anImage, 1.0);
    NSString *imageName = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString  *pickedImagePath = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@.%@",
                                                                   DOCUMENT_DIRECTORY,
                                                                   imageName, HTTP_ATTACHMENT_IMAGE_EXT_KEY]];
    if([imageData writeToFile:pickedImagePath atomically:YES]){
        NSURL *outputURL = [NSURL fileURLWithPath:pickedImagePath];
        int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:outputURL];
        welvu_images *welvu_imagesModel = [[welvu_images alloc] init];
        welvu_imagesModel.topicId = topicsId;
        welvu_imagesModel.imageDisplayName = imageName;
        welvu_imagesModel.orderNumber = ([welvu_images getMaxOrderNumber:appDelegate.getDBPath :topicsId
                                                                  userId:appDelegate.welvu_userModel.welvu_user_id] + 1);
        welvu_imagesModel.type = IMAGE_ALBUM_TYPE;
        welvu_imagesModel.url = [NSString stringWithFormat:@"%@.%@", imageName,
                                 HTTP_ATTACHMENT_IMAGE_EXT_KEY];
        welvu_imagesModel.image_guid =  [[Guid randomGuid] description];
        NSInteger imageId = [welvu_images addNewImageToTopic:appDelegate.getDBPath :welvu_imagesModel:topicsId];
        if(imageId > 0) {
            welvu_images *welvu_imagesMod = [[welvu_images alloc] initWithImageId:imageId];
            welvu_imagesMod.topicId = welvu_imagesModel.topicId;
            welvu_imagesMod.imageDisplayName = welvu_imagesModel.imageDisplayName;
            welvu_imagesMod.orderNumber = welvu_imagesModel.orderNumber;
            welvu_imagesMod.type = welvu_imagesModel.type;
            welvu_imagesModel.image_guid =  [[Guid randomGuid] description];
            welvu_imagesMod.url = welvu_imagesModel.url;
            if(topicVUImages == nil) {
                topicVUImages  = [[NSMutableArray alloc] init];
            }
            [topicVUImages addObject:welvu_imagesMod];
            [self.topicVuGMGridView insertObjectAtIndex:[topicVUImages count] - 1
                                          withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
            
            //[welvu_imagesMod release];
            noContentAvailable.hidden = TRUE;
            BOOL inserted = [welvu_sync addSyncDetail:[appDelegate getDBPath] guid:welvu_imagesMod.image_guid
                                             objectId:imageId
                                             syncType:SYNC_TYPE_CONTENT_CONSTANT
                                           actionType:ACTION_TYPE_CREATE_CONSTANT];
            NSNumber *topicIdNumber = [NSNumber numberWithInteger: topicsId];
            NSNumber *imageIdNumber = [NSNumber numberWithInteger: ((welvu_images *)[topicVUImages objectAtIndex                                                                                         :(topicVUImages.count -1)]).imageId];
            NSDictionary *lastSelectedImageInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                   topicIdNumber, @"currentTopicId",imageIdNumber,
                                                   @"imageId", nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"albumButtonSelected" object:self userInfo:lastSelectedImageInfo];
            
            SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
            [dataToCloud startSyncDataToCloud:SYNC_TYPE_CONTENT_CONSTANT objectId:imageId
                                   actionType:HTTP_REQUEST_ACTION_TYPE_CREATE actionURL:PLATFORM_SYNC_CONTENTS];
            
        }
    }
    [picker dismissModalViewControllerAnimated:YES];
    
    picker = nil;
    
    
    if(popover != NULL) {
        [popover dismissPopoverAnimated:YES];
        popover = nil;
    }
     albumBtn.selected = false;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    [picker dismissModalViewControllerAnimated:YES];
    picker = nil;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if(popover != nil) {
        [popover dismissPopoverAnimated:NO];
        popover = nil;
    }
     albumBtn.selected = false;
}

-(UIImage *)generateImageFromVideo:(NSString *) pathString:(NSString *)pathType {
    NSURL *theContentURL;
    if([pathType isEqualToString:IMAGE_VIDEO_TYPE] &&
       ![[NSFileManager defaultManager] fileExistsAtPath:pathString]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSArray *nameAndType = [pathString componentsSeparatedByString: @"."];
        NSString *moviePath = [bundle pathForResource:[nameAndType objectAtIndex:0] ofType:[nameAndType objectAtIndex:1]];
        theContentURL = [NSURL fileURLWithPath:moviePath];
    } else {
        theContentURL = [NSURL fileURLWithPath:pathString];
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:theContentURL options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    CGImageRef thumb = [imageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(1.0, 1.0)
                                              actualTime:NULL
                                                   error:NULL];
    UIImage *thumbImage = [UIImage imageWithCGImage:thumb];
    imageGenerator = nil;
    asset = nil;
    CGImageRelease(thumb);
    return thumbImage;
}
//Navigate to previous view
-(IBAction)backBtnClicked:(id)sender {
    //[self.delegate topicVuViewControllerRefreshTableData];
    [self popoverControllerDidDismissPopover:popover];
    //[self.navigationController popViewControllerAnimated:NO];
}

//get welvu images
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        //Declaring Page View Analytics
       
        if(![welvu_images getArchiveImageCount:appDelegate.getDBPath] > 0) {
            [imagesReviewBtn setEnabled:FALSE];
            if(self.topicVuGMGridView.contentSize.height > self.topicVuGMGridView.frame.size.height) {
                self.bottomFadingView.hidden = false;
            } else {
                self.bottomFadingView.hidden = true;
            }
            appDelegate.currentMasterScreen = INFORMATION_TOPIC_CONTENT_VU;
            //welvuTopicVUviewController.parentController=self;
            /*[[NSNotificationCenter defaultCenter] addObserver:self
             selector:@selector(selectedAccordianViewVU1:)
             name:@"selectedAccordianViewVU"
             object:nil];
             [[NSNotificationCenter defaultCenter] addObserver:self
             selector:@selector(setAccordianScrollViewEnabled:)
             name:@"scrolViewEnabled" object:self];*/
            
                        
            [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                               value:@"TopicVU - TV"];
            [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];

        }
        
        
    }
    return self;
}

- (void)setAccordianScrollViewEnabled:(NSNotification *)note {
    
    
    //[sc setScrollEnabled:FALSE];
}
-(void)selectedAccordianViewVU1:(NSNotification *)note {
    
    if(noContentAvailable.inputView == NULL)
    {
        // NSLog(@"loading..");
    }
    else
    {
        // NSLog(@"already image is there...");
    }
}
#pragma mark - NSRequest  delegates
- (void)syncContentToPlatformDidReceivedData:(BOOL)success :(NSDictionary *)responseDictionary {
    if(success) {
        // [self.delegate specialtyViewControllerDidFinish:YES];
    }
}



-(void)syncResponseDicFromPlatform:(BOOL)success :(NSDictionary *)responseDictionary {
    
    
    //NSLog(@"response dic %@",responseDictionary);
    if([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_FAILED_KEY]== NSOrderedSame)
    {
        
        
        UIAlertView *myalert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Admin has deleted the topics" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        myalert.tag = 10000;
        [myalert show];
        
    }
    
}
- (void)syncContentToPlatformSendResponse:(BOOL)success {
    //  NSLog(@"Response received for Sync Data");
}

//content sync failed
- (void)syncContentFailedWithErrorDetails:(NSError *)error {
    //   NSLog(@"Sync Content Failed: %@", error);
}
@end
