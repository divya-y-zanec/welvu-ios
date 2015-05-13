//
//  welvuArchiveImageController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 22/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "welvuArchiveImageController.h"
#import "welvuContants.h"
#import "welvu_images.h"
#import "UIImage+Resize.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

//Controller private method declaration
@interface welvuArchiveImageController ()
<GMGridViewDataSource,
GMGridViewSortingDelegate,
GMGridViewActionDelegate> {
    NSInteger _lastDeleteItemIndexAsked;
    
    BOOL isModified;
}
@end

@implementation welvuArchiveImageController
@synthesize delegate;
@synthesize counter,update;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
        UIToolbar* toolbarLeft = [[UIToolbar alloc]
                                  initWithFrame:CGRectMake(0, 0, 40, 44)];
        
        // create an array for the buttons
        NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:8];
        
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(backBtnClicked:)];
        [buttons addObject:back];
        
        [toolbarLeft setItems:buttons animated:NO];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithCustomView:toolbarLeft];
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                      target:self
                                      action:@selector(doneBtnClicked:)];
        addButton.style = UIBarButtonItemStyleBordered;
        self.navigationItem.rightBarButtonItem = addButton;
    }
    return self;
}

//Custom method to initialize the view controller
- (id)initWithTopicId:(NSInteger)topic_Id {
    self = [super initWithNibName:@"welvuArchiveImageController" bundle:nil];
    if (self) {
        // Custom initialization
        topicsId = topic_Id;
        
        UIToolbar* toolbarLeft = [[UIToolbar alloc]
                                  initWithFrame:CGRectMake(0, 0, 40, 44)];
        
        // create an array for the buttons
        NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:8];
        
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(backBtnClicked:)];
        [buttons addObject:back];
        
        [toolbarLeft setItems:buttons animated:NO];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithCustomView:toolbarLeft];
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                      target:self
                                      action:@selector(doneBtnClicked:)];
        addButton.style = UIBarButtonItemStyleBordered;
        self.navigationItem.rightBarButtonItem = addButton;
    }
    return self;
}


-(IBAction)doneBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
       id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder  createEventWithCategory:@"welvuArchiveImageController"
                                                           action:@"doneBtnClicked"
                                                           label:@"done"
                                                           value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];


    @try {
        
        if (counter== 0) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"ALERT_NO_CONTENT_SELECTED_TITLE",nil)
                                  message: NSLocalizedString(@"ALERT_NO_TOPIC_SELECTED_MSG",nil)
                                  delegate: nil
                                  cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                  otherButtonTitles:nil];
            alert.tag = 1;
            [alert show];
            
        }
        else{
            for(welvu_images *welvu_ImagesModel in archivedVUImages) {
                if(welvu_ImagesModel.selected == true) {
                    isModified = true;
                    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                 update = [welvu_images unarchiveImageByTopicId:appDelegate.getDBPath :welvu_ImagesModel.imageId
                                                                      :topicsId
                                                                      :([welvu_images getMaxOrderNumber:appDelegate.getDBPath :topicsId
                                                                                                 userId:appDelegate.welvu_userModel.welvu_user_id
                                                                         ]+1)];
                }
            }
            [self.delegate welvuArchiveImageDidFinish:isModified];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
               NSString * description = [NSString stringWithFormat:@"welvuArchiveImageController_doneBtnClicked:%@",exception];

        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        

        
       
        
    }
}
/*
 * Method name: backBtnClicked
 * Description: clickbackbutton
 * Parameters: analytics
 * return self
 * Created On: 19-dec-2012
 */
-(IBAction)backBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder  createEventWithCategory:@"welvuArchiveImageController"
                                                           action:@"settingBtnClicked"
                                                            label:@"settings"
                                                            value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];

    @try {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
            id tracker = [[GAI sharedInstance] defaultTracker];
               NSString * description = [NSString stringWithFormat:@"welvuArchiveImageController_backBtnClicked:%@",exception];

        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];

        
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//////////////////////////////////////////////////////////
//Intializing GridViews
//////////////////////////////////////////////////////////
-(void)intializeGMGridViews {
    archivedVUGridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 50, 320, 654)];
    archivedVUGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //topicVuGMGridView.autoresizesSubviews = NO;
    archivedVUGridView.clipsToBounds = YES;
    archivedVUGridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:archivedVUGridView];
    
    archivedVUGridView.style = GMGridViewStylePush;
    archivedVUGridView.itemSpacing = 5;
    archivedVUGridView.minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    archivedVUGridView.centerGrid = NO;
    archivedVUGridView.actionDelegate = self;
    archivedVUGridView.sortingDelegate = self;
    archivedVUGridView.dataSource = self;
    archivedVUGridView.mainSuperView = self.view;
}


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////
/*Required*/
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [archivedVUImages count];
}
/*Required*/
- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (INTERFACE_IS_PHONE)
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            return CGSizeMake(170, 135);
        }
        else
        {
            return CGSizeMake(140, 110);
        }
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            return CGSizeMake(THUMB_BUTTON_WIDTH, THUMB_BUTTON_HEIGHT);
        }
        else
        {
            return CGSizeMake(THUMB_BUTTON_WIDTH, THUMB_BUTTON_HEIGHT);
        }
    }
}
/*Required*/
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
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
    
    welvu_images *welvu_imagesModel = [archivedVUImages objectAtIndex:index];
    
    if([welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE]) {
        NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        UIImage *originalImage = [UIImage imageWithData:imageData];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
    } else if(([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE]
               ||[welvu_imagesModel.type isEqualToString:IMAGE_HISTORY_TYPE])&& welvu_imagesModel.imageId > 0) {
        NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        UIImage *originalImage = [UIImage imageWithData:imageData];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
    }
    
    if(welvu_imagesModel.selected) {
        cell.isSelected = TRUE;
        thumbnail  = [thumbnail imageWithBorderForSelected:THUMB_IMAGE_BORDER];
        //cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"imageBackground1.png"]];
    } else {
        cell.isSelected = FALSE;
        thumbnail  = [thumbnail imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
        //cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"imageBackground3.png"]];
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
    GMGridViewCell *cell = (GMGridViewCell *)[gridView cellForItemAtIndex:position];
    if(!cell.isSelected) {
        for(UIView *subview in [cell.contentView subviews]) {
            if([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)subview;
                imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
            }
        }
        cell.isSelected = TRUE;
        welvu_images *welvu_imagesModel = [archivedVUImages objectAtIndex:position];
        welvu_imagesModel.selected = YES;
    } else {
        
        for(UIView *subview in [cell.contentView subviews]) {
            if([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)subview;
                imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
            }
        }
        cell.isSelected = FALSE;
        welvu_images *welvu_imagesModel = [archivedVUImages objectAtIndex:position];
        welvu_imagesModel.selected = NO;
    }
}
/*Required*/
- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    
}
/*Required*/
- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
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
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    welvu_images *object = [archivedVUImages objectAtIndex:oldIndex];
    [archivedVUImages removeObject:object];
    [archivedVUImages insertObject:object atIndex:newIndex];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    [archivedVUImages exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}


/*Required*/
- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Declaring Page View Analytics
    
    
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];

    [[GAI sharedInstance] dispatch];
    

        // Do any additional setup after loading the view from its nib.
    isModified = false;
    //Intialize the Application delegate
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    contentArchive.text = CONTENTS_ARCHIVE;
    //Get topics from the database
    archivedVUImages = [welvu_images getArchivedImage:appDelegate.getDBPath];
    [self intializeGMGridViews];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation != UIInterfaceOrientationPortrait &&
            interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    
}


- (BOOL)shouldAutorotate {
    return YES;
}
@end
