//
//  welvuOrganizationViewController.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 23/01/14.
//  Copyright (c) 2014 ZANEC Soft Tech. All rights reserved.
//

#import "welvuOrganizationViewController.h"
#import "welvu_organization.h"
#import "welvuSettingsMasterViewController.h"
#import "welvuContants.h"
#import "welvu_specialty.h"
#import "PathHandler.h"
//#import "GAI.h"
//#import "SBJSON.h"
#import "UIDeviceHardware.h"
#import "welvu_user.h"

@interface welvuOrganizationViewController ()

@end

@implementation welvuOrganizationViewController
@synthesize organnizationsListTable, welvu_OrganizationArray ,matchDataArray, indexRow;
@synthesize themeLogo;
@synthesize delegate;
@synthesize fadeColor = fadeColor_;
@synthesize baseColor = baseColor_;
@synthesize  patientBottomFaddingView ,patientTopFaddingView;
@synthesize fadeOrientation = fadeOrientation_;
@synthesize g1 = g1_;
@synthesize g2 = g2_;
@synthesize g3 = g3_;
@synthesize g4 = g4_;

/*
 * Method name: initWithNibName
 * Description: initlize with nib name
 * Parameters: nibNameOrNil
 * return id
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    // [self orgSyncBtnClicked:nil];
    self.fadeOrientation = FADE_TOPNBOTTOM;
    self.baseColor = [UIColor colorWithRed:0.32f green:0.71f blue:0.95f alpha:1.0f];
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated {
    [self organizationDetailedList];
    indexRow = 0;
    
    
    
}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    indexRow = 0;
    // [self removeOauthRefreshToken];
    
}


-(void)viewDidAppear:(BOOL)animated {
    [self organizationDetailedList];
  
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.g3.frame = self.patientTopFaddingView.frame;
    self.g4.frame = self.patientBottomFaddingView.frame;
    [self.patientTopFaddingView.layer insertSublayer:self.g3 atIndex:0];
    [self.patientBottomFaddingView.layer insertSublayer:self.g4 atIndex:0];
    
    self.patientTopFaddingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TopArrowWithBg.png"]];
    self.patientBottomFaddingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"DownArrowWithBg.png"]];
    
    
    self.patientTopFaddingView.hidden = true;
    self.patientBottomFaddingView.hidden = true;
    
//    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
//                                       value:@"Organization VU-OV"];
//    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    
}
-(void)viewDidDisappear:(BOOL)animated{


}

//To get Organization list from DB and display it in a view
-(void)organizationDetailedList {
    
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    NSMutableArray * orgIds = nil;
    if(appDelegate.welvu_userModel.org_id == 0) {
        orgIds = [welvu_user getAllOrgIdOfUser:[appDelegate getDBPath]
                                        userId:appDelegate.welvu_userModel.welvu_user_id];
    } else {
        appDelegate.org_Logo = [PathHandler getDocumentDirPathForFile:([welvu_organization getOrganizationDetailsById
                                                                        :[appDelegate getDBPath]
                                                                        orgId:appDelegate.welvu_userModel.org_id]).orgLogoName];
        UIImage *image=[UIImage imageWithContentsOfFile:appDelegate.org_Logo];
        themeLogo.image = image;
        orgIds = [welvu_user getAllOrgIdOfUser:[appDelegate getDBPath]
                                        userId:appDelegate.welvu_userModel.user_primary_key];
    }
    // NSMutableArray * orgStatus = [[NSMutableArray alloc]init];
    if([orgIds count] > 0) {
        welvu_OrganizationArray = [[NSMutableArray alloc] init];
        for (NSNumber *orgId in orgIds) {
            NSInteger orgIdInteger = [orgId integerValue];
            
            NSString *orgStatuss =  [welvu_organization getOrganizationDetailsByOrgStatus:[appDelegate getDBPath] :orgIdInteger];
            
            if([orgStatuss isEqualToString:@"1"]) {
                
                [welvu_OrganizationArray addObject:[welvu_organization getOrganizationDetailsById
                                                    :[appDelegate getDBPath] orgId:orgIdInteger]];
            }
        }
    }
    [organnizationsListTable reloadData];
    
    
}

//scroll for fadding inorganization vu
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
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
#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [welvu_OrganizationArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    indexRow = 0;
    [organnizationsListTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                         animated:NO scrollPosition:0];
    welvu_organizationModel = [welvu_OrganizationArray objectAtIndex:indexRow];
    
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    UIView *selectedBackgroundView = [[UIView alloc]initWithFrame:cell.bounds];
    UIImageView  *selectedBackgroundViewImageView;
    selectedBackgroundViewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 19, 19)];
    [selectedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"PatientSelect.png"]]];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    }
    cell.textLabel.text= ((welvu_organization *)[welvu_OrganizationArray
                                                 objectAtIndex:indexPath.row]).orgName;
    cell.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"SpecialityBg.png"]];
    cell.selectedBackgroundView = selectedBackgroundView;
    cell.accessoryView = selectedBackgroundViewImageView;
    cell.textLabel.textColor = [UIColor blackColor];
    [cell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Organization VU-OV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Organization VU-OV"
                                                          action:@"Organization Name  - OV"
                                                           label:@"Organization Name"
                                                           value:nil] build]];
    
    
    
    
    @try {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        
        indexRow = indexPath.row;
        NSLog(@" inddex path.row %d",indexRow);
        welvu_organizationModel = [welvu_OrganizationArray objectAtIndex:indexRow];
        
        
    }
    @catch (NSException *exception) {
//        
//        id tracker = [[GAI sharedInstance] defaultTracker];
//        NSString * description = [NSString stringWithFormat:@"Organization VU-OV_Organization Name:%@",exception];
//        
//        [tracker send:[[GAIDictionaryBuilder
//                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
//                        withFatal:NO] build]];
        
        
        
    }
}
/*
 * Method name: loginUserWithOrganization
 * Description:user can log in ithrough organzization
 * Parameters: user_id ,orgId
 * return nil
 */
-(void) loginUserWithOrganization :(NSInteger) user_id orgId:(NSInteger)orgId {
    
    NSInteger select = false;
    select = [welvu_user updateLoggedUserByOrgId:[appDelegate getDBPath]
                                          userId:user_id orgId:orgId isPrimary:false];
    if (select == 1) {
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        NSInteger specialtyCount = [welvu_specialty getSpecialtyCount:[appDelegate getDBPath]
                                                               userId:appDelegate.welvu_userModel.welvu_user_id];
        if(specialtyCount > 0) {
           // [self syncSpecialtyFromPlatform];
            [self.delegate welvuOrganizationViewControllerDidFinish];
        } else {
            [self syncSpecialtyFromPlatform];
        }
    }
    
}

#pragma mark - sync Specialty


/*
 * Method name: syncSpecialtyFromPlatform
 * Description:this method will sync specialty from platform
 * Parameters: nil
 * return nil
 */
-(void) syncSpecialtyFromPlatform {
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
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view:NSLocalizedString(@"PLEASE_WAIT_SPINNER_ORG_MSG", nil)];
        }
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        
        // getting an
        NSString *accessToken = nil;
        if(appDelegate.welvu_userModel.access_token == nil) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
        } else {
            accessToken = appDelegate.welvu_userModel.access_token;
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        
        NSDictionary *requestData = nil;
        HTTPRequestHandler *requestHandler = nil;
        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
            requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                            [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                            appDelegate.welvu_userModel.box_access_token ,HTTP_RESPONSE_BOX_ACCESSTOKEN_KEY,
                            appDelegate.welvu_userModel.box_refresh_access_token ,HTTP_RESPONSE_BOX_REFRESH_ACCESSTOKEN_KEY,
                            appDelegate.welvu_userModel.box_expires_in ,HTTP_RESPONSE_BOX_EXPIRES_IN,
                            accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,nil];
            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
            if(appDelegate.welvu_userModel.org_id > 0) {
                [requestDataMutable
                 setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                 forKey:HTTP_REQUEST_ORGANISATION_KEY];
            }
            
            requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                              :PLATFORM_HOST_URL :PLATFORM_GET_BOX_SPECIALTY_ACTION_URL
                              :HTTP_METHOD_POST
                              :requestDataMutable :nil];
            
        } else if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU])  {
            
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
                    
                    
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",combineUrl, getString]];
                    
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
                
            } else {
                
                NSString *getString = [NSString stringWithFormat:@"?organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
                NSLog(@"get string %@",getString);
                
                
                
                NSString *combineUrl = [NSString stringWithFormat:@"%@%@",PLATFORM_HOST_URL1, PLATFORM_GET_SPECIALTY_ACTION_URL];
                NSLog(@"url %@",combineUrl);
                
                
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",combineUrl, getString]];
                
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
        }else {
            requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                            [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                            accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,nil];
            NSMutableDictionary *requestDataMutable = [requestData mutableCopy];
            if(appDelegate.welvu_userModel.org_id > 0) {
                [requestDataMutable
                 setObject:[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]
                 forKey:HTTP_REQUEST_ORGANISATION_KEY];
            }
            requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                              :PLATFORM_HOST_URL :PLATFORM_GET_SPECIALTY_ACTION_URL
                              :HTTP_METHOD_POST
                              :requestDataMutable :nil];
            
        }
        requestHandler.delegate = self;
        [requestHandler makeHTTPRequest];
        
    }
}


-(IBAction)orgSyncBtnClicked:(id)sender {
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    
    [tracker set:kGAIScreenName value:@"Organization VU-OV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Organization VU-OV"
                                                          action:@"Sync Button - OV"
                                                           label:@"Sync"
                                                           value:nil] build]];
    
    
    
    
    @try {

    
    if(spinner == nil) {
        spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view:NSLocalizedString(@"SYNC_ORGANIZATION_SPINNER_MSG", nil)];
    }
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    NSString *accessToken = nil;
    if(appDelegate.welvu_userModel.access_token == nil) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
    } else {
        accessToken = appDelegate.welvu_userModel.access_token;
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
    
    } @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Organization VU-OV_Sync:%@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
/*
 * Method name: settingBtnClicked
 * Description:To view the settings page
 * Parameters: usender
 * return IBAction
 */

//To view the settings
-(IBAction)settingBtnClicked:(id)sender {
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    
    [tracker set:kGAIScreenName value:@"Organization VU-OV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Organization VU-OV"
                                                          action:@"Setting Button - OV"
                                                           label:@"Setting"
                                                           value:nil] build]];
    
    
    
    
    
    @try {
        
        welvuSettingsMasterViewController *settingsMasterViewController = [[welvuSettingsMasterViewController alloc]                 initWithNibName:@"welvuSettingsMasterViewController" bundle:nil];
        settingsMasterViewController.delegate = self;
        settingsMasterViewController.orgVUController = @"OrgVU";
        UINavigationController *cntrol = [[UINavigationController alloc]
                                          initWithRootViewController:settingsMasterViewController];
        [cntrol setNavigationBarHidden:YES];
        appDelegate.welvu_userModel.org_id = nil;
        cntrol.navigationBar.barStyle = UIBarStyleBlack;
        cntrol.modalPresentationStyle = UIModalPresentationFormSheet;
        cntrol.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:cntrol animated:YES];
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Organization VU-OV_Setting:%@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}


#pragma mark Setting View Controller Delegate
-(void)settingsMasterViewControllerDidFinish {
    // [self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SETTINGS_UPDATED object:self userInfo:nil];
}

-(void)settingsMasterViewControllerDidCancel {
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark button action

- (IBAction)informationBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Organization VU - OV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Organization VU - OV"
                                                          action:@"Guide Button  - OV"
                                                           label:@"Guide"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
        overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        overlay.alpha = 1;
        overlay.backgroundColor = [UIColor clearColor];
        [overlay removeFromSuperview];
        
        UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        UIButton *overlayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [overlayCustomBtn addTarget:self action:@selector(closeOverlay:) forControlEvents:UIControlEventTouchUpInside];
        [overlayCustomBtn setFrame:CGRectMake(0, 0, 1024, 768)];
        overlayImageView.image = [UIImage imageNamed:@"OrgVUOverlay.png"];
        
        [overlay addSubview:overlayImageView];
        [overlay addSubview:overlayCustomBtn];
        
        [self.view addSubview:overlay];
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@" Organization-OV_Guide %@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}
- (IBAction)closeOverlay:(id)sender {
    
    //declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Organization VU - OV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Organization VU - OV"
                                                          action:@"Close help overlay  - OV"
                                                           label:@"overlayclose"
                                                           value:nil] build]];
    
    
    
    @try {
        if (overlay !=nil) {
            [overlay removeFromSuperview];
            overlay = nil;
        }
        
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Organization VU-OV_closeOverlay: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
/*
 * Method name: goButtonClicked
 * Description: to navigate ti specilaty
 * Parameters: sender
 * return IBAction
 */
-(IBAction)goButtonClicked:(id)sender {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Organization VU-OV" ];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Organization VU-OV"
                                                         action :@"Go Button - OV"
                                                         label  :@"Go"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
        
        //NSUserDefaults *standaradUserDefault = [NSUserDefaults standardUserDefaults];
        //NSInteger row = [standaradUserDefault integerForKey:@"selectOrgIndexValue"];
        NSLog(@"indexRow %d",indexRow);
        /* welvu_organizationModel = [welvu_OrganizationArray
         objectAtIndex:indexRow];*/
        //if(welvu_organizationModel.orgId != appDelegate.welvu_userModel.org_id) {
        
        NSInteger org_id = welvu_organizationModel.orgId;
        NSInteger user_id = appDelegate.welvu_userModel.welvu_user_id;
        
        appDelegate.welvu_userModel.org_id = welvu_organizationModel.orgId;
        
        appDelegate.org_Logo = [PathHandler getDocumentDirPathForFile:welvu_organizationModel.orgLogoName];
        UIImage *image=[UIImage imageWithContentsOfFile:appDelegate.org_Logo];
        themeLogo.image = image;
        [self loginUserWithOrganization :user_id orgId:org_id];
        //NSLog(@"help %@", appDelegate.splitViewController.popoverPresentationController );
        
        // }
        //row = nil;
        //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"selectOrgIndexValue"];
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Organization VU-OV_Go: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
/*
 * Method name: skipToWelVUBtnClicked
 * Description:To navigate and view the defalut welvu specpialty
 * Parameters: usender
 * return IBAction
 */

-(IBAction)skipToWelVUBtnClicked:(id)sender {
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Organization VU-OV" ];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Organization VU-OV"
                                                         action :@"Skip to WelVU Button - OV"
                                                         label  :@"Skip to WelVU"
                                                           value:nil] build]];
    
    
    
    
    @try {
        
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
            if(specialtyCount > 0) {
                [self.delegate welvuOrganizationViewControllerDidFinish];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"selectOrgIndexValue"];
            } else {
                [self syncSpecialtyFromPlatform];
            }
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        
        NSString * description = [NSString stringWithFormat:@"Organization VU-OV_Skip to WelVU:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
        
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
    
    //Remove Database
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
}

#pragma mark  NSURLCONNECTION DELEGATE

/*
 * Method name: platformDidResponseReceived
 * Description: GET RESPONSE FROM PLATFORM
 * Parameters: success,actionAPI
 * return nil
 */
-(void) platformDidResponseReceived:(BOOL)success:(NSString *)actionAPI {
    //  NSLog(@"Response received for get Specialty");
}
/*
 * Method name: platformDidReceivedData
 * Description:Get Respnse value from platform
 * Parameters: success,actionAPI,responseDictionary
 * return nil
 */
-(void)platformDidReceivedData:(BOOL)success :(NSDictionary *)responseDictionary:(NSString *)actionAPI {
    
    NSLog(@"dict %@",responseDictionary);
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
            if([welvu_organization getOrganizationDetailsById:[appDelegate getDBPath]
                                                        orgId:welvuOrganizationModel.orgId] == nil) {
                inserted = [welvu_organization addOrganizationUser:[appDelegate getDBPath] :
                            welvuOrganizationModel];
                
            } else {
                inserted = [welvu_organization updateOrganizationDetails
                            :[appDelegate getDBPath]
                            :welvuOrganizationModel];
                
            }
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            if([welvu_user getUserByEmailIdAndOrgId:[appDelegate getDBPath]
                                            emailId:appDelegate.welvu_userModel.email
                                              orgId:welvuOrganizationModel.orgId] == nil) {
                welvu_user *welvu_userMod = [welvu_user copy:appDelegate.welvu_userModel];
                welvu_userMod.org_id = welvuOrganizationModel.orgId;
                welvu_userMod.user_primary_key = appDelegate.welvu_userModel.welvu_user_id;
                welvu_userMod.user_Org_Role = welvuOrganizationModel.product_Type;
                welvu_userMod.user_org_status =welvuOrganizationModel.org_Status;
                [welvu_user addUserWithOrganizationDetails:[appDelegate getDBPath]
                                                          :welvu_userMod];
                welvu_userMod = nil;
            }
            welvuOrganizationModel = nil;
        }
        [self organizationDetailedList];
        
        if(spinner != nil) {
            [spinner removeSpinner];
            spinner = nil;
        }
    }
    else if(responseDictionary && ([actionAPI isEqualToString:PLATFORM_GET_SPECIALTY_ACTION_URL]
                                   || [actionAPI isEqualToString:PLATFORM_GET_BOX_SPECIALTY_ACTION_URL])) {
        
        BOOL insert = false;
        for(NSDictionary *welvuSpecialty in responseDictionary) {
            welvu_specialty *welvuSpecialtyModel = [[welvu_specialty alloc] init];
            welvuSpecialtyModel.welvu_platform_id = [[welvuSpecialty objectForKey:HTTP_RESPONSE_ID] integerValue];
            welvuSpecialtyModel.welvu_specialty_name = [welvuSpecialty objectForKey:HTTP_RESPONSE_NAME];
            
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"Specialty_%d",welvuSpecialtyModel.welvu_platform_id]];
            
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
            
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
            welvuSpecialtyModel.subscriptionStartDate = [dateFormatter dateFromString
                                                         :[welvuSpecialty objectForKey:HTTP_REQUEST_SUBSCRIPTION_START_DATE]];
            welvuSpecialtyModel.subscriptionEndDate = [dateFormatter dateFromString
                                                       :[welvuSpecialty objectForKey:HTTP_REQUEST_SUBSCRIPTION_END_DATE]];
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"Specialty_%d", welvuSpecialtyModel.welvu_platform_id]];
            [[NSUserDefaults standardUserDefaults] setValue:[welvuSpecialty
                                                             objectForKey:HTTP_REQUEST_TRANSACTION_RECEIPT]
                                                     forKey:[NSString stringWithFormat:@"Specialty_Receipt_%d",welvuSpecialtyModel.welvu_platform_id]];
            
            
            welvuSpecialtyModel.welvu_user_id = appDelegate.welvu_userModel.welvu_user_id;
            
            BOOL updateOnly = false;
            if([welvu_specialty getSpecialtyNameById:[appDelegate getDBPath]:welvuSpecialtyModel.welvu_platform_id
                                              userId:appDelegate.welvu_userModel.welvu_user_id]) {
                updateOnly = true;
            }
            BOOL updated = [welvu_specialty updateAllSpecialty:[appDelegate getDBPath] specialtyModel:welvuSpecialtyModel specialtyUpdate:updateOnly];
            if(!updated) {
                break;
            } else {
                insert = true;
            }
        }
        //BOOL insert = [welvu_specialty addAllSpecialty:[appDelegate getDBPath]:welvuSpecialtyModels];
        
        if(insert) {
            [self.delegate welvuOrganizationViewControllerDidFinish];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"selectOrgIndexValue"];
            
        }
    }
}
/*
 * Method name: connection
 * Description:if connection fails while loading
 * Parameters: error
 * return nil
 */
-(void)failedWithErrorDetails:(NSError *)error:(NSString *)actionAPI {
    // NSLog(@"Failed to get Specialty %@", error);
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
}

-(void)logoutUser {
    [self.delegate userLoggedOutFromOrganizationViewController];
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
        
        
        if( (connection ==  authorize)) {
            
            //SBJSON *parser = [[SBJSON alloc] init];
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
        else if (connection == getOrganization) {
            if(data) {
                
                
                
                NSError *error;
                //SBJSON *parser = [[SBJSON alloc] init];
                // 1. get the top level value as a dictionary
                NSString* newStr = [[NSString alloc] initWithData:data
                                                         encoding:NSUTF8StringEncoding];
                NSLog(@"platform data %@",newStr);
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
                NSLog(@"response dic %@",responseDictionary);
                
                
                
                
                
                
                NSDictionary *getOrganization = [responseDictionary objectForKey:@"organizations"];
                
                for(NSDictionary *welvuOrg in getOrganization) {
                    
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
                    if([welvu_organization getOrganizationDetailsById:[appDelegate getDBPath]
                                                                orgId:welvuOrganizationModel.orgId] == nil) {
                        inserted = [welvu_organization addOrganizationUser:[appDelegate getDBPath] :
                                    welvuOrganizationModel];
                        
                    } else {
                        inserted = [welvu_organization updateOrganizationDetails
                                    :[appDelegate getDBPath]
                                    :welvuOrganizationModel];
                        
                    }
                    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                    if([welvu_user getUserByEmailIdAndOrgId:[appDelegate getDBPath]
                                                    emailId:appDelegate.welvu_userModel.email
                                                      orgId:welvuOrganizationModel.orgId] == nil) {
                        welvu_user *welvu_userMod = [welvu_user copy:appDelegate.welvu_userModel];
                        welvu_userMod.org_id = welvuOrganizationModel.orgId;
                        welvu_userMod.user_primary_key = appDelegate.welvu_userModel.welvu_user_id;
                        welvu_userMod.user_Org_Role = welvuOrganizationModel.product_Type;
                        welvu_userMod.user_org_status =welvuOrganizationModel.org_Status;
                        [welvu_user addUserWithOrganizationDetails:[appDelegate getDBPath]
                                                                  :welvu_userMod];
                        welvu_userMod = nil;
                    }
                    welvuOrganizationModel = nil;
                }
                [self organizationDetailedList];
                
                if(spinner != nil) {
                    [spinner removeSpinner];
                    spinner = nil;
                }
                
                
            }
        }
        else if(connection == getSpecialty) {
            if(data) {
                
                
                
                NSError *error;
               // SBJSON *parser = [[SBJSON alloc] init];
                // 1. get the top level value as a dictionary
                NSString* newStr = [[NSString alloc] initWithData:data
                                                         encoding:NSUTF8StringEncoding];
                NSLog(@"platform data %@",newStr);
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                NSLog(@"response dic %@",responseDictionary);
                NSDictionary *getSpecialties = [responseDictionary objectForKey:@"specialties"];
                
                
                BOOL insert = false;
                for(NSDictionary *welvuSpecialty in getSpecialties) {
                    welvu_specialty *welvuSpecialtyModel = [[welvu_specialty alloc] init];
                    welvuSpecialtyModel.welvu_platform_id = [[welvuSpecialty objectForKey:HTTP_RESPONSE_ID] integerValue];
                    welvuSpecialtyModel.welvu_specialty_name = [welvuSpecialty objectForKey:HTTP_RESPONSE_NAME];
                    
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"Specialty_%d",welvuSpecialtyModel.welvu_platform_id]];
                    
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
                    
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
                    welvuSpecialtyModel.subscriptionStartDate = [dateFormatter dateFromString
                                                                 :[welvuSpecialty objectForKey:HTTP_REQUEST_SUBSCRIPTION_START_DATE]];
                    welvuSpecialtyModel.subscriptionEndDate = [dateFormatter dateFromString
                                                               :[welvuSpecialty objectForKey:HTTP_REQUEST_SUBSCRIPTION_END_DATE]];
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"Specialty_%d", welvuSpecialtyModel.welvu_platform_id]];
                    [[NSUserDefaults standardUserDefaults] setValue:[welvuSpecialty
                                                                     objectForKey:HTTP_REQUEST_TRANSACTION_RECEIPT]
                                                             forKey:[NSString stringWithFormat:@"Specialty_Receipt_%d",welvuSpecialtyModel.welvu_platform_id]];
                    
                    
                    welvuSpecialtyModel.welvu_user_id = appDelegate.welvu_userModel.welvu_user_id;
                    
                    BOOL updateOnly = false;
                    if([welvu_specialty getSpecialtyNameById:[appDelegate getDBPath]:welvuSpecialtyModel.welvu_platform_id
                                                      userId:appDelegate.welvu_userModel.welvu_user_id]) {
                        updateOnly = true;
                    }
                    BOOL updated = [welvu_specialty updateAllSpecialty:[appDelegate getDBPath] specialtyModel:welvuSpecialtyModel specialtyUpdate:updateOnly];
                    if(!updated) {
                        break;
                    } else {
                        insert = true;
                    }
                }
                //BOOL insert = [welvu_specialty addAllSpecialty:[appDelegate getDBPath]:welvuSpecialtyModels];
                
                if(insert) {
                    [self.delegate welvuOrganizationViewControllerDidFinish];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"selectOrgIndexValue"];
                    
                }
            }
            
        }
        
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        if(connection == authorize)  {
            [welvu_configuration deleteCacheData:[appDelegate getDBPath]];
            NSError *error;
            //SBJSON *parser = [[SBJSON alloc] init];
            // 1. get the top level value as a dictionary
            if([defaults objectForKey:@"getAuthorize"]) {
                responseStr = [defaults objectForKey:@"getAuthorize"];
            }
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
            
            NSLog(@"response dic %@",responseDictionary);
            
            
            NSDictionary *getOrganization = [responseDictionary objectForKey:@"organizations"];
            
            for(NSDictionary *welvuOrg in getOrganization) {
                
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
                        [appDelegate configInsertOrUpdate :welvu_configurationModel];
                        
                        welvu_configurationModel.welvu_configuration_key = @"client_secret";
                        welvu_configurationModel.welvu_configuration_value = [youtube objectForKey:@"client_secret"];
                        [appDelegate configInsertOrUpdate :welvu_configurationModel];
                        
                        welvu_configurationModel.welvu_configuration_key = @"DEV_KEY";
                        welvu_configurationModel.welvu_configuration_value = [youtube objectForKey:@"DEV_KEY"];
                        [appDelegate configInsertOrUpdate :welvu_configurationModel];
                        
                        welvu_configurationModel.welvu_configuration_key = @"id";
                        welvu_configurationModel.welvu_configuration_value = [youtube objectForKey:@"id"];
                        [appDelegate configInsertOrUpdate :welvu_configurationModel];
                        
                        
                    }
                    
                    NSDictionary *box = [config objectForKey:@"box"];
                    NSLog(@"box org %@",box);
                    
                    if ((NSNull *)box == [NSNull null]){
                        // NSLog(@"Patient image null");
                        
                    } else {
                        welvu_configurationModel.welvu_configuration_adapter = @"box";
                        
                        welvu_configurationModel.welvu_configuration_key = @"client_id";
                        welvu_configurationModel.welvu_configuration_value = [box objectForKey:@"client_id"];
                        [appDelegate configInsertOrUpdate :welvu_configurationModel];
                        
                        welvu_configurationModel.welvu_configuration_key = @"client_secret";
                        welvu_configurationModel.welvu_configuration_value = [box objectForKey:@"client_secret"];
                        [appDelegate configInsertOrUpdate :welvu_configurationModel];
                        
                        welvu_configurationModel.welvu_configuration_key = @"id";
                        welvu_configurationModel.welvu_configuration_value  = [box objectForKey:@"id"];
                        [appDelegate configInsertOrUpdate :welvu_configurationModel];
                        
                        welvu_configurationModel.welvu_configuration_key = @"redirect_uri";
                        welvu_configurationModel.welvu_configuration_value  = [box objectForKey:@"redirect_uri"];
                        [appDelegate configInsertOrUpdate :welvu_configurationModel];
                    }
                    
                }
                config = nil;
                
                
                //end key values
                
                
                
                if([welvu_organization getOrganizationDetailsById:[appDelegate getDBPath]
                                                            orgId:welvuOrganizationModel.orgId] == nil) {
                    inserted = [welvu_organization addOrganizationUser:[appDelegate getDBPath] :
                                welvuOrganizationModel];
                    
                } else {
                    inserted = [welvu_organization updateOrganizationDetails
                                :[appDelegate getDBPath]
                                :welvuOrganizationModel];
                    
                }
                appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
                if([welvu_user getUserByEmailIdAndOrgId:[appDelegate getDBPath]
                                                emailId:appDelegate.welvu_userModel.email
                                                  orgId:welvuOrganizationModel.orgId] == nil) {
                    welvu_user *welvu_userMod = [welvu_user copy:appDelegate.welvu_userModel];
                    welvu_userMod.org_id = welvuOrganizationModel.orgId;
                    welvu_userMod.user_primary_key = appDelegate.welvu_userModel.welvu_user_id;
                    welvu_userMod.user_Org_Role = welvuOrganizationModel.product_Type;
                    welvu_userMod.user_org_status =welvuOrganizationModel.org_Status;
                    [welvu_user addUserWithOrganizationDetails:[appDelegate getDBPath]
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
                [appDelegate configInsertOrUpdate :welvu_configurationModel];
                
                welvu_configurationModel.welvu_configuration_key = @"client_secret";
                welvu_configurationModel.welvu_configuration_value = [youtube objectForKey:@"client_secret"];
                [appDelegate configInsertOrUpdate :welvu_configurationModel];
                
                welvu_configurationModel.welvu_configuration_key = @"DEV_KEY";
                welvu_configurationModel.welvu_configuration_value = [youtube objectForKey:@"DEV_KEY"];
                [appDelegate configInsertOrUpdate :welvu_configurationModel];
                
                welvu_configurationModel.welvu_configuration_key = @"id";
                welvu_configurationModel.welvu_configuration_value = [youtube objectForKey:@"id"];
                [appDelegate configInsertOrUpdate :welvu_configurationModel];
                
            }
            
            NSDictionary *box = [systemConfig objectForKey:@"box"];
            if ((NSNull *)box == [NSNull null]){
                // NSLog(@"Patient image null");
                
            } else {
                welvu_configurationModel.welvu_configuration_adapter = @"box";
                
                welvu_configurationModel.welvu_configuration_key = @"client_id";
                welvu_configurationModel.welvu_configuration_value = [box objectForKey:@"client_id"];
                [appDelegate configInsertOrUpdate :welvu_configurationModel];
                
                welvu_configurationModel.welvu_configuration_key = @"client_secret";
                welvu_configurationModel.welvu_configuration_value = [box objectForKey:@"client_secret"];
                [appDelegate configInsertOrUpdate :welvu_configurationModel];
                
                welvu_configurationModel.welvu_configuration_key = @"DEV_KEY";
                welvu_configurationModel.welvu_configuration_value  = [box objectForKey:@"DEV_KEY"];
                [appDelegate configInsertOrUpdate :welvu_configurationModel];
                
                welvu_configurationModel.welvu_configuration_key = @"id";
                welvu_configurationModel.welvu_configuration_value  = [box objectForKey:@"id"];
                [appDelegate configInsertOrUpdate :welvu_configurationModel];
            }
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            
            //[appDelegate.masterViewController switchToWelvuUSer];
            
            [self organizationDetailedList];
            
            if(spinner != nil) {
                [spinner removeSpinner];
                spinner = nil;
            }
            [defaults removeObjectForKey:@"getAuthorize"];
            
            
        }
    }
    
}

- (NSString *)getDeviceUDID {
    NSString *udid = @"";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    udid = [defaults stringForKey:@"userDeviceID"];
    return udid;
}


/*
 * Method name: getConfiguration
 * Description:this method will sync specialty from platform
 * Parameters: nil
 * return nil
 */
-(void)getConfigurationOrg {
    if (!appDelegate.networkReachable){
        /// Create an alert if connection doesn't work
        UIAlertView* myAlert = [[UIAlertView alloc]
                                            initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                            message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                            delegate:self
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
        [myAlert show];
    } else {
        
        
        
        
        UIDeviceHardware *device = [[UIDeviceHardware alloc] init];
        
        NSString * deviceModel = [device platformString];
        NSString * udid = @"";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        udid = [defaults stringForKey:@"userDeviceID"];
        
        
        NSString *getudid = [self getDeviceUDID];
        
        NSString *getDeviceId = [NSString stringWithFormat:@"?device_id=%@",getudid];
        NSLog(@" getDeviceId %@",getDeviceId);
        
        
        NSString *getbundleIdentifier = [NSString stringWithFormat:@"&app_identifier=%@",[[NSBundle mainBundle] bundleIdentifier]];
        NSLog(@"get bundleIdentifier %@",getbundleIdentifier);
        
        NSString *getdeviceModel = [NSString stringWithFormat:@"&device_info=%@",deviceModel];
        NSLog(@"get device_info %@",getdeviceModel);
        
        NSString *getcurrentSystemVersion = [NSString stringWithFormat:@"&platform_version=%@",currSysVer];
        NSLog(@"get getcurrentSystemVersion %@",getcurrentSystemVersion);
        
        
        
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@",PLATFORM_HOST_URL2,  PLATFORM_GET_ORGANIZE_ACTION_URL,getDeviceId,getbundleIdentifier,getdeviceModel,getcurrentSystemVersion ]];
        
        
        // NSString *loginString = [NSString stringWithFormat:@"%@:%@", username, password];
        NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
        
        [request setHTTPMethod:HTTP_METHOD_GET];
        
        authorize =[[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        [authorize start];
    }
}

-(void)AppDidBecomeActive{
    
    welvu_organizationModel = [welvu_OrganizationArray objectAtIndex:0];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
