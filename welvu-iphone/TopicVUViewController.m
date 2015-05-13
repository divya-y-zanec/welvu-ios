//
//  TopicVUViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 15/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "TopicVUViewController.h"
#import "welvuiPhoneContants.h"
#import "welvu_topics.h"
#import "welvu_images.h"
#import "UIImage+Resize.h"
#import "welvuTopicVUAnnotationViewController.h"
#import "welvuViewController.h"
#import "welvuArchiveTopicController.h"
#import "welvuArchiveImageController.h"


@interface TopicVUViewController () <GMGridViewDataSource, GMGridViewSortingDelegate,
GMGridViewActionDelegate> {
    NSInteger _lastDeleteItemIndexAsked;
}
-(void) initializeView;
-(void)intializeGMGridViews;
-(void) updateOrderTopicVUImages;
@end

@implementation TopicVUViewController

@synthesize topicVuGMGridView, topicsId, topicVUImages, noimage;

-(void) initializeView {
    
    
    UIToolbar* toolbarLeft = [[UIToolbar alloc]
                              initWithFrame:CGRectMake(-30, 0, 304, 35)];
    
    // create an array for the buttons
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:8];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(backBtnClicked:)];
    [buttons addObject:back];
    [back release];
    
    UIBarButtonItem *review = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"archieveout.png"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(reviewContentBtnClicked:)];
    //review.enabled = false;
    [buttons addObject:review];
    [review release];
    
    UIBarButtonItem *archive = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"selectAll.png"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(selectAllImagesBtnClicked:)];
    //archive.enabled = false;
    archive.tag = 1;
    [buttons addObject:archive];
    [archive release];
    
    /*UIBarButtonItem *selectAll = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"selectall.png"]
     style:UIBarButtonItemStylePlain
     target:self
     action:@selector(selectAllImagesBtnClicked:)];
     [buttons addObject:selectAll];
     [selectAll release];*/
    
    UIBarButtonItem *blankCanvas = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"blankcanvasicon.png"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(blankImageBtnOnClicked:)];
    [buttons addObject:blankCanvas];
    [blankCanvas release];
    
    preAnnotation = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"annotationoff.png"]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(editBtnClicked:)];
    preAnnotation.tag = 3;
    [buttons addObject:preAnnotation];
    [preAnnotation release];
    
    UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraicon.png"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(camButtonClicked:)];
    //camera.enabled = false;
    [buttons addObject:camera];
    [camera release];
    
    UIBarButtonItem *album = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"albumicon.png"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(albumButtonClicked:)];
    // album.enabled = false;
    [buttons addObject:album];
    [album release];
    
    [toolbarLeft setItems:buttons animated:NO];
    [buttons release];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
                                              initWithCustomView:toolbarLeft] autorelease];
    
    
    
    
    
    switch (currentMainSettings.welvu_loading_vu) {
        case SETTINGS_LOAD_TOPICVU_PATIENTVU_OPTION:
            retainPatientVU = FALSE;
            break;
        case SETTINGS_RETAIN_PATIENTVU_OPTION:
            retainPatientVU = TRUE;
            break;
        default:
            break;
    }
    
    //self.topicVuGMGridView.itemSpacing = currentMainSettings.welvu_content_vu_spacing;
    [self.topicVuGMGridView layoutSubviewsWithAnimation:GMGridViewItemAnimationFade];
    
    self.topicVuGMGridView.style = currentMainSettings.welvu_content_vu_style;
    
    switch (currentMainSettings.welvu_content_vu_grid_bg) {
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
-(IBAction)reviewContentBtnClicked:(id)sender {
    
    welvuArchiveImageController *welvuArchiveImage = [[[welvuArchiveImageController alloc]
                                                       initWithTopicId:topicsId] autorelease];
    welvuArchiveImage.delegate = self;
    [self.navigationController pushViewController:welvuArchiveImage animated:YES];
    edit = FALSE;
    preAnnotation.image = [UIImage imageNamed:@"annotationoff.png"];
    preAnnotation.tag = 3;
}

-(void)welvuArchiveImageDidFinish:(BOOL)isModified {
    if(isModified) {
        [self removeTopicVuImages];
        [self loadVU];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initializeView];
    }
    return self;
}

-(id)initwithTopicAndSettings:(NSInteger) topic_id:(welvu_main_settings *) current_settings
                             :(NSMutableArray *) patientVU_images{
    self = [super initWithNibName:@"TopicVUViewController" bundle:nil];
    if (self) {
        // Custom initialization
        topicsId = topic_id;
        currentMainSettings = current_settings;
        compPatientVUImages = patientVU_images;
    }
    return self;
}
-(IBAction)backBtnClicked:(id)sender {
    //  welvuViewController *control=[[welvuViewController alloc]init];
    // [self.navigationController pushViewController:control animated:YES];
    
    //[appDelegate.ddMenuController.navigationController popViewControllerAnimated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
    //  [appDelegate.ddMenuController.navigationController popViewControllerAnimated:YES];
}


-(void)loadVU {
    isAllTopicVUSelected = TRUE;
    topicLabel.text = [welvu_topics getTopicNameById:appDelegate.getDBPath :topicsId];
    topicVUImages = [welvu_images getImagesByTopicId:appDelegate.getDBPath :topicsId];
    [topicVuGMGridView reloadData];
    
    if(topicVUImages == nil) {
        noimage.hidden = FALSE;
    } else {
        noimage.hidden = TRUE;
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

-(void) updateOrderTopicVUImages {
    NSInteger orderNumber = 1;
    for(welvu_images *welvu_imagesModel in topicVUImages) {
        welvu_imagesModel.orderNumber = orderNumber;
        int updated = [welvu_images updateImagesOrderNumberByTopicId:appDelegate.getDBPath
                                                                    :welvu_imagesModel.topicId
                                                                    :welvu_imagesModel.imageId :orderNumber];
        orderNumber++;
    }
}
-(IBAction)blankImageBtnOnClicked:(id)sender{
    welvuTopicVUAnnotationViewController *welvuTopicVUAnnotation = [[welvuTopicVUAnnotationViewController alloc]
                                                                    initWithImageGroup:@"welvuTopicVUAnnotationViewControlleriPhone" bundle:nil
                                                                    currentTopicId:topicsId
                                                                    images:[topicVUImages mutableCopy] currentSelectedImage:0
                                                                    annotateBlankCanvas:true];
    welvuTopicVUAnnotation.delegate = self;
    welvuTopicVUAnnotation.modalPresentationStyle = UIModalPresentationFullScreen;
    welvuTopicVUAnnotation.modalTransitionStyle = UIModalTransitionStyleCoverVertical; //transition shouldn't matter
    [appDelegate.ddMenuController presentModalViewController:welvuTopicVUAnnotation animated:YES];
    [welvuTopicVUAnnotation release];
    edit = FALSE;
    // preAnnotation.image = [UIImage imageNamed:@"annotationoff.png"];
    // preAnnotation.tag = 3;
    topicVuGMGridView.editing = NO;
}

-(IBAction)editBtnClicked:(id)sender {
    UIBarButtonItem *btn  = (UIBarButtonItem *) sender;
    if(btn.tag == 3) {
        btn.tag = 4;
        btn.image = [UIImage imageNamed:@"annotationon.png"];
        topicVuGMGridView.editing = NO;
        edit = TRUE;
    } else {
        btn.tag = 3;
        btn.image = [UIImage imageNamed:@"annotationoff.png"];
        edit = FALSE;
    }
}

//Camera & Album
-(IBAction) camButtonClicked:(id)sender {
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        picker = [[UIImagePickerController alloc] init];
        picker.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        specialtyViewController *specialityVU = (specialtyViewController*)((welvuAppDelegate*)[[UIApplication sharedApplication] delegate]).special;
        // [specialityVU presentModalViewController:picker animated:YES];
        [appDelegate.ddMenuController presentModalViewController:picker animated:YES];
        // patientVuGMGridView.editing = NO;
        // deleteBtn.image = [UIImage imageNamed:@"deleteicon_closed.png"];
        // deleteBtn.tag = 1;
    }
}



-(IBAction) albumButtonClicked:(id)sender {
    
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        picker = [[UIImagePickerController alloc] init];
        picker.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        specialtyViewController *specialityVU = (specialtyViewController*)((welvuAppDelegate*)[[UIApplication sharedApplication] delegate]).special;
        // [specialityVU presentModalViewController:picker animated:YES];
        [appDelegate.ddMenuController presentModalViewController:picker animated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    [picker dismissModalViewControllerAnimated:YES];
    [picker release], picker = nil;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [picker release], picker = nil;
    
    [popover dismissPopoverAnimated:YES];
    [popover release], popover = nil;
    
}
-(void) removeTopicVuImages {
    if(topicVUImages != nil) {
        [topicVUImages release], topicVUImages = nil;
    }
}

-(void)welvuTopicVUAnnotationDidFinish:(BOOL)isModified {
    [appDelegate.ddMenuController dismissModalViewControllerAnimated:YES];
    if(isModified) {
        [self removeTopicVuImages];
        [self loadVU];
    }
}

//////////////////////////////////////////////////////////
//Intializing GridViews
//////////////////////////////////////////////////////////
-(void)intializeGMGridViews {
    topicVuGMGridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 40, 280, 256)];
    topicVuGMGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //topicVuGMGridView.autoresizesSubviews = NO;
    topicVuGMGridView.clipsToBounds = YES;
    topicVuGMGridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topicVuGMGridView];
    
    topicVuGMGridView.style = GMGridViewStylePush;
    topicVuGMGridView.itemSpacing = 3;
    topicVuGMGridView.minEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    topicVuGMGridView.centerGrid = NO;
    topicVuGMGridView.enableEditOnLongPress = YES;
    topicVuGMGridView.disableEditOnEmptySpaceTap = YES;
    topicVuGMGridView.actionDelegate = self;
    topicVuGMGridView.sortingDelegate = self;
    topicVuGMGridView.dataSource = self;
    topicVuGMGridView.mainSuperView = self.view;
}


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////
/*Required*/
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [topicVUImages count];
}
/*Required*/

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (INTERFACE_IS_PHONE)
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            return CGSizeMake(200, 135);
        }
        else
        {
            return CGSizeMake(170, 110);
        }
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            return CGSizeMake(THUMB_BUTTON_WIDTH1, THUMB_BUTTON_HEIGHT1);
        }
        else
        {
            return CGSizeMake(THUMB_BUTTON_WIDTH1, THUMB_BUTTON_HEIGHT1);
        }
    }
}
/*Required*/
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //NSLog(@"Creating view indx %d", index);
    
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    CGSize destinationSize = CGSizeMake(THUMB_IMAGE_WIDTH, THUMB_IMAGE_HEIGHT);
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 8;
        view.contentMode = UIViewContentModeCenter;
        cell.contentView = view;
        
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImage *thumbnail = nil;
    
    welvu_images *welvu_imagesModel = [topicVUImages objectAtIndex:index];
    
    if([welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE]) {
        UIImage *originalImage = [UIImage imageNamed:welvu_imagesModel.url];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
    } else if(([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE]
               ||[welvu_imagesModel.type isEqualToString:IMAGE_HISTORY_TYPE])&& welvu_imagesModel.imageId > 0) {
        NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        UIImage *originalImage = [UIImage imageWithData:imageData];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
    }
    
    if(welvu_imagesModel.selected || ([self searchImageGroups:welvu_imagesModel.imageId
                                                             :compPatientVUImages] > -1)) {
        cell.isSelected = TRUE;
        thumbnail  = [thumbnail imageWithBorderForSelected:THUMB_IMAGE_BORDER];
    } else {
        cell.isSelected = FALSE;
        thumbnail  = [thumbnail imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = thumbnail;
    [cell.contentView addSubview:imageView];
    
    
    return cell;
}

/*Required*/
- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    
    return YES; //index % 2 == 0;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////
/*Required*/
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    
    if(gridView == topicVuGMGridView) {
        GMGridViewCell *cell = (GMGridViewCell *)[gridView cellForItemAtIndex:position];
        if(!cell.isSelected && !edit) {
            for(UIView *subview in [cell.contentView subviews]) {
                if([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)subview;
                    imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                }
            }
            cell.isSelected = TRUE;
            welvu_images *welvu_imagesModel = [topicVUImages objectAtIndex:position];
            welvu_imagesModel.selected = YES;
            [self.delegate topicVUViewControllerImageSelected:welvu_imagesModel];
            NSLog(@"Did tap at index from 1st %d", position);
            appDelegate.ispatientVUContent = TRUE;
        } else if(edit) {
            //Image annotation part
            welvuTopicVUAnnotationViewController *welvuTopicVUAnnotation = [[welvuTopicVUAnnotationViewController alloc]
                                                                            initWithImageGroup:@"welvuTopicVUAnnotationViewControlleriPhone" bundle:nil
                                                                            currentTopicId:topicsId
                                                                            images:topicVUImages currentSelectedImage:position annotateBlankCanvas:false];
            welvuTopicVUAnnotation.delegate = self;
            welvuTopicVUAnnotation.modalPresentationStyle = UIModalPresentationFullScreen;
            welvuTopicVUAnnotation.modalTransitionStyle = UIModalTransitionStyleCoverVertical; //transition shouldn't matter
            [appDelegate.ddMenuController presentModalViewController:welvuTopicVUAnnotation animated:YES];
            [welvuTopicVUAnnotation release];
        }
    } else  {
        NSLog(@"Did tap at index from 2nd %d", position);
    }
}/*Required*/
- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    
    if(gridView == topicVuGMGridView) {
        NSLog(@"Tap on empty space 1st");
    } else  {
        NSLog(@"Tap on empty space 2nd");
    }
}
/*Required*/
- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
    UIAlertView *alert = nil;
    _lastDeleteItemIndexAsked = index;
    if([((welvu_images *)[topicVUImages objectAtIndex:_lastDeleteItemIndexAsked]).type isEqualToString:IMAGE_ASSET_TYPE]) {
        alert = [[UIAlertView alloc]
                 initWithTitle: NSLocalizedString(@"ALERT_TOPIC_VU_TITLE", nil)
                 message: NSLocalizedString(@"ALERT_TOPIC_VU_ARCHIVE_MSG", nil)
                 delegate: self
                 cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                 otherButtonTitles:NSLocalizedString(@"ARCHIVE", nil),nil];
    } else {
        alert = [[UIAlertView alloc]
                 initWithTitle: NSLocalizedString(@"ALERT_TOPIC_VU_TITLE", nil)
                 message: NSLocalizedString(@"ALERT_TOPIC_VU_ARCHIVE_DELETE_MSG", nil)
                 delegate: self
                 cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                 otherButtonTitles:NSLocalizedString(@"ARCHIVE", nil),
                 NSLocalizedString(@"DELETE", nil),nil];
    }
    
    [alert show];
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
                         NSLog(@"Tag: %d", cell.tag);
                     }
                     completion:nil
     ];
}
/*Required*/
- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIImageView *imageView;
    for(UIView *subview in [cell.contentView subviews]) {
        if([subview isKindOfClass:[UIImageView class]]) {
            imageView = (UIImageView *)subview;
        }
    }
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         if(!cell.isSelected) {
                             imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                         } else {
                             imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                         }
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil
     ];
    if(gridView == topicVuGMGridView) {
        [self updateOrderTopicVUImages];
    }
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    welvu_images *object = [topicVUImages objectAtIndex:oldIndex];
    [topicVUImages removeObject:object];
    [topicVUImages insertObject:object atIndex:newIndex];
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_TOPIC_VU_TITLE", nil)]) {
        if (buttonIndex == 1) {
            
            int update = [welvu_images deactivateImageFromTopic
                          :appDelegate.getDBPath:((welvu_images *)[topicVUImages objectAtIndex:_lastDeleteItemIndexAsked]).imageId];
            if(update > 0) {
                [topicVUImages removeObjectAtIndex:_lastDeleteItemIndexAsked];
                [topicVuGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
            }
            [imagesReviewBtn setEnabled:TRUE];
        } else if(buttonIndex == 2) {
            [self.delegate topicVUViewControllerRemoveImageSelected:(welvu_images *)[topicVUImages objectAtIndex
                                                                                     :_lastDeleteItemIndexAsked]];
            /* [welvu_vu_history deleteHistoryWithImageId:appDelegate.getDBPath:((welvu_images *)[topicVUImages objectAtIndex
             :_lastDeleteItemIndexAsked]).imageId];*/
            BOOL deleted = [welvu_images deleteImageFromTopic:appDelegate.getDBPath
                                                             :((welvu_images *)[topicVUImages objectAtIndex
                                                                                :_lastDeleteItemIndexAsked]).imageId];
            if(deleted) {
                [topicVUImages removeObjectAtIndex:_lastDeleteItemIndexAsked];
                [topicVuGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
            }
        }
        if([topicVUImages count] == 0) {
            noimage.hidden = FALSE;
        }
        
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil)
                                                                   style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
    
    
    [self intializeGMGridViews];
    [self initializeView];
    [self loadVU];
    topicVuGMGridView.mainSuperView = self.navigationController.view;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearedAllPatientVU:) name:NOTIFY_CLEARALL_PATIENTVU object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removedContentFromPatientVU:) name:NOTIFY_REMOVED_FROM_PATIENTVU object:nil];
}
-(void)clearedAllPatientVU:(NSNotification *)notification {
    if([topicVUImages count] > 0) {
        for(welvu_images *welvu_imagesModel in topicVUImages) {
            if(welvu_imagesModel.selected) {
                NSInteger index = [self searchImageGroups:welvu_imagesModel.imageId :topicVUImages];
                welvu_imagesModel.selected = NO;
                GMGridViewCell *cell = (GMGridViewCell *)[topicVuGMGridView cellForItemAtIndex:index];
                
                UIImageView *imageView;
                for(UIView *subview in [cell.contentView subviews]) {
                    if([subview isKindOfClass:[UIImageView class]]) {
                        imageView = (UIImageView *)subview;
                    }
                }
                imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                
                cell.isSelected = NO;
                welvu_imagesModel.selected = NO;
            }
        }
    }
}

- (void) removedContentFromPatientVU:(NSNotification *)notification {
    NSInteger index = [self searchImageGroups:((welvu_images *)[notification.userInfo objectForKey:TABLE_WELVU_IMAGES]).imageId :topicVUImages];
    if(index > -1) {
        welvu_images *welvu_imagesModel = [topicVUImages objectAtIndex:index];
        if(welvu_imagesModel.selected) {
            NSInteger index = [self searchImageGroups:welvu_imagesModel.imageId :topicVUImages];
            welvu_imagesModel.selected = NO;
            GMGridViewCell *cell = (GMGridViewCell *)[topicVuGMGridView cellForItemAtIndex:index];
            if([cell.contentView viewWithTag:THUMB_TICK_IMAGE_TAG]) {
                UIImageView *imageTickView = (UIImageView *) [cell.contentView viewWithTag:THUMB_TICK_IMAGE_TAG];
                imageTickView.hidden = TRUE;
            }
            cell.isSelected = NO;
            welvu_imagesModel.selected = NO;
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *) Picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT];
    UIImage *anImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(anImage, 1.0);
    NSString *imageName = [dateFormatter stringFromDate:[NSDate date]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString  *pickedImagePath = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@.jpg", path,
                                                                   imageName]];
    if([imageData writeToFile:pickedImagePath atomically:YES]){
        NSLog(@"Path: %@", pickedImagePath);
        welvu_images *welvu_imagesModel = [[welvu_images alloc] init];
        welvu_imagesModel.topicId = topicsId;
        welvu_imagesModel.imageDisplayName = imageName;
        welvu_imagesModel.orderNumber = ([welvu_images getMaxOrderNumber:appDelegate.getDBPath :topicsId] + 1);
        welvu_imagesModel.type = IMAGE_ALBUM_TYPE;
        welvu_imagesModel.url = pickedImagePath;
        
        NSInteger imageId = [welvu_images addNewImageToTopic:appDelegate.getDBPath :welvu_imagesModel:topicsId];
        if(imageId > 0) {
            welvu_images *welvu_imagesMod = [[welvu_images alloc] initWithImageId:imageId];
            welvu_imagesMod.topicId = welvu_imagesModel.topicId;
            welvu_imagesMod.imageDisplayName = welvu_imagesModel.imageDisplayName;
            welvu_imagesMod.orderNumber = welvu_imagesModel.orderNumber;
            welvu_imagesMod.type = welvu_imagesModel.type;
            welvu_imagesMod.url = welvu_imagesModel.url;
            if(topicVUImages == nil) {
                topicVUImages  = [[NSMutableArray alloc] init];
            }
            [topicVUImages addObject:welvu_imagesMod];
            [topicVuGMGridView insertObjectAtIndex:[topicVUImages count] - 1
                                     withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
            
            //[welvu_imagesMod release];
            noimage.hidden = TRUE;
        }
        [welvu_imagesModel release];
    }
    [dateFormatter release];
    [picker dismissModalViewControllerAnimated:YES];
    
    [picker release],picker = nil;
    
    
    if(popover != NULL) {
        [popover dismissPopoverAnimated:YES];
        [popover release], popover = nil;
    }
}


-(IBAction)selectAllImagesBtnClicked:(id)sender {
    edit = FALSE;
    preAnnotation.image = [UIImage imageNamed:@"annotationoff.png"];
    preAnnotation.tag = 3;
    topicVuGMGridView.editing = NO;
    if([topicVUImages count] > 0) {
        for(welvu_images *welvu_imagesModel in topicVUImages) {
            if(!welvu_imagesModel.selected) {
                NSInteger index = [self searchImageGroups:welvu_imagesModel.imageId :topicVUImages];
                welvu_imagesModel.selected = YES;
                GMGridViewCell *cell = (GMGridViewCell *)[topicVuGMGridView cellForItemAtIndex:index];
                
                UIImageView *imageView;
                for(UIView *subview in [cell.contentView subviews]) {
                    if([subview isKindOfClass:[UIImageView class]]) {
                        imageView = (UIImageView *)subview;
                    }
                }
                imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                
                cell.isSelected = TRUE;
                welvu_imagesModel.selected = TRUE;
            }
        }
        [self.delegate topicVUViewControllerImageSelectedAll:[topicVUImages mutableCopy]];
    }
}
-(NSInteger) searchImageGroups:(NSInteger) imgId:(NSMutableArray *) imagesArray {
    
    for(int i=0; i < imagesArray.count; i++) {
        welvu_images *img = [imagesArray objectAtIndex:i];
        if(img.imageId == imgId) {
            return i;
        }
    }
    return -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft
       || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return YES;
    }
	return NO;
}

- (BOOL)shouldAutorotate {
    return [self shouldAutorotateToInterfaceOrientation:self.interfaceOrientation];
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}
- (void)dealloc
{
    [topicVUImages release];
    [topicVuGMGridView release];
    [super dealloc];
}

@end
