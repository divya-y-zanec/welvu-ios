//
//  welvuAppDelegate.m
//  welvu
//
//  Created by Logesh Kumaraguru on 15/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvuAppDelegate.h"
#import "welvuContants.h"
#import "welvuMasterViewController.h"
#import "welvuDetailViewControllerIpad.h"
#import "welvu_app_version.h"
#import "ZipArchive.h"
#import "HTTPDownloadFileHandler.h"
#import "NSFileManagerDoNotBackup.h"
#import "Guid.h"
#import "welvu_sync.h"
#import "welvu_images.h"
#import "BoxNavigationController.h"
#import "KeychainItemWrapper.h"
#import "PathHandler.h"
#import "iRate.h"
#import "UIDeviceHardware.h"
//#import <SBJSON.h>



#define REFRESH_TOKEN_KEY   (@"box_api_refresh_token")


@interface welvuAppDelegate ()

@property (nonatomic, readwrite, strong) KeychainItemWrapper *keychain;
- (void)boxAPITokensDidRefresh:(NSNotification *)notification;
@end

@implementation welvuAppDelegate

@synthesize welvu_userModel;
@synthesize currentWelvuSettings;
@synthesize window = _window;
@synthesize splitViewController = _splitViewController, masterViewController, orgViewController;
@synthesize isHelpShown;
@synthesize ispatientVUContent;
@synthesize specialtyId, imageId;
@synthesize currentMasterScreen;
@synthesize recordCounter;
@synthesize isExportInProcess;
@synthesize updatedCurrentVersion;
@synthesize accessToken;
@synthesize networkReachable;
@synthesize currentPatientInfo;
@synthesize currentPatientGraphInfo;
@synthesize currentPatientAppointments;
@synthesize isPatientSelected;
@synthesize appBundleIdentifier, specialtydwnlding;
@synthesize isIPXInProgress, isEMRVUInProgress;
@synthesize boxExpiresIn,boxRefreshAccessToken,boxAccessToken;
@synthesize notificationLable, canRequestAccessToken;
@synthesize mapLinks ,spinner, isSettingsChanged, downLoadSpecialtyId;
@synthesize updateOrg ,insertOrg ,checkOrganizationUserLicense ,checkOrganizationDetails ,orgGoToWelVU,isOrgSubcribed ,welvu_specialtyModels;
@synthesize showGuideCreateVU,showGuideDetailVU,showGuideEditVU,showGuideSettingsVU,showGuideSpecialtyVU, showGuideIPxVU;
//Org
@synthesize org_Logo;
@synthesize welvu_userOrganizationModel ,bundleVersionNumber;
@synthesize oauth_accessToken ,oauth_refreshToken,oauth_timer,confirmRegisteredUser,welvu_configurationArray;
@synthesize iPxImagesList,ipxOrgImagesList,iPxLibImagesList, iPxLibTopicList,lastSelectedIpxTopicId;


//App finish launching here
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    specialtydwnlding = false;
    checkOrganizationUserLicense = false;
    checkOrganizationDetails = false;
    [self obtainBundleIdentifier];
    // isHelpShown = FALSE;
    ispatientVUContent = FALSE;
    isExportInProcess = FALSE;
    isIPXInProgress = FALSE;
    isEMRVUInProgress = FALSE;
    isSettingsChanged = FALSE;
    canRequestAccessToken = YES;
    imageId = -1;
    recordCounter = 0;
    welvu_userModel = nil;
    
    showGuideSpecialtyVU = 1;
    showGuideDetailVU = 1;
    showGuideEditVU = 1;
    showGuideIPxVU = 1;
    showGuideCreateVU = 1;
    showGuideSettingsVU = 1;
    
    [application setStatusBarHidden:YES withAnimation:NO];
    //Copy the database
    [self copyDatabaseIfNeeded];
    currentWelvuSettings = [welvu_settings getActiveSettings:[self getDBPath]];
    mapLinks = [[NSMutableArray alloc] init];
    
    
    //notification for reachability
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification object: nil];
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    hostReach = [Reachability reachabilityWithHostName:PING_HOST_URL];
    [hostReach startNotifier];
    localWifi = [Reachability reachabilityForLocalWiFi];
    [localWifi startNotifier];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [GAI sharedInstance].dispatchInterval = 20;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    bundleVersionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [tracker set:kGAIAppVersion value:bundleVersionNumber];
    [tracker set:kGAIAppName value:@"WelVU"];
    [[GAI sharedInstance] trackerWithName:@"Application Launched"
                               trackingId:GOOGLE_ANALYTICS_WELVU_KEY];
    
    [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_ANALYTICS_WELVU_KEY];
    
    //[self addWelvuVersionNumber];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    orgViewController = [[welvuOrganizationViewController alloc] initWithNibName:@"welvuOrganizationViewController" bundle:nil];
    
    
    
    UINavigationController *orgNavigationController = [[UINavigationController alloc] initWithRootViewController:orgViewController];
    [orgNavigationController setNavigationBarHidden:YES];
    
    masterViewController = [[welvuMasterViewController alloc] initWithNibName:@"welvuMasterViewController" bundle:nil];
    UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    [masterNavigationController setNavigationBarHidden:YES];
    
    welvuDetailViewControllerIpad *detailViewController = [[welvuDetailViewControllerIpad alloc] initWithNibName:@"welvuDetailViewControllerIpad" bundle:nil];
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    [detailNavigationController setNavigationBarHidden:YES];
    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = detailViewController;
    [self.splitViewController setValue:[NSNumber numberWithFloat:MASTER_VIEW_WIDTH] forKey:@"_masterColumnWidth"];
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
    masterViewController.detailViewController = detailViewController;
    detailViewController.masterViewController = masterViewController;
    self.splitViewController.view.opaque = NO;
    self.splitViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:PLAIN_BG_IMAGE_PNG]];
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
    if (self.splitViewController.presentedViewController == NULL) {
        [self.masterViewController closePatchForIos8];
        
    }else if(!self.splitViewController.presentedViewController == NULL){
        
        NSLog(@"view controller");
        
    }else {
        //  NSLog(@"dont crash %@",self.splitViewController.presentedViewController);
        
    }
    //Email sent notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:NOTIFY_MAIL_SENT
                                               object:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    iPxImagesList = [[NSMutableArray alloc]init];
    ipxOrgImagesList = [[NSMutableArray alloc]init];
    iPxLibImagesList = [[NSMutableArray alloc]init];
    iPxLibTopicList = [[NSMutableArray alloc]init];
    
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        //Box
        [BoxSDK sharedSDK].OAuth2Session.clientID = BOX_CLIENT_ID;
        [BoxSDK sharedSDK].OAuth2Session.clientSecret = BOX_SECRET_ID;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(boxAPITokensDidRefresh:)
                                                     name:BoxOAuth2SessionDidBecomeAuthenticatedNotification
                                                   object:[BoxSDK sharedSDK].OAuth2Session];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(boxAPITokensDidRefresh:)
                                                     name:BoxOAuth2SessionDidRefreshTokensNotification
                                                   object:[BoxSDK sharedSDK].OAuth2Session];
        
        [self refreshBoxAccessToken];
        
        // set up stored OAuth2 refresh token
        self.keychain = [[KeychainItemWrapper alloc] initWithIdentifier:REFRESH_TOKEN_KEY accessGroup:nil];
        
        id storedRefreshToken = [self.keychain objectForKey:(__bridge id)kSecValueData];
        if (storedRefreshToken)
        {
            [BoxSDK sharedSDK].OAuth2Session.refreshToken = storedRefreshToken;
        }
        
    }
    return YES;
}



- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSString * appVersionString = [[NSBundle mainBundle]
                                   objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSLog(@"CGFloat)[userVersionString floatValue]1 %3f", (CGFloat)[appVersionString floatValue]);
    canRequestAccessToken = YES;
    [self appRatingForWelvu];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppDidBecomeActive" object:self];
    if (networkReachable) {
        //[self syncDatasToCloud];
        [self performSelector:@selector(syncDatasToCloud) withObject:nil afterDelay:5.0];
        [self checkUserLicense];
        self.checkOrganizationUserLicense = false;
        
        NSLog(@"specialty id %d",specialtyId);
        
        if(self.welvu_userModel.org_id >0) {
            [self checkAlertForOrgUser];
            
        }
        /*if(specialtyId){
         [self checkAlertForOrgUser];
         
         //[self subcriptionCompletion];
         }*/
    }
    [self obtainBundleIdentifier];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    if(self.welvu_userModel != nil &&  [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        [[BoxSDK sharedSDK].foldersManager folderInfoWithID:BoxAPIFolderIDRoot requestBuilder:nil success:nil failure:nil];
    }
    
    
    
    NSLog(@"expires in %@",welvu_userModel.oauth_expires_in);
    NSLog(@"current date in %@",self.welvu_userModel.oauth_currentDate);
    
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
    expiresdatefromstring = [dateFormatter dateFromString:self.welvu_userModel.oauth_expires_in];
    
    
    NSDate *oauth_expiresIn = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:expiresdatefromstring]];
    NSLog(@"oauth_expiresIn%@",oauth_expiresIn);
    
    //currentdb date
    
    NSDate *currentdatefromstring = [[NSDate alloc] init];
    currentdatefromstring = [dateFormatter dateFromString:self.welvu_userModel.oauth_currentDate];
    
    
    // NSLog(@"dateFromString%@",dateFromString);
    NSDate *oauth_currenrDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:currentdatefromstring]];
    
    NSLog(@"oauth_currenrDate%@",oauth_currenrDate);
    
    
    NSComparisonResult startCompare = [oauth_expiresIn compare: currentGmtDate];
    NSComparisonResult endCompare = [oauth_currenrDate compare: currentGmtDate];
    NSLog(@"startcompare %d",startCompare);
    NSLog(@"end compare %d",endCompare);
    
    if(startCompare == NSOrderedAscending  && endCompare == NSOrderedAscending){
        [self oauthRefreshAccessToken];
    }
    
    
    
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
    orgViewController.indexRow = 0;
    specialtydwnlding = false;
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    /*   [[NSNotificationCenter defaultCenter]
     postNotificationName:@"removePinInSettings"
     object:self];*/
    
    orgViewController.indexRow = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppDidEnterBackground" object:self];
}




- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}




//copy the db if we need
- (void)copyDatabaseIfNeeded {
    //Using NSFileManager we can perform many file system operations.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = [self getDBPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if (!success) {
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:WELVU_SQLITE];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        //Need to add Exception handling
        if (!success) {
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        } else {
            NSURL *url = [NSURL fileURLWithPath:defaultDBPath];
            BOOL accomplised = [fileManager addSkipBackupAttributeToItemAtURL:url];
            //  NSLog( @"DB has been written");
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:TRUE forKey:@"guideAnimationOn"];
            [defaults synchronize];
            [self setDeviceIndentity];
        }
        showGuideSpecialtyVU = 0;
        showGuideDetailVU = 0;
        showGuideEditVU = 0;
        showGuideIPxVU = 0;
        showGuideCreateVU = 0;
        showGuideSettingsVU = 0;
        
    } else {
        NSString * appVersionString = [[NSBundle mainBundle]
                                       objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString * userVersionString = [[welvu_app_version checkCurrentVersion:[self getDBPath]] stringByReplacingOccurrencesOfString:@""
                                                                                                                           withString:@""];
        //   NSLog (@"Build Version %f and Current Version %f",[appVersionString floatValue], [userVersionString floatValue]);
        if ((CGFloat)[userVersionString floatValue]
            < (CGFloat)[@"1.1" floatValue]) {  //1.1
            BOOL updated = [welvu_app_version alterTablesForGUID:[self getDBPath]];
            if (updated) {
                welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
                welvu_app_versionModel.welvu_app_version_txt = @"1.1"; //@"1.1"
                welvu_app_versionModel.welvu_app_version_sequence = 1;
                welvu_app_versionModel.welvu_app_version_active = true;
                welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
                updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
            }
        }
        
        if ((CGFloat)[userVersionString floatValue]
            < (CGFloat)[@"1.2" floatValue]) {  //1.2
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"1.2"; //@"1.2"
            welvu_app_versionModel.welvu_app_version_sequence = 2;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
        }
        
        if ((CGFloat)[userVersionString floatValue]
            < (CGFloat)[@"1.21" floatValue]) {  //1.21
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"1.21"; //@"1.21"
            welvu_app_versionModel.welvu_app_version_sequence = 3;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
        }
        
        if ((CGFloat)[userVersionString floatValue]
            < (CGFloat)[@"1.30" floatValue]) {  //1.30
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:TRUE forKey:@"guideAnimationOn"];
            [defaults synchronize];
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"1.30"; //@"1.30"
            welvu_app_versionModel.welvu_app_version_sequence = 5;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
        }
        
        if ((CGFloat)[userVersionString floatValue]
            < (CGFloat)[@"1.40" floatValue]) {  //1.40
            [self setDeviceIndentity];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:TRUE forKey:@"guideAnimationOn"];
            [defaults synchronize];
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"1.40"; //@"1.40"
            welvu_app_versionModel.welvu_app_version_sequence = 6;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
        }
        
        if ((CGFloat)[userVersionString floatValue]
            < (CGFloat)[@"1.41" floatValue]) {  //1.41
            [self handle6_0IOSIssue];
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"1.41"; //@"1.41"
            welvu_app_versionModel.welvu_app_version_sequence = 7;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
        }
        
        if ((CGFloat)[userVersionString floatValue]
            < (CGFloat)[@"1.42" floatValue]) {  //1.42
            [welvu_images updateImagesUrlLastComponentPath:[self getDBPath]];
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"1.42"; //@"1.42"
            welvu_app_versionModel.welvu_app_version_sequence = 8;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
        }
        
        if ((CGFloat)[userVersionString floatValue]
            < (CGFloat)[@"1.43" floatValue]) {  //1.43
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"1.43"; //@"1.43"
            welvu_app_versionModel.welvu_app_version_sequence = 9;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
        }
        //Video Queue update mandatory update
        if((CGFloat) [userVersionString floatValue]
           < (CGFloat) [@"1.480" floatValue]) { //@"1.48" //IS @"1.660" //OEMR @"1.520"
            [welvu_app_version createWelVUVideoQueue:[self getDBPath]];
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"1.480"; //@"1.480" //IS @"1.660" //OEMR @"1.520"
            welvu_app_versionModel.welvu_app_version_sequence = 10;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
        }
        
        if((CGFloat) [userVersionString floatValue]
           < (CGFloat) [@"1.481" floatValue]) { //@"1.481" //IS @"1.661" //OEMR @"1.521"
            [welvu_app_version userManagementUpdate:[self getDBPath]];
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"1.481"; //@"1.481" //IS @"1.661" //OEMR @"1.521"
            welvu_app_versionModel.welvu_app_version_sequence = 11;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
        }
        
        if((CGFloat) [userVersionString floatValue]
           < (CGFloat) [@"1.482" floatValue]) { //@"1.482" //IS @"1.662" //OEMR @"1.522"
            [welvu_app_version welvuUserAndContentsModification:[self getDBPath]];
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"1.482"; //@"1.482" //IS @"1.662" //OEMR @"1.522"
            welvu_app_versionModel.welvu_app_version_sequence = 12;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
        }
        
        if((CGFloat) [userVersionString floatValue]
           < (CGFloat) [@"1.4830" floatValue]) { //@"1.4830" //IS @"1.6630" //OEMR @"1.5230"
            [welvu_app_version welvuOrganizationTableUpdates:[self getDBPath]];
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"1.4830"; //@"1.4830" //IS @"1.6630" //OEMR @"1.5230"
            welvu_app_versionModel.welvu_app_version_sequence = 13;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
        }
        
        if((CGFloat) [userVersionString floatValue]
           < (CGFloat) [@"1.4852" floatValue]) { //@"1.4852" //IS @"1.6653" //OEMR @"1.5252"
            [welvu_app_version insertDontShowForiPX:[self getDBPath]];
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"1.4852"; //@"1.4852" //IS @"1.6653" //OEMR @"1.5252"
            welvu_app_versionModel.welvu_app_version_sequence = 14;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
        }  if((CGFloat) [userVersionString floatValue]
              < (CGFloat) [@"2.0" floatValue]) { //@"1.4852" //IS @"1.6653" //OEMR @"1.5252"
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"2.0"; //@"1.4852" //IS @"1.6653" //OEMR @"1.5252"
            welvu_app_versionModel.welvu_app_version_sequence = 15;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
        }
        
        
        
        if((CGFloat) [userVersionString floatValue]
           < (CGFloat) [@"2.01" floatValue]) { //@"1.4852" //IS @"1.6653" //OEMR @"1.5252"
            
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"2.01"; //@"1.4852" //IS @"1.6653" //OEMR @"1.5252"
            welvu_app_versionModel.welvu_app_version_sequence = 16;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
        }
        
        if ((CGFloat)[userVersionString floatValue]
            < (CGFloat)[appVersionString floatValue]) {//2.02
            [welvu_app_version alterTableForTopicListOrder:[self getDBPath]];
            
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"2.01"; //@"2.02"
            welvu_app_versionModel.welvu_app_version_sequence = 17;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :
                                     welvu_app_versionModel];
            
        }
        NSLog(@"CGFloat)[userVersionString floatValue] %3f", (CGFloat)[userVersionString floatValue]);
        NSLog(@"CGFloat)[userVersionString floatValue] %3f", (CGFloat)[appVersionString floatValue]);
        if ((CGFloat)[userVersionString floatValue]
            < (CGFloat)[@"2.1" floatValue]) {//2.02
            [welvu_app_version welvuIpxImagesTableUpdates:[self getDBPath]];
            [welvu_app_version welvuConfigurationCreateTable:[self getDBPath]];
            [welvu_app_version welvuOauthCreateTable:[self getDBPath]];
            [welvu_app_version welvuPinCreateTable:[self getDBPath]];
            [welvu_app_version alterUserTableForOauth:[self getDBPath]];
            
            
            welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
            welvu_app_versionModel.welvu_app_version_txt = @"2.1"; //@"2.02"
            welvu_app_versionModel.welvu_app_version_sequence = 18;
            welvu_app_versionModel.welvu_app_version_active = true;
            welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
            updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :
                                     welvu_app_versionModel];
            
            BOOL oauthclear = [welvu_user clearAccessandRefreshToken:[self getDBPath]];
            
            
        }
        
        
        
        /*if((CGFloat) [userVersionString floatValue]
         < (CGFloat) [@"2.0" floatValue]) {
         //[self addorganizationDetails];//@"1.4852" //IS @"1.6653" //OEMR @"1.5252"
         // [welvu_app_version userorgStatusUpdate:[self getDBPath]];
         welvu_app_version *welvu_app_versionModel = [[welvu_app_version alloc] init];
         welvu_app_versionModel.welvu_app_version_txt = @"2.0"; //@"1.4852" //IS @"1.6653" //OEMR @"1.5252"
         welvu_app_versionModel.welvu_app_version_sequence = 15;
         welvu_app_versionModel.welvu_app_version_active = true;
         welvu_app_versionModel.welvu_app_updated_on = [NSDate date];
         updatedCurrentVersion = [welvu_app_version updatedCurrentVersion:[self getDBPath] :welvu_app_versionModel];
         
         } */
        
    }
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *preIosVersion = [defaults objectForKey:@"previousiOSVersion"];
    if (![preIosVersion isEqualToString:currSysVer]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:currSysVer forKey:@"currentiOSVersion"];
        BOOL inserted = [welvu_sync addSyncDetail:[self getDBPath] guid:[defaults stringForKey:@"userDeviceID"]
                                         objectId:0
                                         syncType:SYNC_TYPE_OS_CHANGES_CONSTANT
                                       actionType:ACTION_TYPE_UPDATE_CONSTANT];
        
    }
}
/*
 * Class name: handle6_0IOSIssue
 * Description: hanle the issue for ios 6 i:e udid and Guid
 * Extends: nil
 * Delegate : nil
 */

- (void)handle6_0IOSIssue {
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    //    currSysVer = @"6.0";
    if ([currSysVer isEqualToString:@"6.0"]) {
        NSString *udid = @"";
        
        udid = [[Guid randomGuid] description];
        //  NSLog(@"OS 6.0 getDeviceUDID %@", udid);
        BOOL inserted = [welvu_sync addSyncDetail:[self getDBPath] guid:udid objectId:0
                                         syncType:SYNC_TYPE_PLATFORM_ID_CONSTANT
                                       actionType:ACTION_TYPE_UPDATE_CONSTANT];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:currSysVer forKey:@"previousiOSVersion"];
        [defaults setObject:udid forKey:@"userDeviceID"];
        [defaults setObject:currSysVer forKey:@"currentiOSVersion"];
        [defaults synchronize];
    }
}

/*
 * Class name: setDeviceIndentity
 * Description: To find current system version
 * Extends: nil
 * Delegate : nil
 */
- (void) setDeviceIndentity {
    
    NSString *udid = @"";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    //    currSysVer = @"6.0.1";
    if (([currSysVer compare:OS_VERSION_LIMITATION options:NSNumericSearch] == NSOrderedAscending)
        || [currSysVer isEqualToString:@"6.0"]) {
        udid = [[Guid randomGuid] description];
        //  NSLog(@"OS 5.1 getDeviceUDID %@", udid);
        
    } else if ([currSysVer compare:OS_VERSION_LIMITATION options:NSNumericSearch]
               == NSOrderedDescending) {
        NSUUID *nsudid =  [[UIDevice currentDevice] identifierForVendor];
        udid = [[nsudid UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        // NSLog(@"OS 6 getDeviceUDID %@", udid);
    }
    
    BOOL inserted = [welvu_sync addSyncDetail:[self getDBPath] guid:udid objectId:0
                                     syncType:SYNC_TYPE_PLATFORM_ID_CONSTANT
                                   actionType:ACTION_TYPE_UPDATE_CONSTANT];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:currSysVer forKey:@"previousiOSVersion"];
    [defaults setObject:udid forKey:@"userDeviceID"];
    [defaults setObject:currSysVer forKey:@"currentiOSVersion"];
    [defaults synchronize];
    
    
}
//Get the path of the database
- (NSString *)getDBPath {
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    return [DOCUMENT_DIRECTORY stringByAppendingPathComponent:WELVU_SQLITE];
}

//notification to  identify the network reachability
- (void)reachabilityChanged:(NSNotification* )note {
    Reachability* curReach = [note object];
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    if(netStatus == NotReachable) {
        networkReachable = false;
    } else {
        networkReachable = true;
        if(self.welvu_userModel!=nil) {
            [self checkForConfirmedUser];
            
        }
        [self syncDatasToCloud];
    }
}

-(void)checkUserLicense {
    
    self.welvu_userModel = [welvu_user getCurrentLoggedUser:[self getDBPath]];
    //  NSLog(@"org id %@",self.welvu_userModel);
    if(welvu_userModel.org_id > 0) {
        
        NSString *accessToken = nil;
        if(self.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = self.welvu_userModel.access_token;
        }
        NSInteger org_ID = self.welvu_userModel.org_id;
        //  NSLog(@"org id %d",org_ID);
        NSNumber *organizationId = [NSNumber numberWithInteger:org_ID];
        NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                      [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                      accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                      organizationId ,HTTP_REQUEST_ORGANISATION_KEY,
                                      nil];
        
        NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
        if(welvu_userModel.org_id > 0) {
            [requestDataMutable
             setObject:[NSNumber numberWithInteger:welvu_userModel.org_id]
             forKey:HTTP_REQUEST_ORGANISATION_KEY];
        }
        
        HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                              :PLATFORM_HOST_URL :PLATFORM_CHECK_USER_LICENSE:HTTP_METHOD_POST
                                              :requestDataMutable :nil];
        requestHandler.delegate = self;
        [requestHandler makeHTTPRequest];
        checkOrganizationUserLicense = true;
    }
}

//Check the user is confirmed user or not
- (void)checkForConfirmedUser {
    
    // NSLog(@"specialty id %d",specialtyId);
    NSUserDefaults *prefs =  [NSUserDefaults standardUserDefaults];
    accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
    
    
    
    if (self.welvu_userModel.access_token == nil && accessToken != nil) {
        NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                      [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                      accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                      [NSNumber numberWithInteger:specialtyId], HTTP_SPECIALTY_ID,nil];
        
        NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
        if(welvu_userModel.org_id > 0) {
            [requestDataMutable
             setObject:[NSNumber numberWithInteger:welvu_userModel.org_id]
             forKey:HTTP_REQUEST_ORGANISATION_KEY];
        }
        
        HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                              :PLATFORM_HOST_URL :PLATFORM_CHECK_USER_CONFIRMATION:HTTP_METHOD_POST
                                              :requestDataMutable :nil];
        requestHandler.delegate = self;
        [requestHandler makeHTTPRequest];
    }
    
}
//if network is there then start syncing
- (void)startSyncProcess {
    if (networkReachable) {
        SyncDataToCloud *sync = [[SyncDataToCloud alloc] init];
        sync.delegate = self;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        
        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
            currentRequestActionURL = PLATFORM_GET_BOX_TOPICS_ACTION_URL;
            [sync checkForUpdate:PLATFORM_GET_BOX_TOPICS_ACTION_URL];
        } else {
            currentRequestActionURL = PLATFORM_GET_UPDATE_NOTIFICATIONS;
            [sync checkForUpdate:PLATFORM_GET_UPDATE_NOTIFICATIONS];
        }
    }
    //[self subcriptionCompletion];
}

- (void)syncContentToPlatformSendResponse:(BOOL)success {
    //  NSLog(@"Response received for Sync Data");
}
//sync the content to cloud/platform
BOOL calledAlready = false;
- (void)syncDatasToCloud {
    // NSLog(@"SyncDataToCloud trial");
    if (networkReachable && !calledAlready) {
        calledAlready = true;
        NSMutableArray *welvu_syncModels = [welvu_sync getSyncList:[self getDBPath]];
        for (welvu_sync *welvu_syncModel in welvu_syncModels) {
            SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
            NSString *actionType = nil;
            switch (welvu_syncModel.action_type) {
                case ACTION_TYPE_CREATE_CONSTANT:
                    actionType = HTTP_REQUEST_ACTION_TYPE_CREATE;
                    break;
                case ACTION_TYPE_DELETE_CONSTANT:
                    actionType = HTTP_REQUEST_ACTION_TYPE_DELETE;
                    break;
                case ACTION_TYPE_UPDATE_CONSTANT:
                    actionType = HTTP_REQUEST_ACTION_TYPE_UPDATE;
                    break;
                default:
                    break;
            }
            
            
            // NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            self.welvu_userModel = [welvu_user getCurrentLoggedUser:[self getDBPath]];
            NSString *accessToken = nil;
            if(self.welvu_userModel.access_token == nil) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            } else {
                accessToken = self.welvu_userModel.access_token;
            }
            boxAccessToken = self.welvu_userModel.box_access_token;
            boxRefreshAccessToken = self.welvu_userModel.box_refresh_access_token;
            boxExpiresIn = self.welvu_userModel.box_expires_in;
            
            //ios version
            
            //accessToken validate
            if((welvu_syncModel.sync_type ==  SYNC_TYPE_OS_CHANGES_CONSTANT) && (!accessToken == nil)){
                [dataToCloud startSyncDataToCloud:welvu_syncModel.sync_type guid:welvu_syncModel.guid
                                         objectId:welvu_syncModel.object_id
                                       actionType:actionType
                                        actionURL:PLATFORM_SYNC_OS_VERSION];
                //  NSLog (@"Platform sync ios version");
            } else if((welvu_syncModel.sync_type ==  SYNC_TYPE_PLATFORM_ID_CONSTANT) && (!accessToken == nil)){
                [dataToCloud startSyncDataToCloud:welvu_syncModel.sync_type objectId:welvu_syncModel.object_id
                                       actionType:actionType
                                        actionURL:PLATFORM_SYNC_DEVICE_ID];
                // NSLog (@"Platform sync");
            } else if (welvu_syncModel.sync_type == SYNC_TYPE_TOPIC_CONSTANT) {
                if (welvu_syncModel.action_type == ACTION_TYPE_CREATE_CONSTANT) {
                    [dataToCloud startSyncDataToCloud:welvu_syncModel.sync_type objectId:welvu_syncModel.object_id
                                           actionType:actionType
                                            actionURL:PLATFORM_SYNC_TOPICS];
                } else if (welvu_syncModel.action_type == ACTION_TYPE_DELETE_CONSTANT){
                    
                    [dataToCloud startSyncDeletedDataToCloud:SYNC_TYPE_TOPIC_CONSTANT
                                                        guid:welvu_syncModel.guid
                                                  actionType:HTTP_REQUEST_ACTION_TYPE_DELETE
                                                   actionURL:PLATFORM_SYNC_TOPICS];
                    
                }
            }
            else  if (welvu_syncModel.sync_type == SYNC_TYPE_CONTENT_CONSTANT) {
                
                if (welvu_syncModel.action_type == ACTION_TYPE_CREATE_CONSTANT) {
                    [dataToCloud startSyncDataToCloud:welvu_syncModel.sync_type objectId:welvu_syncModel.object_id
                                           actionType:actionType
                                            actionURL:PLATFORM_SYNC_CONTENTS];
                } else if (welvu_syncModel.action_type == ACTION_TYPE_DELETE_CONSTANT){
                    [dataToCloud startSyncDeletedDataToCloud:SYNC_TYPE_CONTENT_CONSTANT guid:welvu_syncModel.guid
                                                  actionType:HTTP_REQUEST_ACTION_TYPE_DELETE actionURL:PLATFORM_SYNC_CONTENTS];
                }
            }
        }
        [self performSelector:@selector(syncNextCallAllowed) withObject:nil afterDelay:60];
    }
    
}

- (void)syncNextCallAllowed {
    // NSLog(@"Called for next sync");
    calledAlready = false;
}

//sync content to platforn and receive content
- (void)syncContentToPlatformDidReceivedData:(BOOL)success:(NSDictionary *) responseDictionary {
    //NeedToCheck
    if ([currentRequestActionURL isEqualToString:PLATFORM_GET_UPDATE_NOTIFICATIONS] && success) {
        if ([responseDictionary objectForKey:HTTP_RESPONSE_TOPIC_SYNC_DATA]) {
            NSDictionary *topicsDatas = [responseDictionary objectForKey:HTTP_RESPONSE_TOPIC_SYNC_DATA];
            for (NSDictionary *welvuTopics in topicsDatas) {
                welvu_topics *welvu_topicsModel = nil;
                if ([welvuTopics objectForKey:HTTP_REQUEST_TOPIC_GUID]) {
                    welvu_topicsModel = [[welvu_topics alloc] init];
                    welvu_topicsModel.topic_is_user_created = true;
                    welvu_topicsModel.topics_guid = [welvuTopics objectForKey:HTTP_REQUEST_TOPIC_GUID];
                } else if ([welvuTopics objectForKey:HTTP_REQUEST_TOPIC_ID] ){
                    welvu_topicsModel = [[welvu_topics alloc] initWithTopicId:
                                         [[welvuTopics objectForKey:HTTP_REQUEST_TOPIC_ID] integerValue]];
                    welvu_topicsModel.topic_is_user_created = false;
                }
                welvu_topicsModel.specialty_id = [[welvuTopics objectForKey:HTTP_SPECIALTY_ID] integerValue];
                welvu_topicsModel.topicName = [welvuTopics objectForKey:HTTP_RESPONSE_TITLE];
                welvu_topicsModel.welvu_user_id = welvu_userModel.welvu_user_id;
                welvu_topicsModel.is_locked = false;
                welvu_topicsModel.topic_active = true;
                BOOL inserted;
                //NeedToCheck
                if ([[welvuTopics objectForKey:HTTP_REQUEST_ACTION_TYPE_KEY] isEqualToString:HTTP_REQUEST_ACTION_TYPE_CREATE]) {
                    
                    
                    
                    if (welvu_topicsModel.topic_is_user_created
                        && [welvu_topics getTopicDetailByGUID:[self getDBPath]:welvu_topicsModel.topics_guid] == nil) {
                        inserted = [welvu_topics addNewTopic:[self getDBPath] :welvu_topicsModel:
                                    welvu_topicsModel.specialty_id];
                    } else if (!welvu_topicsModel.topic_is_user_created
                               && [welvu_topics getTopicById:[self getDBPath] :welvu_topicsModel.topicId
                                                      userId:welvu_userModel.welvu_user_id] == nil) {
                                   inserted = [welvu_topics addTopicFromPlatform:[self getDBPath] :welvu_topicsModel];
                               }
                    
                    
                    
                    //welvu_topicsModel = nil;
                    if (inserted > 0) {
                        SyncDataToCloud *sync = [[SyncDataToCloud alloc] init];
                        //sync.delegate = self;
                        //currentRequestActionURL = PLATFORM_READ_NOTIFICATIONS_ACTION_URL;
                        [sync syncNotificationToDevice:PLATFORM_READ_NOTIFICATIONS_ACTION_URL
                                        notificationId:[[welvuTopics objectForKey:HTTP_REQUEST_NOTIFICATION_ID] integerValue]];
                        
                    }
                    
                    
                }
                
                else if ([[welvuTopics objectForKey:HTTP_REQUEST_ACTION_TYPE_KEY] isEqualToString:HTTP_REQUEST_ACTION_TYPE_UPDATE]) {
                    
                    
                }
                
                else if ([[welvuTopics objectForKey:HTTP_REQUEST_ACTION_TYPE_KEY] isEqualToString:HTTP_REQUEST_ACTION_TYPE_DELETE]) {
                    NSLog(@"topic deleted");
                    BOOL deleted = false;
                    //santhosh september 25
                    //NeedToCheck
                    
                    if(welvu_topicsModel.topic_is_user_created) {
                        inserted = [welvu_topics deleteTopicWithTopicGUID:[self getDBPath] :welvu_topicsModel.topics_guid];
                        
                    } else {
                        inserted = [welvu_topics deleteTopicWithTopicId:[self getDBPath] :welvu_topicsModel.topicId
                                                                user_id:welvu_topicsModel.welvu_user_id];
                    }
                    
                    welvu_topicsModel = nil;
                    if (inserted > 0) {
                        SyncDataToCloud *sync = [[SyncDataToCloud alloc] init];
                        //sync.delegate = self;
                        //currentRequestActionURL = PLATFORM_READ_NOTIFICATIONS_ACTION_URL;
                        [sync syncNotificationToDevice:PLATFORM_READ_NOTIFICATIONS_ACTION_URL
                                        notificationId:[[welvuTopics objectForKey:HTTP_REQUEST_NOTIFICATION_ID] integerValue]];
                        
                    }
                }
                
                
                /*
                 
                 inserted = [welvu_topics deleteTopicWithTopicGUID:[self getDBPath] :welvu_topicsModel.topics_guid];
                 inserted = [welvu_topics deleteTopicWithTopicId:[self getDBPath] :welvu_topicsModel.topicId
                 user_id:welvu_topicsModel.welvu_user_id];
                 
                 if (welvu_topicsModel.topic_is_user_created) {
                 
                 //  NSLog(@"topic_guid %@",welvu_topicsModel.topics_guid);
                 NSInteger topicId = [welvu_topics getTopicIdByGUID:[self getDBPath]
                 :welvu_topicsModel.topics_guid];
                 
                 if(topicId > 0) {
                 deleted = [welvu_images deleteImagesFromTopic:[self getDBPath]
                 :topicId
                 userId:self.welvu_userModel.welvu_user_id];
                 } else {
                 inserted = [welvu_topics deleteTopicWithTopicGUID:[self getDBPath] :welvu_topicsModel.topics_guid];
                 
                 }
                 
                 } else if (!welvu_topicsModel.topic_is_user_created){
                 inserted = [welvu_topics deleteTopicWithTopicId:[self getDBPath] :welvu_topicsModel.topicId
                 user_id:welvu_topicsModel.welvu_user_id];
                 
                 
                 }
                 
                 }
                 welvu_topicsModel = nil;
                 if (inserted > 0) {
                 SyncDataToCloud *sync = [[SyncDataToCloud alloc] init];
                 //sync.delegate = self;
                 //currentRequestActionURL = PLATFORM_READ_NOTIFICATIONS_ACTION_URL;
                 [sync syncNotificationToDevice:PLATFORM_READ_NOTIFICATIONS_ACTION_URL
                 notificationId:[[welvuTopics objectForKey:HTTP_REQUEST_NOTIFICATION_ID] integerValue]];
                 
                 } */
            }
        }
        
        if ([responseDictionary objectForKey:HTTP_RESPONSE_MEDIA_SYNC_DATA]) {
            NSDictionary *mediaDatas = [responseDictionary objectForKey:HTTP_RESPONSE_MEDIA_SYNC_DATA];
            for(NSDictionary *welvuImage in mediaDatas) {
                welvu_images *welvuImagesModel = nil;
                if ([welvuImage objectForKey:HTTP_REQUEST_CONTENT_GUID]) {
                    welvuImagesModel = [[welvu_images alloc] init];
                    welvuImagesModel.image_guid = [welvuImage objectForKey:HTTP_REQUEST_CONTENT_GUID];
                    if ([[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_TYPE] isEqualToString:IMAGE_ASSET_TYPE]) {
                        welvuImagesModel.type = IMAGE_ALBUM_TYPE;
                    } else if ([[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_TYPE] isEqualToString:IMAGE_VIDEO_TYPE]) {
                        welvuImagesModel.type = IMAGE_VIDEO_ALBUM_TYPE;
                    }
                } else if ([welvuImage objectForKey:HTTP_REQUEST_CONTENT_ID]){
                    welvuImagesModel = [[welvu_images alloc] initWithImageId:
                                        [[welvuImage objectForKey:HTTP_REQUEST_CONTENT_ID] integerValue]];
                    if ([[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_TYPE] isEqualToString:IMAGE_ASSET_TYPE]) {
                        welvuImagesModel.type = IMAGE_ASSET_TYPE;
                    } else if ([[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_TYPE] isEqualToString:IMAGE_VIDEO_TYPE]) {
                        welvuImagesModel.type = IMAGE_VIDEO_TYPE;
                    }
                }
                // if([[welvuImage objectForKey:HTTP_REQUEST_TOPIC_ID] integerValue] > 0)  {
                
                /* if ([welvuImage objectForKey:HTTP_REQUEST_TOPIC_GUID]) {
                 //welvuImagesModel. = [welvuImage objectForKey:];
                 welvuImagesModel.topicId = [welvu_topics getTopicIdByGUID:[self getDBPath]
                 :[welvuImage objectForKey:HTTP_REQUEST_TOPIC_GUID]];
                 welvuImagesModel.image_guid = [welvuImage objectForKey:HTTP_REQUEST_CONTENT_GUID];
                 
                 } else {
                 welvuImagesModel.topicId = [[welvuImage objectForKey:HTTP_REQUEST_TOPIC_ID] integerValue];
                 welvuImagesModel.imageId = [[welvuImage objectForKey:HTTP_REQUEST_CONTENT_ID] integerValue];
                 } */
                
                if ([welvuImage objectForKey:HTTP_REQUEST_TOPIC_GUID]) {
                    //welvuImagesModel. = [welvuImage objectForKey:];
                    welvuImagesModel.topicId = [welvu_topics getTopicIdByGUID:[self getDBPath]
                                                                             :[welvuImage objectForKey:HTTP_REQUEST_TOPIC_GUID]];
                    welvuImagesModel.image_guid = [welvuImage objectForKey:HTTP_REQUEST_CONTENT_GUID];
                } else {
                    welvuImagesModel.topicId = [[welvuImage objectForKey:HTTP_REQUEST_TOPIC_ID] integerValue];
                    welvuImagesModel.imageId = [[welvuImage objectForKey:HTTP_REQUEST_CONTENT_ID] integerValue];
                }
                welvuImagesModel.orderNumber = [[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_ORDER] integerValue];
                
                
                welvuImagesModel.welvu_user_id = welvu_userModel.welvu_user_id;
                
                
                BOOL inserted = false;
                welvuImagesModel.imageDisplayName = [welvuImage objectForKey:HTTP_RESPONSE_NAME];
                
                if ([[welvuImage objectForKey:HTTP_REQUEST_ACTION_TYPE_KEY] isEqualToString:HTTP_REQUEST_ACTION_TYPE_CREATE]) {
                    
                    
                    NSString* outputPath = [NSString stringWithFormat:@"%@/%@",
                                            DOCUMENT_DIRECTORY, [welvuImage objectForKey:HTTP_RESPONSE_NAME]];
                    NSData *thedata = [NSData dataWithContentsOfURL:[NSURL URLWithString:[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_URL]]];
                    [thedata writeToFile:outputPath atomically:YES];
                    int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:outputPath]];
                    welvuImagesModel.url = [welvuImage objectForKey:HTTP_RESPONSE_NAME];
                    if (welvuImagesModel.topicId > 0 && [welvuImage objectForKey:HTTP_REQUEST_CONTENT_GUID]
                        && [welvu_images getImageByGuid:[self getDBPath]:welvuImagesModel.image_guid] == nil) {
                        inserted = [welvu_images
                                    addNewImageToTopic:[self getDBPath]
                                    :welvuImagesModel
                                    :welvuImagesModel.topicId];
                    } else if (welvuImagesModel.topicId > 0 && [welvuImage objectForKey:HTTP_REQUEST_CONTENT_ID]
                               && [welvu_images getImageById:[self getDBPath] :welvuImagesModel.imageId userId
                                                            :welvuImagesModel.welvu_user_id] == nil) {
                                   inserted = [welvu_images addImageToTopicFromPlatform:[self getDBPath]
                                                                                       :welvuImagesModel
                                                                                       :welvuImagesModel.topicId];
                               }
                    //YetToDo
                } else if ([[welvuImage objectForKey:HTTP_REQUEST_ACTION_TYPE_KEY] isEqualToString:HTTP_REQUEST_ACTION_TYPE_UPDATE]) {
                    
                    
                } else if ([[welvuImage objectForKey:HTTP_REQUEST_ACTION_TYPE_KEY] isEqualToString:HTTP_REQUEST_ACTION_TYPE_DELETE]) {
                    
                    
                    if (welvuImagesModel.topicId > 0 && [welvuImage objectForKey:HTTP_REQUEST_CONTENT_GUID]) {
                        inserted = [welvu_images deleteImageFromTopicByGuid:[self getDBPath] :welvuImagesModel.image_guid];
                        
                    } else if (welvuImagesModel.topicId > 0 && [welvuImage objectForKey:HTTP_REQUEST_CONTENT_ID]) {
                        inserted = [welvu_images deleteImageFromTopic:[self getDBPath] :welvuImagesModel.imageId userId:self.welvu_userModel.welvu_user_id];
                    }
                    
                    
                    if (inserted) {
                        NSString* outputPath = [NSString stringWithFormat:@"%@/%@",
                                                DOCUMENT_DIRECTORY, [welvuImage objectForKey:HTTP_RESPONSE_NAME]];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
                            [[NSFileManager defaultManager] removeItemAtPath: outputPath error:NULL];
                            //  NSLog(@"Deleted Content from %@", outputPath);
                        }
                    }
                    
                }
                if (inserted) {
                    SyncDataToCloud *sync = [[SyncDataToCloud alloc] init];
                    //sync.delegate = self;
                    //currentRequestActionURL = PLATFORM_READ_NOTIFICATIONS_ACTION_URL;
                    [sync syncNotificationToDevice:PLATFORM_READ_NOTIFICATIONS_ACTION_URL
                                    notificationId:[[welvuImage objectForKey:HTTP_REQUEST_NOTIFICATION_ID] integerValue]];
                    
                }
            }
            
        }
        
        if ([responseDictionary objectForKey:HTTP_RESPONSE_ORDER_SYNC_DATA]) {
            NSDictionary *order_sync_data = [responseDictionary objectForKey:HTTP_RESPONSE_ORDER_SYNC_DATA];
            for (NSDictionary *orderData in order_sync_data) {
                NSDictionary *order_data = [orderData objectForKey:HTTP_REQUEST_MEDIA_ORDER_DETAILS_KEY];
                for (NSDictionary *welvuImage in order_data) {
                    welvu_images *welvuImagesModel = nil;
                    BOOL updated = false;
                    if ([welvuImage objectForKey:HTTP_REQUEST_CONTENT_GUID]) {
                        welvuImagesModel = [welvu_images getImageByGuid:[self getDBPath]
                                                                       :[welvuImage objectForKey:HTTP_REQUEST_CONTENT_GUID]];
                        
                    } else if ([welvuImage objectForKey:HTTP_REQUEST_CONTENT_ID]){
                        welvuImagesModel = [[welvu_images alloc] initWithImageId:
                                            [[welvuImage objectForKey:HTTP_REQUEST_CONTENT_ID] integerValue]];
                        
                    }
                    
                    if ([orderData objectForKey:HTTP_REQUEST_TOPIC_GUID]) {
                        //welvuImagesModel. = [welvuImage objectForKey:];
                        welvuImagesModel.topicId = [welvu_topics getTopicIdByGUID:[self getDBPath] :
                                                    [orderData objectForKey:HTTP_REQUEST_TOPIC_GUID]];
                        
                        
                        
                    } else if ([orderData objectForKey:HTTP_REQUEST_TOPIC_ID] ){
                        
                        welvuImagesModel.topicId = [[orderData objectForKey:HTTP_REQUEST_TOPIC_ID] integerValue];
                        
                    }
                    
                    
                    
                    if (welvuImagesModel ) {
                        self.welvu_userModel = [welvu_user getCurrentLoggedUser:self.getDBPath];
                        updated = [welvu_images updateImagesOrderNumberByTopicId:[self getDBPath]
                                                                                :welvuImagesModel.topicId
                                                                                :welvuImagesModel.imageId
                                                                                :[[welvuImage objectForKey
                                                                                   :HTTP_REQUEST_ORDER_NUMBER_KEY] integerValue]
                                                                          userId:self.welvu_userModel.welvu_user_id];
                        if (updated) {
                            SyncDataToCloud *sync = [[SyncDataToCloud alloc] init];
                            [sync syncNotificationToDevice:PLATFORM_READ_NOTIFICATIONS_ACTION_URL
                                            notificationId:[[orderData objectForKey:HTTP_REQUEST_NOTIFICATION_ID] integerValue]];
                            
                        }
                    }
                }
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_RELOAD_TABLE_DATA object:self];
        //self.masterViewController.spinner = nil;
        
    }else if([currentRequestActionURL isEqualToString:PLATFORM_GET_BOX_TOPICS_ACTION_URL] && success) {
        [self syncContentFromBox:responseDictionary];
    } else if ([currentRequestActionURL isEqualToString:PLATFORM_READ_NOTIFICATIONS_ACTION_URL]
               && success) {
        //  NSLog(@"Notification synced successfully");
    }
    //[self subcriptionCompletion];
    [self checkAlertForOrgUser];
}

/*
 * Class name: syncContentFromBox
 * Description: Sync content from the box
 * Extends: NSDictionary
 * Delegate : nil
 */
-(BOOL) syncContentFromBox:(NSDictionary *) responseTopicsDictionary {
    
    NSDictionary *details = [responseTopicsDictionary objectForKey:HTTP_DETAILS_KEY];
    if(![details isKindOfClass:[NSNull class]]) {
        for(NSDictionary *welvuTopic in details) {
            
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
            welvuTopicModel.specialty_id = specialtyId;
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
            welvuTopicModel.welvu_user_id = self.welvu_userModel.welvu_user_id;
            BOOL insert;
            if([welvuTopic objectForKey:HTTP_REQUEST_TOPIC_GUID]
               && [welvu_topics getTopicDetailByGUID:[self getDBPath] :welvuTopicModel.topics_guid]  == nil) {
                
                NSInteger topicId = [welvu_topics addNewTopic:[self getDBPath]:welvuTopicModel:welvuTopicModel.specialty_id];
                welvuTopicModel = [welvu_topics setTopicId:welvuTopicModel :topicId];
                if(topicId > 0) {
                    insert = true;
                }
            } else if ([welvuTopic objectForKey:HTTP_REQUEST_TOPIC_GUID]) {
                insert = true;
            }
            if([welvu_topics getTopicById:[self getDBPath] :welvuTopicModel.topicId
                                   userId:self.welvu_userModel.welvu_user_id]  == nil){
                
                insert = [welvu_topics addTopicFromPlatform:[self getDBPath]:welvuTopicModel];
            } else {
                insert = true;
            }
            if(insert && ![[welvuTopic objectForKey:HTTP_RESPONSE_MEDIAS] isKindOfClass:[NSNull class]]) {
                NSDictionary *mediaDatas = [welvuTopic objectForKey:HTTP_RESPONSE_MEDIAS];
                for(NSDictionary *welvuImage in mediaDatas) {
                    welvu_images *welvuImagesModel = nil;
                    if ([welvuImage objectForKey:HTTP_REQUEST_CONTENT_GUID]) {
                        welvuImagesModel = [[welvu_images alloc] init];
                        welvuImagesModel.image_guid = [welvuImage objectForKey:HTTP_REQUEST_CONTENT_GUID];
                        if ([[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_TYPE] isEqualToString:IMAGE_ASSET_TYPE]) {
                            welvuImagesModel.type = IMAGE_ALBUM_TYPE;
                        } else if ([[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_TYPE] isEqualToString:IMAGE_VIDEO_TYPE]) {
                            welvuImagesModel.type = IMAGE_VIDEO_ALBUM_TYPE;
                        }
                    } else if ([welvuImage objectForKey:HTTP_REQUEST_CONTENT_ID]){
                        welvuImagesModel = [[welvu_images alloc] initWithImageId:
                                            [[welvuImage objectForKey:HTTP_REQUEST_CONTENT_ID] integerValue]];
                        if ([[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_TYPE] isEqualToString:IMAGE_ASSET_TYPE]) {
                            welvuImagesModel.type = IMAGE_ASSET_TYPE;
                        } else if ([[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_TYPE] isEqualToString:IMAGE_VIDEO_TYPE]) {
                            welvuImagesModel.type = IMAGE_VIDEO_TYPE;
                        }
                    } else if ([welvuImage objectForKey:HTTP_REQUEST_ID]) {
                        /* NSInteger imageID = [[welvuImage objectForKey:HTTP_REQUEST_ID] doubleValue];
                         NSLog(@"Image Content Id long %d", imageID);
                         welvuImagesModel = [[welvu_images alloc] initWithImageId:
                         imageID];*/
                        
                        double welvuPlatformId = [[welvuImage objectForKey:HTTP_REQUEST_ID] doubleValue];
                        welvuImagesModel = [[welvu_images alloc] init];
                        welvuImagesModel.welvu_platform_id = welvuPlatformId;
                        welvuImagesModel.image_guid = [[Guid randomGuid] description];
                        
                        if ([[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_TYPE] isEqualToString:IMAGE_ASSET_TYPE]) {
                            welvuImagesModel.type = IMAGE_ASSET_TYPE;
                        } else if ([[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_TYPE] isEqualToString:IMAGE_VIDEO_TYPE]) {
                            welvuImagesModel.type = IMAGE_VIDEO_TYPE;
                        }
                    }
                    // if([[welvuImage objectForKey:HTTP_REQUEST_TOPIC_ID] integerValue] > 0)  {
                    
                    welvuImagesModel.topicId = welvuTopicModel.topicId;
                    welvuImagesModel.orderNumber = [[welvuImage objectForKey:HTTP_RESPONSE_MEDIA_ORDER] integerValue];
                    
                    
                    welvuImagesModel.welvu_user_id = welvu_userModel.welvu_user_id;
                    
                    BOOL inserted = false;
                    welvuImagesModel.imageDisplayName = [welvuImage objectForKey:HTTP_RESPONSE_NAME];
                    
                    NSString* outputPath = [NSString stringWithFormat:@"%@/%@",
                                            DOCUMENT_DIRECTORY, [welvuImage objectForKey:HTTP_RESPONSE_NAME]];
                    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@?%@=%@",
                                           @"https://api.box.com/2.0/files/",
                                           [welvuImage objectForKey:HTTP_RESPONSE_URL],@"content",
                                           @"access_token",
                                           [BoxSDK sharedSDK].OAuth2Session.accessToken];
                    NSData *thedata = [NSData dataWithContentsOfURL:[NSURL URLWithString:[welvuImage objectForKey:HTTP_RESPONSE_URL]]];
                    [thedata writeToFile:outputPath atomically:YES];
                    int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:outputPath]];
                    welvuImagesModel.url = [welvuImage objectForKey:HTTP_RESPONSE_NAME];
                    if (welvuImagesModel.topicId > 0
                        && [welvuImage objectForKey:HTTP_REQUEST_CONTENT_GUID]
                        && [welvu_images getImageByGuid:[self getDBPath]:welvuImagesModel.image_guid] == nil) {
                        inserted = [welvu_images
                                    addNewImageToTopic:[self getDBPath]
                                    :welvuImagesModel
                                    :welvuImagesModel.topicId];
                    }else if (welvuImagesModel.topicId > 0
                              && [welvuImage objectForKey:HTTP_REQUEST_ID]
                              && [welvu_images getImageByBoxPlatormId:[self getDBPath]
                                                                     :welvuImagesModel.welvu_platform_id
                                                                 user:self.welvu_userModel.welvu_user_id] == nil) {
                                  inserted = [welvu_images
                                              addNewImageToTopic:[self getDBPath]
                                              :welvuImagesModel
                                              :welvuImagesModel.topicId];
                              } else if (welvuImagesModel.topicId > 0 && ([welvuImage objectForKey:HTTP_REQUEST_CONTENT_ID])
                                         && [welvu_images getImageById:[self getDBPath] :welvuImagesModel.imageId userId
                                                                      :welvuImagesModel.welvu_user_id] == nil) {
                                             inserted = [welvu_images addImageToTopicFromPlatform:[self getDBPath]
                                                                                                 :welvuImagesModel
                                                                                                 :welvuImagesModel.topicId];
                                         }
                    //YetToDo
                }
            }
        }
        self.welvu_userModel = [welvu_user getCurrentLoggedUser:[self getDBPath]];
        [welvu_specialty updateSyncedSpecialty:[self getDBPath]:specialtyId
                                        userId:self.welvu_userModel.welvu_user_id];
        [self.masterViewController topicDownloadFromBoxFinished:YES];
    } else {
        
        if([self.masterViewController.modalViewController isKindOfClass:[welvuSpecialtyViewController class]]) {
            welvuSpecialtyViewController *specialtyViewController = (welvuSpecialtyViewController *)self.masterViewController.modalViewController;
            if(specialtyViewController.spinner != nil)  {
                [specialtyViewController.spinner removeSpinner];
                specialtyViewController.spinner = nil;
            }
        }
        UIAlertView *contentAlert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"No content available for this Specialty" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        contentAlert.tag = 100;
        [contentAlert show];
        //No content available for this specilaty
        // No Content Alert
    }
}


#pragma mark UIAlertView Delegate
/*
 * Class name: didDismissWithButtonIndex
 * Description: to dismiss the alert view
 * Extends: NSInteger
 * Delegate : nil
 */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 111) {
        [self.masterViewController specialtyBtnClicked:nil];
        
    }
    if(alertView.tag == 100) {
        //self.masterViewController.spinner = nil;
    } else if (alertView.tag == 200) {
        
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.splitViewController.presentedViewController.view:NSLocalizedString(@"PLEASE_WAIT_SPINNER_MSG", nil)];
        }
        
        
        NSString *accessToken = nil;
        if(self.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = self.welvu_userModel.access_token;
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        NSDictionary *requestData = nil;
        requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                        [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                        accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,nil];
        HTTPRequestHandler *  requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                :PLATFORM_HOST_URL :PLATFORM_GET_ORGANIZATION_DETAIL_ACTION_URL
                                                :HTTP_METHOD_POST
                                                :requestData :nil];
        
        requestHandler.delegate = self;
        [requestHandler makeHTTPRequest];
        
        //[self.masterViewController logoutUser];
    }
}

#pragma mark - NSConnection delegates
//content sync failed
- (void)syncContentFailedWithErrorDetails:(NSError *)error {
    // NSLog(@"Sync Content Failed: %@", error);
}



-(void)failedWithErrorDetails:(NSError *)error:(NSString *)actionAPI {
    NSLog(@"Failed to get Specialty %@", error);
    
}
- (void)platformDidResponseReceived:(BOOL)success:(NSString *)actionAPI {
    // NSLog(@"Response received for get USER CONFIRMATION");
}
- (void)platformDidReceivedData:(BOOL)success :(NSDictionary *)responseDictionary
                               :(NSString *)actionAPI {
    
    if(responseDictionary
       && ([actionAPI isEqualToString:PLATFORM_GET_ORGANIZATION_DETAIL_ACTION_URL])) {
        
        BOOL inserted = false;
        for(NSDictionary *welvuOrg in responseDictionary) {
            BOOL inserted = false;
            welvu_organization *welvuOrganizationModel = [[welvu_organization alloc] init];
            
            welvuOrganizationModel.orgId= [[welvuOrg objectForKey:HTTP_RESPONSE_ID] integerValue];
            welvuOrganizationModel.orgName= [welvuOrg objectForKey:HTTP_RESPONSE_NAME];
            welvuOrganizationModel.org_Status = [welvuOrg objectForKey:COLUMN_STATUS];
            
            NSURL *url =[welvuOrg objectForKey:@"logourl"];
            
            welvuOrganizationModel.orgLogoName = [welvuOrg objectForKey:@"logo"];
            
            NSString* outputPath = [NSString stringWithFormat:@"%@/%@",
                                    DOCUMENT_DIRECTORY, [welvuOrg objectForKey:@"logo"]];
            NSData *thedata = [NSData dataWithContentsOfURL:[NSURL URLWithString:[welvuOrg objectForKey:@"logourl"]]];
            welvuOrganizationModel.product_Type = [welvuOrg objectForKey:@"product_type"];
            [thedata writeToFile:outputPath atomically:YES];
            if([welvu_organization getOrganizationDetailsById:[self getDBPath]
                                                        orgId:welvuOrganizationModel.orgId] == nil) {
                inserted = [welvu_organization addOrganizationUser:[self getDBPath] :
                            welvuOrganizationModel];
                insertOrg =true;
            } else {
                inserted = [welvu_organization updateOrganizationDetails
                            :[self getDBPath]
                            :welvuOrganizationModel];
                updateOrg = true;
                
            }
            self.welvu_userModel = [welvu_user getCurrentLoggedUser:[self getDBPath]];
            if([welvu_user getUserByEmailIdAndOrgId:[self getDBPath]
                                            emailId:self.welvu_userModel.email
                                              orgId:welvuOrganizationModel.orgId] == nil) {
                welvu_user *welvu_userMod = [welvu_user copy:self.welvu_userModel];
                welvu_userMod.org_id = welvuOrganizationModel.orgId;
                welvu_userMod.user_primary_key = self.welvu_userModel.welvu_user_id;
                welvu_userMod.user_Org_Role = welvuOrganizationModel.product_Type;
                welvu_userMod.user_org_status =welvuOrganizationModel.org_Status;
                [welvu_user addUserWithOrganizationDetails:[self getDBPath]
                                                          :welvu_userMod];
                welvu_userMod = nil;
            }
            welvuOrganizationModel = nil;
        }
        
        //santhosh new added code
        self.welvu_userModel = [welvu_user getCurrentLoggedUser:[self getDBPath]];
        int orgCount = [welvu_organization getOrganizationCount:[self getDBPath]];
        
        if ((orgCount == 0) && (updateOrg) && (!insertOrg)) {
            //[self logOutExistingUser];
            [self.masterViewController welvuLoginCompletedWithAccessToken];
            
            
        }if ((orgCount == 0) && (!updateOrg) && (insertOrg)) {
            
            
            [self.masterViewController welvuLoginCompletedWithAccessToken];
            
            
        }
        
        else if ((orgCount >= 1) &&  (!checkOrganizationUserLicense)&& (updateOrg)) {
            
            //new org added  here it ill called
            /* UIAlertView *orgAlert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"New Organization added" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
             
             [orgAlert show];*/
            [self.masterViewController switchToWelvuUSer];
            
            
        }else if ((orgCount >= 1) &&  (checkOrganizationUserLicense)&& (!insertOrg) &&(updateOrg)) {
            
            [self.masterViewController switchToWelvuUSer];
            
            
        } else if ((orgCount >= 1) &&  (!checkOrganizationUserLicense)&& (insertOrg) &&(!updateOrg)) {
            
            [self.masterViewController switchToWelvuUSer];
            
            
        }else if ((orgCount >= 1) &&  (checkOrganizationUserLicense)&& (insertOrg) &&(updateOrg)) {
            
            [self.masterViewController switchToWelvuUSer];
            
            
        }
        
        
        if(spinner != nil) {
            [spinner removeSpinner];
            spinner = nil;
        }
    }
    
    
    
    // NSLog(@"Response received for get USER CONFIRMATION");
    
    else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame)
            &&[actionAPI isEqualToString:PLATFORM_CHECK_USER_LICENSE] ) {
        
        NSLog(@"user is validated");
        
        
    }  else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_FAILED_KEY]==NSOrderedSame)
               &&[actionAPI isEqualToString:PLATFORM_CHECK_USER_LICENSE] ) {
        
        NSString *orgName = [welvu_organization getOrganizationNameById:[self getDBPath] :self.welvu_userModel.org_id];
        
        //orgName = [orgName stringByAppendingString:@"admin"];
        
        NSLog(@"Invalid License.");
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:
                                             NSLocalizedString(@"LICENCE_EXPIRED1", nil), orgName]
                              message:nil
                              delegate: self
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil];
        alert.tag = 200;
        [alert show];
    }
    
    else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame)
            &&[actionAPI isEqualToString:PLATFORM_CHECK_USER_CONFIRMATION] ) {
        
        NSInteger update = 0;
        if (welvu_userModel) {
            welvu_user *welvuUserModel = [[welvu_user alloc]
                                          initWithUserId:welvu_userModel.welvu_user_id];
            
            welvuUserModel.access_token =accessToken;
            welvuUserModel.access_token_obtained_on = [NSDate date];
            
            update = [welvu_user updateConfirmedLoggedUserAccessToken:self.getDBPath :welvuUserModel];
            welvu_userModel = [welvu_user getCurrentLoggedUser:[self getDBPath]];
        }
        //   NSLog(@"account Activated");
    }/*else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_FAILED_KEY]==NSOrderedSame)
      &&[actionAPI isEqualToString:PLATFORM_CHECK_USER_CONFIRMATION] ){
      
      [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ALERT_VERIFY_EMAIL_ADDRESS", nil)
      message:nil
      delegate:self
      cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
      otherButtonTitles:NSLocalizedString(@"YES", nil), nil] show];
      
      }*/ else {
          //NSLog(@"Account not activated");
      }}
/*
 * Method name: obtainBundleIdentifier
 * Description: to obtain the bundle identifier
 * Parameters: nil
 * return nil
 */
-(void)obtainBundleIdentifier {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    //  NSLog(@" bundle identifer %@",bundleIdentifier);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:bundleIdentifier forKey:@"appBundleIdentifier"];
    [defaults synchronize];
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        if (connection ==  getOrganization) {
            
            NSError *error;
            
            defaults = [NSUserDefaults standardUserDefaults];
            NSString* newStr = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            if([defaults objectForKey:@"getAuthorize"]) {
                responseStr = [defaults objectForKey:@"getAuthorize"];
            } else {
                responseStr = [[NSString alloc] init];
            }
            responseStr = [responseStr stringByAppendingString:newStr];
            [defaults setObject:responseStr forKey:@"getAuthorize"];
            
            
        }
        else  if (connection == confirmUser) {
            if(data) {
                NSError *error = nil;
                // 1. get the top level value as a dictionary
                NSString* newStr = [[NSString alloc] initWithData:data
                                                         encoding:NSUTF8StringEncoding];
                NSLog(@"platform data %@",newStr);
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
                NSLog(@"response dic %@",responseDictionary);
                
                NSString * responseStatus = [responseDictionary objectForKey:@"title"];
                
                if([responseStatus isEqualToString:@"Forbidden"]) {
                    
                    
                }
                
                else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame)
                        ) {
                    
                    NSInteger update = 0;
                    if (welvu_userModel) {
                        welvu_user *welvuUserModel = [[welvu_user alloc]
                                                      initWithUserId:welvu_userModel.welvu_user_id];
                        
                        welvuUserModel.access_token =accessToken;
                        welvuUserModel.access_token_obtained_on = [NSDate date];
                        
                        update = [welvu_user updateConfirmedLoggedUserAccessToken:self.getDBPath :welvuUserModel];
                        welvu_userModel = [welvu_user getCurrentLoggedUser:[self getDBPath]];
                        self.confirmRegisteredUser = TRUE;
                    }
                    NSLog(@"account Activated");
                } else {
                    NSLog(@"Account not activated");
                    self.confirmRegisteredUser = FALSE;
                    
                }
                
                
            }
        }
        
        else if (connection == checkUserLicense) {
            if(data) {
                NSError *error = nil;
                // 1. get the top level value as a dictionary
                NSString* newStr = [[NSString alloc] initWithData:data
                                                         encoding:NSUTF8StringEncoding];
                NSLog(@"platform data %@",newStr);
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];

                NSLog(@"response dic %@",responseDictionary);
                
                
                
                NSString * responseStatus = [responseDictionary objectForKey:@"title"];
                
                if([responseStatus isEqualToString:@"Forbidden"]) {
                    
                    
                }
                
                else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame)
                        ) {
                    self.checkOrganizationUserLicense = TRUE;
                    NSLog(@"user is validated");
                    
                    
                }  else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_FAILED_KEY]==NSOrderedSame)) {
                    
                    NSString *orgName = [welvu_organization getOrganizationNameById:[self getDBPath] :self.welvu_userModel.org_id];
                    
                    //orgName = [orgName stringByAppendingString:@"admin"];
                    
                    NSLog(@"Invalid License.");
                    
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:[NSString stringWithFormat:
                                                         NSLocalizedString(@"LICENCE_EXPIRED1", nil), orgName]
                                          message:nil
                                          delegate: self
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
                    alert.tag = 200;
                    [alert show];
                }
                
                
                
                
            }
        }
        else if (connection == loginConnection){
            [self oAuthRespMethod:data];
        
        }
    }
    
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        if(connection == getOrganization) {
            [welvu_configuration deleteCacheData:[self getDBPath]];
            NSError *error = nil;
            // 1. get the top level value as a dictionary
            if([defaults objectForKey:@"getAuthorize"]) {
                responseStr = [defaults objectForKey:@"getAuthorize"];
            }
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];

            
            NSLog(@"response dic %@",responseDictionary);
            
            
            NSDictionary *getOrganization = [responseDictionary objectForKey:@"organizations"];
            
            for(NSDictionary *welvuOrg in getOrganization) {
                
                BOOL inserted = false;
                welvu_organization *welvuOrganizationModel = [[welvu_organization alloc] init];
                
                welvuOrganizationModel.orgId = [[welvuOrg objectForKey:HTTP_RESPONSE_ID] integerValue];
                welvuOrganizationModel.orgName = [welvuOrg objectForKey:HTTP_RESPONSE_NAME];
                welvuOrganizationModel.org_Status = [welvuOrg objectForKey:COLUMN_STATUS];
                
                NSURL *url =[welvuOrg objectForKey:@"logourl"];
                
                welvuOrganizationModel.orgLogoName = [welvuOrg objectForKey:@"logo"];
                
                NSString* outputPath = [NSString stringWithFormat:@"%@/%@",
                                        DOCUMENT_DIRECTORY, [welvuOrg objectForKey:@"logo"]];
                NSData *thedata = [NSData dataWithContentsOfURL:[NSURL URLWithString:[welvuOrg objectForKey:@"logourl"]]];
                welvuOrganizationModel.product_Type = [welvuOrg objectForKey:@"product_type"];
                [thedata writeToFile:outputPath atomically:YES];
                
                //key values
                
                welvu_configuration *welvu_configurationModel = [[welvu_configuration alloc] init];
                NSDictionary *config = [welvuOrg objectForKey:@"config"];
                NSLog(@"config org %@",config);
                
                if ((NSNull *)config == [NSNull null]){
                    NSLog(@"config  data is nil ");
                    
                } else {
                    NSDictionary *youtube = [config objectForKey:@"youtube"];
                    NSLog(@"youtube org %@",youtube);
                    welvu_configurationModel.welvu_user_id = welvu_userModel.welvu_user_id;
                    welvu_configurationModel.orgId = welvuOrganizationModel.orgId;
                    
                    if ((NSNull *)youtube == [NSNull null]){
                        // NSLog(@"Patient image null");
                        
                    } else {
                        
                        welvu_configurationModel.welvu_configuration_adapter = @"youtube";
                        
                        welvu_configurationModel.welvu_configuration_key = @"client_id";
                        welvu_configurationModel.welvu_configuration_value = [youtube objectForKey:@"client_id"];
                        [self configInsertOrUpdate :welvu_configurationModel];
                        
                        welvu_configurationModel.welvu_configuration_key = @"client_secret";
                        welvu_configurationModel.welvu_configuration_value = [youtube objectForKey:@"client_secret"];
                        [self configInsertOrUpdate :welvu_configurationModel];
                        
                        welvu_configurationModel.welvu_configuration_key = @"DEV_KEY";
                        welvu_configurationModel.welvu_configuration_value = [youtube objectForKey:@"DEV_KEY"];
                        [self configInsertOrUpdate :welvu_configurationModel];
                        
                        welvu_configurationModel.welvu_configuration_key = @"id";
                        welvu_configurationModel.welvu_configuration_value = [youtube objectForKey:@"id"];
                        [self configInsertOrUpdate :welvu_configurationModel];
                        
                        
                    }
                    
                    NSDictionary *box = [config objectForKey:@"box"];
                    NSLog(@"box org %@",box);
                    
                    if ((NSNull *)box == [NSNull null]){
                        // NSLog(@"Patient image null");
                        
                    } else {
                        welvu_configurationModel.welvu_configuration_adapter = @"box";
                        
                        welvu_configurationModel.welvu_configuration_key = @"client_id";
                        welvu_configurationModel.welvu_configuration_value = [box objectForKey:@"client_id"];
                        [self configInsertOrUpdate :welvu_configurationModel];
                        
                        welvu_configurationModel.welvu_configuration_key = @"client_secret";
                        welvu_configurationModel.welvu_configuration_value = [box objectForKey:@"client_secret"];
                        [self configInsertOrUpdate :welvu_configurationModel];
                        
                        welvu_configurationModel.welvu_configuration_key = @"id";
                        welvu_configurationModel.welvu_configuration_value  = [box objectForKey:@"id"];
                        [self configInsertOrUpdate :welvu_configurationModel];
                        
                        welvu_configurationModel.welvu_configuration_key = @"redirect_uri";
                        welvu_configurationModel.welvu_configuration_value  = [box objectForKey:@"redirect_uri"];
                        [self configInsertOrUpdate :welvu_configurationModel];
                    }
                    
                }
                config = nil;
                
                
                //end key values
                
                
                
                if([welvu_organization getOrganizationDetailsById:[self getDBPath]
                                                            orgId:welvuOrganizationModel.orgId] == nil) {
                    inserted = [welvu_organization addOrganizationUser:[self getDBPath] :
                                welvuOrganizationModel];
                    
                } else {
                    inserted = [welvu_organization updateOrganizationDetails
                                :[self getDBPath]
                                :welvuOrganizationModel];
                    
                }
                self.welvu_userModel = [welvu_user getCurrentLoggedUser:[self getDBPath]];
                if([welvu_user getUserByEmailIdAndOrgId:[self getDBPath]
                                                emailId:self.welvu_userModel.email
                                                  orgId:welvuOrganizationModel.orgId] == nil) {
                    welvu_user *welvu_userMod = [welvu_user copy:self.welvu_userModel];
                    welvu_userMod.org_id = welvuOrganizationModel.orgId;
                    welvu_userMod.user_primary_key = self.welvu_userModel.welvu_user_id;
                    welvu_userMod.user_Org_Role = welvuOrganizationModel.product_Type;
                    welvu_userMod.user_org_status =welvuOrganizationModel.org_Status;
                    [welvu_user addUserWithOrganizationDetails:[self getDBPath]
                                                              :welvu_userMod];
                    welvu_userMod = nil;
                }
                welvuOrganizationModel = nil;
            }
            
            welvu_configuration *welvu_configurationModel = [[welvu_configuration alloc] init];
            NSDictionary *systemConfig = [responseDictionary objectForKey:@"system"];
            
            NSDictionary *youtube = [systemConfig objectForKey:@"youtube"];
            welvu_configurationModel.welvu_user_id = welvu_userModel.welvu_user_id;
            if ((NSNull *)youtube == [NSNull null]){
                // NSLog(@"Patient image null");
                
            } else {
                
                welvu_configurationModel.welvu_configuration_adapter = @"youtube";
                
                welvu_configurationModel.welvu_configuration_key = @"div";
                welvu_configurationModel.welvu_configuration_value = [youtube objectForKey:@"client_id"];
                [self configInsertOrUpdate :welvu_configurationModel];
                
                welvu_configurationModel.welvu_configuration_key = @"client_secret";
                welvu_configurationModel.welvu_configuration_value = [youtube objectForKey:@"client_secret"];
                [self configInsertOrUpdate :welvu_configurationModel];
                
                welvu_configurationModel.welvu_configuration_key = @"DEV_KEY";
                welvu_configurationModel.welvu_configuration_value = [youtube objectForKey:@"DEV_KEY"];
                [self configInsertOrUpdate :welvu_configurationModel];
                
                welvu_configurationModel.welvu_configuration_key = @"id";
                welvu_configurationModel.welvu_configuration_value = [youtube objectForKey:@"id"];
                [self configInsertOrUpdate :welvu_configurationModel];
                
            }
            
            NSDictionary *box = [systemConfig objectForKey:@"box"];
            if ((NSNull *)box == [NSNull null]){
                // NSLog(@"Patient image null");
                
            } else {
                welvu_configurationModel.welvu_configuration_adapter = @"box";
                
                welvu_configurationModel.welvu_configuration_key = @"client_id";
                welvu_configurationModel.welvu_configuration_value = [box objectForKey:@"client_id"];
                [self configInsertOrUpdate :welvu_configurationModel];
                
                welvu_configurationModel.welvu_configuration_key = @"client_secret";
                welvu_configurationModel.welvu_configuration_value = [box objectForKey:@"client_secret"];
                [self configInsertOrUpdate :welvu_configurationModel];
                
                welvu_configurationModel.welvu_configuration_key = @"DEV_KEY";
                welvu_configurationModel.welvu_configuration_value  = [box objectForKey:@"DEV_KEY"];
                [self configInsertOrUpdate :welvu_configurationModel];
                
                welvu_configurationModel.welvu_configuration_key = @"id";
                welvu_configurationModel.welvu_configuration_value  = [box objectForKey:@"id"];
                [self configInsertOrUpdate :welvu_configurationModel];
            }
            
            
            self.welvu_userModel = [welvu_user getCurrentLoggedUser:[self getDBPath]];
            
            
            
            
            [orgViewController organizationDetailedList];
            [self.masterViewController switchToWelvuUSer];
            
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            
            
        }
        
    }
    [defaults removeObjectForKey:@"getAuthorize"];
    
}





#pragma mark Box Delegate
//box
- (void)boxAPITokensDidRefresh:(NSNotification *)notification
{
    BoxOAuth2Session *OAuth2Session = (BoxOAuth2Session *) notification.object;
    [self setRefreshTokenInKeychain:OAuth2Session.refreshToken];
}
//To refresh Token in KeyCahin.
- (void)setRefreshTokenInKeychain:(NSString *)refreshToken
{
    [self.keychain setObject:@"welvu" forKey: (__bridge id)kSecAttrService];
    [self.keychain setObject:refreshToken forKey:(__bridge id)kSecValueData];
}

//To refresh box access token.
- (void)boxTokensDidRefresh:(NSNotification *)notification {
    BoxOAuth2Session *OAuth2Session = (BoxOAuth2Session *)notification.object;
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.welvu_userModel.box_access_token = OAuth2Session.accessToken;
        self.welvu_userModel.box_refresh_access_token = OAuth2Session.refreshToken;
        self.welvu_userModel.box_expires_in = OAuth2Session.accessTokenExpiration;
        [welvu_user updateBoxAccessToken:[self getDBPath] :welvu_userModel];
    });
}

- (void)boxDidGetLoggedOut:(NSNotification *)notification {
    dispatch_sync(dispatch_get_main_queue(), ^{
        // clear old folder items
        self.boxAccessToken = nil;
        self.boxRefreshAccessToken = nil;
        self.boxExpiresIn = nil;
        self.welvu_userModel = nil;
    });
}

//Notification to refresh box access token
-(void)refreshBoxAccessToken {
    // Handle logged in
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxTokensDidRefresh:)
                                                 name:BoxOAuth2SessionDidBecomeAuthenticatedNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxTokensDidRefresh:)
                                                 name:BoxOAuth2SessionDidRefreshTokensNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
    // Handle logout
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxDidGetLoggedOut:)
                                                 name:BoxOAuth2SessionDidReceiveAuthenticationErrorNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxDidGetLoggedOut:)
                                                 name:BoxOAuth2SessionDidReceiveRefreshErrorNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
    
}


//box
- (void) receiveTestNotification:(NSNotification *) notification {
    notificationLable = [[UILabel alloc] initWithFrame:NOTIFICATION_DIMENTION_INITIAL_DETAILVU];
    
    //notificationLable.hidden = YES;
    notificationLable.layer.cornerRadius  = 5;
    notificationLable.textAlignment =  UITextAlignmentCenter;
    notificationLable.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    notificationLable.numberOfLines = 3;
    notificationLable.layer.masksToBounds = YES;
    notificationLable.backgroundColor = [UIColor whiteColor];
    notificationLable.textColor = [UIColor blackColor];
    notificationLable.text = @"  Email sent";
    //NSLog(@"self.splitViewController.presentedViewController %@",self.splitViewController.presentedViewController);
    if (self.splitViewController.presentedViewController == NULL) {
        
        [self.splitViewController.view addSubview:notificationLable];
        [self.splitViewController.view bringSubviewToFront:notificationLable];
        
    }else if(!self.splitViewController.presentedViewController == NULL){
        
        [self.splitViewController.presentedViewController.view addSubview:notificationLable];
        [self.splitViewController.view sendSubviewToBack:self.splitViewController.presentedViewController.view];
        [self.splitViewController.presentedViewController.view bringSubviewToFront:notificationLable];
        
    }else {
        //  NSLog(@"dont crash %@",self.splitViewController.presentedViewController);
        
    }
    
    NSDictionary *userInfo = [notification userInfo];
    NSString *statusMessage = [userInfo objectForKey:@"msg"];
    // NSLog (@"Successfully received the test notification!");
    
    notificationLable.hidden = false;
    //anin
    [notificationLable setText:statusMessage];
    [notificationLable setAlpha:0.0];
    [notificationLable setFrame:NOTIFICATION_DIMENTION_INITIAL];
    
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void)
     {
         [notificationLable setAlpha:1.0];
         [notificationLable setFrame:NOTIFICATION_DIMENTION];
     }
                     completion:^(BOOL finished)
     {
         if(finished)
         {
             [UIView animateWithDuration:2.5
                                   delay:8
                                 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                              animations:^(void)
              {
                  [notificationLable setAlpha:0.0];
                  [notificationLable setFrame:NOTIFICATION_DIMENTION];
              }
                              completion:^(BOOL finished)
              {
                  if(finished)
                      NSLog(@"Hurray. Label fadedIn & fadedOut");
              }];
         }
     }];
    //ani
    [self performSelector:@selector(hideNotificationLable) withObject:nil afterDelay:10];
}

//To Hide the label which text displays after send mail.
- (void) hideNotificationLable {
    [notificationLable setHidden:YES];
    [notificationLable removeFromSuperview];
}
//To add organization details to existing user
-(void)addorganizationDetails {
    if (!networkReachable){
        /// Create an alert if connection doesn't work
        UIAlertView* myAlert = [[UIAlertView alloc]
                                initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                delegate:self
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil];
        [myAlert show];
        
    }else{
        
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        
        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
            
            UIDeviceHardware *device = [[UIDeviceHardware alloc] init];
            
            NSString * deviceModel = [device platformString];
            NSString * udid = @"";
            NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            udid = [defaults stringForKey:@"userDeviceID"];
            
            
            NSString *getudid = [NSString stringWithFormat:@"?device_id=%@",[NSNumber numberWithInteger:udid]];
            NSLog(@"get udid %@",getudid);
            
            NSString *getbundleIdentifier = [NSString stringWithFormat:@"&app_identifier=%@",[[NSBundle mainBundle] bundleIdentifier]];
            NSLog(@"get bundleIdentifier %@",getbundleIdentifier);
            
            NSString *getdeviceModel = [NSString stringWithFormat:@"&device_info=%@",deviceModel];
            NSLog(@"get device_info %@",getdeviceModel);
            
            NSString *getcurrentSystemVersion = [NSString stringWithFormat:@"&platform_version=%@",currSysVer];
            NSLog(@"get getcurrentSystemVersion %@",getcurrentSystemVersion);
            
            
            
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@",PLATFORM_HOST_URL2,  PLATFORM_GET_ORGANIZE_ACTION_URL,getudid,getbundleIdentifier,getdeviceModel,getcurrentSystemVersion ]];
            
            
            // NSString *loginString = [NSString stringWithFormat:@"%@:%@", username, password];
            NSString *authHeader = [@"Bearer " stringByAppendingString:self.welvu_userModel.access_token];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
            
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
            
            [request setHTTPMethod:HTTP_METHOD_GET];
            
            getOrganization =[[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            [getOrganization start];
            
        }
        
    }
}

-(void)addWelvuVersionNumber {
    if(networkReachable) {
        
        self.welvu_userModel = [welvu_user getCurrentLoggedUser:[self getDBPath]];
        NSString *accessToken = nil;
        if(self.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = self.welvu_userModel.access_token;
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        NSDictionary *requestData = nil;
        requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                        [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                        
                        self.bundleVersionNumber ,HTTP_WELVU_VERSION_NUMBER,
                        accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,nil];
        HTTPRequestHandler *  requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                                :PLATFORM_HOST_URL :PLATFORM_SEND_WELVU_VERSION_ACTION_URL
                                                :HTTP_METHOD_POST
                                                :requestData :nil];
        
        requestHandler.delegate = self;
        [requestHandler makeHTTPRequest];
        
    }
}

-(void)logOutExistingUser{
    BOOL logoutUser = [welvu_user logoutUser:[self getDBPath] :self.welvu_userModel];
    
    
    //BOOL resetCompleted = [welvu_settings logoutUserResetTable:[appDelegate getDBPath]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * udid = [[defaults stringForKey:@"userDeviceID"] copy];
    NSString * currSysVer = [[defaults stringForKey:@"currentiOSVersion"] copy];
    NSString * prevSysVer = [[defaults stringForKey:@"previousiOSVersion"] copy];
    
    self.welvu_userModel = nil;
    self.isHelpShown = FALSE;
    self.ispatientVUContent = FALSE;
    self.isExportInProcess = FALSE;
    self.imageId = -1;
    self.recordCounter = 0;
    self.accessToken = nil;
    self.specialtyId = 0;
    self.currentWelvuSettings = nil;
    self.currentMasterScreen = 0;
    self.currentPatientInfo =  nil;
    self.currentPatientGraphInfo = nil;
    self.currentPatientAppointments = nil;
    self.isPatientSelected = nil;
    
    //Remove Database
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
}
// Prompting alert to user to rate for the app
-(void)appRatingForWelvu {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    [iRate sharedInstance].applicationBundleID = bundleIdentifier;
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    
    //enable preview mode
    [iRate sharedInstance].previewMode = NO;
    
    [iRate sharedInstance].daysUntilPrompt = 3;
    [iRate sharedInstance].usesUntilPrompt = 5;
    
}
//To check organization specialty is locked or not,if locked show alert to the user
-(void)checkAlertForOrgUser {
    welvu_specialtyModels = [welvu_specialty getAllSpecialty:self.getDBPath
                                                      userId:self.welvu_userModel.welvu_user_id];
    if(self.welvu_userModel.org_id > 0) {
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
            //  NSLog(@"gmt date %@" ,timeStamp);
            NSDate *dateFromString = [[NSDate alloc] init];
            dateFromString = [dateFormatter dateFromString:timeStamp];
            // NSLog(@"dateFromString%@",dateFromString);
            
            
            NSDate *dateFromString1 = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateFromString]];
            
            // NSLog(@"gmt date%@",dateFromString1);
            
            
            NSComparisonResult startCompare = [endServerDate compare: dateFromString1];
            if (startCompare == NSOrderedDescending || startCompare == NSOrderedSame) {
                activeSpecilaty ++;
                //  NSLog(@"activeSpecilaty %d" ,activeSpecilaty);
                
            }
            
            
        }
        
        if (activeSpecilaty <= 0) {
            
            //  NSLog(@" orgid %d",self.welvu_userModel.org_id);
            
            NSString *orgName = [welvu_organization getOrganizationNameById:[self getDBPath] :self.welvu_userModel.org_id];
            
            
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:[NSString stringWithFormat:
                                                 NSLocalizedString(@"LICENCE_EXPIRED1", nil), orgName]
                                  message:nil
                                  delegate: self
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil];
            alert.tag = 111;
            [alert show];
            
        }
        activeSpecilaty = 0;
        
    }
    
}
- (void)subcriptionCompletion{
    
    
    welvu_specialty *spec = [welvu_specialty getSpecialtymodel:[self getDBPath] :specialtyId userId:welvu_userModel.welvu_user_id];
    
    if(!spec.welvu_specialty_subscribed) {
        
        
        if (networkReachable){
            // NSLog(@" orgid %d",self.welvu_userModel.org_id);
            
            NSString *orgName = [welvu_organization getOrganizationNameById:[self getDBPath] :self.welvu_userModel.org_id];
            
            NSLog(@"Invalid License.");
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:[NSString stringWithFormat:
                                                 NSLocalizedString(@"LICENCE_EXPIRED1", nil), orgName]
                                  message:nil
                                  delegate: self
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil];
            alert.tag = 111;
            [alert show];
        } else {
            UIAlertView *contentAlert = [[UIAlertView alloc]initWithTitle:@"Message"
                                                                  message:@"CONNECT_INTERNET_UPDATE_SUBSCRIPTION" delegate:self
                                                        cancelButtonTitle:nil
                                                        otherButtonTitles:@"Ok", nil];
            contentAlert.tag = 112;
            [contentAlert show];
            
        }
    }
}

-(void)hidePatechForIos {
    [self.masterViewController removepatchinIos8];
    
}

-(void)configInsertOrUpdate  :(welvu_configuration *)welvu_configurationModel{
    int select = 0;
    // NSLog(@"OMG %d", [welvu_configuration getConfigurationForInsertUpdate:[self getDBPath] :welvu_configurationModel]);
    
    NSLog(@"user id %d",self.welvu_userModel.welvu_user_id);
    
    NSInteger PrimaryId = [welvu_user getPrimaryIdByUserId:[self getDBPath] :self.welvu_userModel.welvu_user_id];
    
    NSLog(@"userprimaryid %d" ,PrimaryId);
    BOOL  logoutPinValue;
    
    if(PrimaryId >0) {
        welvu_configurationModel.welvu_user_id = PrimaryId;
        
    } else {
        welvu_configurationModel.welvu_user_id = self.welvu_userModel.welvu_user_id;
        
    }
    
    select = [welvu_configuration getConfigurationForInsertUpdate:[self getDBPath] :welvu_configurationModel];
    NSLog(@"OMG %d", welvu_configurationModel.welvu_configuration_value);
    if (welvu_configurationModel.welvu_configuration_value) {
        
        if (select == 1) {
            [welvu_configuration updateOrgConfigDetails:[self getDBPath] :welvu_configurationModel];
        }else if (select == 0){
            [welvu_configuration addConfiguration:[self getDBPath] :welvu_configurationModel];
        }
        
    }
    
    
}

/*
 * Method name: POSTRequestWithURL
 * Description:post a request with url
 * Parameters: url
 * return nil,message_data
 */
- (NSMutableURLRequest *) POSTRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) message_data
                              attachmentData:(NSData *) attachment_data attachmentType:(NSString *) attachment_type
                          attachmentFileName:(NSString *) attachment_fileName {
    
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:180.0];
    [request setHTTPMethod:HTTP_METHOD_POST];
    
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
    
    if (attachment_data != nil) {
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
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:HTTP_REQUEST_CONTENT_LENGTH_KEY];
    
    // set URL
    [request setURL:url];
    
    
    return request;
}


-(void)oauthRefreshAccessToken {
    if(spinner == nil) {
        spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.splitViewController.presentedViewController.view:NSLocalizedString(@"PLEASE_WAIT_SPINNER_MSG", nil)];
    }
    
    if (canRequestAccessToken == YES) {
        canRequestAccessToken = NO;
        welvu_userModel = [welvu_user getCurrentLoggedUser:self.getDBPath];
        
        
        // HTTP_PASSWORD_KEY,PLATFORM_WELVU_GRANT_TYPE ,
        // WELVU_CLIENT_ID , PLATFORM_WELVU_CLIENT_ID ,
        
        NSLog(@"oauth refresh token %@",self.welvu_userModel.oauth_refresh_token);
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL, PLATFORM_SEND_AUTHENTICATION_ACTION_URL];
        NSLog(@"urlStr %@",urlStr);
        NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                     COLUMN_REFRESH_TOKEN,PLATFORM_WELVU_GRANT_TYPE ,
                                     WELVU_CLIENT_ID , PLATFORM_WELVU_CLIENT_ID ,
                                     self.welvu_userModel.oauth_refresh_token ,@"refresh_token",
                                     nil];
        NSLog(@"messageData %@",messageData);
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:url andDataDictionary:messageData attachmentData:nil
                                                         attachmentType:nil
                                                     attachmentFileName:nil];
        NSURLResponse *oAuthResponse;
        NSError *respError;
        
        //loginConnection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        //[loginConnection start];
       NSData *oAuthRespData = [NSURLConnection sendSynchronousRequest:requestDelegate returningResponse:&oAuthResponse error:&respError];
        [self oAuthRespMethod:oAuthRespData];
        
        
        
    }
    
}

-(void)oAuthRespMethod:(NSData *)data{
    NSLog(@"data %@", data);
    
    if(data) {
        NSError *error = nil;
        // 1. get the top level value as a dictionary
        
        NSString* newStr = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
        NSLog(@"platform data %@",newStr);
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"response dic %@",responseDictionary);
        NSString * responseStatus = [responseDictionary objectForKey:@"detail"];
        
        if ([responseStatus isEqualToString:@"Invalid refresh token"]) {
            
            welvu_user *welvu_userMod = [welvu_user copy:self.welvu_userModel];
            welvu_userMod.access_token = [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            
            welvu_userMod.oauth_token_type = [responseDictionary objectForKey:COLUMN_TOKEN_TYPE];
            
            welvu_userMod.oauth_refresh_token = [responseDictionary objectForKey:COLUMN_REFRESH_TOKEN];
            
            welvu_userMod.oauth_scope = [responseDictionary objectForKey:COLUMN_SCOPE];
            
            //update = [welvu_user updateOauthLoggedUserAccessToken:self.getDBPath :welvu_userMod];
            [self logOutExistingUser];
            
            
        }else {
            
            NSInteger insert = 0;
            
            welvu_user *welvu_userMod = [welvu_user copy:self.welvu_userModel];
            welvu_userMod.access_token = [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
            
            welvu_userMod.oauth_token_type = [responseDictionary objectForKey:COLUMN_TOKEN_TYPE];
            
            welvu_userMod.oauth_refresh_token = [responseDictionary objectForKey:COLUMN_REFRESH_TOKEN];
            
            welvu_userMod.oauth_scope = [responseDictionary objectForKey:COLUMN_SCOPE];
            
            
            
            
            
            NSString *columnexpiresin = [responseDictionary objectForKey:COLUMN_EXPIRES_IN];
            NSInteger  oauthvalue = [columnexpiresin integerValue];
            NSLog(@"value %d",oauthvalue);
            NSTimeInterval interval = oauthvalue ;
            NSDateFormatter *dateFormatters = NSDateFormatter.new;
            [dateFormatters setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
            NSTimeZone *gmt1 = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatters setTimeZone:gmt1];
            NSDate *today = [NSDate dateWithTimeIntervalSinceNow:interval];
            // "Today, 11:40 AM"
            NSLog(@"server date%@", [dateFormatters stringFromDate:today]);
            welvu_userMod.oauth_expires_in = [dateFormatters stringFromDate:today];
            
            //current date
            
            
            //ended
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setTimeZone:gmt];
            [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
            NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
            NSLog(@"gmt date %@" ,timeStamp);
            
            welvu_userMod.oauth_currentDate = timeStamp;
            
            
            //if ([welvu_userMod.oauth_refresh_token isEqualToString:nil] || [welvu_userMod.access_token isEqualToString:nil] ) {
            update = [welvu_user updateOauthLoggedUserAccessToken:self.getDBPath :welvu_userMod];
            // }
        }
    }
    canRequestAccessToken = YES;
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
    
}

@end
