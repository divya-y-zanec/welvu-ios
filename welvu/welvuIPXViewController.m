////
//  welvuIPXViewController.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 19/10/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "welvuIPXViewController.h"
#import "welvuContants.h"
#import "welvu_settings.h"
#import "welvu_images.h"
#import "UIImage+Resize.h"
#import <GMGridView.h>
#import <GMGridViewLayoutStrategies.h>
#import "HTTPRequestHandler.h"
#import "welvuSaveIpxViewController.h"
#import "welvu_ipx_images.h"
#import "welvu_ipx_topics.h"
#import "welvu_alerts.h"
//#import "SBJSON.h"
//#import "JSON.h"
#import "GAI.h"
#import "WSLActionSheetAutoDismiss.h"
#import "WSLAlertViewAutoDismiss.h"

@interface welvuIPXViewController () <GMGridViewDataSource, GMGridViewSortingDelegate,
GMGridViewActionDelegate ,GMGridViewLayoutStrategy > {
    NSInteger _lastDeleteItemIndexAsked;
    NSString* previousSelectedId;
    int videoIndex ;
    int playAllVideoIndex;
    BOOL playAllVideo ;
}
@end

@implementation welvuIPXViewController
@synthesize rightIPXGMGridView ,ipxvideoview ,moviePlayerController,myVideosGMGridView ,isSelected;
@synthesize imageData;
@synthesize titleipx,descriptionipx,ipx_id;
@synthesize _rightcurrentData, libTopicTbl, libTaleView;
@synthesize update;
@synthesize title,description,videoid ,bundlePath;
@synthesize displayDescriptionXib,displayLabelXib;
@synthesize ipxRightBanner;
@synthesize themeLogo;
@synthesize teamBtn;
@synthesize myVideosBtn ,sharedVideosBtn, videoLibraryBtn, libraryVideoGMGridView;
@synthesize sharedVideoGMGridView;
@synthesize noContentAvailable, noVideoContent ,searchTimer ,searchTextField;
@synthesize searchText ,searchImage ,deleteBtn;
@synthesize internetReach,hostReach;
@synthesize topFadingView = _topFadingView;
@synthesize bottomFadingView = _bottomFadingView;
@synthesize right_LeftFadingView,right_RightFadingView;
@synthesize offset, responseStrIpxTps, libcurrentTopicIpx;
@synthesize _ptrMyVideos ,deleteAll ,videoidipx,responseStr, removePreVUcontents ;





- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    //[self startPlatformData];
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(IBAction)appHasGoneInBackground1:(id)sender {
    
}

#pragma mark View Life Cycle
/*
 * Method name: viewDidLoad
 * Description: initially load the data
 * Parameters: nil
 * return nil
 
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"iPxImagesListdidlo %@",appDelegate.iPxImagesList);
    //Declaring the page view analytics
    //Declaring Page View Analytics
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"List iPx VU - LIV"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    [self checkForMyAndSharedVideos];
    videoIndex = 0;
    playAllVideoIndex = 0;
    playAllVideo = false;
    previousSelectedId = @"-1";
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[self intializeVideoPreviewContent];
    _rightcurrentData = [[NSMutableArray alloc]init];
    libcurrentTopicIpx = [[NSMutableArray alloc]init];
    title = [[NSMutableArray alloc]init];
    description = [[NSMutableArray alloc]init];
    videoid = [[NSMutableArray alloc]init];
    previewVUContents.layer.borderColor = [UIColor colorWithRed:(9/255.0) green:(54/255.0) blue:(90/255.0) alpha:1].CGColor;
    previewVUContents.layer.borderWidth = 5.0f;
    myVideosBtn.selected = YES;
    if ([appDelegate.iPxImagesList count] == 0) {
        [self startPlatformData];
    }else{
        mediaTab = 100;
       // [self checkForMyAndSharedVideos];
        
        if([ appDelegate.iPxImagesList count] == 0) {
            noContentAvailable.hidden = false;
            
        } else {
            noContentAvailable.hidden = true;
            [self.view bringSubviewToFront:noContentAvailable];
        }
        
        /*if(([responseDictionary count] > 0)|| (iPxImagesList > 0)) {
         noContentAvailable.hidden = true;
         } else {
         noContentAvailable.hidden = false;
         [self.view bringSubviewToFront:noContentAvailable];
         }*/
        [rightIPXGMGridView reloadData];
        rightIPXGMGridView.hidden = false;
        sharedVideoGMGridView.hidden = true;
        [_ptrMyVideos endRefresh];
        if(_ptrMyVideos) {
            [_ptrMyVideos  relocateBottomPullToRefresh];
        }
        
        
    }
    
    
    UITapGestureRecognizer *dtapGestureRecognize = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(doubleTapGestureRecognizer:)];
    dtapGestureRecognize.delegate = self;
    dtapGestureRecognize.numberOfTapsRequired = 1;
    [moviePlayerController.view addGestureRecognizer:dtapGestureRecognize];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    // ipxRightBanner.image = [UIImage imageNamed:@"IPXiPRightPanelWithBanner.png"];
    [self themeSettingsViewControllerDidFinish];
    
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    libTaleView = [[UIView alloc]initWithFrame:CGRectMake(0, 150 , 293, 444)];
    libTaleView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LeftPanelWithoutBanner.png"]];
    
    libTopicTbl = [[UITableView alloc] initWithFrame:CGRectMake(15, 10, 270, 454) style:UITableViewStylePlain];
    libTopicTbl.delegate = self;
    libTopicTbl.dataSource = self;
    libTopicTbl.backgroundColor = [UIColor clearColor];
    [libTopicTbl setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview:libTaleView];
    [libTaleView addSubview:libTopicTbl];
    libTaleView.hidden = true;
    
    
    if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        [teamBtn setImage:[UIImage imageNamed:@"iPxVULib.png"] forState:UIControlStateNormal];
        [sharedVideosBtn setTitle:@"VU Library" forState:UIControlStateNormal];
    }
    else if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU] ||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_HEV])  {
        
        [teamBtn setImage:[UIImage imageNamed:@"teamicon.png"] forState:UIControlStateNormal];
        [sharedVideosBtn setTitle:@"Shared Videos" forState:UIControlStateNormal];
        
    }
     [self.view bringSubviewToFront:myVideosGMGridView];
    [myVideosGMGridView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInBackground1:) name:@"AppDidEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fourDigitPin:)
                                                 name:@"currentViewController"  object: nil];
    
    [self startLockTimer];
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification object: nil];
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    hostReach = [Reachability reachabilityWithHostName:PING_HOST_URL];
    [hostReach startNotifier];
    //[self checkForMyAndSharedVideos];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    
}


-(void)intializeLeftGMGridView {
    
    if(rightIPXGMGridView == nil) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        patientVuGMGrid = [[GMGridView alloc] initWithFrame:CGRectMake(22, 650, 993,102 )];
        patientVuGMGrid.clipsToBounds = YES;
        patientVuGMGrid.alwaysBounceVertical = YES;
        [self.view addSubview:patientVuGMGrid];
        rightIPXGMGridView = patientVuGMGrid;
        rightIPXGMGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal];
        rightIPXGMGridView.style = GMGridViewStylePush;
        rightIPXGMGridView.itemSpacing = 15;
        rightIPXGMGridView.minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        rightIPXGMGridView.centerGrid = NO;
        rightIPXGMGridView.enableEditOnLongPress = NO;
        rightIPXGMGridView.disableEditOnEmptySpaceTap = YES;
        rightIPXGMGridView.delegate = self;
        rightIPXGMGridView.actionDelegate = self;
        rightIPXGMGridView.sortingDelegate = self;
        rightIPXGMGridView.dataSource = self;
        rightIPXGMGridView.mainSuperView = self.view;
    } else {
        //  [self.view bringSubviewToFront:leftIPXGMGridView];
    }
}

/*
 * Method name: intializeGMGridViews
 * Description:initlize gridview to display the thumbnail of images in gmgridview .
 * Parameters: nil
 * return nil
 
 */
-(void)intializeGMGridViews {
    
    
    
    //gmgrid view fro right view.
    if(myVideosGMGridView == nil) {
        
        patientVuGMGrid = [[GMGridView alloc] initWithFrame:CGRectMake(16, 150 , 993, 444)];
        patientVuGMGrid.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        patientVuGMGrid.autoresizesSubviews = YES;
        patientVuGMGrid.clipsToBounds = true;
        patientVuGMGrid.backgroundColor = [UIColor clearColor];
        [self.view addSubview:patientVuGMGrid];
        myVideosGMGridView = patientVuGMGrid;
        
        myVideosGMGridView.style = GMGridViewStylePush;
        myVideosGMGridView.clipsToBounds = true;
        myVideosGMGridView.itemSpacing = 15;
        myVideosGMGridView.minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        myVideosGMGridView.centerGrid = NO;
        myVideosGMGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
        myVideosGMGridView.enableEditOnLongPress = NO;
        myVideosGMGridView.disableEditOnEmptySpaceTap = YES;
        myVideosGMGridView.delegate = self;
        myVideosGMGridView.actionDelegate = self;
        myVideosGMGridView.sortingDelegate = self;
        myVideosGMGridView.dataSource = self;
        myVideosGMGridView.mainSuperView = self.view;
        
        // rightIPXGMGridView.mainSuperView = self.view;
        myVideosGMGridView.contentSize = CGSizeMake(230, THUMB_IMAGE_HEIGHT);
    }
    
    
    
    if(searchImage && searchText) {
        searchText.hidden = true;
        searchImage.hidden = true;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if(_ptrMyVideos == nil && ![bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        
        _ptrMyVideos = [[CustomPullToRefresh alloc] initWithScrollView:myVideosGMGridView
                                                              delegate:self
                                                                 isTop:true isBot:true ];
        
        
    }
    
}

-(void)intializesharedVideosGMGridViews {
    
    if(searchImage == nil && searchText == nil) {
        searchImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 150, 271, 41)];
        searchImage.image=[UIImage imageNamed:@"search-box.png"];
        searchImage.userInteractionEnabled = YES;
        searchText =[[UITextField alloc]initWithFrame:CGRectMake(40, 8, 225, 30)];
        searchText.borderStyle=UITextBorderStyleNone;
        searchText.clearButtonMode = UITextFieldViewModeAlways;
        searchText.placeholder = @"Search VU Library";
        searchText.text = searchTextField;
        searchText.delegate=self;
        searchText.userInteractionEnabled=YES;
        [searchText setTextAlignment:UITextAlignmentCenter];
        [searchText addTarget:self action:@selector(searchTimerEvent) forControlEvents:UIControlEventEditingChanged];
        [searchImage addSubview:searchText];
        [self.view addSubview:searchImage];
        
    } else {
        searchText.hidden = true;
        searchImage.hidden = true;
    }
    [self.view bringSubviewToFront:searchImage];
    if(sharedVideoGMGridView == nil) {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        sharedVideoView = [[GMGridView alloc] initWithFrame:CGRectMake(16, 150 , 993, 444)];
        sharedVideoView.clipsToBounds = YES;
        sharedVideoView.alwaysBounceVertical = YES;
        [self.view addSubview:sharedVideoView];
        sharedVideoGMGridView = sharedVideoView;
        sharedVideoGMGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
        sharedVideoGMGridView.style = GMGridViewStylePush;
        sharedVideoGMGridView.itemSpacing = 15;
         sharedVideoGMGridView.clipsToBounds = true;
        sharedVideoGMGridView.minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        sharedVideoGMGridView.centerGrid = NO;
        sharedVideoGMGridView.enableEditOnLongPress = YES;
        sharedVideoGMGridView.disableEditOnEmptySpaceTap = YES;
        sharedVideoGMGridView.delegate = self;
        sharedVideoGMGridView.actionDelegate = self;
        sharedVideoGMGridView.sortingDelegate = self;
        sharedVideoGMGridView.dataSource = self;
        sharedVideoGMGridView.mainSuperView = self.view;
        sharedVideoView.contentSize = CGSizeMake(230, THUMB_IMAGE_HEIGHT);
        
    } else {
        //[self.view bringSubviewToFront:leftsharedVideoGMGridView];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if(_ptr == nil && ![bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        
        _ptr = [[CustomPullToRefresh alloc] initWithScrollView:sharedVideoGMGridView
                                                      delegate:self
                                                         isTop:true isBot:true ];
        
        
    }
}
-(void)intializeLibVideosGMGridViews {
    
    //gmgrid view fro right view.
    if(libraryVideoGMGridView == nil) {
        libTopicTbl.hidden =  NO;
        [self.view bringSubviewToFront:libTopicTbl];
        
        patientVuGMGrid = [[GMGridView alloc] initWithFrame:CGRectMake(309, 150 , 890, 444)];
        patientVuGMGrid.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        patientVuGMGrid.autoresizesSubviews = YES;
        patientVuGMGrid.clipsToBounds = YES;
        patientVuGMGrid.backgroundColor = [UIColor clearColor];
        [self.view addSubview:patientVuGMGrid];
        libraryVideoGMGridView = patientVuGMGrid;
        
        libraryVideoGMGridView.style = GMGridViewStylePush;
        libraryVideoGMGridView.itemSpacing = 15;
        libraryVideoGMGridView.clipsToBounds = true;
        libraryVideoGMGridView.minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        libraryVideoGMGridView.centerGrid = NO;
        libraryVideoGMGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
        libraryVideoGMGridView.enableEditOnLongPress = NO;
        libraryVideoGMGridView.disableEditOnEmptySpaceTap = YES;
        libraryVideoGMGridView.delegate = self;
        libraryVideoGMGridView.actionDelegate = self;
        libraryVideoGMGridView.sortingDelegate = self;
        libraryVideoGMGridView.dataSource = self;
        libraryVideoGMGridView.mainSuperView = self.view;
        libraryVideoGMGridView.contentSize = CGSizeMake(230, THUMB_IMAGE_HEIGHT);

        // rightIPXGMGridView.mainSuperView = self.view;
    }
    
    
    
    if(searchImage && searchText) {
        searchText.hidden = true;
        searchImage.hidden = true;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if(_ptrMyVideos == nil && ![bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        
        _ptrMyVideos = [[CustomPullToRefresh alloc] initWithScrollView:libraryVideoGMGridView
                                                              delegate:self
                                                                 isTop:true isBot:true ];
        
        
    }
    
}

#pragma mark Shared Videos
/*
 * Method name: getSharedVideosFromPlatform
 * Description: get Shared videos from Platform
 * Parameters: nil
 * return nil
 */
-(void)getSharedVideosFromPlatform {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    // ipxRightBanner.image = [UIImage imageNamed:@"IPXiPXRightPanelWithBanner"];
    [self themeSettingsViewControllerDidFinish];
    
    if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        offset = 0;
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view
                                                                :NSLocalizedString(@"PLEASE_WAIT_DOWNLOADING_IPX_VIDEOS", nil;)];
        }
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.networkReachable) {
            
            appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            
            NSLog(@"expires in %@",appDelegate.welvu_userModel.oauth_expires_in);
            NSLog(@"current date in %@",appDelegate.welvu_userModel.oauth_currentDate);
            
            //date comparision start
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmt];
            [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
            NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
            
            NSDate *dateFromString = [[NSDate alloc] init];
            dateFromString = [dateFormatter dateFromString:timeStamp];
            
            
            
            NSDate *currentGmtDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
            NSLog(@"currentGmtDate%@",currentGmtDate);
            
            
            
            NSDate *expiresdatefromstring = [[NSDate alloc] init];
            expiresdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_expires_in];
            
            
            NSDate *oauth_expiresIn = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:expiresdatefromstring]];
            NSLog(@"oauth_expiresIn%@",oauth_expiresIn);
            
            //currentdb date
            
            NSDate *currentdatefromstring = [[NSDate alloc] init];
            currentdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_currentDate];
            
            
            // NSLog(@"dateFromString%@",dateFromString);
            NSDate *oauth_currenrDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:currentdatefromstring]];
            
            NSLog(@"oauth_currenrDate%@",oauth_currenrDate);
            
            
            NSComparisonResult startCompare = [oauth_expiresIn compare: currentGmtDate];
            NSComparisonResult endCompare = [oauth_currenrDate compare: currentGmtDate];
            NSLog(@"startcompare %d",startCompare);
            NSLog(@"end compare %d",endCompare);
            
            if(startCompare == NSOrderedAscending  && endCompare == NSOrderedAscending){
                
                
                [appDelegate oauthRefreshAccessToken];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self getOrganizationIpx];
                    
                    
                    
                    
                });
            }else {
                [self getOrganizationIpx];
            }
            
            
        } else {
            WSLAlertViewAutoDismiss* networkAlert = [[WSLAlertViewAutoDismiss alloc]
                                                     initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                     message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                     delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
            [networkAlert show];
            
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            
            
        }
    }
    
    else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        offset = 0;
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view
                                                                :NSLocalizedString(@"PLEASE_WAIT_DOWNLOADING_IPX_VIDEOS", nil;)];
        }
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.networkReachable) {
            
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            NSString *accessToken = nil;
            if(appDelegate.welvu_userModel.access_token == nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            } else {
                accessToken = appDelegate.welvu_userModel.access_token;
            }
            
            
            if([BoxSDK sharedSDK].OAuth2Session.accessToken != nil) {
                appDelegate.welvu_userModel.box_access_token = [BoxSDK sharedSDK].OAuth2Session.accessToken;
                appDelegate.welvu_userModel.box_refresh_access_token= [BoxSDK sharedSDK].OAuth2Session.refreshToken;
                appDelegate.welvu_userModel.box_expires_in =  [BoxSDK sharedSDK].OAuth2Session.accessTokenExpiration;
                [welvu_user updateBoxAccessToken:[appDelegate getDBPath] :appDelegate.welvu_userModel];
            }
            
            
            NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                          [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                          accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                          [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                          appDelegate.welvu_userModel.box_access_token ,HTTP_RESPONSE_BOX_ACCESSTOKEN_KEY,
                                          appDelegate.welvu_userModel.box_refresh_access_token ,HTTP_RESPONSE_BOX_REFRESH_ACCESSTOKEN_KEY,
                                          appDelegate.welvu_userModel.box_expires_in ,HTTP_RESPONSE_BOX_EXPIRES_IN,
                                          
                                          searchTextField ,@"q",
                                          nil];
            
            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
            if(appDelegate.welvu_userModel.org_id > 0) {
                [requestDataMutable
                 setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                 forKey:HTTP_REQUEST_ORGANISATION_KEY];
            }
            
            HTTPRequestHandler *requestHandler = nil;
            requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                              :PLATFORM_HOST_URL :PLATFORM_GET_BOX_IPX_LIBRARY:HTTP_METHOD_POST
                              :requestDataMutable :nil];
            requestHandler.delegate = self;
            [requestHandler makeHTTPRequest];
            
            
        } else {
            WSLAlertViewAutoDismiss* networkAlert = [[WSLAlertViewAutoDismiss alloc]
                                                     initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                     message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                     delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
            [networkAlert show];
            
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            
            
        }
    }
    else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]) {
        
        offset = 0;
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view
                                                                :NSLocalizedString(@"PLEASE_WAIT_DOWNLOADING_IPX_VIDEOS", nil;)];
        }
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.networkReachable) {
            
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            NSString *accessToken = nil;
            if(appDelegate.welvu_userModel.access_token == nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            } else {
                accessToken = appDelegate.welvu_userModel.access_token;
            }
            
            NSNumber *offsetNumber = [NSNumber numberWithInteger:0];
            
            NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                          [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                          accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                          offsetNumber ,HTTP_RESPONSE_IPX_OFFSET_KEY,
                                          searchTextField ,@"q",
                                          nil];
            
            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
            if(appDelegate.welvu_userModel.org_id > 0) {
                [requestDataMutable
                 setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                 forKey:HTTP_REQUEST_ORGANISATION_KEY];
            }
            
            HTTPRequestHandler *requestHandler = nil;
            requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                              :PLATFORM_HOST_URL :PLATFORM_GET_ORGANIZATION_INFORMATION_PRESCRIPTION:HTTP_METHOD_POST
                              :requestDataMutable :nil];
            requestHandler.delegate = self;
            [requestHandler makeHTTPRequest];
            
            
        }
        
        
        else {
            WSLAlertViewAutoDismiss* networkAlert = [[WSLAlertViewAutoDismiss alloc]
                                                     initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                     message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                     delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
            [networkAlert show];
            
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            
        }
    }
}

-(void)getLibraryVideosFromPlatform :(NSInteger)libSpcltId{
    
    
    
    offset = 0;
    if(spinner == nil) {
        spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view
                                                            :NSLocalizedString(@"PLEASE_WAIT_DOWNLOADING_IPX_VIDEOS", nil;)];
    }
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.networkReachable) {
        
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        
        NSLog(@"expires in %@",appDelegate.welvu_userModel.oauth_expires_in);
        NSLog(@"current date in %@",appDelegate.welvu_userModel.oauth_currentDate);
        
        //date comparision start
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [dateFormatter setTimeZone:gmt];
        [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
        NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
        
        NSDate *dateFromString = [[NSDate alloc] init];
        dateFromString = [dateFormatter dateFromString:timeStamp];
        
        
        
        NSDate *currentGmtDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
        NSLog(@"currentGmtDate%@",currentGmtDate);
        
        
        
        NSDate *expiresdatefromstring = [[NSDate alloc] init];
        expiresdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_expires_in];
        
        
        NSDate *oauth_expiresIn = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:expiresdatefromstring]];
        NSLog(@"oauth_expiresIn%@",oauth_expiresIn);
        
        //currentdb date
        
        NSDate *currentdatefromstring = [[NSDate alloc] init];
        currentdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_currentDate];
        
        
        // NSLog(@"dateFromString%@",dateFromString);
        NSDate *oauth_currenrDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:currentdatefromstring]];
        
        NSLog(@"oauth_currenrDate%@",oauth_currenrDate);
        
        
        NSComparisonResult startCompare = [oauth_expiresIn compare: currentGmtDate];
        NSComparisonResult endCompare = [oauth_currenrDate compare: currentGmtDate];
        NSLog(@"startcompare %d",startCompare);
        NSLog(@"end compare %d",endCompare);
        
        if(startCompare == NSOrderedAscending  && endCompare == NSOrderedAscending){
            
            
            [appDelegate oauthRefreshAccessToken];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self getLibraryIpx:libSpcltId];
                
                
                
                
            });
        }else {
            [self getLibraryIpx:libSpcltId];
        }
        
        
    } else {
        WSLAlertViewAutoDismiss* networkAlert = [[WSLAlertViewAutoDismiss alloc]
                                                 initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                 message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                 delegate:self
                                                 cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
        [networkAlert show];
        
        if(spinner != nil) {
            [spinner removeSpinner];
            spinner = nil;
        }
        
        
    }
    
    
}


/*
 * Method name: getSharedVideosFromPlatform
 * Description: Get shared video rom platofrom using offset values
 * Parameters: lastVideoId ,searchTextField ,offsetVideo
 * return nil
 */
-(void)getSharedVideosFromPlatform:(NSInteger)offsetVideo :(NSString *)lastVideoId :(NSString *)searchTextField {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    // NSLog(@"search text %@",searchTextField);
    /*if(spinner == nil) {
     spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view
     :NSLocalizedString(@"PLEASE_WAIT_DOWNLOADING_IPX_VIDEOS", nil;)];
     } */
    if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        if(appDelegate.networkReachable) {
            
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            NSString *accessToken = nil;
            if(appDelegate.welvu_userModel.access_token == nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            } else {
                accessToken = appDelegate.welvu_userModel.access_token;
            }
            appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            
            NSLog(@"expires in %@",appDelegate.welvu_userModel.oauth_expires_in);
            NSLog(@"current date in %@",appDelegate.welvu_userModel.oauth_currentDate);
            
            //date comparision start
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmt];
            [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
            NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
            
            NSDate *dateFromString = [[NSDate alloc] init];
            dateFromString = [dateFormatter dateFromString:timeStamp];
            
            
            
            NSDate *currentGmtDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
            NSLog(@"currentGmtDate%@",currentGmtDate);
            
            
            
            NSDate *expiresdatefromstring = [[NSDate alloc] init];
            expiresdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_expires_in];
            
            
            NSDate *oauth_expiresIn = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:expiresdatefromstring]];
            NSLog(@"oauth_expiresIn%@",oauth_expiresIn);
            
            //currentdb date
            
            NSDate *currentdatefromstring = [[NSDate alloc] init];
            currentdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_currentDate];
            
            
            // NSLog(@"dateFromString%@",dateFromString);
            NSDate *oauth_currenrDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:currentdatefromstring]];
            
            NSLog(@"oauth_currenrDate%@",oauth_currenrDate);
            
            
            NSComparisonResult startCompare = [oauth_expiresIn compare: currentGmtDate];
            NSComparisonResult endCompare = [oauth_currenrDate compare: currentGmtDate];
            NSLog(@"startcompare %d",startCompare);
            NSLog(@"end compare %d",endCompare);
            
            if(startCompare == NSOrderedAscending  && endCompare == NSOrderedAscending){
                
                
                [appDelegate oauthRefreshAccessToken];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    NSString *searchtext = [NSString stringWithFormat:@"&q=%@",searchTextField];
                    NSLog(@"searchtext %@",searchtext);
                    
                    NSString *lastvideoId1 = [NSString stringWithFormat:@"&lastid=%@",lastVideoId];
                    NSLog(@"lastvideoId1 %@",lastvideoId1);
                    
                    
                    NSNumber *offsetNumber = [NSNumber numberWithInteger:offsetVideo];
                    
                    
                    
                    
                    NSString *offset = [NSString stringWithFormat:@"&offset=%@",offsetNumber];
                    NSLog(@"offset %@",offset);
                    
                    
                    NSString *getString = [NSString stringWithFormat:@"organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
                    NSLog(@"get string %@",getString);
                    
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@",PLATFORM_GET_OAUTH_ORGANIZATION_IPX_URL, getString,lastvideoId1,searchtext,offset]];
                    
                    NSLog(@"get string %@",url);
                    /* NSString *getString = [NSString stringWithFormat:@"HTTP_SPECIALTY_ID=%@",[NSNumber numberWithInteger:specialtyId]];
                     NSLog(@"get string %@",getString);*/
                    
                    
                    NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
                    
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
                    
                    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
                    
                    [request setHTTPMethod:HTTP_METHOD_GET];
                    
                    getOrganizationIpx =
                    [[NSURLConnection alloc] initWithRequest:request delegate:self];
                    
                    [getOrganizationIpx start];
                    
                    
                    
                    
                    
                });
            }
            
            
            else {
                
                NSString *searchtext = [NSString stringWithFormat:@"&q=%@",searchTextField];
                NSLog(@"searchtext %@",searchtext);
                
                NSString *lastvideoId1 = [NSString stringWithFormat:@"&lastid=%@",lastVideoId];
                NSLog(@"lastvideoId1 %@",lastvideoId1);
                
                
                NSNumber *offsetNumber = [NSNumber numberWithInteger:offsetVideo];
                
                
                
                
                NSString *offset = [NSString stringWithFormat:@"&offset=%@",offsetNumber];
                NSLog(@"offset %@",offset);
                
                
                NSString *getString = [NSString stringWithFormat:@"organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
                NSLog(@"get string %@",getString);
                
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@",PLATFORM_GET_OAUTH_ORGANIZATION_IPX_URL, getString,lastvideoId1,searchtext,offset]];
                
                NSLog(@"get string %@",url);
                /* NSString *getString = [NSString stringWithFormat:@"HTTP_SPECIALTY_ID=%@",[NSNumber numberWithInteger:specialtyId]];
                 NSLog(@"get string %@",getString);*/
                
                
                NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
                
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
                
                [request setHTTPMethod:HTTP_METHOD_GET];
                
                getOrganizationIpx =
                [[NSURLConnection alloc] initWithRequest:request delegate:self];
                
                [getOrganizationIpx start];
                
                
            }
            
            
        }else {
            WSLAlertViewAutoDismiss* networkAlert = [[WSLAlertViewAutoDismiss alloc]
                                                     initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                     message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                     delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
            [networkAlert show];
            
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            
        }
        
    } else {
        if(appDelegate.networkReachable) {
            
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            NSString *accessToken = nil;
            if(appDelegate.welvu_userModel.access_token == nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            } else {
                accessToken = appDelegate.welvu_userModel.access_token;
            }
            
            NSNumber *offsetNumber = [NSNumber numberWithInteger:offsetVideo];
            
            NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                          [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                          accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                          offsetNumber ,HTTP_RESPONSE_IPX_OFFSET_KEY,
                                          lastVideoId,ALERT_IPX_LASTVIDEO_ID,
                                          searchTextField ,@"q",
                                          nil];
            
            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
            if(appDelegate.welvu_userModel.org_id > 0) {
                [requestDataMutable
                 setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                 forKey:HTTP_REQUEST_ORGANISATION_KEY];
            }
            
            HTTPRequestHandler *requestHandler = nil;
            requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                              :PLATFORM_HOST_URL :PLATFORM_GET_ORGANIZATION_INFORMATION_PRESCRIPTION:HTTP_METHOD_POST
                              :requestDataMutable :nil];
            requestHandler.delegate = self;
            [requestHandler makeHTTPRequest];
            
            
        }else {
            WSLAlertViewAutoDismiss* networkAlert = [[WSLAlertViewAutoDismiss alloc]
                                                     initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                     message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                     delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
            [networkAlert show];
            
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            
        }
        
    }
    
}

/*
 * Method name: getSharedVideosFromPlatform
 * Description: Get shared video rom platofrom using offset values
 * Parameters: lastVideoId ,searchTextField ,offsetVideo
 * return nil
 */
-(void)getLibraryVideosFromPlatform:(NSInteger)offsetVideo :(NSString *)lastVideoId :(NSString *)searchTextField {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    // NSLog(@"search text %@",searchTextField);
    /*if(spinner == nil) {
     spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view
     :NSLocalizedString(@"PLEASE_WAIT_DOWNLOADING_IPX_VIDEOS", nil;)];
     } */
    if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        if(appDelegate.networkReachable) {
            
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            NSString *accessToken = nil;
            if(appDelegate.welvu_userModel.access_token == nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            } else {
                accessToken = appDelegate.welvu_userModel.access_token;
            }
            appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            
            NSLog(@"expires in %@",appDelegate.welvu_userModel.oauth_expires_in);
            NSLog(@"current date in %@",appDelegate.welvu_userModel.oauth_currentDate);
            
            //date comparision start
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmt];
            [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
            NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
            
            NSDate *dateFromString = [[NSDate alloc] init];
            dateFromString = [dateFormatter dateFromString:timeStamp];
            
            
            
            NSDate *currentGmtDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
            NSLog(@"currentGmtDate%@",currentGmtDate);
            
            
            
            NSDate *expiresdatefromstring = [[NSDate alloc] init];
            expiresdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_expires_in];
            
            
            NSDate *oauth_expiresIn = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:expiresdatefromstring]];
            NSLog(@"oauth_expiresIn%@",oauth_expiresIn);
            
            //currentdb date
            
            NSDate *currentdatefromstring = [[NSDate alloc] init];
            currentdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_currentDate];
            
            
            // NSLog(@"dateFromString%@",dateFromString);
            NSDate *oauth_currenrDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:currentdatefromstring]];
            
            NSLog(@"oauth_currenrDate%@",oauth_currenrDate);
            
            
            NSComparisonResult startCompare = [oauth_expiresIn compare: currentGmtDate];
            NSComparisonResult endCompare = [oauth_currenrDate compare: currentGmtDate];
            NSLog(@"startcompare %d",startCompare);
            NSLog(@"end compare %d",endCompare);
            
            if(startCompare == NSOrderedAscending  && endCompare == NSOrderedAscending){
                
                
                [appDelegate oauthRefreshAccessToken];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    NSString *searchtext = [NSString stringWithFormat:@"&q=%@",searchTextField];
                    NSLog(@"searchtext %@",searchtext);
                    
                    NSString *lastvideoId1 = [NSString stringWithFormat:@"&lastid=%@",lastVideoId];
                    NSLog(@"lastvideoId1 %@",lastvideoId1);
                    
                    
                    NSNumber *offsetNumber = [NSNumber numberWithInteger:offsetVideo];
                    
                    
                    
                    
                    NSString *offset = [NSString stringWithFormat:@"&offset=%@",offsetNumber];
                    NSLog(@"offset %@",offset);
                    
                    
                    NSString *getString = [NSString stringWithFormat:@"organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
                    NSLog(@"get string %@",getString);
                    
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@",PLATFORM_GET_OAUTH_ORGANIZATION_IPX_URL, getString,lastvideoId1,searchtext,offset]];
                    
                    NSLog(@"get string %@",url);
                    /* NSString *getString = [NSString stringWithFormat:@"HTTP_SPECIALTY_ID=%@",[NSNumber numberWithInteger:specialtyId]];
                     NSLog(@"get string %@",getString);*/
                    
                    
                    NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
                    
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
                    
                    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
                    
                    [request setHTTPMethod:HTTP_METHOD_GET];
                    
                    getOrganizationIpx =
                    [[NSURLConnection alloc] initWithRequest:request delegate:self];
                    
                    [getOrganizationIpx start];
                    
                    
                    
                    
                    
                });
            }
            
            
            else {
                
                NSString *searchtext = [NSString stringWithFormat:@"&q=%@",searchTextField];
                NSLog(@"searchtext %@",searchtext);
                
                NSString *lastvideoId1 = [NSString stringWithFormat:@"&lastid=%@",lastVideoId];
                NSLog(@"lastvideoId1 %@",lastvideoId1);
                
                
                NSNumber *offsetNumber = [NSNumber numberWithInteger:offsetVideo];
                
                
                
                
                NSString *offset = [NSString stringWithFormat:@"&offset=%@",offsetNumber];
                NSLog(@"offset %@",offset);
                
                
                NSString *getString = [NSString stringWithFormat:@"organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
                NSLog(@"get string %@",getString);
                
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@",PLATFORM_GET_OAUTH_ORGANIZATION_IPX_URL, getString,lastvideoId1,searchtext,offset]];
                
                NSLog(@"get string %@",url);
                /* NSString *getString = [NSString stringWithFormat:@"HTTP_SPECIALTY_ID=%@",[NSNumber numberWithInteger:specialtyId]];
                 NSLog(@"get string %@",getString);*/
                
                
                NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
                
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
                
                [request setHTTPMethod:HTTP_METHOD_GET];
                
                getOrganizationIpx =
                [[NSURLConnection alloc] initWithRequest:request delegate:self];
                
                [getOrganizationIpx start];
                
                
            }
            
            
        }else {
            WSLAlertViewAutoDismiss* networkAlert = [[WSLAlertViewAutoDismiss alloc]
                                                     initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                     message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                     delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
            [networkAlert show];
            
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            
        }
        
    } else {
        if(appDelegate.networkReachable) {
            
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            NSString *accessToken = nil;
            if(appDelegate.welvu_userModel.access_token == nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            } else {
                accessToken = appDelegate.welvu_userModel.access_token;
            }
            
            NSNumber *offsetNumber = [NSNumber numberWithInteger:offsetVideo];
            
            NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                          [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                          accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                          offsetNumber ,HTTP_RESPONSE_IPX_OFFSET_KEY,
                                          lastVideoId,ALERT_IPX_LASTVIDEO_ID,
                                          searchTextField ,@"q",
                                          nil];
            
            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
            if(appDelegate.welvu_userModel.org_id > 0) {
                [requestDataMutable
                 setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                 forKey:HTTP_REQUEST_ORGANISATION_KEY];
            }
            
            HTTPRequestHandler *requestHandler = nil;
            requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                              :PLATFORM_HOST_URL :PLATFORM_GET_ORGANIZATION_INFORMATION_PRESCRIPTION:HTTP_METHOD_POST
                              :requestDataMutable :nil];
            requestHandler.delegate = self;
            [requestHandler makeHTTPRequest];
            
            
        }else {
            WSLAlertViewAutoDismiss* networkAlert = [[WSLAlertViewAutoDismiss alloc]
                                                     initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                     message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                     delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
            [networkAlert show];
            
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            
        }
        
    }
    
}
#pragma mark MYVideos

/*
 * Method name: startPlatformData
 * Description: To get iPx videos from platform .
 * Parameters: nil
 * return nil
 
 */
-(void)startPlatformData {
    
    if(spinner == nil) {
        spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view
                                                            :NSLocalizedString(@"PLEASE_WAIT_DOWNLOADING_IPX_VIDEOS", nil;)];
    }
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    mediaTab = 100;
    if(appDelegate.networkReachable) {
        
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        NSString *accessToken = nil;
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        
        
        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
            
            NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                          [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                          nil];
            
            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
            HTTPRequestHandler *requestHandler = nil;
            [requestDataMutable
             setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
             forKey:HTTP_REQUEST_ORGANISATION_KEY];
            requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                              :PLATFORM_HOST_URL1 :PLATFORM_GET_INFORMATION_PRESCRIPTION:HTTP_METHOD_GET
                              :requestDataMutable :nil];
            requestHandler.delegate = self;
            [requestHandler makeHTTPRequest];
        } else if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
            
            NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                          [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                          accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,nil];
            
            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
            HTTPRequestHandler *requestHandler = nil;
            if([BoxSDK sharedSDK].OAuth2Session.accessToken != nil) {
                appDelegate.welvu_userModel.box_access_token = [BoxSDK sharedSDK].OAuth2Session.accessToken;
                appDelegate.welvu_userModel.box_refresh_access_token= [BoxSDK sharedSDK].OAuth2Session.refreshToken;
                appDelegate.welvu_userModel.box_expires_in =  [BoxSDK sharedSDK].OAuth2Session.accessTokenExpiration;
                [welvu_user updateBoxAccessToken:[appDelegate getDBPath] :appDelegate.welvu_userModel];
            }
            
            [requestDataMutable setObject:accessToken forKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            [requestDataMutable setObject: [[NSBundle mainBundle] bundleIdentifier] forKey:HTTP_REQUEST_APP_IDENTIFIER_KEY];
            [requestDataMutable setObject: appDelegate.welvu_userModel.box_access_token forKey:HTTP_RESPONSE_BOX_ACCESSTOKEN_KEY];
            [requestDataMutable setObject: appDelegate.welvu_userModel.box_refresh_access_token forKey:HTTP_RESPONSE_BOX_REFRESH_ACCESSTOKEN_KEY];
            [requestDataMutable setObject: appDelegate.welvu_userModel.box_expires_in forKey:HTTP_RESPONSE_BOX_EXPIRES_IN];
            requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                              :PLATFORM_HOST_URL :PLATFORM_GET_BOX_IPX:HTTP_METHOD_POST
                              :requestDataMutable :nil];
            requestHandler.delegate = self;
            [requestHandler makeHTTPRequest];
        }
    } else {
        WSLAlertViewAutoDismiss* networkAlert = [[WSLAlertViewAutoDismiss alloc]
                                                 initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                 message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                 delegate:self
                                                 cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
        [networkAlert show];
        
        if(spinner != nil) {
            [spinner removeSpinner];
            spinner = nil;
        }
        
    }
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    if(appDelegate.welvu_userModel.org_id > 0) {
        mediaTab = 100;
    }
}
/*
 * Method name: startPlatformData
 * Description: get ipx videos from platform using offset and video to display
 * Parameters: lastVideoId ,offsetVideo
 * return ni
 */
-(void)startPlatformData:(NSInteger)offsetVideo :(NSString *)lastVideoId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if(spinner == nil) {
        spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view
                                                            :NSLocalizedString(@"PLEASE_WAIT_DOWNLOADING_IPX_VIDEOS", nil;)];
    }
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.networkReachable) {
        
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        NSString *accessToken = nil;
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        if( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
            
            NSNumber *offsetNumber = [NSNumber numberWithInteger:offsetVideo];
            NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                          [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                          
                                          offsetNumber ,HTTP_RESPONSE_IPX_OFFSET_KEY,
                                          lastVideoId,ALERT_IPX_LASTVIDEO_ID,nil];
            
            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
            if(appDelegate.welvu_userModel.org_id > 0) {
                [requestDataMutable
                 setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                 forKey:HTTP_REQUEST_ORGANISATION_KEY];
            }
            
            HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                  :PLATFORM_HOST_URL1 :PLATFORM_GET_INFORMATION_PRESCRIPTION:HTTP_METHOD_GET
                                                  :requestDataMutable :nil];
            requestHandler.delegate = self;
            [requestHandler makeHTTPRequest];
        } else {
            
            
            NSNumber *offsetNumber = [NSNumber numberWithInteger:offsetVideo];
            NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                          [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                          accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                          offsetNumber ,HTTP_RESPONSE_IPX_OFFSET_KEY,
                                          lastVideoId,ALERT_IPX_LASTVIDEO_ID,nil];
            
            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
            if(appDelegate.welvu_userModel.org_id > 0) {
                [requestDataMutable
                 setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                 forKey:HTTP_REQUEST_ORGANISATION_KEY];
            }
            
            HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                  :PLATFORM_HOST_URL :PLATFORM_GET_INFORMATION_PRESCRIPTION:HTTP_METHOD_POST
                                                  :requestDataMutable :nil];
            requestHandler.delegate = self;
            [requestHandler makeHTTPRequest];
            
            
        }
    }else {
        WSLAlertViewAutoDismiss* networkAlert = [[WSLAlertViewAutoDismiss alloc]
                                                 initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                 message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                 delegate:self
                                                 cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
        [networkAlert show];
        
        if(spinner != nil) {
            [spinner removeSpinner];
            spinner = nil;
        }
        
    }
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    if(appDelegate.welvu_userModel.org_id > 0) {
        mediaTab = 100;
    }
}
#pragma mark mpmovie player controller
/*
 * Method name: intializeVideoPreviewContent
 * Description:To initlize the mpmovie player controller to play video .
 * Parameters: nil
 * return nil
 
 */
- (void)intializeVideoPreviewContent  {
    moviePlayerController = [[MPMoviePlayerController alloc] init];
    [moviePlayerController setAllowsAirPlay:NO];
    // [moviePlayerController setControlStyle:MPMovieControlStyleEmbedded];
    [moviePlayerController setEndPlaybackTime:-1];
    [moviePlayerController setInitialPlaybackTime:-1];
    [moviePlayerController setMovieSourceType:MPMovieSourceTypeUnknown];
    [moviePlayerController setRepeatMode:MPMovieRepeatModeNone];
    [moviePlayerController setScalingMode:MPMovieScalingModeAspectFit];
    [moviePlayerController setShouldAutoplay:NO];
    [moviePlayerController setUseApplicationAudioSession:NO];
    // [moviePlayerController setControlStyle:MPMovieRepeatModeNone];
    // moviePlayerController.shouldAutoplay = YES;
    [moviePlayerController setControlStyle:MPMovieControlStyleEmbedded];
    // moviePlayerController.movieControlMode = MPMovieControlModeHidden;
    
    [moviePlayerController.view setFrame:CGRectMake(5, 5, (previewVUContents.frame.size.width - 10), (previewVUContents.frame.size.height- 10))];
    [previewVUContents addSubview:moviePlayerController.view];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoQueue)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayerController];
    [previewVUContentParent bringSubviewToFront:removePreVUcontents];
    
    
}

- (void)playVideoQueue {
    if(playAllVideo) {
        if(_rightcurrentData != nil
           && (((([_rightcurrentData count] - 1) > playAllVideoIndex) && mediaTab == 100)
               || ((([_rightcurrentData count] - 1) >= playAllVideoIndex) && mediaTab == 101)
               || ((([_rightcurrentData count] - 1) >= playAllVideoIndex) && mediaTab == 102)))
        {
            welvu_ipx_images *welvu_ipxModel = [_rightcurrentData objectAtIndex:playAllVideoIndex];
            
            if(videoIndex == 0 || (videoIndex > 0
                                   && ![welvu_ipxModel.ipx_Org_VideoDetails isKindOfClass:[NSNull class]]
                                   && welvu_ipxModel.ipx_Org_VideoDetails != nil
                                   && !([welvu_ipxModel.ipx_Org_VideoDetails count] > videoIndex))) {
                videoIndex = 0;
                playAllVideoIndex ++;
                welvu_ipxModel = nil;
                
            }
            
            if(([_rightcurrentData count] - 1) >= playAllVideoIndex) {
                
                welvu_ipxModel = [_rightcurrentData objectAtIndex:playAllVideoIndex];
                
                if(![welvu_ipxModel.ipx_Org_VideoDetails isKindOfClass:[NSNull class]]
                   && welvu_ipxModel.ipx_Org_VideoDetails != nil) {
                    if([welvu_ipxModel.ipx_Org_VideoDetails count] > videoIndex) {
                        
                        displayLabelXib.text =welvu_ipxModel.ipx_image_display_name;
                        displayDescriptionXib.text = welvu_ipxModel.ipx_image_display_name;
                        NSDictionary *videoObject = [welvu_ipxModel.ipx_Org_VideoDetails objectAtIndex:videoIndex];
                        NSURL *myurl= [NSURL URLWithString:welvu_ipxModel.platform_video_url];
                        [moviePlayerController setContentURL:myurl];
                        [moviePlayerController play];
                        videoIndex++;
                        [self unselectPreviousSelectedImage];
                        GMGridViewCell *previousCell = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:playAllVideoIndex];
                        for(UIView *subview in [previousCell.contentView subviews]) {
                            if ([subview isKindOfClass:[UIImageView class]]) {
                                UIImageView *imageView = (UIImageView *)subview;
                                imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                                   makeRoundCornerImage:5 :5];
                            }
                        }
                        
                        welvu_ipxModel.selected = YES;
                        welvu_ipxModel.pickedToView = YES;
                        previousCell.isSelected = true;
                        
                        
                        previousSelectedId = [NSString stringWithFormat: @"%d", welvu_ipxModel.iPx_images_id]; ;
                        
                        
                    }
                }  else if(![welvu_ipxModel.ipx_VideoUrl
                             isKindOfClass:[NSNull class]]
                           && welvu_ipxModel.ipx_VideoUrl != nil) {
                    
                    [self unselectPreviousSelectedImage];
                    GMGridViewCell *previousCell = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:playAllVideoIndex];
                    for(UIView *subview in [previousCell.contentView subviews]) {
                        if ([subview isKindOfClass:[UIImageView class]]) {
                            UIImageView *imageView = (UIImageView *)subview;
                            imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                               makeRoundCornerImage:5 :5];
                        }
                    }
                    // welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:playAllVideoIndex];
                    welvu_ipxModel.selected = YES;
                    welvu_ipxModel.pickedToView = YES;
                    previousCell.isSelected = true;
                    previousSelectedId = [NSString stringWithFormat: @"%d", welvu_ipxModel.iPx_images_id];
                    videoIndex = 0;
                    displayLabelXib.text =welvu_ipxModel.ipx_image_display_name;
                    displayDescriptionXib.text = welvu_ipxModel.ipx_image_info;
                    NSURL *myurl= [NSURL URLWithString:welvu_ipxModel.ipx_VideoUrl];
                    [moviePlayerController setContentURL:myurl];
                    [moviePlayerController play];
                    
                }
            } else if( _rightcurrentData != nil) {
                [self resetPlayAll];
            }
        } else if (_rightcurrentData != nil) {
            [self resetPlayAll];
        }
        
    } else  {
        welvu_ipx_images *welvu_ipxModel = [_rightcurrentData objectAtIndex:currentSelection];
        if(![welvu_ipxModel.ipx_Org_VideoDetails isKindOfClass:[NSNull class]]
           && welvu_ipxModel.ipx_Org_VideoDetails != nil) {
            if(([welvu_ipxModel.ipx_Org_VideoDetails count] - 1) > videoIndex) {
                videoIndex++;
                NSDictionary *videoObject = [welvu_ipxModel.ipx_Org_VideoDetails objectAtIndex:videoIndex];
                NSURL *myurl= [NSURL URLWithString:[videoObject objectForKey:@"videourl"]];
                [moviePlayerController setContentURL:myurl];
                [moviePlayerController play];
                
            } else {
                videoIndex = 0;
                NSDictionary *videoObject = [welvu_ipxModel.ipx_Org_VideoDetails objectAtIndex:videoIndex];
                NSURL *myurl= [NSURL URLWithString:[videoObject objectForKey:@"videourl"]];
                [moviePlayerController setContentURL:myurl];
                [moviePlayerController prepareToPlay];
            }
        }
    }
}

-(void) resetPlayAll {
    [self unselectPreviousSelectedImage];
    videoIndex = 0;
    playAllVideoIndex = 0;
    NSURL *myurl = [self playAlliPxContentFirstVideo];
    if(moviePlayerController == nil) {
        [self intializeVideoPreviewContent];
    }
    
    if(myurl != nil) {
        [moviePlayerController setContentURL:myurl];
        [moviePlayerController prepareToPlay];
    }
    videoIndex = 0;
    playAllVideoIndex = 0;
}

- (void) playbackStateChanged {
    switch (moviePlayerController.playbackState) {
        case MPMoviePlaybackStatePaused:{
            NSLog(@"paused");
        }
            break;
        case MPMoviePlaybackStatePlaying:{
            NSLog(@"playing");
            //[moviePlayerController setFullscreen:YES animated:YES];
        }
            break;
            
        case MPMoviePlaybackStateSeekingForward:{
            NSLog(@"forward");
            
            
        }
            break;
        case MPMoviePlaybackStateSeekingBackward:{
            NSLog(@"backward");
            
        }
            break;
            
        case MPMoviePlaybackStateStopped:{
            NSLog(@"stopped");
            
        }
            break;
        case MPMoviePlaybackStateInterrupted:{
            NSLog(@"interuupted");
            
        }
            break;
            
        default:
            break;
    }
    
    
}

-(void)playiPxVideo {
    [self unselectPreviousSelectedImage];
    // NSLog(@"current data %d" ,[_rightcurrentData count]);
    //NSLog(@"current data %@" ,_rightcurrentData);
    
    playAllVideoIndex = 0;
    if([_rightcurrentData count] > 0) {
        playAllVideo = true;
        NSURL *myurl = [self playAlliPxContentFirstVideo];
        if(moviePlayerController == nil) {
            [self intializeVideoPreviewContent];
        }
        
        if(myurl != nil) {
            [moviePlayerController setContentURL:myurl];
            [moviePlayerController play];
        }
    }
}

-(NSURL *) playAlliPxContentFirstVideo {
   // [self.view sendSubviewToBack:myVideosGMGridView];
    [self.view bringSubviewToFront:previewVUContents];
    [self.view bringSubviewToFront:previewVUContentParent];
    NSURL *myurl =nil;
    if([_rightcurrentData count] > 0) {
        welvu_ipx_images *welvu_ipxModel = [_rightcurrentData objectAtIndex:0];
        previousSelectedId = [NSString stringWithFormat: @"%d", welvu_ipxModel.iPx_images_id];
        welvu_ipxModel.pickedToView = true;
        displayLabelXib.text =welvu_ipxModel.ipx_image_display_name;
        displayDescriptionXib.text = welvu_ipxModel.ipx_image_info;
        
        
        
        
        if ([welvu_ipxModel.ipx_image_thumbnail isKindOfClass:[NSNull class]]
            || [welvu_ipxModel.ipx_image_thumbnail isEqualToString:@""]) {
            [self removeVideoPreviewContent];
            noVideoContent.image = [UIImage imageNamed:@"video-being-processed.png"];
            noVideoContent.hidden = false;
        } else {
            noVideoContent.hidden = true;
        }
        
        
        if(![welvu_ipxModel.ipx_image_thumbnail isKindOfClass:[NSNull class]]
           && ![welvu_ipxModel.ipx_image_thumbnail isEqualToString:@""]
           && welvu_ipxModel.ipx_VideoUrl  == nil) {
            videoIndex++;
           
            NSDictionary *videoObject = [welvu_ipxModel.ipx_Org_VideoDetails objectAtIndex:0];
            myurl= [NSURL URLWithString:[videoObject objectForKey:@"videourl"]];
            
        } else if(![welvu_ipxModel.ipx_image_thumbnail isKindOfClass:[NSNull class]]
                  && ![welvu_ipxModel.ipx_image_thumbnail isEqualToString:@""]
                  && welvu_ipxModel.ipx_VideoUrl  != nil){
            NSLog(@"welvu_ipxModel.ipx_VideoUrl %@", welvu_ipxModel.ipx_VideoUrl);
            myurl= [NSURL URLWithString:welvu_ipxModel.ipx_VideoUrl];
            
        }
        GMGridViewCell *previousCell = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:0];
        for(UIView *subview in [previousCell.contentView subviews]) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)subview;
                imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                   makeRoundCornerImage:5 :5];
            }
        }
        
        welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
        welvu_imagesModel.selected = YES;
        welvu_imagesModel.pickedToView = YES;
        previousCell.isSelected = true;
        
    }
    return myurl;
}
/*
 * Method name: removeVideoPreviewContent
 * Description:To remove the video preview content fron the view .
 * Parameters: nil
 * return nil
 
 */
- (void)removeVideoPreviewContent {
    deleteBtn.enabled = NO;
    deleteAll.enabled = NO;
    playAll.enabled = NO;
    teamBtn.enabled = NO;
    shareBtn.enabled = NO;
    rightIPXGMGridView.hidden = NO;
     previewVUContents.hidden = YES;
    previewVUContentParent.hidden = YES;
    removePreVUcontents.hidden= YES;
    if (mediaTab == 100) {
        myVideosGMGridView.hidden = NO;
        libraryVideoGMGridView.hidden = YES;
        sharedVideoGMGridView.hidden = YES;
        
    }else if (mediaTab == 101) {
        myVideosGMGridView.hidden = YES;
        libraryVideoGMGridView.hidden = YES;
        sharedVideoGMGridView.hidden = NO;
        
    }else if (mediaTab == 102) {
        myVideosGMGridView.hidden = YES;
        libraryVideoGMGridView.hidden = NO;
        sharedVideoGMGridView.hidden = YES;
        
    }
    displayDescriptionXib.text = nil;
    displayLabelXib.text = nil;
    if(moviePlayerController != nil ) {
        [moviePlayerController.view removeFromSuperview];
        moviePlayerController = nil;
    }
}


/*
 * Method name: searchTimerEvent
 * Description: Search event timer trigger.
 * Parameters: nil
 * Return Type: void
 */
-(void) searchTimerEvent  {
    
    
    noVideoContent.hidden = true;
    
    // previousSelectedId = @"-1";
    if(_rightcurrentData == nil || [_rightcurrentData count] == 0) {
        shareBtn.enabled = false;
    }
    teamBtn.hidden = YES;
    searchTextField = searchText.text;
    if(searchTimer != nil) {
        [searchTimer invalidate];
    }
    
    searchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(searchSharedVideos)
                                                 userInfo:nil
                                                  repeats:NO];
    
}
/*
 * Method name: searchSharedVideos
 * Description: search the shared videos by keyword
 * Parameters: nil
 * return nil
 */
-(void)searchSharedVideos {
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        offset = 0;
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view
                                                                :NSLocalizedString(@"PLEASE_WAIT_DOWNLOADING_IPX_VIDEOS", nil;)];
        }
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.networkReachable) {
            
            appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            
            NSLog(@"expires in %@",appDelegate.welvu_userModel.oauth_expires_in);
            NSLog(@"current date in %@",appDelegate.welvu_userModel.oauth_currentDate);
            
            //date comparision start
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmt];
            [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
            NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
            
            NSDate *dateFromString = [[NSDate alloc] init];
            dateFromString = [dateFormatter dateFromString:timeStamp];
            
            
            
            NSDate *currentGmtDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
            NSLog(@"currentGmtDate%@",currentGmtDate);
            
            
            
            NSDate *expiresdatefromstring = [[NSDate alloc] init];
            expiresdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_expires_in];
            
            
            NSDate *oauth_expiresIn = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:expiresdatefromstring]];
            NSLog(@"oauth_expiresIn%@",oauth_expiresIn);
            
            //currentdb date
            
            NSDate *currentdatefromstring = [[NSDate alloc] init];
            currentdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_currentDate];
            
            
            // NSLog(@"dateFromString%@",dateFromString);
            NSDate *oauth_currenrDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:currentdatefromstring]];
            
            NSLog(@"oauth_currenrDate%@",oauth_currenrDate);
            
            
            NSComparisonResult startCompare = [oauth_expiresIn compare: currentGmtDate];
            NSComparisonResult endCompare = [oauth_currenrDate compare: currentGmtDate];
            NSLog(@"startcompare %d",startCompare);
            NSLog(@"end compare %d",endCompare);
            
            if(startCompare == NSOrderedAscending  && endCompare == NSOrderedAscending){
                
                
                [appDelegate oauthRefreshAccessToken];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    
                    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                    
                    
                    NSString *searchtext = [NSString stringWithFormat:@"&q=%@",searchTextField];
                    NSLog(@"searchtext %@",searchtext);
                    
                    
                    NSString *getString = [NSString stringWithFormat:@"organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
                    NSLog(@"get string %@",getString);
                    
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",PLATFORM_GET_OAUTH_ORGANIZATION_IPX_URL, getString,searchtext]];
                    
                    NSLog(@"get string %@",url);
                    /* NSString *getString = [NSString stringWithFormat:@"HTTP_SPECIALTY_ID=%@",[NSNumber numberWithInteger:specialtyId]];
                     NSLog(@"get string %@",getString);*/
                    
                    
                    NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
                    
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
                    
                    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
                    
                    [request setHTTPMethod:HTTP_METHOD_GET];
                    
                    getOrganizationIpx =
                    [[NSURLConnection alloc] initWithRequest:request delegate:self];
                    
                    [getOrganizationIpx start];
                    
                    
                });
            }
            
            
            else {
                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                
                
                NSString *searchtext = [NSString stringWithFormat:@"&q=%@",searchTextField];
                NSLog(@"searchtext %@",searchtext);
                
                
                NSString *getString = [NSString stringWithFormat:@"organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
                NSLog(@"get string %@",getString);
                
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",PLATFORM_GET_OAUTH_ORGANIZATION_IPX_URL, getString,searchtext]];
                
                NSLog(@"get string %@",url);
                /* NSString *getString = [NSString stringWithFormat:@"HTTP_SPECIALTY_ID=%@",[NSNumber numberWithInteger:specialtyId]];
                 NSLog(@"get string %@",getString);*/
                
                
                NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
                
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
                
                [request setHTTPMethod:HTTP_METHOD_GET];
                
                getOrganizationIpx =
                [[NSURLConnection alloc] initWithRequest:request delegate:self];
                
                [getOrganizationIpx start];
                
            }
        } WSLAlertViewAutoDismiss* networkAlert = [[WSLAlertViewAutoDismiss alloc]
                                                   initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                   message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                   delegate:self
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
        [networkAlert show];
        
    }else if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        
        offset = 0;
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view
                                                                :NSLocalizedString(@"PLEASE_WAIT_DOWNLOADING_IPX_VIDEOS", nil;)];
        }
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.networkReachable) {
            
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            NSString *accessToken = nil;
            if(appDelegate.welvu_userModel.access_token == nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            } else {
                accessToken = appDelegate.welvu_userModel.access_token;
            }
            
            
            if([BoxSDK sharedSDK].OAuth2Session.accessToken != nil) {
                appDelegate.welvu_userModel.box_access_token = [BoxSDK sharedSDK].OAuth2Session.accessToken;
                appDelegate.welvu_userModel.box_refresh_access_token= [BoxSDK sharedSDK].OAuth2Session.refreshToken;
                appDelegate.welvu_userModel.box_expires_in =  [BoxSDK sharedSDK].OAuth2Session.accessTokenExpiration;
                [welvu_user updateBoxAccessToken:[appDelegate getDBPath] :appDelegate.welvu_userModel];
            }
            
            
            NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                          [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                          accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                          [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                          appDelegate.welvu_userModel.box_access_token ,HTTP_RESPONSE_BOX_ACCESSTOKEN_KEY,
                                          appDelegate.welvu_userModel.box_refresh_access_token ,HTTP_RESPONSE_BOX_REFRESH_ACCESSTOKEN_KEY,
                                          appDelegate.welvu_userModel.box_expires_in ,HTTP_RESPONSE_BOX_EXPIRES_IN,
                                          
                                          searchTextField ,@"q",
                                          nil];
            
            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
            if(appDelegate.welvu_userModel.org_id > 0) {
                [requestDataMutable
                 setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                 forKey:HTTP_REQUEST_ORGANISATION_KEY];
            }
            
            HTTPRequestHandler *requestHandler = nil;
            requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                              :PLATFORM_HOST_URL :PLATFORM_GET_BOX_IPX_LIBRARY:HTTP_METHOD_POST
                              :requestDataMutable :nil];
            requestHandler.delegate = self;
            [requestHandler makeHTTPRequest];
            
            
        }
        else {
            WSLAlertViewAutoDismiss* networkAlert = [[WSLAlertViewAutoDismiss alloc]
                                                     initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                     message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                     delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
            [networkAlert show];
            
            
        }
    } else {
        //[iPxImagesList removeAllObjects];
        offset = 0;
        [sharedVideoGMGridView reloadData];
        // [rightIPXGMGridView reloadData];
        
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.networkReachable) {
            
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            NSString *accessToken = nil;
            if(appDelegate.welvu_userModel.access_token == nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            } else {
                accessToken = appDelegate.welvu_userModel.access_token;
            }
            
            
            NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                          [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                          accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                          searchTextField ,@"q",
                                          nil];
            
            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
            if(appDelegate.welvu_userModel.org_id > 0) {
                [requestDataMutable
                 setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                 forKey:HTTP_REQUEST_ORGANISATION_KEY];
            }
            
            HTTPRequestHandler *requestHandler = nil;
            requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                              :PLATFORM_HOST_URL :PLATFORM_GET_ORGANIZATION_INFORMATION_PRESCRIPTION:HTTP_METHOD_POST
                              :requestDataMutable :nil];
            requestHandler.delegate = self;
            [requestHandler makeHTTPRequest];
            
            
            
        }
        else {
            WSLAlertViewAutoDismiss* networkAlert = [[WSLAlertViewAutoDismiss alloc]
                                                     initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                     message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                     delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
            [networkAlert show];
            
            
        }
    }
}
//Rechability change
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
- (void)doubleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"gestire %@" ,gestureRecognizer);
    NSLog(@"%s", __FUNCTION__);
}



#pragma mark Action Methods

-(IBAction)moviePlayerCloseBtn:(id)sender{
    [moviePlayerController stop];
    removePreVUcontents.hidden= YES;
    previewVUContents.hidden = YES;
    previewVUContentParent.hidden = YES;
    if (mediaTab == 100) {
        
        [self.view bringSubviewToFront:myVideosGMGridView];
        myVideosGMGridView.hidden = NO;
        libraryVideoGMGridView.hidden = YES;
        sharedVideoGMGridView.hidden = YES;
        
    }else if (mediaTab == 101) {
        myVideosGMGridView.hidden = YES;
        libraryVideoGMGridView.hidden = YES;
        sharedVideoGMGridView.hidden = NO;
        
    }else if (mediaTab == 102) {
        myVideosGMGridView.hidden = YES;
        libraryVideoGMGridView.hidden = NO;
        sharedVideoGMGridView.hidden = YES;
        
    }
    
    
}
/*
 * Method name: playiPxBtnClicked
 * Description: to play the ipx video using mpmovie player controller
 * Parameters: id
 * return value :IBAction
 */
-(IBAction)playiPxBtnClicked:(id)sender {
    
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"ListiPx VU - LIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ListiPx VU - LIV"
                                                          action:@"PlayAll Button  - LIV"
                                                           label:@"Play All"
                                                           value:nil] build]];
    
    
    
    
    @try {
        previewVUContents.hidden = false;
        previewVUContentParent.hidden = false;
        removePreVUcontents.hidden= false;
        [self unselectPreviousSelectedImage];
        //  NSLog(@"current data %d" ,[_rightcurrentData count]);
        //NSLog(@"current data %@" ,_rightcurrentData);
        
        playAllVideoIndex = 0;
        if([_rightcurrentData count] > 0) {
            playAllVideo = true;
            NSURL *myurl = [self playAlliPxContentFirstVideo];
            if(moviePlayerController == nil) {
                [self intializeVideoPreviewContent];
            }
            
            if(myurl != nil) {
                [moviePlayerController setContentURL:myurl];
                [moviePlayerController play];
            }
        }
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ListiPx VU - LIV_Play all %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}


/*
 * Method name: backBtnClicked
 * Description: navigating to previous view
 * Parameters: id
 * return IBAction
 */
-(IBAction)backBtnClicked:(id)sender {
    
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"ListiPx VU - LIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ListiPx VU - LIV"
                                                          action:@"Back Button  - LIV"
                                                           label:@"Back"
                                                           value:nil] build]];
    
    
    
    
    @try {
        NSLog(@"iPxImagesListback %@",appDelegate.iPxImagesList);
        
        [self.delegate welvuIPXDidFinish:YES];
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ListiPx VU - LIV_Back %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

/*
 * Method name: shareBtnClicked
 * Description: to share the list of ipx videos in the deck
 * Parameters: id
 * return IBAction
 */
-(IBAction)shareBtnClicked:(id)sender {
    
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"ListiPx VU - LIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ListiPx VU - LIV"
                                                          action:@"Share Button  - LIV"
                                                           label:@"Share"
                                                           value:nil] build]];
    
    
    
    
    @try {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.networkReachable) {
            if(![welvu_alerts canAlertShowAgain:appDelegate.getDBPath :ALERT_PUSHING_TO_IPX]) {
                WSLAlertViewAutoDismiss* alert = [[WSLAlertViewAutoDismiss alloc]
                                                  initWithTitle: NSLocalizedString(@"ALERT_PUSHING_TO_IPX", nil)
                                                  message: NSLocalizedString(@"ALERT_HIPPA_INFO_MSG", nil)
                                                  delegate: self
                                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                  otherButtonTitles:NSLocalizedString(@"DONT_SHOW_AGAIN", nil), NSLocalizedString(@"CONTINUE", nil),nil];
                alert.delegate = self;
                [alert show];
            }
            else {
                
                [self shareiPxData];
                
                
            }
            
        } else {
            WSLAlertViewAutoDismiss* myAlert = [[WSLAlertViewAutoDismiss alloc]
                                                initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [myAlert show];    }
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ListiPx VU - LIV_share %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

/*
 * Method name: myVideosBtnClicked
 * Description: To get my ipx videos from platform
 * Parameters: id
 * return IBAction
 */
-(IBAction)myVideosBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"ListiPx VU - LIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ListiPx VU - LIV"
                                                          action:@"MyVideos Button  - LIV"
                                                           label:@"MyVideos"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        [searchText resignFirstResponder];
        [self.view bringSubviewToFront:myVideosGMGridView];
        UIButton *button = (UIButton *)sender;
        myVideosBtn.selected = true;
        sharedVideosBtn.selected = false;
        videoLibraryBtn.selected = false;
        libTaleView.hidden = true;
        
        if ([appDelegate.iPxImagesList count] == 0) {
            [self startPlatformData];
        }else{
            mediaTab = 100;
            
            if([ appDelegate.iPxImagesList count] == 0) {
                noContentAvailable.hidden = false;
                
            } else {
                noContentAvailable.hidden = true;
                [self.view bringSubviewToFront:myVideosGMGridView];
            }
            
            [rightIPXGMGridView reloadData];
            rightIPXGMGridView.hidden = false;
            sharedVideoGMGridView.hidden = true;
            [_ptrMyVideos endRefresh];
            if(_ptrMyVideos) {
                [_ptrMyVideos  relocateBottomPullToRefresh];
            }
            
            
        }
        
        
        //[self removeVideoPreviewContent];
        sharedVideoGMGridView.editing = NO;
        // leftsharedVideoGMGridView.hidden = YES;
        noVideoContent.hidden = true;
        mediaTab = button.tag;
        shareBtn.enabled = false;
        teamBtn.enabled = false;
        deleteBtn.enabled = false;
        deleteAll.enabled = false;
        playAll.enabled = false;
        previousSelectedId = @"-1";
        teamBtn.hidden = NO;
        displayDescriptionXib.hidden = YES;
        displayLabelXib.hidden = YES;
        [moviePlayerController.view removeFromSuperview];
        //[iPxImagesList removeAllObjects];
        [_rightcurrentData removeAllObjects];
        //NSLog(@"iPxImagesList %@",appDelegate.iPxImagesList);
        myVideosGMGridView.hidden = NO;
        libraryVideoGMGridView.hidden = YES;
        sharedVideoGMGridView.hidden = YES;
        [myVideosGMGridView reloadData];
        searchImage.hidden = true;
        searchText.hidden = true;
        [self clearAllBtnClicked:self];
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ListiPx VU - LIV_MyVideos %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

/*
 * Method name: sharedVideosBtnClicked
 * Description: To get shared ipx videos from platform
 * Parameters: id
 * return IBAction
 */
-(IBAction)sharedVideosBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"ListiPx VU - LIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ListiPx VU - LIV"
                                                          action:@"SharedVideos Button  - LIV"
                                                           label:@"SharedVideos"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
        myVideosBtn.selected = false;
        sharedVideosBtn.selected = true;
        videoLibraryBtn.selected = false;
        libTaleView.hidden = true;
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([appDelegate.ipxOrgImagesList count] == 0) {
            
            [self getSharedVideosFromPlatform];
        }else{
            mediaTab = 101;
             
            if([ appDelegate.ipxOrgImagesList count] == 0) {
                noContentAvailable.hidden = false;
                
            } else {
                noContentAvailable.hidden = true;
                [self.view bringSubviewToFront:noContentAvailable];
            }
            
            [sharedVideoGMGridView reloadData];
            sharedVideoGMGridView.hidden = false;
            rightIPXGMGridView.hidden = false;
            [_ptr endRefresh];
            if(_ptr) {
                [_ptr  relocateBottomPullToRefresh];
            }
        }
        NSLog(@"iPxImagesList %@",appDelegate.iPxImagesList);
        UIButton *button = (UIButton *)sender;
        [self removeVideoPreviewContent];
        searchText.text = @"";
        searchTextField = @"";
        rightIPXGMGridView.editing = NO;
        mediaTab =  button.tag;
        noVideoContent.hidden = true;
        searchImage.hidden = true;
        searchText.hidden = true;
        previousSelectedId = @"-1";
        deleteBtn.enabled = false;
        deleteAll.enabled = false;
        playAll.enabled = false;
        shareBtn.enabled = false;
        teamBtn.hidden = YES;
        displayDescriptionXib.hidden = YES;
        displayLabelXib.hidden = YES;
        [moviePlayerController.view removeFromSuperview];
        //[iPxImagesList removeAllObjects];
        [_rightcurrentData removeAllObjects];
        [rightIPXGMGridView reloadData];
        myVideosGMGridView.hidden = YES;
        libraryVideoGMGridView.hidden = YES;
        sharedVideoGMGridView.hidden = NO;
        [sharedVideoGMGridView reloadData];
        NSLog(@"iPxImagesList1 %@",appDelegate.iPxImagesList);
         [self clearAllBtnClicked:self];
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ListiPx VU - LIV_SharedVideos %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

/*
 * Method name: videoLibraryBtnClicked
 * Description: To get shared ipx videos from platform
 * Parameters: id
 * return IBAction
 */

-(IBAction)videoLibraryBtnClicked:(id)sender{
    //Declaring EventTrackiing Analytics
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"ListiPx VU - LIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ListiPx VU - LIV"
                                                          action:@"SharedVideos Button  - LIV"
                                                           label:@"SharedVideos"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
         
        
        if ([appDelegate.iPxLibTopicList count] == 0){
            [self getLibraryIpxTopicList];
        }
        myVideosBtn.selected = false;
        sharedVideosBtn.selected = false;
        videoLibraryBtn.selected = true;
        libTaleView.hidden = false;
        libraryVideoGMGridView.hidden = false;
        UIButton *button = (UIButton *)sender;
        
        [self removeVideoPreviewContent];
        searchText.text = @"";
        searchTextField = @"";
        rightIPXGMGridView.editing = NO;
        mediaTab =  button.tag;
        noVideoContent.hidden = true;
        searchImage.hidden = true;
        searchText.hidden = true;
        previousSelectedId = @"-1";
        deleteBtn.enabled = false;
        deleteAll.enabled = false;
        playAll.enabled = false;
        
        shareBtn.enabled = false;
        teamBtn.hidden = YES;
        displayDescriptionXib.hidden = YES;
        displayLabelXib.hidden = YES;
        [moviePlayerController.view removeFromSuperview];
        
        //[iPxImagesList removeAllObjects];
        [_rightcurrentData removeAllObjects];
        [rightIPXGMGridView reloadData];
        myVideosGMGridView.hidden = YES;
        libraryVideoGMGridView.hidden = NO;
        sharedVideoGMGridView.hidden = YES;
        [libraryVideoGMGridView reloadData];
        [self clearAllBtnClicked:self];
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ListiPx VU - LIV_SharedVideos %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}




//unselect the previous selected image
- (void) unselectPreviousSelectedImage {
    
    if (![previousSelectedId isEqualToString:@"-1"] || [previousSelectedId isEqual:[NSNull null]] ) {
        
        NSInteger myInt = [previousSelectedId intValue];
        NSInteger index =  [self searchImageGroups:myInt :_rightcurrentData];
        
        NSLog(@"index %d",index);
        GMGridViewCell *previousCell = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:index];
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
        NSLog(@"index %d",index);
        welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:index];
        welvu_imagesModel.pickedToView = NO;
    }
    
}
-(void)welvuShareIPXVideoDidFinish:(BOOL)isModified {
    
    if(isModified) {
        
        [self dismissModalViewControllerAnimated:YES];
        
    }
}

-(void)IPXViewControllerWillFinish:(BOOL)isFinished {
    if(isFinished) {
        [self dismissModalViewControllerAnimated:YES];
    }
}

-(void)welvuIPXDidFinish:(BOOL)isModified {
    if(isModified) {
        [self dismissModalViewControllerAnimated:YES];
        
    }
}

int currentSelection = -1;

- (void)setPreviewImageInView:(NSInteger )position {
    
    moviePlayerController.backgroundView.backgroundColor  = [UIColor clearColor];
    currentSelection = position;
    int videoIndex = 0;
    displayDescriptionXib.hidden = NO;
    displayLabelXib.hidden = NO;
    
    if (moviePlayerController != nil) {
        [moviePlayerController stop];
        [moviePlayerController.view removeFromSuperview];
        moviePlayerController = nil;
    }
    CGSize destinationSize = CGSizeMake(IMAGE_VIEW_WIDTH, IMAGE_VIEW_HEIGHT);
    
    if(moviePlayerController == nil) {
        //[self intializeVideoPreviewContent];
    }
    
    welvu_ipx_images *welvu_ipxModel = [_rightcurrentData objectAtIndex:currentSelection];
    previousSelectedId = [NSString stringWithFormat: @"%d", welvu_ipxModel.iPx_images_id];
    welvu_ipxModel.pickedToView = true;
    displayLabelXib.text =welvu_ipxModel.ipx_image_display_name;
    displayDescriptionXib.text = welvu_ipxModel.ipx_image_info;
    NSURL *myurl =nil;
    if ([welvu_ipxModel.ipx_image_thumbnail isKindOfClass:[NSNull class]]
        || [welvu_ipxModel.ipx_image_thumbnail isEqualToString:@""]) {
        //NSString *urlString = [NSString stringWithFormat:@"%@", @"video-being-processed.png"];
        //myurl= [NSURL URLWithString:urlString];
        noVideoContent.image = [UIImage imageNamed:@"video-being-processed.png"];
        noVideoContent.hidden = false;
    } else {
        noVideoContent.hidden = true;
    }
    
    
    if(![welvu_ipxModel.ipx_image_thumbnail isKindOfClass:[NSNull class]]
       && ![welvu_ipxModel.ipx_image_thumbnail isEqualToString:@""]
       && welvu_ipxModel.ipx_VideoUrl  == nil) {
        
        NSDictionary *videoObject = [welvu_ipxModel.ipx_Org_VideoDetails objectAtIndex:0];
        myurl= [NSURL URLWithString:[videoObject objectForKey:@"videourl"]];
        
    } else if(![welvu_ipxModel.ipx_image_thumbnail isKindOfClass:[NSNull class]]
              && ![welvu_ipxModel.ipx_image_thumbnail isEqualToString:@""]
              && welvu_ipxModel.ipx_VideoUrl  != nil){
        
        myurl= [NSURL URLWithString:welvu_ipxModel.ipx_VideoUrl];
        
    }
    
    GMGridViewCell *previousCell = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:position];
    for(UIView *subview in [previousCell.contentView subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)subview;
            imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                               makeRoundCornerImage:5 :5];
        }
    }
    
    previousCell.isSelected = true;
    if(myurl != nil) {
        moviePlayerController.movieSourceType = MPMovieSourceTypeUnknown;
        [moviePlayerController setContentURL:myurl];
        [moviePlayerController setUseApplicationAudioSession:NO];
        [moviePlayerController prepareToPlay];
        self.moviePlayerController = moviePlayerController;
    }
}
-(NSInteger) searchImageGroups:(NSInteger) imgId:(NSMutableArray *) imagesArray {
    NSLog(@"imagesArray.count %d",imagesArray.count);
    for(int i=0; i < imagesArray.count; i++) {
        welvu_ipx_images *img = [imagesArray objectAtIndex:i];
        
        if(img.iPx_images_id == imgId) {
            return i;
        }
    }
    return -1;
}




/*
 * Method name: welvuShareIpxVideoDidCancel
 * Description: while cancel the sharevu
 * Parameters: nil
 * return nil
 */
-(void)welvuShareIpxVideoDidCancel {
    [self dismissModalViewControllerAnimated:YES];
    
}

/*
 * Method name: syncBtnClicked
 * Description: to get all my videos /shared videos from platform
 * Parameters: id
 * return IBAction
 */
-(IBAction)syncBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"ListiPx VU - LIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ListiPx VU - LIV"
                                                          action:@"Sync Button  - LIV"
                                                           label:@"sync"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
        
        if(appDelegate.networkReachable) {
            self.rightIPXGMGridView.editing = NO;
            deleteBtn.enabled= false;
            deleteBtn.selected=NO;
            deleteAll.enabled= false;
            deleteAll.selected=NO;
            playAll.enabled= false;
            playAll.selected=NO;
            myVideosGMGridView.editing = false;
            if(mediaTab == 100) {
                previousSelectedId = @"-1";
                deleteBtn.enabled = false;
                deleteAll.enabled = false;
                playAll.enabled = false;
                noVideoContent.hidden = true;
                displayDescriptionXib.hidden = YES;
                displayLabelXib.hidden = YES;
                [moviePlayerController.view removeFromSuperview];
                 [appDelegate.iPxImagesList removeAllObjects];
                [_rightcurrentData removeAllObjects];
                if (!appDelegate.iPxImagesList == nil) {
                    [self startPlatformData];
                }
                [myVideosGMGridView reloadData];
                [rightIPXGMGridView setContentOffset:CGPointZero animated:YES];
                [rightIPXGMGridView reloadData];
            } else if (mediaTab == 101) {
                searchText.text = @"";
                searchTextField = @"";
                previousSelectedId = @"-1";
                deleteBtn.enabled = false;
                deleteAll.enabled = false;
                playAll.enabled = false;
                noVideoContent.hidden = true;
                
                displayDescriptionXib.hidden = YES;
                displayLabelXib.hidden = YES;
                [moviePlayerController.view removeFromSuperview];
                
                 [appDelegate.ipxOrgImagesList removeAllObjects];
                [_rightcurrentData removeAllObjects];
                [self getSharedVideosFromPlatform];
                // [leftIPXGMGridView reloadData];
                [myVideosGMGridView reloadData];
                [sharedVideoGMGridView setContentOffset:CGPointZero animated:YES];
                [sharedVideoGMGridView reloadData];
            }else if (mediaTab == 102) {
                searchText.text = @"";
                searchTextField = @"";
                previousSelectedId = @"-1";
                deleteBtn.enabled = false;
                deleteAll.enabled = false;
                playAll.enabled = false;
                noVideoContent.hidden = true;
                
                displayDescriptionXib.hidden = YES;
                displayLabelXib.hidden = YES;
                [moviePlayerController.view removeFromSuperview];
                
                // [iPxImagesList removeAllObjects];
                [appDelegate.iPxLibTopicList removeAllObjects];
                [appDelegate.iPxLibImagesList removeAllObjects];
                [self getLibraryIpxTopicList];
                // [leftIPXGMGridView reloadData];
                [libraryVideoGMGridView reloadData];
                [libraryVideoGMGridView setContentOffset:CGPointZero animated:YES];
                [libraryVideoGMGridView reloadData];
            } else {
                if (!appDelegate.iPxImagesList == nil) {
                    [self startPlatformData];
                }
                [myVideosGMGridView reloadData];
                
            }
        } else {
            
            WSLAlertViewAutoDismiss* networkAlert = [[WSLAlertViewAutoDismiss alloc]
                                                     initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                     message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                     delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
            [networkAlert show];
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ListiPx VU - LIV_Sync %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

- (void)themeSettingsViewControllerDidFinish {
    
    
    
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




/*
 * Method name: teamShareBtnClicked
 * Description: To  shared ipx videos from to Shared videos
 * Parameters: id
 * return IBAction
 */
-(IBAction)teamShareBtnClicked:(id)sender {
    
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"ListiPx VU - LIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ListiPx VU - LIV"
                                                          action:@"TeamShare Button  - LIV"
                                                           label:@"Team"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        
        
        if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
            WSLAlertViewAutoDismiss* topicName = [[WSLAlertViewAutoDismiss alloc] initWithTitle:NSLocalizedString(@"ALERT_PUSHING_IPX_TO_TEAM", nil)
                                                                                        message:NSLocalizedString(@"ALERT_SHARE_IPX_VIDEO_TO_VU_LIBRARY", nil)
                                                                                       delegate:self
                                                                              cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                                                              otherButtonTitles:NSLocalizedString(@"YES", nil) , nil];
            
            [topicName setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [topicName show];
            [[topicName textFieldAtIndex:0] setPlaceholder:NSLocalizedString(@"PLACEHOLDER_ENTER_TAG_NAME", nil)];
            
        }
        else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]) {
            
            if(appDelegate.networkReachable) {
                
                WSLAlertViewAutoDismiss* alert = [[WSLAlertViewAutoDismiss alloc]
                                                  initWithTitle: NSLocalizedString(@"ALERT_PUSHING_IPX_TO_TEAM", nil)
                                                  message: NSLocalizedString(@"ALERT_SHARE_IPX_VIDEO_TO_TEAM", nil)
                                                  delegate: self
                                                  cancelButtonTitle:NSLocalizedString(@"YES", nil)
                                                  otherButtonTitles:NSLocalizedString(@"NO", nil) , nil];
                
                alert.delegate = self;
                [alert show];
                
            }
        }else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
            
            if(appDelegate.networkReachable) {
                
                WSLAlertViewAutoDismiss* alert = [[WSLAlertViewAutoDismiss alloc]
                                                  initWithTitle: NSLocalizedString(@"ALERT_PUSHING_IPX_TO_TEAM", nil)
                                                  message: NSLocalizedString(@"ALERT_SHARE_IPX_VIDEO_TO_TEAM", nil)
                                                  delegate: self
                                                  cancelButtonTitle:NSLocalizedString(@"YES", nil)
                                                  otherButtonTitles:NSLocalizedString(@"NO", nil) , nil];
                
                alert.delegate = self;
                [alert show];
                
            }
        }
        
        
        else {
            WSLAlertViewAutoDismiss* networkAlert = [[WSLAlertViewAutoDismiss alloc]
                                                     initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                     message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                     delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
            [networkAlert show];
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ListiPx VU - LIV_Team %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

-(void) getRecentIPX {
    //[self intializeLeftGMGridView];
    
    if(mediaTab == 100) {
        [appDelegate.iPxImagesList removeAllObjects];
        offset = 0;
        if (!appDelegate.iPxImagesList == nil) {
            [self startPlatformData];
        }
        [myVideosGMGridView reloadData];
        
    } else if (mediaTab == 101) {
        [appDelegate.ipxOrgImagesList removeAllObjects];
        offset = 0;
        [self getSharedVideosFromPlatform];
        [sharedVideoGMGridView reloadData];
    }else if (mediaTab == 102) {
        /*[appDelegate removeAllObjects];
        offset = 0;
        [self getLibraryVideosFromPlatform:appDelegate.lastSelectedIpxTopicId];
        
        [libraryVideoGMGridView reloadData];*/
    } else {
        [self intializeGMGridViews];
    }
    
}
-(void) findBottomIpxVideos {
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(mediaTab == 100) {
        offset = [ appDelegate.iPxImagesList count];
        // NSLog(@"offset value nsdic %d" ,offset);
        welvu_ipx_images *welvu_iPxImageModel= [appDelegate.iPxImagesList lastObject];
        //NSLog(@"offset value nsdic %@" ,welvu_iPxImageModel.ipx_id);
        
        [self startPlatformData:offset :[NSString stringWithFormat: @"%d", welvu_iPxImageModel.iPx_images_id]];
        //[self intializeGMGridViews];
    } else if (mediaTab == 101) {
        //  NSLog(@"search text field %@",searchTextField);
        
        offset = [ appDelegate.ipxOrgImagesList count];
        //  NSLog(@"offset value nsdic %d" ,offset);
        welvu_ipx_images *welvu_iPxImageModel= [ appDelegate.ipxOrgImagesList lastObject];
        // NSLog(@"offset value nsdic %@" ,welvu_iPxImageModel.ipx_id);
        [self getSharedVideosFromPlatform:offset :[NSString stringWithFormat: @"%d", welvu_iPxImageModel.iPx_images_id] :searchTextField];
    }else if (mediaTab == 102) {
        //  NSLog(@"search text field %@",searchTextField);
        
        offset = [ appDelegate.iPxLibImagesList count];
        //  NSLog(@"offset value nsdic %d" ,offset);
        welvu_ipx_images *welvu_iPxImageModel= [ appDelegate.iPxLibImagesList lastObject];
        // NSLog(@"offset value nsdic %@" ,welvu_iPxImageModel.ipx_id);
        [self getLibraryVideosFromPlatform:offset :[NSString stringWithFormat: @"%d", welvu_iPxImageModel.iPx_images_id] :searchTextField];
    } else {
        [self intializeGMGridViews];
    }
}
-(void)checkForMyAndSharedVideos {
    
        [self intializeGMGridViews];
    
    
        [self intializesharedVideosGMGridViews];
    
        [self intializeLibVideosGMGridViews];
    
        [self intializeLeftGMGridView];
   
    
}

-(IBAction)informationBtnClicked:(id)sender{
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"ListiPx VU - LIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ListiPx VU - LIV"
                                                          action:@"Guide Button  - LIV"
                                                           label:@"Guide"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
        overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        overlay.alpha = 1;
        overlay.backgroundColor = [UIColor clearColor];
        
        
        UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        UIButton *overlayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [overlayCustomBtn addTarget:self action:@selector(closeOverlay:) forControlEvents:UIControlEventTouchUpInside];
        [overlayCustomBtn setFrame:CGRectMake(0, 0, 1024, 768)];
        if(mediaTab == 100) {
            overlayImageView.image = [UIImage imageNamed:@"iPxVU.png"];
            
        } else if (mediaTab == 101) {
            overlayImageView.image = [UIImage imageNamed:@"iPxVU_modified.png"];
        }
        [overlay addSubview:overlayImageView];
        [overlay addSubview:overlayCustomBtn];
        
        [self.view addSubview:overlay];
        
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ListiPx VU - LIV_Guide %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

-(IBAction)closeOverlay:(id)sender
{
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"ListiPx VU - LIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ListiPx VU - LIV"
                                                          action:@"closeOverlay Button  - LIV"
                                                           label:@"Close"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
        /*
         if(mediaTab == 100) {
         overlayImageView.image = [UIImage imageNamed:@"iPxVU_modified.png"];
         } else if (mediaTab == 101) {
         overlayImageView.image = [UIImage imageNamed:@"iPxVU.png"];
         }*/
        if(overlay !=nil) {
            [overlay removeFromSuperview];
            overlay = nil;
        }
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ListiPx VU - LIV_Close %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}



- (IBAction)clearAllBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"ListiPx VU - LIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ListiPx VU - LIV"
                                                          action:@"Delete All Button  - LIV"
                                                           label:@"Delete All"
                                                           value:nil] build]];
    
    @try {
        
        previousSelectedId =@"-1";
        
        [_rightcurrentData removeAllObjects];
        [rightIPXGMGridView reloadData];
        deleteAll.enabled = NO;
        deleteBtn.enabled = NO;
        playAll.enabled = NO;
        [self removeVideoPreviewContent];
        
        if(mediaTab == 100) {
            
            [self ClearleftIPXGMGridViewBorder];
            [self.view bringSubviewToFront:myVideosGMGridView];
            myVideosGMGridView.hidden = NO;
            libraryVideoGMGridView.hidden = YES;
            sharedVideoGMGridView.hidden = YES;
        } else if (mediaTab == 101) {
            
            [self ClearleftSharedIPXGMGridViewBorder];
            myVideosGMGridView.hidden = YES;
            libraryVideoGMGridView.hidden = YES;
            sharedVideoGMGridView.hidden = NO;
        }else if (mediaTab == 102) {
            [self ClearlibIPXGMGridViewBorder];
            myVideosGMGridView.hidden = YES;
            libraryVideoGMGridView.hidden = NO;
            sharedVideoGMGridView.hidden = YES;
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ListiPx VU - LIV_Delete All %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}
-(void)ClearleftIPXGMGridViewBorder {
    if([  appDelegate.iPxImagesList count] > 0) {
        for(welvu_ipx_images *welvu_imagesModel in  appDelegate.iPxImagesList) {
            if(welvu_imagesModel.selected) {
                NSInteger index = [self searchImageGroups:welvu_imagesModel.iPx_images_id : appDelegate.iPxImagesList];
                welvu_imagesModel.selected = NO;
                GMGridViewCell *cell = (GMGridViewCell *)[self.myVideosGMGridView cellForItemAtIndex:index];
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

-(void)ClearleftSharedIPXGMGridViewBorder {
    if([  appDelegate.ipxOrgImagesList count] > 0) {
        for(welvu_ipx_images *welvu_imagesModel in  appDelegate.ipxOrgImagesList) {
            if(welvu_imagesModel.selected) {
                NSInteger index = [self searchImageGroups:welvu_imagesModel.iPx_images_id : appDelegate.ipxOrgImagesList];
                welvu_imagesModel.selected = NO;
                GMGridViewCell *cell = (GMGridViewCell *)[self.sharedVideoGMGridView cellForItemAtIndex:index];
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

-(void)ClearlibIPXGMGridViewBorder {
    if([  libcurrentTopicIpx count] > 0) {
        for(welvu_ipx_images *welvu_imagesModel in  appDelegate.iPxLibImagesList) {
            if(welvu_imagesModel.selected) {
                NSInteger index = [self searchImageGroups:welvu_imagesModel.iPx_images_id : libcurrentTopicIpx];
                welvu_imagesModel.selected = NO;
                GMGridViewCell *cell = (GMGridViewCell *)[self.libraryVideoGMGridView cellForItemAtIndex:index];
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




-(IBAction)deleteBtnClciked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"ListiPx VU - LIV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ListiPx VU - LIV"
                                                          action:@"Delete Button  - LIV"
                                                           label:@"Delete"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
        if (((UIButton *) sender).selected) {
            ((UIButton *) sender).selected = false;
            rightIPXGMGridView.editing = false;
        } else {
            ((UIButton *) sender).selected = true;
            rightIPXGMGridView.editing = true;
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"ListiPx VU - LIV_Delete %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

-(void)shareVUContentViewControllerStartedSharing {
    /*if(spinner == nil) {
     spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view];
     [self.view bringSubviewToFront:spinner];
     }*/
    
}
-(void)shareVUContentViewControllerDidCancel {
    [self dismissModalViewControllerAnimated:YES];
    
}
- (UIImage *)getThumbnail:(welvu_ipx_images *)welvu_imagesModel {
    NSString *thumbNailName ;
    UIImage *thumbnail = nil;
    CGSize destinationSize = CGSizeMake(THUMB_IPX_BUTTON_WIDTH, THUMB_IPX_BUTTON_HEIGHT);
    NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.ipx_image_thumbnail];
    UIImage *originalImage = [UIImage imageWithData:imageData];
    thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
    return thumbnail;
}
-(void)shareiPxData {
    // NSLog(@"media tab %d",mediaTab);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        title = nil;
        description = nil;
        videoid = nil;
        title = [[NSMutableArray alloc]init];
        description = [[NSMutableArray alloc]init];
        videoid = [[NSMutableArray alloc]init];
        
        if(mediaTab == 100) {
            for (int i=0; i < _rightcurrentData.count; i++) {
                welvu_ipx_images *img = [_rightcurrentData objectAtIndex:i];
                [ title addObject:img.ipx_image_display_name];
                [description addObject:img.ipx_image_info];
                if(img.ipx_VideoUrl != nil) {
                    [videoid addObject:img.platform_image_id];
                } else if (img.ipx_Org_VideoDetails != nil) {
                    [videoid addObject:img.ipx_VideoIds];
                }
            }
            
            
        } else if(mediaTab == 101) {
            for (int i=0; i < _rightcurrentData.count; i++) {
                welvu_ipx_images *img = [_rightcurrentData objectAtIndex:i];
                [ title addObject:img.ipx_image_display_name];
                [description addObject:img.ipx_image_info];
                if(img.ipx_VideoUrl != nil) {
                    [videoid addObject:img.platform_image_id];
                } else if (img.ipx_Org_VideoDetails != nil) {
                    [videoid addObject:img.ipx_VideoIds];
                }
            }
            
        }else if(mediaTab == 102) {
            for (int i=0; i < _rightcurrentData.count; i++) {
                welvu_ipx_images *img = [_rightcurrentData objectAtIndex:i];
                [ title addObject:img.ipx_image_display_name];
                [description addObject:img.ipx_image_info];
                if(img.ipx_VideoUrl != nil) {
                    [videoid addObject:img.platform_image_id];
                } else if (img.ipx_Org_VideoDetails != nil) {
                    [videoid addObject:img.ipx_VideoIds];
                }
            }
            
        }
        
        
        welvuSaveIpxViewController *shareViewController = [[welvuSaveIpxViewController alloc] init];
        shareViewController.delegate = self;
        shareViewController.ipx_description =description;
        shareViewController.ipx_title =title;
        shareViewController.ipx_videoId = videoid;
        shareViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        shareViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:shareViewController animated:YES];
    } else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        title = nil;
        description = nil;
        videoid = nil;
        // NSLog(@"right current data %@",_rightcurrentData);
        //NSLog(@"previous selected id %@" ,previousSelectedId);
        NSInteger myInt = [previousSelectedId intValue];
        int index = [self searchImageGroups:myInt :_rightcurrentData];
        welvu_ipx_images *ipxModel =  [_rightcurrentData objectAtIndex:index];
        titleipx = ipxModel.ipx_image_display_name;
        // NSLog(@"title for ipx %@",titleipx);
        NSRange start = [titleipx rangeOfString:@"-"];
        NSRange end = [titleipx rangeOfString:@".mp4"];
        NSRange range = NSMakeRange(start.location, end.location);
        // NSLog(@"range %d" ,range);
        // NSLog(@"range lenght %d" ,range.length);
        //  NSLog(@"range loca %d" ,range.location);
        NSInteger startRange = range.location;
        NSInteger endRange = range.length ;
        // NSLog(@"start range %d" ,startRange);
        // NSLog(@"end range %d",endRange);
        NSInteger endValue = ( (endRange +4) - startRange);
        NSRange ranges = NSMakeRange(startRange,endValue);
        titleipx= [titleipx stringByReplacingCharactersInRange:ranges withString:@" "];
        // NSLog(@"ipxTitle %@",titleipx);
        //Remove character in range
        NSString * numberToRemove = @"-";
        titleipx = [titleipx stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",numberToRemove] withString:@""];
        titleipx = [titleipx stringByReplacingOccurrencesOfString:@",," withString:@","];
        // NSLog(@"title for ipx %@",titleipx);
        //santhosh
        descriptionipx = ipxModel.ipx_image_info;
        videoidipx = ipxModel.platform_image_id;
        welvuSaveIpxViewController *shareViewController = [[welvuSaveIpxViewController alloc] init];
        shareViewController.delegate = self;
        shareViewController.ipx_description =descriptionipx;
        shareViewController.ipx_title =titleipx;
        shareViewController.boxVideoId = videoidipx;
        shareViewController.boxMediaTab = mediaTab;
        shareViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        shareViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:shareViewController animated:YES];
    }
}


#pragma mark - PlatformSync Delegate methods
- (void)platformDidResponseReceived:(BOOL)success:(NSString *)actionAPI {
    NSLog(@"Response received for get USER CONFIRMATION");
}
- (void)platformDidReceivedData:(BOOL)success :(NSDictionary *)responseDictionary
                               :(NSString *)actionAPI {
    NSLog(@"response dic %@",responseDictionary);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        NSString * responseStatus = [responseDictionary objectForKey:@"title"];
        
        if([responseStatus isEqualToString:@"Forbidden"]) {
            
            
        }else if([actionAPI isEqualToString:PLATFORM_GET_INFORMATION_PRESCRIPTION]) {
            if(myVideosBtn.selected && offset == 0){
                // [iPxImagesList removeAllObjects];
            }
            NSDictionary *getiPx = [responseDictionary objectForKey:@"ipx"];
            for(NSDictionary *patientApp in getiPx) {
                
                NSString *ipxImageId = [patientApp objectForKey:@"ipx_id"];
                welvu_ipx_images * welvuiPxModels = [[welvu_ipx_images alloc]
                                                     initWithImageId:[patientApp objectForKey:@"ipx_id"]];
                //welvuiPxModels.platform_image_id =[patientApp objectForKey:@"ipx_guid"];
                welvuiPxModels.ipx_image_thumbnail = [patientApp objectForKey:@"thumbnail"];
                welvuiPxModels.ipx_image_display_name = [patientApp objectForKey:@"title"];
                welvuiPxModels.ipx_VideoUrl = [patientApp objectForKey:@"videourl"];
                welvuiPxModels.ipx_image_info =[patientApp objectForKey:@"description"];
                welvuiPxModels.platform_image_id = [patientApp objectForKey:@"id"];
                if([self searchImageGroups:welvuiPxModels.iPx_images_id :_rightcurrentData] > -1) {
                    welvuiPxModels.selected = true;
                }
                [ appDelegate.iPxImagesList addObject:welvuiPxModels];
            }
            
            
             [myVideosGMGridView reloadData];
             
            
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            if(([responseDictionary count] == 0) && ([ appDelegate.iPxImagesList count] == 0)) {
                noContentAvailable.hidden = false;
                
            } else {
                noContentAvailable.hidden = true;
                [self.view bringSubviewToFront:noContentAvailable];
            }
            
            /*if(([responseDictionary count] > 0)|| (iPxImagesList > 0)) {            noContentAvailable.hidden = true;
             } else {
             noContentAvailable.hidden = false;
             [self.view bringSubviewToFront:noContentAvailable];
             }*/
            [rightIPXGMGridView reloadData];
            rightIPXGMGridView.hidden = false;
            sharedVideoGMGridView.hidden = true;
            [_ptrMyVideos endRefresh];
            if(_ptrMyVideos) {
                [_ptrMyVideos  relocateBottomPullToRefresh];
            }
        }else if([actionAPI isEqualToString:PLATFORM_GET_ORGANIZATION_INFORMATION_PRESCRIPTION]) {
            
            if (sharedVideosBtn.selected && offset == 0) {
                // [iPxImagesList removeAllObjects];
            }
            /*  NSDictionary *getOrganizationiPx = [responseDictionary objectForKey:@"ipx"];
             for(NSDictionary *patientApp in responseDictionary) {
             
             
             
             NSString *ipxImageId = [patientApp objectForKey:@"id"];
             
             welvu_ipx_images * welvuiPxModels = [[welvu_ipx_images alloc]
             initWithImageId:[patientApp objectForKey:@"ipx_id"]];
             welvuiPxModels.ipx_guid =[patientApp objectForKey:@"ipx_guid"];
             welvuiPxModels.ipx_Thumbnail = [patientApp objectForKey:@"thumbnail"];
             welvuiPxModels.ipx_title = [patientApp objectForKey:@"title"];
             welvuiPxModels.ipx_Org_VideoDetails = [patientApp objectForKey:@"video_details"];
             welvuiPxModels.ipx_VideoIds = [patientApp objectForKey:@"video_ids"];
             welvuiPxModels.ipx_description =[patientApp objectForKey:@"description"];
             welvuiPxModels.canDelete = [patientApp objectForKey:@"can_delete"];
             welvuiPxModels.ipxPlatfrm_id =[patientApp objectForKey:@"id"];
             if([self searchImageGroups:welvuiPxModels.ipx_id :_rightcurrentData] > -1) {
             welvuiPxModels.selected = true;
             }
             [iPxImagesList addObject:welvuiPxModels];
             
             
             }
             */
            
             
            [sharedVideoGMGridView reloadData];
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            /* if(([responseDictionary count] > 0)|| (iPxImagesList > 0)) {
             noContentAvailable.hidden = true;
             } else {
             noContentAvailable.hidden = false;
             [self.view bringSubviewToFront:noContentAvailable];
             }*/
            
            if(([responseDictionary count] == 0) && ([ appDelegate.iPxImagesList count] == 0)) {
                noContentAvailable.hidden = false;
                
            } else {
                noContentAvailable.hidden = true;
                [self.view bringSubviewToFront:noContentAvailable];
            }
            
            [sharedVideoGMGridView reloadData];
            sharedVideoGMGridView.hidden = false;
            rightIPXGMGridView.hidden = false;
            [_ptr endRefresh];
            if(_ptr) {
                [_ptr  relocateBottomPullToRefresh];
            }
            
        }
        else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame) &&[actionAPI isEqualToString:PLATFORM_ADD_ORGANIZATION_INFORMATION_PRESCRIPTION]      )  {
            
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:NOTIFY_MAIL_SENT
             object:self userInfo:responseDictionary];
        }else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame) &&[actionAPI isEqualToString:PLATFORM_GET_MY_VIDEOS_DELETE]      )  {
            
            NSLog(@"code for sync");
            
        } else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame) &&[actionAPI isEqualToString:PLATFORM_ADD_BOX_INFORMATION_PRESCRIPTION])  {
            
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:NOTIFY_MAIL_SENT
             object:self userInfo:responseDictionary];
        }
        
    } else {
        
        
        if([actionAPI isEqualToString:PLATFORM_GET_INFORMATION_PRESCRIPTION]) {
            if(myVideosBtn.selected && offset == 0){
                //[iPxImagesList removeAllObjects];
            }
            
            for(NSDictionary *patientApp in responseDictionary) {
                
                NSString *ipxImageId = [patientApp objectForKey:@"ipx_id"];
                welvu_ipx_images * welvuiPxModels = [[welvu_ipx_images alloc]
                                                     initWithImageId:[patientApp objectForKey:@"ipx_id"]];
                //welvuiPxModels.ipx_guid =[patientApp objectForKey:@"ipx_guid"];
                welvuiPxModels.ipx_image_thumbnail = [patientApp objectForKey:@"thumbnail"];
                welvuiPxModels.ipx_image_display_name = [patientApp objectForKey:@"title"];
                welvuiPxModels.ipx_VideoUrl = [patientApp objectForKey:@"videourl"];
                welvuiPxModels.ipx_image_info =[patientApp objectForKey:@"description"];
                welvuiPxModels.platform_image_id = [patientApp objectForKey:@"id"];
                if([self searchImageGroups:welvuiPxModels.ipx_image_info :_rightcurrentData] > -1) {
                    welvuiPxModels.selected = true;
                }
                [ appDelegate.iPxImagesList addObject:welvuiPxModels];
            }
            
            
            // [self intializeGMGridViews];
             
            
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            if(([responseDictionary count] == 0) && ([ appDelegate.iPxImagesList count] == 0)) {
                noContentAvailable.hidden = false;
                
            } else {
                noContentAvailable.hidden = true;
                [self.view bringSubviewToFront:noContentAvailable];
            }
            
            /*if(([responseDictionary count] > 0)|| (iPxImagesList > 0)) {            noContentAvailable.hidden = true;
             } else {
             noContentAvailable.hidden = false;
             [self.view bringSubviewToFront:noContentAvailable];
             }*/
            [rightIPXGMGridView reloadData];
            rightIPXGMGridView.hidden = false;
            sharedVideoGMGridView.hidden = true;
            [_ptrMyVideos endRefresh];
            if(_ptrMyVideos) {
                [_ptrMyVideos  relocateBottomPullToRefresh];
            }
        } else if([actionAPI isEqualToString:PLATFORM_GET_ORGANIZATION_INFORMATION_PRESCRIPTION]) {
            
            if (sharedVideosBtn.selected && offset == 0) {
                [ appDelegate.ipxOrgImagesList removeAllObjects];
            }
            
            for(NSDictionary *patientApp in responseDictionary) {
                
                
                
                NSString *ipxImageId = [patientApp objectForKey:@"id"];
                
                welvu_ipx_images * welvuiPxModels = [[welvu_ipx_images alloc]
                                                     initWithImageId:[patientApp objectForKey:@"ipx_id"]];
                //welvuiPxModels.ipx_guid =[patientApp objectForKey:@"ipx_guid"];
                welvuiPxModels.ipx_image_thumbnail = [patientApp objectForKey:@"thumbnail"];
                welvuiPxModels.ipx_image_display_name = [patientApp objectForKey:@"title"];
                welvuiPxModels.ipx_Org_VideoDetails = [patientApp objectForKey:@"video_details"];
                welvuiPxModels.ipx_VideoIds = [patientApp objectForKey:@"video_ids"];
                welvuiPxModels.ipx_image_info =[patientApp objectForKey:@"description"];
                //welvuiPxModels.canDelete = [patientApp objectForKey:@"can_delete"];
                welvuiPxModels.platform_image_id =[patientApp objectForKey:@"id"];
                if([self searchImageGroups:welvuiPxModels.iPx_images_id :_rightcurrentData] > -1) {
                    welvuiPxModels.selected = true;
                }
                [ appDelegate.ipxOrgImagesList addObject:welvuiPxModels];
                
                
            }
            
            
             
            [sharedVideoGMGridView reloadData];
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            /* if(([responseDictionary count] > 0)|| (iPxImagesList > 0)) {
             noContentAvailable.hidden = true;
             } else {
             noContentAvailable.hidden = false;
             [self.view bringSubviewToFront:noContentAvailable];
             }*/
            
            if(([responseDictionary count] == 0) && ([ appDelegate.iPxImagesList count] == 0)) {
                noContentAvailable.hidden = false;
                
            } else {
                noContentAvailable.hidden = true;
                [self.view bringSubviewToFront:noContentAvailable];
            }
            
            [sharedVideoGMGridView reloadData];
            sharedVideoGMGridView.hidden = false;
            rightIPXGMGridView.hidden = false;
            [_ptr endRefresh];
            if(_ptr) {
                [_ptr  relocateBottomPullToRefresh];
            }
            
        } else if([actionAPI isEqualToString:PLATFORM_GET_BOX_IPX_LIBRARY]) {
            
            if (sharedVideosBtn.selected && offset == 0) {
                // [ appDelegate.iPxLibImagesList removeAllObjects];
            }
            
            if([BoxSDK sharedSDK].OAuth2Session.accessToken != nil) {
                appDelegate.welvu_userModel.box_access_token = [BoxSDK sharedSDK].OAuth2Session.accessToken;
                appDelegate.welvu_userModel.box_refresh_access_token= [BoxSDK sharedSDK].OAuth2Session.refreshToken;
                appDelegate.welvu_userModel.box_expires_in =  [BoxSDK sharedSDK].OAuth2Session.accessTokenExpiration;
                [welvu_user updateBoxAccessToken:[appDelegate getDBPath] :appDelegate.welvu_userModel];
            }
            for(NSDictionary *patientApp in responseDictionary) {
                
                NSString *ipxImageId = [patientApp objectForKey:@"ipx_id"];
                welvu_ipx_images * welvuiPxModels = [[welvu_ipx_images alloc]
                                                     initWithImageId:[patientApp objectForKey:@"id"]];
                welvuiPxModels.platform_image_id = [patientApp objectForKey:@"id"];
                //welvuiPxModels.ipx_guid =[patientApp objectForKey:@"ipx_guid"];
                
                welvuiPxModels.ipx_image_display_name = [patientApp objectForKey:@"title"];
                welvuiPxModels.ipx_VideoUrl = [patientApp objectForKey:@"videourl"];
                welvuiPxModels.ipx_image_thumbnail = [patientApp objectForKey:@"thumbnail"];
                welvuiPxModels.ipx_image_info = @"";
                
                if([self searchImageGroups:welvuiPxModels.iPx_images_id :_rightcurrentData] > -1) {
                    welvuiPxModels.selected = true;
                }
                [ appDelegate.iPxLibImagesList addObject:welvuiPxModels];
            }
            
            
           // [self checkForMyAndSharedVideos];
            [sharedVideoGMGridView reloadData];
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            /* if(([responseDictionary count] > 0)|| (iPxImagesList > 0)) {
             noContentAvailable.hidden = true;
             } else {
             noContentAvailable.hidden = false;
             [self.view bringSubviewToFront:noContentAvailable];
             }*/
            
            if(([responseDictionary count] == 0) && ([ appDelegate.iPxImagesList count] == 0)) {
                noContentAvailable.hidden = false;
                
            } else {
                noContentAvailable.hidden = true;
                [self.view bringSubviewToFront:noContentAvailable];
            }
            
            [sharedVideoGMGridView reloadData];
            sharedVideoGMGridView.hidden = false;
            rightIPXGMGridView.hidden = false;
            
            
        } else if([actionAPI isEqualToString:PLATFORM_GET_BOX_IPX]) {
            if(myVideosBtn.selected && offset == 0){
                //[iPxImagesList removeAllObjects];
                
            }
            if([BoxSDK sharedSDK].OAuth2Session.accessToken != nil) {
                appDelegate.welvu_userModel.box_access_token = [BoxSDK sharedSDK].OAuth2Session.accessToken;
                appDelegate.welvu_userModel.box_refresh_access_token= [BoxSDK sharedSDK].OAuth2Session.refreshToken;
                appDelegate.welvu_userModel.box_expires_in =  [BoxSDK sharedSDK].OAuth2Session.accessTokenExpiration;
                [welvu_user updateBoxAccessToken:[appDelegate getDBPath] :appDelegate.welvu_userModel];
            }
            for(NSDictionary *patientApp in responseDictionary) {
                
                NSString *ipxImageId = [patientApp objectForKey:@"ipx_id"];
                welvu_ipx_images * welvuiPxModels = [[welvu_ipx_images alloc]
                                                     initWithImageId:[patientApp objectForKey:@"id"]];
                welvuiPxModels.platform_image_id = [patientApp objectForKey:@"id"];
                //welvuiPxModels.ipx_guid =[patientApp objectForKey:@"ipx_guid"];
                
                welvuiPxModels.ipx_image_info = [patientApp objectForKey:@"title"];
                welvuiPxModels.platform_video_url = [NSString stringWithFormat:@"%@/%@/%@?%@=%@",
                                                     @"https://api.box.com/2.0/files",
                                                     welvuiPxModels.platform_image_id,@"content",
                                                     @"access_token",
                                                     appDelegate.welvu_userModel.box_access_token];
                welvuiPxModels.ipx_image_thumbnail = [NSString stringWithFormat:@"%@/%@/%@?%@%@=%@",
                                                      @"https://api.box.com/2.0/files",
                                                      welvuiPxModels.platform_image_id,@"thumbnail.png",
                                                      @"min_height=256&min_width=256&",
                                                      @"access_token",
                                                      appDelegate.welvu_userModel.box_access_token];
                welvuiPxModels.ipx_image_info = @"";
                
                if([self searchImageGroups:welvuiPxModels.iPx_images_id :_rightcurrentData] > -1) {
                    welvuiPxModels.selected = true;
                }
                [ appDelegate.iPxImagesList addObject:welvuiPxModels];
            }
            
            
            // [self intializeGMGridViews];
             
            
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            if(([responseDictionary count] == 0) && ([ appDelegate.iPxImagesList count] == 0)) {
                noContentAvailable.hidden = false;
                
            } else {
                noContentAvailable.hidden = true;
                [self.view bringSubviewToFront:noContentAvailable];
            }
            
            /*if(([responseDictionary count] > 0)|| (iPxImagesList > 0)) {            noContentAvailable.hidden = true;
             } else {
             noContentAvailable.hidden = false;
             [self.view bringSubviewToFront:noContentAvailable];
             }*/
            [rightIPXGMGridView reloadData];
            rightIPXGMGridView.hidden = false;
            sharedVideoGMGridView.hidden = true;
            
        } else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame) &&[actionAPI isEqualToString:PLATFORM_ADD_ORGANIZATION_INFORMATION_PRESCRIPTION]      )  {
            
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:NOTIFY_MAIL_SENT
             object:self userInfo:responseDictionary];
        }else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame) &&[actionAPI isEqualToString:PLATFORM_GET_MY_VIDEOS_DELETE]      )  {
            
            NSLog(@"code for sync");
            
        } else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame) &&[actionAPI isEqualToString:PLATFORM_ADD_BOX_INFORMATION_PRESCRIPTION]      )  {
            
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:NOTIFY_MAIL_SENT
             object:self userInfo:responseDictionary];
        }
        
    }
}
- (void)syncContentFailedWithErrorDetails:(NSError *)error {
    NSLog(@"Error %@", error);
}

-(void)failedWithErrorDetails:(NSError *)error:(NSString *)actionAPI {
    NSLog(@"Failed to get Specialty %@", error);
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
}

#pragma mark - CustomPullToRefresh Delegate methods
-(void)customPullToRefreshShouldRefresh:(CustomPullToRefresh *)ptr directionEngaged:(MSRefreshDirection)direction {
    
    if(direction == MSRefreshDirectionBottom) {
        
        [self findBottomIpxVideos];
        ptr = nil;
    } else if(direction == MSRefreshDirectionTop) {
        
        [self getRecentIPX];
        ptr = nil;
    }
    
}

#pragma mark - GMGridView Delegate methods
/*Required*/
/*Required*/
//show the number of items in gmgrid view
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    if([gridView isEqual:rightIPXGMGridView]) {
        
        return [ _rightcurrentData count];
    }else if([gridView isEqual:myVideosGMGridView]) {
        
        return [appDelegate.iPxImagesList count];
    } else if([gridView isEqual:sharedVideoGMGridView]) {
        
        return [ appDelegate.ipxOrgImagesList count];
    } else if([gridView isEqual:libraryVideoGMGridView]) {
        
        return [ libcurrentTopicIpx count];
    }
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if([gridView isEqual:myVideosGMGridView]) {
        if (!INTERFACE_IS_PHONE)
        {
            if (UIInterfaceOrientationIsLandscape(orientation))
            {
                if(((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_grid_layout) {
                    
                    //return CGSizeMake(THUMB_BUTTON_GRID_WIDTH, THUMB_BUTTON_GRID_HEIGHT);
                    //changes by santhosh settings
                    return CGSizeMake(230, THUMB_IMAGE_HEIGHT);
                } else {
                    
                    return CGSizeMake(230, THUMB_IMAGE_HEIGHT);
                    
                }
            }
            else
            {
                if(((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_grid_layout) {
                    
                    return CGSizeMake(230, THUMB_IMAGE_HEIGHT);
                    
                } else {
                    
                    return CGSizeMake(230, THUMB_IMAGE_HEIGHT);
                    
                }
            }
        }
        return CGSizeMake(230, THUMB_IMAGE_HEIGHT);
    }else if([gridView isEqual:libraryVideoGMGridView]){
        if (!INTERFACE_IS_PHONE)
        {
            if (UIInterfaceOrientationIsLandscape(orientation))
            {
                if(((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_grid_layout) {
                    
                    //return CGSizeMake(THUMB_BUTTON_GRID_WIDTH, THUMB_BUTTON_GRID_HEIGHT);
                    //changes by santhosh settings
                    return CGSizeMake(230, THUMB_IMAGE_HEIGHT);
                } else {
                    
                    return CGSizeMake(230, THUMB_IMAGE_HEIGHT);
                    
                }
            }
            else
            {
                if(((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_grid_layout) {
                    
                    return CGSizeMake(230, THUMB_IMAGE_HEIGHT);
                    
                } else {
                    
                    return CGSizeMake(230, THUMB_IMAGE_HEIGHT);
                    
                }
            }
        }
        return CGSizeMake(230, THUMB_IMAGE_HEIGHT);
    } else if([gridView isEqual:sharedVideoGMGridView]) {
        if (!INTERFACE_IS_PHONE)
        {
            if (UIInterfaceOrientationIsLandscape(orientation))
            {
                if(((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_grid_layout) {
                    
                    //return CGSizeMake(THUMB_BUTTON_GRID_WIDTH, THUMB_BUTTON_GRID_HEIGHT);
                    //changes by santhosh settings
                    return CGSizeMake(230, THUMB_IMAGE_HEIGHT);
                } else {
                    
                    return CGSizeMake(230, THUMB_IMAGE_HEIGHT);
                    
                }
            }
            else
            {
                if(((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_grid_layout) {
                    
                    return CGSizeMake(230, THUMB_IMAGE_HEIGHT);
                    
                } else {
                    
                    return CGSizeMake(230, THUMB_IMAGE_HEIGHT);
                    
                }
            }
        }
        return CGSizeMake(230, THUMB_IMAGE_HEIGHT);
    }
    else if ([gridView isEqual:rightIPXGMGridView]) {
        
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            return CGSizeMake(THUMB_IPX_BUTTON_WIDTH, THUMB_IPX_BUTTON_HEIGHT);
        } else {
            return CGSizeMake(THUMB_IPX_BUTTON_WIDTH, THUMB_IPX_BUTTON_HEIGHT);
        }
    }
    return CGSizeMake(THUMB_IPX_BUTTON_WIDTH, THUMB_IPX_BUTTON_HEIGHT);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    
    
    if([gridView isEqual:myVideosGMGridView]) {
        
        
        [self.view  bringSubviewToFront:_bottomFadingView];
        [self.view bringSubviewToFront:_topFadingView];
        
        CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:
                       [[UIApplication sharedApplication] statusBarOrientation]];
        
        GMGridViewCell *cell = [gridView dequeueReusableCell];
        
        CGSize destinationSize = CGSizeMake(230, THUMB_IMAGE_HEIGHT);
        
        if (!cell) {
            cell = [[GMGridViewCell alloc] init];
            cell.deleteButtonIcon = [UIImage imageNamed:@"ContCloseButton.png"];
            cell.deleteButtonOffset = CGPointMake(-5, 0);
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, THUMB_IMAGE_HEIGHT)];
            view.layer.masksToBounds = NO;
            view.layer.cornerRadius = 8;
            view.contentMode = UIViewContentModeCenter;
            cell.contentView = view;
            
        }
        
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIImage *thumbnail = nil;
        
        NSString *imageThumbnailPath = nil;
        NSString *filePaths;
        if([((welvu_ipx_images *)[ appDelegate.iPxImagesList objectAtIndex:index]).ipx_image_thumbnail
            isKindOfClass:[NSNull class]]
           || [((welvu_ipx_images *)[ appDelegate.iPxImagesList objectAtIndex:index]).ipx_image_thumbnail
               isEqualToString:@""]) {
               
               imageThumbnailPath= [[NSBundle mainBundle] pathForResource:@"video-being-processed" ofType:@"png"];
               imageData = [NSData dataWithContentsOfFile:imageThumbnailPath];
               
               
           } else {
               imageThumbnailPath = ((welvu_ipx_images *)[ appDelegate.iPxImagesList objectAtIndex:index]).ipx_image_thumbnail;
               NSURL *myurl = [[NSURL alloc]initWithString:imageThumbnailPath];
               imageData = [NSData dataWithContentsOfURL:myurl];
           }
        
        UIImage *originalImage = [UIImage imageWithData:imageData];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        //santhosh for overlay
        NSString *imageTitle = ((welvu_ipx_images *)[ appDelegate.iPxImagesList objectAtIndex:index]).ipx_image_display_name;
        
        
        UIImageView *replayImageView = [[UIImageView alloc]
                                        initWithFrame:CGRectMake(0, 102, 230, 30)];
        
        UIButton *replayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        replayImageView.image = [UIImage imageNamed:@"iPx_Overlay.png"];
        
        
        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 230, 45)];
        myLabel.text = imageTitle;
        myLabel.textColor = [UIColor whiteColor];
        myLabel.backgroundColor = [UIColor clearColor];
        [replayImageView addSubview:myLabel];
        
        
        thumbnail = [thumbnail makeRoundCornerImage:5 :5 ];
        if( ((welvu_ipx_images *)[ appDelegate.iPxImagesList objectAtIndex:index]).selected) {
            thumbnail = [thumbnail imageWithBorderForSelected:THUMB_IMAGE_BORDER];
            thumbnail = [thumbnail makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
            
            
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        // [imageView setFrame:CGRectMake(0, 0, 110, 50)];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = thumbnail;
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:replayImageView];
        
        return cell;
    }else if([gridView isEqual:libraryVideoGMGridView]) {
        
        
        
        [self.view  bringSubviewToFront:_bottomFadingView];
        [self.view bringSubviewToFront:_topFadingView];
        
        CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:
                       [[UIApplication sharedApplication] statusBarOrientation]];
        
        GMGridViewCell *cell = [gridView dequeueReusableCell];
        
        CGSize destinationSize = CGSizeMake(230, THUMB_IMAGE_HEIGHT);
        
        if (!cell) {
            cell = [[GMGridViewCell alloc] init];
            cell.deleteButtonIcon = [UIImage imageNamed:@"ContCloseButton.png"];
            cell.deleteButtonOffset = CGPointMake(-5, 0);
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, THUMB_IMAGE_HEIGHT)];
            view.layer.masksToBounds = NO;
            view.layer.cornerRadius = 8;
            view.contentMode = UIViewContentModeCenter;
            cell.contentView = view;
            
        }
        
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIImage *thumbnail = nil;
        
        NSString *imageThumbnailPath = nil;
        NSString *filePaths;
        
        NSLog(@"index %d",index);
        
        
                if([((welvu_ipx_images *)[ libcurrentTopicIpx objectAtIndex:index]).ipx_image_thumbnail
            isKindOfClass:[NSNull class]]
           || [((welvu_ipx_images *)[ libcurrentTopicIpx objectAtIndex:index]).ipx_image_thumbnail
               isEqualToString:@""]) {
               
               imageThumbnailPath= [[NSBundle mainBundle] pathForResource:@"video-being-processed" ofType:@"png"];
               imageData = [NSData dataWithContentsOfFile:imageThumbnailPath];
               
               
           } else {
               imageThumbnailPath = ((welvu_ipx_images *)[ libcurrentTopicIpx objectAtIndex:index]).ipx_image_thumbnail;
               NSURL *myurl = [[NSURL alloc]initWithString:imageThumbnailPath];
               imageData = [NSData dataWithContentsOfURL:myurl];
           }
        

        

        
        
        UIImage *originalImage = [UIImage imageWithData:imageData];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        //santhosh for overlay
        NSString *imageTitle = ((welvu_ipx_images *)[ libcurrentTopicIpx objectAtIndex:index]).ipx_image_display_name;
        
        imageThumbnailPath = ((welvu_ipx_images *)[ libcurrentTopicIpx objectAtIndex:index]).platform_video_url;
        NSLog(@"((welvu_ipx_images *)[ libcurrentTopicIpx objectAtIndex:index]) %@",imageThumbnailPath);

        
        NSURL *myurl = [[NSURL alloc]initWithString:imageThumbnailPath];
        imageData = [NSData dataWithContentsOfURL:myurl];
        
        UIImageView *replayImageView = [[UIImageView alloc]
                                        initWithFrame:CGRectMake(0, 102, 230, 30)];
        
        UIButton *replayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        replayImageView.image = [UIImage imageNamed:@"iPx_Overlay.png"];
        
        
        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 230, 45)];
        myLabel.text = imageTitle;
        myLabel.textColor = [UIColor whiteColor];
        myLabel.backgroundColor = [UIColor clearColor];
        [replayImageView addSubview:myLabel];
        
        
        thumbnail = [thumbnail makeRoundCornerImage:5 :5 ];
        if( ((welvu_ipx_images *)[ libcurrentTopicIpx objectAtIndex:index]).selected) {
            thumbnail = [thumbnail imageWithBorderForSelected:THUMB_IMAGE_BORDER];
            thumbnail = [thumbnail makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
            
            
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        // [imageView setFrame:CGRectMake(0, 0, 110, 50)];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = thumbnail;
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:replayImageView];
        
        return cell;
        
    } else if([gridView isEqual:sharedVideoGMGridView]) {
        
        [self.view  bringSubviewToFront:_bottomFadingView];
        [self.view bringSubviewToFront:_topFadingView];
        
        CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:
                       [[UIApplication sharedApplication] statusBarOrientation]];
        
        GMGridViewCell *cell = [gridView dequeueReusableCell];
        CGSize destinationSize;
        destinationSize = CGSizeMake(230, THUMB_IMAGE_HEIGHT);
        if (!cell) {
            cell = [[GMGridViewCell alloc] init];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, THUMB_IMAGE_HEIGHT)];
            view.layer.masksToBounds = NO;
            view.layer.cornerRadius = 8;
            view.contentMode = UIViewContentModeCenter;
            cell.contentView = view;
            
        }
        
        /*  if([((welvu_ipx_images *)[ appDelegate.ipxOrgImagesList objectAtIndex:index]).canDelete integerValue] == 0) {
         cell.deleteButtonOffset = CGPointMake(-500, -500);
         } else {
         cell.deleteButtonIcon = [UIImage imageNamed:@"ContCloseButton.png"];
         cell.deleteButtonOffset = CGPointMake(-5, 0);
         }
         */
        
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIImage *thumbnail = nil;
        NSString *imageThumbnailPath = nil;
        NSString *filePaths;
        if([((welvu_ipx_images *)[ appDelegate.ipxOrgImagesList objectAtIndex:index]).ipx_image_thumbnail
            isKindOfClass:[NSNull class]]
           || [((welvu_ipx_images *)[ appDelegate.ipxOrgImagesList objectAtIndex:index]).ipx_image_thumbnail
               isEqualToString:@""] || [((welvu_ipx_images *)[ appDelegate.ipxOrgImagesList objectAtIndex:index]).ipx_image_thumbnail isEqualToString:@"nil"]) {
               
               imageThumbnailPath= [[NSBundle mainBundle] pathForResource:@"video-being-processed" ofType:@"png"];
               imageData = [NSData dataWithContentsOfFile:imageThumbnailPath];
               
               
           } else {
               imageThumbnailPath = ((welvu_ipx_images *)[ appDelegate.ipxOrgImagesList objectAtIndex:index]).ipx_image_thumbnail;
               NSURL *myurl = [[NSURL alloc]initWithString:imageThumbnailPath];
               imageData = [NSData dataWithContentsOfURL:myurl];
           }
        
        UIImage *originalImage = [UIImage imageWithData:imageData];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        
        //santhosh for overlay
        
        NSString *imageTitle = ((welvu_ipx_images *)[ appDelegate.ipxOrgImagesList objectAtIndex:index]).ipx_image_display_name;
        UIImageView *replayImageView = [[UIImageView alloc]
                                        initWithFrame:CGRectMake(0, 102, 230, 30)];
        
        UIButton *replayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        replayImageView.image = [UIImage imageNamed:@"iPx_Overlay.png"];
        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 230, 45)];
        myLabel.text = imageTitle;
        myLabel.textColor = [UIColor whiteColor];
        myLabel.backgroundColor = [UIColor clearColor];
        [replayImageView addSubview:myLabel];
        
        // [self.view addSubview:myVideosBtn];
        thumbnail = [thumbnail makeRoundCornerImage:5 :5 ];
        if( ((welvu_ipx_images *)[ appDelegate.ipxOrgImagesList objectAtIndex:index]).selected) {
            thumbnail = [thumbnail imageWithBorderForSelected:THUMB_IMAGE_BORDER];
            thumbnail = [thumbnail makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        // [imageView setFrame:CGRectMake(0, 0, 110, 50)];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = thumbnail;
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:replayImageView];
        return cell;
    } else if([gridView isEqual:rightIPXGMGridView]) {
        
        [self.view  bringSubviewToFront:right_LeftFadingView];
        [self.view bringSubviewToFront:right_RightFadingView];
        
        CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:
                       [[UIApplication sharedApplication] statusBarOrientation]];
        CGSize  destinationSize = CGSizeMake(THUMB_IPX_BUTTON_WIDTH, THUMB_IPX_BUTTON_HEIGHT);
        
        GMGridViewCell *cell = [gridView dequeueReusableCell];
        
        if (!cell) {
            cell = [[GMGridViewCell alloc] init];
            cell.deleteButtonIcon = [UIImage imageNamed:@"ContCloseButton.png"];
            cell.deleteButtonOffset = CGPointMake(-5, 0);
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            view.layer.masksToBounds = NO;
            view.layer.cornerRadius = 8;
            view.contentMode = UIViewContentModeCenter;
            cell.contentView = view;
        }
        
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        welvu_ipx_images *welvuiPxModels= [_rightcurrentData objectAtIndex:index];
        
        if([welvuiPxModels.ipx_image_thumbnail
            isKindOfClass:[NSNull class]]
           || [welvuiPxModels.ipx_image_thumbnail
               isEqualToString:@""]) {
               
               imageThumbnailPath= [[NSBundle mainBundle]
                                    pathForResource:@"video-being-processed" ofType:@"png"];
               imageData = [NSData dataWithContentsOfFile:imageThumbnailPath];
               
               
           } else {
               imageThumbnailPath = welvuiPxModels.ipx_image_thumbnail;
               NSURL *myurl = [[NSURL alloc]initWithString:imageThumbnailPath];
               imageData = [NSData dataWithContentsOfURL:myurl];
           }
        
        UIImage *originalImage = [UIImage imageWithData:imageData];
        
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
        
        thumbnail = [thumbnail makeRoundCornerImage:5 :5 ];
        
        if (welvuiPxModels.pickedToView) {
            cell.isSelected = TRUE;
            thumbnail  = [thumbnail imageWithBorderForSelected:THUMB_IMAGE_BORDER];
        } else {
            cell.isSelected = FALSE;
            thumbnail  = [thumbnail imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
        }
        thumbnail = [thumbnail makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = thumbnail;
        [cell.contentView addSubview:imageView];
        
        return cell;
    }
    
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {
    teamBtn.enabled = TRUE;
    shareBtn.enabled = TRUE;
    playAllVideo = false;
    // [leftsharedVideoGMGridView reloadData];
    //  [leftIPXGMGridView reloadData];
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    welvu_ipx_images *welvuipxModel = [ appDelegate.iPxImagesList objectAtIndex:position];
    if([gridView isEqual:myVideosGMGridView]) {
        GMGridViewCell *cell = (GMGridViewCell *)[gridView cellForItemAtIndex:position];
        if(!welvuipxModel.selected   && !isSelected) {
            for(UIView *subview in [cell.contentView subviews]) {
                if([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)subview;
                    imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                    imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                    // cell.deleteButtonIcon = [UIImage imageNamed:@"ContCloseButton.png"];
                    // cell.deleteButtonOffset = CGPointMake(0, 0);
                }
            }
            [self unselectPreviousSelectedImage];
            welvu_ipx_images *welvu_imagesModel = [appDelegate.iPxImagesList objectAtIndex:position];
            welvu_imagesModel.selected = YES;
            welvu_imagesModel.pickedToView = YES;
            [_rightcurrentData addObject:[[welvu_ipx_images alloc] initWithImageObject:welvu_imagesModel]];
            cell.isSelected = TRUE;
            deleteBtn.enabled = true;
            deleteBtn.selected =false;
            deleteAll.enabled = true;
            deleteAll.selected = false;
            playAll.enabled = true;
            playAll.selected = false;
            rightIPXGMGridView.editing = false;
            [self setPreviewImageInView:([_rightcurrentData count] - 1)];
            [rightIPXGMGridView insertObjectAtIndex:[_rightcurrentData count] - 1 withAnimation:GMGridViewItemAnimationScroll];
            [myVideosGMGridView reloadData];
            
            //[rightIPXGMGridView reloadData];
            
        } else if(welvuipxModel.selected && !isSelected){
            for(UIView *subview in [cell.contentView subviews]) {
                if([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)subview;
                    imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                    imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                    
                }
            }
            
            cell.isSelected = FALSE;
            [self unselectPreviousSelectedImage];
            // welvuipxModel.selected = NO;
            welvu_ipx_images *iPxModel = [appDelegate.iPxImagesList objectAtIndex:position];
            iPxModel.selected = false;
            iPxModel.pickedToView = false;
            int index = [self searchImageGroups:iPxModel.iPx_images_id :_rightcurrentData];
            if(index > -1) {
                [_rightcurrentData removeObjectAtIndex:index];
                [rightIPXGMGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
                [myVideosGMGridView reloadData];
                
                if ([_rightcurrentData count] > 0) {
                    GMGridViewCell *cellRight = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:0];
                    if (!cellRight.isSelected) {
                        previousSelectedId = [NSString stringWithFormat: @"%d",((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
                        for (UIView *subview in [cellRight.contentView subviews]) {
                            if ([subview isKindOfClass:[UIImageView class]]) {
                                UIImageView *imageView = (UIImageView *)subview;
                                imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                                   makeRoundCornerImage:5 :5];
                                imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                                
                            }
                        }
                        cellRight.isSelected = TRUE;
                        welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
                        welvu_imagesModel.pickedToView = YES;
                        [self setPreviewImageInView:0];
                        deleteBtn.enabled = true;
                        deleteAll.enabled = true;
                        playAll.enabled = true;
                        
                    }
                } else {
                    
                    previousSelectedId = @"-1";
                    [self removeVideoPreviewContent];
                    noVideoContent.hidden = true;
                    deleteBtn.enabled= false;
                    deleteAll.enabled = false;
                    playAll.enabled = false;
                    myVideosGMGridView.editing = NO;
                    rightIPXGMGridView.editing = false;
                    
                }
                // [rightIPXGMGridView reloadData];
            }
            
        }
    }/*else if([gridView isEqual:leftIPXGMGridView]) {
      GMGridViewCell *cell = (GMGridViewCell *)[gridView cellForItemAtIndex:position];
      if(!welvuipxModel.selected   && !isSelected) {
      for(UIView *subview in [cell.contentView subviews]) {
      if([subview isKindOfClass:[UIImageView class]]) {
      UIImageView *imageView = (UIImageView *)subview;
      imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
      imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
      
      }
      }
      
      //[self unselectPreviousSelectedImage];
      //santhosh
      welvu_ipx_images *welvu_imagesModel = [ appDelegate.iPxImagesList objectAtIndex:position];
      welvu_imagesModel.selected = YES;
      welvu_imagesModel.pickedToView = YES;
      [_rightcurrentData addObject:[[welvu_ipx_images alloc] initWithImageObject:welvu_imagesModel]];
      cell.isSelected = TRUE;
      deleteBtn.enabled = TRUE;
      deleteBtn.selected =false;
      deleteAll.enabled = true;
      deleteAll.selected = false;
      playAll.enabled = true;
      playAll.selected = false;
      myVideosGMGridView.editing = false;
      
      [self setPreviewImageInView:([_rightcurrentData count] - 1)];
      [leftIPXGMGridView insertObjectAtIndex:[_rightcurrentData count] - 1 withAnimation:GMGridViewItemAnimationScroll];
      
      //[sharedVideoGMGridView reloadData];
      [leftIPXGMGridView reloadData];
      } else if(welvuipxModel.selected && !isSelected){
      for(UIView *subview in [cell.contentView subviews]) {
      if([subview isKindOfClass:[UIImageView class]]) {
      UIImageView *imageView = (UIImageView *)subview;
      imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
      imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
      
      }
      }
      cell.isSelected = FALSE;
      [self unselectPreviousSelectedImage];
      welvu_ipx_images *iPxModel = [ appDelegate.iPxLibImagesList objectAtIndex:position];
      
      iPxModel.selected = false;
      iPxModel.pickedToView = false;
      int index = [self searchImageGroups:iPxModel.iPx_images_id :_rightcurrentData];
      if(index > -1) {
      [_rightcurrentData removeObjectAtIndex:index];
      [leftIPXGMGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
      [leftIPXGMGridView reloadData];
      
      if ([_rightcurrentData count] > 0) {
      GMGridViewCell *cellRight = (GMGridViewCell *)[leftIPXGMGridView cellForItemAtIndex:0];
      if (!cellRight.isSelected) {
      previousSelectedId = [NSString stringWithFormat: @"%d",((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
      for (UIView *subview in [cellRight.contentView subviews]) {
      if ([subview isKindOfClass:[UIImageView class]]) {
      UIImageView *imageView = (UIImageView *)subview;
      imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
      makeRoundCornerImage:5 :5];
      }
      }
      cellRight.isSelected = TRUE;
      welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
      welvu_imagesModel.pickedToView = YES;
      [self setPreviewImageInView:0];
      deleteBtn.enabled = true;
      deleteAll.enabled = true;
      playAll.enabled = true;
      
      }
      } else {
      previousSelectedId = @"-1";
      [self removeVideoPreviewContent];
      noVideoContent.hidden = true;
      deleteBtn.enabled = false;
      deleteAll.enabled = false;
      playAll.enabled = false;
      
      sharedVideoGMGridView.editing = NO;
      myVideosGMGridView.editing = false;
      
      }
      [leftIPXGMGridView reloadData];
      }
      
      }
      }*/ else if([gridView isEqual:libraryVideoGMGridView]) {
          welvu_ipx_images *welvuipxModel = [ libcurrentTopicIpx objectAtIndex:position];
          GMGridViewCell *cell = (GMGridViewCell *)[gridView cellForItemAtIndex:position];
          //  NSLog(@"welvuipxModel.selected %@",welvuipxModel.selected);
          if(!welvuipxModel.selected   && !isSelected) {
              for(UIView *subview in [cell.contentView subviews]) {
                  if([subview isKindOfClass:[UIImageView class]]) {
                      UIImageView *imageView = (UIImageView *)subview;
                      imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                      imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                      // cell.deleteButtonIcon = [UIImage imageNamed:@"ContCloseButton.png"];
                      // cell.deleteButtonOffset = CGPointMake(0, 0);
                  }
              }
              [self unselectPreviousSelectedImage];
              welvu_ipx_images *welvu_imagesModel = [libcurrentTopicIpx objectAtIndex:position];
              welvu_imagesModel.selected = YES;
              welvu_imagesModel.pickedToView = YES;
              [_rightcurrentData addObject:[[welvu_ipx_images alloc] initWithImageObject:welvu_imagesModel]];
              cell.isSelected = TRUE;
              deleteBtn.enabled = true;
              deleteBtn.selected =false;
              deleteAll.enabled = true;
              deleteAll.selected = false;
              playAll.enabled = true;
              playAll.selected = false;
              rightIPXGMGridView.editing = false;
              [self setPreviewImageInView:([_rightcurrentData count] - 1)];
              [rightIPXGMGridView insertObjectAtIndex:[_rightcurrentData count] - 1 withAnimation:GMGridViewItemAnimationScroll];
              
              [libraryVideoGMGridView reloadData];
              
              //[rightIPXGMGridView reloadData];
              
          } else if(welvuipxModel.selected && !isSelected){
              for(UIView *subview in [cell.contentView subviews]) {
                  if([subview isKindOfClass:[UIImageView class]]) {
                      UIImageView *imageView = (UIImageView *)subview;
                      imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                      imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                      
                  }
              }
              
              cell.isSelected = FALSE;
              [self unselectPreviousSelectedImage];
              // welvuipxModel.selected = NO;
              welvu_ipx_images *iPxModel = [ libcurrentTopicIpx objectAtIndex:position];
              iPxModel.selected = false;
              iPxModel.pickedToView = false;
              int index = [self searchImageGroups:iPxModel.iPx_images_id :_rightcurrentData];
              if(index > -1) {
                  [_rightcurrentData removeObjectAtIndex:index];
                  [rightIPXGMGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
                  [libraryVideoGMGridView reloadData];
                  
                  if ([_rightcurrentData count] > 0) {
                      GMGridViewCell *cellRight = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:0];
                      if (!cellRight.isSelected) {
                          previousSelectedId =[NSString stringWithFormat: @"%d",((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
                          for (UIView *subview in [cellRight.contentView subviews]) {
                              if ([subview isKindOfClass:[UIImageView class]]) {
                                  UIImageView *imageView = (UIImageView *)subview;
                                  imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                                     makeRoundCornerImage:5 :5];
                                  imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                                  
                              }
                          }
                          cellRight.isSelected = TRUE;
                          welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
                          welvu_imagesModel.pickedToView = YES;
                          [self setPreviewImageInView:0];
                          deleteBtn.enabled = true;
                          deleteAll.enabled = true;
                          playAll.enabled = true;
                          
                      }
                  } else {
                      
                      previousSelectedId = @"-1";
                      [self removeVideoPreviewContent];
                      noVideoContent.hidden = true;
                      deleteBtn.enabled= false;
                      deleteAll.enabled = false;
                      playAll.enabled = false;
                      rightIPXGMGridView.editing = NO;
                      libraryVideoGMGridView.editing = false;
                      
                  }
                  [rightIPXGMGridView reloadData];
              }
              
          }
      } else if([gridView isEqual:sharedVideoGMGridView]) {
          welvu_ipx_images *welvuipxModel = [ appDelegate.ipxOrgImagesList objectAtIndex:position];
          GMGridViewCell *cell = (GMGridViewCell *)[gridView cellForItemAtIndex:position];
          // NSLog(@"welvuipxModel.selected %@", welvuipxModel.selected);
          NSLog(@"isSelected %@", isSelected);
          if(!welvuipxModel.selected   && !isSelected) {
              for(UIView *subview in [cell.contentView subviews]) {
                  if([subview isKindOfClass:[UIImageView class]]) {
                      UIImageView *imageView = (UIImageView *)subview;
                      imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                      imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                      // cell.deleteButtonIcon = [UIImage imageNamed:@"ContCloseButton.png"];
                      // cell.deleteButtonOffset = CGPointMake(0, 0);
                  }
              }
              [self unselectPreviousSelectedImage];
              welvu_ipx_images *welvu_imagesModel = [appDelegate.ipxOrgImagesList objectAtIndex:position];
              welvu_imagesModel.selected = YES;
              welvu_imagesModel.pickedToView = YES;
              [_rightcurrentData addObject:[[welvu_ipx_images alloc] initWithImageObject:welvu_imagesModel]];
              cell.isSelected = TRUE;
              deleteBtn.enabled = true;
              deleteBtn.selected =false;
              deleteAll.enabled = true;
              deleteAll.selected = false;
              playAll.enabled = true;
              playAll.selected = false;
              myVideosGMGridView.editing = false;
              [self setPreviewImageInView:([_rightcurrentData count] - 1)];
              [rightIPXGMGridView insertObjectAtIndex:[_rightcurrentData count] - 1 withAnimation:GMGridViewItemAnimationScroll];
              [sharedVideoGMGridView reloadData];
              
              //[rightIPXGMGridView reloadData];
              
          } else if(welvuipxModel.selected && !isSelected){
              for(UIView *subview in [cell.contentView subviews]) {
                  if([subview isKindOfClass:[UIImageView class]]) {
                      UIImageView *imageView = (UIImageView *)subview;
                      imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                      imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                      
                  }
              }
              
              cell.isSelected = FALSE;
              [self unselectPreviousSelectedImage];
              // welvuipxModel.selected = NO;
              welvu_ipx_images *iPxModel = [ appDelegate.ipxOrgImagesList objectAtIndex:position];
              iPxModel.selected = false;
              iPxModel.pickedToView = false;
              int index = [self searchImageGroups:iPxModel.iPx_images_id :_rightcurrentData];
              if(index > -1) {
                  [_rightcurrentData removeObjectAtIndex:index];
                  [rightIPXGMGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
                  [sharedVideoGMGridView reloadData];
                  
                  if ([_rightcurrentData count] > 0) {
                      GMGridViewCell *cellRight = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:0];
                      if (!cellRight.isSelected) {
                          previousSelectedId = [NSString stringWithFormat: @"%d",((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
                          for (UIView *subview in [cellRight.contentView subviews]) {
                              if ([subview isKindOfClass:[UIImageView class]]) {
                                  UIImageView *imageView = (UIImageView *)subview;
                                  imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                                     makeRoundCornerImage:5 :5];
                                  imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                                  
                              }
                          }
                          cellRight.isSelected = TRUE;
                          welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
                          welvu_imagesModel.pickedToView = YES;
                          [self setPreviewImageInView:0];
                          deleteBtn.enabled = true;
                          deleteAll.enabled = true;
                          playAll.enabled = true;
                          
                      }
                  } else {
                      
                      previousSelectedId = @"-1";
                      [self removeVideoPreviewContent];
                      noVideoContent.hidden = true;
                      deleteBtn.enabled= false;
                      deleteAll.enabled = false;
                      playAll.enabled = false;
                      rightIPXGMGridView.editing = NO;
                      sharedVideoGMGridView.editing = false;
                      
                  }
                  [rightIPXGMGridView reloadData];
              }
              
          }
      } else {
          [self unselectPreviousSelectedImage];
          [self setPreviewImageInView:position];
          
          
      }
    
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex {
    if([gridView isEqual:myVideosGMGridView]) {
        welvu_ipx_images *object = [ appDelegate.iPxImagesList objectAtIndex:oldIndex];
        [ appDelegate.iPxImagesList removeObject:object];
        [ appDelegate.iPxImagesList insertObject: object atIndex:newIndex];
        
    } else if([gridView isEqual:sharedVideoGMGridView]) {
        welvu_ipx_images *object = [ appDelegate.ipxOrgImagesList objectAtIndex:oldIndex];
        [ appDelegate.ipxOrgImagesList removeObject:object];
        [ appDelegate.ipxOrgImagesList insertObject: object atIndex:newIndex];
    }else if([gridView isEqual:libraryVideoGMGridView]) {
        welvu_ipx_images *object = [libcurrentTopicIpx objectAtIndex:oldIndex];
        [ libcurrentTopicIpx removeObject:object];
        [ libcurrentTopicIpx insertObject: object atIndex:newIndex];
    } else {
        welvu_ipx_images *object = [_rightcurrentData objectAtIndex:oldIndex];
        [_rightcurrentData removeObject:object];
        [_rightcurrentData insertObject: object atIndex:newIndex];
    }
}


//Delete the item at the given index
- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index {
    if([gridView isEqual:myVideosGMGridView]) {
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
        _lastDeleteItemIndexAsked = index;
        
        if(![welvu_alerts canAlertShowAgain:appDelegate.getDBPath :ALERT_DELETING_MY_VIDEOS_FROM_IPX]){
            WSLAlertViewAutoDismiss* alert = [[WSLAlertViewAutoDismiss alloc]
                                              initWithTitle: NSLocalizedString(@"ALERT_IPX_VU_TITLE", nil)
                                              message: NSLocalizedString(@"ALERT_IPX_VU_ARCHIVE_DELETE_MSG", nil)
                                              delegate: self
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:NSLocalizedString(@"DONT_SHOW_AGAIN", nil),
                                              NSLocalizedString(@"DELETE", nil),nil];
            
            alert.tag = 400;
            
            [alert show];
            
        } else {
            
            GMGridViewCell *cell = (GMGridViewCell *)[gridView cellForItemAtIndex:_lastDeleteItemIndexAsked];
            
            welvu_ipx_images *welvu_imagesModel = [ appDelegate.iPxImagesList objectAtIndex:_lastDeleteItemIndexAsked];
            NSString *iPx_guid = welvu_imagesModel.platform_image_id;
            //[ appDelegate.iPxImagesList removeObjectAtIndex:_lastDeleteItemIndexAsked];
            [myVideosGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
            //need to wrk
            //remove right gridview cell
            
            if(welvu_imagesModel.selected && !isSelected){
                for(UIView *subview in [cell.contentView subviews]) {
                    if([subview isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView = (UIImageView *)subview;
                        imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                        imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                        
                    }
                }
                
                cell.isSelected = FALSE;
                [self unselectPreviousSelectedImage];
                
                welvu_imagesModel.selected = false;
                welvu_imagesModel.pickedToView = false;
                
                int index = [self searchImageGroups:welvu_imagesModel.iPx_images_id :_rightcurrentData];
                if(index > -1) {
                    [_rightcurrentData removeObjectAtIndex:index];
                    [rightIPXGMGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
                    
                    if ([_rightcurrentData count] > 0) {
                        GMGridViewCell *cellRight = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:0];
                        if (!cellRight.isSelected) {
                            previousSelectedId = [NSString stringWithFormat: @"%d",((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
                            for (UIView *subview in [cellRight.contentView subviews]) {
                                if ([subview isKindOfClass:[UIImageView class]]) {
                                    UIImageView *imageView = (UIImageView *)subview;
                                    imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                                       makeRoundCornerImage:5 :5];
                                }
                            }
                            cellRight.isSelected = TRUE;
                            welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
                            welvu_imagesModel.pickedToView = YES;
                            [self setPreviewImageInView:0];
                            deleteBtn.enabled = true;
                            deleteAll.enabled = true;
                            playAll.enabled = true;
                        }
                    } else {
                        previousSelectedId = @"-1";
                        [self removeVideoPreviewContent];
                        noVideoContent.hidden = true;
                        deleteBtn.enabled= false;
                        deleteBtn.selected=NO;
                        deleteAll.enabled = false;
                        deleteAll.selected = NO;
                        playAll.enabled = false;
                        playAll.selected = NO;
                        rightIPXGMGridView.editing = false;
                        
                    }
                    
                    [rightIPXGMGridView reloadData];
                }
                
            }
            
            appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
            if(appDelegate.networkReachable) {
                
                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                NSString *accessToken = nil;
                if(appDelegate.welvu_userModel.access_token == nil) {
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                } else {
                    accessToken = appDelegate.welvu_userModel.access_token;
                }
                HTTPRequestHandler *requestHandler;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
                // ipxRightBanner.image = [UIImage imageNamed:@"IPXiPRightPanelWithBanner.png"];
                
                if( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
                    NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                                  iPx_guid,HTTP_RESPONSE_IPX_GUID_KEY,
                                                  [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], HTTP_REQUEST_ORGANISATION_KEY,nil];
                    
                    
                    
                    HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                          :PLATFORM_HOST_URL1:PLATFORM_GET_MY_VIDEOS_DELETE:HTTP_METHOD_POST
                                                          :requestData :nil];
                    
                }
                
                requestHandler.delegate = self;
                [requestHandler makeHTTPRequest];
            }
            
        }
    }  else if([gridView isEqual:sharedVideoGMGridView]) {
        
        GMGridViewCell *cell = (GMGridViewCell *)[gridView cellForItemAtIndex:_lastDeleteItemIndexAsked];
        
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
        _lastDeleteItemIndexAsked = index;
        
        welvu_ipx_images *welvu_imagesModel = [ appDelegate.ipxOrgImagesList objectAtIndex:_lastDeleteItemIndexAsked];
        NSString *canDeleteVideos = NO;
        
        if( [canDeleteVideos isEqualToString:@"1"]) {
            if(![welvu_alerts canAlertShowAgain:appDelegate.getDBPath :ALERT_DELETING_SHARED_VIDEOS_FROM_IPX]){
                
                
                
                WSLAlertViewAutoDismiss* myAlert = [[WSLAlertViewAutoDismiss alloc]initWithTitle:@"iPx VU" message:@"Delete videos form shared iPxVU" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Do Not Show Again",@"Delete", nil];
                myAlert.tag = 56;
                [myAlert show];
                
            } else {
                welvu_ipx_images *welvu_imagesModel = [ appDelegate.ipxOrgImagesList objectAtIndex:_lastDeleteItemIndexAsked];
                NSInteger iPx_id = welvu_imagesModel.iPx_images_id;
                [ appDelegate.ipxOrgImagesList removeObjectAtIndex:_lastDeleteItemIndexAsked];
                [sharedVideoGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
                previousSelectedId = @"-1";
                [self removeVideoPreviewContent];
                noVideoContent.hidden = true;
                deleteBtn.enabled= false;
                deleteAll.enabled = false;
                playAll.enabled = false;
                if(welvu_imagesModel.selected && !isSelected){
                    for(UIView *subview in [cell.contentView subviews]) {
                        if([subview isKindOfClass:[UIImageView class]]) {
                            UIImageView *imageView = (UIImageView *)subview;
                            imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                            imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                            
                        }
                    }
                    
                    cell.isSelected = FALSE;
                    [self unselectPreviousSelectedImage];
                    
                    welvu_imagesModel.selected = false;
                    welvu_imagesModel.pickedToView = false;
                    
                    int index = [self searchImageGroups:welvu_imagesModel.iPx_images_id :_rightcurrentData];
                    if(index > -1) {
                        [_rightcurrentData removeObjectAtIndex:index];
                        [rightIPXGMGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
                        
                        if ([_rightcurrentData count] > 0) {
                            GMGridViewCell *cellRight = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:0];
                            if (!cellRight.isSelected) {
                                previousSelectedId = [NSString stringWithFormat: @"%d",((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
                                for (UIView *subview in [cellRight.contentView subviews]) {
                                    if ([subview isKindOfClass:[UIImageView class]]) {
                                        UIImageView *imageView = (UIImageView *)subview;
                                        imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                                           makeRoundCornerImage:5 :5];
                                    }
                                }
                                cellRight.isSelected = TRUE;
                                welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
                                welvu_imagesModel.pickedToView = YES;
                                [self setPreviewImageInView:0];
                                deleteBtn.enabled = true;
                                deleteAll.enabled = true;
                                playAll.enabled = true;
                                
                            }
                        } else {
                            previousSelectedId = @"-1";
                            [self removeVideoPreviewContent];
                            noVideoContent.hidden = true;
                            deleteBtn.enabled= false;
                            deleteBtn.selected=NO;
                            deleteAll.enabled = false;
                            deleteAll.selected = NO;
                            playAll.enabled = false;
                            playAll.selected = NO;
                            myVideosGMGridView.editing = false;
                        }
                        
                        [rightIPXGMGridView reloadData];
                    }
                    
                }
                
                appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                if(appDelegate.networkReachable) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
                    
                    
                    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                    NSString *accessToken = nil;
                    if(appDelegate.welvu_userModel.access_token == nil) {
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                    } else {
                        accessToken = appDelegate.welvu_userModel.access_token;
                    }
                    
                    if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
                        
                        
                        
                        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                        
                        NSLog(@"expires in %@",appDelegate.welvu_userModel.oauth_expires_in);
                        NSLog(@"current date in %@",appDelegate.welvu_userModel.oauth_currentDate);
                        
                        //date comparision start
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                        [dateFormatter setTimeZone:gmt];
                        [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
                        NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
                        
                        NSDate *dateFromString = [[NSDate alloc] init];
                        dateFromString = [dateFormatter dateFromString:timeStamp];
                        
                        
                        
                        NSDate *currentGmtDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
                        NSLog(@"currentGmtDate%@",currentGmtDate);
                        
                        
                        
                        NSDate *expiresdatefromstring = [[NSDate alloc] init];
                        expiresdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_expires_in];
                        
                        
                        NSDate *oauth_expiresIn = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:expiresdatefromstring]];
                        NSLog(@"oauth_expiresIn%@",oauth_expiresIn);
                        
                        //currentdb date
                        
                        NSDate *currentdatefromstring = [[NSDate alloc] init];
                        currentdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_currentDate];
                        
                        
                        // NSLog(@"dateFromString%@",dateFromString);
                        NSDate *oauth_currenrDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:currentdatefromstring]];
                        
                        NSLog(@"oauth_currenrDate%@",oauth_currenrDate);
                        
                        
                        NSComparisonResult startCompare = [oauth_expiresIn compare: currentGmtDate];
                        NSComparisonResult endCompare = [oauth_currenrDate compare: currentGmtDate];
                        NSLog(@"startcompare %d",startCompare);
                        NSLog(@"end compare %d",endCompare);
                        
                        if(startCompare == NSOrderedAscending  && endCompare == NSOrderedAscending){
                            
                            
                            [appDelegate oauthRefreshAccessToken];
                            
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                
                                NSMutableURLRequest *requestDelegate = nil;
                                NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
                                NSDictionary *requestData = nil;
                                
                                
                                
                                NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_GET_ORGANIZATION_VIDEOS_DELETE];
                                
                                NSURL *url = [NSURL URLWithString:urlStr];
                                // NSLog(@"guid)ipx %@",guid_ipx);
                                requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                                [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                                iPx_id,HTTP_RESPONSE_IPX_ID_KEY,
                                                [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], HTTP_REQUEST_ORGANISATION_KEY,nil];
                                
                                
                                
                                requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:requestData attachmentData:nil attachmentType:nil attachmentFileName:nil];
                                deleteOrganizationIpx= [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                                
                                [deleteOrganizationIpx start];
                                
                                
                                
                                
                            });
                        }
                        
                        
                        
                        else {
                            NSMutableURLRequest *requestDelegate = nil;
                            NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
                            NSDictionary *requestData = nil;
                            
                            
                            
                            NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_GET_ORGANIZATION_VIDEOS_DELETE];
                            
                            NSURL *url = [NSURL URLWithString:urlStr];
                            // NSLog(@"guid)ipx %@",guid_ipx);
                            requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                            [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                            iPx_id,HTTP_RESPONSE_IPX_ID_KEY,
                                            [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], HTTP_REQUEST_ORGANISATION_KEY,nil];
                            
                            
                            
                            requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:requestData attachmentData:nil attachmentType:nil attachmentFileName:nil];
                            deleteOrganizationIpx= [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                            
                            [deleteOrganizationIpx start];
                        }
                    } else {
                        NSDictionary *requestData = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                                     [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                                     iPx_id,HTTP_RESPONSE_IPX_ID_KEY,
                                                     
                                                     nil];
                        
                        NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
                        if(appDelegate.welvu_userModel.org_id > 0) {
                            [requestDataMutable
                             setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                             forKey:HTTP_REQUEST_ORGANISATION_KEY];
                        }
                        
                        HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                              :PLATFORM_HOST_URL :PLATFORM_GET_ORGANIZATION_VIDEOS_DELETE:HTTP_METHOD_POST
                                                              :requestDataMutable :nil];
                        requestHandler.delegate = self;
                        [requestHandler makeHTTPRequest];
                        
                    }
                    
                    
                    
                }
            }
            NSLog(@"user himseld shared videos");
        } else {
            
            WSLAlertViewAutoDismiss* myAlert = [[WSLAlertViewAutoDismiss alloc]initWithTitle:@"iPx VU" message:@"Not Able to delete Doctor shared videos" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [myAlert show];
            NSLog(@"doctoer shared videos");
        }
    }   else if([gridView isEqual:libraryVideoGMGridView]) {
        
        GMGridViewCell *cell = (GMGridViewCell *)[gridView cellForItemAtIndex:_lastDeleteItemIndexAsked];
        
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
        _lastDeleteItemIndexAsked = index;
        
        welvu_ipx_images *welvu_imagesModel = [ libcurrentTopicIpx objectAtIndex:_lastDeleteItemIndexAsked];
        NSString *canDeleteVideos = NO;
        
        if( [canDeleteVideos isEqualToString:@"1"]) {
            if(![welvu_alerts canAlertShowAgain:appDelegate.getDBPath :ALERT_DELETING_SHARED_VIDEOS_FROM_IPX]){
                
                
                
                WSLAlertViewAutoDismiss* myAlert = [[WSLAlertViewAutoDismiss alloc]initWithTitle:@"iPx VU" message:@"Delete videos form shared iPxVU" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Do Not Show Again",@"Delete", nil];
                myAlert.tag = 56;
                [myAlert show];
                
            } else {
                welvu_ipx_images *welvu_imagesModel = [ libcurrentTopicIpx objectAtIndex:_lastDeleteItemIndexAsked];
                NSInteger iPx_id = welvu_imagesModel.iPx_images_id;
                [ libcurrentTopicIpx removeObjectAtIndex:_lastDeleteItemIndexAsked];
                [sharedVideoGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
                previousSelectedId = @"-1";
                [self removeVideoPreviewContent];
                noVideoContent.hidden = true;
                deleteBtn.enabled= false;
                deleteAll.enabled = false;
                playAll.enabled = false;
                if(welvu_imagesModel.selected && !isSelected){
                    for(UIView *subview in [cell.contentView subviews]) {
                        if([subview isKindOfClass:[UIImageView class]]) {
                            UIImageView *imageView = (UIImageView *)subview;
                            imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                            imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                            
                        }
                    }
                    
                    cell.isSelected = FALSE;
                    [self unselectPreviousSelectedImage];
                    
                    welvu_imagesModel.selected = false;
                    welvu_imagesModel.pickedToView = false;
                    
                    int index = [self searchImageGroups:welvu_imagesModel.iPx_images_id :_rightcurrentData];
                    if(index > -1) {
                        [_rightcurrentData removeObjectAtIndex:index];
                        [rightIPXGMGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
                        
                        if ([_rightcurrentData count] > 0) {
                            GMGridViewCell *cellRight = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:0];
                            if (!cellRight.isSelected) {
                                previousSelectedId = [NSString stringWithFormat: @"%d",((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
                                for (UIView *subview in [cellRight.contentView subviews]) {
                                    if ([subview isKindOfClass:[UIImageView class]]) {
                                        UIImageView *imageView = (UIImageView *)subview;
                                        imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                                           makeRoundCornerImage:5 :5];
                                    }
                                }
                                cellRight.isSelected = TRUE;
                                welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
                                welvu_imagesModel.pickedToView = YES;
                                [self setPreviewImageInView:0];
                                deleteBtn.enabled = true;
                                deleteAll.enabled = true;
                                playAll.enabled = true;
                                
                            }
                        } else {
                            previousSelectedId = @"-1";
                            [self removeVideoPreviewContent];
                            noVideoContent.hidden = true;
                            deleteBtn.enabled= false;
                            deleteBtn.selected=NO;
                            deleteAll.enabled = false;
                            deleteAll.selected = NO;
                            playAll.enabled = false;
                            playAll.selected = NO;
                            rightIPXGMGridView.editing = false;
                        }
                        
                        [rightIPXGMGridView reloadData];
                    }
                    
                }
                
                appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                if(appDelegate.networkReachable) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
                    
                    
                    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                    NSString *accessToken = nil;
                    if(appDelegate.welvu_userModel.access_token == nil) {
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                    } else {
                        accessToken = appDelegate.welvu_userModel.access_token;
                    }
                    
                    if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
                        
                        
                        
                        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                        
                        NSLog(@"expires in %@",appDelegate.welvu_userModel.oauth_expires_in);
                        NSLog(@"current date in %@",appDelegate.welvu_userModel.oauth_currentDate);
                        
                        //date comparision start
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                        [dateFormatter setTimeZone:gmt];
                        [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
                        NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
                        
                        NSDate *dateFromString = [[NSDate alloc] init];
                        dateFromString = [dateFormatter dateFromString:timeStamp];
                        
                        
                        
                        NSDate *currentGmtDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
                        NSLog(@"currentGmtDate%@",currentGmtDate);
                        
                        
                        
                        NSDate *expiresdatefromstring = [[NSDate alloc] init];
                        expiresdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_expires_in];
                        
                        
                        NSDate *oauth_expiresIn = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:expiresdatefromstring]];
                        NSLog(@"oauth_expiresIn%@",oauth_expiresIn);
                        
                        //currentdb date
                        
                        NSDate *currentdatefromstring = [[NSDate alloc] init];
                        currentdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_currentDate];
                        
                        
                        // NSLog(@"dateFromString%@",dateFromString);
                        NSDate *oauth_currenrDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:currentdatefromstring]];
                        
                        NSLog(@"oauth_currenrDate%@",oauth_currenrDate);
                        
                        
                        NSComparisonResult startCompare = [oauth_expiresIn compare: currentGmtDate];
                        NSComparisonResult endCompare = [oauth_currenrDate compare: currentGmtDate];
                        NSLog(@"startcompare %d",startCompare);
                        NSLog(@"end compare %d",endCompare);
                        
                        if(startCompare == NSOrderedAscending  && endCompare == NSOrderedAscending){
                            
                            
                            [appDelegate oauthRefreshAccessToken];
                            
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                
                                NSMutableURLRequest *requestDelegate = nil;
                                NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
                                NSDictionary *requestData = nil;
                                
                                
                                
                                NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_GET_ORGANIZATION_VIDEOS_DELETE];
                                
                                NSURL *url = [NSURL URLWithString:urlStr];
                                // NSLog(@"guid)ipx %@",guid_ipx);
                                requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                                [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                                iPx_id,HTTP_RESPONSE_IPX_ID_KEY,
                                                [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], HTTP_REQUEST_ORGANISATION_KEY,nil];
                                
                                
                                
                                requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:requestData attachmentData:nil attachmentType:nil attachmentFileName:nil];
                                deleteOrganizationIpx= [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                                
                                [deleteOrganizationIpx start];
                                
                                
                                
                                
                            });
                        }
                        
                        
                        
                        else {
                            NSMutableURLRequest *requestDelegate = nil;
                            NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
                            NSDictionary *requestData = nil;
                            
                            
                            
                            NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_GET_ORGANIZATION_VIDEOS_DELETE];
                            
                            NSURL *url = [NSURL URLWithString:urlStr];
                            // NSLog(@"guid)ipx %@",guid_ipx);
                            requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                            [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                            iPx_id,HTTP_RESPONSE_IPX_ID_KEY,
                                            [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], HTTP_REQUEST_ORGANISATION_KEY,nil];
                            
                            
                            
                            requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:requestData attachmentData:nil attachmentType:nil attachmentFileName:nil];
                            deleteOrganizationIpx= [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                            
                            [deleteOrganizationIpx start];
                        }
                    } else {
                        NSDictionary *requestData = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                                     [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                                     iPx_id,HTTP_RESPONSE_IPX_ID_KEY,
                                                     
                                                     nil];
                        
                        NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
                        if(appDelegate.welvu_userModel.org_id > 0) {
                            [requestDataMutable
                             setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                             forKey:HTTP_REQUEST_ORGANISATION_KEY];
                        }
                        
                        HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                              :PLATFORM_HOST_URL :PLATFORM_GET_ORGANIZATION_VIDEOS_DELETE:HTTP_METHOD_POST
                                                              :requestDataMutable :nil];
                        requestHandler.delegate = self;
                        [requestHandler makeHTTPRequest];
                        
                    }
                    
                    
                    
                }
            }
            NSLog(@"user himseld shared videos");
        } else {
            
            WSLAlertViewAutoDismiss* myAlert = [[WSLAlertViewAutoDismiss alloc]initWithTitle:@"iPx VU" message:@"Not Able to delete Doctor shared videos" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [myAlert show];
            NSLog(@"doctoer shared videos");
        }
    }
    else if([gridView isEqual:rightIPXGMGridView]) {
        
        _lastDeleteItemIndexAsked = index;
        
        [self unselectPreviousSelectedImage];
        
        if(mediaTab == 101) {
            welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:index];
            
            
            NSInteger index = [self searchImageGroups:welvu_imagesModel.iPx_images_id : appDelegate.ipxOrgImagesList];
            
            if(index > -1) {
                welvu_ipx_images *welvu_imagesModel = [ appDelegate.ipxOrgImagesList objectAtIndex:index];
                if(welvu_imagesModel.selected) {
                    NSInteger index = [self searchImageGroups:welvu_imagesModel.iPx_images_id : appDelegate.ipxOrgImagesList];
                    welvu_imagesModel.selected = NO;
                    GMGridViewCell *cell = (GMGridViewCell *)[self.sharedVideoGMGridView cellForItemAtIndex:index];
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
            [_rightcurrentData removeObjectAtIndex:_lastDeleteItemIndexAsked];
            [rightIPXGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
            
            
            if ([_rightcurrentData count] > 0) {
                GMGridViewCell *cell = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:0];
                if (!cell.isSelected) {
                    previousSelectedId = [NSString stringWithFormat: @"%d",((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
                    for (UIView *subview in [cell.contentView subviews]) {
                        if ([subview isKindOfClass:[UIImageView class]]) {
                            UIImageView *imageView = (UIImageView *)subview;
                            imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                            imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                            
                        }
                    }
                    cell.isSelected = TRUE;
                    welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
                    welvu_imagesModel.pickedToView = YES;
                    [self setPreviewImageInView:0];
                }
            } else {
                [self removeVideoPreviewContent];
                previousSelectedId = @"-1";
                self.sharedVideoGMGridView.editing = NO;
                rightIPXGMGridView.editing = false;
                
            }
        }
        else   if(mediaTab == 100) {
            
            welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:index];
            
            
            NSInteger index = [self searchImageGroups:welvu_imagesModel.iPx_images_id : appDelegate.iPxImagesList];
            
            if(index > -1) {
                welvu_ipx_images *welvu_imagesModel = [ appDelegate.iPxImagesList objectAtIndex:index];
                if(welvu_imagesModel.selected) {
                    NSInteger index = [self searchImageGroups:welvu_imagesModel.iPx_images_id : appDelegate.iPxImagesList];
                    welvu_imagesModel.selected = NO;
                    GMGridViewCell *cell = (GMGridViewCell *)[self.myVideosGMGridView cellForItemAtIndex:index];
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
            [_rightcurrentData removeObjectAtIndex:_lastDeleteItemIndexAsked];
            [rightIPXGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
            
            
            if ([_rightcurrentData count] > 0) {
                GMGridViewCell *cell = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:0];
                if (!cell.isSelected) {
                    previousSelectedId = [NSString stringWithFormat: @"%d",((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
                    for (UIView *subview in [cell.contentView subviews]) {
                        if ([subview isKindOfClass:[UIImageView class]]) {
                            UIImageView *imageView = (UIImageView *)subview;
                            imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                            imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                            
                        }
                    }
                    cell.isSelected = TRUE;
                    welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
                    welvu_imagesModel.pickedToView = YES;
                    [self setPreviewImageInView:0];
                }
            } else {
                [self removeVideoPreviewContent];
                previousSelectedId = @"-1";
                self.rightIPXGMGridView.editing = NO;
                rightIPXGMGridView.editing = false;
                
                
            }
        }else   if(mediaTab == 102) {
            
            welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:index];
            
            
            NSInteger index = [self searchImageGroups:welvu_imagesModel.iPx_images_id : libcurrentTopicIpx];
            
            if(index > -1) {
                welvu_ipx_images *welvu_imagesModel = [ libcurrentTopicIpx objectAtIndex:index];
                if(welvu_imagesModel.selected) {
                    NSInteger index = [self searchImageGroups:welvu_imagesModel.iPx_images_id : libcurrentTopicIpx];
                    welvu_imagesModel.selected = NO;
                    GMGridViewCell *cell = (GMGridViewCell *)[self.libraryVideoGMGridView cellForItemAtIndex:index];
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
            [_rightcurrentData removeObjectAtIndex:_lastDeleteItemIndexAsked];
            [rightIPXGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
            
            
            if ([_rightcurrentData count] > 0) {
                GMGridViewCell *cell = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:0];
                if (!cell.isSelected) {
                    previousSelectedId = [NSString stringWithFormat: @"%d",((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
                    for (UIView *subview in [cell.contentView subviews]) {
                        if ([subview isKindOfClass:[UIImageView class]]) {
                            UIImageView *imageView = (UIImageView *)subview;
                            imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                            imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                            
                        }
                    }
                    cell.isSelected = TRUE;
                    welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
                    welvu_imagesModel.pickedToView = YES;
                    [self setPreviewImageInView:0];
                }
            } else {
                [self removeVideoPreviewContent];
                previousSelectedId = @"-1";
                self.rightIPXGMGridView.editing = NO;
                rightIPXGMGridView.editing = false;
                
                
            }
        }
    }
}
- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index {
    if([gridView isEqual:myVideosGMGridView]) {
        
        myVideosGMGridView.editing = true;
    }
    else if([gridView isEqual:sharedVideoGMGridView]) {
        
        sharedVideoGMGridView.editing = true;
        
    } else if([gridView isEqual:libraryVideoGMGridView]) {
        
        libraryVideoGMGridView.editing = true;
        
    } else if([gridView isEqual:rightIPXGMGridView]) {
        
        //leftsharedVideoGMGridView.editing = true;
        
    }
    
    
    return YES;
}
- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index {
    return YES;
}
- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    
    if(gridView == myVideosGMGridView) {
        deleteBtn.selected=NO;
        deleteAll.selected = NO;
        playAll.selected = NO;
        self.myVideosGMGridView.editing = NO;
        
    } else if(gridView == sharedVideoGMGridView) {
        deleteBtn.selected=NO;
        deleteAll.selected = NO;
        playAll.selected = NO;
        
        self.sharedVideoGMGridView.editing = NO;
        
    }else if(gridView == libraryVideoGMGridView) {
        deleteBtn.selected=NO;
        deleteAll.selected = NO;
        playAll.selected = NO;
        
        self.libraryVideoGMGridView.editing = NO;
        
    }else if(gridView == rightIPXGMGridView) {
        deleteBtn.selected=NO;
        deleteAll.selected = NO;
        playAll.selected = NO;
        
        self.sharedVideoGMGridView.editing = NO;
        self.libraryVideoGMGridView.editing = NO;
        self.myVideosGMGridView.editing = NO;
        self.rightIPXGMGridView.editing = NO;
    }
    
}
#pragma mark UIAlert ViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if(alertView.tag == 56) {
        
        if(buttonIndex == 1) {
            update = [welvu_alerts updateAlertConfirmation:appDelegate.getDBPath :ALERT_DELETING_SHARED_VIDEOS_FROM_IPX];
            
            GMGridViewCell *cell = (GMGridViewCell *)[sharedVideoGMGridView cellForItemAtIndex:_lastDeleteItemIndexAsked];
            
            
            welvu_ipx_images *welvu_imagesModel = [ appDelegate.iPxImagesList objectAtIndex:_lastDeleteItemIndexAsked];
            NSInteger iPx_id = welvu_imagesModel.iPx_images_id;
            //[ appDelegate.iPxImagesList removeObjectAtIndex:_lastDeleteItemIndexAsked];
            [sharedVideoGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
            previousSelectedId = @"-1";
            [self removeVideoPreviewContent];
            noVideoContent.hidden = true;
            deleteBtn.enabled= false;
            deleteAll.enabled = false;
            playAll.enabled = false;
            
            if(welvu_imagesModel.selected && !isSelected){
                for(UIView *subview in [cell.contentView subviews]) {
                    if([subview isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView = (UIImageView *)subview;
                        imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                        imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                        
                    }
                }
                
                cell.isSelected = FALSE;
                [self unselectPreviousSelectedImage];
                
                welvu_imagesModel.selected = false;
                welvu_imagesModel.pickedToView = false;
                
                int index = [self searchImageGroups:welvu_imagesModel.iPx_images_id :_rightcurrentData];
                if(index > -1) {
                    [_rightcurrentData removeObjectAtIndex:index];
                    [myVideosGMGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
                    
                    if ([_rightcurrentData count] > 0) {
                        GMGridViewCell *cellRight = (GMGridViewCell *)[myVideosGMGridView cellForItemAtIndex:0];
                        if (!cellRight.isSelected) {
                            previousSelectedId = [NSString stringWithFormat: @"%d",((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
                            for (UIView *subview in [cellRight.contentView subviews]) {
                                if ([subview isKindOfClass:[UIImageView class]]) {
                                    UIImageView *imageView = (UIImageView *)subview;
                                    imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                                       makeRoundCornerImage:5 :5];
                                }
                            }
                            cellRight.isSelected = TRUE;
                            welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
                            welvu_imagesModel.pickedToView = YES;
                            [self setPreviewImageInView:0];
                            deleteBtn.enabled = true;
                            deleteAll.enabled = true;
                            playAll.enabled = true;
                        }
                    } else {
                        previousSelectedId = @"-1";
                        [self removeVideoPreviewContent];
                        noVideoContent.hidden = true;
                        deleteBtn.enabled= false;
                        deleteBtn.selected=NO;
                        deleteAll.enabled = false;
                        deleteAll.selected = NO;
                        playAll.enabled = false;
                        playAll.selected = NO;
                        myVideosGMGridView.editing = false;
                    }
                    
                    [myVideosGMGridView reloadData];
                }
                
            }
            
            appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
            if(appDelegate.networkReachable) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
                
                
                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                NSString *accessToken = nil;
                if(appDelegate.welvu_userModel.access_token == nil) {
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                } else {
                    accessToken = appDelegate.welvu_userModel.access_token;
                }
                
                if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
                    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                    
                    NSLog(@"expires in %@",appDelegate.welvu_userModel.oauth_expires_in);
                    NSLog(@"current date in %@",appDelegate.welvu_userModel.oauth_currentDate);
                    
                    //date comparision start
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                    [dateFormatter setTimeZone:gmt];
                    [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
                    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
                    
                    NSDate *dateFromString = [[NSDate alloc] init];
                    dateFromString = [dateFormatter dateFromString:timeStamp];
                    
                    
                    
                    NSDate *currentGmtDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
                    NSLog(@"currentGmtDate%@",currentGmtDate);
                    
                    
                    
                    NSDate *expiresdatefromstring = [[NSDate alloc] init];
                    expiresdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_expires_in];
                    
                    
                    NSDate *oauth_expiresIn = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:expiresdatefromstring]];
                    NSLog(@"oauth_expiresIn%@",oauth_expiresIn);
                    
                    //currentdb date
                    
                    NSDate *currentdatefromstring = [[NSDate alloc] init];
                    currentdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_currentDate];
                    
                    
                    // NSLog(@"dateFromString%@",dateFromString);
                    NSDate *oauth_currenrDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:currentdatefromstring]];
                    
                    NSLog(@"oauth_currenrDate%@",oauth_currenrDate);
                    
                    
                    NSComparisonResult startCompare = [oauth_expiresIn compare: currentGmtDate];
                    NSComparisonResult endCompare = [oauth_currenrDate compare: currentGmtDate];
                    NSLog(@"startcompare %d",startCompare);
                    NSLog(@"end compare %d",endCompare);
                    
                    if(startCompare == NSOrderedAscending  && endCompare == NSOrderedAscending){
                        
                        
                        [appDelegate oauthRefreshAccessToken];
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            
                            
                            NSMutableURLRequest *requestDelegate = nil;
                            NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
                            NSDictionary *requestData = nil;
                            
                            
                            
                            NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_GET_ORGANIZATION_VIDEOS_DELETE];
                            
                            NSURL *url = [NSURL URLWithString:urlStr];
                            // NSLog(@"guid)ipx %@",guid_ipx);
                            requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                            [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                            iPx_id,HTTP_RESPONSE_IPX_ID_KEY,
                                            [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], HTTP_REQUEST_ORGANISATION_KEY,nil];
                            
                            
                            
                            requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:requestData attachmentData:nil attachmentType:nil attachmentFileName:nil];
                            deleteOrganizationIpx= [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                            
                            [deleteOrganizationIpx start];
                            
                            
                            
                        });
                    }
                    
                    
                    else {
                        NSMutableURLRequest *requestDelegate = nil;
                        NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
                        NSDictionary *requestData = nil;
                        
                        
                        
                        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_GET_ORGANIZATION_VIDEOS_DELETE];
                        
                        NSURL *url = [NSURL URLWithString:urlStr];
                        // NSLog(@"guid)ipx %@",guid_ipx);
                        requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                        [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                        iPx_id,HTTP_RESPONSE_IPX_ID_KEY,
                                        [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], HTTP_REQUEST_ORGANISATION_KEY,nil];
                        
                        
                        
                        requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:requestData attachmentData:nil attachmentType:nil attachmentFileName:nil];
                        deleteOrganizationIpx= [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                        
                        [deleteOrganizationIpx start];
                    }
                } else {
                    NSDictionary *requestData = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                                 [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                                 iPx_id,HTTP_RESPONSE_IPX_ID_KEY,
                                                 
                                                 nil];
                    
                    NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
                    if(appDelegate.welvu_userModel.org_id > 0) {
                        [requestDataMutable
                         setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                         forKey:HTTP_REQUEST_ORGANISATION_KEY];
                    }
                    
                    HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                          :PLATFORM_HOST_URL :PLATFORM_GET_ORGANIZATION_VIDEOS_DELETE:HTTP_METHOD_POST
                                                          :requestDataMutable :nil];
                    requestHandler.delegate = self;
                    [requestHandler makeHTTPRequest];
                    
                }
                
                
                
            }
        }
        
        
        else if (buttonIndex == 2) {
            
            
            GMGridViewCell *cell = (GMGridViewCell *)[sharedVideoGMGridView cellForItemAtIndex:_lastDeleteItemIndexAsked];
            
            
            welvu_ipx_images *welvu_imagesModel = [ appDelegate.ipxOrgImagesList objectAtIndex:_lastDeleteItemIndexAsked];
            NSInteger iPx_id = welvu_imagesModel.iPx_images_id;
            [ appDelegate.ipxOrgImagesList removeObjectAtIndex:_lastDeleteItemIndexAsked];
            [sharedVideoGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
            previousSelectedId = @"-1";
            [self removeVideoPreviewContent];
            noVideoContent.hidden = true;
            deleteBtn.enabled= false;
            deleteAll.enabled =false;
            playAll.enabled = false;
            
            if(welvu_imagesModel.selected && !isSelected){
                for(UIView *subview in [cell.contentView subviews]) {
                    if([subview isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView = (UIImageView *)subview;
                        imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                        imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                        
                    }
                }
                
                cell.isSelected = FALSE;
                [self unselectPreviousSelectedImage];
                
                welvu_imagesModel.selected = false;
                welvu_imagesModel.pickedToView = false;
                
                int index = [self searchImageGroups:welvu_imagesModel.iPx_images_id :_rightcurrentData];
                if(index > -1) {
                    [_rightcurrentData removeObjectAtIndex:index];
                    [myVideosGMGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
                    
                    if ([_rightcurrentData count] > 0) {
                        GMGridViewCell *cellRight = (GMGridViewCell *)[myVideosGMGridView cellForItemAtIndex:0];
                        if (!cellRight.isSelected) {
                            previousSelectedId = [NSString stringWithFormat: @"%d", ((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
                            for (UIView *subview in [cellRight.contentView subviews]) {
                                if ([subview isKindOfClass:[UIImageView class]]) {
                                    UIImageView *imageView = (UIImageView *)subview;
                                    imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                                       makeRoundCornerImage:5 :5];
                                }
                            }
                            cellRight.isSelected = TRUE;
                            welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
                            welvu_imagesModel.pickedToView = YES;
                            [self setPreviewImageInView:0];
                            deleteBtn.enabled = true;
                            deleteAll.enabled = true;
                            playAll.enabled = true;
                        }
                    } else {
                        previousSelectedId = @"-1";
                        [self removeVideoPreviewContent];
                        noVideoContent.hidden = true;
                        deleteBtn.enabled= false;
                        deleteBtn.selected=NO;
                        deleteAll.enabled = false;
                        deleteAll.selected = NO;
                        playAll.enabled = false;
                        playAll.selected = NO;
                        myVideosGMGridView.editing = false;
                    }
                    
                    [myVideosGMGridView reloadData];
                }
                
            }
            
            appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
            if(appDelegate.networkReachable) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
                
                
                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                NSString *accessToken = nil;
                if(appDelegate.welvu_userModel.access_token == nil) {
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                } else {
                    accessToken = appDelegate.welvu_userModel.access_token;
                }
                
                if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
                    
                    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                    
                    NSLog(@"expires in %@",appDelegate.welvu_userModel.oauth_expires_in);
                    NSLog(@"current date in %@",appDelegate.welvu_userModel.oauth_currentDate);
                    
                    //date comparision start
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                    [dateFormatter setTimeZone:gmt];
                    [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
                    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
                    
                    NSDate *dateFromString = [[NSDate alloc] init];
                    dateFromString = [dateFormatter dateFromString:timeStamp];
                    
                    
                    
                    NSDate *currentGmtDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
                    NSLog(@"currentGmtDate%@",currentGmtDate);
                    
                    
                    
                    NSDate *expiresdatefromstring = [[NSDate alloc] init];
                    expiresdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_expires_in];
                    
                    
                    NSDate *oauth_expiresIn = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:expiresdatefromstring]];
                    NSLog(@"oauth_expiresIn%@",oauth_expiresIn);
                    
                    //currentdb date
                    
                    NSDate *currentdatefromstring = [[NSDate alloc] init];
                    currentdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_currentDate];
                    
                    
                    // NSLog(@"dateFromString%@",dateFromString);
                    NSDate *oauth_currenrDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:currentdatefromstring]];
                    
                    NSLog(@"oauth_currenrDate%@",oauth_currenrDate);
                    
                    
                    NSComparisonResult startCompare = [oauth_expiresIn compare: currentGmtDate];
                    NSComparisonResult endCompare = [oauth_currenrDate compare: currentGmtDate];
                    NSLog(@"startcompare %d",startCompare);
                    NSLog(@"end compare %d",endCompare);
                    
                    if(startCompare == NSOrderedAscending  && endCompare == NSOrderedAscending){
                        
                        
                        [appDelegate oauthRefreshAccessToken];
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            
                            
                            NSMutableURLRequest *requestDelegate = nil;
                            NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
                            NSDictionary *requestData = nil;
                            
                            
                            
                            NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_GET_ORGANIZATION_VIDEOS_DELETE];
                            
                            NSURL *url = [NSURL URLWithString:urlStr];
                            // NSLog(@"guid)ipx %@",guid_ipx);
                            requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                            [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                            iPx_id,HTTP_RESPONSE_IPX_ID_KEY,
                                            [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], HTTP_REQUEST_ORGANISATION_KEY,nil];
                            
                            
                            
                            requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:requestData attachmentData:nil attachmentType:nil attachmentFileName:nil];
                            deleteOrganizationIpx= [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                            
                            [deleteOrganizationIpx start];
                            
                            
                        });
                    }
                    
                    else {
                        NSMutableURLRequest *requestDelegate = nil;
                        NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
                        NSDictionary *requestData = nil;
                        
                        
                        
                        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_GET_ORGANIZATION_VIDEOS_DELETE];
                        
                        NSURL *url = [NSURL URLWithString:urlStr];
                        // NSLog(@"guid)ipx %@",guid_ipx);
                        requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                        [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                        iPx_id,HTTP_RESPONSE_IPX_ID_KEY,
                                        [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], HTTP_REQUEST_ORGANISATION_KEY,nil];
                        
                        
                        
                        requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:requestData attachmentData:nil attachmentType:nil attachmentFileName:nil];
                        deleteOrganizationIpx= [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                        
                        [deleteOrganizationIpx start];
                    }
                } else {
                    NSDictionary *requestData = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                                 [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                                 iPx_id,HTTP_RESPONSE_IPX_ID_KEY,
                                                 
                                                 nil];
                    
                    NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
                    if(appDelegate.welvu_userModel.org_id > 0) {
                        [requestDataMutable
                         setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                         forKey:HTTP_REQUEST_ORGANISATION_KEY];
                    }
                    
                    HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                          :PLATFORM_HOST_URL :PLATFORM_GET_ORGANIZATION_VIDEOS_DELETE:HTTP_METHOD_POST
                                                          :requestDataMutable :nil];
                    requestHandler.delegate = self;
                    [requestHandler makeHTTPRequest];
                    
                }
                
                
                
            }
        }
        
        else if (buttonIndex == 0) {
            NSLog(@"3");
        }
        
        NSLog(@"left shared videos");
    }
    
    else if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_PUSHING_TO_IPX", nil)]) {
        
        
        
        if(buttonIndex == 1) {
            update = [welvu_alerts updateAlertConfirmation:appDelegate.getDBPath:ALERT_PUSHING_TO_IPX];
            [self shareiPxData];
        }else if (buttonIndex == 2) {
            [self shareiPxData];
        } else if (buttonIndex == 3) {
            
        }
        
    } else if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_PUSHING_IPX_TO_TEAM", nil)]) {
        
        
        
        if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
            NSMutableURLRequest *requestDelegate = nil;
            if(buttonIndex == 0) {
                
                title = nil;
                description = nil;
                videoid = nil;
                
                title = [[NSMutableArray alloc]init];
                description = [[NSMutableArray alloc]init];
                videoid = [[NSMutableArray alloc]init];
                
                for (int i=0; i < _rightcurrentData.count; i++) {
                    welvu_ipx_images *img = [_rightcurrentData objectAtIndex:i];
                    [ title addObject:img.ipx_image_display_name];
                    [description addObject:img.ipx_image_info];
                    [videoid addObject:img.platform_image_id];
                }
                
                
                //TO SHARE TO TEAM
                NSString * ipxidvideo= [videoid componentsJoinedByString:@","];
                NSString *ipxTitle = [title componentsJoinedByString:@","];
                NSString *ipxDescription = [description componentsJoinedByString:@","];
                NSError *error;
                //SBJSON *parser = [[SBJSON alloc] init];
//                NSString*jsonString = [NSJSONSerialization dataWithJSONObject:ipxidvideo options:NSJSONWritingPrettyPrinted error:&error];
//                
//                NSLog(@"json str %@",jsonString);
                
                // NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL, PLATFORM_ADD_ORGANIZATION_INFORMATION_PRESCRIPTION];
                
                /// NSURL *url = [NSURL URLWithString:urlStr];
                
                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                
                NSString *accessToken = nil;
                if(appDelegate.welvu_userModel.access_token == nil) {
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                } else {
                    accessToken = appDelegate.welvu_userModel.access_token;
                }
                appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                
                NSLog(@"expires in %@",appDelegate.welvu_userModel.oauth_expires_in);
                NSLog(@"current date in %@",appDelegate.welvu_userModel.oauth_currentDate);
                
                //date comparision start
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                [dateFormatter setTimeZone:gmt];
                [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
                NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
                
                NSDate *dateFromString = [[NSDate alloc] init];
                dateFromString = [dateFormatter dateFromString:timeStamp];
                
                
                
                NSDate *currentGmtDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
                NSLog(@"currentGmtDate%@",currentGmtDate);
                
                
                
                NSDate *expiresdatefromstring = [[NSDate alloc] init];
                expiresdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_expires_in];
                
                
                NSDate *oauth_expiresIn = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:expiresdatefromstring]];
                NSLog(@"oauth_expiresIn%@",oauth_expiresIn);
                
                //currentdb date
                
                NSDate *currentdatefromstring = [[NSDate alloc] init];
                currentdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_currentDate];
                
                
                // NSLog(@"dateFromString%@",dateFromString);
                NSDate *oauth_currenrDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:currentdatefromstring]];
                
                NSLog(@"oauth_currenrDate%@",oauth_currenrDate);
                
                
                NSComparisonResult startCompare = [oauth_expiresIn compare: currentGmtDate];
                NSComparisonResult endCompare = [oauth_currenrDate compare: currentGmtDate];
                NSLog(@"startcompare %d",startCompare);
                NSLog(@"end compare %d",endCompare);
                
                if(startCompare == NSOrderedAscending  && endCompare == NSOrderedAscending){
                    
                    
                    [appDelegate oauthRefreshAccessToken];
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSMutableURLRequest *requestDelegate = nil;
                        NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
                        NSDictionary *requestData = nil;
                        
                        
                        
                        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_ADD_ORGANIZATION_INFORMATION_PRESCRIPTION];
                        
                        NSURL *url = [NSURL URLWithString:urlStr];
                        // NSLog(@"guid)ipx %@",guid_ipx);
                        requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                        
                                        ipxTitle,@"title",
                                        ipxDescription,@"description",
                                        
                                        ipxidvideo,@"videoids",
                                        [ NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id] ,HTTP_REQUEST_ORGANISATION_KEY,
                                        nil];
                        
                        
                        requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:requestData attachmentData:nil
                                                     attachmentType:nil
                                                 attachmentFileName:nil];
                        
                        addOrganizationIpx= [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                        
                        [addOrganizationIpx start];
                        
                        
                        
                        
                    });
                }
                
                else {
                    NSMutableURLRequest *requestDelegate = nil;
                    NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
                    NSDictionary *requestData = nil;
                    
                    
                    
                    NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_ADD_ORGANIZATION_INFORMATION_PRESCRIPTION];
                    
                    NSURL *url = [NSURL URLWithString:urlStr];
                    // NSLog(@"guid)ipx %@",guid_ipx);
                    requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                    
                                    ipxTitle,@"title",
                                    ipxDescription,@"description",
                                    
                                    ipxidvideo,@"videoids",
                                    [ NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id] ,HTTP_REQUEST_ORGANISATION_KEY,
                                    nil];
                    
                    
                    requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:requestData attachmentData:nil
                                                 attachmentType:nil
                                             attachmentFileName:nil];
                    
                    addOrganizationIpx= [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                    
                    [addOrganizationIpx start];
                    
                }
                
                
                /*  requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                 
                 ipxTitle,@"title",
                 ipxDescription,@"description",
                 
                 ipxidvideo,@"videoids",
                 [ NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id] ,HTTP_REQUEST_ORGANISATION_KEY,
                 nil];
                 SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
                 NSDictionary *jsonString1 = nil;
                 
                 jsonString1 = [jsonWriter stringWithObject:requestData];
                 
                 NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
                 
                 HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                 :PLATFORM_HOST_URL1 :PLATFORM_ADD_ORGANIZATION_INFORMATION_PRESCRIPTION:HTTP_METHOD_POST
                 :requestDataMutable :nil];
                 requestHandler.delegate = self;
                 [requestHandler makeHTTPRequest];*/
                
            }
            
            
            
            
            //TO SHARE TO TEAM
            
            
            else if (buttonIndex == 1) {
            }
            
        }
        
        else {
            if(buttonIndex == 0) {
                
                title = nil;
                description = nil;
                videoid = nil;
                
                title = [[NSMutableArray alloc]init];
                description = [[NSMutableArray alloc]init];
                videoid = [[NSMutableArray alloc]init];
                
                for (int i=0; i < _rightcurrentData.count; i++) {
                    welvu_ipx_images *img = [_rightcurrentData objectAtIndex:i];
                    [ title addObject:img.ipx_image_display_name];
                    [description addObject:img.ipx_image_info];
                    [videoid addObject:img.platform_image_id];
                }
                
                
                //TO SHARE TO TEAM
                NSString * ipxidvideo= [videoid componentsJoinedByString:@","];
                NSString *ipxTitle = [title componentsJoinedByString:@","];
                NSString *ipxDescription = [description componentsJoinedByString:@","];
               
                //SBJSON *parser = [[SBJSON alloc] init];
                //NSString*jsonString = [ipxidvideo JSONRepresentation];
                 NSError *error;
//                NSString*jsonString = [NSJSONSerialization dataWithJSONObject:ipxidvideo options:NSJSONWritingPrettyPrinted error:&error];
//                
//                NSLog(@"json str %@",jsonString);
                
                // NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL, PLATFORM_ADD_ORGANIZATION_INFORMATION_PRESCRIPTION];
                
                /// NSURL *url = [NSURL URLWithString:urlStr];
                
                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                
                NSString *accessToken = nil;
                if(appDelegate.welvu_userModel.access_token == nil) {
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                } else {
                    accessToken = appDelegate.welvu_userModel.access_token;
                }
                
                
                
                NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
                NSDictionary *requestData = nil;
                
                
                
                
                
                requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                ipxTitle,@"title",
                                ipxDescription,@"description",
                                
                                ipxidvideo,@"videoids",
                                
                                nil];
                //SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
//                NSDictionary *jsonString1 = nil;
//                
//                jsonString1 = [NSJSONSerialization dataWithJSONObject:requestData options:NSJSONWritingPrettyPrinted error:&error];
                
                NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
                if(appDelegate.welvu_userModel.org_id > 0) {
                    [requestDataMutable
                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                }
                HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                      :PLATFORM_HOST_URL :PLATFORM_ADD_ORGANIZATION_INFORMATION_PRESCRIPTION:HTTP_METHOD_POST
                                                      :requestDataMutable :nil];
                requestHandler.delegate = self;
                [requestHandler makeHTTPRequest];
                
            }
            
            
            
            
            //TO SHARE TO TEAM
            
            
            else if (buttonIndex == 1) {
            }
            
        }
    }
    else if(alertView.tag == 400) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        
        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
            
            if(buttonIndex == 1) {
                update = [welvu_alerts updateAlertConfirmation:appDelegate.getDBPath :ALERT_DELETING_MY_VIDEOS_FROM_IPX];
                
                
                GMGridViewCell *cell = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:_lastDeleteItemIndexAsked];
                
                welvu_ipx_images *welvu_imagesModel = [ appDelegate.iPxImagesList objectAtIndex:_lastDeleteItemIndexAsked];
                NSString *iPx_guid = welvu_imagesModel.platform_image_id;
                // [ appDelegate.iPxImagesList removeObjectAtIndex:_lastDeleteItemIndexAsked];
                [rightIPXGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
                
                
                //need to wrk
                //remove right gridview cell
                
                if(welvu_imagesModel.selected && !isSelected){
                    for(UIView *subview in [cell.contentView subviews]) {
                        if([subview isKindOfClass:[UIImageView class]]) {
                            UIImageView *imageView = (UIImageView *)subview;
                            imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                            imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                            
                        }
                    }
                    
                    cell.isSelected = FALSE;
                    [self unselectPreviousSelectedImage];
                    
                    welvu_imagesModel.selected = false;
                    welvu_imagesModel.pickedToView = false;
                    
                    int index = [self searchImageGroups:welvu_imagesModel.iPx_images_id :_rightcurrentData];
                    if(index > -1) {
                        [_rightcurrentData removeObjectAtIndex:index];
                        [myVideosGMGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
                        
                        if ([_rightcurrentData count] > 0) {
                            GMGridViewCell *cellRight = (GMGridViewCell *)[myVideosGMGridView cellForItemAtIndex:0];
                            if (!cellRight.isSelected) {
                                previousSelectedId =[NSString stringWithFormat: @"%d", ((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
                                for (UIView *subview in [cellRight.contentView subviews]) {
                                    if ([subview isKindOfClass:[UIImageView class]]) {
                                        UIImageView *imageView = (UIImageView *)subview;
                                        imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                                           makeRoundCornerImage:5 :5];
                                    }
                                }
                                cellRight.isSelected = TRUE;
                                welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
                                welvu_imagesModel.pickedToView = YES;
                                [self setPreviewImageInView:0];
                                deleteBtn.enabled = true;
                                deleteAll.enabled = true;
                                playAll.enabled = true;
                            }
                        } else {
                            previousSelectedId = @"-1";
                            [self removeVideoPreviewContent];
                            noVideoContent.hidden = true;
                            deleteBtn.enabled= false;
                            deleteBtn.selected=NO;
                            deleteAll.enabled= false;
                            deleteAll.selected=NO;
                            playAll.enabled= false;
                            playAll.selected=NO;
                            myVideosGMGridView.editing = false;
                        }
                        
                        [myVideosGMGridView reloadData];
                    }
                    
                }
                
                //remove right gmgrid view
                appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                if(appDelegate.networkReachable) {
                    
                    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                    NSString *accessToken = nil;
                    if(appDelegate.welvu_userModel.access_token == nil) {
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                    } else {
                        accessToken = appDelegate.welvu_userModel.access_token;
                    }
                    
                    
                    // ipxRightBanner.image = [UIImage imageNamed:@"IPXiPRightPanelWithBanner.png"];
                    
                    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                    
                    NSLog(@"expires in %@",appDelegate.welvu_userModel.oauth_expires_in);
                    NSLog(@"current date in %@",appDelegate.welvu_userModel.oauth_currentDate);
                    
                    //date comparision start
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                    [dateFormatter setTimeZone:gmt];
                    [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
                    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
                    
                    NSDate *dateFromString = [[NSDate alloc] init];
                    dateFromString = [dateFormatter dateFromString:timeStamp];
                    
                    
                    
                    NSDate *currentGmtDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
                    NSLog(@"currentGmtDate%@",currentGmtDate);
                    
                    
                    
                    NSDate *expiresdatefromstring = [[NSDate alloc] init];
                    expiresdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_expires_in];
                    
                    
                    NSDate *oauth_expiresIn = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:expiresdatefromstring]];
                    NSLog(@"oauth_expiresIn%@",oauth_expiresIn);
                    
                    //currentdb date
                    
                    NSDate *currentdatefromstring = [[NSDate alloc] init];
                    currentdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_currentDate];
                    
                    
                    // NSLog(@"dateFromString%@",dateFromString);
                    NSDate *oauth_currenrDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:currentdatefromstring]];
                    
                    NSLog(@"oauth_currenrDate%@",oauth_currenrDate);
                    
                    
                    NSComparisonResult startCompare = [oauth_expiresIn compare: currentGmtDate];
                    NSComparisonResult endCompare = [oauth_currenrDate compare: currentGmtDate];
                    NSLog(@"startcompare %d",startCompare);
                    NSLog(@"end compare %d",endCompare);
                    
                    if(startCompare == NSOrderedAscending  && endCompare == NSOrderedAscending){
                        
                        
                        [appDelegate oauthRefreshAccessToken];
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            
                            
                            NSMutableURLRequest *requestDelegate = nil;
                            NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
                            NSDictionary *requestData = nil;
                            
                            
                            
                            NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_GET_MY_VIDEOS_DELETE];
                            
                            NSURL *url = [NSURL URLWithString:urlStr];
                            // NSLog(@"guid)ipx %@",guid_ipx);
                            requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                            [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                            iPx_guid,HTTP_RESPONSE_IPX_GUID_KEY,
                                            [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], HTTP_REQUEST_ORGANISATION_KEY,nil];
                            
                            
                            
                            requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:requestData attachmentData:nil attachmentType:nil attachmentFileName:nil];
                            deleteIpx= [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                            
                            [deleteIpx start];
                            
                            
                            
                            
                        });
                    }
                    
                    else {
                        NSMutableURLRequest *requestDelegate = nil;
                        NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
                        NSDictionary *requestData = nil;
                        
                        
                        
                        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_GET_MY_VIDEOS_DELETE];
                        
                        NSURL *url = [NSURL URLWithString:urlStr];
                        // NSLog(@"guid)ipx %@",guid_ipx);
                        requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                        [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                        iPx_guid,HTTP_RESPONSE_IPX_GUID_KEY,
                                        [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], HTTP_REQUEST_ORGANISATION_KEY,nil];
                        
                        
                        
                        requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:requestData attachmentData:nil attachmentType:nil attachmentFileName:nil];
                        deleteIpx= [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                        
                        [deleteIpx start];
                        
                        
                        
                        
                        /*  NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                         [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                         iPx_guid,HTTP_RESPONSE_IPX_GUID_KEY,
                         [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], HTTP_REQUEST_ORGANISATION_KEY,nil];
                         
                         
                         HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                         :PLATFORM_HOST_URL1:PLATFORM_GET_MY_VIDEOS_DELETE:HTTP_METHOD_POST
                         :requestData :nil];
                         requestHandler.delegate = self;
                         [requestHandler makeHTTPRequest];*/
                        
                    }
                    
                }
                
                
            }
            
            
            
            
            
            
            
            
            else if ( buttonIndex == 2) {
                
                GMGridViewCell *cell = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:_lastDeleteItemIndexAsked];
                
                welvu_ipx_images *welvu_imagesModel = [ appDelegate.iPxImagesList objectAtIndex:_lastDeleteItemIndexAsked];
                NSString *iPx_guid = welvu_imagesModel.platform_image_id;
                //[ appDelegate.iPxImagesList removeObjectAtIndex:_lastDeleteItemIndexAsked];
                [rightIPXGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
                
                
                //need to wrk
                //remove right gridview cell
                
                if(welvu_imagesModel.selected && !isSelected){
                    for(UIView *subview in [cell.contentView subviews]) {
                        if([subview isKindOfClass:[UIImageView class]]) {
                            UIImageView *imageView = (UIImageView *)subview;
                            imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                            imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                            
                        }
                    }
                    
                    cell.isSelected = FALSE;
                    [self unselectPreviousSelectedImage];
                    
                    welvu_imagesModel.selected = false;
                    welvu_imagesModel.pickedToView = false;
                    
                    int index = [self searchImageGroups:welvu_imagesModel.iPx_images_id :_rightcurrentData];
                    if(index > -1) {
                        [_rightcurrentData removeObjectAtIndex:index];
                        [myVideosGMGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
                        
                        if ([_rightcurrentData count] > 0) {
                            GMGridViewCell *cellRight = (GMGridViewCell *)[myVideosGMGridView cellForItemAtIndex:0];
                            if (!cellRight.isSelected) {
                                previousSelectedId = [NSString stringWithFormat: @"%d",((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
                                for (UIView *subview in [cellRight.contentView subviews]) {
                                    if ([subview isKindOfClass:[UIImageView class]]) {
                                        UIImageView *imageView = (UIImageView *)subview;
                                        imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                                           makeRoundCornerImage:5 :5];
                                    }
                                }
                                cellRight.isSelected = TRUE;
                                welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
                                welvu_imagesModel.pickedToView = YES;
                                [self setPreviewImageInView:0];
                                deleteBtn.enabled = true;
                                deleteAll.enabled = true;
                                playAll.enabled = true;
                            }
                        } else {
                            previousSelectedId = @"-1";
                            [self removeVideoPreviewContent];
                            noVideoContent.hidden = true;
                            deleteBtn.enabled= false;
                            deleteBtn.selected=NO;
                            deleteAll.enabled= false;
                            deleteAll.selected=NO;
                            playAll.enabled= false;
                            playAll.selected=NO;
                            myVideosGMGridView.editing = false;
                        }
                        
                        [myVideosGMGridView reloadData];
                    }
                    
                }
                
                //remove right gmgrid view
                
                appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                if(appDelegate.networkReachable) {
                    
                    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                    NSString *accessToken = nil;
                    if(appDelegate.welvu_userModel.access_token == nil) {
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                    } else {
                        accessToken = appDelegate.welvu_userModel.access_token;
                    }
                    
                    
                    // ipxRightBanner.image = [UIImage imageNamed:@"IPXiPRightPanelWithBanner.png"];
                    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                    
                    NSLog(@"expires in %@",appDelegate.welvu_userModel.oauth_expires_in);
                    NSLog(@"current date in %@",appDelegate.welvu_userModel.oauth_currentDate);
                    
                    //date comparision start
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                    [dateFormatter setTimeZone:gmt];
                    [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
                    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
                    
                    NSDate *dateFromString = [[NSDate alloc] init];
                    dateFromString = [dateFormatter dateFromString:timeStamp];
                    
                    
                    
                    NSDate *currentGmtDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
                    NSLog(@"currentGmtDate%@",currentGmtDate);
                    
                    
                    
                    NSDate *expiresdatefromstring = [[NSDate alloc] init];
                    expiresdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_expires_in];
                    
                    
                    NSDate *oauth_expiresIn = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:expiresdatefromstring]];
                    NSLog(@"oauth_expiresIn%@",oauth_expiresIn);
                    
                    //currentdb date
                    
                    NSDate *currentdatefromstring = [[NSDate alloc] init];
                    currentdatefromstring = [dateFormatter dateFromString:appDelegate.welvu_userModel.oauth_currentDate];
                    
                    
                    // NSLog(@"dateFromString%@",dateFromString);
                    NSDate *oauth_currenrDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:currentdatefromstring]];
                    
                    NSLog(@"oauth_currenrDate%@",oauth_currenrDate);
                    
                    
                    NSComparisonResult startCompare = [oauth_expiresIn compare: currentGmtDate];
                    NSComparisonResult endCompare = [oauth_currenrDate compare: currentGmtDate];
                    NSLog(@"startcompare %d",startCompare);
                    NSLog(@"end compare %d",endCompare);
                    
                    if(startCompare == NSOrderedAscending  && endCompare == NSOrderedAscending){
                        
                        
                        [appDelegate oauthRefreshAccessToken];
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            
                            NSMutableURLRequest *requestDelegate = nil;
                            NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
                            NSDictionary *requestData = nil;
                            
                            
                            
                            NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_GET_MY_VIDEOS_DELETE];
                            
                            NSURL *url = [NSURL URLWithString:urlStr];
                            // NSLog(@"guid)ipx %@",guid_ipx);
                            requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                            [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                            iPx_guid,HTTP_RESPONSE_IPX_GUID_KEY,
                                            [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], HTTP_REQUEST_ORGANISATION_KEY,nil];
                            
                            
                            
                            requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:requestData attachmentData:nil attachmentType:nil attachmentFileName:nil];
                            deleteIpx= [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                            
                            [deleteIpx start];
                            
                            
                            
                        });
                    }
                    
                    else {
                        NSMutableURLRequest *requestDelegate = nil;
                        NSNumber *org_ID = [NSNumber numberWithInt:appDelegate.welvu_userModel.org_id];
                        NSDictionary *requestData = nil;
                        
                        
                        
                        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL1, PLATFORM_GET_MY_VIDEOS_DELETE];
                        
                        NSURL *url = [NSURL URLWithString:urlStr];
                        // NSLog(@"guid)ipx %@",guid_ipx);
                        requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                        [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                        iPx_guid,HTTP_RESPONSE_IPX_GUID_KEY,
                                        [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], HTTP_REQUEST_ORGANISATION_KEY,nil];
                        
                        
                        
                        requestDelegate  = [self POSTRequestWithURL:url andDataDictionary:requestData attachmentData:nil attachmentType:nil attachmentFileName:nil];
                        deleteIpx= [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
                        
                        [deleteIpx start];
                        
                        /*
                         
                         NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                         [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                         iPx_guid,HTTP_RESPONSE_IPX_GUID_KEY,
                         [NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], HTTP_REQUEST_ORGANISATION_KEY,nil];
                         
                         
                         
                         HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                         :PLATFORM_HOST_URL1:PLATFORM_GET_MY_VIDEOS_DELETE:HTTP_METHOD_POST
                         :requestData :nil];
                         requestHandler.delegate = self;
                         [requestHandler makeHTTPRequest];
                         
                         }*/
                        
                        
                        
                        
                        
                    }
                }
                
            }
        }
        else {
            if(buttonIndex == 1) {
                update = [welvu_alerts updateAlertConfirmation:appDelegate.getDBPath :ALERT_DELETING_MY_VIDEOS_FROM_IPX];
                
                
                GMGridViewCell *cell = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:_lastDeleteItemIndexAsked];
                
                welvu_ipx_images *welvu_imagesModel = [ appDelegate.iPxImagesList objectAtIndex:_lastDeleteItemIndexAsked];
                NSString *iPx_guid = welvu_imagesModel.platform_image_id;
                //[ appDelegate.iPxImagesList removeObjectAtIndex:_lastDeleteItemIndexAsked];
                [rightIPXGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
                
                
                //need to wrk
                //remove right gridview cell
                
                if(welvu_imagesModel.selected && !isSelected){
                    for(UIView *subview in [cell.contentView subviews]) {
                        if([subview isKindOfClass:[UIImageView class]]) {
                            UIImageView *imageView = (UIImageView *)subview;
                            imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                            imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                            
                        }
                    }
                    
                    cell.isSelected = FALSE;
                    [self unselectPreviousSelectedImage];
                    
                    welvu_imagesModel.selected = false;
                    welvu_imagesModel.pickedToView = false;
                    
                    int index = [self searchImageGroups:welvu_imagesModel.iPx_images_id :_rightcurrentData];
                    if(index > -1) {
                        [_rightcurrentData removeObjectAtIndex:index];
                        [myVideosGMGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
                        
                        if ([_rightcurrentData count] > 0) {
                            GMGridViewCell *cellRight = (GMGridViewCell *)[myVideosGMGridView cellForItemAtIndex:0];
                            if (!cellRight.isSelected) {
                                previousSelectedId = [NSString stringWithFormat: @"%d",((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
                                for (UIView *subview in [cellRight.contentView subviews]) {
                                    if ([subview isKindOfClass:[UIImageView class]]) {
                                        UIImageView *imageView = (UIImageView *)subview;
                                        imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                                           makeRoundCornerImage:5 :5];
                                    }
                                }
                                cellRight.isSelected = TRUE;
                                welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
                                welvu_imagesModel.pickedToView = YES;
                                [self setPreviewImageInView:0];
                                deleteBtn.enabled = true;
                                deleteAll.enabled = true;
                                playAll.enabled = true;
                            }
                        } else {
                            previousSelectedId = @"-1";
                            [self removeVideoPreviewContent];
                            noVideoContent.hidden = true;
                            deleteBtn.enabled= false;
                            deleteBtn.selected=NO;
                            deleteAll.enabled= false;
                            deleteAll.selected=NO;
                            playAll.enabled= false;
                            playAll.selected=NO;
                            myVideosGMGridView.editing = false;
                        }
                        
                        [myVideosGMGridView reloadData];
                    }
                    
                }
                
                //remove right gmgrid view
                appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                if(appDelegate.networkReachable) {
                    
                    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                    NSString *accessToken = nil;
                    if(appDelegate.welvu_userModel.access_token == nil) {
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                    } else {
                        accessToken = appDelegate.welvu_userModel.access_token;
                    }
                    
                    
                    // ipxRightBanner.image = [UIImage imageNamed:@"IPXiPRightPanelWithBanner.png"];
                    
                    
                    NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                                  iPx_guid,HTTP_RESPONSE_IPX_GUID_KEY,
                                                  accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,nil];
                    
                    NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
                    if(appDelegate.welvu_userModel.org_id > 0) {
                        [requestDataMutable
                         setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                         forKey:HTTP_REQUEST_ORGANISATION_KEY];
                    }
                    
                    HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                          :PLATFORM_HOST_URL:PLATFORM_GET_MY_VIDEOS_DELETE:HTTP_METHOD_POST
                                                          :requestDataMutable :nil];
                    requestHandler.delegate = self;
                    [requestHandler makeHTTPRequest];
                    
                }
                
            } else if ( buttonIndex == 2) {
                
                GMGridViewCell *cell = (GMGridViewCell *)[rightIPXGMGridView cellForItemAtIndex:_lastDeleteItemIndexAsked];
                
                welvu_ipx_images *welvu_imagesModel = [ appDelegate.ipxOrgImagesList objectAtIndex:_lastDeleteItemIndexAsked];
                NSString *iPx_guid = welvu_imagesModel.platform_image_id;
                [ appDelegate.ipxOrgImagesList removeObjectAtIndex:_lastDeleteItemIndexAsked];
                [rightIPXGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
                
                
                //need to wrk
                //remove right gridview cell
                
                if(welvu_imagesModel.selected && !isSelected){
                    for(UIView *subview in [cell.contentView subviews]) {
                        if([subview isKindOfClass:[UIImageView class]]) {
                            UIImageView *imageView = (UIImageView *)subview;
                            imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                            imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                            
                        }
                    }
                    
                    cell.isSelected = FALSE;
                    [self unselectPreviousSelectedImage];
                    
                    welvu_imagesModel.selected = false;
                    welvu_imagesModel.pickedToView = false;
                    
                    int index = [self searchImageGroups:welvu_imagesModel.iPx_images_id :_rightcurrentData];
                    if(index > -1) {
                        [_rightcurrentData removeObjectAtIndex:index];
                        [myVideosGMGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
                        
                        if ([_rightcurrentData count] > 0) {
                            GMGridViewCell *cellRight = (GMGridViewCell *)[myVideosGMGridView cellForItemAtIndex:0];
                            if (!cellRight.isSelected) {
                                previousSelectedId = [NSString stringWithFormat: @"%d",((welvu_ipx_images *)[_rightcurrentData objectAtIndex:0]).iPx_images_id];
                                for (UIView *subview in [cellRight.contentView subviews]) {
                                    if ([subview isKindOfClass:[UIImageView class]]) {
                                        UIImageView *imageView = (UIImageView *)subview;
                                        imageView.image = [[imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER]
                                                           makeRoundCornerImage:5 :5];
                                    }
                                }
                                cellRight.isSelected = TRUE;
                                welvu_ipx_images *welvu_imagesModel = [_rightcurrentData objectAtIndex:0];
                                welvu_imagesModel.pickedToView = YES;
                                [self setPreviewImageInView:0];
                                deleteBtn.enabled = true;
                                deleteAll.enabled = true;
                                playAll.enabled = true;
                            }
                        } else {
                            previousSelectedId = @"-1";
                            [self removeVideoPreviewContent];
                            noVideoContent.hidden = true;
                            deleteBtn.enabled= false;
                            deleteBtn.selected=NO;
                            deleteAll.enabled= false;
                            deleteAll.selected=NO;
                            playAll.enabled= false;
                            playAll.selected=NO;
                            myVideosGMGridView.editing = false;
                        }
                        
                        [myVideosGMGridView reloadData];
                    }
                    
                }
                
                //remove right gmgrid view
                
                appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                if(appDelegate.networkReachable) {
                    
                    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                    NSString *accessToken = nil;
                    if(appDelegate.welvu_userModel.access_token == nil) {
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                    } else {
                        accessToken = appDelegate.welvu_userModel.access_token;
                    }
                    
                    
                    // ipxRightBanner.image = [UIImage imageNamed:@"IPXiPRightPanelWithBanner.png"];
                    
                    
                    
                    NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                                  iPx_guid,HTTP_RESPONSE_IPX_GUID_KEY,
                                                  accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,nil];
                    
                    NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
                    if(appDelegate.welvu_userModel.org_id > 0) {
                        [requestDataMutable
                         setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                         forKey:HTTP_REQUEST_ORGANISATION_KEY];
                    }
                    
                    HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                          :PLATFORM_HOST_URL:PLATFORM_GET_MY_VIDEOS_DELETE:HTTP_METHOD_POST
                                                          :requestDataMutable :nil];
                    requestHandler.delegate = self;
                    [requestHandler makeHTTPRequest];
                    
                }
                
                
                
                
                
            }
        }
        
    }
}

#pragma mark Touch Event Delegate methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self startLockTimer];
    
    [searchText resignFirstResponder];
    // deleteBtn.selected=FALSE;
    self.libraryVideoGMGridView.editing = NO;
    self.rightIPXGMGridView.editing = NO;
    self.sharedVideoGMGridView.editing = NO;
    self.myVideosGMGridView.editing = NO;
    deleteBtn.selected=NO;
    deleteAll.selected = NO;
    playAll.selected = NO;
}

-(IBAction)lockScreen:(NSTimer *) t {
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"lock"
     object:self];
}
-(void)startLockTimer{
    /*  [appDelegate.lockTimer invalidate];
     
     appDelegate.lockTimer = [NSTimer scheduledTimerWithTimeInterval:WELVU_LOCK_TIME
     target:self
     selector:@selector(lockScreen:)
     userInfo:nil
     repeats:NO];
     NSLog(@"t %@",appDelegate.lockTimer);*/
}

-(void)logoutUser {
    [self.delegate userLoggedOutFromIpxViewController];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 * Method name: POSTRequestWithURL
 * Description: Get the data and post with request url toplatform
 * Parameters: ur,Filename,file type etc
 * return request
 */
- (NSMutableURLRequest *) POSTRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) message_data
                              attachmentData:(NSData *) attachment_data attachmentType:(NSString *) attachment_type
                          attachmentFileName:(NSString *) attachment_fileName {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:180.0];
    
    
    
    
    
    [request setHTTPMethod:HTTP_METHOD_POST];
    
    /*NSMutableString *loginString = (NSMutableString *)
     [@"" stringByAppendingFormat:@"%@:%@",  MAIL_ID, MAIL_PASSWORD];
     NSString *encodedLoginData = [Base64 encode:[loginString dataUsingEncoding:NSUTF8StringEncoding]];
     [request addValue:[NSString stringWithFormat:@"%@ %@",HTTP_SSL_BASIC, encodedLoginData] forHTTPHeaderField:HTTP_SSL_HEADER_KEY];*/
    
    NSString *contentType = [NSString stringWithFormat:@"%@; %@=%@", HTTP_REQUEST_MULTIPART_TYPE,
                             HTTP_BOUNDARY_KEY, HTTP_BOUNDARY];
    [request setValue:contentType forHTTPHeaderField:HTTP_REQUEST_CONTENT_TYPE_KEY];
    
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in message_data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", HTTP_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\"%@\"\r\n\r\n", HTTP_CONTENT_DISPOSITION,param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [message_data objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (attachment_data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", HTTP_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
        //MOdify from here
        [body appendData:[[NSString stringWithFormat:@"%@\"%@\"; filename=\"%@.%@\"\r\n",HTTP_CONTENT_DISPOSITION, @"filename",attachment_fileName, HTTP_ATTACHMENT_VIDEO_EXT_KEY] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@: %@\r\n\r\n",HTTP_REQUEST_CONTENT_TYPE_KEY,attachment_type] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:attachment_data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", HTTP_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    
    NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:HTTP_REQUEST_CONTENT_LENGTH_KEY];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    
    
    
    
    
    // set URL
    [request setURL:url];
    
    
    return request;
}

#pragma mark NSURL Connection Delegate
// NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge previousFailureCount] == 0) {
        // NSLog(@"responded to authentication challenge");
    }
    else {
        // NSLog(@"previous authentication failure");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //[self.delegate shareVUContentUploadSendResponse:YES];
    [[UIApplication sharedApplication] endBackgroundTask:bti];
    bti = UIBackgroundTaskInvalid;
    NSLog(@"response %@",response);
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    
    defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    NSError *error;
    //SBJSON *parser = [[SBJSON alloc] init];
    
    if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        if( connection == getOrganizationIpx) {
            
            //SBJSON *parser = [[SBJSON alloc] init];
            NSError *error;
            
            defaults = [NSUserDefaults standardUserDefaults];
            NSString* newStr = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            if([defaults objectForKey:@"getOrganizationIpx"]) {
                responseStr = [defaults objectForKey:@"getOrganizationIpx"];
            } else {
                responseStr = [[NSString alloc] init];
            }
            responseStr = [responseStr stringByAppendingString:newStr];
            [defaults setObject:responseStr forKey:@"getOrganizationIpx"];
            
            
            
        }else if( connection == getLibraryIpxTopicList) {
//            SBJSON *parser = [[SBJSON alloc] init];
            NSError *error;
            
            defaults = [NSUserDefaults standardUserDefaults];
            NSString* newStr = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            NSLog(@"newStr ipx topics %@",newStr);
            responseStrIpxTps = [[NSString alloc] init];
            if([defaults objectForKey:@"getLibTopic"]) {
                responseStrIpxTps = [defaults objectForKey:@"getLibTopic"];
            } else {
                responseStrIpxTps = [[NSString alloc] init];
            }
            responseStrIpxTps = [responseStrIpxTps stringByAppendingString:newStr];
            [defaults setObject:responseStrIpxTps forKey:@"getLibTopic"];
            
            
        }else if( connection == getLibraryIpx) {
            
//            SBJSON *parser = [[SBJSON alloc] init];
            NSError *error;
            
            defaults = [NSUserDefaults standardUserDefaults];
            NSString* newStr = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            if([defaults objectForKey:@"getOrganizationIpx"]) {
                responseStr = [defaults objectForKey:@"getOrganizationIpx"];
            } else {
                responseStr = [[NSString alloc] init];
            }
            responseStr = [responseStr stringByAppendingString:newStr];
            [defaults setObject:responseStr forKey:@"getOrganizationIpx"];
            
            
            
        }
        
        else if( connection == deleteIpx) {
            if(data) {
                NSError *error;
//                SBJSON *parser = [[SBJSON alloc] init];
                // 1. get the top level value as a dictionary
                NSString* newStr = [[NSString alloc] initWithData:data
                                                         encoding:NSUTF8StringEncoding];
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                NSLog(@"code for sync");
                
            }
        }else if( connection == deleteOrganizationIpx) {
            if(data) {
                NSError *error;
                //SBJSON *parser = [[SBJSON alloc] init];
                // 1. get the top level value as a dictionary
                NSString* newStr = [[NSString alloc] initWithData:data
                                                         encoding:NSUTF8StringEncoding];
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
                NSLog(@"response idc %@",responseDictionary);
                NSLog(@"code for sync");
                
            }
        }
        
        
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        if(connection == getOrganizationIpx) {
           // SBJSON *parser = [[SBJSON alloc] init];
            NSError *error;
            
            if([defaults objectForKey:@"getOrganizationIpx"]) {
                responseStr = [defaults objectForKey:@"getOrganizationIpx"];
                NSLog(@" response dic %@", responseStr);
            
            
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
            
            NSLog(@" response dic %@", responseDictionary);
            
            if (sharedVideosBtn.selected && offset == 0) {
                [ appDelegate.ipxOrgImagesList removeAllObjects];
            }
            NSDictionary *getOrganizationiPx = [responseDictionary objectForKey:@"ipx"];
            for(NSDictionary *patientApp in getOrganizationiPx) {
                
                
                
                NSString *ipxImageId = [patientApp objectForKey:@"id"];
                
                welvu_ipx_images * welvuiPxModels = [[welvu_ipx_images alloc]
                                                     initWithImageId:[patientApp objectForKey:@"ipx_id"]];
                //welvuiPxModels.ipx_guid =[patientApp objectForKey:@"ipx_guid"];
                welvuiPxModels.ipx_image_thumbnail = [patientApp objectForKey:@"thumbnail"];
                welvuiPxModels.ipx_image_display_name = [patientApp objectForKey:@"title"];
                welvuiPxModels.ipx_Org_VideoDetails = [patientApp objectForKey:@"video_details"];
                welvuiPxModels.ipx_VideoUrl = [patientApp objectForKey:@"videourl"];
                welvuiPxModels.ipx_VideoIds = [patientApp objectForKey:@"video_ids"];
                welvuiPxModels.ipx_image_info =[patientApp objectForKey:@"description"];
                // welvuiPxModels.canDelete = [patientApp objectForKey:@"can_delete"];
                welvuiPxModels.platform_image_id =[patientApp objectForKey:@"id"];
                
                if([self searchImageGroups:welvuiPxModels.ipx_image_info :_rightcurrentData] > -1) {
                    welvuiPxModels.selected = true;
                }
                [ appDelegate.ipxOrgImagesList addObject:welvuiPxModels];
                
                
            }
            
            
             
            [sharedVideoGMGridView reloadData];
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            /* if(([responseDictionary count] > 0)|| (iPxImagesList > 0)) {
             noContentAvailable.hidden = true;
             } else {
             noContentAvailable.hidden = false;
             [self.view bringSubviewToFront:noContentAvailable];
             }*/
            
            if(([responseDictionary count] == 0) && ([ appDelegate.ipxOrgImagesList count] == 0)) {
                noContentAvailable.hidden = false;
                
            } else {
                noContentAvailable.hidden = true;
                [self.view bringSubviewToFront:noContentAvailable];
            }
            
            [sharedVideoGMGridView reloadData];
            sharedVideoGMGridView.hidden = false;
            rightIPXGMGridView.hidden = false;
            [_ptr endRefresh];
            if(_ptr) {
                [_ptr  relocateBottomPullToRefresh];
            }
            
            [defaults removeObjectForKey:@"getOrganizationIpx"];
        }
        
        }else if( connection == getLibraryIpxTopicList) {
           // SBJSON *parser = [[SBJSON alloc] init];
            NSError *error;
            
            if([defaults objectForKey:@"getLibTopic"]) {
                responseStrIpxTps = [defaults objectForKey:@"getLibTopic"];
                NSLog(@" response dic %@", responseStrIpxTps);
            
            //[string dataUsingEncoding:NSUTF8StringEncoding]
            
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[responseStrIpxTps dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableContainers error:&error];
            NSLog(@" response dic %@", responseDictionary);
            
            NSDictionary *getOrganizationiPx = [responseDictionary objectForKey:@"specialties"];
            NSLog(@" getOrganizationiPx %@", getOrganizationiPx);
            for(NSDictionary *patientApp in getOrganizationiPx) {
                
                //welvu_ipx_topics *welvuIpxtopic = [[welvu_ipx_topics alloc]init];
                NSInteger intId = [[patientApp objectForKey:@"id"] intValue];
                NSLog(@" patientApp %d", intId);
                welvu_ipx_topics * welvuIpxtopic = [[welvu_ipx_topics alloc]
                                                    initWithTopicId:intId];
                //welvuIpxtopic = [patientApp objectForKey:@"id"];
                welvuIpxtopic.ipx_topic_name = [patientApp objectForKey:@"name"];
                
                [ appDelegate.iPxLibTopicList addObject:welvuIpxtopic];
                NSLog(@"appDelegate.iPxLibTopicList %@", appDelegate.iPxLibTopicList);
                
            }
            
            [defaults removeObjectForKey:@"getLibTopic"];
        }
        
        }else if ( connection == getLibraryIpx){
            //SBJSON *parser = [[SBJSON alloc] init];
            NSError *error;
            
            if([defaults objectForKey:@"getOrganizationIpx"]) {
                responseStr = [defaults objectForKey:@"getOrganizationIpx"];
            
            
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableContainers error:&error];
            NSLog(@" response dic %@", responseDictionary);
            
            if (videoLibraryBtn.selected && offset == 0) {
                [ appDelegate.iPxLibImagesList removeAllObjects];
            }
            NSDictionary *getOrganizationiPx = [responseDictionary objectForKey:@"ipx"];
            for(NSDictionary *patientApp in getOrganizationiPx) {
                
                NSInteger lastIpxImgId = [welvu_ipx_images getLastInsertRowId:appDelegate.getDBPath];
                NSLog(@" response dic %d", lastIpxImgId);
                NSLog(@" response dic %d", (lastIpxImgId + 1));
                NSInteger lastIpxImgIda = (lastIpxImgId + 1);
                NSString *ipxImageId = [patientApp objectForKey:@"id"];
                
                welvu_ipx_images * welvuiPxModels = [[welvu_ipx_images alloc]
                                                     initWithImageId:lastIpxImgIda];
                welvuiPxModels.iPx_images_id = lastIpxImgIda;
                welvuiPxModels.platform_image_id =[patientApp objectForKey:@"ipx_guid"];
                welvuiPxModels.ipx_image_thumbnail = [patientApp objectForKey:@"thumbnail"];
                welvuiPxModels.ipx_image_display_name = [patientApp objectForKey:@"title"];
                welvuiPxModels.ipx_Org_VideoDetails = [patientApp objectForKey:@"video_details"];
                welvuiPxModels.platform_video_url = [patientApp objectForKey:@"videourl"];
                welvuiPxModels.ipx_VideoUrl = [patientApp objectForKey:@"videourl"];
                welvuiPxModels.ipx_VideoIds = [patientApp objectForKey:@"video_ids"];
                welvuiPxModels.ipx_image_info =[patientApp objectForKey:@"description"];
                // welvuiPxModels.canDelete = [patientApp objectForKey:@"can_delete"];
                welvuiPxModels.platform_image_id =[patientApp objectForKey:@"id"];
                welvuiPxModels.ipx_Specilaty_id = appDelegate.lastSelectedIpxTopicId;
                if([self searchImageGroups:welvuiPxModels.iPx_images_id :_rightcurrentData] > -1) {
                    welvuiPxModels.selected = true;
                }
                NSLog(@"welvuiPxModels.iPx_images_id %@", welvuiPxModels.ipx_image_display_name);
                [ appDelegate.iPxLibImagesList addObject:welvuiPxModels];
                [welvu_ipx_images addIpxImageFromPlatform:appDelegate.getDBPath :welvuiPxModels :LIBRARY_TYPE];
                
                welvu_ipx_images *welvuIpxImages;
            }
            [libcurrentTopicIpx removeAllObjects];
            libcurrentTopicIpx =[welvu_ipx_images getImagesIdBySpecialtyId:appDelegate.getDBPath :appDelegate.lastSelectedIpxTopicId type:LIBRARY_TYPE];
            libTopicTbl.hidden = NO;
            //[libTopicTbl reloadData];
            
             
            [libraryVideoGMGridView reloadData];
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            /* if(([responseDictionary count] > 0)|| (iPxImagesList > 0)) {
             noContentAvailable.hidden = true;
             } else {
             noContentAvailable.hidden = false;
             [self.view bringSubviewToFront:noContentAvailable];
             }*/
            
            if(([responseDictionary count] == 0) && ([ appDelegate.iPxLibImagesList count] == 0)) {
                noContentAvailable.hidden = false;
                
            } else {
                noContentAvailable.hidden = true;
                [self.view bringSubviewToFront:noContentAvailable];
            }
            
            [libraryVideoGMGridView reloadData];
            sharedVideoGMGridView.hidden = true;
            rightIPXGMGridView.hidden = false;
            [_ptr endRefresh];
            if(_ptr) {
                [_ptr  relocateBottomPullToRefresh];
            }
            
            [defaults removeObjectForKey:@"getOrganizationIpx"];
        }
        
        }else if ( connection == getLibraryIpx){
            //SBJSON *parser = [[SBJSON alloc] init];
            NSError *error;
            
            if([defaults objectForKey:@"specialties"]) {
                responseStr = [defaults objectForKey:@"specialties"];
            
            
           NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableContainers error:&error];
            NSLog(@" response specialties %@", responseDictionary);
            
            if (videoLibraryBtn.selected && offset == 0) {
                [ appDelegate.iPxLibImagesList removeAllObjects];
            }
            NSDictionary *getOrganizationiPx = [responseDictionary objectForKey:@"ipx"];
            for(NSDictionary *patientApp in getOrganizationiPx) {
                
            }
        }
        }
    }
    
    [libTopicTbl reloadData];
    
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
    
}

-(void)getOrganizationIpx {
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    NSString *accessToken = nil;
    if(appDelegate.welvu_userModel.access_token == nil) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
    } else {
        accessToken = appDelegate.welvu_userModel.access_token;
    }
    
    
    NSNumber *offsetNumber = [NSNumber numberWithInteger:0];
    
    
    NSString *getString = [NSString stringWithFormat:@"organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
    NSLog(@"get string %@",getString);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PLATFORM_GET_OAUTH_ORGANIZATION_IPX_URL, getString]];
    
    NSLog(@"get string org ipx %@",url);
    /* NSString *getString = [NSString stringWithFormat:@"HTTP_SPECIALTY_ID=%@",[NSNumber numberWithInteger:specialtyId]];
     NSLog(@"get string %@",getString);*/
    
    
    NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
    
    [request setHTTPMethod:HTTP_METHOD_GET];
    
    getOrganizationIpx =
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [getOrganizationIpx start];
    
    
    
}

-(void)getLibraryIpx:(NSInteger)libSpcltId {
    if(spinner == nil) {
        spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view
                                                            :NSLocalizedString(@"PLEASE_WAIT_DOWNLOADING_IPX_VIDEOS", nil;)];
    }
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    NSString *accessToken = nil;
    if(appDelegate.welvu_userModel.access_token == nil) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
    } else {
        accessToken = appDelegate.welvu_userModel.access_token;
    }
    
    
    NSNumber *offsetNumber = [NSNumber numberWithInteger:0];
    
    
    NSString *getString = [NSString stringWithFormat:@"organization_id=%@&specialty_id=%d",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id], libSpcltId];
    NSLog(@"get string %@",getString);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PLATFORM_GET_OAUTH_LIBRARY_IPX_URL, getString]];
    
    NSLog(@"get string %@",url);
    /* NSString *getString = [NSString stringWithFormat:@"HTTP_SPECIALTY_ID=%@",[NSNumber numberWithInteger:specialtyId]];
     NSLog(@"get string %@",getString);*/
    
    
    NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
    
    [request setHTTPMethod:HTTP_METHOD_GET];
    
    getLibraryIpx =
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [getLibraryIpx start];
    
    
    
}

-(void)getLibraryIpxTopicList {
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    NSString *accessToken = nil;
    if(appDelegate.welvu_userModel.access_token == nil) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
    } else {
        accessToken = appDelegate.welvu_userModel.access_token;
    }
    
    
    NSNumber *offsetNumber = [NSNumber numberWithInteger:0];
    
    
    NSString *getString = [NSString stringWithFormat:@"organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
    NSLog(@"get string %@",getString);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PLATFORM_GET_OAUTH_LIBRARY_TOPIC_IPX_URL, getString]];
    
    NSLog(@"getipxlibrarytopics %@",url);
    /* NSString *getString = [NSString stringWithFormat:@"HTTP_SPECIALTY_ID=%@",[NSNumber numberWithInteger:specialtyId]];
     NSLog(@"get string %@",getString);*/
    
    
    NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPMethod:HTTP_METHOD_GET];
    
    getLibraryIpxTopicList =
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [getLibraryIpxTopicList start];
    
    
    
}



-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // NSLog(@"Share Content %@",error);
    [[UIApplication sharedApplication] endBackgroundTask:bti];
    bti = UIBackgroundTaskInvalid;
}

#pragma mark table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [appDelegate.iPxLibTopicList count];
    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    cell.frame = CGRectMake(0, 0, 280, 44);
    cell.textLabel.frame = CGRectMake(0, 0, 280, 44);
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    }
    UIView *backGroundView = [[UIView alloc]initWithFrame:cell.bounds];
    UIImageView  *backgroundViewImageView;
    backgroundViewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    [backGroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SpecialityBg.png"]]];
    cell.backgroundView = backGroundView;
    
    UIView *selectedBackgroundView = [[UIView alloc]initWithFrame:cell.bounds];
    UIImageView  *selectedBackgroundViewImageView;
    selectedBackgroundViewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    [selectedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"PatientSelect.png"]]];
    cell.selectedBackgroundView = selectedBackgroundView;
    cell.textLabel.frame = CGRectMake(0, 0, 280, 44);
    cell.textLabel.textColor = [UIColor blackColor];
    [cell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
    if (!appDelegate.iPxLibTopicList == nil) {
        welvu_ipx_topics *welvuIpxTopics;
       
        welvuIpxTopics = [appDelegate.iPxLibTopicList objectAtIndex:indexPath.row];
        cell.textLabel.text = welvuIpxTopics.ipx_topic_name;
         NSLog(@"indexPath.row %@",welvuIpxTopics.ipx_topic_name);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 44;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL imgsForSpec = false;
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    welvu_ipx_topics *welvuIpxTopics =[appDelegate.iPxLibTopicList objectAtIndex:indexPath.row];
    
    appDelegate.lastSelectedIpxTopicId = welvuIpxTopics.ipx_topic_id;
    NSLog(@"lastSelectedIpxTopicId %d",appDelegate.lastSelectedIpxTopicId);
    welvu_ipx_images *welvuIpxImages;
    
    [libcurrentTopicIpx removeAllObjects];
    
    libcurrentTopicIpx = [welvu_ipx_images getImagesIdBySpecialtyId:appDelegate.getDBPath :appDelegate.lastSelectedIpxTopicId type:LIBRARY_TYPE];
    
    if ([libcurrentTopicIpx count] == 0 ) {
        welvuIpxTopics = [appDelegate.iPxLibTopicList objectAtIndex:indexPath.row];
        [self getLibraryVideosFromPlatform:welvuIpxTopics.ipx_topic_id];
    }else {
        NSLog(@"libcurrentTopicIpx %@",libcurrentTopicIpx);
        [libraryVideoGMGridView reloadData];
    }
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
        [self.view bringSubviewToFront:spinner];
    }
}

@end
