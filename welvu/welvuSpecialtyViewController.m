//
//  welvuDetailViewController.h
//  welvu
//
//  Created by Divya yadav on 27/09/12.
//  Copyright (c) 2012 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvuSpecialtyViewController.h"
#import "welvu_specialty.h"
#import "GAI.h"
#import "welvu_topics.h"
#import "welvu_images.h"
#import "ZipArchive.h"
#import "ReceiptCheck.h"
#import "welvu_patient_Doc.h"
//#import "SBJSON.h"
#import "welvu_organization.h"
#import "PathHandler.h"
#import "welvu_sharevu.h"
#import "welvu_sync.h"
#import "M13ProgressViewBarNavigationControllerViewController.h"
#import "UINavigationController+M13ProgressViewBar.h"
//#import "M13ProgressViewPie.h"
/*#import "FUIAlertView.h"
 #import "UIColor+FlatUI.h"
 #import "UISlider+FlatUI.h"
 #import "UIStepper+FlatUI.h"
 #import "UITabBar+FlatUI.h"
 #import "UINavigationBar+FlatUI.h"
 #import "FUIButton.h"
 #import "FUISwitch.h"
 #import "UIFont+FlatUI.h"
 #import "UIBarButtonItem+FlatUI.h"
 #import "UIProgressView+FlatUI.h"
 #import "FUISegmentedControl.h"
 #import "UIPopoverController+FlatUI.h"*/
/*
 * Class name: welvuSpecialtyViewController
 * Description: Specialty View
 * Extends: nil
 * Delegate : nil
 */
@interface welvuSpecialtyViewController () {
    
    BOOL unarchivedWithoutCorruption;
    int activeSpecilaty;
    
    
}
//InAppPurchaseManager *inApp;
-(NSInteger) searchSpecialtyDefaultId:(NSMutableArray *) specialtyArray;
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation welvuSpecialtyViewController
//Synthesizing the object defined in the interface properties
@synthesize delegate, specialtyTableView, welvu_specialtyModels;
@synthesize internetReach, hostReach;
@synthesize update;
@synthesize fadeColor = fadeColor_;
@synthesize baseColor = baseColor_;
@synthesize  patientBottomFaddingView ,patientTopFaddingView, themeLogo, notificationLable;
@synthesize topFadingView = _topFadingView;
@synthesize bottomFadingView = _bottomFadingView;
@synthesize g1 = g1_;
@synthesize g2 = g2_;
@synthesize g3 = g3_;
@synthesize g4 = g4_;
@synthesize patientIndexPathSelectDefault ,savedIndexPath;
@synthesize selectedIndexPath, totalDownldPercent;
@synthesize  TableHeader ,overVUImage, spinner, activityIndicator;
@synthesize fadeOrientation = fadeOrientation_;
@synthesize isReloaded ,hasPresentedModalMenuView, totalSpcltySze, selectionView;
@synthesize oemrToken,objectsID,PatientimageArray,responseStr, spinnerEMR, loading ,selectedIndexRow, ringprogressView;
/*
 * Method name: initWithNibName
 * Description: initlize with nib name
 * Parameters: nibNameOrNil
 * return id
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    notificationLable.hidden = TRUE;
    if (self) {
        // Custom initialization
        self.fadeOrientation = FADE_TOPNBOTTOM;
        self.baseColor = [UIColor colorWithRed:0.32f green:0.71f blue:0.95f alpha:1.0f];
        selectedIndexRow = -1;
        selectedIndexRow = -1;
        unarchivedWithoutCorruption = true;
        isAlreadyCalled = false;
    }
    
    return self;
}

/*
 * Method name: fadeColor
 * Description: Sets fadeColor to be 10% alpha of baseColor
 * Parameters: nill
 * Return Type: UIColor
 */
-(UIColor*)fadeColor {
    if (fadeColor_ == nil) {
        const CGFloat* components = CGColorGetComponents(self.baseColor.CGColor);
        fadeColor_ = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:CGColorGetAlpha(self.baseColor.CGColor)*.1];
    }
    return fadeColor_;
}


-(CAGradientLayer*)g1 {
    if (g1_ == nil) {
        g1_ = [CAGradientLayer layer];
        
        if (self.fadeOrientation == FADE_LEFTNRIGHT) {
            g1_.startPoint = CGPointMake(0, 0);
            g1_.endPoint = CGPointMake(1.0, 0.5);
        }
        
        g1_.colors = [NSArray arrayWithObjects:(id)[self.baseColor CGColor], (id)[self.fadeColor CGColor], nil];
    }
    return g1_;
}

-(CAGradientLayer*)g2 {
    if (g2_ == nil) {
        g2_ = [CAGradientLayer layer];
        
        if (self.fadeOrientation == FADE_LEFTNRIGHT) {
            g2_.startPoint = CGPointMake(0, 0);
            g2_.endPoint = CGPointMake(1.0, 0.5);
        }
        
        g2_.colors = [NSArray arrayWithObjects: (id)[self.fadeColor CGColor],(id)[self.baseColor CGColor], nil];
    }
    return g2_;
}

-(NSInteger) searchSpecialtyDefaultId:(NSMutableArray *) specialtyArray {
    for(int i=0; i < specialtyArray.count; i++) {
        welvu_specialty *specialty = [specialtyArray objectAtIndex:i];
        if(specialty.welvu_specialty_default) {
            return i;
        }
    }
    return -1;
}

-(NSInteger) searchSpecialtyById:(NSInteger) specId specialty:(NSMutableArray *) specialtyArray {
    
    for(int i=0; i < specialtyArray.count; i++) {
        welvu_specialty *specialty = [specialtyArray objectAtIndex:i];
        if(specialty.welvu_platform_id == specId) {
            return i;
        }
    }
    return -1;
}
#pragma mark View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidden = YES;
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self startUpViewController];
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    
    
    
    int orgCount = [welvu_organization getOrganizationCount:[appDelegate getDBPath]];
    NSLog(@"orgCount %d", orgCount);
    //[syncSpecialty sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    if(appDelegate.welvu_userModel.org_id > 0) {
        
        
        backBtn.hidden = false;
    } else {
        if(appDelegate.orgGoToWelVU) {
            backBtn.hidden = false;
            
        } else {
            backBtn.hidden = TRUE;
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    patientIndexPathSelectDefault = [NSUserDefaults standardUserDefaults];
    [ patientIndexPathSelectDefault synchronize];
    
    //Declaring Page View Analytics
//    
//    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
//                                       value:@"Speciality VU-SPV"];
//    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    if(appDelegate.welvu_userModel.org_id > 0) {
        
        if(!appDelegate.isHelpShown && ![welvu_alerts canAlertShowAgain:appDelegate.getDBPath :ALERT_HELP_OVER_VU] ) {
            helpView.hidden = false;
            syncSpecialty.hidden = YES;
            guideBtn.hidden = YES;
            
        } else {
            helpView.hidden = true;
        } } else {
            helpView.hidden = TRUE;
        }
    // NSLog(@"userid %d" ,appDelegate.welvu_userModel.welvu_user_id);
    
    appDelegate.welvu_userModel.org_id = appDelegate.welvu_userOrganizationModel.orgId;
    welvu_specialtyModels = [welvu_specialty getAllSpecialty:appDelegate.getDBPath
                                                      userId:appDelegate.welvu_userModel.welvu_user_id];
    self.g1.frame = self.topFadingView.frame;
    self.g2.frame = self.bottomFadingView.frame;
    self.g3.frame = self.patientTopFaddingView.frame;
    self.g4.frame = self.patientTopFaddingView.frame;
    
    [self.topFadingView.layer insertSublayer:self.g1 atIndex:0];
    [self.bottomFadingView.layer insertSublayer:self.g2 atIndex:0];
    
    [self.patientTopFaddingView.layer insertSublayer:self.g3 atIndex:0];
    [self.patientBottomFaddingView.layer insertSublayer:self.g4 atIndex:0];
    
    self.topFadingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TopArrowWithBg.png"]];
    self.bottomFadingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"DownArrowWithBg.png"]];
    
    
    self.topFadingView.hidden = true;
    self.bottomFadingView.hidden = true;
    
    self.patientTopFaddingView.hidden = true;
    self.patientBottomFaddingView.hidden = true;
    
    
  
    [self themeSettingsViewControllerDidFinish];
    
}
- (void)viewWillAppear:(BOOL)animated{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]|| [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_EBOLAVU]||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_HEV]) {
        hidePatientView.hidden = YES;
        // goBtn.hidden = YES;
        savedIndexPath = nil;
        hidePatientView.hidden = NO;
        [self loadPatientVU];
        
        
    } else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OPENEMR]||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]
               ||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]){
        savedIndexPath = nil;
        hidePatientView.hidden = NO;
        [self loadPatientVU];
        
    }
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        syncSpecialty.hidden = true;
        
    }

}
//EMR Intigration

-(void)loadPatientVU{
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    NSString *accessToken = nil;
    if(appDelegate.welvu_userModel.access_token == nil) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
    } else {
        accessToken = appDelegate.welvu_userModel.access_token;
    }
    
    //  NSLog( @"access token %@",accessToken);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
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
                
                NSString *getString = [NSString stringWithFormat:@"organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
                NSLog(@"get string %@",getString);
                
                NSURL *url;
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", PLATFORM_GET_OAUTH_LIBRARY_PATIENTS_URL,getString]];
                
                NSLog(@"url %@",url);
                
                NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
                
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
                
                [request setHTTPMethod:HTTP_METHOD_GET];
                
                oauthPatientListConn =
                [[NSURLConnection alloc] initWithRequest:request delegate:self];
                
                [oauthPatientListConn start];
                
                NSLog(@"web service call");
                
            });
        }
        
        else {
            NSString *getString = [NSString stringWithFormat:@"organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
            NSLog(@"get string %@",getString);
            
            NSURL *url;
            
            
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@" , PLATFORM_GET_OAUTH_LIBRARY_PATIENTS_URL,getString]];
            NSLog(@"url %@",url);
            
            NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
            
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
            
            [request setHTTPMethod:HTTP_METHOD_GET];
            
            oauthPatientListConn =
            [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            [oauthPatientListConn start];
            
            
            
        }
    }
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification object: nil];
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    
    
    hostReach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    [hostReach startNotifier];
    
    [self themeSettingsViewControllerDidFinish];
    
    
    
    
    
    
    
    [patientIndexPathSelectDefault removeObjectForKey:@"PatientSelectedIndexRow"];
    [ patientIndexPathSelectDefault synchronize];
    
    middleName=[[NSMutableArray alloc]init];
    lastName=[[NSMutableArray alloc]init];
    objects=[[NSMutableArray alloc]init];
    objectsID=[[NSMutableArray alloc]init];
    PatientimageArray =[[NSMutableArray alloc]init];
    title =[[NSMutableArray alloc]init];
    startTime =[[NSMutableArray alloc]init];
    endTime =[[NSMutableArray alloc]init];
    duration =[[NSMutableArray alloc]init];
    description =[[NSMutableArray alloc]init];
    
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    /*
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
     oemrToken = [defaults stringForKey:@"keyToLookupString"];
     NSLog(@"oemr token %@", appDelegate.welvu_userModel.access_token);
     */

    
    
}

//EMR intigration ends

/*
 * Method name: viewDidUnload
 * Description: to unload the notification
 * Parameters: <#parameters#>
 * return notification
 * Created On: 03-12-2012
 */
- (void)viewDidUnload
{
    [super viewDidUnload];
    
}
/*
 * Method name: viewDidAppear
 * Description: to add observer for notification
 * Parameters:
 * return notification
 * Created On: 03-12-2012
 */
-(void)viewDidAppear:(BOOL)animated
{
    
    // if (!self.hasPresentedModalMenuView) {
    // helpView.hidden = YES;
    [super viewDidAppear:animated];
    appDelegate.currentPatientInfo = nil;
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"TheWelVUMovie" ofType:@"mov"]];
    
    moviePlayer = [[MPMoviePlayerController alloc] init];
    [moviePlayer setContentURL:url];
    
    [moviePlayer setAllowsAirPlay:NO];
    [moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
    [moviePlayer setEndPlaybackTime:-1];
    [moviePlayer setInitialPlaybackTime:-1];
    [moviePlayer setMovieSourceType:MPMovieSourceTypeUnknown];
    [moviePlayer setRepeatMode:MPMovieRepeatModeNone];
    [moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
    [moviePlayer setShouldAutoplay:NO];
    [moviePlayer.view setFrame:CGRectMake(258, 160, 436, 330)];
    [moviePlayer setFullscreen:NO animated:YES];
    
    replayOverlay = [[UIView alloc] initWithFrame:CGRectMake(258, 160, 440, 290)];
    replayOverlay.alpha = 1;
    replayOverlay.backgroundColor = [UIColor clearColor];
    
    
    UIImageView *replayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 436, 290)];
    UIButton *replayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [replayCustomBtn addTarget:self action:@selector(closeOverlay:) forControlEvents:UIControlEventTouchUpInside];
    [replayCustomBtn setFrame:CGRectMake(0, 0, 436, 290)];
    replayImageView.image = [UIImage imageNamed:@"PlayIconSmall.png"];
    
    [replayOverlay addSubview:replayImageView];
    [replayOverlay addSubview:replayCustomBtn];
    
    [helpView addSubview:moviePlayer.view];
    [helpView addSubview:replayOverlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseDoneStringMyprofileUpgrade:)
                                                 name:kProductPurchasedNotificationUpgrade object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseFailedStringMyprofileUpgrade:)
                                                 name:kProductPurchaseFailedNotificationUpgrade object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSpecialty:)
                                                 name:@"AppDidBecomeActive" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInBackground:) name:@"AppDidEnterBackground" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    
    if(!appDelegate.isOrgSubcribed) {
        
        
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        
        appDelegate.isOrgSubcribed = TRUE;
        
        
        update = [welvu_organization getOrganizationCount:[appDelegate getDBPath]];
        
        
        // NSLog(@"userid %d" ,appDelegate.welvu_userModel.welvu_user_id);
        
        
        appDelegate.welvu_userModel.org_id = [welvu_user getOrgIdByWelvuUserId:[appDelegate getDBPath] :appDelegate.welvu_userModel.welvu_user_id];
        welvu_specialtyModels = [welvu_specialty getAllSpecialty:appDelegate.getDBPath
                                                          userId:appDelegate.welvu_userModel.welvu_user_id];
        
        // [self performSelector:@selector(checkAlertForOrgUser) withObject:nil afterDelay:1.0];
    }
    
    //self.hasPresentedModalMenuView = TRUE;
    //}
    /* if ( appDelegate.showGuideSpecialtyVU == 0) {
     [self performSelector:@selector(helpBtnClicked:) withObject:nil];
     appDelegate.showGuideSpecialtyVU = 1;
     }*/
    [self loadPatientVU];
    
    
}
/*
 * Method name: viewWillDisappear
 * Description: to remove observer for notification
 * Parameters:
 * return notification
 * Created On: 03-12-2012
 */
-(void)viewDidDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchasedNotificationUpgrade object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchaseFailedNotificationUpgrade object:nil];
    [notificationLable setAlpha:0.0];
    [super viewDidDisappear:animated];
}

#pragma mark  button Action Methods
//navigate to organization view
-(IBAction)backBtnClicked:(id)sender {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Speciality VU-SPV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Speciality VU-SPV"
                                                          action:@"Back Button - SPV"
                                                           label:@"Back"
                                                           value:nil] build]];
    
    @try {
        
        
        //Check for ShareVU & Platform Sync
        NSInteger syncCount = [welvu_sync getSyncCount:[appDelegate getDBPath]];
        BOOL shareVUStatus = [welvu_sharevu getShareVUQueueByStatus:[appDelegate getDBPath]
                                                             status:WELVU_SHARVU_UNDER_PROGRESS];
        if(!appDelegate.isEMRVUInProgress && !appDelegate.isIPXInProgress
           && syncCount == 0 && !shareVUStatus &&  appDelegate.networkReachable) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:NSLocalizedString(@"ALERT_SWITCH_WELVU_CONFIRMATION_MSG", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                  otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
            alert.tag = 6;
            [alert show];
        } else {
            if(appDelegate.networkReachable) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:nil
                                      message:NSLocalizedString(@"ALERT_SWITCH_ACCOUNT_UNDER_PROGRESS", nil)
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                      otherButtonTitles:nil];
                alert.tag = 7;
                [alert show];
                if(syncCount > 0) {
                    [appDelegate startSyncProcess];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:nil
                                      message:NSLocalizedString(@"ALERT_SHARE_UNDER_PROGRESS_NO_INTERNET_SWITCH_ORG", nil)
                                      delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                      otherButtonTitles:nil];
                [alert show];
            }
        }
        
        
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"SpecialityVU-SPV_Back:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
//App when enters background
-(IBAction)appHasGoneInBackground:(id)sender {
    
    appDelegate.isOrgSubcribed = TRUE;
}
//Sync Specialty
-(IBAction)syncSpecialty:(id)sender {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Speciality VU-SPV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Speciality VU-SPV"
                                                          action:@"Sync Specialty - SPV"
                                                           label:@"Sync"
                                                           value:nil] build]];
    
    @try {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if (!appDelegate.networkReachable){
            /// Create an alert if connection doesn't work
            UIAlertView *myAlert = [[UIAlertView alloc]
                                    initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                    message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                    delegate:self
                                    cancelButtonTitle:@"Ok"
                                    otherButtonTitles:nil];
            [myAlert show];
        } else {
            if(spinner == nil) {
                spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view:NSLocalizedString(@"SYNC_SPECIALTY_SPINNER_MSG", nil)];
            }
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            NSString *accessToken = nil;
            if(appDelegate.welvu_userModel.access_token == nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            } else {
                accessToken = appDelegate.welvu_userModel.access_token;
            }
            
            
            NSDictionary *syncContent = nil;
            HTTPRequestHandler *requestHandler =nil;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
            
            if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
                if([BoxSDK sharedSDK].OAuth2Session.accessToken != nil) {
                    appDelegate.welvu_userModel.box_access_token = [BoxSDK sharedSDK].OAuth2Session.accessToken;
                    appDelegate.welvu_userModel.box_refresh_access_token= [BoxSDK sharedSDK].OAuth2Session.refreshToken;
                    appDelegate.welvu_userModel.box_expires_in =  [BoxSDK sharedSDK].OAuth2Session.accessTokenExpiration;
                    [welvu_user updateBoxAccessToken:[appDelegate getDBPath] :appDelegate.welvu_userModel];
                }
                
                syncContent = [NSDictionary dictionaryWithObjectsAndKeys:
                               accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                               [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                               appDelegate.welvu_userModel.box_access_token ,HTTP_RESPONSE_BOX_ACCESSTOKEN_KEY,
                               appDelegate.welvu_userModel.box_refresh_access_token ,HTTP_RESPONSE_BOX_REFRESH_ACCESSTOKEN_KEY,
                               appDelegate.welvu_userModel.box_expires_in ,HTTP_RESPONSE_BOX_EXPIRES_IN,
                               nil];
                
                
                
                requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                  :PLATFORM_HOST_URL :PLATFORM_GET_BOX_SPECIALTY_ACTION_URL:HTTP_METHOD_POST
                                  :syncContent :nil];
                
                
                requestHandler.delegate = self;
                [requestHandler makeHTTPRequest];
                
            }
            else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
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
                        
                        NSString *getString = [NSString stringWithFormat:@"?organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
                        NSLog(@"get string %@",getString);
                        
                        
                        
                        NSString *combineUrl = [NSString stringWithFormat:@"%@%@",PLATFORM_HOST_URL1, PLATFORM_GET_SPECIALTY_ACTION_URL];
                        NSLog(@"url %@",combineUrl);
                        NSURL *url;
                        
                        
                        
                        
                        
                        
                        if(appDelegate.welvu_userModel.org_id > 0) {
                            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",combineUrl, getString]];
                        } else {
                            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PLATFORM_HOST_URL1, PLATFORM_GET_SPECIALTY_ACTION_URL]];
                        }
                        NSLog(@"url %@",url);
                        
                        NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
                        
                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                        [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
                        
                        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
                        
                        [request setHTTPMethod:HTTP_METHOD_GET];
                        
                        getSpecialty =
                        [[NSURLConnection alloc] initWithRequest:request delegate:self];
                        
                        [getSpecialty start];
                        
                        NSLog(@"web service call");
                        
                    });
                }
                
                else {
                    NSString *getString = [NSString stringWithFormat:@"?organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
                    NSLog(@"get string %@",getString);
                    
                    
                    
                    NSString *combineUrl = [NSString stringWithFormat:@"%@%@",PLATFORM_HOST_URL1, PLATFORM_GET_SPECIALTY_ACTION_URL];
                    NSLog(@"url %@",combineUrl);
                    NSURL *url;
                    
                    
                    
                    
                    
                    
                    if(appDelegate.welvu_userModel.org_id > 0) {
                        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",combineUrl, getString]];
                    } else {
                        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PLATFORM_HOST_URL1, PLATFORM_GET_SPECIALTY_ACTION_URL]];
                    }
                    NSLog(@"url %@",url);
                    
                    NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
                    
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
                    
                    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
                    
                    [request setHTTPMethod:HTTP_METHOD_GET];
                    
                    getSpecialty =
                    [[NSURLConnection alloc] initWithRequest:request delegate:self];
                    
                    [getSpecialty start];
                    
                    
                    
                }
            }
            
            
            
            
            requestHandler.delegate = self;
            [requestHandler makeHTTPRequest];
        }
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"SpecialityVU-SPV_Sync:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
/*
 * Method name: goToSpecialty
 * Description: to navigate to topicVU
 * Parameters: id
 * return IBAction
 
 */

-(IBAction)goToSpecialty:(id)sender {
    
    NSUserDefaults *standaradUserDefault = [NSUserDefaults standardUserDefaults];
    NSInteger row = [standaradUserDefault integerForKey:@"SelectedIndexRowValue"];
    // NSLog(@"row %d" ,row);
    specialtyId = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:row]).welvu_platform_id;
    appDelegate.specialtyId = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:row]).welvu_platform_id;
    BOOL checkFeasibility = [self checkSubscriptionFeasibility:row];
    if(((welvu_specialty *)[welvu_specialtyModels objectAtIndex:row]).welvu_specialty_subscribed
       && checkFeasibility) {
        if(((welvu_specialty *)[welvu_specialtyModels objectAtIndex:row]).welvu_topic_synced) {
            appDelegate.specialtyId = specialtyId;
            [self.delegate specialtyViewControllerDidFinish:YES];
        } else {
            if (!appDelegate.networkReachable){
                /// Create an alert if connection doesn't work
                UIAlertView *myAlert = [[UIAlertView alloc]
                                        initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                        message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                        delegate:self
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
                [myAlert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:NSLocalizedString(@"ALERT_ARCHIVE_TOPIC_SPECIALTY_VU_TITLE", nil)
                                      message:NSLocalizedString(@"ALERT_SPECIALTY_REQUIRES_DOWNLOAD", nil)
                                      delegate: self
                                      cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                      otherButtonTitles:NSLocalizedString(@"DOWNLOAD_NOW", nil),nil];
                [alert show];
            }
        }
    } else if(!((welvu_specialty *)[welvu_specialtyModels objectAtIndex:row]).welvu_specialty_subscribed ||
              !checkFeasibility) {
        
        // NSLog(@" orgid %d",appDelegate.welvu_userModel.org_id);
        
        NSString *orgName = [welvu_organization getOrganizationNameById:[appDelegate getDBPath] :appDelegate.welvu_userModel.org_id];
        
        
        
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"SUBCRIPTION_ENDED", nil)
                              message:[NSString stringWithFormat:
                                       NSLocalizedString(@"PLEASE_CONTACT_YOUR_ADMIN", nil), orgName]
                              delegate: nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil];
        
        [alert show];
        
        
        
    }
    
}

/*
 * Method name: settingBtnClicked
 * Description: To navigate to settings view controller
 * Parameters: id
 * return value :IBAction
 */

-(IBAction)settingBtnClicked:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Speciality VU-SPV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Speciality VU-SPV"
                                                          action:@"Setting Button - SPV"
                                                           label:@"Settings"
                                                           value:nil] build]];
    
    @try {
        welvuSettingsMasterViewController *settingsMasterViewController = [[welvuSettingsMasterViewController alloc]                 initWithNibName:@"welvuSettingsMasterViewController" bundle:nil];
        settingsMasterViewController.delegate = self;
        UINavigationController *cntrol = [[UINavigationController alloc]
                                          initWithRootViewController:settingsMasterViewController];
        [cntrol setNavigationBarHidden:YES];
        cntrol.navigationBar.barStyle = UIBarStyleBlack;
        cntrol.modalPresentationStyle = UIModalPresentationFormSheet;
        cntrol.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:cntrol animated:YES];
        
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"SpecialityVU-SPV_Settings:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

-(IBAction)helpContinueBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Speciality VU-SPV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Speciality VU-SPV"
                                                          action:@"Continue Button - SPV"
                                                           label:@"Get Started"
                                                           value:nil] build]];
    
    
    @try {
        [moviePlayer stop];
        helpView.hidden = true;
        syncSpecialty.hidden=FALSE;
        appDelegate.isHelpShown = true;
        guideBtn.hidden = false;
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"SpecialityVU-SPV_GetStarted:  %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}


-(IBAction)helpBtnClicked:(id)sender {
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Speciality VU-SPV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Speciality VU-SPV"
                                                          action:@"Guide Button  - SPV"
                                                           label:@"Guide"
                                                           value:nil] build]];
    @try {
        
        helpView.hidden = false;
        syncSpecialty.hidden = YES;
        guideBtn.hidden = YES;
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"SpecialityVU-SPV_Guide:  %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}

/*
 * Method name: selectBtnClicked
 * Description: select on any Specialty table cell
 * Parameters: Table cell ID
 * Return Type: IBAction
 */
-(IBAction)selectBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Speciality VU-SPV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Speciality VU-SPV"
                                                          action:@"Select Button - SPV"
                                                           label:@"Specialty"
                                                           value:nil] build]];
    
    
    @try {
        
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"SpecialityVU-SPV_Specialty:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}




/*
 * Method name: dontShowAgainBtnClicked
 * Description: it shows the alert of Donotshowagain
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2012
 */
-(IBAction)dontShowAgainBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Speciality VU-SPV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Speciality VU-SPV"
                                                          action:@"DontShowAgain Button - SPV"
                                                           label:@"AlertDonotshowagain"
                                                           value:nil] build]];
    
    
    @try {
        
        update = [welvu_alerts updateAlertConfirmation:appDelegate.getDBPath :ALERT_HELP_OVER_VU];
        helpView.hidden = true;
        appDelegate.isHelpShown = true;
        
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"SpecialityVU-SPV_DontShowAgainButton-SPV: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
#pragma mark movieplayercontroller
//State of movie palyer
- (void) playbackStateChanged {
    switch (moviePlayer.playbackState) {
        case MPMoviePlaybackStatePaused:{
            if(replayOverlay !=nil) {
                replayOverlay.hidden=FALSE;
            }
            
        }
            break;
        case MPMoviePlaybackStatePlaying:{
            if(replayOverlay !=nil) {
                replayOverlay.hidden=TRUE;
            }
        }
            break;
        case MPMoviePlaybackStateStopped:{
            if(replayOverlay !=nil) {
                replayOverlay.hidden=FALSE;
            }
        }
            break;
            
        default:
            break;
    }
}
//Close the overlay
-(IBAction)closeOverlay:(id)sender
{
    if(replayOverlay !=nil) {
        replayOverlay.hidden=TRUE;
        [moviePlayer prepareToPlay];
        [moviePlayer play];
        
    }
}

#pragma mark delegate methods
/*
 * Method name: settingsMasterViewControllerDidFinish
 * Description: After  data saved to db from settings master view controller
 * Parameters: nil
 * return nil
 */
-(void)settingsMasterViewControllerDidFinish {
    [self themeSettingsViewControllerDidFinish];
    //[self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SETTINGS_UPDATED object:self userInfo:nil];
    
}

/*
 * Method name: themeSettingsViewControllerDidFinish
 * Description: To Display theme of the organization
 * Parameters: nil
 * return nil
 */
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

/*
 * Method name: settingsMasterViewControllerDidCancel
 * Description: while cancel the setting master view controller the view will dismiss
 * Parameters: nil
 * return nil
 */
-(void)settingsMasterViewControllerDidCancel {
    [self dismissModalViewControllerAnimated:YES];
}
/*
 * Method name: logoutUser
 * Description: User can logout from specilaty view controller
 * Parameters: nil
 * return nil
 */
-(void)logoutUser {
    [self.delegate userLoggedOutFromSpecialtyViewController];
}
/*
 * Method name: switchToWelvuUSer
 * Description: User can switch account to view organizatiob from specilaty view controller
 * Parameters: nil
 * return nil
 */
-(void)switchToWelvuUSer {
    [self.delegate userSwitchFromSpecialtyViewController];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]removeObserver:self name: MPMoviePlayerPlaybackDidFinishNotification object:player];
    
    if ([player respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player.view removeFromSuperview];
    } }



#pragma mark UITableView Delegate
/*
 * Method name: numberOfSectionsInTableView
 * Description: Customize the number of sections in the table view.
 * Parameters: UITableView
 * Return Type: IBAction
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if([tableView isEqual:specialtyTableView]) {
        return [welvu_specialtyModels count];
    }else {
        return [objects count];
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([tableView isEqual:specialtyTableView]) {
        return 44;    } else {
            return 44;
            
        }
}
/*
 * Method name: tableView
 * Description: Customize the appearance of table view cells.
 * Parameters: UITableView, NSIndexPath
 * Return Type: cell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [[cell viewWithTag:100] removeFromSuperview];
    [[cell viewWithTag:101] removeFromSuperview];
    [[cell viewWithTag:102] removeFromSuperview];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if([tableView isEqual:specialtyTableView]) {
         selectionView = [[UIView alloc]initWithFrame:cell.bounds];
        
        [self configureCell:cell atIndexPath:indexPath];
        if(appDelegate.specialtydwnlding == true ){
            [self configureDownloadingCell:cell atIndexPath:indexPath];
            
        }else{
            activityIndicator.hidden = true;
        }
        selectionView = [[UIView alloc]initWithFrame:cell.bounds];
        [selectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"PatientSelect.png"]]];
    
        UIView *cellView = [[UIView alloc]initWithFrame:cell.bounds];
        [cellView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SpecialityBg.png"]]];
        
        
        
        cell.backgroundColor = [UIColor clearColor];
       // cell.backgroundView = cellView;
        cell.selectedBackgroundView = selectionView;
        
       /* ringprogressView.frame = CGRectMake(0, 0, 40, 40); ;
        [ringprogressView setProgress:.25 animated:YES];
        ringprogressView.primaryColor =  [UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0];
        // ringprogressView.secondaryColor = self.primaryColor;
        [ringprogressView setNeedsDisplay];
        //[ringprogressView setShowPercentage:YES];
        // ringprogressView.
        [cell bringSubviewToFront:ringprogressView];
        //[self.view addSubview:ringprogressView];
        [ringprogressView setProgress:.25 animated:YES];
        
        [cell addSubview:ringprogressView];*/

        
        
    } else {
        
        cell.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"SpecialityBg.png"]];
        
        //intersystem
        NSString *firstName1=[objects objectAtIndex:indexPath.row];
        NSString *lastName1=[lastName objectAtIndex:indexPath.row];
        
        
        NSString *appStrtTime=[startTime objectAtIndex:indexPath.row];
        NSString *appEndTime=[endTime objectAtIndex:indexPath.row];
        
        NSString *imageFullName=[NSString stringWithFormat:@"%@ %@ ",  firstName1, lastName1];
        UILabel *AlertNameRHS = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 265, 30)];
        AlertNameRHS.text = imageFullName;
        AlertNameRHS.font=[UIFont systemFontOfSize:16.0];
        AlertNameRHS.backgroundColor=[UIColor clearColor];
        //AlertNameRHS.textColor = [UIColor colorWithRed:100.0f/255.0f green:25.0f/255.0f blue:55.0f/255.0f alpha:0.5f];
        // AlertNameRHS.textColor = [UIColor blackColor];
        [AlertNameRHS sizeToFit];
        [AlertNameRHS setTag:100];
        [cell addSubview:AlertNameRHS];
        NSString *imageFullName1;
        if([appStrtTime isEqualToString:@""]&&[appEndTime isEqualToString:@""]) {
            
            imageFullName1 =@"";
        } else {
            imageFullName1=[NSString stringWithFormat:@"%@ to %@ ",  appStrtTime, appEndTime];
        }
        
        UILabel *AlertNameRHS1 = [[UILabel alloc] initWithFrame:CGRectMake(175, 15, 265, 30)];
        AlertNameRHS1.text = imageFullName1;
        AlertNameRHS1.font=[UIFont italicSystemFontOfSize:14.0];
        AlertNameRHS1.backgroundColor=[UIColor clearColor];
        //AlertNameRHS1.textColor = [UIColor colorWithRed:100.0f/255.0f green:25.0f/255.0f blue:55.0f/255.0f alpha:0.5f];
        // AlertNameRHS.textColor = [UIColor blackColor];
        [AlertNameRHS1 sizeToFit];
        [AlertNameRHS1 setTag:101];
        [cell addSubview:AlertNameRHS1];
        
    }
    return cell;
    
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

/*
 * Method name: tableView
 * Description: didSelectRowAtIndexPath
 * Parameters: indexPath
 * return <#value#>
 * Created On: 05-12-2012
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    selectedIndexPath = [tableView indexPathForSelectedRow];
    
    
    
    if([tableView isEqual:specialtyTableView]) {
        specialtyId = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_platform_id;
        
        appDelegate.specialtyId = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_platform_id;
        NSString *SpecialtyName = ((welvu_specialty *)[welvu_specialtyModels
                                                       objectAtIndex:indexPath.row]).welvu_specialty_name;
        
        defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        if([appDelegate.welvu_userModel.user_Org_Role isEqualToString: @"premium"] ){
            int theRow =  indexPath.row;
            // NSLog(@" index path.row %d",theRow);
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:theRow forKey:@"SelectedIndexRowValue"];
            [defaults synchronize];
            [specialtyTableView reloadData];
        } else {
            // NSLog(@"index path %d",indexPath.row);
            int theRow =  indexPath.row;
            // NSLog(@" inddex path.row %d",theRow);
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:theRow forKey:@"SelectedIndexRowValue"];
            [defaults synchronize];
            
            specialtyId = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_platform_id;
            
            appDelegate.specialtyId = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_platform_id;
            BOOL checkFeasibility = [self checkSubscriptionFeasibility:indexPath.row];
            if(((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_specialty_subscribed
               && checkFeasibility) {
                if(((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_topic_synced) {
                    appDelegate.specialtyId = specialtyId;
                    [self.delegate specialtyViewControllerDidFinish:YES];
                } else {
                    if (!appDelegate.networkReachable){
                        /// Create an alert if connection doesn't work
                        UIAlertView *myAlert = [[UIAlertView alloc]
                                                initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                                message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                                delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
                        [myAlert show];
                    } else {
                        
                        
                        UIAlertView *alert = [[UIAlertView alloc]
                                              initWithTitle:NSLocalizedString(@"ALERT_ARCHIVE_TOPIC_SPECIALTY_VU_TITLE", nil)
                                              message:NSLocalizedString(@"ALERT_SPECIALTY_REQUIRES_DOWNLOAD", nil)
                                              delegate: self
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:NSLocalizedString(@"DOWNLOAD_NOW", nil),nil];
                        [alert show];
                    }
                }
            } else if(!((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_specialty_subscribed
                      || !checkFeasibility) {
                
                // NSLog(@" orgid %d",appDelegate.welvu_userModel.org_id);
                
                NSString *orgName = [welvu_organization getOrganizationNameById:[appDelegate getDBPath] :appDelegate.welvu_userModel.org_id];
                
                
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:NSLocalizedString(@"SUBCRIPTION_ENDED", nil)
                                      message:[NSString stringWithFormat:
                                               NSLocalizedString(@"PLEASE_CONTACT_YOUR_ADMIN", nil), orgName]
                                      delegate: self
                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                      otherButtonTitles:nil];
                
                
                [alert show];
                
            }
        }
        
               
        
        
    } else {
        NSNumber *myNumber;
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"PatientSelectedIndexRow"] != nil) {
            // NSLog(@"value is there");
            
            myNumber = [NSNumber numberWithUnsignedInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"PatientSelectedIndexRow"] unsignedIntegerValue]];
            
        } else {
            myNumber ==nil;
            
        }
        
        [patientIndexPathSelectDefault synchronize];
        spinnerEMR.hidden = NO;
        loading.hidden = NO;
        loading.text = @"Loading";
        spinnerEMR.startAnimating;
        spinnerEMR.hidden = YES;
        [patientTableView reloadData];
        loading.hidden = YES;
        UITableViewCell *selectedCell  = [patientTableView cellForRowAtIndexPath:indexPath];
        NSIndexPath *indexPath = [patientTableView indexPathForCell:selectedCell];
        NSInteger indexPathRow =  indexPath.row;
        NSNumber *myNum = [NSNumber numberWithInt:indexPathRow];
        if((myNumber) && ([myNumber isEqual:myNum])){
            
            appDelegate.currentPatientInfo = nil;
            
            UILabel *lblManuName = (UILabel *)[selectedCell viewWithTag:100];
            UILabel *lblManuName1 = (UILabel *)[selectedCell viewWithTag:101];
            UILabel *lblManuName2 = (UILabel *)[selectedCell viewWithTag:102];
            lblManuName.textColor = [UIColor blackColor];
            lblManuName1.textColor = [UIColor blackColor];
            lblManuName2.textColor = [UIColor blackColor];
            selectedCell.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"SpecialityBg.png"]];
            [patientIndexPathSelectDefault removeObjectForKey:@"PatientSelectedIndexRow"];
            [ patientIndexPathSelectDefault synchronize];
            
        } else {
            // NSLog(@"selected index not equal");
            UILabel *lblManuName = (UILabel *)[selectedCell viewWithTag:100];
            UILabel *lblManuName1 = (UILabel *)[selectedCell viewWithTag:101];
            UILabel *lblManuName2 = (UILabel *)[selectedCell viewWithTag:102];
            
            lblManuName.textColor = [UIColor whiteColor];
            lblManuName1.textColor = [UIColor whiteColor];
            lblManuName2.textColor = [UIColor whiteColor];
            selectedCell.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PatientSelect.png"]];
            
            patientID = [objectsID objectAtIndex:indexPath.row];
            
            //  NSLog(@"selectedPatient %@", patientID);
            appDelegate.currentPatientInfo = nil;
            [welvu_patient_Doc  deleteCacheData:[appDelegate getDBPath]];
            [self getPatientDocuments:patientID];
            int theRow =  indexPath.row;
            [ patientIndexPathSelectDefault setInteger:theRow forKey:@"PatientSelectedIndexRow"];
            [patientIndexPathSelectDefault synchronize];
            
        }
    }
}

-(void)getPatientDocuments: (NSString *) patientIDentity{
    
    if(spinner == nil) {
        spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view
                                                            :NSLocalizedString(@"EMR_PLEASE_WAIT_DOWNLOADING_SPINNER_MSG", nil;)];
    }
    {
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
                
                NSString *getString = [NSString stringWithFormat:@"organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
                NSString *getString1 = [NSString stringWithFormat:@"&patientid=%@",patientIDentity];
                NSLog(@"get string %@",getString);
                
                NSURL *url;
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@" , PLATFORM_GET_OAUTH_LIBRARY_PATIENT_DETAILS_URL ,getString ,getString1]];
                
                NSLog(@"url %@",url);
                
                NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
                
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
                
                [request setHTTPMethod:HTTP_METHOD_GET];
                
                oauthPatientDocumentConn =
                [[NSURLConnection alloc] initWithRequest:request delegate:self];
                
                [oauthPatientDocumentConn start];
                
                NSLog(@"web service call");
                
            });
        }
        
        else {
            NSString *getString = [NSString stringWithFormat:@"organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
            NSLog(@"get string %@",getString);
             NSString *getString1 = [NSString stringWithFormat:@"&patientid=%@",patientIDentity];
            NSURL *url;
            
            
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@" , PLATFORM_GET_OAUTH_LIBRARY_PATIENT_DETAILS_URL ,getString,getString1]];
            NSLog(@"url %@",url);
            
            NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
            
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
            
            [request setHTTPMethod:HTTP_METHOD_GET];
            
            oauthPatientDocumentConn =
            [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            [oauthPatientDocumentConn start];
            
            
            
        }
    }

}




#pragma mark UIAlertView Delegate
/*
 * Method name: alertview
 * Description: to display alertview
 * Parameters: buttonindex
 * return <#value#>
 * Created On: 05-12-2012
 
 */


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == 100) {
        if (buttonIndex == 0) {
            
            
        } else if (buttonIndex == 1) {
            NSLog(@"upgrade");
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:URL_UPGRADE]];
            appDelegate.isOrgSubcribed = FALSE;
            
            
            
        }else if (buttonIndex == 2) {
            appDelegate.orgGoToWelVU= TRUE;
            /* welvuSpecialtyViewController * specialtyController = [[welvuSpecialtyViewController alloc]init];
             [self presentModalViewController:specialtyController animated:YES];*/
            NSInteger user_id = 0;
            if(appDelegate.welvu_userModel.org_id > 0) {
                user_id = appDelegate.welvu_userModel.user_primary_key;
                [self logOutExistingUser];
            } else {
                user_id = appDelegate.welvu_userModel.welvu_user_id;
            }
            NSInteger select = [welvu_user updateLoggedUserByOrgId:[appDelegate getDBPath]
                                                            userId:user_id orgId:0 isPrimary:true];
            if (select == 1) {
                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                NSInteger specialtyCount = [welvu_specialty getSpecialtyCount:[appDelegate getDBPath]
                                                                       userId:appDelegate.welvu_userModel.welvu_user_id];
                
                appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                
                [self syncSpecialty:nil];
                
            }
            NSLog(@"gotowelvu");         }
    }
    
    else if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_ARCHIVE_TOPIC_SPECIALTY_VU_TITLE", nil)]) {
        if (buttonIndex == 1) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
            
            if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
                if (!appDelegate.networkReachable){
                    /// Create an alert if connection doesn't work
                    UIAlertView *myAlert = [[UIAlertView alloc]
                                            initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                            message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                            delegate:self
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
                    [myAlert show];
                } else {
                    if(spinner == nil) {
                        spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view
                                                                            :NSLocalizedString(@"PLEASE_WAIT_DOWNLOADING_SPINNER_MSG", nil;)];
                    }
                    [appDelegate startSyncProcess];
                }
            } else {
                [self syncTopicsFromPlatform];
                
                
            }
        } else {
            
        }
    }else if([alertView.title isEqualToString:NSLocalizedString(@"SUBCRIPTION_ENDED", nil)]) {
        if (buttonIndex == 0) {
            
        }else if (buttonIndex == 1) {
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:URL_UPGRADE]];
        }
        
    }
    
    
    if (alertView.tag == 6 && buttonIndex == 1) {
        
        
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        
        
        BOOL switchAccount = [welvu_user switchAccount:[appDelegate getDBPath]];
        
        appDelegate.currentWelvuSettings = [welvu_settings getActiveSettings:[appDelegate getDBPath]];
        
        //[self.delegate userSwitchFromSpecialtyViewController];
        [appDelegate addorganizationDetails];
        
        
    } else if (alertView.tag == 7 && buttonIndex == 0) {
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view];
        }
        [self syncingContentBeforeSwitchAccount];
    }
    
}

#pragma mark delegate methods


- (void) syncingContentBeforeSwitchAccount {
    NSInteger syncCount = [welvu_sync getSyncCount:[appDelegate getDBPath]];
    BOOL shareVUStatus = [welvu_sharevu getShareVUQueueByStatus:[appDelegate getDBPath]
                                                         status:WELVU_SHARVU_UNDER_PROGRESS];
    if(!appDelegate.isEMRVUInProgress && !appDelegate.isIPXInProgress
       && syncCount == 0 && !shareVUStatus) {
        if(spinner != nil) {
            [spinner removeSpinner];
            spinner = nil;
        }
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:NSLocalizedString(@"ALERT_SWITCH_WELVU_CONFIRMATION_MSG", nil)
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"NO", nil)
                              otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        alert.tag = 6;
        [alert show];
    } else {
        [self performSelector:@selector(syncingContentBeforeSwitchAccount) withObject:nil afterDelay:2];
    }
}



/*
 * Method name: LoadIcon
 * Description: loading the view when subcription occur
 * Parameters: <#parameters#>
 * return <#value#>
 * Created On: 05-12-2012
 
 */

-(void)LoadIcon
{
    
    loadingView = [[UIView alloc] init];
    
    if( [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
       [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown)
    {
        loadingView.frame=CGRectMake(339, 467, 90, 90);
    }
    else  if( [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft ||
             [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight)
    {
        loadingView.frame=CGRectMake(467, 339, 90, 90);
        
    }
    
    //       WithFrame:CGRectMake((self.view.frame.size.width/2)-80, (self.view.frame.size.height/2)-80, 80, 80)];
    
    // }
    else {
        loadingView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-40, (self.view.frame.size.height/2)-40, 90, 90)];
    }
    
    [loadingView setBackgroundColor:[UIColor blackColor]];
    //Enable maskstobound so that corner radius would work.
    [loadingView.layer setMasksToBounds:YES];
    //Set the corner radius
    [loadingView.layer setCornerRadius:10.0];
    /*UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityView setFrame:CGRectMake(21, 21, 37, 37)];
    [activityView setHidesWhenStopped:YES];
    [activityView startAnimating];*/
    
    
    
    UILabel * LoadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, 90, 30)];
    LoadingLabel.textColor = [UIColor whiteColor];
    LoadingLabel.numberOfLines = 2;
    LoadingLabel.textAlignment = UITextAlignmentCenter;
    LoadingLabel.text = NSLocalizedString(@"Loading", @"");
    LoadingLabel.font = [UIFont boldSystemFontOfSize:14];
    LoadingLabel.backgroundColor = [UIColor whiteColor];
    [loadingView addSubview:ringprogressView];
    [loadingView addSubview:LoadingLabel];
    [self.view addSubview:loadingView];
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    
}
- (void)configureDownloadingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UIView *spinnerView;
    //NSLog(@"welvuSpecialty.welvu_specialty_id %d",((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_platform_id);
    NSLog(@"downLoadSpecialtyId %d",appDelegate.downLoadSpecialtyId);
    
    if  (appDelegate.downLoadSpecialtyId == ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_platform_id) {
        
        [selectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"TopicListButtonSelected.png"]]];
        UIView *cellView = [[UIView alloc]initWithFrame:cell.bounds];
        [cellView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SpecialityBg.png"]]];
       // activityIndicator.hidden = false;
        activityIndicator.alpha = 1.0;
        activityIndicator.center = CGPointMake(0, 0);
        activityIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5);
        activityIndicator.layer.cornerRadius = 5.0f;
        // activityIndicator.backgroundColor = [UIColor orangeColor];
        activityIndicator.color = [UIColor orangeColor];
        activityIndicator.hidesWhenStopped = NO;
        //  NSLog(@"first view");
        spinnerView = [[UIView alloc] initWithFrame:CGRectMake(215,270 ,20 ,20)];
        //spinnerView.backgroundColor = [UIColor blueColor];
        //[spinnerView addSubview:activityIndicator];
        [self.navigationController showProgress];
        [activityIndicator startAnimating];
        [cell addSubview:spinnerView];
        cell.backgroundView = cellView;
        cell.selectedBackgroundView = selectionView;
//        ringprogressView = [[M13ProgressView alloc] init];
        [cell addSubview:ringprogressView];
        [cell bringSubviewToFront:ringprogressView];
        
        ringprogressView.frame = CGRectMake(200,5, 30, 30);
        
        ringprogressView.backgroundColor = [UIColor colorWithRed:237/255 green:237/255 blue:237/255 alpha:237/255];
        //[ringprogressView setProgress:.25 animated:YES];
        ringprogressView.primaryColor =  [UIColor orangeColor];
        ringprogressView.secondaryColor = [ UIColor lightGrayColor];
        NSLog(@"ringprogressView.backgroundRingWidth %f", ringprogressView.backgroundRingWidth);
        ringprogressView.progressRingWidth = ringprogressView.backgroundRingWidth;
        //ringprogressView.
        // ringprogressView.secondaryColor = self.primaryColor;
        [ringprogressView setNeedsDisplay];
        //[ringprogressView setShowPercentage:YES];
        // ringprogressView.
       // [ringprogressView setProgress:.0 animated:YES];

        //[spinnerView addSubview:dwnloadSpinner];
    }
    
    
    
}

/*
 * Method name: configureCell
 * Description: Custom methods for specialty
 * Parameters: UITableViewCell, NSIndexPath
 * Return Type: nill
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString *SpecialtyName = ((welvu_specialty *)[welvu_specialtyModels
                                                   objectAtIndex:indexPath.row]).welvu_specialty_name;
    
    
    defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    UIView *selectedBackgroundView = [[UIView alloc]initWithFrame:cell.bounds];
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]
       ||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OPENEMR]
       ||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        //santhosh 30 nov
        cell.textLabel.textColor = [UIColor blackColor];
        [cell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
        //30 nov
        NSUserDefaults *standaradUserDefault = [NSUserDefaults standardUserDefaults];
        NSInteger row = [standaradUserDefault integerForKey:@"SelectedIndexRowValue"];
        selectedIndexPath = [specialtyTableView indexPathForSelectedRow];
        [specialtyTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]
                                        animated:NO scrollPosition:0];
        UIView *selectedBackgroundView = [[UIView alloc]initWithFrame:cell.bounds];
        UIImageView  *selectedBackgroundViewImageView;
        selectedBackgroundViewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 19, 19)];
        [selectedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"PatientSelect.png"]]];
        selectedBackgroundViewImageView.image = [UIImage imageNamed:@"RightArrowTable.png"];
        //cell.textLabel.tintColor = [UIColor whiteColor];
        cell.selectedBackgroundView = selectedBackgroundView;
        cell.accessoryView = selectedBackgroundViewImageView;
    }
    cell.textLabel.text = ((welvu_specialty *)[welvu_specialtyModels
                                               objectAtIndex:indexPath.row]).welvu_specialty_name;
    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
    // cell.textLabel.textColor = [UIColor blackColor];
    
    UIImageView  *imageView;
    
    BOOL checkFeasibility = [self checkSubscriptionFeasibility:indexPath.row];
    
    if(!((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_topic_synced
       && (((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_specialty_subscribed)
       && checkFeasibility) {
        //  NSLog(@"first view");
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 19, 19)];
        [selectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"CloudListButton.png"]]];
        imageView.image = [UIImage imageNamed:@"RightArrowTable.png"];
        
    } else if(((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_topic_synced &&
              ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_specialty_subscribed
              && checkFeasibility) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 19, 19)];
        [selectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SpecialityBg.png"]]];
        imageView.image = [UIImage imageNamed:@"RightArrowTable.png"];
        // NSLog(@"second view");
    }
    
    
    else if(!((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_specialty_subscribed
            || !checkFeasibility) {
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 85, 20)];
        [selectionView setBackgroundColor:[UIColor colorWithPatternImage:
                                           [UIImage imageNamed:@"SpecialityBg.png"]]];
        
        // NSLog(@"third view");
        imageView.image = [UIImage imageNamed:@"Spl_lockBgText.png"];
    }
    //cell.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PatientSelect.png"]];
    cell.backgroundView = selectionView;
    cell.accessoryView = imageView;
    cell.tag = ((welvu_specialty *)[welvu_specialtyModels
                                    objectAtIndex:indexPath.row]).welvu_specialty_id;
    
}



/*
 * Method name: scrollViewDidScroll
 * Description: Scroll view for Specialty table
 * Parameters: UIScrollView
 * Return Type: nill
 */

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    if([aScrollView isEqual:specialtyTableView]) {
        
        //   NSLog(@"specialty");
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
        
    } else {
        
        // NSLog(@"PatientList");
        // NSLog(@"specialty");
        CGPoint offset = aScrollView.contentOffset;
        CGRect bounds = aScrollView.bounds;
        CGSize size = aScrollView.contentSize;
        UIEdgeInsets inset = aScrollView.contentInset;
        float y = offset.y + bounds.size.height - inset.bottom;
        float h = size.height;
        
        
        if (aScrollView.contentOffset.y <= 0) {
            self.patientBottomFaddingView.hidden = false;
        }
        
        if(aScrollView.contentOffset.y >= 5) {
            self.patientTopFaddingView.hidden = false;
            self.patientBottomFaddingView.hidden = false;
        }
        
        float reload_distance = 10;
        if(y > h - reload_distance) {
            self.patientTopFaddingView.hidden = false;
            self.patientBottomFaddingView.hidden = true;
        }
        
        if (aScrollView.contentOffset.y <= 0) {
            self.patientTopFaddingView.hidden = true;
        }
        
    }
    
    
}

//Sync Topics From Platform
-(void) syncTopicsFromPlatform {
     [UIApplication sharedApplication].idleTimerDisabled = YES;
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    if (!appDelegate.networkReachable){
        /// Create an alert if connection doesn't work
        UIAlertView* myAlert = [[UIAlertView alloc]
                                initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                delegate:self
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil];
        [myAlert show];
    }else if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
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
            
            appDelegate.downLoadSpecialtyId = specialtyId;
            appDelegate.specialtydwnlding = true;
            [specialtyTableView reloadData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                /*if(spinner == nil) {
                 spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view
                 :NSLocalizedString(@"PLEASE_WAIT_DOWNLOADING_SPINNER_MSG", nil;)];
                 }
                 
                 if (progressView == nil) {
                 progressView = [[ProgressView alloc] initWithFrame:CGRectMake(380, 460, 250, 80)];
                 
                 [self.view addSubview:progressView];
                 
                 [progressView setNeedsDisplay];
                 }*/
                
                //santhosh 30 nov  for display white tint color progress view in ios7
                //ios 7
                NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
                //  NSLog(@"current version %@",currSysVer);
                
                NSArray *arr = [currSysVer componentsSeparatedByString:@"."];
                NSString *versionValue = [arr objectAtIndex:0];
                // NSLog(@"Version Value %@",versionValue);
                UILabel *label = [[UILabel alloc] init];
                if([versionValue isEqualToString: @"7"]) {
                    progressView.backgroundColor = [UIColor clearColor];
                }
                
                
                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                
                appDelegate.downLoadSpecialtyId = specialtyId;
                NSString *getString = [NSString stringWithFormat:@"specialtyid=%@",[NSNumber numberWithInteger:appDelegate.downLoadSpecialtyId]];
                NSLog(@"get string %@",getString);
                
                NSString *getOrgId = [NSString stringWithFormat:@"&organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
                NSLog(@"get getOrgId %@",getOrgId);
                NSURL *url ;
                if(appDelegate.welvu_userModel.org_id >0) {
                    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",PLATFORM_GET_OAUTH_TOPIC_URL, getString,getOrgId]];
                    
                } else {
                    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PLATFORM_GET_OAUTH_TOPIC_URL, getString]];
                }
                
                NSLog(@"get string %@",url);
                // NSString *getString = [NSString stringWithFormat:@"HTTP_SPECIALTY_ID=%@",[NSNumber numberWithInteger:specialtyId]];
                // NSLog(@"get string %@",getString);
                
                
                NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
                
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
                
                [request setHTTPMethod:HTTP_METHOD_GET];
                getTopics = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                
                [getTopics start];
                
                [NSURLConnection sendAsynchronousRequest:request
                                                   queue:[NSOperationQueue currentQueue]
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                           
                                           if (data != nil && error == nil)
                                           {
                                               NSLog(@"done saving file %@",response);
                                               NSString *archiveFileName = [url lastPathComponent];
                                               
                                               // NSArray *paths =
                                               
                                               NSString *path = [NSString stringWithFormat:@"%@/%@",
                                                                 DOCUMENT_DIRECTORY, archiveFileName];
                                               NSString *zipPath = [path stringByAppendingPathComponent:@"zipfile.zip"];
                                               
                                               [data writeToFile:path options:0 error:&error];
                                               [[NSNotificationCenter defaultCenter] addObserver:self
                                                                                        selector: @selector(hi:)
                                                                                            name: @"hi" object: data];
                                               
                                               if(!error)
                                               {
                                                   NSLog(@"done saving file %@",path);
                                                   [self downloadFileDidReceivedData:YES :path];
                                                  /* if(dwnloadSpinner != nil) {
                                                       [dwnloadSpinner removeFromSuperview];
                                                       spinner = nil;
                                                       appDelegate.specialtydwnlding = false;
                                                       [specialtyTableView reloadData];
                                                   }*/
                                               }
                                               else
                                               {
                                                   NSLog(@"Error saving file %@",error);
                                                   appDelegate.specialtydwnlding = false;
                                                   [specialtyTableView reloadData];
                                                   /*if(dwnloadSpinner != nil) {
                                                       [dwnloadSpinner removeFromSuperview];
                                                       spinner = nil;
                                                       appDelegate.specialtydwnlding = false;
                                                       [specialtyTableView reloadData];
                                                   }*/
                                               }
                                               
                                               
                                               
                                           }
                                           else
                                           {
                                               NSLog(@"Error downloading file %@",error);
                                               appDelegate.specialtydwnlding = false;
                                               [specialtyTableView reloadData];
                                              /* if(dwnloadSpinner != nil) {
                                                   [dwnloadSpinner removeFromSuperview];
                                                   spinner = nil;
                                                   appDelegate.specialtydwnlding = false;
                                                   [specialtyTableView reloadData];
                                               }*/
                                           }
                                           
                                       }];
                
                
            });
        }
        
        
        
        else {
            if (appDelegate.specialtydwnlding == true) {
                UIAlertView *myAlert = [[UIAlertView alloc]
                                        initWithTitle:NSLocalizedString(@"Cant download", nil)
                                        message:NSLocalizedString(@"ALERT_SPECIALTY_TOPIC_DOWNLOAD_ERROR_FIREWALL", nil)
                                        delegate:self
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
                [myAlert show];
                
            }else{
                appDelegate.downLoadSpecialtyId = specialtyId;
                appDelegate.specialtydwnlding = true;
                [specialtyTableView reloadData];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                /*    if(spinner == nil) {
                     spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view
                     :NSLocalizedString(@"PLEASE_WAIT_DOWNLOADING_SPINNER_MSG", nil;)];
                     }
                     
                     if (progressView == nil) {
                     progressView = [[ProgressView alloc] initWithFrame:CGRectMake(380, 460, 250, 80)];
                     
                     [self.view addSubview:progressView];
                     
                     [progressView setNeedsDisplay];
                     }*/
                    
                    //santhosh 30 nov  for display white tint color progress view in ios7
                    //ios 7
                    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
                    //  NSLog(@"current version %@",currSysVer);
                    
                    NSArray *arr = [currSysVer componentsSeparatedByString:@"."];
                    NSString *versionValue = [arr objectAtIndex:0];
                    // NSLog(@"Version Value %@",versionValue);
                    UILabel *label = [[UILabel alloc] init];
                    if([versionValue isEqualToString: @"7"]) {
                        progressView.backgroundColor = [UIColor clearColor];
                    }
                    
                    
                    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                    
                    appDelegate.downLoadSpecialtyId = specialtyId;
                    NSString *getString = [NSString stringWithFormat:@"specialtyid=%@",[NSNumber numberWithInteger:appDelegate.downLoadSpecialtyId]];
                    NSLog(@"get string %@",getString);
                    
                    NSString *getOrgId = [NSString stringWithFormat:@"&organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
                    NSLog(@"get getOrgId %@",getOrgId);
                    NSURL *url ;
                    if(appDelegate.welvu_userModel.org_id >0) {
                        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",PLATFORM_GET_OAUTH_TOPIC_URL, getString,getOrgId]];
                        
                    } else {
                        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PLATFORM_GET_OAUTH_TOPIC_URL, getString]];
                    }
                    
                    NSLog(@"get string %@",url);
                    // NSString *getString = [NSString stringWithFormat:@"HTTP_SPECIALTY_ID=%@",[NSNumber numberWithInteger:specialtyId]];
                    // NSLog(@"get string %@",getString);
                    
                    
                    NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
                    
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
                    
                    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
                    
                    [request setHTTPMethod:HTTP_METHOD_GET];
                    getTopics = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                    
                    [getTopics start];
                    
                    [NSURLConnection sendAsynchronousRequest:request
                                                       queue:[NSOperationQueue currentQueue]
                                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                               
                                               if (data != nil && error == nil)
                                               {
                                                   NSLog(@"done saving file %@",response);
                                                   NSString *archiveFileName = [url lastPathComponent];
                                                   
                                                   // NSArray *paths =
                                                   
                                                   NSString *path = [NSString stringWithFormat:@"%@/%@",
                                                                     DOCUMENT_DIRECTORY, archiveFileName];
                                                   NSString *zipPath = [path stringByAppendingPathComponent:@"zipfile.zip"];
                                                   
                                                   [data writeToFile:path options:0 error:&error];
                                                   [[NSNotificationCenter defaultCenter] addObserver:self
                                                                                            selector: @selector(hi:)
                                                                                                name: @"hi" object: data];
                                                   
                                                   if(!error)
                                                   {
                                                       NSLog(@"done saving file %@",path);
                                                       [self downloadFileDidReceivedData:YES :path];
                                                       /*if(dwnloadSpinner != nil) {
                                                           [dwnloadSpinner removeFromSuperview];
                                                           spinner = nil;
                                                           appDelegate.specialtydwnlding = false;
                                                           [specialtyTableView reloadData];
                                                       }*/
                                                   }
                                                   else
                                                   {
                                                       NSLog(@"Error saving file %@",error);
                                                       appDelegate.specialtydwnlding = false;
                                                       [specialtyTableView reloadData];
                                                     /*  if(dwnloadSpinner != nil) {
                                                           [dwnloadSpinner removeFromSuperview];
                                                           spinner = nil;
                                                           appDelegate.specialtydwnlding = false;
                                                           [specialtyTableView reloadData];
                                                       }*/
                                                   }
                                                   
                                                   
                                                   
                                               }
                                               else
                                               {
                                                   NSLog(@"Error downloading file %@",error);
                                                   appDelegate.specialtydwnlding = false;
                                                   [specialtyTableView reloadData];
                                                  /* if(dwnloadSpinner != nil) {
                                                       [dwnloadSpinner removeFromSuperview];
                                                       spinner = nil;
                                                       appDelegate.specialtydwnlding = false;
                                                       [specialtyTableView reloadData];*
                                                   }*/
                                               }
                                               
                                           }];
                    
                    
                });
                
                
                
            }
        }
    }
}



#pragma mark platform Delegate
- (void)syncContentToPlatformDidReceivedData:(BOOL)success :(NSDictionary *)responseDictionary {
    if(success) {
        
        [self.delegate specialtyViewControllerDidFinish:YES];
    }
}

-(void) platformDidResponseReceived:(BOOL)success:(NSString *)actionAPI {
    
    
}
//Receove data from platform
-(void)platformDidReceivedData:(BOOL)success :(NSDictionary *)responseDictionary
                              :(NSString *)actionAPI {
    NSLog(@"response dic %@",responseDictionary);
    
    
    if(responseDictionary && [actionAPI isEqualToString:PLATFORM_GET_TOPICS_ACTION_URL]) {
        HTTPDownloadFileHandler *downloadHandler = [[HTTPDownloadFileHandler alloc]
                                                    initWithDownloadFileDetails:[responseDictionary objectForKey:HTTP_ZIP_URL_KEY]
                                                    :[responseDictionary objectForKey:HTTP_FILE_TYPE_KEY]
                                                    :[[responseDictionary objectForKey:HTTP_FILE_SIZE_KEY] doubleValue]];
        downloadHandler.delegate = self;
        [downloadHandler downloadFileContent];
        responseTopicsDictionary =  [responseDictionary objectForKey:HTTP_DETAILS_KEY];
        
    } else if(responseDictionary && [actionAPI isEqualToString:PLATFORM_SPECIALTY_SUBSCRIBED]) {
        if(((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_topic_synced) {
            /*if(appDelegate.specialtyId != specialtyId) {
             appDelegate.specialtyId = specialtyId;
             [self.delegate specialtyViewControllerDidFinish:YES];
             } else {
             [self.delegate specialtyViewControllerDidFinish:NO];
             }*/
            appDelegate.specialtyId = specialtyId;
            [self.delegate specialtyViewControllerDidFinish:YES];
        } else {
            [self syncTopicsFromPlatform];
        }
    } else if(responseDictionary && [actionAPI isEqualToString:PLATFORM_GET_SPECIALTY_ACTION_URL]
              ||[actionAPI isEqualToString:PLATFORM_GET_BOX_SPECIALTY_ACTION_URL]) {
        //NSMutableArray *welvuSpecialtyModels = [[NSMutableArray alloc] initWithCapacity:[responseDictionary count]];
        welvu_specialtyModels = [welvu_specialty getAllSpecialty:[appDelegate getDBPath]
                                                          userId:appDelegate.welvu_userModel.welvu_user_id];
        BOOL deleteAll = [welvu_specialty deleteSpecialitiesByUserId:[appDelegate getDBPath]
                                                             user_id:appDelegate.welvu_userModel.welvu_user_id];
        for(NSDictionary *welvuSpecialty in responseDictionary) {
            welvu_specialty *welvuSpecialtyModel = [[welvu_specialty alloc] init];
            welvuSpecialtyModel.welvu_platform_id = [[welvuSpecialty objectForKey:HTTP_RESPONSE_ID] integerValue];
            welvuSpecialtyModel.welvu_specialty_name = [welvuSpecialty objectForKey:HTTP_RESPONSE_NAME];
            
            
            int index = [self searchSpecialtyById:welvuSpecialtyModel.welvu_platform_id specialty:welvu_specialtyModels];
            BOOL checkFeasibility = [self checkSubscriptionFeasibility:index];
            
            if(index == -1 || checkFeasibility) {
                [[NSUserDefaults standardUserDefaults] setInteger:0
                                                           forKey:[NSString stringWithFormat:@"Specialty_%d",welvuSpecialtyModel.welvu_platform_id]];
            }
            if(index > -1) {
                welvuSpecialtyModel.welvu_topic_synced = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:index]).welvu_topic_synced;
            }
            /*if([[welvuSpecialty objectForKey:HTTP_RESPONSE_ISDEFAULT] integerValue] == 1) {
             welvuSpecialtyModel.welvu_specialty_default = true;
             } else {
             welvuSpecialtyModel.welvu_specialty_default = false;
             }*/
            if([[welvuSpecialty objectForKey:HTTP_RESPONSE_SUBSCRIBE] integerValue] == 1) {
                welvuSpecialtyModel.welvu_specialty_subscribed = true;
            } else {
                welvuSpecialtyModel.welvu_specialty_subscribed = false;
            }
            
            if([welvuSpecialty objectForKey:HTTP_RESPONSE_PRODUCT_IDENTIFIER]) {
                welvuSpecialtyModel.product_identifier = [welvuSpecialty objectForKey:HTTP_RESPONSE_PRODUCT_IDENTIFIER];
            } else {
                welvuSpecialtyModel.product_identifier = @"";
            }
            if([welvuSpecialty objectForKey:HTTP_RESPONSE_YEARLY_PRODUCT_IDENTIFIER]) {
                welvuSpecialtyModel.yearly_product_identifier = [welvuSpecialty
                                                                 objectForKey:HTTP_RESPONSE_YEARLY_PRODUCT_IDENTIFIER];
            } else {
                welvuSpecialtyModel.yearly_product_identifier = @"";
            }
            
            if(welvuSpecialtyModel.welvu_specialty_subscribed) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
                welvuSpecialtyModel.subscriptionStartDate = [dateFormatter dateFromString:
                                                             [welvuSpecialty objectForKey:HTTP_REQUEST_SUBSCRIPTION_START_DATE]];
                welvuSpecialtyModel.subscriptionEndDate = [dateFormatter dateFromString:
                                                           [welvuSpecialty objectForKey:HTTP_REQUEST_SUBSCRIPTION_END_DATE]];
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"Specialty_%d", specialtyId]];
                [[NSUserDefaults standardUserDefaults] setValue:[welvuSpecialty
                                                                 objectForKey:HTTP_REQUEST_TRANSACTION_RECEIPT]
                                                         forKey:[NSString stringWithFormat:@"Specialty_Receipt_%d",specialtyId]];
            }
            welvuSpecialtyModel.welvu_user_id = appDelegate.welvu_userModel.welvu_user_id;
            BOOL updateOnly = false;
            if([welvu_specialty getSpecialtyNameById:[appDelegate getDBPath]:welvuSpecialtyModel.welvu_platform_id
                                              userId:appDelegate.welvu_userModel.welvu_user_id]) {
                updateOnly = true;
            }
            BOOL updated = [welvu_specialty updateAllSpecialty:[appDelegate getDBPath]
                                                specialtyModel:welvuSpecialtyModel specialtyUpdate:updateOnly];
        }
        if(welvu_specialtyModels) {
            welvu_specialtyModels = nil;
        }
        welvu_specialtyModels = [welvu_specialty getAllSpecialty:[appDelegate getDBPath]
                                                          userId:appDelegate.welvu_userModel.welvu_user_id];
        [specialtyTableView reloadData];
        [self performSelector:@selector(checkAlertForOrgUser) withObject:nil afterDelay:1.0];
        if(spinner != nil) {
            [spinner removeSpinner];
            spinner = nil;
        }
    }
}

-(void)failedWithErrorDetails:(NSError *)error:(NSString *)actionAPI {
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
    if(progressView != nil) {
        [progressView removeFromSuperview];
        progressView = nil;
    }
    
    // NSLog(@"Failed to get Specialty %@", error);
}

-(void)downloadFileDidResponseReceived:(BOOL)success {
}
//Percenatge completion of downloaded file
-(void)downloadFilePercentageCompletion:(float)percentageCompletion {
    NSString *percent=@"%";
    [selectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SpecialityBg.png"]]];
    // NSLog(@"Percentage Downloaded %f", percentageCompletion);
    if(progressView != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressView.progressView.progress = percentageCompletion;
            NSString *percentValue=[NSString stringWithFormat:@"%0.0f%",
                                    (percentageCompletion * 100),100];
            // progressView.progressStatus.text =
            NSString *getPercentage=[percentValue stringByAppendingFormat:@"%@",percent];
            progressView.progressStatus.text =getPercentage;
            NSLog(@"getPercentage %@", getPercentage );
            
            
        });
    }
}

-(void)downloadFileDidReceivedData:(BOOL)success :(NSString *)fileStoredLocation {
    if(success) {
        unarchivedWithoutCorruption = true;
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        zipArchive.delegate = self;
        [zipArchive UnzipOpenFile:fileStoredLocation];
        [zipArchive UnzipFileTo:[NSString stringWithFormat:@"%@/",
                                 DOCUMENT_DIRECTORY] overWrite:YES];
        [zipArchive UnzipCloseFile];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            progressView.progressView.progress = 1.0;
            NSString *percent=@"%";
            NSString *getValue= [NSString stringWithFormat:@"%d / %d ", 100, 100];
            NSString *getTotalPercentage=[getValue stringByAppendingFormat:@"%@",percent];
            progressView.progressStatus.text =getTotalPercentage;
        });
        
        NSString *fileName = @"metadata.json";
        NSString *documentsFolderURL = [NSString stringWithFormat:@"%@/",
                                        DOCUMENT_DIRECTORY];
        NSString *filePath = [documentsFolderURL stringByAppendingString:fileName];
        NSLog(@"filePath %@",filePath);
        NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
        NSError *jsonError;
        NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
        
        
        
        if(unarchivedWithoutCorruption) {
            for(NSDictionary *welvuTopic in jsonDict) {
                
                welvu_topics *welvuTopicModel = nil;
                if([welvuTopic objectForKey:HTTP_REQUEST_TOPIC_GUID]) {
                    welvuTopicModel = [[welvu_topics alloc] init];
                    welvuTopicModel.topics_guid = [welvuTopic objectForKey:HTTP_REQUEST_TOPIC_GUID];
                    welvuTopicModel.topic_is_user_created = true;
                } else {
                    welvuTopicModel = [[welvu_topics alloc] initWithTopicId
                                       :[[welvuTopic objectForKey:HTTP_RESPONSE_ID] integerValue]];
                    welvuTopicModel.topic_is_user_created = false;
                }
                welvuTopicModel.topicName = [welvuTopic objectForKey:HTTP_RESPONSE_TITLE];
                //NeedToCheck
                welvuTopicModel.specialty_id = appDelegate.downLoadSpecialtyId;
                welvuTopicModel.topicInfo = [welvuTopic objectForKey:HTTP_RESPONSE_INFO];
                
                if([[welvuTopic objectForKey:HTTP_RESPONSE_ACTIVE] integerValue] == 1) {
                    welvuTopicModel.topic_active = true;
                } else {
                    welvuTopicModel.topic_active = false;
                }
                welvuTopicModel.topic_hit_counter = 0;
                
                
                
                welvuTopicModel.topic_default_order = [[welvuTopic objectForKey:HTTP_RESPONSE_ORDER] integerValue];
                if([[welvuTopic objectForKey:HTTP_REQUEST_LOCKED] integerValue] == 1) {
                    welvuTopicModel.is_locked = true;
                } else {
                    welvuTopicModel.is_locked = false;
                }
                welvuTopicModel.welvu_user_id = appDelegate.welvu_userModel.welvu_user_id;
                BOOL insert;
                if([welvuTopic objectForKey:HTTP_REQUEST_TOPIC_GUID]) {
                    
                    NSInteger topicId = [welvu_topics addNewTopic:[appDelegate getDBPath]:welvuTopicModel:welvuTopicModel.specialty_id];
                    welvuTopicModel = [welvu_topics setTopicId:welvuTopicModel :topicId];
                    if(topicId > 0) {
                        insert = true;
                    }
                } else {
                    
                    insert = [welvu_topics addTopicFromPlatform:[appDelegate getDBPath]:welvuTopicModel];
                }
                if(insert) {
                    NSDictionary *mediaDatas = [welvuTopic objectForKey:HTTP_RESPONSE_MEDIAS];
                    for(NSDictionary *welvuImage in mediaDatas) {
                        welvu_images *welvuImagesModel = [[welvu_images alloc] initWithImageId
                                                          :[[welvuImage objectForKey:HTTP_RESPONSE_ID] integerValue]];
                        
                        
                        welvuImagesModel.topicId = welvuTopicModel.topicId;
                        welvuImagesModel.orderNumber = [[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_ORDER] integerValue];
                        welvuImagesModel.imageDisplayName = [welvuImage objectForKey:HTTP_RESPONSE_URL];
                        
                        NSString* outputPath = [NSString stringWithFormat:@"%@/%@",
                                                DOCUMENT_DIRECTORY, [welvuImage objectForKey:HTTP_RESPONSE_URL]];
                        welvuImagesModel.url = [welvuImage objectForKey:HTTP_RESPONSE_URL];
                        welvuImagesModel.welvu_user_id = appDelegate.welvu_userModel.welvu_user_id;
                        BOOL inserted;
                        if([welvuImage objectForKey:HTTP_REQUEST_CONTENT_GUID]) {
                            if([[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_TYPE] isEqualToString:IMAGE_ASSET_TYPE]) {
                                welvuImagesModel.type = IMAGE_ALBUM_TYPE;
                            } else if([[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_TYPE] isEqualToString:IMAGE_VIDEO_TYPE]) {
                                welvuImagesModel.type = IMAGE_VIDEO_ALBUM_TYPE;
                            }
                            welvuImagesModel.image_guid = [welvuImage objectForKey:HTTP_REQUEST_CONTENT_GUID];
                            inserted = [welvu_images
                                        addNewImageToTopic:[appDelegate getDBPath]
                                        :welvuImagesModel
                                        :welvuTopicModel.topicId];
                        } else {
                            if([[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_TYPE] isEqualToString:IMAGE_ASSET_TYPE]) {
                                welvuImagesModel.type = IMAGE_ASSET_TYPE;
                            } else if([[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_TYPE] isEqualToString:IMAGE_VIDEO_TYPE]) {
                                welvuImagesModel.type = IMAGE_VIDEO_TYPE;
                            }
                            inserted = [welvu_images
                                        addImageToTopicFromPlatform:[appDelegate getDBPath]
                                        :welvuImagesModel
                                        :welvuTopicModel.topicId];
                        }
                    }
                    //[welvuTopicModel release];
                }
            }
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            [welvu_specialty updateSyncedSpecialty:[appDelegate getDBPath]:appDelegate.downLoadSpecialtyId
                                            userId:appDelegate.welvu_userModel.welvu_user_id];
            
            NSString *accessToken = nil;
            if(appDelegate.welvu_userModel.access_token == nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            } else {
                accessToken = appDelegate.welvu_userModel.access_token;
            }
            
            // NSLog( @"access token %@",accessToken);
            
            NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                          accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                          [NSNumber numberWithInteger:appDelegate.downLoadSpecialtyId], HTTP_SPECIALTY_ID,
                                          [self getDeviceUDID], HTTP_REQUEST_DEVICE_ID,
                                          [NSNumber numberWithInt:1], HTTP_RESPONSE_STATUS_KEY,nil];
            
            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
            if(appDelegate.welvu_userModel.org_id > 0) {
                [requestDataMutable
                 setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                 forKey:HTTP_REQUEST_ORGANISATION_KEY];
            }
            
            HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                  :PLATFORM_HOST_URL:PLATFORM_GET_TOPICS_RECEIVED_ACTION_URL:HTTP_METHOD_POST
                                                  :requestDataMutable :nil];
            [requestHandler makeHTTPRequest];
        }
    } else {
        UIAlertView *myAlert = [[UIAlertView alloc]
                                initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                message:NSLocalizedString(@"ALERT_SPECIALTY_TOPIC_DOWNLOAD_ERROR_FIREWALL", nil)
                                delegate:self
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil];
        [myAlert show];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileStoredLocation])
    {
        [[NSFileManager defaultManager] removeItemAtPath:fileStoredLocation error:nil];
    }
    
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
    if(progressView != nil) {
        [progressView removeFromSuperview];
        progressView = nil;
    }
    
    if(success && unarchivedWithoutCorruption) {
        appDelegate.specialtyId = appDelegate.downLoadSpecialtyId;
        [self.delegate specialtyViewControllerDidFinish:YES];
    }
    
}

-(NSString *)getDeviceUDID {
    NSString * udid = @"";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    defaults = [NSUserDefaults standardUserDefaults];
    udid = [defaults stringForKey:@"userDeviceID"];
    // NSLog(@"Specialty UDID %@", udid);
    return udid;
}

-(void)downloadFilefailedWithErrorDetails:(NSError *)error {
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
    if(progressView != nil) {
        [progressView removeFromSuperview];
        progressView = nil;
    }
    UIAlertView *myAlert = [[UIAlertView alloc]
                            initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                            message:NSLocalizedString(@"ALERT_SPECIALTY_TOPIC_DOWNLOAD_ERROR", nil)
                            delegate:nil
                            cancelButtonTitle:@"Ok"
                            otherButtonTitles:nil];
    [myAlert show];
    
}

-(void) ErrorMessage:(NSString*) msg {
    unarchivedWithoutCorruption = false;
    UIAlertView *myAlert = [[UIAlertView alloc]
                            initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                            message:NSLocalizedString(@"ALERT_SPECIALTY_TOPIC_DOWNLOAD_ERROR", nil)
                            delegate:self
                            cancelButtonTitle:@"Ok"
                            otherButtonTitles:nil];
    [myAlert show];
}


#pragma mark INAPP

/*
 * Method name: purchaseDoneStringMyprofileUpgrade
 * Description: Purchase Done
 * Parameters: nc
 * return welvu_specialty_id
 * Created On: 07-12-2012
 */

- (void)purchaseDoneStringMyprofileUpgrade:(NSNotification *)nc {
    
    /*if(update > 0 && welvu_specialtyModels != nil) {;
     [welvu_specialtyModels release], welvu_specialtyModels = nil;
     }*/
}
-(void)InAppPurchaseManagerDidFinish:(BOOL)purchasedSuccessfully receipt:(NSString *)transactionRecipt {
    [loadingView removeFromSuperview];
    if(purchasedSuccessfully && !isAlreadyCalled) {
        isAlreadyCalled = true;
        
        NSDate *subscriptionStartDate = [NSDate date];
        NSDate *subscriptionEndDate;
        NSString *productIdentifier;
        if(!((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).yearlySubscription) {
            productIdentifier = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).product_identifier;
            subscriptionEndDate = [subscriptionStartDate dateByAddingTimeInterval:3600*24*30];
        } else {
            productIdentifier = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).yearly_product_identifier;
            subscriptionEndDate = [subscriptionStartDate dateByAddingTimeInterval:3600*24*365];
        }
        //NeedToCheck
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
        BOOL insert = [welvu_topics updateLock:[appDelegate getDBPath] specialty:specialtyId setLock:false
                                        userId:appDelegate.welvu_userModel.welvu_user_id];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"Specialty_%d", specialtyId]];
        [[NSUserDefaults standardUserDefaults] setValue:transactionRecipt
                                                 forKey:[NSString stringWithFormat:@"Specialty_Receipt_%d",specialtyId]];
        if(insert) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
            NSString *validFrom = [dateFormatter stringFromDate:subscriptionStartDate];
            NSString *validTill = [dateFormatter stringFromDate:subscriptionEndDate];
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            specialtyId = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_platform_id;
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            NSString *accessToken = nil;
            if(appDelegate.welvu_userModel.access_token == nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            } else {
                accessToken = appDelegate.welvu_userModel.access_token;
            }
            
            // NSLog( @"access token %@",accessToken);
            NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                          accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                          productIdentifier, HTTP_RESPONSE_PRODUCT_IDENTIFIER,
                                          [NSNumber numberWithInteger:specialtyId], HTTP_SPECIALTY_ID,
                                          validFrom, HTTP_REQUEST_SUBSCRIPTION_START_DATE,
                                          validTill, HTTP_REQUEST_SUBSCRIPTION_END_DATE,
                                          transactionRecipt, HTTP_REQUEST_TRANSACTION_RECEIPT,nil];
            
            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
            if(appDelegate.welvu_userModel.org_id > 0) {
                [requestDataMutable
                 setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                 forKey:HTTP_REQUEST_ORGANISATION_KEY];
            }
            
            HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                  :PLATFORM_HOST_URL:PLATFORM_SPECIALTY_SUBSCRIBED:HTTP_METHOD_POST
                                                  :requestDataMutable :nil];
            requestHandler.delegate = self;
            [requestHandler makeHTTPRequest];
            
            update =[welvu_specialty updateSubscribedSpecialty:appDelegate.getDBPath specialtyId:specialtyId
                                         subscriptionStartDate:subscriptionStartDate subscriptionEndDate:subscriptionEndDate
                                                        userId:appDelegate.welvu_userModel.welvu_user_id];
        }
    }
}
/*
 * Method name: purchaseFailedStringMyprofileUpgrade
 * Description: Purchase Failed
 * Parameters: nc
 * return nil
 * Created On: 06-12-2012
 */
- (void)purchaseFailedStringMyprofileUpgrade:(NSNotification *)nc
{
    
    // NSLog(@"Purchase Failed !");
    [loadingView  removeFromSuperview];
    // NSLog(@"PurchaseFailed Details %@", [nc userInfo]);
    /*UIAlertView *myAlert = [[UIAlertView alloc]
     initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
     message:NSLocalizedString(@"ALERT_PURCHASE_FAILED_MSG", nil)
     delegate:self
     cancelButtonTitle:@"Ok"
     otherButtonTitles:nil];
     [myAlert show];
     
     [myAlert release];*/
}

/*
 * Method name: buyCredits
 * Description: has to buy credit i.e has to call inapppurchasemanager
 * Parameters: app
 * return product identifier
 * Created On: 04-12-2012
 */
/*
 -(void)buyCredits {
 if (!inApp) {
 inApp = [[InAppPurchaseManager alloc] init];
 inApp.delegate = self;
 }
 if(!((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).yearlySubscription) {
 
 [inApp buyProductIdentifier:((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).product_identifier
 NotficationIdent:@"Upgrade" specialtyId:specialtyId];
 } else {
 [inApp buyProductIdentifier:((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).yearly_product_identifier
 NotficationIdent:@"Upgrade" specialtyId:specialty_id];
 }
 
 } */
//Check user subcribed the purchase or not

-(BOOL)checkSubscriptionFeasibility:(NSInteger)index {
    BOOL valid = false;
    defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    if(appDelegate.welvu_userModel.org_id > 0) {
        
        //BOOL valid = true;
        
        if(index > -1 && ![bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
            welvu_specialty *specId = ((welvu_specialty *)[welvu_specialtyModels
                                                           objectAtIndex:index]);
            NSDate *subscriptionStartDate = ((welvu_specialty *)[welvu_specialtyModels
                                                                 objectAtIndex:index]).subscriptionStartDate;
            NSDate *subscriptionEndDate = ((welvu_specialty *)[welvu_specialtyModels
                                                               objectAtIndex:index]).subscriptionEndDate;
            
            //GMT Date
            
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmt];
            [dateFormatter setDateFormat:SERVER_DATE_COMPARE_FORMAT];
            NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
            // NSLog(@"gmt date %@" ,timeStamp);
            
            NSDate *dateFromString = [[NSDate alloc] init];
            dateFromString = [dateFormatter dateFromString:timeStamp];
            // NSLog(@"dateFromString%@",dateFromString);
            
            
            NSDate *dateFromString1 = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
            
            // NSLog(@"dateFromString1%@",dateFromString1);
            
            //START SUBCRIPTION DATE
            NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
            [startDateFormatter setDateFormat:SERVER_DATE_COMPARE_FORMAT];
            NSDate *startServerDate = [NSString stringWithFormat:@"%@",[startDateFormatter stringFromDate:subscriptionStartDate]];
            
            // NSLog(@"startServerDate%@",startServerDate);
            
            //END SUBCRIPTION DATE
            NSDateFormatter *endDateFormatter = [[NSDateFormatter alloc] init];
            [endDateFormatter setDateFormat:SERVER_DATE_COMPARE_FORMAT];
            NSDate *endServerDate = [NSString stringWithFormat:@"%@",[endDateFormatter stringFromDate:subscriptionEndDate]];
            
            // NSLog(@"endServerDate%@",endServerDate);
            
            
            NSComparisonResult startCompare = [startServerDate compare: dateFromString1];
            NSComparisonResult endCompare = [endServerDate compare: dateFromString1];
            
            NSComparisonResult endDateCompare = [endServerDate compare: dateFromString1];
            
            if(startCompare == NSOrderedAscending  && endCompare == NSOrderedSame){
                valid = true;
                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                BOOL insert = [welvu_topics updateLock:[appDelegate getDBPath]
                                             specialty:specId.welvu_specialty_id setLock:false
                                                userId:appDelegate.welvu_userModel.welvu_user_id];
            }
            else if(startCompare == NSOrderedSame  && endCompare == NSOrderedDescending){
                valid = true;
                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                BOOL insert = [welvu_topics updateLock:[appDelegate getDBPath]
                                             specialty:specId.welvu_specialty_id setLock:false
                                                userId:appDelegate.welvu_userModel.welvu_user_id];
            }
            
            else if (startCompare == NSOrderedAscending && endCompare == NSOrderedDescending)
            {
                valid = true;
                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                BOOL insert = [welvu_topics updateLock:[appDelegate getDBPath]
                                             specialty:specId.welvu_specialty_id setLock:false
                                                userId:appDelegate.welvu_userModel.welvu_user_id];
            } else if (endDateCompare == NSOrderedAscending ){
                
                if (!appDelegate.networkReachable){
                    /// Create an alert if connection doesn't work
                    /*UIAlertView *myAlert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                     message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                     delegate:self
                     cancelButtonTitle:@"Ok"
                     otherButtonTitles:nil];
                     [myAlert show];*/
                } else {
                    if([[NSUserDefaults standardUserDefaults] objectForKey:
                        [NSString stringWithFormat:@"Specialty_Receipt_%d",specId.welvu_platform_id]]) {
                        ReceiptCheck *checker = [[ReceiptCheck alloc] initWithReceiptHandler:
                                                 [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Specialty_Receipt_%d",specId.welvu_platform_id]]
                                                                                 specialtyId:specId.welvu_platform_id];
                        if(checker.statusCode == 0 || checker.statusCode == 21006) {
                            valid = true;
                        }
                        
                        if(checker.statusCode == 21006) {
                            NSString *productId = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Specialty_IDentifier_%d",specId.welvu_platform_id]];
                            NSDate *subscriptionStartDate = [NSDate date];
                            NSDate *subscriptionEndDate;
                            NSString *productIdentifier;
                            if([specId.product_identifier isEqualToString:productId]) {
                                productIdentifier = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).product_identifier;
                                subscriptionEndDate = [subscriptionStartDate dateByAddingTimeInterval:3600*24*30];
                            } else {
                                productIdentifier = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).yearly_product_identifier;
                                subscriptionEndDate = [subscriptionStartDate dateByAddingTimeInterval:3600*24*365];
                            }
                            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                            BOOL insert = [welvu_topics updateLock:[appDelegate getDBPath]
                                                         specialty:specId.welvu_specialty_id setLock:false
                                                            userId:appDelegate.welvu_userModel.welvu_user_id];
                            [[NSUserDefaults standardUserDefaults] setInteger:0
                                                                       forKey:[NSString stringWithFormat:@"Specialty_%d", specId.welvu_platform_id]];
                            if(insert) {
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
                                NSString *validFrom = [dateFormatter stringFromDate:subscriptionStartDate];
                                NSString *validTill = [dateFormatter stringFromDate:subscriptionEndDate];
                                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                                NSString *transactionRecipt = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Specialty_Receipt_%d",specId.welvu_platform_id]];
                                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                                NSString *accessToken = nil;
                                if(appDelegate.welvu_userModel.access_token == nil) {
                                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                                    accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                                } else {
                                    accessToken = appDelegate.welvu_userModel.access_token;
                                }
                                
                                //  NSLog( @"access token %@",accessToken);
                                NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                                              accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                                              productIdentifier, HTTP_RESPONSE_PRODUCT_IDENTIFIER,
                                                              [NSNumber numberWithInteger:specId.welvu_specialty_id], HTTP_SPECIALTY_ID,
                                                              validFrom, HTTP_REQUEST_SUBSCRIPTION_START_DATE,
                                                              validTill, HTTP_REQUEST_SUBSCRIPTION_END_DATE,
                                                              transactionRecipt, HTTP_REQUEST_TRANSACTION_RECEIPT,
                                                              nil];
                                
                                NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
                                if(appDelegate.welvu_userModel.org_id > 0) {
                                    [requestDataMutable
                                     setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                                     forKey:HTTP_REQUEST_ORGANISATION_KEY];
                                }
                                
                                HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                                      :PLATFORM_HOST_URL:PLATFORM_SPECIALTY_SUBSCRIBED:HTTP_METHOD_POST
                                                                      :requestDataMutable :nil];
                                requestHandler.delegate = self;
                                [requestHandler makeHTTPRequest];
                                
                                update =[welvu_specialty updateSubscribedSpecialty:appDelegate.getDBPath specialtyId:specialtyId
                                                             subscriptionStartDate:subscriptionStartDate subscriptionEndDate:subscriptionEndDate
                                                                            userId:appDelegate.welvu_userModel.welvu_user_id];
                            }
                        }
                        
                        NSLog(@"valid not true");
                    }
                }
            }
            
            
        } }else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
            valid = true;
        }else {
            valid = true;
        }
    
    
    return valid;
}

#pragma mark NSURL Connection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"connection %@", connection);
     NSLog(@"response %@", response);
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger statusCode = [httpResponse statusCode];
    if (connection == getTopics) {
        NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
        NSLog(@"1 %@", [headers objectForKey:@"Content-Length"]);
        totalSpcltySze =  [[headers objectForKey:@"Content-Length"] integerValue];
        
        
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        if( connection == oauthPatientDocumentConn) {
            {
                NSError *error= nil;
                if([defaults objectForKey:@"oauthPatientDocConn"]) {
                    responseStr = [defaults objectForKey:@"oauthPatientDocConn"];
                }
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
                NSLog(@" response dic %@", responseDictionary);
                
                appDelegate.currentPatientGraphInfo = [responseDictionary objectForKey:@"vitals"];
                appDelegate.currentPatientInfo = [responseDictionary objectForKey:@"demographics"];
                // NSLog(@"current patient info %@",appDelegate.currentPatientInfo);
                patientImages = [responseDictionary objectForKey:@"documents"];
                // NSLog(@"%@", [responseDictionary objectForKey:@"documents"]);
                
                if ((NSNull *)patientImages == [NSNull null]){
                    //  NSLog(@"Patient image null");
                    
                } else {
                    for (NSDictionary *patientDoc in patientImages) {
                        patientImageUrl = [patientDoc objectForKey:HTTP_RESPONSE_URL];
                        NSString *type = [patientDoc objectForKey:HTTP_RESPONSE_MEDIA_TYPE];
                        [[NSUserDefaults standardUserDefaults] setObject:type
                                                                  forKey:@"media_type"];
                        //NSLog(@"patientImageUrl %@", patientImageUrl);
                        NSURL *ImageURL = [NSURL URLWithString: patientImageUrl];
                        //generating unique name for the cached file with ImageURLString so you can retrive it back
                        NSArray *parts = [patientImageUrl componentsSeparatedByString:@"/"];
                        NSString *filename = [parts objectAtIndex:[parts count]-1];
                        
                        uniquePath = [CACHE_DIRECTORY stringByAppendingPathComponent: filename];
                        
                        //IMAGE_VIDEO_TYPE
                        if([[patientDoc objectForKey:HTTP_RESPONSE_MEDIA_TYPE]
                            isEqualToString:IMAGE_ASSET_TYPE]) {
                            NSData *data = [[NSData alloc] initWithContentsOfURL: ImageURL];
                            UIImage *image = [[UIImage alloc] initWithData: data];
                            
                            if([[patientDoc objectForKey:HTTP_RESPONSE_MIME_TYPE] isEqualToString:HTTP_ATTACHMENT_IMAGE_CONTENT_TYPE_PNG_KEY]) {
                                [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
                            } else if([[patientDoc objectForKey:HTTP_RESPONSE_MIME_TYPE]
                                       isEqualToString: HTTP_ATTACHMENT_IMAGE_CONTENT_TYPE_KEY]) {
                                [UIImageJPEGRepresentation(image, 100) writeToFile:uniquePath
                                                                        atomically: YES];
                            }
                            [self saveImagePath];
                        } else if([[patientDoc objectForKey:HTTP_RESPONSE_MEDIA_TYPE]
                                   isEqualToString:IMAGE_VIDEO_TYPE]){
                            NSData *data = [[NSData alloc] initWithContentsOfURL: ImageURL];
                            int copied = [data writeToFile:uniquePath atomically:YES];
                            
                            [self saveImagePath];
                            
                        }
                        
                        if (spinner != nil) {
                            [spinner removeSpinner];
                            spinner = nil;
                        }
                    }
                }
                [defaults removeObjectForKey:@"oauthPatientDocConn"];
            }
            
        }
        
        else if( connection == oauthPatientListConn) {
            NSError *error= nil;
            responseStr = nil;
            NSLog(@"responseStr %@", responseStr);
            NSData *data = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"data %@", data);
            
            if([defaults objectForKey:@"oauthpatientListConn"]) {
                responseStr = [defaults objectForKey:@"oauthpatientListConn"];
                NSLog(@"responseStr %@", responseStr);
           
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            NSLog(@" response dic %@", responseDictionary);
            
            NSString * responseStatus = [responseDictionary objectForKey:@"title"];
            if([responseStatus isEqualToString:@"Forbidden"]) {
                
                
                
            } else {
                NSDictionary *getPatientList = [responseDictionary objectForKey:@"patients"];
                
                
                //  NSLog(@" response dic %@", responseDictionary);
                for(NSDictionary *patient in getPatientList) {
                    //             patientID = [patient objectForKey:@"id"];
                    //  NSLog(@"Patient id: %@", patientID);
                    [objects addObject:[patient objectForKey:@"firstname"]];
                    [lastName addObject:[patient objectForKey:@"lastname"]];
                    [objectsID addObject:[patient objectForKey:@"id"]];
                    [startTime addObject:[patient objectForKey:@"start_time"]];
                    [endTime addObject:[patient objectForKey:@"end_time"]];
                    patientAppointmentLabel.hidden = YES;
                }
                spinnerEMR.hidden = NO;
                loading.hidden = NO;
                loading.text = @"Loading";
                spinnerEMR.startAnimating;
                
                [patientTableView reloadData];
                
                spinnerEMR.hidden = YES;
                loading.hidden = YES;
                [defaults removeObjectForKey:@"oauthpatientListConn"];
            }
        }
            
        }
        else if( connection == getSpecialty) {
            NSError *error= nil;
            if([defaults objectForKey:@"getSpecialties"]) {
                responseStr = [defaults objectForKey:@"getSpecialties"];
            }
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
            NSLog(@" response dic %@", responseDictionary);
            
            
            welvu_specialtyModels = [welvu_specialty getAllSpecialty:[appDelegate getDBPath]
                                                              userId:appDelegate.welvu_userModel.welvu_user_id];
            BOOL deleteAll = [welvu_specialty deleteSpecialitiesByUserId:[appDelegate getDBPath]
                                                                 user_id:appDelegate.welvu_userModel.welvu_user_id];
            
            NSDictionary *getSpecialties = [responseDictionary objectForKey:@"specialties"];
            for(NSDictionary *welvuSpecialty in getSpecialties) {
                welvu_specialty *welvuSpecialtyModel = [[welvu_specialty alloc] init];
                welvuSpecialtyModel.welvu_platform_id = [[welvuSpecialty objectForKey:HTTP_RESPONSE_ID] integerValue];
                welvuSpecialtyModel.welvu_specialty_name = [welvuSpecialty objectForKey:HTTP_RESPONSE_NAME];
                
                
                int index = [self searchSpecialtyById:welvuSpecialtyModel.welvu_platform_id specialty:welvu_specialtyModels];
                BOOL checkFeasibility = [self checkSubscriptionFeasibility:index];
                
                if(index == -1 || checkFeasibility) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0
                                                               forKey:[NSString stringWithFormat:@"Specialty_%d",welvuSpecialtyModel.welvu_platform_id]];
                }
                if(index > -1) {
                    welvuSpecialtyModel.welvu_topic_synced = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:index]).welvu_topic_synced;
                }
                /*if([[welvuSpecialty objectForKey:HTTP_RESPONSE_ISDEFAULT] integerValue] == 1) {
                 welvuSpecialtyModel.welvu_specialty_default = true;
                 } else {
                 welvuSpecialtyModel.welvu_specialty_default = false;
                 }*/
                if([[welvuSpecialty objectForKey:HTTP_RESPONSE_SUBSCRIBE] integerValue] == 1) {
                    welvuSpecialtyModel.welvu_specialty_subscribed = true;
                } else {
                    welvuSpecialtyModel.welvu_specialty_subscribed = false;
                }
                
                if([welvuSpecialty objectForKey:HTTP_RESPONSE_PRODUCT_IDENTIFIER]) {
                    welvuSpecialtyModel.product_identifier = [welvuSpecialty objectForKey:HTTP_RESPONSE_PRODUCT_IDENTIFIER];
                } else {
                    welvuSpecialtyModel.product_identifier = @"";
                }
                if([welvuSpecialty objectForKey:HTTP_RESPONSE_YEARLY_PRODUCT_IDENTIFIER]) {
                    welvuSpecialtyModel.yearly_product_identifier = [welvuSpecialty
                                                                     objectForKey:HTTP_RESPONSE_YEARLY_PRODUCT_IDENTIFIER];
                } else {
                    welvuSpecialtyModel.yearly_product_identifier = @"";
                }
                
                if(welvuSpecialtyModel.welvu_specialty_subscribed) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
                    welvuSpecialtyModel.subscriptionStartDate = [dateFormatter dateFromString:
                                                                 [welvuSpecialty objectForKey:HTTP_REQUEST_SUBSCRIPTION_START_DATE]];
                    welvuSpecialtyModel.subscriptionEndDate = [dateFormatter dateFromString:
                                                               [welvuSpecialty objectForKey:HTTP_REQUEST_SUBSCRIPTION_END_DATE]];
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"Specialty_%d", specialtyId]];
                    [[NSUserDefaults standardUserDefaults] setValue:[welvuSpecialty
                                                                     objectForKey:HTTP_REQUEST_TRANSACTION_RECEIPT]
                                                             forKey:[NSString stringWithFormat:@"Specialty_Receipt_%d",specialtyId]];
                }
                welvuSpecialtyModel.welvu_user_id = appDelegate.welvu_userModel.welvu_user_id;
                BOOL updateOnly = false;
                if([welvu_specialty getSpecialtyNameById:[appDelegate getDBPath]:welvuSpecialtyModel.welvu_platform_id
                                                  userId:appDelegate.welvu_userModel.welvu_user_id]) {
                    updateOnly = true;
                }
                BOOL updated = [welvu_specialty updateAllSpecialty:[appDelegate getDBPath]
                                                    specialtyModel:welvuSpecialtyModel specialtyUpdate:updateOnly];
            }
            if(welvu_specialtyModels) {
                welvu_specialtyModels = nil;
            }
            welvu_specialtyModels = [welvu_specialty getAllSpecialty:[appDelegate getDBPath]
                                                              userId:appDelegate.welvu_userModel.welvu_user_id];
            [specialtyTableView reloadData];
            [self checkAlertForOrgUser];
            
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            [defaults removeObjectForKey:@"getSpecialties"];
        }
        
        
        else if( connection == getTopics) {
            appDelegate.specialtydwnlding = false;
            [specialtyTableView reloadData];
            ringprogressView.indeterminate = true;
             [UIApplication sharedApplication].idleTimerDisabled = YES;
        }
    }else if(([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]
              ||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) && connection == patientListConn) {
        NSError *error= nil;
        if([defaults objectForKey:@"patientListConn"]) {
            responseStr = [defaults objectForKey:@"patientListConn"];
        }
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        //  NSLog(@" response dic %@", responseDictionary);
        for(NSDictionary *patient in responseDictionary) {
            //             patientID = [patient objectForKey:@"id"];
            //  NSLog(@"Patient id: %@", patientID);
            [objects addObject:[patient objectForKey:@"firstname"]];
            [lastName addObject:[patient objectForKey:@"lastname"]];
            [objectsID addObject:[patient objectForKey:@"id"]];
            [startTime addObject:[patient objectForKey:@"start_time"]];
            [endTime addObject:[patient objectForKey:@"end_time"]];
            
        }
        
        spinnerEMR.hidden = NO;
        loading.hidden = NO;
        loading.text = @"Loading";
        spinnerEMR.startAnimating;
        
        [patientTableView reloadData];
        
        spinnerEMR.hidden = YES;
        loading.hidden = YES;
        [defaults removeObjectForKey:@"patientListConn"];
        
    } else if (([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]
                ||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX])
               && connection == PatientDocConn) {
        NSError *error = nil;
        if([defaults objectForKey:@"PatientDocConn"]) {
            responseStr = [defaults objectForKey:@"PatientDocConn"];
        }
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        // NSLog(@" response dic %@", responseDictionary);
        
        appDelegate.currentPatientGraphInfo = [responseDictionary objectForKey:@"vitals"];
        appDelegate.currentPatientInfo = [responseDictionary objectForKey:@"demographics"];
        // NSLog(@"current patient info %@",appDelegate.currentPatientInfo);
        patientImages = [responseDictionary objectForKey:@"documents"];
        //  NSLog(@"%@", [responseDictionary objectForKey:@"documents"]);
        
        if ((NSNull *)patientImages == [NSNull null]){
            // NSLog(@"Patient image null");
            
        } else {
            for (NSDictionary *patientDoc in patientImages) {
                patientImageUrl = [patientDoc objectForKey:HTTP_RESPONSE_URL];
                NSString *type = [patientDoc objectForKey:HTTP_RESPONSE_MEDIA_TYPE];
                [[NSUserDefaults standardUserDefaults] setObject:type
                                                          forKey:@"media_type"];
                // NSLog(@"patientImageUrl %@", patientImageUrl);
                NSURL *ImageURL = [NSURL URLWithString: patientImageUrl];
                //generating unique name for the cached file with ImageURLString so you can retrive it back
                NSArray *parts = [patientImageUrl componentsSeparatedByString:@"/"];
                NSString *filename = [parts objectAtIndex:[parts count]-1];
                uniquePath = [CACHE_DIRECTORY stringByAppendingPathComponent: filename];
                //IMAGE_VIDEO_TYPE
                if([[patientDoc objectForKey:HTTP_RESPONSE_MEDIA_TYPE]
                    isEqualToString:IMAGE_ASSET_TYPE]) {
                    NSData *data = [[NSData alloc] initWithContentsOfURL: ImageURL];
                    UIImage *image = [[UIImage alloc] initWithData: data];
                    
                    if([[patientDoc objectForKey:HTTP_RESPONSE_MIME_TYPE] isEqualToString:HTTP_ATTACHMENT_IMAGE_CONTENT_TYPE_PNG_KEY]) {
                        [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
                    } else if([[patientDoc objectForKey:HTTP_RESPONSE_MIME_TYPE]
                               isEqualToString: HTTP_ATTACHMENT_IMAGE_CONTENT_TYPE_KEY]) {
                        [UIImageJPEGRepresentation(image, 100) writeToFile:uniquePath
                                                                atomically: YES];
                    }
                    [self saveImagePath];
                } else if([[patientDoc objectForKey:HTTP_RESPONSE_MEDIA_TYPE]
                           isEqualToString:IMAGE_VIDEO_TYPE]){
                    NSData *data = [[NSData alloc] initWithContentsOfURL: ImageURL];
                    int copied = [data writeToFile:uniquePath atomically:YES];
                    [self saveImagePath];
                }
                
                if (spinner != nil) {
                    [spinner removeSpinner];
                    spinner = nil;
                }
            }
        }
        [defaults removeObjectForKey:@"PatientDocConn"];
    }
    //EMR
    else if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OPENEMR] && connection == patientListConn) {
        NSError *error = nil;
        if([defaults objectForKey:@"patientListConn"]) {
            responseStr = [defaults objectForKey:@"patientListConn"];
        }
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        // NSLog(@" response dic %@", responseDictionary);
        NSDictionary *patients = [responseDictionary objectForKey:@"appointments"];
        for(NSDictionary *patient in patients) {
            patientID = [patient objectForKey:@"id"];
            // NSLog(@"Patient id: %@", patientID);
            [objects addObject:[patient objectForKey:@"firstname"]];
            [middleName addObject:[patient objectForKey:@"middlename"]];
            [lastName addObject:[patient objectForKey:@"lastname"]];
            [objectsID addObject:[patient objectForKey:@"id"]];
            [title addObject:[patient objectForKey:@"app_title"]];
            [startTime addObject:[patient objectForKey:@"start_time"]];
            [endTime addObject:[patient objectForKey:@"end_time"]];
            [duration addObject:[patient objectForKey:@"duration"]];
            [description addObject:[patient objectForKey:@"app_description"]];
            
        }
        spinnerEMR.hidden = NO;
        loading.hidden = NO;
        loading.text = @"Loading";
        spinnerEMR.startAnimating;
        
        [patientTableView reloadData];
        
        spinnerEMR.hidden = YES;
        loading.hidden = YES;
        [defaults removeObjectForKey:@"patientListConn"];
        
    } else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OPENEMR]&& connection == PatientDocConn) {
        NSError *error = nil;
        if([defaults objectForKey:@"PatientDocConn"]) {
            responseStr = [defaults objectForKey:@"PatientDocConn"];
        }
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        //NSLog(@" response dic %@", responseDictionary);
        
        appDelegate.currentPatientGraphInfo = [responseDictionary objectForKey:@"vitals"];
        appDelegate.currentPatientInfo = [responseDictionary objectForKey:@"demographics"];
        // NSLog(@"current patient info %@",appDelegate.currentPatientInfo);
        patientImages = [responseDictionary objectForKey:@"documents"];
        // NSLog(@"%@", [responseDictionary objectForKey:@"documents"]);
        
        if ((NSNull *)patientImages == [NSNull null]){
            //  NSLog(@"Patient image null");
            
        } else {
            for (NSDictionary *patientDoc in patientImages) {
                patientImageUrl = [patientDoc objectForKey:HTTP_RESPONSE_URL];
                NSString *type = [patientDoc objectForKey:HTTP_RESPONSE_MEDIA_TYPE];
                [[NSUserDefaults standardUserDefaults] setObject:type
                                                          forKey:@"media_type"];
                //NSLog(@"patientImageUrl %@", patientImageUrl);
                NSURL *ImageURL = [NSURL URLWithString: patientImageUrl];
                //generating unique name for the cached file with ImageURLString so you can retrive it back
                NSArray *parts = [patientImageUrl componentsSeparatedByString:@"/"];
                NSString *filename = [parts objectAtIndex:[parts count]-1];
                
                uniquePath = [CACHE_DIRECTORY stringByAppendingPathComponent: filename];
                
                //IMAGE_VIDEO_TYPE
                if([[patientDoc objectForKey:HTTP_RESPONSE_MEDIA_TYPE]
                    isEqualToString:IMAGE_ASSET_TYPE]) {
                    NSData *data = [[NSData alloc] initWithContentsOfURL: ImageURL];
                    UIImage *image = [[UIImage alloc] initWithData: data];
                    
                    if([[patientDoc objectForKey:HTTP_RESPONSE_MIME_TYPE] isEqualToString:HTTP_ATTACHMENT_IMAGE_CONTENT_TYPE_PNG_KEY]) {
                        [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
                    } else if([[patientDoc objectForKey:HTTP_RESPONSE_MIME_TYPE]
                               isEqualToString: HTTP_ATTACHMENT_IMAGE_CONTENT_TYPE_KEY]) {
                        [UIImageJPEGRepresentation(image, 100) writeToFile:uniquePath
                                                                atomically: YES];
                    }
                    [self saveImagePath];
                } else if([[patientDoc objectForKey:HTTP_RESPONSE_MEDIA_TYPE]
                           isEqualToString:IMAGE_VIDEO_TYPE]){
                    NSData *data = [[NSData alloc] initWithContentsOfURL: ImageURL];
                    int copied = [data writeToFile:uniquePath atomically:YES];
                    
                    [self saveImagePath];
                    
                }
                
                if (spinner != nil) {
                    [spinner removeSpinner];
                    spinner = nil;
                }
            }
        }
        [defaults removeObjectForKey:@"PatientDocConn"];
    }
}
- (void)connection:(NSURLConnection *) theConnection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *) challenge
{
#pragma unused(theConnection, challenge)
    
    NSLog(@"In Will send function");
    
    NSLog(@"%@", challenge.protectionSpace);
    
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    NSError *error = nil;
    if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        if(connection == oauthPatientDocumentConn) {
           // SBJSON *parser = [[SBJSON alloc] init];
            NSError *error = nil;
            
            defaults = [NSUserDefaults standardUserDefaults];
            NSString* newStr = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            if([defaults objectForKey:@"oauthPatientDocConn"]) {
                responseStr = [defaults objectForKey:@"oauthPatientDocConn"];
            } else {
                responseStr = [[NSString alloc] init];
            }
            responseStr = [responseStr stringByAppendingString:newStr];
           
            [defaults setObject:responseStr forKey:@"oauthPatientDocConn"];
            
            NSLog(@"defaults %@", defaults);
            
            
        }else if( connection == oauthPatientListConn) {
            NSError *error = nil;
            
            defaults = [NSUserDefaults standardUserDefaults];
            NSString* newStr = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            if([defaults objectForKey:@"oauthpatientListConn"]) {
                responseStr = [defaults objectForKey:@"oauthpatientListConn"];
            } else {
                responseStr = [[NSString alloc] init];
            }
            responseStr = [responseStr stringByAppendingString:newStr];
            [defaults setObject:responseStr forKey:@"oauthpatientListConn"];
            
            
            
            
        }else if( connection == getSpecialty) {
            NSError *error = nil;
            
            defaults = [NSUserDefaults standardUserDefaults];
            NSString* newStr = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            if([defaults objectForKey:@"getSpecialties"]) {
                responseStr = [defaults objectForKey:@"getSpecialties"];
            } else {
                responseStr = [[NSString alloc] init];
            }
            responseStr = [responseStr stringByAppendingString:newStr];
            [defaults setObject:responseStr forKey:@"getSpecialties"];
            
            
            
            
        }else if( connection == getTopics) {
            NSLog(@"%.2f",(float)data.length);
            
            
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    float percentageCompletion = ((float)data.length/totalSpcltySze);
                   
                    NSString *percentValue=[NSString stringWithFormat:@"%0.0f%",
                                            (percentageCompletion * 100),100];
                    // progressView.progressStatus.text =
                   // NSString *getPercentage=[percentValue stringByAppendingFormat:@"%@",percent];
                    //NSLog(@"percentValue %.2f",(percentageCompletion * 100) );
                    totalDownldPercent = totalDownldPercent + (percentageCompletion) ;
                    NSLog(@"totalDownldPercent %.2f ",totalDownldPercent );
                    [ specialtyTableView reloadData];
                    [ringprogressView setProgress:totalDownldPercent animated:YES];
                    
                    
                });
            
        }
    }else if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]
             ||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        if(data) {
            if (connection == patientListConn){
                NSError *error;
                defaults = [NSUserDefaults standardUserDefaults];
                NSString* newStr = [[NSString alloc] initWithData:data
                                                         encoding:NSUTF8StringEncoding];
                if([defaults objectForKey:@"patientListConn"]) {
                    responseStr = [defaults objectForKey:@"patientListConn"];
                } else {
                    responseStr = [[NSString alloc] init];
                }
                responseStr = [responseStr stringByAppendingString:newStr];
                [defaults setObject:responseStr forKey:@"patientListConn"];
            } else if (connection == PatientDocConn) {
                NSError *error;
                defaults = [NSUserDefaults standardUserDefaults];
                NSString* newStr = [[NSString alloc] initWithData:data
                                                         encoding:NSUTF8StringEncoding];
                if([defaults objectForKey:@"PatientDocConn"]) {
                    responseStr = [defaults objectForKey:@"PatientDocConn"];
                } else {
                    responseStr = [[NSString alloc] init];
                }
                responseStr = [responseStr stringByAppendingString:newStr];
                [defaults setObject:responseStr forKey:@"PatientDocConn"];
            }
        }
    } else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OPENEMR]) {
        if(data) {
            if (connection == patientListConn){
                NSError *error;
                defaults = [NSUserDefaults standardUserDefaults];
                NSString* newStr = [[NSString alloc] initWithData:data
                                                         encoding:NSUTF8StringEncoding];
                if([defaults objectForKey:@"patientListConn"]) {
                    responseStr = [defaults objectForKey:@"patientListConn"];
                } else {
                    responseStr = [[NSString alloc] init];
                }
                responseStr = [responseStr stringByAppendingString:newStr];
                [defaults setObject:responseStr forKey:@"patientListConn"];
            } else if (connection == PatientDocConn) {
                NSError *error;
                defaults = [NSUserDefaults standardUserDefaults];
                NSString* newStr = [[NSString alloc] initWithData:data
                                                         encoding:NSUTF8StringEncoding];
                if([defaults objectForKey:@"PatientDocConn"]) {
                    responseStr = [defaults objectForKey:@"PatientDocConn"];
                } else {
                    responseStr = [[NSString alloc] init];
                }
                responseStr = [responseStr stringByAppendingString:newStr];
                [defaults setObject:responseStr forKey:@"PatientDocConn"];
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
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

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (void)orientationChanged:(NSNotification *)notification {
    [self shouldAutorotate];
}
- (void)startUpViewController {
    isLandScapeMode = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}
#pragma mark rechability Change
- (void) reachabilityChanged: (NSNotification* )note {
    Reachability* curReach = [note object];
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    if(netStatus == NotReachable) {
        networkReachable = false;
    } else {
        networkReachable = true;
    }
}
-(void)saveImagePath {
    // NSLog(@"unque path %@",uniquePath);
    BOOL userId= [welvu_patient_Doc insertCacheData:appDelegate.getDBPath :patientID :uniquePath];
    // NSLog(@"Bool value: %d",userId);
    
}

//To show alert for user when organization specialty gets locked
-(void)checkAlertForOrgUser {
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    // NSLog(@"welvu specialty %@",welvu_specialtyModels);
    welvu_specialty *welvuSpecilaty;
    
    if(appDelegate.welvu_userModel.org_id > 0) {
        welvu_specialty *welvuSpecilaty;
        
        for (welvuSpecilaty in welvu_specialtyModels) {
            
            NSDate * subscriptionEndDate = welvuSpecilaty.subscriptionEndDate;
            
            NSDateFormatter *endDateFormatter = [[NSDateFormatter alloc] init];
            [endDateFormatter setDateFormat:SERVER_DATE_COMPARE_FORMAT];
            NSDate *endServerDate = [NSString stringWithFormat:@"%@",[endDateFormatter stringFromDate:subscriptionEndDate]];
            
            // NSLog(@"end date%@",endServerDate);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmt];
            [dateFormatter setDateFormat:SERVER_DATE_COMPARE_FORMAT];
            NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
            // NSLog(@"gmt date %@" ,timeStamp);
            NSDate *dateFromString = [[NSDate alloc] init];
            dateFromString = [dateFormatter dateFromString:timeStamp];
            // NSLog(@"dateFromString%@",dateFromString);
            
            
            NSDate *dateFromString1 = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
            
            // NSLog(@"gmt date%@",dateFromString1);
            
            
            NSComparisonResult startCompare = [endServerDate compare: dateFromString1];
            if (startCompare == NSOrderedDescending || startCompare == NSOrderedSame) {
                activeSpecilaty ++;
                // NSLog(@"activeSpecilaty %d" ,activeSpecilaty);
                
            }
            
        }
        
        if (activeSpecilaty <= 0) {
            
            // NSLog(@" orgid %d",appDelegate.welvu_userModel.org_id);
            
            NSString *orgName = [welvu_organization getOrganizationNameById:[appDelegate getDBPath] :appDelegate.welvu_userModel.org_id];
            
            
            
            dismissAlert = [[UIAlertView alloc]
                            initWithTitle: nil
                            message:[NSString stringWithFormat:
                                     NSLocalizedString(@"ALERT_ALL_SPECIALTY_LOCKED_ORG", nil), orgName]
                            delegate: self
                            cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                            otherButtonTitles:NSLocalizedString(@"UPGRADE", nil), NSLocalizedString(@"GOTOWELVU", nil),nil];
            dismissAlert.tag = 100;
            [dismissAlert show];
            
        }
        activeSpecilaty = 0;
        
    }
    
}


/*
 * Method name: logOutExistingUser
 * Description:To log out Existing user.
 * Parameters: nil
 * return nil
 */
-(void)logOutExistingUser{
    BOOL logoutUser = [welvu_user logoutUser:[appDelegate getDBPath] :appDelegate.welvu_userModel];
    //BOOL resetCompleted = [welvu_settings logoutUserResetTable:[appDelegate getDBPath]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * udid = [[defaults stringForKey:@"userDeviceID"] copy];
    NSString * currSysVer = [[defaults stringForKey:@"currentiOSVersion"] copy];
    NSString * prevSysVer = [[defaults stringForKey:@"previousiOSVersion"] copy];
    
    appDelegate.welvu_userModel = nil;
    appDelegate.isHelpShown = FALSE;
    appDelegate.ispatientVUContent = FALSE;
    appDelegate.isExportInProcess = FALSE;
    appDelegate.imageId = -1;
    appDelegate.recordCounter = 0;
    appDelegate.accessToken = nil;
    appDelegate.specialtyId = 0;
    appDelegate.currentWelvuSettings = nil;
    appDelegate.currentMasterScreen = 0;
    appDelegate.currentPatientInfo =  nil;
    appDelegate.currentPatientGraphInfo = nil;
    appDelegate.currentPatientAppointments = nil;
    appDelegate.isPatientSelected = nil;
    appDelegate.org_Logo = nil;
    appDelegate.welvu_userModel.org_id =nil;
    //Remove Database
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
}

- (void)applicationDidEnterBackground:(NSNotification *)theNotification {
    NSInteger cancelButtonIndex = dismissAlert.cancelButtonIndex;
    [dismissAlert dismissWithClickedButtonIndex:cancelButtonIndex
                                       animated:NO];
}

-(void)reloadSpecialty:(NSNotification *)notify {
    [specialtyTableView reloadData];
    appDelegate.isOrgSubcribed = TRUE;
    
}
@end
