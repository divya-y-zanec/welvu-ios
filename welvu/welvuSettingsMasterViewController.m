//
//  SettingsMasterViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 25/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "welvuSettingsMasterViewController.h"
#import "welvuContants.h"
#import "welvu_sync.h"
#import "welvu_sharevu.h"
#import "GAI.h"

@interface welvuSettingsMasterViewController ()

@end

@implementation welvuSettingsMasterViewController
@synthesize delegate, headers, currentWelvuSettings ,displayVersion ,switchWelVUBtn ,orgVUController;
/*
 * Method name: initWithNibName
 * Description: initlizing with nib file
 * Parameters: bundle
 * return self
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        headers = [[NSMutableArray alloc] initWithCapacity:7];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        
        if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]
           ||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OPENEMR]
           ||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
            [headers addObject:NSLocalizedString(@"SETTINGS_TOPIC_SORT_HEADER", nil)];
            [headers addObject:NSLocalizedString(@"SETTINGS_LAYOUT_HEADER", nil)];
            [headers addObject:NSLocalizedString(@"SETTINGS_VIDEO_HEADER", nil)];
            [headers addObject:NSLocalizedString(@"SETTINGS_EMAIL_HEADER", nil)];
            [headers addObject:NSLocalizedString(@"SETTINGS_BLANK_CANVAS_COLOR_HEADER", nil)];
            [headers addObject:NSLocalizedString(@"SETTINGS_SPECIALTY_HEADER", nil)];
            
            //Theme
            //[headers addObject:NSLocalizedString(@"SETTINGS_ORGANIZATION_CHANGE", nil)];
            [headers addObject:NSLocalizedString(@"SETTINGS_VITAL_STATISTICS_CHANGE", nil)];
        }else {
            [headers addObject:NSLocalizedString(@"SETTINGS_TOPIC_SORT_HEADER", nil)];
            [headers addObject:NSLocalizedString(@"SETTINGS_LAYOUT_HEADER", nil)];
            [headers addObject:NSLocalizedString(@"SETTINGS_VIDEO_HEADER", nil)];
            [headers addObject:NSLocalizedString(@"SETTINGS_EMAIL_HEADER", nil)];
            [headers addObject:NSLocalizedString(@"SETTINGS_BLANK_CANVAS_COLOR_HEADER", nil)];
            [headers addObject:NSLocalizedString(@"SETTINGS_SPECIALTY_HEADER", nil)];
            // [headers addObject:NSLocalizedString(@"SETTINGS_ORGANIZATION_CHANGE", nil)];
        }
        
        
        
    }
    return self;
}
/*
 * Method name: informationBtnClicked
 * Description: show the guide for the user
 * Parameters: id
 * return nil
 */
-(IBAction)informationBtnClicked:(id)sender{
    
    //Declaring Event Tracking Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"SettingsVU - S"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SettingsVU - S"
                                                          action:@"Guide Button -S"
                                                           label:@"Guide"
                                                           value:nil] build]];
    
    @try {
        if ([orgVUController isEqualToString:@"OrgVU"]) {
            overlay = [[UIView alloc] initWithFrame:[self.parentViewController.view frame]];
            overlay.alpha = 1;
            overlay.backgroundColor = [UIColor clearColor];
            
            
            UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:[self.parentViewController.view frame]];
            UIButton *overlayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [overlayCustomBtn addTarget:self action:@selector(closeOverlay:) forControlEvents:UIControlEventTouchUpInside];
            [overlayCustomBtn setFrame:[self.parentViewController.view frame]];
            overlayImageView.image = [UIImage imageNamed:@"Org_SettingsVUOverlay.png"];
            
            [overlay addSubview:overlayImageView];
            [overlay addSubview:overlayCustomBtn];
            
            [self.parentViewController.view addSubview:overlay];
        } else {
            int orgCount = [welvu_organization getOrganizationCount:[appDelegate getDBPath]];
            
            
            if(appDelegate.welvu_userModel.org_id > 0) {
                
                
                overlay = [[UIView alloc] initWithFrame:[self.parentViewController.view frame]];
                overlay.alpha = 1;
                overlay.backgroundColor = [UIColor clearColor];
                
                
                UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:[self.parentViewController.view frame]];
                UIButton *overlayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [overlayCustomBtn addTarget:self action:@selector(closeOverlay:) forControlEvents:UIControlEventTouchUpInside];
                [overlayCustomBtn setFrame:[self.parentViewController.view frame]];
                overlayImageView.image = [UIImage imageNamed:@"SettingsVUOverlay.png"];
                
                [overlay addSubview:overlayImageView];
                [overlay addSubview:overlayCustomBtn];
                
                [self.parentViewController.view addSubview:overlay];
            } else {
                if(appDelegate.orgGoToWelVU) {
                    overlay = [[UIView alloc] initWithFrame:[self.parentViewController.view frame]];
                    overlay.alpha = 1;
                    overlay.backgroundColor = [UIColor clearColor];
                    
                    
                    UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:[self.parentViewController.view frame]];
                    UIButton *overlayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [overlayCustomBtn addTarget:self action:@selector(closeOverlay:) forControlEvents:UIControlEventTouchUpInside];
                    [overlayCustomBtn setFrame:[self.parentViewController.view frame]];
                    overlayImageView.image = [UIImage imageNamed:@"SettingsVUOverlay.png"];
                    
                    [overlay addSubview:overlayImageView];
                    [overlay addSubview:overlayCustomBtn];
                    
                    [self.parentViewController.view addSubview:overlay];
                } else {
                    overlay = [[UIView alloc] initWithFrame:[self.parentViewController.view frame]];
                    overlay.alpha = 1;
                    overlay.backgroundColor = [UIColor clearColor];
                    
                    
                    UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:[self.parentViewController.view frame]];
                    UIButton *overlayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [overlayCustomBtn addTarget:self action:@selector(closeOverlay:) forControlEvents:UIControlEventTouchUpInside];
                    [overlayCustomBtn setFrame:[self.parentViewController.view frame]];
                    overlayImageView.image = [UIImage imageNamed:@"Org_SettingsVUOverlay.png"];
                    
                    [overlay addSubview:overlayImageView];
                    [overlay addSubview:overlayCustomBtn];
                    
                    [self.parentViewController.view addSubview:overlay];            }
            }
            
            
        }
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"SettingsVU-S_Guide: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

/*
 * Method name: closeOverlay
 * Description: to close the overlay
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2012
 */
-(IBAction)closeOverlay:(id)sender
{
    //Declaring Event Tracking Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"SettingsVU - S"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SettingsVU - S"
                                                          action:@"close guide -S"
                                                           label:@"overlayclosed"
                                                           value:nil] build]];
    
    
    @try {
        
        
        if(overlay !=nil) {
            [overlay removeFromSuperview];
            overlay = nil;
        }
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"SettingsVU_closeOverlay: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
    }
}

/*
 * Method name: doneBtnClicked
 * Description: save the description
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2012
 */

-(IBAction)doneBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    //Declaring Event Tracking Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"SettingsVU - S"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SettingsVU - S"
                                                          action:@"Save Button -S"
                                                           label:@"Save"
                                                           value:nil] build]];
    
    @try {
        int updated = [welvu_settings updateCustomSettings:appDelegate.getDBPath :currentWelvuSettings];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:currentWelvuSettings.isAnimationOn forKey:@"guideAnimationOn"];
        
        //[defaults synchronize];
        if(updated > 0) {
            if(((welvu_settings *)appDelegate.currentWelvuSettings) != nil) {
                appDelegate.currentWelvuSettings = nil;
            }
            appDelegate.currentWelvuSettings = [welvu_settings getActiveSettings:appDelegate.getDBPath];
            appDelegate.currentWelvuSettings.isAnimationOn = [defaults boolForKey:@"guideAnimationOn"];
        }
        [self.delegate settingsMasterViewControllerDidFinish];
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"SettingsVU-S_Save:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
        
        
    }
}

-(IBAction)logoutBtnClicked:(id)sender {
    //Check for ShareVU & Platform Sync
    NSInteger syncCount = [welvu_sync getSyncCount:[appDelegate getDBPath]];
    BOOL shareVUStatus = [welvu_sharevu getShareVUQueueByStatus:[appDelegate getDBPath]
                                                         status:WELVU_SHARVU_UNDER_PROGRESS];
    if(!appDelegate.isEMRVUInProgress && !appDelegate.isIPXInProgress
       && syncCount == 0 && !shareVUStatus &&  appDelegate.networkReachable) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:NSLocalizedString(@"ALERT_LOGOUT_CONFIRMATION_MSG", nil)
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"NO", nil)
                              otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        alert.tag = 1;
        [alert show];
    } else {
        if(appDelegate.networkReachable) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:NSLocalizedString(@"ALERT_SHARE_UNDER_PROGRESS", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil];
            alert.tag = 2;
            [alert show];
            if(syncCount > 0) {
                [appDelegate startSyncProcess];
            }
        } else {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:NSLocalizedString(@"ALERT_SHARE_UNDER_PROGRESS_NO_INTERNET_EBOLA", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                  otherButtonTitles:NSLocalizedString(@"CONTINUE", nil), nil];
            alert.tag = 100;
            [alert show];
            
            /*if ([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_EBOLAVU]) {
             

            }else{
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:NSLocalizedString(@"ALERT_SHARE_UNDER_PROGRESS_NO_INTERNET", nil)
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil];
            [alert show];
            }*/
        }
    }
}

- (void) syncingContentBeforeLogout {
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
                              message:NSLocalizedString(@"ALERT_LOGOUT_CONFIRMATION_MSG", nil)
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"NO", nil)
                              otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        alert.tag = 1;
        [alert show];
    } else {
        [self performSelector:@selector(syncingContentBeforeLogout) withObject:nil afterDelay:2];
    }
}

//Deleagte Methods
-(void)layoutSettingsViewControllerDidClose{
    [self dismissModalViewControllerAnimated:YES];
}
-(void)layoutSettingsViewControllerDidFinish {
    [self performSelector:@selector(doneBtnClicked:) withObject:nil];
}

-(void)videoSettingsViewControllerDidClose{
    [self dismissModalViewControllerAnimated:YES];
}


-(void)videoSettingsViewControllerDidFinish {
    [self performSelector:@selector(doneBtnClicked:) withObject:nil];
}

-(void)emailSettingsViewControllerDidClose{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)emailSettingsViewControllerDidFinish {
    [self performSelector:@selector(doneBtnClicked:) withObject:nil];
}

-(void)topicSettingsViewControllerDidClose{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)topicSettingsViewControllerDidFinish {
    [self performSelector:@selector(doneBtnClicked:) withObject:nil];
}

-(void)blankSettingsViewControllerDidClose{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)blankSettingsViewControllerDidFinish {
    [self performSelector:@selector(doneBtnClicked:) withObject:nil];
}

-(void)welvuSettingsGuideAnimationDidClose{
    [self dismissModalViewControllerAnimated:YES];
}
-(void)welvuSettingsGuideAnimationDidFinish {
    [self performSelector:@selector(doneBtnClicked:) withObject:nil];
}
//Theme
- (void)themeSettingsViewControllerDidFinish {
    
    [self performSelector:@selector(doneBtnClicked1:) withObject:nil];
}

-(void)VitalStatisticViewControllerDidFinish {
    [self performSelector:@selector(doneBtnClicked:) withObject:nil];
    
}
-(IBAction)doneBtnClicked1:(id)sender {
    //Declaring Event Tracking Analytics
    
    int updated = [welvu_settings updateCustomSettings:appDelegate.getDBPath :currentWelvuSettings];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:currentWelvuSettings.isAnimationOn forKey:@"guideAnimationOn"];
    
    //[defaults synchronize];
    if(updated > 0) {
        if(((welvu_settings *)appDelegate.currentWelvuSettings) != nil) {
            appDelegate.currentWelvuSettings = nil;
        }
        appDelegate.currentWelvuSettings = [welvu_settings getActiveSettings:appDelegate.getDBPath];
        appDelegate.currentWelvuSettings.isAnimationOn = [defaults boolForKey:@"guideAnimationOn"];
    }
    [self.delegate settingsMasterViewControllerDidFinish];
    
    
}

/*
 * Method name: cancelBtnClicked
 * Description: cancel the description
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2012
 */

-(IBAction)cancelBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"SettingsVU - S"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SettingsVU - S"
                                                          action:@"Cancel Button -S"
                                                           label:@"Cancel"
                                                           value:nil] build]];
    
    @try {
        
        [self.delegate settingsMasterViewControllerDidCancel];
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"SettingsVU-S_Cancel%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
        
    }
}

#pragma mark alertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    appDelegate.isOrgSubcribed = FALSE;
    if (alertView.tag == 100 && buttonIndex == 1) {
        
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        // clear Tokens from memory
        [BoxSDK sharedSDK].OAuth2Session.accessToken = @"INVALID_ACCESS_TOKEN";
        [BoxSDK sharedSDK].OAuth2Session.refreshToken = @"INVALID_REFRESH_TOKEN";
        
        // clear tokens from keychain
        appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate setRefreshTokenInKeychain:@"INVALID_REFRESH_TOKEN"];
        
        //Delete Topics table and images
        BOOL logoutUser = [welvu_user logoutUserInSettings:[appDelegate getDBPath] :appDelegate.welvu_userModel];
        //BOOL resetCompleted = [welvu_settings logoutUserResetTable:[appDelegate getDBPath]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString * udid = [[defaults stringForKey:@"userDeviceID"] copy];
        NSString * currSysVer = [[defaults stringForKey:@"currentiOSVersion"] copy];
        NSString * prevSysVer = [[defaults stringForKey:@"previousiOSVersion"] copy];
        appDelegate.orgGoToWelVU= false;
        
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
        /* for (NSString *file in [fm contentsOfDirectoryAtPath:DOCUMENT_DIRECTORY error:&error]) {
         BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", DOCUMENT_DIRECTORY, file] error:&error];
         if (!success || error) {
         // it failed.
         }
         }*/
        
        error = nil;
        for (NSString *file in [fm contentsOfDirectoryAtPath:CACHE_DIRECTORY error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", CACHE_DIRECTORY, file] error:&error];
            if (!success || error) {
                // it failed.
            }
        }
        //Remove UserDefaults
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        //Set BundleIdentifier
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        // NSLog(@" bundle identifer %@",bundleIdentifier);
        
        [defaults setObject:bundleIdentifier forKey:@"appBundleIdentifier"];
        [defaults setObject:prevSysVer forKey:@"previousiOSVersion"];
        [defaults setObject:udid forKey:@"userDeviceID"];
        [defaults setObject:currSysVer forKey:@"currentiOSVersion"];
        [defaults synchronize];
        
        //[appDelegate copyDatabaseIfNeeded];
        appDelegate.currentWelvuSettings = [welvu_settings getActiveSettings:[appDelegate getDBPath]];
        
        [self.delegate logoutUser];
    }else if (alertView.tag ==  1 && buttonIndex == 1) {
        
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        // clear Tokens from memory
        [BoxSDK sharedSDK].OAuth2Session.accessToken = @"INVALID_ACCESS_TOKEN";
        [BoxSDK sharedSDK].OAuth2Session.refreshToken = @"INVALID_REFRESH_TOKEN";
        
        // clear tokens from keychain
        appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate setRefreshTokenInKeychain:@"INVALID_REFRESH_TOKEN"];
        
        //Delete Topics table and images
        BOOL logoutUser = [welvu_user logoutUserInSettings:[appDelegate getDBPath] :appDelegate.welvu_userModel];
        //BOOL resetCompleted = [welvu_settings logoutUserResetTable:[appDelegate getDBPath]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString * udid = [[defaults stringForKey:@"userDeviceID"] copy];
        NSString * currSysVer = [[defaults stringForKey:@"currentiOSVersion"] copy];
        NSString * prevSysVer = [[defaults stringForKey:@"previousiOSVersion"] copy];
        appDelegate.orgGoToWelVU= false;
        
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
        /* for (NSString *file in [fm contentsOfDirectoryAtPath:DOCUMENT_DIRECTORY error:&error]) {
         BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", DOCUMENT_DIRECTORY, file] error:&error];
         if (!success || error) {
         // it failed.
         }
         }*/
        
        error = nil;
        for (NSString *file in [fm contentsOfDirectoryAtPath:CACHE_DIRECTORY error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", CACHE_DIRECTORY, file] error:&error];
            if (!success || error) {
                // it failed.
            }
        }
        //Remove UserDefaults
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        //Set BundleIdentifier
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        // NSLog(@" bundle identifer %@",bundleIdentifier);
        
        [defaults setObject:bundleIdentifier forKey:@"appBundleIdentifier"];
        [defaults setObject:prevSysVer forKey:@"previousiOSVersion"];
        [defaults setObject:udid forKey:@"userDeviceID"];
        [defaults setObject:currSysVer forKey:@"currentiOSVersion"];
        [defaults synchronize];
        
        //[appDelegate copyDatabaseIfNeeded];
        appDelegate.currentWelvuSettings = [welvu_settings getActiveSettings:[appDelegate getDBPath]];
        
        [self.delegate logoutUser];
    } else if (alertView.tag == 2 && buttonIndex == 0) {
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view];
        }
        [self syncingContentBeforeLogout];
    } else if (alertView.tag ==  6 && buttonIndex == 1) {
        
        
        appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        
        
        BOOL switchAccount = [welvu_user switchAccount:[appDelegate getDBPath]];
        
        appDelegate.currentWelvuSettings = [welvu_settings getActiveSettings:[appDelegate getDBPath]];
        
        [self.delegate switchToWelvuUSer];
    } else if (alertView.tag == 7 && buttonIndex == 0) {
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:self.view];
        }
        [self syncingContentBeforeSwitchAccount];
    }
}
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
#pragma mark UITableView Delegate

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //return [[self.fetchedResultsController sections] count];
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [headers count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    //ios 7
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     currentWelvuSettings = [welvu_settings getActiveSettings:appDelegate.getDBPath];
    switch (indexPath.row) {
        case SETTINGS_TOPIC_SORT_OPTION: {
            welvuTopicSortSettingsViewController *topicSortSettings = [[welvuTopicSortSettingsViewController alloc]
                                                                       initWithTopicSortSettings:currentWelvuSettings];
            topicSortSettings.delegate = self;
            [self.navigationController pushViewController:topicSortSettings animated:YES];
            
        }
            break;
        case SETTINGS_LAYOUT_OPTION: {
            welvuLayoutSettingsViewController *layoutSettings = [[welvuLayoutSettingsViewController alloc]
                                                                 initWithLayoutSettings:currentWelvuSettings];
            layoutSettings.delegate = self;
            [self.navigationController pushViewController:layoutSettings animated:YES];
        }
            break;
        case SETTINGS_VIDEO_OPTION: {
            welvuVideoSettingsViewController *videoSettings = [[welvuVideoSettingsViewController alloc]
                                                               initWithVideoSettings:currentWelvuSettings];
            videoSettings.delegate = self;
            [self.navigationController pushViewController:videoSettings animated:YES];
        }
            break;
        case SETTINGS_EMAIL_HEADER: {
            welvuEmailSettingsViewController *emailSettings = [[welvuEmailSettingsViewController alloc]
                                                               initWithEmailSettings:currentWelvuSettings];
            emailSettings.delegate = self;
            [self.navigationController pushViewController:emailSettings animated:YES];
        }
            break;
            
        case SETTINGS_BLANK_CANVAS_COLOR_HEADER: {
            welvuBlankCanvasColorSettingsViewController *blankCanvasColorSettings = [[welvuBlankCanvasColorSettingsViewController alloc] initWithBlankCanvasColorSettings:currentWelvuSettings];
            blankCanvasColorSettings.delegate = self;
            [self.navigationController pushViewController:blankCanvasColorSettings animated:YES];
            
        }
            break;
            
        case SETTINGS_SPECIALTY_HEADER: {
            welvuSettingsGuideAnimationViewController *guideAnimatiomsettings = [[welvuSettingsGuideAnimationViewController alloc] initWithGuideAnimatiom:currentWelvuSettings];
            guideAnimatiomsettings.delegate=self;
            [self.navigationController pushViewController:guideAnimatiomsettings animated:YES];
        }
            break;
            
        case SETTINGS_ORG_CHANGE: {
            welvuSettingsThemeViewController *themeSettings = [[welvuSettingsThemeViewController alloc]
                                                               initWithThemeSettings:currentWelvuSettings];
            themeSettings.delegate = self;
            [self.navigationController pushViewController:themeSettings animated:YES];
        }
            break;
            
        case SETTINGS_VITAL_STATISTICS_CHANGE: {
            welvuSettingsVitalStatisticViewController *topicSortSettings = [[welvuSettingsVitalStatisticViewController alloc]
                                                                            initwithVitalSettings:currentWelvuSettings];
            topicSortSettings.delegate = self;
            [self.navigationController pushViewController:topicSortSettings animated:YES];
        }
            
        default:
            break;
    }
    
}
//Configure table view cell
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTHFULL_DATE_TIME_FORAMAT];
    UIView *selectionView = [[UIView alloc]initWithFrame:cell.bounds];
    [selectionView setBackgroundColor:[UIColor colorWithRed:0.94f green:0.67f blue:0.14f alpha:1.0f]];
    
    cell.selectedBackgroundView = selectionView;
   // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryType = UITableViewCellAccessoryNone;
cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white_arrow.png"]];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    cell.textLabel.text = [headers objectAtIndex:indexPath.row];
    cell.textLabel.numberOfLines = 2;
    
}


#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //Declaring Page View Analytics
    
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"SettingsVU - S"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    
    headerLabel.text = NSLocalizedString(@"SETTINGS_HEADER", nil);
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    currentWelvuSettings = [welvu_settings getActiveSettings:appDelegate.getDBPath];
    
    // NSLog(@"user id %d" ,appDelegate.welvu_userModel.welvu_user_id);
    // NSLog(@"primary_id %d" ,appDelegate.welvu_userModel.user_primary_key);
    // NSLog(@"org_id %d",appDelegate.welvu_userModel.org_id);
    
    int orgCount = [welvu_organization getOrganizationCount:[appDelegate getDBPath]];
    
    if ([orgVUController isEqualToString:@"OrgVU"]) {
        switchWelVUBtn.hidden = TRUE;
    } else {
        if(appDelegate.welvu_userModel.org_id > 0) {
            
            
            switchWelVUBtn.hidden = false;
        } else {
            if(appDelegate.orgGoToWelVU) {
                switchWelVUBtn.hidden = false;
                
            } else {
                switchWelVUBtn.hidden = TRUE;
            }
        }
        
    }
    settingsTableView.layer.cornerRadius = 10;
    
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *bundleDisplayName =  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    
    
    NSString* versionDisplayName = [NSString stringWithFormat:@"%@ v %@", bundleDisplayName, version];
    
    // NSLog(@"version display name %@",versionDisplayName);
    
    displayVersion.text = versionDisplayName ;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        
        // logOutBtn.hidden = YES;
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    if ( appDelegate.showGuideSettingsVU == 0) {
        [self performSelector:@selector(informationBtnClicked:)withObject:nil];
        appDelegate.showGuideSettingsVU = 1;
    }


}

//naviagte to organization vu
-(IBAction)skipToWelVUBtnClicked:(id)sender {
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UIInterfaceOrientation
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


@end
