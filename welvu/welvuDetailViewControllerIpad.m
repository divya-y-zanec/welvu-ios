//
//  welvuDetailViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 15/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvuDetailViewControllerIpad.h"
#import "welvuMasterViewController.h"
#import "GMGridViewLayoutStrategies.h"
#import "AccordionView.h"
#import "welvuContants.h"
#import "welvu_topics.h"
#import "welvu_images.h"
#import "WelVUMapsLink.h"
#import "welvu_history.h"
#import "welvu_organization.h"

#import "UIImage+Resize.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "JSTokenField.h"
#import "welvu_contenttag.h"
#import "NSFileManagerDoNotBackup.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "Guid.h"
#import "welvu_sync.h"
#import "PathHandler.h"
//EMR
#import "ShinobiGetValue.h"
#import "ShinobiChart+LineChart.h"
#import "welvuIPXViewController.h"
//Reachability
#import "Reachability.h"
#import "ELCAlbumPickerViewController.h"


@interface welvuDetailViewControllerIpad () <GMGridViewDataSource, GMGridViewSortingDelegate,
GMGridViewActionDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
    NSInteger _lastDeleteItemIndexAsked;
    NSInteger previousSelectedId;
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation welvuDetailViewControllerIpad

@synthesize detailItem = _detailItem;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize retainPatientVU, patientVUImages, patientVuGMGridView, masterViewController;
@synthesize topFadingView = _topFadingView;
@synthesize bottomFadingView = _bottomFadingView;
@synthesize themeLogo, notificationLable;
@synthesize internetReach,hostReach, spinner ,userCreatedTopicID;
/*
 * Method name: intializeSettings
 * Description: change the view according to the settings change initlizing the settings
 * Parameters: nil
 * return nil
 */
- (void)intializeSettings {
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OPENEMR]
       || [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]
       || [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        if(!appDelegate.currentPatientInfo == nil && lineChart!=nil) {
            [self showGraphView];
        }
    }
    
    
    
    BOOL *guideAnimation = [defaults boolForKey:@"guideAnimationOn"];
    [defaults synchronize];
    
    if ([patientVUImages count] >=1 && !isAnimationStarted && guideAnimation &&(appDelegate.currentWelvuSettings.isAnimationOn)) {
        isAnimationStarted = TRUE;
        [self flashOn:animatedButton];
    } else {
        isAnimationStarted = FALSE;
        [self flashOff:animatedButton];
    }
    [patientVuGMGridView reloadData];
    self.patientVuGMGridView.itemSpacing = ((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_spacing;
    [self.patientVuGMGridView layoutSubviewsWithAnimation:GMGridViewItemAnimationFade];
    
    self.patientVuGMGridView.style = ((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_style;
    
    switch (((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_grid_bg) {
        case SETTINGS_CONTENT_VU_GRID_BG_NONE:
            self.patientVuGMGridView.backgroundColor = [UIColor clearColor];
            break;
        case SETTINGS_CONTENT_VU_GRID_BG:
            self.patientVuGMGridView.backgroundColor = [UIColor lightGrayColor];
            break;
        default:
            break;
    }
}
/*
 * Method name: initWithNibName
 * Description: display the view and allocate the mutable array and add albumcount
 * Parameters: bundle
 * return self
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    
    
    if (self) {
        //self.title = NSLocalizedString(@"Detail", @"Detail");
        [self.navigationController setNavigationBarHidden:YES];
        patientVUImages = [[NSMutableArray alloc] init];
        previousSelectedId = -1;
        albumAddedCount = LOCAL_TEMP_CONTENT_ID_START_RANGE;
        //
        
    }
    return self;
}
#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //network reachability
    
    //notification for reachability
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification object: nil];
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    hostReach = [Reachability reachabilityWithHostName:PING_HOST_URL];
    [hostReach startNotifier];
    
    
    //Declaring Page View Analytics
    
    
    /*[[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Pre VU - Pv"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];*/
    
    
    //token field
    scrol.layer.cornerRadius = 10;
    scrol.hidden = true;
    tagLabel.hidden = true;
    currentOpenedTopicId = 0;
    
    NSMutableArray *animatedImages = [[NSMutableArray alloc] initWithCapacity:2];
    [animatedImages addObject:[UIImage imageNamed:@"patientVUIcon.png"]];
    [animatedImages addObject:[UIImage imageNamed:@"patientVUIcon2.png"]];
    
    animatedButton =  [[UIImageView alloc] initWithFrame:CGRectMake(0,0,68,53)];
    animatedButton.animationImages = animatedImages;
    animatedButton.animationDuration = 1;
    [patientVU addSubview:animatedButton];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTokenFieldFrameDidChange:)
                                                 name:JSTokenFieldFrameDidChangeNotification
                                               object:nil];
    _toGetTagName = [[NSMutableArray alloc] init];
    
    [self.view addSubview:scrol];
    
    UIView *separator1 = [[UIView alloc] initWithFrame:CGRectMake(0, _toTokenfield.bounds.size.height-1, _toTokenfield.bounds.size.width, 1)];
    [separator1 setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_toTokenfield addSubview:separator1];
    [separator1 setBackgroundColor:[UIColor lightGrayColor]];
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"RightPanelWithBanner.png"]];
    
    [self themeSettingsViewControllerDidFinish];
    
    clearAll.enabled = NO;
    deleteVUBtn.enabled = NO;
    selectAllBtn.enabled = NO;
    
    [self startUpViewController];
    [self intializeGMGridViews];
    [self intializeSettings];
    self.topFadingView.hidden = true;
    self.bottomFadingView.hidden = true;
    [self.view bringSubviewToFront:self.topFadingView];
    [self.view bringSubviewToFront:self.bottomFadingView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAnnotatedImage:)
                                                 name:NOTIFY_BLANK_IMAGE_ANNOTATED
                                               object:nil];
    
    //EMR
    seriesListView.hidden = YES;
    
    snapBtn.enabled = NO;
    //EMR
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    //Map search bar
    [self.searchDisplayController setDelegate:self];
    [ibSearchBar setDelegate:self];
    ibSearchBar.hidden = true;
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_EBOLAVU]||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]) {
        boxBtn.hidden = false;
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        
        if(appDelegate.welvu_userModel.org_id == 0) {
            //  ipxBtn.hidden = true;
        } else {
            ipxBtn.hidden = false;
        }
        
        snapBtn.hidden = TRUE;
        mapVUBtn.hidden = true;
        deleteVUBtn.frame= CGRectMake(226, deleteVUBtn.frame.origin.y, deleteVUBtn.frame.size.width, deleteVUBtn.frame.size.height);
        
        clearAll.frame= CGRectMake(279, clearAll.frame.origin.y, clearAll.frame.size.width, clearAll.frame.size.height);
        
        
        photoBtn.frame= CGRectMake(332, photoBtn.frame.origin.y, photoBtn.frame.size.width, photoBtn.frame.size.height);
        
        cameraBtn.frame= CGRectMake(383, cameraBtn.frame.origin.y, cameraBtn.frame.size.width, cameraBtn.frame.size.height);
        
        //saveBtn.frame= CGRectMake(436, saveBtn.frame.origin.y, saveBtn.frame.size.width, saveBtn.frame.size.height);
        
    } else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OPENEMR]) {
        
        // ipxBtn.hidden = true;
        mapVUBtn.hidden = true;
        previewVUContents.backgroundColor = [UIColor clearColor];
        
        
    }else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_HEV] ) {
        
        ipxBtn.hidden = false;
        mapVUBtn.hidden = true;
        previewVUContents.backgroundColor = [UIColor clearColor];
        
        
    }
    
    else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        ipxBtn.hidden = false;
        boxBtn.hidden = false;
        saveBtn.hidden = true;
        saveBtn.enabled = false;
        snapBtn.hidden = false;
        mapVUBtn.hidden = false;
        snapBtn.frame= CGRectMake(436, snapBtn.frame.origin.y, snapBtn.frame.size.width, snapBtn.frame.size.height);
        
        boxBtn.frame= CGRectMake(383, boxBtn.frame.origin.y, boxBtn.frame.size.width, boxBtn.frame.size.height);
        
        mapVUBtn.frame= CGRectMake(332 , mapVUBtn.frame.origin.y, mapVUBtn.frame.size.width, mapVUBtn.frame.size.height);
        
        cameraBtn.frame= CGRectMake(279 , cameraBtn.frame.origin.y, cameraBtn.frame.size.width, cameraBtn.frame.size.height);
        
        photoBtn.frame= CGRectMake(226 , photoBtn.frame.origin.y, photoBtn.frame.size.width, photoBtn.frame.size.height);
        
        clearAll.frame= CGRectMake(173 , clearAll.frame.origin.y, clearAll.frame.size.width, clearAll.frame.size.height);
        
        deleteVUBtn.frame= CGRectMake(120 , deleteVUBtn.frame.origin.y, deleteVUBtn.frame.size.width, deleteVUBtn.frame.size.height);
        
        
        
        previewVUContents.backgroundColor = [UIColor clearColor];
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self; // send loc updates to myself
        locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    
    if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_EBOLAVU]){
        
        saveBtn.hidden = false;
    }
    
}


- (void)viewDidUnload {
    [super viewDidUnload];
    [self startUpViewController];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFY_BLANK_IMAGE_ANNOTATED
                                                  object:nil];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    /* appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
     int orgCount = [welvu_organization getOrganizationCount:[appDelegate getDBPath]];
     
     if(appDelegate.networkReachable) {
     [appDelegate addorganizationDetails];
     appDelegate.checkOrganizationDetails = true;
     
     }
     */
    
    
    
    //  notificationLable.hidden = YES;
    //refresh so dat edited image will be updated
    if (previousSelectedId > 0) {
        welvu_images *welvu_imgesModel = (welvu_images *) [patientVUImages
                                                           objectAtIndex:[self searchImageGroups:previousSelectedId :patientVUImages]];
        welvu_imgesModel.pickedToView = YES;
        [self setPreviewImageInView:welvu_imgesModel];
        [patientVuGMGridView reloadData];
    }
    if(locationManager != nil) {
        [locationManager startUpdatingLocation];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    if(appDelegate.welvu_userModel != nil &&  [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        
        [[BoxSDK sharedSDK].foldersManager folderInfoWithID:BoxAPIFolderIDRoot requestBuilder:nil success:nil failure:nil];
    }
    bundleIdentifier = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    if (overlay !=nil) {
        [overlay removeFromSuperview];
        overlay = nil;
    }
    [super viewDidAppear:animated];
    if ( appDelegate.showGuideDetailVU == 0) {
        [self performSelector:@selector(informationBtnClicked:)withObject:nil];
       
    }
    mapVUBtn.frame= CGRectMake( 100, mapVUBtn.frame.origin.y, mapVUBtn.frame.size.width, mapVUBtn.frame.size.height);

    snapBtn.frame= CGRectMake(153, snapBtn.frame.origin.y, snapBtn.frame.size.width, snapBtn.frame.size.height);
    boxBtn.frame= CGRectMake(206, boxBtn.frame.origin.y, boxBtn.frame.size.width, boxBtn.frame.size.height);

    deleteVUBtn.frame= CGRectMake(259, deleteVUBtn.frame.origin.y, deleteVUBtn.frame.size.width, deleteVUBtn.frame.size.height);
    clearAll.frame= CGRectMake(312, clearAll.frame.origin.y, clearAll.frame.size.width, clearAll.frame.size.height);
    
    cameraBtn.frame= CGRectMake(363, cameraBtn.frame.origin.y, cameraBtn.frame.size.width, cameraBtn.frame.size.height);
    
    photoBtn.frame= CGRectMake(416 , photoBtn.frame.origin.y, photoBtn.frame.size.width, photoBtn.frame.size.height);
    saveBtn.frame= CGRectMake(463, saveBtn.frame.origin.y, saveBtn.frame.size.width, saveBtn.frame.size.height);
    
}


- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    notificationLable.hidden = TRUE;
    [notificationLable setAlpha:0.0];
    if(locationManager != nil) {
        [locationManager stopUpdatingLocation];
    }
    
}
/*
 * Method name: intializePreviewImageContent
 * Description: initlize the image content of the view i:e preview inage content
 * Parameters: nil
 * return nil
 */
- (void)intializePreviewImageContent {
    previewVUContent = [[UIImageView alloc] initWithFrame:
                        CGRectMake(0, 0, IMAGE_VIEW_WIDTH, IMAGE_VIEW_HEIGHT)];
    previewVUContent.contentMode = UIViewContentModeScaleAspectFit;
    [previewVUContents addSubview:previewVUContent];
}
/*
 * Method name: intializePreviewImageContent
 * Description:Remove the image content for the view i:e preview
 * Parameters: nil
 * return nil
 */
- (void)removePreviewImageContent {
    [self removePatientGraphContent];
    if (previewVUContent != nil) {
        [previewVUContent removeFromSuperview];
        previewVUContent = nil;
    }
}
/*
 * Method name: intializeVideoPreviewContent
 * Description: initlize the video content of the view i:e preview video content
 * Parameters: nil
 * return nil
 */
- (void)intializeVideoPreviewContent  {
    moviePlayerController = [[MPMoviePlayerController alloc] init];
    [moviePlayerController setAllowsAirPlay:NO];
    [moviePlayerController setControlStyle:MPMovieControlStyleEmbedded];
    [moviePlayerController setEndPlaybackTime:-1];
    [moviePlayerController setInitialPlaybackTime:-1];
    [moviePlayerController setMovieSourceType:MPMovieSourceTypeUnknown];
    [moviePlayerController setRepeatMode:MPMovieRepeatModeNone];
    [moviePlayerController setScalingMode:MPMovieScalingModeAspectFit];
    [moviePlayerController setShouldAutoplay:NO];
    [moviePlayerController setUseApplicationAudioSession:NO];
    [moviePlayerController.view setFrame:CGRectMake(0, 0, IMAGE_VIEW_WIDTH, IMAGE_VIEW_HEIGHT)];
    [previewVUContents addSubview:moviePlayerController.view];
}

- (void)removeVideoPreviewContent {
    if(moviePlayerController != nil) {
        [moviePlayerController stop];
        [moviePlayerController.view removeFromSuperview];
        moviePlayerController = nil;
    }
}

/*
 * Method name: searchImageGroups
 * Description: to search the topic
 * Parameters: NSInteger,NSMutableArray
 * Return Type: NSInteger
 */
- (NSInteger)searchImageGroups:(NSInteger)imgId:(NSMutableArray *)imagesArray {
    
    for (int i=0; i < imagesArray.count; i++) {
        welvu_images *img = [imagesArray objectAtIndex:i];
        if (img.imageId == imgId) {
            return i;
        }
    }
    return -1;
}


- (NSInteger)searchMapLinkGroups:(NSInteger)imgId:(NSMutableArray *)imagesArray {
    
    for (int i=0; i < imagesArray.count; i++) {
        WelVUMapsLink *mapLink = [imagesArray objectAtIndex:i];
        if (mapLink.imageId == imgId) {
            return i;
        }
    }
    return -1;
}

- (NSInteger) searchPatientImageGroups:(NSInteger) imgId:(NSMutableArray *) imagesArray {
    
    for(int i=0; i < imagesArray.count; i++) {
        welvu_images *img = [imagesArray objectAtIndex:i];
        if(img.patientImageID == imgId) {
            return i;
        }
    }
    return -1;
}

- (NSInteger) searchTokenIndex:(NSString *) tokenTitle:(NSMutableArray *) tokenArray {
    for (int i=0; i < tokenArray.count; i++) {
        
        if ([tokenTitle isEqualToString:(NSString *)[tokenArray objectAtIndex:i]]) {
            return i;
        }
    }
    return -1;
}

/*
 * Method name: getThumbnail
 * Description: get image thumbmail of destination size
 * Parameters: welvu_imagesModel
 * Return Type: UIImage
 */
- (UIImage *)getThumbnail:(welvu_images *)welvu_imagesModel {
    UIImage *thumbnail = nil;
    CGSize destinationSize = CGSizeMake(THUMB_HORIZONTAL_IMAGE_WIDTH, THUMB_HORIZONTAL_IMAGE_HEIGHT);
    if([welvu_imagesModel.type isEqualToString:IMAGE_PATIENT_TYPE]
       || [welvu_imagesModel.type isEqualToString:IMAGE_PATIENT_TYPE]  ) {
        // NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        UIImage *originalImage = [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        originalImage = nil;
        //imageData = nil;
    }
    
    
    
    else if([welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE]
            || [welvu_imagesModel.type isEqualToString:IMAGE_PATIENT_TYPE]  ) {
        //  NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        UIImage *originalImage =  [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        originalImage = nil;
        // imageData = nil;
    }
    
    else if(([welvu_imagesModel.type isEqualToString:IMAGE_PATIENTINFO_TYPE]
             ||[welvu_imagesModel.type isEqualToString:IMAGE_HISTORY_TYPE])&& welvu_imagesModel.imageId > 0) {
        UIImage *originalImage = nil;
        if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            // NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            originalImage =  [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
            //  imageData = nil;
        } else {
            originalImage = welvu_imagesModel.imageData;
        }
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        originalImage = nil;
    }
    
    else if(([welvu_imagesModel.type isEqualToString:GRAPH_IMAGE_TYPE]
             ||[welvu_imagesModel.type isEqualToString:IMAGE_HISTORY_TYPE])&& welvu_imagesModel.imageId > 0) {
        UIImage *originalImage = nil;
        if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            // NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            originalImage =  [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
            // imageData = nil;
        } else {
            originalImage = welvu_imagesModel.imageData;
        }
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        originalImage = nil;
    }
    
    else if(([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE]
             ||[welvu_imagesModel.type isEqualToString:IMAGE_HISTORY_TYPE])&& welvu_imagesModel.imageId > 0) {
        UIImage *originalImage = nil;
        if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            // NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            originalImage =  [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
            // imageData = nil;
        } else {
            originalImage = welvu_imagesModel.imageData;
        }
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        originalImage = nil;
    } else if([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] && welvu_imagesModel.imageId == 0) {
        UIImage *originalImage = welvu_imagesModel.imageData;
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
    } else if([welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_TYPE]
              || [welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE] || [welvu_imagesModel.type isEqualToString:VIDEO_PATIENT_TYPE]) {
        UIImage *originalImage = [self generateImageFromVideo:welvu_imagesModel.url :welvu_imagesModel.type];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        originalImage = nil;
    }
    
    else if([welvu_imagesModel.type isEqualToString:IMAGE_BLANK_TYPE]) {
        NSString *imageName = [NSString stringWithFormat:welvu_imagesModel.url];
        UIImage *originalImage =  [UIImage imageNamed:imageName];
        // UIImage *originalImage = [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        originalImage = nil;
        
    }
    else if([welvu_imagesModel.type isEqualToString:IMAGE_PATIENTINFO_TYPE] && welvu_imagesModel.imageId == 0) {
        UIImage *originalImage = welvu_imagesModel.imageData;
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        originalImage = nil;
    }
    else if([welvu_imagesModel.type isEqualToString:GRAPH_IMAGE_TYPE] && welvu_imagesModel.imageId == 0) {
        UIImage *originalImage = welvu_imagesModel.imageData;
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        originalImage = nil;
    }
    else if([welvu_imagesModel.type isEqualToString:IMAGE_PATIENTINFO_TYPE]) {
        NSString *imageName = [NSString stringWithFormat:welvu_imagesModel.url];
        UIImage *originalImage =  [UIImage imageNamed:imageName];
        // UIImage *originalImage = [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        originalImage = nil;
        
    }
    else if([welvu_imagesModel.type isEqualToString:GRAPH_IMAGE_TYPE]) {
        NSString *imageName = [NSString stringWithFormat:welvu_imagesModel.url];
        UIImage *originalImage =  [UIImage imageNamed:imageName];
        // UIImage *originalImage = [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        
    }
    else if(([welvu_imagesModel.type isEqualToString:IMAGE_PATIENTINFO_TYPE]
             ||[welvu_imagesModel.type isEqualToString:IMAGE_HISTORY_TYPE])&& welvu_imagesModel.imageId > 0) {
        UIImage *originalImage = nil;
        if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            //  NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            originalImage = [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
            //  imageData = nil;
        } else {
            originalImage = welvu_imagesModel.imageData;
        }
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        originalImage = nil;
    }
    else if(([welvu_imagesModel.type isEqualToString:GRAPH_IMAGE_TYPE]
             ||[welvu_imagesModel.type isEqualToString:IMAGE_HISTORY_TYPE])&& welvu_imagesModel.imageId > 0) {
        UIImage *originalImage = nil;
        if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            //  NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            originalImage = [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
            //  imageData = nil;
        } else {
            originalImage = welvu_imagesModel.imageData;
        }
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        originalImage = nil;
    }
    return thumbnail;
}

/*
 * Method name: setPreviewImageInView
 * Description: to set the Preview of image in the view
 * Parameters: welvu_imagesModel
 * Return Type: nil
 */
- (void)setPreviewImageInView:(welvu_images *)welvu_imagesModel {
    if(spinner != nil) {
        [spinner removeFromSuperview];
        spinner = nil;
    }
    CGSize destinationSize = CGSizeMake(IMAGE_VIEW_WIDTH, IMAGE_VIEW_HEIGHT);
    if([welvu_imagesModel.type isEqualToString:IMAGE_PATIENTINFO_TYPE] && welvu_imagesModel.imageId == 0) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        UIImage *originalImage = [UIImage imageWithData:imageData];
        previewVUContent.image = [[originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                  makeRoundCornerImage:5 :5];
    } else if([welvu_imagesModel.type isEqualToString:GRAPH_IMAGE_TYPE] && welvu_imagesModel.imageId == 0) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        UIImage *originalImage = [UIImage imageWithData:imageData];
        previewVUContent.image = originalImage;
    }  else if([welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE] ||
               [welvu_imagesModel.type isEqualToString:IMAGE_PATIENT_TYPE]) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        UIImage *originalImage = [UIImage imageWithData:imageData];
        previewVUContent.image = [[originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                  makeRoundCornerImage:5 :5];
    } else if([welvu_imagesModel.type isEqualToString:IMAGE_BLANK_TYPE]) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        NSString *imageName = [NSString stringWithFormat:welvu_imagesModel.url];
        UIImage *originalImage =  [UIImage imageNamed:imageName];
        // UIImage *originalImage = [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
        previewVUContent.image = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        
        /* UIImage *originalImage = [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
         previewVUContent.image = [[originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
         makeRoundCornerImage:5 :5];*/
    }
    else if(([welvu_imagesModel.type isEqualToString:IMAGE_PATIENTINFO_TYPE]
             ||[welvu_imagesModel.type isEqualToString:IMAGE_HISTORY_TYPE])&& welvu_imagesModel.imageId > 0) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        UIImage *originalImage = nil;
        if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            originalImage = [UIImage imageWithData:imageData];
        } else {
            originalImage = welvu_imagesModel.imageData;
        }
        previewVUContent.image = [[originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                  makeRoundCornerImage:5 :5];
    }
    else if(([welvu_imagesModel.type isEqualToString:GRAPH_IMAGE_TYPE]
             ||[welvu_imagesModel.type isEqualToString:IMAGE_HISTORY_TYPE])&& welvu_imagesModel.imageId > 0) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        UIImage *originalImage = nil;
        if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            originalImage = [UIImage imageWithData:imageData];
        } else {
            originalImage = welvu_imagesModel.imageData;
        }
        previewVUContent.image = originalImage;
    }
    else if(([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE]
             ||[welvu_imagesModel.type isEqualToString:IMAGE_HISTORY_TYPE])&& welvu_imagesModel.imageId > 0) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        UIImage *originalImage = nil;
        if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            originalImage = [UIImage imageWithData:imageData];
        } else {
            originalImage = welvu_imagesModel.imageData;
        }
        previewVUContent.image = [[originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                  makeRoundCornerImage:5 :5];
    } else if([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] && welvu_imagesModel.imageId == 0) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        UIImage *originalImage = welvu_imagesModel.imageData;
        previewVUContent.image = [[originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                  makeRoundCornerImage:5 :5];
    } else if([welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_TYPE]
              || [welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE] || [welvu_imagesModel.type isEqualToString:VIDEO_PATIENT_TYPE]) {
        [self removePreviewImageContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(moviePlayerController == nil) {
            [self intializeVideoPreviewContent];
        }
        NSURL *theContentURL;
        if(![[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            NSBundle *bundle = [NSBundle mainBundle];
            NSArray *nameAndType = [welvu_imagesModel.url componentsSeparatedByString: @"."];
            NSString *moviePath = [bundle pathForResource:[nameAndType objectAtIndex:0] ofType:[nameAndType objectAtIndex:1]];
            theContentURL = [NSURL fileURLWithPath:moviePath];
        } else {
            theContentURL = [NSURL fileURLWithPath:welvu_imagesModel.url];
        }
        moviePlayerController.movieSourceType = MPMovieSourceTypeFile;
        [moviePlayerController setContentURL:theContentURL];
        [moviePlayerController setUseApplicationAudioSession:NO];
        [moviePlayerController prepareToPlay];
    }
    
    
    scrol.hidden = false;
    tagLabel.hidden = false;
    if (_toTokenfield != nil) {
        [_toTokenfield removeFromSuperview];
        _toTokenfield = nil;
    }
    _toTokenfield = [[JSTokenField alloc] initWithFrame:CGRectMake(0, 0, 650, 30)];
    _toTokenfield.contentMode = UIViewContentModeTopLeft;
    [_toTokenfield setBackgroundColor:[UIColor clearColor]];
	[_toTokenfield setDelegate:self];
	[scrol addSubview:_toTokenfield];
    
    scrol.contentSize=CGSizeMake(_toTokenfield.frame.size.width, _toTokenfield.frame.size.height);
    [scrol setScrollsToTop:YES];
    
    [_toGetTagName removeAllObjects];
    
    getContentValue=[welvu_contenttag reterievetagnamefromdb:appDelegate.getDBPath :previousSelectedId];
    
    
    NSMutableArray *getContent=[[NSMutableArray alloc]initWithObjects:getContentValue, nil];
    NSArray *temp =[[getContent lastObject] componentsSeparatedByString:@","];
    for (int i=0; i < temp.count; i++) {
        [_toTokenfield addTokenWithTitle:temp[i] representedObject:self];
        
    }
    lineChart = nil;
    [patientVuGMGridView reloadData];
}
/*
 * Method name: saveAsTopicBtnClicked
 * Description: To save the image and video content as topic in topicVU
 * Parameters: id
 * Return Type: nil
 */
- (IBAction)saveAsTopicBtnClicked:(id)sender {
    //declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"Pre VU - PV"
                                                          action:@"Save Topic - PV"
                                                           label:@"saveAsTopic"
                                                           value:nil] build];
   
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];

    
    
    @try {
        [moviePlayerController stop];
        [self popoverControllerDidDismissPopover:popover];
        // patientVUImages
        if ([patientVUImages count] > 0) {
            [self getTopicName];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"ALERT_NO_CONTENT_ADDED_TITLE", nil)
                                  message:  NSLocalizedString(@"ALERT_NO_CONTENT_ADDED_MSG", nil)
                                  delegate: nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"PreVU-PV_saveAsTopic: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

//Get the name of the Topic to save the Images from the PatientVU.
- (void)getTopicName {
    UIAlertView *topicName = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_SAVE_NEW_TOPIC_TITLE", nil)
                                                        message:NSLocalizedString(@"ALERT_SAVE_NEW_TOPIC_MSG", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:NSLocalizedString(@"OK", nil) , nil];
    
    [topicName setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [topicName show];
    [[topicName textFieldAtIndex:0] setPlaceholder:NSLocalizedString(@"PLACEHOLDER_ENTER_TOPIC_NAME", nil)];
    
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    BOOL isTopicValid = YES;
    if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_SAVE_NEW_TOPIC_TITLE", nil)]) {
        NSRange range = [[[alertView textFieldAtIndex:0] text] rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        NSString *inputText = [[[alertView textFieldAtIndex:0] text] stringByReplacingCharactersInRange:range withString:@""];
        if( [inputText length] > 0  && [inputText length] < 50) {
            isTopicValid = YES;
            if([welvu_topics isTopicAlreadyExist:appDelegate.getDBPath:inputText userId:appDelegate.welvu_userModel.welvu_user_id]) {
                isTopicValid = NO;
            }
        } else {
            isTopicValid = NO;
        }
    }
    return isTopicValid;
}
/*
 * Method name: informationBtnClicked
 * Description: show the guide for the user
 * Parameters: id
 * return nil
 */
- (IBAction)informationBtnClicked:(id)sender {
    //declaring Event Tracking Analytics
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"UI"
                                            action:@"buttonPress"
                                             label:@"dispatch"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
    
    
    
    @try {
   
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
       
               if(appDelegate.welvu_userModel.org_id > 0) {
            [moviePlayerController stop];
            overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            overlay.alpha = 1;
            overlay.backgroundColor = [UIColor clearColor];
            
            UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            UIButton *overlayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [overlayCustomBtn addTarget:self action:@selector(closeOverlay:) forControlEvents:UIControlEventTouchUpInside];
            [overlayCustomBtn setFrame:CGRectMake(0, 0, 1024, 768)];
            if (masterViewController.accordion.accordianSelectedFlag) {
                overlayImageView.image = [UIImage imageNamed:@"TopicVUAccordianOverlay-iPx.png"];
                UIButton *header = [ masterViewController.accordion.headers objectAtIndex: masterViewController.accordion.selectedIndex];
                NSInteger yCoordinate = 0;
                if ((header.frame.origin.y + 44 + 445) >
                    masterViewController.accordion.scrollView.bounds.size.height) {
                    yCoordinate = header.frame.origin.y - ((header.frame.origin.y + 44 + 500) -
                                                       masterViewController.accordion.scrollView.bounds.size.height);
                } else {
                    yCoordinate = header.frame.origin.y;
                }
                UIImageView *overlaySubImageView = [[UIImageView alloc]
                                                    initWithFrame:CGRectMake(15,                                                                       (yCoordinate + 106),
                                                                             259, 498)];
                overlaySubImageView.image = [UIImage imageNamed:@"patientVULeftPanel.png"];
                
                [overlayImageView addSubview:overlaySubImageView];
                
            } else {
                overlayImageView.image = [UIImage imageNamed:@"prevuscreen-org.png"];
            }
            [overlay addSubview:overlayImageView];
            [overlay addSubview:overlayCustomBtn];
            
            [appDelegate.splitViewController.view addSubview:overlay];
        }
        else {
            [moviePlayerController stop];
            overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            overlay.alpha = 1;
            overlay.backgroundColor = [UIColor clearColor];
            
            UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            UIButton *overlayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [overlayCustomBtn addTarget:self action:@selector(closeOverlay:) forControlEvents:UIControlEventTouchUpInside];
            [overlayCustomBtn setFrame:CGRectMake(0, 0, 1024, 768)];
            if (masterViewController.accordion.accordianSelectedFlag) {
                 overlayImageView.image = [UIImage imageNamed:@"TopicVUAccordianOverlay-iPx.png"];
               // overlayImageView.image = [UIImage imageNamed:@"TopicVUAccordianOverlay.png"];
                UIButton *header = [ masterViewController.accordion.headers objectAtIndex: masterViewController.accordion.selectedIndex];
                NSInteger yCoordinate = 0;
                if ((header.frame.origin.y + 44 + 445) >
                    masterViewController.accordion.scrollView.bounds.size.height) {
                    yCoordinate = header.frame.origin.y - ((header.frame.origin.y + 44 + 500) -
                                                           masterViewController.accordion.scrollView.bounds.size.height);
                } else {
                    yCoordinate = header.frame.origin.y;
                }
                UIImageView *overlaySubImageView = [[UIImageView alloc]
                                                    initWithFrame:CGRectMake(15,                                                                       (yCoordinate + 106),
                                                                             259, 498)];
                overlaySubImageView.image = [UIImage imageNamed:@"patientVULeftPanel.png"];
                
                [overlayImageView addSubview:overlaySubImageView];
                
            } else {
                overlayImageView.image = [UIImage imageNamed:@"prevuscreen-org.png"];

                //overlayImageView.image = [UIImage imageNamed:@"TopicVUOverlay.png"];
            }
            [overlay addSubview:overlayImageView];
            [overlay addSubview:overlayCustomBtn];
            
            [appDelegate.splitViewController.view addSubview:overlay];
            
        }
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"PreVU-PV_Guide: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
/*
 * Method name: closeOverlay
 * Description: hide /close the guide for the user
 * Parameters: id
 * return nil
 */
- (IBAction)closeOverlay:(id)sender {
    
    //declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Pre VU - PV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Pre VU - PV"
                                                          action:@"Close help overlay  - PV"
                                                           label:@"overlayclose"
                                                           value:nil] build]];
    
    
    
    @try {
        if (overlay !=nil) {
            [overlay removeFromSuperview];
            overlay = nil;
            appDelegate.showGuideDetailVU = 1;
        }
        
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"PreVU_closeOverlay: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
/*
 * Method name: closeOverlay
 * Description: Delete the selected image content in prevu
 * Parameters: id
 * return nil
 */
- (IBAction)deleteSelectedBtnOnClicked:(id)sender {
    
    //declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Pre VU - PV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Pre VU - PV"
                                                          action:@"Delete VU Button  - PV"
                                                           label:@"Delete"
                                                           value:nil] build]];
    
    
    
    @try {
        
        if (((UIButton *) sender).selected) {
            ((UIButton *) sender).selected = false;
            patientVuGMGridView.editing = false;
        } else {
            ((UIButton *) sender).selected = true;
            patientVuGMGridView.editing = true;
        }
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Pre VU - PV_Delete: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
    }
}
/*
 * Method name: clearAllBtnOnClicked
 * Description: DeleteAll the image/video content in prevu
 * Parameters: id
 * return nil
 */
- (IBAction)clearAllBtnOnClicked:(id)sender {
    //declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Pre VU - PV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Pre VU - PV"
                                                          action:@"Delete all VU Button - PV"
                                                           label:@"DeleteAll"
                                                           value:nil] build]];
    
    @try {
        dynamicChartView.hidden = YES;
        isAnimationStarted = FALSE;
        [self flashOff:animatedButton];
        // imageToMove.hidden=YES;
        [self popoverControllerDidDismissPopover:popover];
        snapBtn.enabled = NO;
        clearAll.enabled = NO;
        deleteVUBtn.enabled = NO;
        [self clearPatientVuSelections];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_CLEARALL_PATIENTVU object:nil];
        
        appDelegate.imageId = previousSelectedId;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LAST_SELECTED_IMAGE_ID
                                                            object:self];
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Pre VU - PV_DeleteAll: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
    }
}
/*
 * Method name: createVUBtnClicked
 * Description: navigate to createvu
 * Parameters: id
 * return nil
 */
- (IBAction)createVUBtnClicked:(id)sender {
    //declaring Event Tracking Analytics
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
   /* if(!appDelegate.networkReachable && ![bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_EBOLAVU]) {
        UIAlertView *networkAlert = [[UIAlertView alloc]
                                     initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                     message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                     delegate:nil
                                     cancelButtonTitle:@"Ok"
                                     otherButtonTitles:nil];
        [networkAlert show];
        
    }else {*/
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker set:kGAIScreenName value:@"Pre VU - PV"];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Pre VU - PV"
                                                              action:@"Create VU Button - PV"
                                                               label:@"CreateVU"
                                                               value:nil] build]];
        
        
        @try {
            notificationLable.hidden = TRUE;
            isAnimationStarted = FALSE;
            [self flashOff:animatedButton];
            [moviePlayerController stop];
            [self popoverControllerDidDismissPopover:popover];
            if ([patientVUImages count] > 0) {
                [self callRecordVideoController:[patientVUImages mutableCopy]];
            } else {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: NSLocalizedString(@"ALERT_NO_CONTENT_ADDED_TITLE", nil)
                                      message:  NSLocalizedString(@"ALERT_NO_CONTENT_ADDED_TO_CREATE_VU_MSG", nil)
                                      delegate: nil
                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                      otherButtonTitles:nil];
                [alert show];
                
            }
        }
        @catch (NSException *exception) {
            
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            NSString * description = [NSString stringWithFormat:@"Pre VU - PV_createVU: %@",exception];
            [tracker send:[[GAIDictionaryBuilder
                            createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                            withFatal:NO] build]];
            
            
        }
        
    //}
    
    

    }
//PatientVU Video Maker
- (void)callRecordVideoController:(NSMutableArray *)imageDeck {
    if (moviePlayerController != nil) {
        [moviePlayerController stop];
        [moviePlayerController.view removeFromSuperview];
        moviePlayerController = nil;
    }
    welvuVideoMakerViewController* videoController = [[welvuVideoMakerViewController alloc]
                                                      initWithImageGroup:@"welvuVideoMakerViewController" bundle:nil images:imageDeck
                                                      imageCount: albumAddedCount];
    videoController.delegate = self;
    videoController.modalPresentationStyle = UIModalPresentationFullScreen;
    videoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical; //transition shouldn't matter
    [self presentModalViewController:videoController animated:YES];
    
    
//[masterViewController.accordion.scrollView setScrollEnabled:TRUE];
    //[masterViewController accordionScrollViewDidScroll:nil];

}

- (void)welvuVideoMakerViewControllerDidFinish:(welvuVideoMakerViewController *)welvuVideoMakerView {
    notificationLable.hidden = YES;
    dynamicChartView.hidden = YES;
    [self dismissModalViewControllerAnimated:YES];
   // [masterViewController.accordion.scrollView setScrollEnabled:TRUE];

    //[self refreshHistoryBtns];
}

- (void)userLoggedOutFromVideoMakerController {
    dynamicChartView.hidden = YES;
    [self dismissModalViewControllerAnimated:NO];
    [self.masterViewController logoutUser];
}

- (void)userSwitchWelVUFromVideoMakerController {
    dynamicChartView.hidden = YES;
    [self dismissModalViewControllerAnimated:NO];
    [self.masterViewController switchToWelvuUSer];
}

/*
 * Method name: camButtonClicked
 * Description: To capture the image/video content using camera
 * Parameters: id
 * return nil
 */
//Camera & Album
//Camera & Album
- (IBAction)camButtonClicked:(id)sender {
    //declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Pre VU - PV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Pre VU - PV"
                                                          action:@"Camera Button - PV"
                                                           label:@"Camera"
                                                           value:nil] build]];
    @try {
        [moviePlayerController stop];
        [self popoverControllerDidDismissPopover:popover];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
            && picker == nil && popover == nil) {
            picker = [[UIImagePickerController alloc] init];
            picker.title = @"camera";
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
            picker.delegate = self;
            [self presentModalViewController:picker animated:YES];
        }
        patientVuGMGridView.editing = NO;
        deleteVUBtn.selected = false;
        dynamicChartView.hidden = YES;
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Pre VU - PV_Camera: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
/*
 * Method name: albumButtonClicked
 * Description: To capture the image/video content using PhotoAlbum
 * Parameters: id
 * return nil
 */
- (IBAction)albumButtonClicked:(id)sender {
    //declaring Event Tracking Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Pre VU - PV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Pre VU - PV"
                                                          action:@"Album Button - PV"
                                                           label:@"PhotoAlbum"
                                                           value:nil] build]];
    
    @try {
        [moviePlayerController stop];
        if (popover == nil) {
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
                                     inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
            // NSLog(@"current version %@",currSysVer);
            if (currSysVer >= @"7.0") {
                              [popover setPopoverContentSize:CGSizeMake(320, 768) animated:NO];
                [popover setBackgroundColor:[UIColor clearColor]];
                
            }
            photoBtn.selected = true;
            patientVuGMGridView.editing = NO;
            deleteVUBtn.selected = false;
            dynamicChartView.hidden = YES;
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Pre VU - PV_PhotoAlbum: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

#pragma mark - box integration 

-(IBAction) boxBtnClicked:(id)sender {
    
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Pre VU - PV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Pre VU - PV"
                                                          action:@"Box Button - PV"
                                                           label:@"Box"
                                                           value:nil] build]];
    
    @try {
    
    
    int orgCount = [welvu_organization getOrganizationCount:[appDelegate getDBPath]];
    
    
    if(appDelegate.welvu_userModel.org_id > 0) {
        
        
        if ([BoxSDK sharedSDK].OAuth2Session.isAuthorized)
        {
            //NSLog(@"Access token %@", [BoxSDK sharedSDK].OAuth2Session.accessToken);
            // in order to avoid a short lag, jump immediatly to the file picker if we are already authorized
            [self presentBoxFolderPicker];
        }
        else
        {
           /* [BoxSDK sharedSDK].OAuth2Session.clientID = BOX_CLIENT_ID;
            [BoxSDK sharedSDK].OAuth2Session.clientSecret = BOX_SECRET_ID;
            
            NSURL *authorizationURL = [BoxSDK sharedSDK].OAuth2Session.authorizeURL;
            NSString *redirectURI = [BoxSDK sharedSDK].OAuth2Session.redirectURIString;
            BoxAuthorizationViewController *authorizationViewController = [[BoxAuthorizationViewController alloc] initWithAuthorizationURL:authorizationURL redirectURI:redirectURI];
            BoxAuthorizationNavigationController *loginNavigation = [[BoxAuthorizationNavigationController alloc] initWithRootViewController:authorizationViewController];
            authorizationViewController.delegate = loginNavigation;
            loginNavigation.modalPresentationStyle = UIModalPresentationFormSheet;
            
            [self presentViewController:loginNavigation animated:YES completion:nil]; */
            [BoxSDK sharedSDK].OAuth2Session.clientID = BOX_CLIENT_ID;
            [BoxSDK sharedSDK].OAuth2Session.clientSecret = BOX_SECRET_ID;
            
            BoxFolderBlock success = ^(BoxFolder * folder) {
                [self presentBoxFolderPicker];
            };
            BoxAPIJSONFailureBlock failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary){
                [self boxError:error];
            };
            // try sending a hearbeat
            [[BoxSDK sharedSDK].foldersManager folderInfoWithID:BoxAPIFolderIDRoot
                                                 requestBuilder:nil
                                                        success:success
                                                        failure:failure];
        }
    } else {
        if(appDelegate.orgGoToWelVU) {
            UIAlertView *myAlert = [[UIAlertView alloc]
                                    initWithTitle:NSLocalizedString(@"UPGRADE_TITLE", nil)
                                    message:nil
                                    delegate:self
                                    cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                    otherButtonTitles:NSLocalizedString(@"UPGRADE", nil),nil];
            myAlert.tag = 123;
            [myAlert show];
            
        } else {
            UIAlertView *myAlert = [[UIAlertView alloc]
                                    initWithTitle:NSLocalizedString(@"UPGRADE_TITLE", nil)
                                    message:nil
                                    delegate:self
                                    cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                    otherButtonTitles:NSLocalizedString(@"UPGRADE", nil),nil];
            myAlert.tag = 123;
            [myAlert show];
        }
    }

    
   
}
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Pre VU - PV_Box: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

- (void)presentBoxFolderPicker {
    if([BoxSDK sharedSDK].OAuth2Session.accessToken != nil) {
        appDelegate.welvu_userModel.box_access_token = [BoxSDK sharedSDK].OAuth2Session.accessToken;
        appDelegate.welvu_userModel.box_refresh_access_token= [BoxSDK sharedSDK].OAuth2Session.refreshToken;
        appDelegate.welvu_userModel.box_expires_in =  [BoxSDK sharedSDK].OAuth2Session.accessTokenExpiration;
        [welvu_user updateBoxAccessToken:[appDelegate getDBPath] :appDelegate.welvu_userModel];
    }
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                       NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
                       NSString *thumbnailPath = [basePath stringByAppendingPathComponent:@"BOX"];
                       
                       self.folderPicker = [[BoxSDK sharedSDK]
                                            folderPickerWithRootFolderID:BoxAPIFolderIDRoot
                                            thumbnailsEnabled:YES
                                            cachedThumbnailsPath:thumbnailPath
                                            fileSelectionEnabled:YES];
                       
                       
                       self.folderPicker.delegate = self;
                       
                       UINavigationController *controller = [[BoxFolderPickerNavigationController alloc] initWithRootViewController:self.folderPicker];
                       
                       controller.modalPresentationStyle = UIModalPresentationFormSheet;
                       
                       controller.view.frame = CGRectMake(0, 0, 10, 10)        ;
                       [self presentViewController:controller animated:YES completion:nil];
                   });
}

- (void)boxError:(NSError*)error
{
    if (error.code == BoxSDKOAuth2ErrorAccessTokenExpiredOperationReachedMaxReenqueueLimit)
    {
        // Launch the picker again if for some reason the OAuth2 session cannot be refreshed.
        // this will bring the login screen which will be followed by the file picker itself
        [self presentBoxFolderPicker];
        return;
    }
    else if (error.code == BoxSDKOAuth2ErrorAccessTokenExpired)
    {
        // This error code appears as part of the re-authentication process and should be ignored
        return;
    }
    else
    {
        // we really failed, let the user know
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Box" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    }
}

-(NSArray *)folderPickerAtIndexes:(NSIndexSet *)indexes {
    NSLog(@"Indexes %@", indexes);
}

- (void)folderPickerController:(BoxFolderPickerViewController *)controller didSelectBoxItem:(BoxItem *)item {
    [self dismissViewControllerAnimated:YES completion:^{
        CGSize destinationSize = CGSizeMake(IMAGE_VIEW_WIDTH, IMAGE_VIEW_HEIGHT);
        /* [[BoxSDK sharedSDK].filesManager downloadFileWithID:fileID outputStream:outputStream requestBuilder:nil success:successBlock failure:failureBlock];*/
        
        NSString *mediaType = [self checkCompatibleMediaType:item.name];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT];
        if(mediaType != nil && [mediaType isEqualToString:IMAGE_FILE_TYPE_CONST]) {
            NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@?%@=%@",
                                   @"https://api.box.com/2.0/files/",
                                   item.modelID,@"content",
                                   @"access_token",
                                   [BoxSDK sharedSDK].OAuth2Session.accessToken];
            NSURL *url = [NSURL URLWithString:urlString];
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            UIImage *anImage = [UIImage imageWithData:imageData];
            
            
            NSString *imageName = [dateFormatter stringFromDate:[NSDate date]];
            
            
            welvu_images *welvu_imagesModel = [[welvu_images alloc]
                                               initWithImageId:(++albumAddedCount)];
            welvu_imagesModel.imageDisplayName = imageName;
            welvu_imagesModel.type = IMAGE_ALBUM_TYPE;
            welvu_imagesModel.imageData = anImage;
            welvu_imagesModel.pickedToView = YES;
            welvu_imagesModel.boxId = item.modelID;
            welvu_imagesModel.boxUrl = urlString;
            [patientVUImages addObject:welvu_imagesModel];
            
            [self unselectPreviousSelectedImage];
            
            [patientVuGMGridView insertObjectAtIndex:[patientVUImages count] - 1
                                       withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
            
            previousSelectedId = ((welvu_images *)[patientVUImages lastObject]).imageId;
            [self setPreviewImageInView:welvu_imagesModel];
            deleteVUBtn.enabled = true;
            clearAll.enabled = true;
            
            imageData = nil;
        } else if(mediaType != nil && [mediaType isEqualToString:VIDEO_FILE_TYPE_CONST]) {
            NSString* videoName = [NSString stringWithFormat:@"%@.%@", [dateFormatter stringFromDate:[NSDate date]],
                                   HTTP_ATTACHMENT_VIDEO_EXT_KEY];
            NSString *exportPath = [DOCUMENT_DIRECTORY stringByAppendingPathComponent:videoName];
            NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:exportPath append:NO];
            if(spinner == nil) {
                appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                spinner = [ProcessingSpinnerView loadSpinnerIntoView:appDelegate.splitViewController.view];
                [appDelegate.splitViewController.view bringSubviewToFront:spinner];
                //  NSLog(@"spinner on");
            }
            [[BoxSDK sharedSDK].filesManager downloadFileWithID:item.modelID outputStream:outputStream
                                                 requestBuilder:nil
                                                        success:^(NSString *fileID, long long expectedTotalBytes) {
                                                            NSURL *outputURL = [NSURL fileURLWithPath:exportPath];
                                                            int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:outputURL];
                                                            welvu_images *welvu_imagesModel = [[welvu_images alloc] initWithImageId:(++albumAddedCount)];
                                                            welvu_imagesModel.imageDisplayName = videoName;
                                                            welvu_imagesModel.type = IMAGE_VIDEO_ALBUM_TYPE;
                                                            welvu_imagesModel.url = exportPath;
                                                            welvu_imagesModel.pickedToView = YES;
                                                            welvu_imagesModel.boxId = item.modelID;
                                                            [patientVUImages addObject:welvu_imagesModel];
                                                            
                                                            [self unselectPreviousSelectedImage];
                                                            
                                                            [patientVuGMGridView insertObjectAtIndex:[patientVUImages count] - 1
                                                                                       withAnimation:GMGridViewItemAnimationFade|GMGridViewItemAnimationScroll];
                                                            
                                                            previousSelectedId = ((welvu_images *)[patientVUImages lastObject]).imageId;
                                                            
                                                            [self performSelectorOnMainThread:@selector(setPreviewImageInView:)
                                                                                   withObject:welvu_imagesModel waitUntilDone:YES];
                                                        }
                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                            NSLog(@"failed");
                                                        }];
            deleteVUBtn.enabled = true;
            clearAll.enabled = true;
        } else if (mediaType == nil) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"BOX_ALLOWED_CONTENT_TYPE_MESSAGE", nil)
                                  message:nil
                                  delegate: nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil];
            [alert show];
            
        }
        
        dateFormatter = nil;
        mediaType = nil;
    }];
    
}

- (void)folderPickerControllerDidCancel:(BoxFolderPickerViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSString *) checkCompatibleMediaType:(NSString *) file {
    NSString* extension = [file pathExtension];
    NSArray* imageExtension = [NSArray arrayWithObjects: @"jpg", @"jpeg", @"png", @"gif", nil];
    NSArray* videoExtension = [NSArray arrayWithObjects: @"mp4", @"mov", nil];
    if ([imageExtension containsObject: extension]) {
        return IMAGE_FILE_TYPE_CONST;
    } else if([videoExtension containsObject: extension]){
        return VIDEO_FILE_TYPE_CONST;
    }
    return nil;
}

#pragma mark - Map Integration
MKPointAnnotation *selectedPlaceAnnotation;
-(IBAction) mapScreenShotBtnClicked:(id)sender {
    UIGraphicsBeginImageContextWithOptions(previewVUContents.bounds.size, previewVUContents.opaque, 0.0);
    [previewVUContents.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [mapVUBtn setBackgroundImage:[UIImage imageNamed:@"map_icon_n"] forState:UIControlStateNormal];
    [mapVUBtn addTarget:self action:@selector(showMapView:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT];
    NSString *mediaType = GRAPH_IMAGE_TYPE;
    NSString *imageName = [dateFormatter stringFromDate:[NSDate date]];
    
    welvu_images *welvu_imagesModel = [[welvu_images alloc] initWithImageId:(++albumAddedCount)];
    welvu_imagesModel.imageDisplayName = imageName;
    welvu_imagesModel.type = GRAPH_IMAGE_TYPE;
    welvu_imagesModel.imageData = screenshot;
    welvu_imagesModel.pickedToView = YES;
    [patientVUImages addObject:welvu_imagesModel];
    
   
    
    [self unselectPreviousSelectedImage];
    
    [patientVuGMGridView insertObjectAtIndex:[patientVUImages count] - 1
                               withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
    
    previousSelectedId = ((welvu_images *)[patientVUImages lastObject]).imageId;
    [self setPreviewImageInView:welvu_imagesModel];
    
}

-(IBAction) showMapView:(id)sender {
    if(appDelegate.networkReachable) {
        if(previewVUContent != nil) {
            [previewVUContent removeFromSuperview];
            previewVUContent = nil;
        }
        [previewVUContent removeFromSuperview];
        snapBtn.enabled = false;
        if(mapView == nil) {
            ibSearchBar.hidden = false;
            dynamicChartView.hidden = false;
            dynamicChartView.text = NSLocalizedString(@"MAP_VIEW", nil);
            appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, IMAGE_VIEW_WIDTH, previewVUContents.frame.size.height)];
            mapView.delegate = self;
            [mapView setShowsUserLocation:YES];
            [previewVUContents addSubview:mapView];
            UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                                  initWithTarget:self action:@selector(handleLongPress:)];
            lpgr.minimumPressDuration = 0.5; //user needs to press for 2 seconds
            [mapView addGestureRecognizer:lpgr];
            selectedPlaceAnnotation = nil;
            
            
            [self performSelector:@selector(showCurrentLocation) withObject:nil afterDelay:1];
            [mapVUBtn setBackgroundImage:[UIImage imageNamed:@"map_VU_n"] forState:UIControlStateNormal];
           
        } else {
            dynamicChartView.hidden = true;
            ibSearchBar.hidden = true;
            UIGraphicsBeginImageContextWithOptions(previewVUContents.bounds.size, previewVUContents.opaque, 0.0);
            [previewVUContents.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage * screenshot = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [mapVUBtn setBackgroundImage:[UIImage imageNamed:@"map_icon_n"] forState:UIControlStateNormal];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT];
            NSString *mediaType = GRAPH_IMAGE_TYPE;
            NSString *imageName = [dateFormatter stringFromDate:[NSDate date]];
            
            welvu_images *welvu_imagesModel = [[welvu_images alloc] initWithImageId:(++albumAddedCount)];
            welvu_imagesModel.imageDisplayName = imageName;
            welvu_imagesModel.type = GRAPH_IMAGE_TYPE;
            welvu_imagesModel.imageData = screenshot;
            welvu_imagesModel.pickedToView = YES;
            [patientVUImages addObject:welvu_imagesModel];

            if(selectedPlaceAnnotation) {
                WelVUMapsLink *mapLink = [[WelVUMapsLink alloc] init];
                mapLink.imageId = welvu_imagesModel.imageId;
                mapLink.placeName = selectedPlaceAnnotation.title;
                mapLink.mapLink = [NSString stringWithFormat:@"https://maps.google.co.in/maps?q=%f,%f",
                                   selectedPlaceAnnotation.coordinate.latitude,
                                   selectedPlaceAnnotation.coordinate.longitude];
                [appDelegate.mapLinks addObject:mapLink];
            }
            
            [self unselectPreviousSelectedImage];
            
            [patientVuGMGridView insertObjectAtIndex:[patientVUImages count] - 1
                                       withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
            
            previousSelectedId = ((welvu_images *)[patientVUImages lastObject]).imageId;
            [self setPreviewImageInView:welvu_imagesModel];
            clearAll.enabled = YES;
            deleteVUBtn.enabled = YES;
        }
    }else {
        UIAlertView *myAlert = [[UIAlertView alloc]
                                initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil];
        [myAlert show];
    }
}

-(void) showCurrentLocation {
    if(mapView != nil) {
        MKCoordinateRegion mapRegion;
        mapRegion.center = mapView.userLocation.coordinate;
        mapRegion.span = MKCoordinateSpanMake(0.02, 0.02);
        [mapView setRegion:mapRegion animated: YES];
    }
}

-(NSString *)getAddressFromLatLon:(double)pdblLatitude withLongitude:(double)pdblLongitude
{
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%f,%f&output=csv",pdblLatitude, pdblLongitude];
    NSError* error;
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSASCIIStringEncoding error:&error];
    locationString = [locationString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSLog(@"Location name %@", locationString);
    return [locationString substringFromIndex:6];
}


- (void) getAddressFromLatLon:(CLLocation *)bestLocation withAnnotation:(MKPointAnnotation *) annotation
{
    NSLog(@"%f %f", bestLocation.coordinate.latitude, bestLocation.coordinate.longitude);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:bestLocation
                   completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error){
             NSLog(@"Geocode failed with error: %@", error);
             [mapView addAnnotation:annotation];
             return;
         }
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
         NSLog(@"locality %@",placemark.name);
         annotation.title = placemark.name;
         NSLog(@"postalCode %@",placemark.postalCode);
         [mapView addAnnotation:annotation];
     }];
    
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    if(selectedPlaceAnnotation !=nil) {
        [mapView removeAnnotation:selectedPlaceAnnotation];
        selectedPlaceAnnotation = nil;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    
    selectedPlaceAnnotation = [[MKPointAnnotation alloc] init];
    selectedPlaceAnnotation.coordinate = touchMapCoordinate;
    CLLocation *theLocation = [[CLLocation alloc]initWithLatitude:selectedPlaceAnnotation.coordinate.latitude
                                                        longitude:selectedPlaceAnnotation.coordinate.longitude];
    [self getAddressFromLatLon:theLocation withAnnotation:selectedPlaceAnnotation];
}

#pragma mark MKMapView Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapViewIn viewForAnnotation:(id <MKAnnotation>)annotation {
    if (mapViewIn != mapView || [annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString *annotationIdentifier = @"WelVuLocation";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
    }
    
    annotationView.animatesDrop = YES;
    annotationView.canShowCallout = YES;
    annotationView.frame = CGRectMake(annotationView.frame.origin.x, annotationView.frame.origin.y, 260, 60);
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    [view.leftCalloutAccessoryView removeFromSuperview];
    [view.rightCalloutAccessoryView removeFromSuperview];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    // Whenever we've dropped a pin on the map, immediately select it to present its callout bubble.
    [mapView selectAnnotation:selectedPlaceAnnotation animated:YES];
}

#pragma mark - Search Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    // Cancel any previous searches.
    [localSearch cancel];
    
    // Perform a new search.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchBar.text;
    request.region = mapView.region;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error != nil) {
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:NSLocalizedString(@"LOCATION_NOT_FOUND", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
            return;
        }
        
        if ([response.mapItems count] == 0) {
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:NSLocalizedString(@"LOCATION_NOT_FOUND", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
            return;
        }
        
        results = response;
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}
#pragma mark - table deligate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results.mapItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"SearchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchDisplayController setActive:NO animated:YES];
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
    if(selectedPlaceAnnotation !=nil) {
        [mapView removeAnnotation:selectedPlaceAnnotation];
        selectedPlaceAnnotation = nil;
    }
    
    selectedPlaceAnnotation = item.placemark;
    
    [mapView setCenterCoordinate:item.placemark.location.coordinate animated:NO];
    
    [mapView setUserTrackingMode:MKUserTrackingModeNone];
    
    [self performSelector:@selector(placeAnnotation) withObject:nil afterDelay:0.5];
}

-(void) placeAnnotation {
    if(selectedPlaceAnnotation != nil)  {
        [mapView addAnnotation:selectedPlaceAnnotation];
        [mapView selectAnnotation:selectedPlaceAnnotation animated:YES];
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    
    [tableView setFrame:CGRectMake(478, 0, 236, 450)];
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.frame = CGRectMake(478, 0, 236, 450);

}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    
    self.searchDisplayController.searchBar.frame=CGRectMake(478, 86, 236, 44);
    
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    
    self.searchDisplayController.searchBar.frame=CGRectMake(478, 86, 236, 44);
}

#pragma mark - Location services
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if(![CLLocationManager locationServicesEnabled] ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        isLocationEnabled = FALSE;
    } else if([CLLocationManager locationServicesEnabled] &&
              [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        isLocationEnabled = TRUE;
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    /*  MKCoordinateRegion mapRegion;
     MKCoordinateSpan span;
     span.latitudeDelta  = 1; // Change these values to change the zoom
     span.longitudeDelta = 1;
     mapRegion.center = mapView.userLocation.coordinate;
     mapRegion.span = MKCoordinateSpanMake(0.003, 0.003);
     [mapView setRegion:mapRegion animated: YES];*/
}



#pragma mark ELCImagePickerController Delegate
//Delegate methos of ELCImagePickerController
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT];
    NSDictionary *dict=[info objectAtIndex:0];
    NSString *mediaType = [dict objectForKey:UIImagePickerControllerMediaType];
    NSString *imageName = [dateFormatter stringFromDate:[NSDate date]];
    if ([mediaType isEqualToString:@"ALAssetTypePhoto"]) {
        UIImage *anImage = [dict objectForKey:UIImagePickerControllerOriginalImage];
        
        welvu_images *welvu_imagesModel = [[welvu_images alloc] initWithImageId:(++albumAddedCount)];
        welvu_imagesModel.imageDisplayName = imageName;
        welvu_imagesModel.type = IMAGE_ALBUM_TYPE;
        welvu_imagesModel.imageData = anImage;
        welvu_imagesModel.pickedToView = YES;
        [patientVUImages addObject:welvu_imagesModel];
        
        [self unselectPreviousSelectedImage];
        
        [patientVuGMGridView insertObjectAtIndex:[patientVUImages count] - 1
                                   withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
        
        previousSelectedId = ((welvu_images *)[patientVUImages lastObject]).imageId;
        [self setPreviewImageInView:welvu_imagesModel];
    } else if ([mediaType isEqualToString:@"ALAssetTypeVideo"]){
        
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
                
                
                
                
                NSURL *outputURL = [NSURL fileURLWithPath:exportPath];
                int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:outputURL];
                
                /*  [self convertVideoToLowQuailtyWithInputURL:inputURL outputURL:outputURL handler:^(AVAssetExportSession *exportSession)
                 {
                 if (exportSession.status == AVAssetExportSessionStatusCompleted)
                 {
                 if ([[NSFileManager defaultManager] fileExistsAtPath:exportPathTemp]) {
                 [[NSFileManager defaultManager] removeItemAtPath: exportPathTemp error:NULL];
                 }
                 
                 }
                 else
                 {
                 printf("error\n");
                 
                 }
                 }];*/
                welvu_images *welvu_imagesModel = [[welvu_images alloc] initWithImageId:(++albumAddedCount)];
                welvu_imagesModel.imageDisplayName = imageName;
                welvu_imagesModel.type = IMAGE_VIDEO_ALBUM_TYPE;
                welvu_imagesModel.url = exportPath;
                welvu_imagesModel.pickedToView = YES;
                
                [patientVUImages addObject:welvu_imagesModel];
                
                [self unselectPreviousSelectedImage];
                
                [patientVuGMGridView insertObjectAtIndex:[patientVUImages count] - 1
                                           withAnimation:GMGridViewItemAnimationFade|GMGridViewItemAnimationScroll];
                
                previousSelectedId = ((welvu_images *)[patientVUImages lastObject]).imageId;
                
                // [self setPreviewImageInView:welvu_imagesModel];
                
                //[self performSelector:@selector(setPreviewImageInViewinnstimer:) withObject:welvu_imagesModel afterDelay:1.0];
                /* NSTimer* t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self  selector:@selector(setPreviewImageInViewinnstimer:) userInfo:welvu_imagesModel repeats:NO];
                 [[NSRunLoop currentRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
                 //[[NSRunLoop currentRunLoop] run];*/
                
                [self performSelectorOnMainThread:@selector(setPreviewImageInView:)
                                       withObject:welvu_imagesModel waitUntilDone:YES];
                
                asset = nil;
            } failureBlock:^(NSError *err) {
                //  NSLog(@"Error: %@",[err localizedDescription]);
            }];
            //
            dispatch_async(dispatch_get_main_queue(), ^ {
                
            });
        });
        
    }
    
    //Problem
    //[welvu_imagesModel release];
    
    clearAll.enabled = YES;
    deleteVUBtn.enabled = YES;
    [popover dismissPopoverAnimated:NO];
    popover = nil;
    
    appDelegate.imageId = previousSelectedId;
    photoBtn.selected = false;
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"annoatationviewcancel"
                                                        object:self];
    
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler {
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetLowQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(exportSession);
     }];
    asset = nil;
    exportSession = nil;
}

//Delegate method ELCImagePickerController
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    [popover dismissPopoverAnimated:NO];
    popover = nil;
    photoBtn.selected = false;
}
//Delegate method UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *) Picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissModalViewControllerAnimated:YES];
    picker = nil;
    if (popover != nil) {
        [popover dismissPopoverAnimated:YES];
        popover = nil;
    }
    clearAll.enabled = YES;
    deleteVUBtn.enabled = YES;
    patientVuGMGridView.editing = NO;
    deleteVUBtn.selected = false;
    
    [self unselectPreviousSelectedImage];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FORMAT];
    
    if ([mediaType isEqualToString:IMAGE_FILE_TYPE_CONST]){
        [self unselectPreviousSelectedImage];
        
        UIImage *anImage = [info valueForKey:UIImagePickerControllerOriginalImage];
        NSString *imageName = [dateFormatter stringFromDate:[NSDate date]];
        
        welvu_images *welvu_imagesModel = [[welvu_images alloc] initWithImageId:(++albumAddedCount)];
        welvu_imagesModel.imageDisplayName = imageName;
        welvu_imagesModel.type = IMAGE_ALBUM_TYPE;
        welvu_imagesModel.imageData = anImage;
        welvu_imagesModel.pickedToView = YES;
        
        [patientVUImages addObject:welvu_imagesModel];
        
        [patientVuGMGridView insertObjectAtIndex:[patientVUImages count] - 1
                                   withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
        previousSelectedId = ((welvu_images *)[patientVUImages lastObject]).imageId;
        [self setPreviewImageInView:welvu_imagesModel];
    } else if ([mediaType isEqualToString:VIDEO_FILE_TYPE_CONST]){
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *exportPath = [videoURL path];
        welvu_images *welvu_imagesModel = [[welvu_images alloc] initWithImageId:(++albumAddedCount)];
        welvu_imagesModel.imageDisplayName = @"Captured Video";
        welvu_imagesModel.type = IMAGE_VIDEO_ALBUM_TYPE;
        welvu_imagesModel.url = exportPath;
        welvu_imagesModel.pickedToView = YES;
        
        [patientVUImages addObject:welvu_imagesModel];
        
        [self unselectPreviousSelectedImage];
        
        [patientVuGMGridView insertObjectAtIndex:[patientVUImages count] - 1
                                   withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
        
        
        previousSelectedId = ((welvu_images *)[patientVUImages lastObject]).imageId;
        
        [self performSelector:@selector(setPreviewImageInView:) withObject:welvu_imagesModel afterDelay:1.0];
    }
    
    appDelegate.imageId = previousSelectedId;
    // [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LAST_SELECTED_IMAGE_ID
    // object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"annoatationviewcancel"
                                                        object:self];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    [picker dismissModalViewControllerAnimated:YES];
    picker = nil;
}

//update the annotaed image using notification
- (void)updateAnnotatedImage:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *imageId=[userInfo objectForKey:@"imageId"];
    
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    welvu_images *welvu_imgesModel = [welvu_images getImageById:[appDelegate getDBPath] :[imageId integerValue]
                                                         userId:appDelegate.welvu_userModel.welvu_user_id];
    NSInteger i = [self searchImageGroups:[imageId integerValue]:patientVUImages];
    if (i > -1) {
        [patientVUImages removeObjectAtIndex:i];
        [patientVUImages insertObject:[[welvu_images alloc]initWithImageObject:welvu_imgesModel] atIndex:i];
        [patientVuGMGridView insertObjectAtIndex:i
                                   withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
    }
}
//Add image/video content from patientvu to prevu
- (void)addVUContentToPatientVU:(welvu_images *)welvu_imgesModel:(CGPoint)droppedPosition {
    previewVUContents.backgroundColor = [UIColor clearColor];
    
    dynamicChartView.hidden = YES;
    BOOL contentVUadded = false;
    clearAll.enabled = YES;
    deleteVUBtn.enabled = YES;
    snapBtn.enabled = NO;
    patientVuGMGridView.editing = NO;
    deleteVUBtn.selected = false;
    [self unselectPreviousSelectedImage];
    
    welvu_imgesModel.pickedToView = YES;
    previousSelectedId = welvu_imgesModel.imageId;
    if (!welvu_imgesModel.patientImageID == 0) {
        previousSelectedId = welvu_imgesModel.patientImageID;
    }
    if (droppedPosition.x > 300) {
        for (int i = 0; i < [patientVUImages count]; i++) {
            GMGridViewCell *cell = [patientVuGMGridView cellForItemAtIndex:i];
            
            if ((cell.frame.origin.x >  (droppedPosition.x - 300))
                && droppedPosition.y > 550) {
                /* && (((cell.frame.origin.y - 70) >= (droppedPosition.y - 704))
                 || ((cell.frame.origin.y + 70) <= (droppedPosition.y)) */
                welvu_images *welvu_imagesSelected =  [[welvu_images alloc]initWithImageObject:welvu_imgesModel];
                welvu_imagesSelected.pickedToView = YES;
                [patientVUImages insertObject:welvu_imagesSelected atIndex:i];
                [patientVuGMGridView insertObjectAtIndex:i
                                           withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
                contentVUadded = true;
                break;
            }
        }
    }
    
    if (!contentVUadded) {
        welvu_images *welvu_imagesSelected =  [[welvu_images alloc]initWithImageObject:welvu_imgesModel];
        welvu_imagesSelected.pickedToView = YES;
        [patientVUImages addObject:welvu_imagesSelected];
        
        [patientVuGMGridView insertObjectAtIndex:[patientVUImages count] - 1
                                   withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
    }
    appDelegate.imageId = previousSelectedId;
    [self setPreviewImageInView:welvu_imgesModel];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LAST_SELECTED_IMAGE_ID
                                                        object:self];
}
// add all topics image content to prevu
- (void)addAllTopicVUContentToPatientVU:(NSMutableArray *)welvu_imgesModels {
    previewVUContents.backgroundColor = [UIColor clearColor];
    
    dynamicChartView.hidden = YES;
    clearAll.enabled = YES;
    deleteVUBtn.enabled = YES;
    patientVuGMGridView.editing = NO;
    deleteVUBtn.selected = false;
    snapBtn.enabled = NO;
    [self unselectPreviousSelectedImage];
    
    for (welvu_images *welvu_imagesModel in welvu_imgesModels) {
        if ([self searchImageGroups:welvu_imagesModel.imageId :patientVUImages] == -1) {
            [patientVUImages addObject:[[welvu_images alloc]initWithImageObject:welvu_imagesModel]];
            [patientVuGMGridView insertObjectAtIndex:[patientVUImages count] - 1 withAnimation:GMGridViewItemAnimationScroll];
        }
    }
    previousSelectedId = ((welvu_images *) [patientVUImages lastObject]).imageId;
    
    welvu_images *welvu_imgesModel = (welvu_images *) [patientVUImages objectAtIndex:([patientVUImages count] - 1)];
    welvu_imgesModel.pickedToView = YES;
    
    [self setPreviewImageInView:welvu_imgesModel];
    
    [patientVuGMGridView reloadData];
    
    appDelegate.imageId = previousSelectedId;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LAST_SELECTED_IMAGE_ID
                                                        object:self];
}
// Remove image/video content form prevu
- (void)removeVUContentFromPatientVU:(welvu_images *)welvu_imgesModel {
    
    patientVuGMGridView.editing = NO;
    deleteVUBtn.selected = false;
    NSInteger index = -1;
    
    if(welvu_imgesModel.patientImageID > 0) {
        index = [self searchPatientImageGroups:welvu_imgesModel.patientImageID: patientVUImages];
    } else {
        index = [self searchImageGroups:welvu_imgesModel.imageId :patientVUImages];
    }
    if (index > -1) {
                _lastDeleteItemIndexAsked = index;
        [self unselectPreviousSelectedImage];
        [patientVUImages removeObjectAtIndex:_lastDeleteItemIndexAsked];
        [patientVuGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
        if ([patientVUImages count] > 0) {
            GMGridViewCell *cell = (GMGridViewCell *)[patientVuGMGridView cellForItemAtIndex:0];
            if (!cell.isSelected) {
                previousSelectedId = ((welvu_images *)[patientVUImages objectAtIndex:0]).imageId;
                for (UIView *subview in [cell.contentView subviews]) {
                    if ([subview isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView = (UIImageView *)subview;
                        imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                           makeRoundCornerImage:5 :5];
                    }
                }
               
                cell.isSelected = TRUE;
                welvu_images *welvu_imagesModel = [patientVUImages objectAtIndex:0];
                welvu_imagesModel.pickedToView = YES;
                [self setPreviewImageInView:welvu_imagesModel];
                appDelegate.ispatientVUContent = TRUE;
            }
        } else {
            isAnimationStarted = FALSE;
            [self flashOff:animatedButton];
            //imageToMove.hidden=YES;
            [self removePreviewImageContent];
            [self removeVideoPreviewContent];
            previousSelectedId = -1;
            previewVUContent.image = nil;
            appDelegate.ispatientVUContent = FALSE;
            clearAll.enabled = NO;
            deleteVUBtn.enabled = NO;
            scrol.hidden = true;
            tagLabel.hidden = true;
            
        }
    }
     //[patientVuGMGridView reloadData];
    dynamicChartView.hidden = YES;
    appDelegate.imageId = previousSelectedId;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LAST_SELECTED_IMAGE_ID
                                                        object:self];
}

- (void)loadPatientVuFromHistory:(NSInteger) historyNumber {
    NSMutableArray *welvu_vu_historyModels = [welvu_history getHistoryByHistoryNumber
                                              :appDelegate.getDBPath:appDelegate.specialtyId:historyNumber];
    [self clearPatientVuSelections];
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    for(welvu_history *welvu_vu_historyModel in welvu_vu_historyModels) {
        [patientVUImages addObject:[welvu_images getImageById:appDelegate.getDBPath :welvu_vu_historyModel.images_id
                                                       userId:appDelegate.welvu_userModel.welvu_user_id]];
    }
    
    previousSelectedId = ((welvu_images *) [patientVUImages lastObject]).imageId;
    
    welvu_images *welvu_imgesModel = (welvu_images *) [patientVUImages objectAtIndex:([patientVUImages count] - 1)];
    welvu_imgesModel.pickedToView = YES;
    [self setPreviewImageInView:welvu_imgesModel];
    [patientVuGMGridView reloadData];
    clearAll.enabled = YES;
    deleteVUBtn.enabled = YES;
    
    appDelegate.imageId = previousSelectedId;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LAST_SELECTED_IMAGE_ID
                                                        object:self];
}
//unselect the previous selected image
- (void) unselectPreviousSelectedImage {
    if (previousSelectedId > -1) {
        NSInteger index =  [self searchImageGroups:previousSelectedId :patientVUImages];
        GMGridViewCell *previousCell = (GMGridViewCell *)[patientVuGMGridView cellForItemAtIndex:index];
        if (previousCell.isSelected) {
            for(UIView *subview in [previousCell.contentView subviews]) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)subview;
                    imageView.image = [[imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER]
                                       makeRoundCornerImage:5 :5];
                }
            }
            previousCell.isSelected = FALSE;
        }
        welvu_images *welvu_imagesModel = [patientVUImages objectAtIndex:index];
        welvu_imagesModel.pickedToView = NO;
    }
    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *) popoverController {
    photoBtn.selected = false;
    if (popover != nil) {
        [popover dismissPopoverAnimated:YES];
        popover = nil;
    }
    if (overlay !=nil) {
        [overlay removeFromSuperview];
        overlay = nil;
    }
}
//STM
- (IBAction)selectAllBtnClicked:(id)sender {
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    NSNumber *topicIdNumber = [NSNumber numberWithInteger: currentOpenedTopicId];
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                         topicIdNumber, @"topicId", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tempSelectedAll" object:self userInfo:dic];
    //NSMutableArray *welvu_images = [welvu_images getImagesByTopicId]
    NSMutableArray *welvu_imagesArray = [welvu_images getImagesByTopicId:[appDelegate getDBPath]:currentOpenedTopicId
                                                                  userId:appDelegate.welvu_userModel.welvu_user_id];
    [self addAllTopicVUContentToPatientVU:welvu_imagesArray];
}

//STM
- (void)setCurrentTopicId:(NSInteger) topicId {
    if(topicId > 0) {
        currentOpenedTopicId = topicId;
        selectAllBtn.enabled = true;
    } else {
        currentOpenedTopicId = 0;
        selectAllBtn.enabled = false;
    }
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}
//Delete all content form prevu
- (void) clearPatientVuSelections {
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    notificationLable.hidden = YES;
    //[notificationLable setHidden:YES];
    [notificationLable removeFromSuperview];
    NSString *patientID=[appDelegate.currentPatientInfo objectForKey:@"pid"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if (patientID == nil && ![bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        //boxBtn.hidden = false;
        snapBtn.hidden = TRUE;
        mapVUBtn.hidden = true;
        deleteVUBtn.frame= CGRectMake(226, deleteVUBtn.frame.origin.y, deleteVUBtn.frame.size.width, deleteVUBtn.frame.size.height);
        
        clearAll.frame= CGRectMake(279, clearAll.frame.origin.y, clearAll.frame.size.width, clearAll.frame.size.height);
        
        
        photoBtn.frame= CGRectMake(332, photoBtn.frame.origin.y, photoBtn.frame.size.width, photoBtn.frame.size.height);
        
        cameraBtn.frame= CGRectMake(383, cameraBtn.frame.origin.y, cameraBtn.frame.size.width, cameraBtn.frame.size.height);
        
        
    } else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        ipxBtn.hidden = false;
        boxBtn.hidden = false;
        saveBtn.hidden = true;
        saveBtn.enabled = false;
        
        mapVUBtn.hidden = false;
        if(patientID != nil) {
            snapBtn.hidden = false;
            snapBtn.frame= CGRectMake(436, snapBtn.frame.origin.y, snapBtn.frame.size.width, snapBtn.frame.size.height);
            
            boxBtn.frame= CGRectMake(383, boxBtn.frame.origin.y, boxBtn.frame.size.width, boxBtn.frame.size.height);
            
            mapVUBtn.frame= CGRectMake(332 , mapVUBtn.frame.origin.y, mapVUBtn.frame.size.width, mapVUBtn.frame.size.height);
            
            cameraBtn.frame= CGRectMake(279 , cameraBtn.frame.origin.y, cameraBtn.frame.size.width, cameraBtn.frame.size.height);
            
            photoBtn.frame= CGRectMake(226 , photoBtn.frame.origin.y, photoBtn.frame.size.width, photoBtn.frame.size.height);
            
            clearAll.frame= CGRectMake(173 , clearAll.frame.origin.y, clearAll.frame.size.width, clearAll.frame.size.height);
            
            deleteVUBtn.frame= CGRectMake(120 , deleteVUBtn.frame.origin.y, deleteVUBtn.frame.size.width, deleteVUBtn.frame.size.height);
        } else {
            boxBtn.hidden = false;
            snapBtn.hidden = true;
            
            boxBtn.frame= CGRectMake(436, boxBtn.frame.origin.y, boxBtn.frame.size.width, boxBtn.frame.size.height);
            
            mapVUBtn.frame= CGRectMake(383 , mapVUBtn.frame.origin.y, mapVUBtn.frame.size.width, mapVUBtn.frame.size.height);
            
            cameraBtn.frame= CGRectMake(332 , cameraBtn.frame.origin.y, cameraBtn.frame.size.width, cameraBtn.frame.size.height);
            
            photoBtn.frame= CGRectMake(279 , photoBtn.frame.origin.y, photoBtn.frame.size.width, photoBtn.frame.size.height);
            
            clearAll.frame= CGRectMake(226 , clearAll.frame.origin.y, clearAll.frame.size.width, clearAll.frame.size.height);
            
            deleteVUBtn.frame= CGRectMake(173 , deleteVUBtn.frame.origin.y, deleteVUBtn.frame.size.width, deleteVUBtn.frame.size.height);
        }
        previewVUContents.backgroundColor = [UIColor clearColor];
        [mapVUBtn setBackgroundImage:[UIImage imageNamed:@"map_icon_n"] forState:UIControlStateNormal];
    } else {
        snapBtn.hidden = FALSE;
        mapVUBtn.hidden = true;
        deleteVUBtn.frame= CGRectMake(173, deleteVUBtn.frame.origin.y, deleteVUBtn.frame.size.width, deleteVUBtn.frame.size.height);
        
        clearAll.frame= CGRectMake(226, clearAll.frame.origin.y, clearAll.frame.size.width, clearAll.frame.size.height);
        
        
        photoBtn.frame= CGRectMake(279, photoBtn.frame.origin.y, photoBtn.frame.size.width, photoBtn.frame.size.height);
        
        cameraBtn.frame= CGRectMake(332, cameraBtn.frame.origin.y, cameraBtn.frame.size.width, cameraBtn.frame.size.height);
        
        saveBtn.frame= CGRectMake(383, saveBtn.frame.origin.y, saveBtn.frame.size.width, saveBtn.frame.size.height);
    }
    
    
    if(appDelegate.welvu_userModel.org_id == 0 && ![bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        //ipxBtn.hidden = true;
    } else {
        ipxBtn.hidden = false;
    }
    
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_HEV]) {
        ipxBtn.hidden = false;
        snapBtn.hidden = TRUE;
        mapVUBtn.hidden = true;
   
    } if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]) {
        boxBtn.hidden = YES;
         ipxBtn.hidden = false;
    }

    previewVUContents.backgroundColor = [UIColor clearColor];
    isAnimationStarted = FALSE;
    [self flashOff:animatedButton];
    [self removeVideoPreviewContent];
    [self removePreviewImageContent];
    [appDelegate.mapLinks removeAllObjects];
    previousSelectedId = -1;
    [patientVUImages removeAllObjects];
    [patientVuGMGridView reloadData];
    previewVUContent.image = nil;
    if (_toTokenfield != nil) {
        [_toTokenfield removeFromSuperview];
        _toTokenfield = nil;
    }
    dynamicChartView.hidden = YES;
    scrol.hidden = true;
    tagLabel.hidden = true;
    clearAll.enabled = NO;
    deleteVUBtn.enabled = NO;
    
    
    // notificationLable.hidden = YES;
    
    //[self clearPatientVuSelections];
    //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_CLEARALL_PATIENTVU object:nil];
    
    appDelegate.imageId = previousSelectedId;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LAST_SELECTED_IMAGE_ID
                                                        object:self];
    
    
}

- (UIImage *)generateImageFromVideo:(NSString *) pathString:(NSString *)pathType {
    NSURL *theContentURL;
    if ([pathType isEqualToString:IMAGE_VIDEO_TYPE] &&
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
#pragma mark UIAlertView DELEGATE
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_PATIENT_VU_TITLE", nil)]) {
        if (buttonIndex == 1)  {
            [self unselectPreviousSelectedImage];
            if(([patientVUImages count] - 1) > 0) {
                GMGridViewCell *cell = (GMGridViewCell *)[patientVuGMGridView cellForItemAtIndex:0];
                if(!cell.isSelected) {
                    previousSelectedId = ((welvu_images *)[patientVUImages objectAtIndex:0]).imageId;
                    for(UIView *subview in [cell.contentView subviews]) {
                        if([subview isKindOfClass:[UIImageView class]]) {
                            UIImageView *imageView = (UIImageView *)subview;
                            imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                               makeRoundCornerImage:5 :5];
                        }
                    }
                    cell.isSelected = TRUE;
                    welvu_images *welvu_imagesModel = [patientVUImages objectAtIndex:0];
                    welvu_imagesModel.pickedToView = YES;
                    [self setPreviewImageInView:welvu_imagesModel];
                    appDelegate.ispatientVUContent = TRUE;
                }
            } else {
                previousSelectedId = -1;
                previewVUContent.image = nil;
                appDelegate.ispatientVUContent = FALSE;
            }
            NSDictionary *itemDetails = [[NSDictionary alloc] initWithObjectsAndKeys
                                         :[patientVUImages objectAtIndex:_lastDeleteItemIndexAsked],
                                         TABLE_WELVU_IMAGES, nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_REMOVED_FROM_PATIENTVU object:self userInfo:itemDetails];
            [patientVUImages removeObjectAtIndex:_lastDeleteItemIndexAsked];
            [patientVuGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
            
        }
    } else if(alertView.tag == 123){
        
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:URL_UPGRADE]];
            
        }
        
        
        
    }
    
    else if ([alertView.title isEqualToString:NSLocalizedString(@"ALERT_SAVE_NEW_TOPIC_TITLE", nil)]) {
        if (buttonIndex == 1) {
            // To get spinner to the foreground...
            if (!spinner) {
                appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                spinner = [ProcessingSpinnerView loadSpinnerIntoView:appDelegate.splitViewController.view];
                [appDelegate.splitViewController.view bringSubviewToFront:spinner];
                
                [self.view bringSubviewToFront:spinner];
            }
        }
        
      /*  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^ { */
      
            if (buttonIndex == 1) {
                //Create topic model with name & persist new topic
                welvu_topics *welvu_topicsModel = [[welvu_topics alloc] init];
                welvu_topicsModel.topics_guid = [[Guid randomGuid] description];
                welvu_topicsModel.topicName = [[alertView textFieldAtIndex:0] text];
                welvu_topicsModel.welvu_user_id = appDelegate.welvu_userModel.welvu_user_id;
                welvu_topicsModel.is_locked = false;
                welvu_topicsModel.topic_active = true;
                welvu_topicsModel.topic_is_user_created = true;
                welvu_topicsModel.topic_hit_counter = -1;
               userCreatedTopicID = [welvu_topics addNewTopic:appDelegate.getDBPath :welvu_topicsModel:appDelegate.specialtyId];
                
                welvu_topicsModel = [welvu_topics setTopicId:welvu_topicsModel :userCreatedTopicID];
                BOOL inserted = [welvu_sync addSyncDetail:[appDelegate getDBPath] guid:welvu_topicsModel.topics_guid
                                                 objectId:welvu_topicsModel.topicId
                                                 syncType:SYNC_TYPE_TOPIC_CONSTANT
                                               actionType:ACTION_TYPE_CREATE_CONSTANT];
                
                int counter = 1;
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FILENAME_FORMAT];
                //Persisting all the PatientVU images to the new topic created
                for (welvu_images *patientWelvu_imagesModel in patientVUImages) {
                    NSString *imageName = [NSString stringWithFormat:@"%@_%d",
                                           [dateFormatter stringFromDate:[NSDate date]],counter];
                    
                    welvu_images *welvu_imagesModel = [[welvu_images alloc] init];
                    welvu_imagesModel.imageDisplayName = imageName;
                    welvu_imagesModel.image_guid = [[Guid randomGuid] description];
                    welvu_imagesModel.orderNumber = ([welvu_images getMaxOrderNumber:appDelegate.getDBPath
                                                                                    :welvu_topicsModel.topicId
                                                                              userId:appDelegate.welvu_userModel.welvu_user_id] + 1);
                    NSInteger imageCreatedId =  0;
                    //Persisting already existing image from the topic to newly created topic / if image is added from the PatientVU deck,
                    //image file is created and its location is saved to the particular topic
                    if(([patientWelvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE]
                        || [patientWelvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE])
                       && patientWelvu_imagesModel.imageData == nil) {
                        NSError *error = nil;
                        NSString *imagePath = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@.%@", DOCUMENT_DIRECTORY,imageName, HTTP_ATTACHMENT_IMAGE_EXT_KEY]];
                        if (![[NSFileManager defaultManager] copyItemAtPath:patientWelvu_imagesModel.url toPath:imagePath error:&error]) {
                            // NSLog(@"Error copying files: %@", [error localizedDescription]);
                        }
                        NSURL *outputURL = [NSURL fileURLWithPath:imagePath];

                        int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:outputURL];
                        welvu_imagesModel.type = IMAGE_ALBUM_TYPE;
                        welvu_imagesModel.url = [[NSString alloc] initWithString
                                                 :[NSString stringWithFormat:@"%@.%@",imageName,HTTP_ATTACHMENT_IMAGE_EXT_KEY]];
                        imageCreatedId = [welvu_images addNewImageToTopic:appDelegate.getDBPath
                                                                         :welvu_imagesModel
                                                                         :welvu_topicsModel.topicId];
                    } else if ([patientWelvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] && patientWelvu_imagesModel.imageData) {
                        
                        NSData *imageData = UIImageJPEGRepresentation(patientWelvu_imagesModel.imageData, 1.0);
                        NSString *imagePath = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@.%@", DOCUMENT_DIRECTORY,imageName, HTTP_ATTACHMENT_IMAGE_EXT_KEY]];
                        if([imageData writeToFile:imagePath atomically:YES]){
                            NSURL *outputURL = [NSURL fileURLWithPath:imagePath];
                            int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:outputURL];
                            welvu_imagesModel.type = IMAGE_ALBUM_TYPE;
                            welvu_imagesModel.url =  [[NSString alloc] initWithString
                                                      :[NSString stringWithFormat:@"%@.%@",imageName,HTTP_ATTACHMENT_IMAGE_EXT_KEY]];;
                            imageCreatedId = [welvu_images addNewImageToTopic:appDelegate.getDBPath
                                                                             :welvu_imagesModel:welvu_topicsModel.topicId];
                        }
                    }else if (([patientWelvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE]
                               || [patientWelvu_imagesModel.type isEqualToString:IMAGE_VIDEO_TYPE])
                              && patientWelvu_imagesModel.imageData == nil) {
                        NSError *error = nil;
                        NSString *imagePath = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@.%@", DOCUMENT_DIRECTORY,imageName, HTTP_ATTACHMENT_VIDEO_EXT_KEY]];
                        if (![[NSFileManager defaultManager] copyItemAtPath:patientWelvu_imagesModel.url toPath:imagePath error:&error]) {
                            // NSLog(@"Error copying files: %@", [error localizedDescription]);
                        }
                        //export complete
                        int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:[NSURL URLWithString: imagePath]];
                        if (!error && success){
                            welvu_imagesModel.type = IMAGE_VIDEO_ALBUM_TYPE;
                            welvu_imagesModel.url =  [[NSString alloc] initWithString
                                                      :[NSString stringWithFormat:@"%@.%@",imageName,HTTP_ATTACHMENT_VIDEO_EXT_KEY]];;
                            imageCreatedId = [welvu_images addNewImageToTopic:appDelegate.getDBPath
                                                                             :welvu_imagesModel:welvu_topicsModel.topicId];
                        }
                    }
                    if (imageCreatedId > 0) {
                        BOOL inserted = [welvu_sync addSyncDetail:[appDelegate getDBPath] guid:welvu_imagesModel.image_guid
                                                         objectId:imageCreatedId
                                                         syncType:SYNC_TYPE_CONTENT_CONSTANT
                                                       actionType:ACTION_TYPE_CREATE_CONSTANT];
                    }
                    counter++;
                   if(spinner != nil) {
                        [spinner removeFromSuperview];
                       // [self.view sendSubviewToBack:spinner];
                        spinner = nil;
                        //[self.view reloadInputViews];
                        NSLog(@"remove");
                    }
                    
                }
                SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
                dataToCloud.delegate = self;
                [dataToCloud startSyncDataToCloud:SYNC_TYPE_TOPIC_CONSTANT objectId:userCreatedTopicID
                                       actionType:HTTP_REQUEST_ACTION_TYPE_CREATE
                                        actionURL:PLATFORM_SYNC_TOPICS];

                               //Prompting user after saving data succesfully
                
                
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:[NSString stringWithFormat:
                                                     NSLocalizedString(@"ALERT_TOPIC_CONTENT_SAVE_TITLE", nil), welvu_topicsModel.topicName]
                                      message:nil
                                      delegate: self
                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                      otherButtonTitles:nil];
                alertView.tag = 10001;
                
                [alert show];
            }
        /*  ///remove dipatch
            dispatch_async(dispatch_get_main_queue(), ^ {
                
               
            });
        });*/
        

    } else if (alertView.tag = 10001) {
       
        NSLog(@"current topic id %d",currentOpenedTopicId);
        
         [self.masterViewController reloadAccordianTableData];
        
                
               }
    
}


/*
 * Method name: syncContentToPlatformDidReceivedData
 * Description: SYNC CONTENT FROM PLATFORM AND RECEIVE DATA FROM THE PLATFORM USING NSDICTIONARY
 * Parameters: success,responseDictionary
 * return NIL
 */
- (void)syncContentToPlatformDidReceivedData:(BOOL)success :(NSDictionary *)responseDictionary {
    if(success) {
        
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
        NSString *topic_guid = [responseDictionary objectForKey:HTTP_REQUEST_TOPIC_GUID];
        NSInteger topicId = [welvu_topics getTopicIdByGUID:[appDelegate getDBPath] :topic_guid];
        NSMutableArray *welvuImagesModel = [welvu_images getImagesIdByTopicId:[appDelegate getDBPath] :topicId
                                                                       userId:appDelegate.welvu_userModel.welvu_user_id];
        for(welvu_images *welvuImageModel in welvuImagesModel) {
            SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
            [dataToCloud startSyncDataToCloud:SYNC_TYPE_CONTENT_CONSTANT objectId:welvuImageModel.imageId
                                   actionType:HTTP_REQUEST_ACTION_TYPE_CREATE actionURL:PLATFORM_SYNC_CONTENTS];
        }
        
    }
}

- (void)syncContentToPlatformSendResponse:(BOOL)success {
    
}

- (void)syncContentFailedWithErrorDetails:(NSError *)error {
    
}

//////////////////////////////////////////////////////////
//Intializing GridViews
//////////////////////////////////////////////////////////
-  (void)intializeGMGridViews {
    GMGridView *patientVuGMGrid = [[GMGridView alloc] initWithFrame:CGRectMake(11, 650, 704, 102)];
    patientVuGMGrid.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //topicVuGMGridView.autoresizesSubviews = NO;
    patientVuGMGrid.clipsToBounds = YES;
    patientVuGMGrid.backgroundColor = [UIColor clearColor];
    [self.view addSubview:patientVuGMGrid];
    patientVuGMGridView = patientVuGMGrid;
    
    patientVuGMGridView.style = GMGridViewStylePush;
    patientVuGMGridView.itemSpacing = 5;
    patientVuGMGridView.minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    patientVuGMGridView.centerGrid = NO;
    patientVuGMGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal];
    patientVuGMGridView.enableEditOnLongPress = NO;
    patientVuGMGridView.disableEditOnEmptySpaceTap = YES;
    patientVuGMGridView.delegate = self;
    patientVuGMGridView.actionDelegate = self;
    patientVuGMGridView.sortingDelegate = self;
    patientVuGMGridView.dataSource = self;
    patientVuGMGridView.mainSuperView = appDelegate.splitViewController.view;
}


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return [patientVUImages count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        return CGSizeMake(THUMB_HORIZONTAL_BUTTON_WIDTH, THUMB_HORIZONTAL_BUTTON_HEIGHT);
    } else {
        return CGSizeMake(THUMB_HORIZONTAL_BUTTON_WIDTH, THUMB_HORIZONTAL_BUTTON_HEIGHT);
    }
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"ContCloseButton.png"];
        cell.deleteButtonOffset = CGPointMake(0, 0);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 8;
        view.contentMode = UIViewContentModeCenter;
        cell.contentView = view;
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    welvu_images *welvu_imagesModel = [patientVUImages objectAtIndex:index];
    
    
    UIImage *thumbnail = [self getThumbnail:welvu_imagesModel];
    
    if (welvu_imagesModel.pickedToView) {
        cell.isSelected = TRUE;
        thumbnail  = [thumbnail imageWithBorderForSelected:THUMB_IMAGE_BORDER];
    } else {
        cell.isSelected = FALSE;
        thumbnail  = [thumbnail imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
    }
    thumbnail = [thumbnail makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
    
    
    //Nsuser default for guide animation
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL *guideAnimation = [defaults boolForKey:@"guideAnimationOn"];
    [defaults synchronize];
    
    
    //To start animation if image count is greater than zero
    if([patientVUImages count] >=1 && !isAnimationStarted && guideAnimation) {
        isAnimationStarted = TRUE;
        [self flashOn:animatedButton];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = thumbnail;
    [cell.contentView addSubview:imageView];
    return cell;
}

- (void)spinLayer:(CALayer *)inLayer duration:(CFTimeInterval)inDuration
        direction:(int)direction {
    //imageToMove.hidden=NO;
    
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration = inDuration;
    fullRotation.repeatCount = 10000;
    //fullRotation.removedOnCompletion = YES;
    [inLayer addAnimation:fullRotation forKey:@"patientVUAnimation"];
}
- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index {
    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {
    if (gridView == patientVuGMGridView) {
        [self unselectPreviousSelectedImage];
        GMGridViewCell *cell = (GMGridViewCell *)[gridView cellForItemAtIndex:position];
        if (!cell.isSelected) {
            previousSelectedId = ((welvu_images *)[patientVUImages objectAtIndex:position]).imageId;
            for (UIView *subview in [cell.contentView subviews]) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)subview;
                    imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                    imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS:IMAGE_ROUNDED_CORNER_RADIUS];
                }
            }
            cell.isSelected = TRUE;
            welvu_images *welvu_imagesModel = [patientVUImages objectAtIndex:position];
            welvu_imagesModel.pickedToView = YES;
            [self setPreviewImageInView:welvu_imagesModel];
            appDelegate.ispatientVUContent = TRUE;
            appDelegate.imageId = previousSelectedId;
            
            dynamicChartView.hidden = YES;
            /*[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LAST_SELECTED_IMAGE_ID
             object:self];*/
            
            // BOOL reterieve=[welvu_contenttag reterievetagname:appDelegate.getDBPath :previousSelectedId];
            
            if ((previousSelectedId >= LOCAL_TEMP_CONTENT_ID_START_RANGE)
                && (previousSelectedId < LOCAL_IMAGE_CONTENT_ID_START_RANGE)) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"annoatationviewcancel"
                                                                    object:self];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LAST_SELECTED_IMAGE_ID
                                                                    object:self];
            }
        }
    }
}


- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView {
    
    if(gridView == patientVuGMGridView) {
        deleteVUBtn.selected = NO;
       
    }
}
//Delete the item at the given index
- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index {
    
    _lastDeleteItemIndexAsked = index;
    
    [self unselectPreviousSelectedImage];
    
    NSDictionary *itemDetails = [[NSDictionary alloc] initWithObjectsAndKeys
                                 :[patientVUImages objectAtIndex:_lastDeleteItemIndexAsked],
                                 TABLE_WELVU_IMAGES, nil];
    NSInteger mapIndex = [self searchMapLinkGroups
                          :((welvu_images *)[patientVUImages objectAtIndex:_lastDeleteItemIndexAsked]).imageId
                           :appDelegate.mapLinks];
    if(mapIndex > -1) {
        [appDelegate.mapLinks removeObjectAtIndex:mapIndex];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_REMOVED_FROM_PATIENTVU object:self userInfo:itemDetails];
    [patientVUImages removeObjectAtIndex:_lastDeleteItemIndexAsked];
    [patientVuGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
    [self.masterViewController refreshTableData];
    
    if ([patientVUImages count] > 0) {
        GMGridViewCell *cell = (GMGridViewCell *)[patientVuGMGridView cellForItemAtIndex:0];
        if (!cell.isSelected) {
            previousSelectedId = ((welvu_images *)[patientVUImages objectAtIndex:0]).imageId;
            for (UIView *subview in [cell.contentView subviews]) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)subview;
                    imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                    imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                    
                }
            }
            cell.isSelected = TRUE;
            welvu_images *welvu_imagesModel = [patientVUImages objectAtIndex:0];
            welvu_imagesModel.pickedToView = YES;
            [self setPreviewImageInView:welvu_imagesModel];
            appDelegate.ispatientVUContent = TRUE;
            // //EMR
            snapBtn.enabled = NO;
            dynamicChartView.hidden = YES;
            //EMR
        }
    } else {
        isAnimationStarted = FALSE;
        [self flashOff:animatedButton];
        [self removePreviewImageContent];
        [self removeVideoPreviewContent];
        previousSelectedId = -1;
        previewVUContent.image = nil;
        appDelegate.ispatientVUContent = FALSE;
        deleteVUBtn.enabled = NO;
        clearAll.enabled = NO;
        scrol.hidden = true;
        tagLabel.hidden = true;
        
    }
    appDelegate.imageId = previousSelectedId;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LAST_SELECTED_IMAGE_ID
                                                        object:self];
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewSortingDelegate
//////////////////////////////////////////////////////////////
- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell {
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
    
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell {
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIImageView *imageView;
    for (UIView *subview in [cell.contentView subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
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
                         imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil
     ];
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex {
    welvu_images *object = [patientVUImages objectAtIndex:oldIndex];
    [patientVUImages removeObject:object];
    [patientVUImages insertObject: object atIndex:newIndex];
}
//Move patientvu images with posotion
- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2 {
    [patientVUImages exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index {
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    UIEdgeInsets inset = aScrollView.contentInset;
    float x = offset.x + bounds.size.width - inset.right;
    
    if (aScrollView.contentOffset.x <= 0) {
        self.bottomFadingView.hidden = true;
    }
    
    if(aScrollView.contentOffset.x <= aScrollView.contentSize.width) {
        self.bottomFadingView.hidden = false;
    }
    
    if(x >= aScrollView.contentSize.width) {
        self.topFadingView.hidden = false;
        self.bottomFadingView.hidden = true;
    }
    
    if (aScrollView.contentOffset.x <= 0) {
        self.topFadingView.hidden = true;
    }
    
    if (aScrollView.contentOffset.x > 5) {
        self.topFadingView.hidden = false;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    CGPoint location = [mytouch locationInView:self.view];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TAP_FROM_DETAILVU object:nil];
    if (location.y < 704) {
        patientVuGMGridView.editing = false;
        deleteVUBtn.selected = false;
        
    }
    
}

#pragma mark -
#pragma mark JSTokenFieldDelegate

- (void)tokenField:(JSTokenField *)tokenField didAddToken:(NSString *)title representedObject:(id)obj {
    //NSDictionary *recipient = [NSDictionary dictionaryWithObject:obj forKey:title];
    [_toGetTagName addObject:title];
    createtag = [welvu_contenttag insertcontenttag:appDelegate.getDBPath :previousSelectedId :_toGetTagName];
}

- (void)tokenField:(JSTokenField *)tokenField didRemoveToken:(NSString *)title representedObject:(id)obj {
    
    NSInteger index = [self searchTokenIndex:title :_toGetTagName];
    if (index > -1) {
        [_toGetTagName removeObjectAtIndex:index];
        createtag = [welvu_contenttag insertcontenttag:appDelegate.getDBPath :previousSelectedId :_toGetTagName];
    }
}

#pragma mark JSTokenField Delegate
- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField {
    [tokenField resignFirstResponder];
    NSMutableString *recipient = [NSMutableString string];
    
    NSMutableCharacterSet *charSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
    [charSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    
    NSString *rawStr = [[tokenField textField] text];
    for (int i = 0; i < [rawStr length]; i++) {
        if (![charSet characterIsMember:[rawStr characterAtIndex:i]]) {
            [recipient appendFormat:@"%@",[NSString stringWithFormat:@"%c", [rawStr characterAtIndex:i]]];
        }
    }
    
    if ([rawStr length]) {
        [tokenField addTokenWithTitle:rawStr representedObject:recipient];
    }
    
    return NO;
}

- (void)handleTokenFieldFrameDidChange:(NSNotification *)note {
    if ([[note object] isEqual:_toTokenfield]) {
        /*[UIView animateWithDuration:0.0
         animations:^{
         [_ccField setFrame:CGRectMake(0, [_toField frame].size.height + [_toField frame].origin.y, [_ccField frame].size.width, [_ccField frame].size.height)];
         }
         completion:nil];*/
        scrol.contentSize=CGSizeMake(_toTokenfield.frame.size.width, _toTokenfield.frame.size.height);
        CGPoint bottomOffset = CGPointMake(0, scrol.contentSize.height - scrol.bounds.size.height);
        [scrol setContentOffset:bottomOffset animated:YES];
        
    }
    
}


- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    if(netStatus == NotReachable) {
        networkReachable = false;
    } else {
        networkReachable = true;
    }
}

- (void) themeSettingsViewControllerDidFinish {
    
    
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    if(appDelegate.welvu_userModel.org_id > 0) {
        NSString *logoName = [welvu_organization getOrganizationLogoNameById:[appDelegate getDBPath] :appDelegate.welvu_userModel.org_id];
        
        if([logoName isEqualToString:@""]) {
            themeLogo.image = [UIImage imageNamed:@"WelvuLogoBanner.png"];
            
        } else {
            
            appDelegate.org_Logo = ([welvu_organization getOrganizationDetailsById
                                     :[appDelegate getDBPath]
                                     orgId:appDelegate.welvu_userModel.org_id]).orgLogoName;
            
            
            
            [themeLogo setImage:[UIImage imageWithContentsOfFile:appDelegate.org_Logo]];
            
            
            
        }
    } else {
        themeLogo.image = [UIImage imageNamed:@"WelvuLogoBanner.png"];
    }
    
    
    [self.view bringSubviewToFront:themeLogo];
    
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark UIInterfaceOrientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (void)startUpViewController {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)orientationChanged:(NSNotification *)notification {
    [self shouldAutorotate];
}

- (void)flashOff:(UIView *)v {
    [animatedButton stopAnimating];
}

- (void)flashOn:(UIView *)v {
    [animatedButton startAnimating];
}

#pragma mark EMR
//EMR
- (void) intializePatientInfoContent {
    previewVUContents.backgroundColor = [UIColor clearColor];
    [self removePatientGraphContent];
    btnSelect.hidden = YES;
    // graphTitle.hidden=YES;
    //graphLegends.hidden=YES;
    // snapBtn.hidden = YES;
    snapBtn.enabled = NO;
    // graphSeriesList.hidden = YES;
    seriesListView.hidden=YES;
    dynamicChartView.hidden = YES;
    clearAll.enabled = YES;
    deleteVUBtn.enabled = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HIDE_PATIENT_INFO_BUTTON object:self userInfo:nil];
    if(appDelegate.currentPatientInfo != nil) {
        //  NSLog(@"array value: %@",appDelegate.currentPatientInfo);
        NSDictionary *patientID=appDelegate.currentPatientInfo;
        NSString *mysam=[appDelegate.currentPatientInfo objectForKey:@"email"];
        patientInfoView = [[UIView alloc] initWithFrame:
                           CGRectMake(0, 0, IMAGE_VIEW_WIDTH, IMAGE_VIEW_HEIGHT)];
        UIImageView *card =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profileBg.png"]];
        card.frame = patientInfoView.frame;
        [patientInfoView addSubview:card];
        [patientInfoView sendSubviewToBack:card];
        patientInfoView.contentMode = UIViewContentModeScaleAspectFit;
        
        UIImageView *patient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user.png"]];
        patient.frame = CGRectMake(300, 30, 100, 100);
        [patient setBackgroundColor: [UIColor whiteColor]];
        [patientInfoView addSubview:patient];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 150, 100, 25)];
        nameLabel.text = @"Name";
        nameLabel.textAlignment = UITextAlignmentRight;
        [patientInfoView addSubview:nameLabel];
        
        UILabel *pName = [[UILabel alloc] initWithFrame:CGRectMake(150, 137, 200, 50)];
        [pName setNumberOfLines:2];
        NSString *fName =[patientID objectForKey:@"fname"];
        NSString *mName =[patientID objectForKey:@"mname"];
        NSString *lName =[patientID objectForKey:@"lname"];
        NSString *imageFullName=[NSString stringWithFormat:@"%@ %@ %@", fName,mName,lName];
        
        pName.text= imageFullName;
        [patientInfoView addSubview:pName];
        
        UILabel *genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 200, 100, 25)];
        genderLabel.text = @"Gender";
        genderLabel.textAlignment = UITextAlignmentRight;
        [patientInfoView addSubview:genderLabel];
        
        UILabel *sex = [[UILabel alloc] initWithFrame:CGRectMake(150, 200, 200, 25)];
        [patientInfoView addSubview:sex];
        sex.text= [patientID objectForKey:@"sex"];
        
        UILabel *address = [[UILabel alloc] initWithFrame:CGRectMake(40, 250, 100, 25)];
        address.text = @"Address";
        address.textAlignment = UITextAlignmentRight;
        [patientInfoView addSubview:address];
        
        UILabel *street = [[UILabel alloc] initWithFrame:CGRectMake(150, 250, 200, 25)];
        street.text= [patientID objectForKey:@"street"];
        [patientInfoView addSubview:street];
        
        UILabel *postalcode = [[UILabel alloc] initWithFrame:CGRectMake(150, 275, 200, 25)];
        postalcode.text= [patientID objectForKey:@"postalcode"];
        [patientInfoView addSubview:postalcode];
        
        UILabel *city = [[UILabel alloc] initWithFrame:CGRectMake(150, 300, 200, 25)];
        [patientInfoView addSubview:city];
        city.text= [patientID objectForKey:@"city"];
        
        
        UILabel *countrycode = [[UILabel alloc] initWithFrame:CGRectMake(150, 325, 200, 25)];
        [patientInfoView addSubview:countrycode];
        countrycode.text= [patientID objectForKey:@"countrycode"];
        
        
        /* UILabel *driverslicense = [[UILabel alloc] initWithFrame:CGRectMake(50, 350, 200, 25)];
         [patientInfoView addSubview:driverslicense];
         driverslicense.text= [patientID objectForKey:@"driverslicense"]; */
        
        UILabel *occupationLabel = [[UILabel alloc] initWithFrame:CGRectMake(380, 150, 100, 25)];
        occupationLabel.text = @"Occupation";
        occupationLabel.textAlignment = UITextAlignmentRight;
        [patientInfoView addSubview:occupationLabel];
        
        UILabel *occupation = [[UILabel alloc] initWithFrame:CGRectMake(500, 137, 200, 50)];
        [occupation setNumberOfLines:2];
        [patientInfoView addSubview:occupation];
        occupation.text= [patientID objectForKey:@"occupation"];
        
        
        UILabel *phoneHLabel = [[UILabel alloc] initWithFrame:CGRectMake(380, 200, 100, 25)];
        phoneHLabel.text = @"Ph Home";
        phoneHLabel.textAlignment = UITextAlignmentRight;
        [patientInfoView addSubview:phoneHLabel];
        
        UILabel *phonehome = [[UILabel alloc] initWithFrame:CGRectMake(500, 200, 200, 25)];
        [patientInfoView addSubview:phonehome];
        phonehome.text= [patientID objectForKey:@"phonehome"];
        
        UILabel *phoneBiz = [[UILabel alloc] initWithFrame:CGRectMake(380, 225, 100, 25)];
        phoneBiz.text = @"Ph Buisness";
        phoneBiz.textAlignment = UITextAlignmentRight;
        [patientInfoView addSubview:phoneBiz];
        
        UILabel *phonebiz = [[UILabel alloc] initWithFrame:CGRectMake(500, 225, 200, 25)];
        [patientInfoView addSubview:phonebiz];
        phonebiz.text= [patientID objectForKey:@"phonebiz"];
        
        UILabel *phoneContactLabel = [[UILabel alloc] initWithFrame:CGRectMake(380, 250, 100, 25)];
        phoneContactLabel.text = @"Ph Contact";
        phoneContactLabel.textAlignment = UITextAlignmentRight;
        [patientInfoView addSubview:phoneContactLabel];
        
        UILabel *phonecontact = [[UILabel alloc] initWithFrame:CGRectMake(500, 250, 200, 25)];
        [patientInfoView addSubview:phonecontact];
        phonecontact.text= [patientID objectForKey:@"phonecontact"];
        
        UILabel *phoneCellLabel = [[UILabel alloc] initWithFrame:CGRectMake(380, 275, 100, 25)];
        phoneCellLabel.text = @"Ph Mobile";
        phoneCellLabel.textAlignment = UITextAlignmentRight;
        [patientInfoView addSubview:phoneCellLabel];
        
        UILabel *phonecell = [[UILabel alloc] initWithFrame:CGRectMake(500, 275, 200, 25)];
        [patientInfoView addSubview:phonecell];
        phonecell.text= [patientID objectForKey:@"phonecell"];
        
        UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(380, 325, 100, 25)];
        emailLabel.text = @"Email";
        emailLabel.textAlignment = UITextAlignmentRight;
        [patientInfoView addSubview:emailLabel];
        
        UILabel *email = [[UILabel alloc] initWithFrame:CGRectMake(500, 322, 200, 50)];
        [email setNumberOfLines:2];
        [patientInfoView addSubview:email];
        email.text= [patientID objectForKey:@"email"];
        
        
        [previewVUContents addSubview:patientInfoView];
        
        for(UIView *view in [patientInfoView subviews]) {
            view.backgroundColor = [UIColor clearColor];
            if([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *) view;
                label.textColor = [UIColor whiteColor];
            }
        }
        
    }
    if(appDelegate.currentPatientInfo == nil) {
        [self performSelector:@selector(intializePatientInfoContent) withObject:nil afterDelay:0.2];
    }
    CGRect rect = [patientInfoView bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [patientInfoView.layer renderInContext:context];
    PinfoSnapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self addPatientInfoImagesToPatientVU:patientInfoView];
    
}
- (void) addPatientInfoImagesToPatientVU:(welvu_images *) welvu_imgesModel{
    // snapBtn.hidden = YES;
    // graphSeriesList.hidden=YES;
    seriesListView.hidden=YES;
    
    // btnSelect.hidden =YES;
    // graphTitle.hidden=YES;
    // graphLegends.hidden=YES;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT];
    NSString *mediaType = IMAGE_PATIENTINFO_TYPE;
    NSString *imageName = [dateFormatter stringFromDate:[NSDate date]];
    UIImage *anImage = PinfoSnapshot;
    
    welvu_images *welvu_imagesModel = [[welvu_images alloc] initWithImageId:(++albumAddedCount)];
    welvu_imagesModel.imageDisplayName = imageName;
    welvu_imagesModel.type = IMAGE_PATIENTINFO_TYPE;
    welvu_imagesModel.imageData = anImage;
    welvu_imagesModel.pickedToView = YES;
    [patientVUImages addObject:welvu_imagesModel];
    
    [self unselectPreviousSelectedImage];
    
    [patientVuGMGridView insertObjectAtIndex:[patientVUImages count] - 1
                               withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
    
    previousSelectedId = ((welvu_images *)[patientVUImages lastObject]).imageId;
    [self setPreviewImageInView:welvu_imagesModel];
    
    
}

- (void) removePatientGraphContent {
    //[patientgraphView removeFromSuperview];
    // patientgraphView = nil;
    btnSelect.hidden = YES;
    graphTitle.hidden=YES;
    graphLegends.hidden=YES;
    // snapBtn.hidden = YES;
    graphSeriesList.hidden = YES;
    seriesListView.hidden=YES;
    
    //[snapBtn removeFromSuperview];
    if(lineChart != nil) {
        [lineChart removeFromSuperview];
        lineChart = nil;
        //patientgraphView.backgroundColor =[UIColor clearColor];
    }
    
    if(mapView != nil) {
        [mapView removeFromSuperview];
        mapView = nil;
        //patientgraphView.backgroundColor =[UIColor clearColor];
    }
    [mapVUBtn setBackgroundImage:[UIImage imageNamed:@"map_icon_n"] forState:UIControlStateNormal];
    ibSearchBar.hidden = true;
}

- (void) removePatientInfoContent {
    if(patientInfoView != nil) {
        [patientInfoView removeFromSuperview];
        patientInfoView = nil;
    }
}

- (void) showGraphView{
    
    NSDictionary *graphInfo = appDelegate.currentPatientGraphInfo;
    
    // NSLog(@"graph info %@",graphInfo);
    if ((NSNull *)graphInfo == [NSNull null]){
        NSLog(@"Patient image null");
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"ALERT_CANT_DISPLAY_GRAPH", nil)
                              message:NSLocalizedString(@"ALERT_NO_VITAL_RECORDS_FOUND", nil)
                              delegate: nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil];
        [alert show];
        
    } else {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        welvu_settings * welvuSettingsModel = [[welvu_settings alloc]init];
        
        welvuSettingsModel = [welvu_settings getActiveSettings:[appDelegate getDBPath]];
        
        // NSLog(@"welvusettingsmodel %@",welvuSettingsModel);
        
        NSInteger weightValue = welvuSettingsModel.weight;
        
        if(weightValue == 0) {
            weightText.text = @"Weight (lbs)";
            
        }else {
            weightText.text = @"Weight (kg)";
            
        }
        
        NSInteger tempValue = welvuSettingsModel.temperature;
        
        if(tempValue == 0) {
            temperatureText.text = @"Temperature (F)";
            
        }else {
            temperatureText.text = @"Temperature (C)";
            
        }
        
        NSInteger heightValue = welvuSettingsModel.height;
        
        if(heightValue == 0) {
            heightText.text = @"Height (cm)";
            
        }else {
            heightText.text = @"Height (in)";
            
        }
             NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        [self removePreviewImageContent];
        [self removeVideoPreviewContent];
        [self removePatientGraphContent];
        dynamicChartView.hidden = NO;
        dynamicChartView.text = NSLocalizedString(@"PATIENT_CHART", nil);
        
        seriesListView.hidden=FALSE;
        snapBtn.enabled = TRUE;
        btnSelect.hidden = NO;
        // snapBtn.hidden = NO;
        graphSeriesList.hidden = NO;
        graphTitle.hidden=NO;
        graphLegends.hidden=NO;
        
        if(previewVUContent != nil) {
            [previewVUContent removeFromSuperview];
            previewVUContent = nil;
        }
        [previewVUContent removeFromSuperview];
        /* patientgraphView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 708, 660)];
         patientgraphView.layer.cornerRadius = 3;
         patientgraphView.layer.masksToBounds = YES;
         patientgraphView.backgroundColor = [UIColor whiteColor];*/
        
        
        ShinobiGetValue *getWeightValue = [[ShinobiGetValue alloc]init];
        [getWeightValue getMaxAndMinValueFromPoints];
        NSString * weightMax =  [getWeightValue minWeight];
        // NSLog(@"maxWeight %@",weightMax);
        NSString * weightMin = [getWeightValue maxWeight];
        // NSLog(@"min Weight %@",weightMin);
        
        //santhosh - to display data value
        
        NSString * dateMax =  [getWeightValue maxDate];
        //  NSLog(@"maxDate %@",weightMax);
        NSString * DateMin = [getWeightValue minDate];
        //  NSLog(@"min Date %@",weightMin);
        
        
        
        lineChart = [ShinobiChart displayChartSeriesinDetailVU:CGRectMake(0, 0, 650, 380) :weightMin :weightMax :DateMin :dateMax];
        
        //santhosh
        
        
        // lineChart = [ShinobiChart displayChartSeriesinDetailVU:CGRectMake(0, 0, 650, 350) :weightMin :weightMax];
        
        
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(legendClick:)];
        tap.delegate=self;
        tap.numberOfTapsRequired =1;
        [lineChart.legend addGestureRecognizer:tap];
        lineChart.legend.hidden = YES;
        // lineChart = [ShinobiChart lineChartForBrowserUsageWithFrame: CGRectMake(7, 10, 708, 660)];
        
        
        
        mobileBrowserUsageStats = [[WeightsHeights alloc]init];
        [mobileBrowserUsageStats init];
        
        datasource = [Datasource new];
        datasource.browserUsageStats = mobileBrowserUsageStats;
        
        
        
        lineChart.delegate = self;
        lineChart.backgroundColor = [UIColor clearColor];
        
        lineChart.datasource = datasource;
      //welvu2.1  [lineChart.crosshair setDefaultTooltip];
        
        
        previewVUContents.backgroundColor = [UIColor colorWithPatternImage:
                                             [UIImage imageNamed:@"bg.png"]];
        
        
        [previewVUContents addSubview:lineChart];
        [previewVUContents sendSubviewToBack:lineChart];
        // [self.view bringSubviewToFront:seriesListView];
        
        
    }
}
- (IBAction) buttonPressed:(id)sender{
    UIButton * button = (UIButton *)sender;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (button.tag == GRAPH_SERIES_WEIGHTS) {
        
        
        if (button.selected) {
            button.selected = NO;
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            [prefs setObject:@"Unselected" forKey:@"Weightselected"];
        }
        else{
            /* UIColor *color = weight_button.currentTitleColor;
             weight_button.titleLabel.layer.shadowColor = [color CGColor];
             weight_button.titleLabel.layer.shadowRadius = 4.0f;
             weight_button.titleLabel.layer.shadowOpacity = .9;
             weight_button.titleLabel.layer.shadowOffset = CGSizeZero;
             weight_button.titleLabel.layer.masksToBounds = NO;
             weight_button.selected = YES;
             weight_button.backgroundColor = [UIColor redColor];
             weight_button.layer.borderColor = [[UIColor blueColor]CGColor];
             weight_button.titleLabel.backgroundColor = [UIColor greenColor];
             weight_button.layer.backgroundColor = (__bridge CGColorRef)([UIColor magentaColor]);*/
            // NSLog(@"first time selected");
            button.selected = YES;
            
            [prefs setObject:@"Weightselected" forKey:@"Weightselected"];
            
        }
    }else if (button.tag == GRAPH_SERIES_BMI){
        if (button.selected) {
            //  NSLog(@"first time unselect");
            button.selected = NO;
            [prefs setObject:@"Unselected" forKey:@"BMIselected"];
        }
        else{
            // NSLog(@"first time selected");
            button.selected = YES;
            [prefs setObject:@"BMIselected" forKey:@"BMIselected"];
            
        }
    }else if (button.tag == GRAPH_SERIES_HEIGHTS){
        if (button.selected) {
            button.selected = NO;
            [prefs setObject:@"Unselected" forKey:@"Heightselected"];
        }
        else{
            
            button.selected = YES;
            [prefs setObject:@"Heightselected" forKey:@"Heightselected"];
            
        }
    }
    else if (button.tag == GRAPH_SERIES_TEMPARATURE){
        if (button.selected) {
            button.selected = NO;
            [prefs setObject:@"Unselected" forKey:@"Tempselected"];
        }
        else{
            button.selected = YES;
            [prefs setObject:@"Tempselected" forKey:@"Tempselected"];
        }
    }else if (button.tag == GRAPH_SERIES_BPS || button.tag == GRAPH_SERIES_BPd ){
        if (button.selected) {
            bpsBtn.selected= NO;
            bpdBtn.selected= NO;
            button.selected = NO;
            [prefs setObject:@"Unselected" forKey:@"Pressureselected"];
        }
        else{
            bpsBtn.selected= YES;
            bpdBtn.selected= YES;
            button.selected = YES;
            [prefs setObject:@"Pressureselected" forKey:@"Pressureselected"];
        }
    }
    [self.view sendSubviewToBack:lineChart];
    // [self.view bringSubviewToFront:seriesListView];
    [self showGraphView];
}
//take snapshot
- (IBAction) graphOpenGLSnapshot:(id)sender  {
    dynamicChartView.hidden = YES;
    //seriesListView.hidden = YES;
    PinfoSnapshot = [lineChart snapshot];
    UIImage *previewContentsSnapShot = [self capturePreviewVUContents];
    
    /* NSData *imageData = UIImageJPEGRepresentation([previewContentsSnapShot fuseImages:previewContentsSnapShot.size :PinfoSnapshot], 1.0);
     NSString *fullPath = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@.jpg",
     DOCUMENT_DIRECTORY,
     @"ShinobiPic"]];
     [imageData writeToFile:fullPath atomically:YES];*/
    
    [self addGraphInfoImagesToPatientVU:[previewContentsSnapShot fuseImages:previewContentsSnapShot.size :PinfoSnapshot]];
    clearAll.enabled = YES;
    deleteVUBtn.enabled = YES;
    snapBtn.enabled = NO;
    lineChart = nil;
}

-(UIImage *) capturePreviewVUContents {
    //Grab the chart image (minus GL)
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(previewVUContents.frame.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(previewVUContents.frame.size);
    }
    
    [previewVUContents.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [previewVUContents.layer renderInContext:context];
    //start a new inner pool
    UIImage *currentScreen = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return currentScreen;
    
}
- (void) addGraphInfoImagesToPatientVU:(UIImage *) graphSnapShot{
    // snapBtn.hidden = YES;
    graphSeriesList.hidden=YES;
    seriesListView.hidden=YES;
    
    btnSelect.hidden =YES;
    graphTitle.hidden=YES;
    graphLegends.hidden=YES;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT];
    NSString *mediaType = GRAPH_IMAGE_TYPE;
    NSString *imageName = [dateFormatter stringFromDate:[NSDate date]];
    UIImage *anImage = graphSnapShot;
    
    welvu_images *welvu_imagesModel = [[welvu_images alloc] initWithImageId:(++albumAddedCount)];
    welvu_imagesModel.imageDisplayName = imageName;
    welvu_imagesModel.type = GRAPH_IMAGE_TYPE;
    welvu_imagesModel.imageData = anImage;
    welvu_imagesModel.pickedToView = YES;
    [patientVUImages addObject:welvu_imagesModel];
    
    [self unselectPreviousSelectedImage];
    
    [patientVuGMGridView insertObjectAtIndex:[patientVUImages count] - 1
                               withAnimation:GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll];
    
    previousSelectedId = ((welvu_images *)[patientVUImages lastObject]).imageId;
    [self setPreviewImageInView:welvu_imagesModel];
    
    
}

//IPX
/*
 * Method name: GetIpxBtnClicked
 * Description: To List the iPx Videos
 * Parameters: id
 * return IBAction
 */


-(IBAction)GetIpxBtnClicked:(id)sender {
    
    //Declaring Event Tracking Analytics
    
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Pre VU - PV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Pre VU - PV"
                                                          action:@"iPx Button  - PV"
                                                           label:@"iPx"
                                                           value:nil] build]];
    @try {
        
        if(appDelegate.networkReachable) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
            
            if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
                appDelegate.checkOrganizationUserLicense = false;
                [appDelegate checkUserLicense];
                
                
                welvuIPXViewController* ipxController = [[welvuIPXViewController alloc]init];
                
                ipxController.delegate = self;
                ipxController.modalPresentationStyle = UIModalPresentationFullScreen;
                ipxController.modalTransitionStyle = UIModalTransitionStyleCoverVertical; //transition shouldn't matt
                [self presentModalViewController:ipxController animated:YES];
                
            } else {
            
            int orgCount = [welvu_organization getOrganizationCount:[appDelegate getDBPath]];
            
            
            if(appDelegate.welvu_userModel.org_id > 0) {
                
                
                appDelegate.checkOrganizationUserLicense = false;
                [appDelegate checkUserLicense];
                
                
                welvuIPXViewController* ipxController = [[welvuIPXViewController alloc]init];
                
                ipxController.delegate = self;
                ipxController.modalPresentationStyle = UIModalPresentationFullScreen;
                ipxController.modalTransitionStyle = UIModalTransitionStyleCoverVertical; //transition shouldn't matt
                [self presentModalViewController:ipxController animated:YES];            } else {
                if(appDelegate.orgGoToWelVU) {
                    UIAlertView *myAlert = [[UIAlertView alloc]
                                            initWithTitle:NSLocalizedString(@"UPGRADE_TITLE", nil)
                                            message:nil
                                            delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                            otherButtonTitles:NSLocalizedString(@"UPGRADE", nil),nil];
                    myAlert.tag = 123;
                    [myAlert show];
                } else {
                    UIAlertView *myAlert = [[UIAlertView alloc]
                                            initWithTitle:NSLocalizedString(@"UPGRADE_TITLE", nil)
                                            message:nil
                                            delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                            otherButtonTitles:NSLocalizedString(@"UPGRADE", nil),nil];
                    myAlert.tag = 123;
                    [myAlert show];
                    

                }
            }

            
            }
            
            
            
        } else {
            UIAlertView *myAlert = [[UIAlertView alloc]
                                    initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                    message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                    delegate:nil
                                    cancelButtonTitle:@"Ok"
                                    otherButtonTitles:nil];
            [myAlert show];
            
        }
    } @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Pre VU - PV_iPx: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
 



-(void)welvuIPXDidFinish:(BOOL)completed {
    notificationLable.hidden = YES;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)setPreviewImageInViewinnstimer:(welvu_images *)welvu_imagesModel {
    if(spinner != nil) {
        [spinner removeFromSuperview];
        spinner = nil;
    }
    CGSize destinationSize = CGSizeMake(IMAGE_VIEW_WIDTH, IMAGE_VIEW_HEIGHT);
    if([welvu_imagesModel.type isEqualToString:IMAGE_PATIENTINFO_TYPE] && welvu_imagesModel.imageId == 0) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        UIImage *originalImage = [UIImage imageWithData:imageData];
        previewVUContent.image = [[originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                  makeRoundCornerImage:5 :5];
    } else if([welvu_imagesModel.type isEqualToString:GRAPH_IMAGE_TYPE] && welvu_imagesModel.imageId == 0) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        UIImage *originalImage = [UIImage imageWithData:imageData];
        previewVUContent.image = originalImage;
    }  else if([welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE] ||
               [welvu_imagesModel.type isEqualToString:IMAGE_PATIENT_TYPE]) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        UIImage *originalImage = [UIImage imageWithData:imageData];
        previewVUContent.image = [[originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                  makeRoundCornerImage:5 :5];
    } else if([welvu_imagesModel.type isEqualToString:IMAGE_BLANK_TYPE]) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        NSString *imageName = [NSString stringWithFormat:welvu_imagesModel.url];
        UIImage *originalImage =  [UIImage imageNamed:imageName];
        // UIImage *originalImage = [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
        previewVUContent.image = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        
        /* UIImage *originalImage = [UIImage imageWithContentsOfFile:welvu_imagesModel.url];
         previewVUContent.image = [[originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
         makeRoundCornerImage:5 :5];*/
    }
    else if(([welvu_imagesModel.type isEqualToString:IMAGE_PATIENTINFO_TYPE]
             ||[welvu_imagesModel.type isEqualToString:IMAGE_HISTORY_TYPE])&& welvu_imagesModel.imageId > 0) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        UIImage *originalImage = nil;
        if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            originalImage = [UIImage imageWithData:imageData];
        } else {
            originalImage = welvu_imagesModel.imageData;
        }
        previewVUContent.image = [[originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                  makeRoundCornerImage:5 :5];
    }
    else if(([welvu_imagesModel.type isEqualToString:GRAPH_IMAGE_TYPE]
             ||[welvu_imagesModel.type isEqualToString:IMAGE_HISTORY_TYPE])&& welvu_imagesModel.imageId > 0) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        UIImage *originalImage = nil;
        if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            originalImage = [UIImage imageWithData:imageData];
        } else {
            originalImage = welvu_imagesModel.imageData;
        }
        previewVUContent.image = originalImage;
    }
    else if(([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE]
             ||[welvu_imagesModel.type isEqualToString:IMAGE_HISTORY_TYPE])&& welvu_imagesModel.imageId > 0) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        UIImage *originalImage = nil;
        if([[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
            originalImage = [UIImage imageWithData:imageData];
        } else {
            originalImage = welvu_imagesModel.imageData;
        }
        previewVUContent.image = [[originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                  makeRoundCornerImage:5 :5];
    } else if([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE] && welvu_imagesModel.imageId == 0) {
        [self removeVideoPreviewContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(previewVUContent == nil) {
            [self intializePreviewImageContent];
        }
        UIImage *originalImage = welvu_imagesModel.imageData;
        previewVUContent.image = [[originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES]
                                  makeRoundCornerImage:5 :5];
    } else if([welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_TYPE]
              || [welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE] || [welvu_imagesModel.type isEqualToString:VIDEO_PATIENT_TYPE]) {
        [self removePreviewImageContent];
        [self removePatientInfoContent];
        [self removePatientGraphContent];
        if(moviePlayerController == nil) {
            [self intializeVideoPreviewContent];
        }
        NSURL *theContentURL;
        if(![[NSFileManager defaultManager] fileExistsAtPath:welvu_imagesModel.url]) {
            NSBundle *bundle = [NSBundle mainBundle];
            NSArray *nameAndType = [welvu_imagesModel.url componentsSeparatedByString: @"."];
            NSString *moviePath = [bundle pathForResource:[nameAndType objectAtIndex:0] ofType:[nameAndType objectAtIndex:1]];
            theContentURL = [NSURL fileURLWithPath:moviePath];
        } else {
            theContentURL = [NSURL fileURLWithPath:welvu_imagesModel.url];
        }
        moviePlayerController.movieSourceType = MPMovieSourceTypeFile;
        [moviePlayerController setContentURL:theContentURL];
        [moviePlayerController setUseApplicationAudioSession:NO];
        [moviePlayerController prepareToPlay];
    }
    
    
    scrol.hidden = false;
    tagLabel.hidden = false;
    if (_toTokenfield != nil) {
        [_toTokenfield removeFromSuperview];
        _toTokenfield = nil;
    }
    _toTokenfield = [[JSTokenField alloc] initWithFrame:CGRectMake(0, 0, 650, 30)];
    _toTokenfield.contentMode = UIViewContentModeTopLeft;
    [_toTokenfield setBackgroundColor:[UIColor clearColor]];
	[_toTokenfield setDelegate:self];
	[scrol addSubview:_toTokenfield];
    
    scrol.contentSize=CGSizeMake(_toTokenfield.frame.size.width, _toTokenfield.frame.size.height);
    [scrol setScrollsToTop:YES];
    
    [_toGetTagName removeAllObjects];
    
    getContentValue=[welvu_contenttag reterievetagnamefromdb:appDelegate.getDBPath :previousSelectedId];
    
    
    NSMutableArray *getContent=[[NSMutableArray alloc]initWithObjects:getContentValue, nil];
    NSArray *temp =[[getContent lastObject] componentsSeparatedByString:@","];
    for (int i=0; i < temp.count; i++) {
        [_toTokenfield addTokenWithTitle:temp[i] representedObject:self];
        
    }
    lineChart = nil;
}

-(IBAction) blankEditBtnClicked:(id)sender {
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //Release any cached data, images, etc that aren't in use.
}
@end
