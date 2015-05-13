
//
//  welvuRegistrationViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 23/01/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

//Sample User: logeshamigo pwd :abc123 AccessToken: 1dad3726dfeb1e41566bc89f2b4b7a6a

#import "welvuRegistrationViewController.h"
#import "welvuLoginViewController.h"
#import "welvu_specialty.h"
#import "welvu_registration.h"
#import "welvu_user.h"
#import "welvuContants.h"
//#import "JSON.h"
#import "Base64.h"
#import "UIDeviceHardware.h"
#import "GAI.h"
//Org
#import "welvu_organization.h";
#import "welvuOrganizationViewController.h"
#import "BoxAuthorizationNavigationController.h"
#import "PathHandler.h"

@interface welvuRegistrationViewController ()
- (void)boxAPITokensDidRefresh:(NSNotification *)notification;
- (void)boxAPIAuthenticationDidSucceed:(NSNotification *)notification;
- (void)boxAPIAuthenticationDidFail:(NSNotification *)notification;
- (void)boxAPIInitiateLogin:(NSNotification *)notification;
@end

@implementation welvuRegistrationViewController
@synthesize delegate;
@synthesize  orgDetails ,OrgInsert ,updateOnly ,orgUpdated ,sucessRegistrationAlert ,organizationCount, responseDictionaryy,actionAPi;

//oauth
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}
#pragma mark UIView Life Cycle

/*
 * Method name: viewDidLoad
 * Description:Load the page when  navigating
 * Parameters: nil
 * return: nil
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    orgDetails = false;
    orgCountPin = FALSE;
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Registration VU-RG"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    // Do any additional setup after loading the view from its nib.
    
    helpView.hidden=false;
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    registration = [[welvu_registration alloc] init];
    welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    
    if(welvu_userModel && !welvu_userModel.access_token_obtained_on) {
        registrationView.hidden = false;
    }
    [self specialtyOptions];
    specialtyPicker.delegate = self;
    [specialtyPicker selectRow:0 inComponent:0 animated:NO];
    errorLoginUsername.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ErrorMessage.png"]];
    errorLoginPassword.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ErrorMessage.png"]];
    errorName.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ErrorMessage.png"]];
    errorSpecialty.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ErrorMessage.png"]];
    errorEmail.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ErrorMessage.png"]];
    /* errorUsername.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ErrorMessage.png"]];*/
    errorPassword.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ErrorMessage.png"]];
    errorConfirmPassword.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ErrorMessage.png"]];
    errorOrganization.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ErrorMessage.png"]];
    errorPhone.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ErrorMessage.png"]];
    
    
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
    
    replayOverlay = [[UIView alloc] initWithFrame:CGRectMake(258, 160, 436, 290)];
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
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OPENEMR]) {
        registrationView.hidden = YES;
        forgotPassword.hidden = YES;
        
    } else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        
        loginView.hidden = YES;
        registrationView.hidden = YES;
        boxLoginBtn.hidden = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(boxAPIAuthenticationDidSucceed:)
                                                     name:BoxOAuth2SessionDidBecomeAuthenticatedNotification
                                                   object:[BoxSDK sharedSDK].OAuth2Session];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(boxAPIAuthenticationDidFail:)
                                                     name:BoxOAuth2SessionDidReceiveAuthenticationErrorNotification
                                                   object:[BoxSDK sharedSDK].OAuth2Session];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(boxAPIInitiateLogin:)
                                                     name:BoxOAuth2SessionDidReceiveRefreshErrorNotification
                                                   object:[BoxSDK sharedSDK].OAuth2Session];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
#pragma mark Action Methods

/*
 * Method name: closeOverlay
 * Description:To close otr hide the overlay
 * Parameters: id
 * return: nil
 */
-(IBAction)closeOverlay:(id)sender {
    if(replayOverlay !=nil) {
        replayOverlay.hidden=TRUE;
        [moviePlayer prepareToPlay];
        [moviePlayer play];
        
    }
}
/*
 * Method name: helpContinueBtnClicked
 * Description:To show the guide and help overlay for the respetced view
 * Parameters: id
 * return: nil
 */
-(IBAction)helpContinueBtnClicked:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Registration VU-RG"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Registration VU-RG"
                                                          action:@"Get Started Button - RG"
                                                           label:@"Get Started"
                    
                                                           value:nil] build]];
    @try {
        
        
        helpView.hidden = true;
        appDelegate.isHelpShown = true;
        [moviePlayer stop];
    }
    @catch (NSException *exception) {
        //[tracker set:kGAIException value:exception ];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"RegistrationVU-RG_Get Started:%@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
    }
}

/*
 * Method name: loginUser
 * Description:to sign in the authorised user
 * Parameters: nil
 * return nil
 */
-(void) loginUser {
    if(spinner == nil) {
        spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view:NSLocalizedString(@"PLEASE_WAIT_SPINNER_MSG", nil)];
    }
    // HTTP_PASSWORD_KEY,PLATFORM_WELVU_GRANT_TYPE ,
    // WELVU_CLIENT_ID , PLATFORM_WELVU_CLIENT_ID ,
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL, PLATFORM_SEND_AUTHENTICATION_ACTION_URL];
    UIDeviceHardware *device = [[UIDeviceHardware alloc] init];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString * deviceModel = [device platformString];
    NSString * udid = @"";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    udid = [defaults stringForKey:@"userDeviceID"];
    NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                 loginUserName.text, HTTP_REQUEST_USER_NAME,
                                 loginPassword.text, HTTP_PASSWORD_KEY,
                                 udid, HTTP_REQUEST_DEVICE_ID,
                                 HTTP_PASSWORD_KEY,PLATFORM_WELVU_GRANT_TYPE ,
                                 WELVU_CLIENT_ID , PLATFORM_WELVU_CLIENT_ID ,
                                 deviceModel, HTTP_REQUEST_DEVICE_INFO,
                                 currSysVer, HTTP_REQUEST_PLATFORM_VERSION,nil];
    NSLog(@"login messageData %@",messageData);
    
    NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:url andDataDictionary:messageData attachmentData:nil
                                                     attachmentType:nil
                                                 attachmentFileName:nil];
    
    loginConnection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
    [loginConnection start];
}

/*
 * Method name: hideRegistrationErrorDetail
 * Description: Hide Error DEtail for Registration view
 * Parameters: nil
 * return nil
 */
-(void) hideRegistrationErrorDetail  {
    errorName.hidden = true;
    // errorUsername.hidden = true;
    errorEmail.hidden = true;
    errorPassword.hidden = true;
    errorConfirmPassword.hidden = true;
    errorOrganization.hidden = true;
    errorPhone.hidden = true;
    
}

/*
 * Method name: registerOptionBtnClicked
 * Description: tap register button to regsiter the details
 * Parameters: id
 * return nil
 */
-(IBAction)registerOptionBtnClicked:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Registration VU-RG"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Registration VU-RG"
                                                          action:@"Register Button - RG"
                                                           label:@"Register"
                                                           value:nil] build]];
    @try {
        [name resignFirstResponder];
        //[username resignFirstResponder];
        [email resignFirstResponder];
        [password resignFirstResponder];
        [confirmPassword resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            specialtyPicker.frame = CGRectMake(specialtyPicker.frame.origin.x, 1000,
                                               specialtyPicker.frame.size.width, specialtyPicker.frame.size.width);
        }];
        
        BOOL validateName = [self validateTextField:name.text :200];
        BOOL validateSpecialty = [self validateTextField:specialty.text:nil];
        //BOOL validateUsername = [self validateTextField:username.text :200];
        BOOL validateEmail = [self validateEmail:email.text];
        BOOL validatePassword = [self validatePasswordTextField:password.text :200];
        BOOL validateConfirmPassword = [self validateConfirmTextField:confirmPassword.text:password.text:200];
        BOOL validateOrganization = [self validateTextField:organization.text :200];
        BOOL validatePhone = [self validatePhoneNumber:phoneNumber.text];
        
        
        if( validateEmail && validatePassword && validateConfirmPassword && validatePhone && validateOrganization) {
            
            [self hideRegistrationErrorDetail];
            registration.name = name.text;
            //registration.username = username.text;
            registration.email = email.text;
            registration.password = password.text;
            registration.organization_Name = organization.text;
            registration.phoneNumber = phoneNumber.text;
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
                [self registerUser];
            }
        } else {
            
            if(!validateName) {
                errorName.hidden = false;
                errorName.text = NSLocalizedString(@"ALERT_REGISTRATION_ERROR_NAME_MSG", nil);
            } else {
                errorName.hidden = true;
            }
            
            if(!validateEmail) {
                errorEmail.hidden = false;
                errorEmail.text = NSLocalizedString(@"ALERT_REGISTRATION_ERROR_EMAIL_MSG", nil);
            } else {
                errorEmail.hidden = true;
            }
            if(!validatePassword) {
                
                if(password.text.length == nil) {
                    
                    
                    errorPassword.hidden = false;
                    errorPassword.text = NSLocalizedString(@"ALERT_REGISTRATION_ERROR_PASSWORD_MSG", nil);}
                
                else if(password.text.length <=8) {
                    
                    errorPassword.hidden = false;
                    errorPassword.text = NSLocalizedString(@"ALERT_REGISTRATION_ERROR_LENGHT_PASSWORD_MSG", nil);}
                else if(password.text.length >=16) {
                    
                    errorPassword.hidden = false;
                    errorPassword.text = NSLocalizedString(@"ALERT_REGISTRATION_ERROR_MAX_LENGHT_PASSWORD_MSG", nil);}
            }else {
                
                errorPassword.hidden = true;
                
            }
            
            if(!validateConfirmPassword) {
                
                if ([password.text isEqualToString:confirmPassword.text]) {
                    
                    if (confirmPassword.text.length == 0) {
                        errorConfirmPassword.hidden = false;
                        
                        errorConfirmPassword.text = NSLocalizedString(@"ALERT_REGISTRATION_ERROR_CONFIRM_PASSWORD_MSG", nil);
                        
                    } else {
                        errorConfirmPassword.hidden = true;
                    }
                } else if (![password.text isEqualToString:confirmPassword.text]) {
                    
                    
                    if(confirmPassword.text.length == 0) {
                        errorConfirmPassword.hidden = false;
                        
                        errorConfirmPassword.text = NSLocalizedString(@"ALERT_REGISTRATION_ERROR_CONFIRM_PASSWORD_MSG", nil);
                    } else {
                        errorConfirmPassword.hidden = false;
                        
                        errorConfirmPassword.text = NSLocalizedString(@"ALERT_REGISTRATION_ERROR_CONFIRM_PASSWORD_NOTVALID_MSG", nil);
                    }
                }
            }else {
                errorConfirmPassword.hidden = true;
                
            }
            
            if(!validateOrganization) {
                errorOrganization.hidden = false;
                errorOrganization.text = NSLocalizedString(@"ALERT_REGISTRATION_ERROR_ORGANIZATION", nil);
                
            } else {
                errorOrganization.hidden = true;
            }
            
            if(!validatePhone) {
                errorPhone.hidden = false;
                errorPhone.text = NSLocalizedString(@"ALERT_REGISTRATION_ERROR_PHONE", nil);
            }
            else {
                errorPhone.hidden = true;
            }
            
        }
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"RegistrationVU-RG_Register:%@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
/*
 * Method name: registerUser
 * Description: register the user with the paltform url
 * Parameters: id
 * return nil
 */
-(void) registerUser {
    if(spinner == nil) {
        spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view:NSLocalizedString(@"PLEASE_WAIT_SPINNER_MSG", nil)];
    }
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    if (/*[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OAUTH] ||*/ [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL2, PLATFORM_SEND_REGISTRATION_ACTION_URL];
        UIDeviceHardware *device = [[UIDeviceHardware alloc] init];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSString * deviceModel = [device platformString];
        NSString * udid = @"";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        udid = [defaults stringForKey:@"userDeviceID"];
        NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                     registration.name, HTTP_REQUEST_NAME,
                                     
                                     registration.email, HTTP_EMAILID_KEY,
                                     registration.password, HTTP_PASSWORD_KEY,
                                     registration.organization_Name, HTTP_ORGANIZATION_KEY,
                                     registration.phoneNumber, HTTP_PHONENUMBER_KEY,
                                     appDelegate.bundleVersionNumber ,HTTP_WELVU_VERSION_NUMBER,
                                     @" ", HTTP_SPECIALTY_KEY,
                                     udid, HTTP_REQUEST_DEVICE_ID,
                                     deviceModel, HTTP_REQUEST_DEVICE_INFO,
                                     currSysVer, HTTP_REQUEST_PLATFORM_VERSION,nil];
        
        NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:url andDataDictionary:messageData attachmentData:nil
                                                         attachmentType:nil
                                                     attachmentFileName:nil];
        
        getRegistration = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        [getRegistration start];
        
    }
    else {
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view:NSLocalizedString(@"PLEASE_WAIT_SPINNER_MSG", nil)];
        }
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL, PLATFORM_SEND_REGISTRATION_ACTION_URL];
        
        NSURL *url = [NSURL URLWithString:urlStr];
        
        
        UIDeviceHardware *device = [[UIDeviceHardware alloc] init];
        NSString * deviceModel = [device platformString];
        NSString * udid = @"";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        udid = [defaults stringForKey:@"userDeviceID"];
        // NSLog(@"RegisterUser UDID %@", udid);
        NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                     registration.name, HTTP_REQUEST_NAME,
                                     
                                     registration.email, HTTP_EMAILID_KEY,
                                     registration.password, HTTP_PASSWORD_KEY,
                                     registration.organization_Name, HTTP_ORGANIZATION_KEY,
                                     registration.phoneNumber, HTTP_PHONENUMBER_KEY,
                                     appDelegate.bundleVersionNumber ,HTTP_WELVU_VERSION_NUMBER,
                                     @" ", HTTP_SPECIALTY_KEY,
                                     udid, HTTP_REQUEST_DEVICE_ID,
                                     deviceModel, HTTP_REQUEST_DEVICE_INFO,
                                     currSysVer, HTTP_REQUEST_PLATFORM_VERSION,nil];
        
        NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:url andDataDictionary:messageData attachmentData:nil
                                                         attachmentType:nil
                                                     attachmentFileName:nil];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        [connection start];
        
        
    }
}
/*
 * Method name: hideLoginErrorDetail
 * Description: Hide Error Detils for Login
 * Parameters: nil
 * return nil
 */
-(void) hideLoginErrorDetail  {
    errorLoginUsername.hidden = true;
    errorLoginPassword.hidden = true;
}
/*
 * Method name: loginBtnClicked
 * Description:user has to tap login button to sign in
 * Parameters: id
 * return nil
 */
-(IBAction)loginBtnClicked:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Registration VU-RG"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Registration VU-RG"
                                                          action:@"Login Button - RG"
                                                           label:@"Login"
                                                           value:nil] build]];
    @try {
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [loginUserName resignFirstResponder];
        [loginPassword resignFirstResponder];
        
        //For welvu
        // BOOL validateUsername = [self validateEmail:loginUserName.text];
        //For Welvu OpenEMR
        BOOL validateUsername = [self validateTextField:loginUserName.text :200];
        
        BOOL validatePassword = [self validateTextField:loginPassword.text :200];
        if((validatePassword) && (validateUsername)) {
            [self hideLoginErrorDetail];
            if (!appDelegate.networkReachable){
                /// Create an alert if connection doesn't work
                UIAlertView *myAlert = [[UIAlertView alloc]
                                        initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                        message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                        delegate:nil
                                        cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                        otherButtonTitles:nil];
                [myAlert show];
            } else {
                [self loginUser];
            }
        } else {
            
            if(!validateUsername) {
                errorLoginUsername.hidden = false;
                errorLoginUsername.text = NSLocalizedString(@"ALERT_REGISTRATION_ERROR_USERNAME_MSG", nil);
            } else {
                errorLoginUsername.hidden = true;
            }
            
            if(!validatePassword) {
                errorLoginPassword.hidden = false;
                errorLoginPassword.text = NSLocalizedString(@"ALERT_REGISTRATION_ERROR_PASSWORD_MSG", nil);
            } else {
                errorLoginPassword.hidden = true;
            }
        }
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"RegistrationVU-RG_Login:%@",exception];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
        
        
    }
}
/*
 * Method name: syncSpecialtyFromPlatform
 * Description:this method will sync specialty from platform
 * Parameters: nil
 * return nil
 */
-(void)syncSpecialtyFromPlatform {
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
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        isForOption = false;
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
            
            requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                              :PLATFORM_HOST_URL :PLATFORM_GET_BOX_SPECIALTY_ACTION_URL
                              :HTTP_METHOD_POST
                              :requestData :nil];
            
        } else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
            NSURL *url;
            
            NSString *getString = [NSString stringWithFormat:@"?organization_id=%@",[NSNumber numberWithInteger:appDelegate.welvu_userModel.org_id]];
            NSLog(@"get string %@",getString);
            
            
            
            
            
            if(appDelegate.welvu_userModel.org_id > 0) {
                NSString *combineUrl = [NSString stringWithFormat:@"%@%@",PLATFORM_HOST_URL1, PLATFORM_GET_SPECIALTY_ACTION_URL];
                NSLog(@"url %@",combineUrl);
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",combineUrl, getString]];
                
            } else {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PLATFORM_HOST_URL1, PLATFORM_GET_SPECIALTY_ACTION_URL]];
                
            }
            
            NSLog(@"url %@",url);
            
            
            
            NSString *loginString = [NSString stringWithFormat:@"%@:%@", username, password];
            NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.welvu_userModel.access_token ];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
            
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
            
            [request setHTTPMethod:HTTP_METHOD_GET];
            
            getSpecialty =
            [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            [getSpecialty start];
        } else {
            
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
/*
 * Method name: specialtyOptions
 * Description: Get List of Specialty
 * Parameters: nil
 * return nil
 */
-(void) specialtyOptions {
    isForOption = true;
    HTTPRequestHandler *requestHandler = [[HTTPRequestHandler alloc] initWithRequestDetails
                                          :PLATFORM_HOST_URL:PLATFORM_GET_SPECIALTY_OPTIONS_URL:HTTP_METHOD_POST
                                          :nil :nil];
    requestHandler.delegate = self;
    // [requestHandler makeHTTPRequest];
}
#pragma mark  NSURLCONNECTION DELEGATE

/*
 * Method name: platformDidResponseReceived
 * Description: GET RESPONSE FROM PLATFORM
 * Parameters: success,actionAPI
 * return nil
 */
-(void) platformDidResponseReceived:(BOOL)success:(NSString *)actionAPI {
    // NSLog(@"Response received for get Specialty");
}
/*
 * Method name: platformDidReceivedData
 * Description:Get Respnse value from platform
 * Parameters: success,actionAPI,responseDictionary
 * return nil
 */
-(void)platformDidReceivedData:(BOOL)success :(NSDictionary *)responseDictionary:(NSString *)actionAPI {
    responseDictionaryy =responseDictionary;
    actionAPi = actionAPI;
    if(responseDictionaryy
       && ([actionAPI isEqualToString:PLATFORM_GET_ORGANIZATION_DETAIL_ACTION_URL])) {
        
        //appDelegate.fourPinAlert = FALSE;
        appDelegate.isOrgSubcribed = FALSE;
        BOOL inserted = false;
        NSLog(@"respdic %@",responseDictionary);
        
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
                inserted = [welvu_organization addOrganizationUser:[appDelegate getDBPath] :welvuOrganizationModel];
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
        
        
        if([responseDictionary count] == 0) {
            [self oraganizationCout];
            //[self.delegate welvuLoginCompletedWithAccessToken];
        } else {
            NSMutableArray * orgIds = nil;
            appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            // NSLog(@"welvu user id %d",appDelegate.welvu_userModel.welvu_user_id);
            
            
            
            
            organizationCount = [welvu_user getOrgUserCount:appDelegate.getDBPath :appDelegate.welvu_userModel.welvu_user_id];
            
            
            NSLog(@"organizationCount %d",organizationCount);
            
            
            
            if (organizationCount > 1) {
                //appDelegate.fourPinAlert = FALSE;
                
                orgCountPin = TRUE;
                [self oraganizationCout];
                /* welvuOrganizationViewController *welvuOrganization = [[welvuOrganizationViewController alloc]initWithNibName:@"welvuOrganizationViewController" bundle:nil];
                 welvuOrganization.modalPresentationStyle = UIModalPresentationFullScreen;
                 
                 welvuOrganization.delegate = self;
                 
                 [self presentModalViewController:welvuOrganization animated:NO];
                 
                 */
                
            } else if (organizationCount == 1){
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
                    //themeLogo.image = image;
                    orgIds = [welvu_user getAllOrgIdOfUser:[appDelegate getDBPath]
                                                    userId:appDelegate.welvu_userModel.user_primary_key];
                }
                
                if([orgIds count] > 0) {
                    welvu_OrganizationArray = [[NSMutableArray alloc] init];
                    for (NSNumber *orgId in orgIds) {
                        NSInteger orgIdInteger = [orgId integerValue];
                        [welvu_OrganizationArray addObject:[welvu_organization getOrganizationDetailsById
                                                            :[appDelegate getDBPath] orgId:orgIdInteger]];
                    }
                    
                    [self getOrganizatioDetails];
                    
                    //  NSLog(@"orgadetails %@",welvu_OrganizationArray);
                } else {
                    [self oraganizationCout];
                    
                }
                
                //[self.delegate welvuLoginCompletedWithAccessToken];
            } else  if([orgIds count] == 0) {
                [self oraganizationCout];
                
            }
            organizationCount = nil;
            
        }
    } else if(responseDictionary && ([actionAPI isEqualToString:PLATFORM_GET_SPECIALTY_ACTION_URL]
                                     || [actionAPI isEqualToString:PLATFORM_GET_BOX_SPECIALTY_ACTION_URL])) {
        
        NSLog(@"respdic %@",responseDictionary);
        
        //NSMutableArray *welvuSpecialtyModels = [[NSMutableArray alloc] initWithCapacity:[responseDictionary count]];
        OrgInsert = false;
        for(NSDictionary *welvuSpecialty in responseDictionary) {
            welvu_specialty *welvuSpecialtyModel = [[welvu_specialty alloc] init];
            welvuSpecialtyModel.welvu_platform_id = [[welvuSpecialty objectForKey:HTTP_RESPONSE_ID] integerValue];
            welvuSpecialtyModel.welvu_specialty_name = [welvuSpecialty objectForKey:HTTP_RESPONSE_NAME];
            
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"Specialty_%d",welvuSpecialtyModel.welvu_platform_id]];
            
            
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
                welvuSpecialtyModel.subscriptionStartDate = [dateFormatter dateFromString
                                                             :[welvuSpecialty objectForKey:HTTP_REQUEST_SUBSCRIPTION_START_DATE]];
                welvuSpecialtyModel.subscriptionEndDate = [dateFormatter dateFromString
                                                           :[welvuSpecialty objectForKey:HTTP_REQUEST_SUBSCRIPTION_END_DATE]];
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"Specialty_%d", welvuSpecialtyModel.welvu_platform_id]];
                [[NSUserDefaults standardUserDefaults] setValue:[welvuSpecialty
                                                                 objectForKey:HTTP_REQUEST_TRANSACTION_RECEIPT]
                                                         forKey:[NSString stringWithFormat:@"Specialty_Receipt_%d",welvuSpecialtyModel.welvu_platform_id]];
            }
            
            welvuSpecialtyModel.welvu_user_id = appDelegate.welvu_userModel.welvu_user_id;
            
            updateOnly = false;
            if([welvu_specialty getSpecialtyNameById:[appDelegate getDBPath]:welvuSpecialtyModel.welvu_platform_id
                                              userId:appDelegate.welvu_userModel.welvu_user_id]) {
                updateOnly = true;
            }
            orgUpdated = [welvu_specialty updateAllSpecialty:[appDelegate getDBPath] specialtyModel:welvuSpecialtyModel specialtyUpdate:updateOnly];
            if(!orgUpdated) {
                break;
            } else {
                OrgInsert = true;
            }
        }
        //BOOL insert = [welvu_specialty addAllSpecialty:[appDelegate getDBPath]:welvuSpecialtyModels];
        
        // NSLog(@"confirm user %d",confirmUser);
        // NSLog(@"updateOnly user %d",updateOnly);
        // NSLog(@"orgDetails user %d",orgDetails);
        // NSLog(@"OrgInsert user %d",OrgInsert);
        // NSLog(@"orgUpdated user %d",orgUpdated);
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        
        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OPENEMR] ) {
            [self.delegate welvuLoginCompletedWithAccessToken];
        }
        
        else {
            
            
            if(!confirmUser) {
                
                [self addOrganizationUserDetails];
                
                /* WSLAlertViewAutoDismiss* myAlert = [[WSLAlertViewAutoDismiss alloc]
                 initWithTitle:NSLocalizedString(@"ALERT_REGISTRATION_TITLE", nil)
                 message:NSLocalizedString(@"ALERT_REGISTRATION_SUCCESSFUL_MSG", nil)
                 delegate:self
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil];
                 myAlert.tag = 200;
                 [myAlert show];*/
                
            }  else if(confirmUser)
                [self addOrganizationUserDetails];
            
        }
        
        
        
        
        //[self.delegate welvuLoginCompletedWithAccessToken];
    } else if([actionAPI isEqualToString:PLATFORM_GET_SPECIALTY_OPTIONS_URL]) {
        specialtyTypes = [[NSMutableArray alloc] initWithCapacity:[responseDictionary count]];
        for(NSString *welvuSpecialty in responseDictionary) {
            welvu_specialty *welvuSpecialtyModel = [[welvu_specialty alloc] init];
            welvuSpecialtyModel.welvu_specialty_name = welvuSpecialty;
            
            [specialtyTypes addObject:welvuSpecialtyModel];
        }
        [specialtyPicker reloadAllComponents];
    }
    if([actionAPI isEqualToString:PLATFORM_GET_BOX_SPECIALTY_ACTION_URL]) {
        
        [self.delegate welvuLoginCompletedWithAccessToken];
        if(spinner != nil) {
            [spinner removeSpinner];
            spinner = nil;
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
    //   NSLog(@"Failed to get Specialty %@", error);
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
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



// NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge previousFailureCount] == 0) {
        /*NSLog(@"received authentication challenge");
         NSURLCredential *newCredential = [NSURLCredential credentialWithUser:MAIL_ID
         password:MAIL_PASSWORD
         persistence:NSURLCredentialPersistenceForSession];
         NSLog(@"credential created");
         [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];*/
        // NSLog(@"responded to authentication challenge");
    }
    else {
        // NSLog(@"previous authentication failure");
    }
}
/*
 * Method name: didReceiveResponse
 * Description:Did receive response from platform
 * Parameters: response
 * return nil */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"connection %@", connection);
    NSLog(@"response %@", response);
    
}
/*
 * Method name: didReceiveData
 * Description:Did receive data from platform
 * Parameters: data
 * return nil */


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    
    if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        if((connection ==  authorize)) {
            //SBJSON *parser = [[SBJSON alloc] init];
            
            NSError *error = nil;
            
            defaults = [NSUserDefaults standardUserDefaults];
            NSString* newStr = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            NSLog(@"newStr %@", newStr);
            if([defaults objectForKey:@"getAuthorize"]) {
                responseStr = [defaults objectForKey:@"getAuthorize"];
            } else {
                responseStr = [[NSString alloc] init];
            }
            responseStr = [responseStr stringByAppendingString:newStr];
            [defaults setObject:responseStr forKey:@"getAuthorize"];
            NSLog(@"defaults data %@",defaults);
            
            
        }else if (connection == getRegistration) {
            {
                if(data) {
                    NSError *error = nil;
                    // 1. get the top level value as a dictionary
                    NSString* newStr = [[NSString alloc] initWithData:data
                                                             encoding:NSUTF8StringEncoding];
                    NSLog(@"platform data %@",newStr);
                    
                    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:&error];
                    
                    NSLog(@"response dic %@",responseDictionary);
                    
                    if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame)
                       ) {
                        
                        
                        welvu_userModel = [welvu_user getUserByEmailId:appDelegate.getDBPath
                                                               emailId:[responseDictionary objectForKey:HTTP_EMAILID_KEY]];
                        NSInteger update = 0;
                        NSInteger insert = 0;
                        if(welvu_userModel) {
                            welvu_user *welvuUserModel = [[welvu_user alloc] initWithUserId:welvu_userModel.welvu_user_id];
                            welvuUserModel.firstname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                            welvuUserModel.middlename = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                            welvuUserModel.lastname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                            //welvuUserModel.username = [responseDictionary objectForKey:HTTP_REQUEST_USER_NAME];
                            welvuUserModel.email = [responseDictionary objectForKey:HTTP_EMAILID_KEY];
                            welvuUserModel.specialty = [responseDictionary objectForKey:HTTP_SPECIALTY_KEY];
                            welvuUserModel.access_token = [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                            appDelegate.oauth_accessToken  = [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                            welvuUserModel.access_token_obtained_on = [NSDate date];
                            
                            update = [welvu_user updateLoggedUserAccessToken:appDelegate.getDBPath :welvuUserModel];
                            
                            welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                            if([[responseDictionary objectForKey:HTTP_RESPONSE_IS_CONFIRMED] integerValue] == 0)
                            {
                                appDelegate.confirmRegisteredUser = FALSE;
                            } else {
                                appDelegate.confirmRegisteredUser = TRUE;
                                
                            }
                            
                        } else if([[responseDictionary objectForKey:HTTP_RESPONSE_IS_CONFIRMED] integerValue] > 0){
                            //Login directly without registration
                            welvu_user *welvuUserModel = [[welvu_user alloc] init];
                            welvuUserModel.firstname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                            welvuUserModel.middlename = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                            welvuUserModel.lastname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                            welvuUserModel.username = [responseDictionary objectForKey:HTTP_REQUEST_USER_NAME];
                            welvuUserModel.email = [responseDictionary objectForKey:HTTP_EMAILID_KEY];
                            welvuUserModel.specialty = [responseDictionary objectForKey:HTTP_SPECIALTY_KEY];
                            appDelegate.oauth_accessToken  = [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                            welvuUserModel.access_token = [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                            welvuUserModel.access_token_obtained_on = [NSDate date];
                            welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                            insert = [welvu_user addWelvuUserWithAccessToken:appDelegate.getDBPath :welvuUserModel];
                            confirmUser = true;
                            
                            
                        } else if([[responseDictionary objectForKey:HTTP_RESPONSE_IS_CONFIRMED] integerValue] == 0){
                            //Registration
                            welvu_user *welvuUserModel = [[welvu_user alloc] init];
                            welvuUserModel.firstname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                            welvuUserModel.middlename = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                            welvuUserModel.lastname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                            welvuUserModel.username = [responseDictionary objectForKey:HTTP_REQUEST_USER_NAME];
                            welvuUserModel.email = [responseDictionary objectForKey:HTTP_EMAILID_KEY];
                            welvuUserModel.specialty = [responseDictionary objectForKey:HTTP_SPECIALTY_KEY];
                            appDelegate.oauth_accessToken  = [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                            insert = [welvu_user addWelvuUser:appDelegate.getDBPath :welvuUserModel];
                            welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                            
                            // saving an NSString
                            [prefs setObject:[responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY] forKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                            confirmUser = false;
                        }
                        
                        //EMR
                        if(update > 0 || insert > 0) {
                            
                            UIAlertView* myAlert = [[UIAlertView alloc]
                                                    initWithTitle:NSLocalizedString(@"ALERT_REGISTRATION_TITLE", nil)
                                                    message:NSLocalizedString(@"ALERT_REGISTRATION_SUCCESSFUL_MSG", nil)
                                                    delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                    otherButtonTitles:nil];
                            myAlert.tag = 200;
                            [myAlert show];
                            // [self registerLoginContinue];
                            // [self syncSpecialtyFromPlatform];
                        }
                    } else if([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_FAILED_KEY]==NSOrderedSame) {
                        if(spinner != nil) {
                            [spinner removeSpinner];
                            spinner = nil;
                        }
                        NSString *msg = @"";
                        if(responseDictionary != nil &&
                           ![[responseDictionary objectForKey:HTTP_RESPONSE_MSG_KEY] isKindOfClass:[NSNull class]]
                           && ![[responseDictionary objectForKey:HTTP_RESPONSE_MSG_KEY] isEqualToString:@""]) {
                            msg = [responseDictionary objectForKey:HTTP_RESPONSE_MSG_KEY];
                        } else {
                            msg = NSLocalizedString(@"CONNECT_SERVER_ISSUE", nil);
                        }
                        
                        UIAlertView* alert = [[UIAlertView alloc]
                                              initWithTitle: NSLocalizedString(@"ALERT_SHAREVU_ERROR_TITLE",nil)
                                              message: msg
                                              delegate: self
                                              cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                              otherButtonTitles:nil];
                        [alert show];
                    }
                }
                
            }
            
        }else if(connection == getOrganization) {
            if(data) {
                
                
                
                NSError *error = nil;
                // NSJSONSerialization *parser = [[SBJSON alloc] init];
                // 1. get the top level value as a dictionary
                NSString* newStr = [[NSString alloc] initWithData:data
                                                         encoding:NSUTF8StringEncoding];
                NSLog(@"platform data %@",newStr);
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:&error];
                NSLog(@"response dic %@",responseDictionary);
                
                
                getOrgResponseDictionary =responseDictionary;
                
                
                
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
                        inserted = [welvu_organization addOrganizationUser:[appDelegate getDBPath] :welvuOrganizationModel];
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
                
                NSLog(@"res count %d", [getOrganization count]);
                if([getOrganization count] == 0) {
                    [self oraganizationCout];
                    //[self.delegate welvuLoginCompletedWithAccessToken];
                } else {
                    NSMutableArray * orgIds = nil;
                    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                    // NSLog(@"welvu user id %d",appDelegate.welvu_userModel.welvu_user_id);
                    
                    
                    
                    
                    organizationCount = [welvu_user getOrgUserCount:appDelegate.getDBPath :appDelegate.welvu_userModel.welvu_user_id];
                    
                    
                    NSLog(@"organizationCount %d",organizationCount);
                    
                    
                    
                    if (organizationCount > 1) {
                        //appDelegate.fourPinAlert = FALSE;
                        
                        
                        [self oraganizationCout];
                        /* welvuOrganizationViewController *welvuOrganization = [[welvuOrganizationViewController alloc]initWithNibName:@"welvuOrganizationViewController" bundle:nil];
                         welvuOrganization.modalPresentationStyle = UIModalPresentationFullScreen;
                         
                         welvuOrganization.delegate = self;
                         
                         [self presentModalViewController:welvuOrganization animated:NO];
                         
                         */
                        
                    } else if (organizationCount == 1){
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
                            //themeLogo.image = image;
                            orgIds = [welvu_user getAllOrgIdOfUser:[appDelegate getDBPath]
                                                            userId:appDelegate.welvu_userModel.user_primary_key];
                        }
                        
                        if([orgIds count] > 0) {
                            welvu_OrganizationArray = [[NSMutableArray alloc] init];
                            for (NSNumber *orgId in orgIds) {
                                NSInteger orgIdInteger = [orgId integerValue];
                                [welvu_OrganizationArray addObject:[welvu_organization getOrganizationDetailsById
                                                                    :[appDelegate getDBPath] orgId:orgIdInteger]];
                            }
                            
                            [self getOrganizatioDetails];
                            
                            //  NSLog(@"orgadetails %@",welvu_OrganizationArray);
                        } else {
                            [self oraganizationCout];
                            
                        }
                        
                        //[self.delegate welvuLoginCompletedWithAccessToken];
                    } else  if([orgIds count] == 0) {
                        [self oraganizationCout];
                        
                    }
                    organizationCount = nil;
                    
                }
                
                //[self.delegate welvuLoginCompletedWithAccessToken];
            }
        }else if(connection == getSpecialty) {
            if(data) {
                NSError *error = nil;
                //SBJSON *parser = [[SBJSON alloc] init];
                // 1. get the top level value as a dictionary
                NSString* newStr = [[NSString alloc] initWithData:data
                                                         encoding:NSUTF8StringEncoding];
                NSLog(@"getSpecialty data %@",newStr);
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:&error];                NSLog(@"getSpecialty dic %@",responseDictionary);
                
                NSDictionary *getSpecialties = [responseDictionary objectForKey:@"specialties"];
                
                OrgInsert = false;
                for(NSDictionary *welvuSpecialty in getSpecialties) {
                    welvu_specialty *welvuSpecialtyModel = [[welvu_specialty alloc] init];
                    welvuSpecialtyModel.welvu_platform_id = [[welvuSpecialty objectForKey:HTTP_RESPONSE_ID] integerValue];
                    welvuSpecialtyModel.welvu_specialty_name = [welvuSpecialty objectForKey:HTTP_RESPONSE_NAME];
                    
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"Specialty_%d",welvuSpecialtyModel.welvu_platform_id]];
                    
                    
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
                        welvuSpecialtyModel.subscriptionStartDate = [dateFormatter dateFromString
                                                                     :[welvuSpecialty objectForKey:HTTP_REQUEST_SUBSCRIPTION_START_DATE]];
                        welvuSpecialtyModel.subscriptionEndDate = [dateFormatter dateFromString
                                                                   :[welvuSpecialty objectForKey:HTTP_REQUEST_SUBSCRIPTION_END_DATE]];
                        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"Specialty_%d", welvuSpecialtyModel.welvu_platform_id]];
                        [[NSUserDefaults standardUserDefaults] setValue:[welvuSpecialty
                                                                         objectForKey:HTTP_REQUEST_TRANSACTION_RECEIPT]
                                                                 forKey:[NSString stringWithFormat:@"Specialty_Receipt_%d",welvuSpecialtyModel.welvu_platform_id]];
                    }
                    
                    welvuSpecialtyModel.welvu_user_id = appDelegate.welvu_userModel.welvu_user_id;
                    
                    updateOnly = false;
                    if([welvu_specialty getSpecialtyNameById:[appDelegate getDBPath]:welvuSpecialtyModel.welvu_platform_id
                                                      userId:appDelegate.welvu_userModel.welvu_user_id]) {
                        updateOnly = true;
                    }
                    orgUpdated = [welvu_specialty updateAllSpecialty:[appDelegate getDBPath] specialtyModel:welvuSpecialtyModel specialtyUpdate:updateOnly];
                    if(!orgUpdated) {
                        break;
                    } else {
                        OrgInsert = true;
                    }
                }
                //BOOL insert = [welvu_specialty addAllSpecialty:[appDelegate getDBPath]:welvuSpecialtyModels];
                
                // NSLog(@"confirm user %d",confirmUser);
                // NSLog(@"updateOnly user %d",updateOnly);
                // NSLog(@"orgDetails user %d",orgDetails);
                // NSLog(@"OrgInsert user %d",OrgInsert);
                // NSLog(@"orgUpdated user %d",orgUpdated);
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
                
                if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OPENEMR] ) {
                    [self.delegate welvuLoginCompletedWithAccessToken];
                }
                
                else {
                    
                    
                    if(!confirmUser) {
                        [self.delegate welvuLoginCompletedWithAccessToken];
                        // [self getConfiguration];
                        // [self.delegate welvuLoginCompletedWithAccessToken];
                        
                        // [self addOrganizationUserDetails];
                        
                        /*  WSLAlertViewAutoDismiss* myAlert = [[WSLAlertViewAutoDismiss alloc]
                         initWithTitle:NSLocalizedString(@"ALERT_REGISTRATION_TITLE", nil)
                         message:NSLocalizedString(@"ALERT_REGISTRATION_SUCCESSFUL_MSG", nil)
                         delegate:self
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil];
                         myAlert.tag = 200;
                         [myAlert show]; */
                        
                    }  else if(confirmUser)
                        [self.delegate welvuLoginCompletedWithAccessToken];
                    
                    
                }
                
                
            }
            
        }else if(connection == loginConnection) {
            if(data) {
                NSError *error = nil;
                //SBJSON *parser = [[SBJSON alloc] init];
                // 1. get the top level value as a dictionary
                NSString* newStr = [[NSString alloc] initWithData:data
                                                         encoding:NSUTF8StringEncoding];
                NSLog(@"platform data %@",newStr);
                 NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:&error];
                NSLog(@"response dic %@",responseDictionary);
                /* welvu_oauthModel = [welvu_oauth getUserByEmailId:appDelegate.getDBPath
                 emailId:[responseDictionary objectForKey:HTTP_EMAILID_KEY]];*/
                
                if([responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY])  {
                    
                    NSString *msg = @"";
                    if(responseDictionary != nil &&
                       ![[responseDictionary objectForKey:HTTP_RESPONSE_MSG_KEY] isKindOfClass:[NSNull class]]
                       && ![[responseDictionary objectForKey:HTTP_RESPONSE_MSG_KEY] isEqualToString:@""]) {
                        msg = [responseDictionary objectForKey:@"detail"];
                    } else {
                        msg = NSLocalizedString(@"CONNECT_SERVER_ISSUE", nil);
                    }
                    
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle: NSLocalizedString(@"ALERT_SHAREVU_ERROR_TITLE",nil)
                                          message: msg
                                          delegate: self
                                          cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                          otherButtonTitles:nil];
                    [alert show];
                }
                
                else {
                    NSInteger update = 0;
                    NSInteger insert = 0;
                    
                    welvu_oauthModel = [[welvu_oauth alloc]initWithUserId:appDelegate.welvu_userModel.welvu_user_id];
                    
                    appDelegate.oauth_accessToken  = [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                    welvu_oauthModel.access_token = [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                    
                    
                    
                    appDelegate.oauth_refreshToken = [responseDictionary objectForKey:COLUMN_REFRESH_TOKEN];
                    welvu_oauthModel.scope = [responseDictionary objectForKey:COLUMN_SCOPE];
                    welvu_oauthModel.token_type = [responseDictionary objectForKey:COLUMN_TOKEN_TYPE];
                    
                    welvu_oauthModel.refresh_token = [responseDictionary objectForKey:COLUMN_REFRESH_TOKEN];
                    
                    welvu_oauthModel.email_id =  loginUserName.text;
                    
                    //newly added for refresh token
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
                    welvu_oauthModel.expires_in = [dateFormatters stringFromDate:today];
                    
                    //current date
                    
                    
                    //ended
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                    [dateFormatter setTimeZone:gmt];
                    [dateFormatter setDateFormat:YEAR_MONTH_DATE_TIME_FORMAT_DB];
                    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
                    NSLog(@"gmt date %@" ,timeStamp);
                    
                    welvu_oauthModel.current_date = timeStamp;
                    welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                    
                    
                    
                    insert = [welvu_oauth addWelvuOauthUser:[appDelegate getDBPath] :welvu_oauthModel];
                    NSLog(@"gmt date %@" ,timeStamp);
                    
                    if([[responseDictionary objectForKey:HTTP_RESPONSE_IS_CONFIRMED] integerValue] == 0)
                    {
                        appDelegate.confirmRegisteredUser = FALSE;
                        
                        
                    } else {
                        appDelegate.confirmRegisteredUser = TRUE;
                    }
                    
                    if(update > 0 || insert > 0) {
                        
                        [self getConfiguration];
                        //[self syncSpecialtyFromPlatform];
                    }
                }
                
            }
        }
    }else  if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        if(data) {
            NSError *error = nil;
           // SBJSON *parser = [[SBJSON alloc] init];
            // 1. get the top level value as a dictionary
            NSString* newStr = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            // NSLog(@"platform data %@",newStr);
             NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:&error];
            
            if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame)
               && [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY]) {
                welvu_userModel = [welvu_user getUserByEmailId:appDelegate.getDBPath
                                                       emailId:[responseDictionary objectForKey:HTTP_EMAILID_KEY]];
                NSInteger update = 0;
                NSInteger insert = 0;
                if(welvu_userModel) {
                    welvu_user *welvuUserModel = [[welvu_user alloc] initWithUserId:welvu_userModel.welvu_user_id];
                    welvuUserModel.firstname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.middlename = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.lastname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    //welvuUserModel.username = [responseDictionary objectForKey:HTTP_REQUEST_USER_NAME];
                    welvuUserModel.email = [responseDictionary objectForKey:HTTP_EMAILID_KEY];
                    welvuUserModel.specialty = [responseDictionary objectForKey:HTTP_SPECIALTY_KEY];
                    welvuUserModel.access_token = [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                    welvuUserModel.box_access_token = [responseDictionary objectForKey:HTTP_RESPONSE_BOX_ACCESSTOKEN_KEY];
                    
                    welvuUserModel.box_refresh_access_token = [responseDictionary objectForKey:HTTP_RESPONSE_BOX_REFRESH_ACCESSTOKEN_KEY];
                    
                    welvuUserModel.box_expires_in = [responseDictionary objectForKey:HTTP_RESPONSE_BOX_EXPIRES_IN];
                    welvuUserModel.access_token_obtained_on = [NSDate date];
                    
                    update = [welvu_user updateLoggedUserAccessToken:appDelegate.getDBPath :welvuUserModel];
                    
                    welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                } else if([[responseDictionary objectForKey:HTTP_RESPONSE_IS_CONFIRMED] integerValue] > 0){
                    //Login directly without registration
                    welvu_user *welvuUserModel = [[welvu_user alloc] init];
                    welvuUserModel.firstname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.middlename = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.lastname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.username = [responseDictionary objectForKey:HTTP_REQUEST_USER_NAME];
                    welvuUserModel.email = [responseDictionary objectForKey:HTTP_EMAILID_KEY];
                    welvuUserModel.specialty = [responseDictionary objectForKey:HTTP_SPECIALTY_KEY];
                    
                    welvuUserModel.access_token = [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                    welvuUserModel.box_access_token = [responseDictionary objectForKey:HTTP_RESPONSE_BOX_ACCESSTOKEN_KEY];
                    
                    welvuUserModel.box_refresh_access_token = [responseDictionary objectForKey:HTTP_RESPONSE_BOX_REFRESH_ACCESSTOKEN_KEY];
                    
                    welvuUserModel.box_expires_in = [responseDictionary objectForKey:HTTP_RESPONSE_BOX_EXPIRES_IN];
                    welvuUserModel.access_token_obtained_on = [NSDate date];
                    welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                    insert = [welvu_user addWelvuUserWithAccessToken:appDelegate.getDBPath :welvuUserModel];
                    
                }
                if(update > 0 || insert > 0) {
                    [self syncSpecialtyFromPlatform];
                }
            } else if([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_FAILED_KEY]==NSOrderedSame) {
                if(spinner != nil) {
                    [spinner removeSpinner];
                    spinner = nil;
                }
                NSString *msg = @"";
                if(responseDictionary != nil &&
                   ![[responseDictionary objectForKey:HTTP_RESPONSE_MSG_KEY] isKindOfClass:[NSNull class]]
                   && ![[responseDictionary objectForKey:HTTP_RESPONSE_MSG_KEY] isEqualToString:@""]) {
                    msg = [responseDictionary objectForKey:HTTP_RESPONSE_MSG_KEY];
                } else {
                    msg = NSLocalizedString(@"CONNECT_SERVER_ISSUE", nil);
                }
                
                UIAlertView* alert = [[UIAlertView alloc]
                                      initWithTitle: NSLocalizedString(@"ALERT_SHAREVU_ERROR_TITLE",nil)
                                      message: msg
                                      delegate: self
                                      cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    } else if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_HEV]) {
        if(data) {
            NSError *error = nil;
            //SBJSON *parser = [[SBJSON alloc] init];
            // 1. get the top level value as a dictionary
            NSString* newStr = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            NSLog(@"platform data %@",newStr);
            
             NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:&error];
            
            NSLog(@"response dic %@",responseDictionary);
            
            if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame)
               && [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY]) {
                
                
                welvu_userModel = [welvu_user getUserByEmailId:appDelegate.getDBPath
                                                       emailId:[responseDictionary objectForKey:HTTP_EMAILID_KEY]];
                NSInteger update = 0;
                NSInteger insert = 0;
                if(welvu_userModel) {
                    welvu_user *welvuUserModel = [[welvu_user alloc] initWithUserId:welvu_userModel.welvu_user_id];
                    welvuUserModel.firstname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.middlename = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.lastname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    //welvuUserModel.username = [responseDictionary objectForKey:HTTP_REQUEST_USER_NAME];
                    welvuUserModel.email = [responseDictionary objectForKey:HTTP_EMAILID_KEY];
                    welvuUserModel.specialty = [responseDictionary objectForKey:HTTP_SPECIALTY_KEY];
                    welvuUserModel.access_token = [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                    welvuUserModel.access_token_obtained_on = [NSDate date];
                    
                    update = [welvu_user updateLoggedUserAccessToken:appDelegate.getDBPath :welvuUserModel];
                    
                    welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                    if([[responseDictionary objectForKey:HTTP_RESPONSE_IS_CONFIRMED] integerValue] == 0)
                    {
                        confirmUser = false;
                        
                    } else {
                        confirmUser = true;
                    }
                    
                } else if([[responseDictionary objectForKey:HTTP_RESPONSE_IS_CONFIRMED] integerValue] > 0){
                    //Login directly without registration
                    welvu_user *welvuUserModel = [[welvu_user alloc] init];
                    welvuUserModel.firstname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.middlename = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.lastname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.username = [responseDictionary objectForKey:HTTP_REQUEST_USER_NAME];
                    welvuUserModel.email = [responseDictionary objectForKey:HTTP_EMAILID_KEY];
                    welvuUserModel.specialty = [responseDictionary objectForKey:HTTP_SPECIALTY_KEY];
                    
                    welvuUserModel.access_token = [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                    welvuUserModel.access_token_obtained_on = [NSDate date];
                    welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                    insert = [welvu_user addWelvuUserWithAccessToken:appDelegate.getDBPath :welvuUserModel];
                    confirmUser = true;
                    
                    
                } else if([[responseDictionary objectForKey:HTTP_RESPONSE_IS_CONFIRMED] integerValue] == 0){
                    //Registration
                    welvu_user *welvuUserModel = [[welvu_user alloc] init];
                    welvuUserModel.firstname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.middlename = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.lastname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.username = [responseDictionary objectForKey:HTTP_REQUEST_USER_NAME];
                    welvuUserModel.email = [responseDictionary objectForKey:HTTP_EMAILID_KEY];
                    welvuUserModel.specialty = [responseDictionary objectForKey:HTTP_SPECIALTY_KEY];
                    insert = [welvu_user addWelvuUser:appDelegate.getDBPath :welvuUserModel];
                    welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    
                    // saving an NSString
                    [prefs setObject:[responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY] forKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                    confirmUser = false;
                }
                
                //EMR
                if(update > 0 || insert > 0) {
                    [self syncSpecialtyFromPlatform];
                }
            } else if([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_FAILED_KEY]==NSOrderedSame) {
                if(spinner != nil) {
                    [spinner removeSpinner];
                    spinner = nil;
                }
                NSString *msg = @"";
                if(responseDictionary != nil &&
                   ![[responseDictionary objectForKey:HTTP_RESPONSE_MSG_KEY] isKindOfClass:[NSNull class]]
                   && ![[responseDictionary objectForKey:HTTP_RESPONSE_MSG_KEY] isEqualToString:@""]) {
                    msg = [responseDictionary objectForKey:HTTP_RESPONSE_MSG_KEY];
                } else {
                    msg = NSLocalizedString(@"CONNECT_SERVER_ISSUE", nil);
                }
                
                UIAlertView* alert = [[UIAlertView alloc]
                                      initWithTitle: NSLocalizedString(@"ALERT_SHAREVU_ERROR_TITLE",nil)
                                      message: msg
                                      delegate: self
                                      cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    } else if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OPENEMR]) {
        
        if(data) {
            NSError *error= nil;
            //SBJSON *parser = [[SBJSON alloc] init];
            // 1. get the top level value as a dictionary
            NSString* newStr = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:&error];
            //NeedToCheck
            if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY]
                 caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame)
               && ![responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY]) {
                if(spinner != nil) {
                    [spinner removeSpinner];
                    spinner = nil;
                }
                
                welvu_user *welvuUserModel = [[welvu_user alloc] init];
                welvuUserModel.firstname = registration.name;
                welvuUserModel.middlename = registration.name;
                welvuUserModel.lastname = registration.name;
                welvuUserModel.username = registration.username;
                welvuUserModel.email = registration.email;
                welvuUserModel.specialty = ((welvu_specialty *) [specialtyTypes objectAtIndex:
                                                                 [specialtyPicker selectedRowInComponent:0]]).welvu_specialty_name;
                int insert = [welvu_user addWelvuUser:appDelegate.getDBPath :welvuUserModel];
                if(insert > 0) {
                    registrationView.hidden = true;
                    [self resetRegistrationTextField];
                    UIAlertView* myAlert = [[UIAlertView alloc]
                                            initWithTitle:NSLocalizedString(@"ALERT_REGISTRATION_TITLE", nil)
                                            message:NSLocalizedString(@"ALERT_REGISTRATION_SUCCESSFUL_MSG", nil)
                                            delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                            otherButtonTitles:nil];
                    [myAlert show];
                    welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                }
                
            } else if(([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY]
                        caseInsensitiveCompare:HTTP_RESPONSE_SUCCESS_KEY]==NSOrderedSame)
                      && [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY]) {
                
                
                
                NSString *myOpenEmr=[responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                //  NSLog(@"oemrtoken %@",myOpenEmr);
                
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                
                // saving an NSString
                [prefs setObject:myOpenEmr forKey:@"keyToLookupString"];
                
                
                welvu_userModel = [welvu_user getUserByAccessToken:appDelegate.getDBPath
                                                             token:[responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY]];
                NSInteger update = 0;
                NSInteger insert = 0;
                if(welvu_userModel) {
                    welvu_user *welvuUserModel = [[welvu_user alloc] initWithUserId:welvu_userModel.welvu_user_id];
                    welvuUserModel.firstname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.middlename = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.lastname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.username = [responseDictionary objectForKey:HTTP_REQUEST_USER_NAME];
                    welvuUserModel.email = [responseDictionary objectForKey:HTTP_EMAILID_KEY];
                    welvuUserModel.specialty = [responseDictionary objectForKey:HTTP_SPECIALTY_KEY];
                    welvuUserModel.access_token = [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                    welvuUserModel.access_token_obtained_on = [NSDate date];
                    update = [welvu_user updateLoggedUserAccessToken:appDelegate.getDBPath :welvuUserModel];
                    welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                } else {
                    welvu_user *welvuUserModel = [[welvu_user alloc] init];
                    welvuUserModel.firstname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.middlename = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.lastname = [responseDictionary objectForKey:HTTP_REQUEST_NAME];
                    welvuUserModel.username = [responseDictionary objectForKey:HTTP_REQUEST_USER_NAME];
                    welvuUserModel.email = [responseDictionary objectForKey:HTTP_EMAILID_KEY];
                    welvuUserModel.specialty = [responseDictionary objectForKey:HTTP_SPECIALTY_KEY];
                    welvuUserModel.access_token = [responseDictionary objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
                    welvuUserModel.access_token_obtained_on = [NSDate date];
                    insert = [welvu_user addWelvuUserWithAccessToken:appDelegate.getDBPath :welvuUserModel];
                    welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                }
                if(update > 0 || insert > 0) {
                    [self syncSpecialtyFromPlatform];
                }
                
            } else if([[responseDictionary objectForKey:HTTP_RESPONSE_STATUS_KEY] caseInsensitiveCompare:HTTP_RESPONSE_FAILED_KEY]==NSOrderedSame) {
                if(spinner != nil) {
                    [spinner removeSpinner];
                    spinner = nil;
                }
                NSString *msg = @"";
                if(responseDictionary != nil &&
                   ![[responseDictionary objectForKey:HTTP_RESPONSE_MSG_KEY] isKindOfClass:[NSNull class]]
                   && ![[responseDictionary objectForKey:HTTP_RESPONSE_MSG_KEY] isEqualToString:@""]) {
                    msg = [responseDictionary objectForKey:HTTP_RESPONSE_MSG_KEY];
                } else {
                    msg = NSLocalizedString(@"CONNECT_SERVER_ISSUE", nil);
                }
                
                UIAlertView* alert = [[UIAlertView alloc]
                                      initWithTitle: NSLocalizedString(@"ALERT_SHAREVU_ERROR_TITLE",nil)
                                      message: msg
                                      delegate: self
                                      cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                      otherButtonTitles:nil];
                [alert show];
            }
            
        }
        
    }
}


/*
 * Method name: connectionDidFinishLoading
 * Description:when connection finish loading ,spinner will remove from the view.
 * Parameters: connection
 * return nil
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    NSLog(@"connection %@", connection);
    if ( [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        if( connection == authorize) {
            [welvu_configuration deleteCacheData:[appDelegate getDBPath]];
            //SBJSON *parser = [[SBJSON alloc] init];
            NSError *error = nil;
            if([defaults objectForKey:@"getAuthorize"]) {
                responseStr = [defaults objectForKey:@"getAuthorize"];
            }
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers  error:&error];
            
            
            NSDictionary *getConfig1 = [responseDictionary objectForKey:@"user"];
            NSLog(@"user %@",getConfig1);
            NSLog(@"user id %d",appDelegate.welvu_userModel.welvu_user_id);
            
            NSInteger update = 0;
            NSInteger insert = 0;
            
            
            
            NSString *emailId = loginUserName.text;
            welvu_userModel = [welvu_user getUserByEmailId:appDelegate.getDBPath
                                                   emailId:loginUserName.text];
            welvu_oauthModel = [welvu_oauth getOauthDetailsByEmailId:[appDelegate getDBPath] emailId:loginUserName.text];
            
            if(welvu_userModel) {
                welvu_user *welvuUserModel = [[welvu_user alloc] initWithUserId:welvu_userModel.welvu_user_id];
                welvuUserModel.firstname = [getConfig1 objectForKey:HTTP_REQUEST_NAME];
                welvuUserModel.middlename = [getConfig1 objectForKey:HTTP_REQUEST_NAME];
                welvuUserModel.lastname = [getConfig1 objectForKey:HTTP_REQUEST_NAME];
                welvuUserModel.username = [getConfig1 objectForKey:HTTP_REQUEST_USER_NAME];
                welvuUserModel.email = [getConfig1 objectForKey:HTTP_EMAILID_KEY];
                welvuUserModel.specialty = [getConfig1 objectForKey:HTTP_SPECIALTY_KEY];
                welvuUserModel.access_token = welvu_oauthModel.access_token;
                welvuUserModel.access_token_obtained_on = [NSDate date];
                welvuUserModel.oauth_refresh_token = welvu_oauthModel.refresh_token;
                welvuUserModel.oauth_scope = welvu_oauthModel.scope;
                welvuUserModel.oauth_expires_in = welvu_oauthModel.expires_in;
                welvuUserModel.oauth_currentDate = welvu_oauthModel.current_date;
                welvuUserModel.oauth_token_type = welvu_oauthModel.token_type;
                
                
                update = [welvu_user updateLoggedUserAccessToken:appDelegate.getDBPath :welvuUserModel];
                update = [welvu_user updateLoggedorgUserAccessToken:appDelegate.getDBPath :welvuUserModel];
                welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
                
            } else {
                welvu_user *welvuUserModel = [[welvu_user alloc] init];
                welvuUserModel.firstname = [getConfig1 objectForKey:HTTP_REQUEST_NAME];
                NSLog(@"welvuUserModel.firstname %@",welvuUserModel.firstname);
                welvuUserModel.middlename = [getConfig1 objectForKey:HTTP_REQUEST_NAME];
                welvuUserModel.lastname = [getConfig1 objectForKey:HTTP_REQUEST_NAME];
                welvuUserModel.username = [getConfig1 objectForKey:HTTP_REQUEST_USER_NAME];
                welvuUserModel.email = [getConfig1 objectForKey:HTTP_EMAILID_KEY];
                welvuUserModel.specialty = [getConfig1 objectForKey:HTTP_SPECIALTY_KEY];
                welvuUserModel.access_token = welvu_oauthModel.access_token;
                welvuUserModel.access_token_obtained_on = [NSDate date];
                welvuUserModel.oauth_refresh_token = welvu_oauthModel.refresh_token;
                welvuUserModel.oauth_scope = welvu_oauthModel.scope;
                welvuUserModel.oauth_expires_in = welvu_oauthModel.expires_in;
                welvuUserModel.oauth_currentDate = welvu_oauthModel.current_date;
                welvuUserModel.oauth_token_type = welvu_oauthModel.token_type;
                
                
                insert = [welvu_user addWelvuUserWithAccessToken:appDelegate.getDBPath :welvuUserModel];
                welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
            }
            
            
            BOOL deleteoauthValues = [welvu_oauth deleteoauthValueFromDB:[appDelegate getDBPath] :loginUserName.text];
            
            NSLog(@"update %d",update);
            NSLog(@"insert %d",insert);
            NSLog(@"welvu_userModel %@",welvu_userModel.firstname);
            
            
            
            
            NSDictionary *getOrgConfig = [responseDictionary objectForKey:@"organizations"];
            NSLog(@"organizations %d",[getOrgConfig count]);
            
            
            
            
            for(NSDictionary *welvuOrgs in getOrgConfig) {
                NSLog(@"welvuOrgs %@",welvuOrgs);
                
                //oauth org db
                
                appDelegate.isOrgSubcribed = FALSE;
                BOOL inserted = false;
                NSLog(@"respdic %@",responseDictionary);
                
                
                
                welvu_organization *welvuOrganizationModel = [[welvu_organization alloc] init];
                
                welvuOrganizationModel.orgId= [[welvuOrgs objectForKey:HTTP_RESPONSE_ID] integerValue];
                welvuOrganizationModel.orgName= [welvuOrgs objectForKey:HTTP_RESPONSE_NAME];
                welvuOrganizationModel.org_Status = [welvuOrgs objectForKey:COLUMN_STATUS];
                
                NSURL *url =[welvuOrgs objectForKey:@"logourl"];
                
                welvuOrganizationModel.orgLogoName = [welvuOrgs objectForKey:@"logo"];
                
                NSString* outputPath = [NSString stringWithFormat:@"%@/%@",
                                        DOCUMENT_DIRECTORY, [welvuOrgs objectForKey:@"logo"]];
                NSData *thedata = [NSData dataWithContentsOfURL:[NSURL URLWithString:[welvuOrgs objectForKey:@"logourl"]]];
                welvuOrganizationModel.product_Type = [welvuOrgs objectForKey:@"product_type"];
                [thedata writeToFile:outputPath atomically:YES];
                
                
                //key values
                
                welvu_configuration *welvu_configurationModel = [[welvu_configuration alloc] init];
                NSDictionary *config = [welvuOrgs objectForKey:@"config"];
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
                    
                }                        config = nil;
                
                //end key values
                
                
                if([welvu_organization getOrganizationDetailsById:[appDelegate getDBPath]
                                                            orgId:welvuOrganizationModel.orgId] == nil) {
                    inserted = [welvu_organization addOrganizationUser:[appDelegate getDBPath] :welvuOrganizationModel];
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
                    
                    welvu_userMod.oauth_refresh_token = welvu_oauthModel.refresh_token;
                    welvu_userMod.oauth_scope = welvu_oauthModel.scope;
                    welvu_userMod.oauth_expires_in = welvu_oauthModel.expires_in;
                    welvu_userMod.oauth_currentDate = welvu_oauthModel.current_date;
                    welvu_userMod.oauth_token_type = welvu_oauthModel.token_type;
                    
                    
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
            
            [self oraganizationCout];
            
        }
    }
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
    
}
/*
 * Method name: connection
 * Description:if connection fails while loading
 * Parameters: error
 * return nil
 */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //  NSLog(@" Content %@",error);
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
}
#pragma mark UIPickerViewContrller Delegate
/*
 * Method name: numberOfComponentsInPickerView
 * Description:It shows number of companent in the picker view
 * Parameters: pickerView
 * return: NSInteger
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
/*
 * Method name: pickerView
 * Description:have to select the specialty in the picker view
 * Parameters: row,companent
 * return: NSString
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    registration.specialtyType = ((welvu_specialty *) [specialtyTypes objectAtIndex:row]).welvu_specialty_name;
    specialty.text = ((welvu_specialty *) [specialtyTypes objectAtIndex:row]).welvu_specialty_name;
}
/*
 * Method name: pickerView
 * Description:show the number of component in the picker view
 * Parameters: row,companent
 * return: NSInteger
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [specialtyTypes count];
}
/*
 * Method name: pickerView
 * Description:show the title in the row
 * Parameters: row,companent
 * return: NSString
 */
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return ((welvu_specialty *) [specialtyTypes objectAtIndex:row]).welvu_specialty_name;
}
-(IBAction)showPicker:(id)sender {
    [name resignFirstResponder];
    //[username resignFirstResponder];
    [email resignFirstResponder];
    [password resignFirstResponder];
    [confirmPassword resignFirstResponder];
    [loginUserName resignFirstResponder];
    [loginPassword resignFirstResponder];
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
        [self specialtyOptions];
        [UIView animateWithDuration:0.3 animations:^{
            specialtyPicker.frame = CGRectMake(specialtyPicker.frame.origin.x, 17,
                                               specialtyPicker.frame.size.width, specialtyPicker.frame.size.width);
        }];
        
    }
    
}
-(IBAction)closePicker:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        specialtyPicker.frame = CGRectMake(specialtyPicker.frame.origin.x, 1000,
                                           specialtyPicker.frame.size.width, specialtyPicker.frame.size.width);
    }];
    
}


/*
 * Method name: touchesBegan
 * Description:when touches begin in the view the view will move upwards ,and keypad will dismisss
 * Parameters: event
 * return: nil
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [name resignFirstResponder];
    //[username resignFirstResponder];
    [email resignFirstResponder];
    [password resignFirstResponder];
    [organization resignFirstResponder];
    [phoneNumber resignFirstResponder];
    [confirmPassword resignFirstResponder];
    [loginUserName resignFirstResponder];
    [loginPassword resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        specialtyPicker.frame = CGRectMake(specialtyPicker.frame.origin.x, 1000,
                                           specialtyPicker.frame.size.width, specialtyPicker.frame.size.width);
    }];
    
}

BOOL isTextFieldMoved = false;
float textFieldMovedDistance;

#pragma mark UITextField Delegate Methods




- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField.text isEqualToString:phoneNumber.text]) {
        if (textField.text.length >= 15 && range.length == 0)
        {
            return NO; // return NO to not change text
        }
        else {
            return YES;
        }
    } else {
        return  YES;
    }
}




/*
 * Method name: validateTextField
 * Description:To Validate the given text field §
 * Parameters: textField,allowedLength
 * return: BOOL
 */
-(BOOL)validateTextField:(NSString *)textField:(NSInteger) allowedLength {
    BOOL textFieldValid = false;
    textField = [textField stringByTrimmingCharactersInSet:
                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([textField length] > 0) {
        textFieldValid = true;
    }
    return textFieldValid;
}


-(BOOL)validatePasswordTextField:(NSString *)textField:(NSInteger) allowedLength {
    BOOL textFieldValid = false;
    textField = [textField stringByTrimmingCharactersInSet:
                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([textField length] >= 8 && [textField length] <= 16 ) {
        
        textFieldValid = true;
    }
    return textFieldValid;
}





-(BOOL)validatePhoneNumber: (NSString *) number{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789*#"] invertedSet];
    NSString *filtered = [[number componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [number isEqualToString:filtered];
    
}


/*
 * Method name: validateConfirmTextField
 * Description:To confirm and validate the given text field
 * Parameters: textField,compareTextField,allowedLength
 * return: BOOL
 */
-(BOOL)validateConfirmTextField:(NSString *)textField
                               :(NSString *)compareTextField:(NSInteger) allowedLength {
    BOOL textFieldValid = false;
    textField = [textField stringByTrimmingCharactersInSet:
                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([textField length] >= 8 &&  [textField length] <= 16 && [textField isEqualToString:compareTextField]) {
        textFieldValid = true;
    }
    return textFieldValid;
}
/*
 * Method name: validateEmail
 * Description:To validate the email id text field
 * Parameters: candidate
 * return: BOOL
 */
- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}


-(void)userLoggedOutFromOrganizationViewController {
    
    [self dismissModalViewControllerAnimated:YES];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    if (textField == loginUserName) {
        [textField resignFirstResponder];
        [loginPassword becomeFirstResponder];
    }
    else if (textField == loginPassword) {
        [textField resignFirstResponder];
        
        [loginPassword resignFirstResponder];
        [self loginBtnClicked:nil];
    }
    else if (textField == name) {
        [textField resignFirstResponder];
        [email becomeFirstResponder];
    }
    else if (textField == email) {
        [textField resignFirstResponder];
        [organization becomeFirstResponder];
    }
    
    else if (textField == organization) {
        [textField resignFirstResponder];
        [phoneNumber becomeFirstResponder];
    }else if (textField == phoneNumber) {
        [textField resignFirstResponder];
        [password becomeFirstResponder];
    }else if (textField == password) {
        [textField resignFirstResponder];
        [confirmPassword becomeFirstResponder];
    }else if (textField == confirmPassword) {
        [textField resignFirstResponder];
        [confirmPassword resignFirstResponder];
        [self registerOptionBtnClicked:nil];
    }
    
    
    
    return YES;
}




/*
 * Method name: textViewDidBeginEditing
 * Description: start the editing
 * Parameters: UITextView
 * Return Type: nil
 */
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if(textField.frame.origin.y > 120) {
        isTextFieldMoved = true;
        textFieldMovedDistance =  (textField.frame.origin.y - 80) + textField.frame.size.height;
        container.frame = CGRectMake(container.frame.origin.x,
                                     (container.frame.origin.y - textFieldMovedDistance),
                                     container.frame.size.width, container.frame.size.height);
    }
    [UIView commitAnimations];
}

/*
 * Method name: textViewDidEndEditing
 * Description: when text view editing is done
 * Parameters: UITextView
 * Return Type: nil
 */

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if(isTextFieldMoved) {
        isTextFieldMoved = false;
        container.frame = CGRectMake(container.frame.origin.x,
                                     (container.frame.origin.y + textFieldMovedDistance),
                                     container.frame.size.width, container.frame.size.height);
    }
    [UIView commitAnimations];
}
/*
 * Method name: resetRegistrationTextField
 * Description:reset text field
 * Parameters: nil
 * return: nil
 */
-(void) resetRegistrationTextField {
    name.text = @"";
    specialty.text = @"";
    //username.text = @"";
    email.text = @"";
    password.text = @"";
    confirmPassword.text = @"";
}

/*
 * Method name: playbackStateChanged
 * Description: Stages of movie player i:e play,pause and stop
 * Parameters: nil
 * return: nil
 */
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


#pragma mark UIINTERFACE ORIENTATION
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


- (void)startUpViewController {
    isLandScapeMode = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}
/*
 * Method name: orientationChanged
 * Description: when orientation changes notification will trigger..
 * Parameters: NSNotification
 * return void
 
 */

- (void)orientationChanged:(NSNotification *)notification {
    [self shouldAutorotate];
}
/*
 * Method name: forgotPassword
 * Description: To show the forgot password while user tap.
 * Parameters: nil
 * return IBAction
 
 */
-(IBAction)forgotPassword:(id)sender {
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:URL_FORGOT_PASSWORD]];
    
}

#pragma mark - Box login
-(IBAction)boxLoginBtnClicked:(id)sender {
    
    
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    // clear Tokens from memory
    //[BoxSDK sharedSDK].OAuth2Session.accessToken = @"INVALID_ACCESS_TOKEN";
    //[BoxSDK sharedSDK].OAuth2Session.refreshToken = @"INVALID_REFRESH_TOKEN";
    
    // clear tokens from keychain
    //appDelegate = [UIApplication sharedApplication].delegate;
    //[appDelegate setRefreshTokenInKeychain:@"INVALID_REFRESH_TOKEN"];
    
    // [(BoxNavigationController *)self.navigationController boxAPIHeartbeat];
    //[appDelegate handleAccessTokenforbox];
    
    
    /*  if (![BoxSDK sharedSDK].OAuth2Session.isAuthorized)
     {*/
    /* BoxAPIJSONFailureBlock failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary){
     [self boxError:error];
     };*/
    NSURL *authorizationURL = [BoxSDK sharedSDK].OAuth2Session.authorizeURL;
    NSString *redirectURI = [BoxSDK sharedSDK].OAuth2Session.redirectURIString;
    BoxAuthorizationViewController *authorizationViewController = [[BoxAuthorizationViewController alloc] initWithAuthorizationURL:authorizationURL redirectURI:redirectURI];
    BoxAuthorizationNavigationController *loginNavigation = [[BoxAuthorizationNavigationController alloc] initWithRootViewController:authorizationViewController];
    authorizationViewController.delegate = loginNavigation;
    loginNavigation.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:loginNavigation animated:YES completion:nil];
    //}
}

- (void)boxError:(NSError*)error {
    if (error.code == BoxSDKOAuth2ErrorAccessTokenExpiredOperationReachedMaxReenqueueLimit)
    {
        // Launch the picker again if for some reason the OAuth2 session cannot be refreshed.
        // this will bring the login screen which will be followed by the file picker itself
        return;
    }
    else if (error.code == BoxSDKOAuth2ErrorAccessTokenExpired)
    {
        // This error code appears as part of the re-authentication process and should be ignored
        return;
    }
    else {
        // we really failed, let the user know
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Box" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    }
}


#pragma mark - Handle OAuth2 session notifications
- (void)boxAPIAuthenticationDidSucceed:(NSNotification *)notification {
    NSLog(@"Received OAuth2 successfully authenticated notification");
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        BoxOAuth2Session *session = (BoxOAuth2Session *) [notification object];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view:NSLocalizedString(@"PLEASE_WAIT_SPINNER_MSG", nil)];
        }
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL, PLATFORM_BOX_AUTHENTICATION];
        
        NSURL *url = [NSURL URLWithString:urlStr];
        
        
        NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                     
                                     
                                     session.accessToken, HTTP_RESPONSE_BOX_ACCESSTOKEN_KEY,
                                     session.refreshToken, HTTP_RESPONSE_BOX_REFRESH_ACCESSTOKEN_KEY,
                                     session.accessTokenExpiration, HTTP_RESPONSE_BOX_EXPIRES_IN,nil];
        
        NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:url andDataDictionary:messageData attachmentData:nil
                                                         attachmentType:nil
                                                     attachmentFileName:nil];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
        [connection start];
        // BOXAssert(self.viewControllers.count == 1, @"There should only be one folder in the hierarchy when authentication succeeds");
    });
    
}
- (void)boxAPIAuthenticationDidFail:(NSNotification *)notification {
    NSLog(@"Received OAuth2 failed authenticated notification");
    NSString *oauth2Error = [[notification userInfo] valueForKey:BoxOAuth2AuthenticationErrorKey];
    NSLog(@"Authentication error  (%@)", oauth2Error);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)boxAPIInitiateLogin:(NSNotification *)notification {
    NSLog(@"Refresh failed. User is logged out. Initiate login flow");
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        // [self popToRootViewControllerAnimated:YES];
        
        NSURL *authorizationURL = [BoxSDK sharedSDK].OAuth2Session.authorizeURL;
        NSString *redirectURI = [BoxSDK sharedSDK].OAuth2Session.redirectURIString;
        BoxAuthorizationViewController *authorizationViewController = [[BoxAuthorizationViewController alloc] initWithAuthorizationURL:authorizationURL redirectURI:redirectURI];
        BoxAuthorizationNavigationController *loginNavigation = [[BoxAuthorizationNavigationController alloc] initWithRootViewController:authorizationViewController];
        authorizationViewController.delegate = loginNavigation;
        loginNavigation.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentViewController:loginNavigation animated:YES completion:nil];
    });
    
}

/*
 * Method name: addOrganizationUserDetails
 * Description: To View the List of user Organization .
 * Parameters: nil
 * return nil
 */
- (void)addOrganizationUserDetails{
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
    
}

#pragma mark - WelvuOrganization Delegate
-(void)welvuOrganizationViewControllerDidFinish {
    dispatch_after(0, dispatch_get_main_queue(), ^{
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view:NSLocalizedString(@"LOADING", nil)];
        }
        
        [self dismissModalViewControllerAnimated:NO];
        if(spinner != nil) {
            [spinner removeSpinner];
            spinner = nil;
        }
        
    });
    
    
    [self.delegate welvuLoginCompletedWithAccessToken];
    
}

-(void) loginUserWithOrganization :(NSInteger) user_id orgId:(NSInteger)orgId {
    
    NSInteger select = false;
    select = [welvu_user updateLoggedUserByOrgId:[appDelegate getDBPath]
                                          userId:user_id orgId:orgId isPrimary:false];
    if (select == 1) {
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        NSInteger specialtyCount = [welvu_specialty getSpecialtyCount:[appDelegate getDBPath]
                                                               userId:appDelegate.welvu_userModel.welvu_user_id];
        if(specialtyCount > 0) {
            [self welvuOrganizationViewControllerDidFinish];
        } else {
            [self syncSpecialtyFromPlatform];
            orgDetails = true;
        }
    }
    
}
-(void) getOrganizatioDetails {
    
    welvu_organization *welvu_organizationModel = [welvu_OrganizationArray
                                                   objectAtIndex:0];
    NSInteger user_id = appDelegate.welvu_userModel.welvu_user_id;
    NSInteger org_id = welvu_organizationModel.orgId;
    
    appDelegate.org_Logo = [PathHandler getDocumentDirPathForFile:welvu_organizationModel.orgLogoName];
    UIImage *image=[UIImage imageWithContentsOfFile:appDelegate.org_Logo];
    // themeLogo.image = image;
    [self loginUserWithOrganization :user_id orgId:org_id];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 * Method name: getConfiguration
 * Description:this method will sync specialty from platform
 * Parameters: nil
 * return nil
 */
-(void)getConfiguration {
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
        
        
        NSString *getudid = [NSString stringWithFormat:@"?device_id=%@",[NSNumber numberWithInteger:udid]];
        NSLog(@"get udid %@",getudid);
        
        NSString *getbundleIdentifier = [NSString stringWithFormat:@"&app_identifier=%@",[[NSBundle mainBundle] bundleIdentifier]];
        NSLog(@"get bundleIdentifier %@",getbundleIdentifier);
        
        NSString *getdeviceModel = [NSString stringWithFormat:@"&device_info=%@",deviceModel];
        NSLog(@"get device_info %@",getdeviceModel);
        
        NSString *getcurrentSystemVersion = [NSString stringWithFormat:@"&platform_version=%@",currSysVer];
        NSLog(@"get getcurrentSystemVersion %@",getcurrentSystemVersion);
        
        
        
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@",PLATFORM_HOST_URL2,  PLATFORM_GET_ORGANIZE_ACTION_URL,getudid,getbundleIdentifier,getdeviceModel,getcurrentSystemVersion ]];
        
        
        NSString *loginString = [NSString stringWithFormat:@"%@:%@", username, password];
        NSString *authHeader = [@"Bearer " stringByAppendingString:appDelegate.oauth_accessToken];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];;
        
        [request setHTTPMethod:HTTP_METHOD_GET];
        
        authorize =
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        [authorize start];
    }
}


-(void)oraganizationCout {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]) {
        
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        organizationCount = [welvu_user getOrgUserCount:appDelegate.getDBPath :appDelegate.welvu_userModel.welvu_user_id];
        
        NSLog(@"organizations %d",organizationCount);
        
        if(organizationCount == 0) {
            
            [self syncSpecialtyFromPlatform];
            
        } else if (organizationCount > 1) {
            
            orgCountPin = TRUE;
            welvuOrganizationViewController *welvuOrganization = [[welvuOrganizationViewController alloc]initWithNibName:@"welvuOrganizationViewController" bundle:nil];
            welvuOrganization.modalPresentationStyle = UIModalPresentationFullScreen;
            
            welvuOrganization.delegate = self;
            
            [self presentModalViewController:welvuOrganization animated:NO];
            
        } else if (organizationCount == 1){
            appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
            NSMutableArray * orgIds = nil;
            //doubt
            if(appDelegate.welvu_userModel.org_id == 0) {
                orgIds = [welvu_user getAllOrgIdOfUser:[appDelegate getDBPath]
                                                userId:appDelegate.welvu_userModel.welvu_user_id];
            } else {
                appDelegate.org_Logo = [PathHandler getDocumentDirPathForFile:([welvu_organization getOrganizationDetailsById
                                                                                :[appDelegate getDBPath]
                                                                                orgId:appDelegate.welvu_userModel.org_id]).orgLogoName];
                UIImage *image=[UIImage imageWithContentsOfFile:appDelegate.org_Logo];
                //themeLogo.image = image;
                orgIds = [welvu_user getAllOrgIdOfUser:[appDelegate getDBPath]
                                                userId:appDelegate.welvu_userModel.user_primary_key];
            }
            
            welvu_OrganizationArray = [[NSMutableArray alloc] init];
            for (NSNumber *orgId in orgIds) {
                NSInteger orgIdInteger = [orgId integerValue];
                [welvu_OrganizationArray addObject:[welvu_organization getOrganizationDetailsById
                                                    :[appDelegate getDBPath] orgId:orgIdInteger]];
            }
            
            [self getOrganizatioDetails];
            
        }
        
        
    }else{
        
        if(responseDictionaryy
           && ([actionAPi isEqualToString:PLATFORM_GET_ORGANIZATION_DETAIL_ACTION_URL])) {
            if(orgCountPin == TRUE) {
                
                // [self performSelector:@selector(fourDigitPin:)  withObject:nil];
                welvuOrganizationViewController *welvuOrganization = [[welvuOrganizationViewController alloc]initWithNibName:@"welvuOrganizationViewController" bundle:nil];
                welvuOrganization.modalPresentationStyle = UIModalPresentationFullScreen;
                //specialtyViewCont.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                welvuOrganization.delegate = self;
                
                [self presentModalViewController:welvuOrganization animated:NO];
                
                orgCountPin = FALSE;
                
            } else {
                [self.delegate welvuLoginCompletedWithAccessToken];
                
            }
        }else {
            [self.delegate welvuLoginCompletedWithAccessToken];
            
        }
        
        
        
        
    }
    
    
}

-(void)registerLoginContinue {
    if(spinner == nil) {
        spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view:NSLocalizedString(@"PLEASE_WAIT_SPINNER_MSG", nil)];
    }
    // HTTP_PASSWORD_KEY,PLATFORM_WELVU_GRANT_TYPE ,
    // WELVU_CLIENT_ID , PLATFORM_WELVU_CLIENT_ID ,
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", PLATFORM_HOST_URL, PLATFORM_SEND_AUTHENTICATION_ACTION_URL];
    UIDeviceHardware *device = [[UIDeviceHardware alloc] init];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString * deviceModel = [device platformString];
    NSString * udid = @"";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    udid = [defaults stringForKey:@"userDeviceID"];
    NSDictionary *messageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [[NSBundle mainBundle] bundleIdentifier], HTTP_REQUEST_APP_IDENTIFIER_KEY,
                                 registration.email, HTTP_REQUEST_USER_NAME,
                                 registration.password, HTTP_PASSWORD_KEY,
                                 udid, HTTP_REQUEST_DEVICE_ID,
                                 HTTP_PASSWORD_KEY,PLATFORM_WELVU_GRANT_TYPE ,
                                 WELVU_CLIENT_ID , PLATFORM_WELVU_CLIENT_ID ,
                                 deviceModel, HTTP_REQUEST_DEVICE_INFO,
                                 currSysVer, HTTP_REQUEST_PLATFORM_VERSION,nil];
    
    NSMutableURLRequest *requestDelegate = [self POSTRequestWithURL:url andDataDictionary:messageData attachmentData:nil
                                                     attachmentType:nil
                                                 attachmentFileName:nil];
    
    loginConnection = [[NSURLConnection alloc] initWithRequest:requestDelegate delegate:self];
    [loginConnection start];
}


#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == 200) {
        // [self addOrganizationUserDetails];
        [self registerLoginContinue];
        //[self.delegate welvuLoginCompletedWithAccessToken];
    }else if(alertView.tag == 100) {
        NSLog(@"100");
        
    }else if(alertView.tag == 300) {
        NSLog(@"300");
        
    }else if(alertView.tag == 400) {
        NSLog(@"400");
        
    }else{
        [self addOrganizationUserDetails];
    }
}
@end
