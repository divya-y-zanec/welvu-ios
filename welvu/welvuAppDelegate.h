//
//  welvuAppDelegate.h
//  welvu
//
//  Created by Logesh Kumaraguru on 15/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncDataToCloud.h"
#import "welvu_settings.h"
#import "welvu_user.h"
#import "Reachability.h"
#import <BoXSDK/BoxSDK.h>
#import "welvu_organization.h"
#import "ProcessingSpinnerView.h"
#import "welvu_configuration.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
/*
 * Class name: welvuAppDelegate
 * Description: TO SET DELEGATE FOR THE CONTROLLER
 * Extends: UIResponder
 *Delegate : UIApplicationDelegate,syncContentToPlatformHelperDelegate
 */
@class welvu_images;
@class welvuMasterViewController;
@class welvuOrganizationViewController;

@interface welvuAppDelegate : UIResponder <UIApplicationDelegate,syncContentToPlatformHelperDelegate > {
    welvu_user *welvu_userModel;
    NSInteger specialtyId;
    BOOL isHelpShown;
    BOOL ispatientVUContent;
    welvu_settings *currentWelvuSettings;
    NSInteger currentMasterScreen;
    NSInteger recordCounter;
    BOOL updatedCurrentVersion;
    BOOL isExportInProcess;
    //network reachability
    BOOL networkReachable;
    Reachability *internetReach;
    Reachability *hostReach;
    Reachability *localWifi;
    NSString *currentRequestActionURL;
    int update;
    NSString *accessToken;
    NSDictionary *currentPatientInfo;
    NSDictionary *currentPatientAppointments;
    NSDictionary *currentPatientGraphInfo;
    BOOL isPatientSelected;
    NSString *appBundleIdentifier;
    //To Check if iPX and EMRVU status
    BOOL isIPXInProgress;
    BOOL isEMRVUInProgress;
    //Box
    NSString *boxAccessToken;
    NSString *boxRefreshAccessToken;
    NSString *boxExpiresIn;
    UILabel *notificationLable;
    //Org
    welvu_organization *welvu_userOrganizationModel;
    NSString *org_Logo;
    ProcessingSpinnerView *spinner;
    BOOL updateOrg;
    BOOL insertOrg;
    BOOL checkOrganizationUserLicense;
    //NSURLConnection *confirmUser;
    //BOOL confirmRegisteredUser;
    BOOL checkOrganizationDetails;
    NSString *bundleVersionNumber;
    BOOL orgGoToWelVU;
    BOOL isSettingsChanged;
    BOOL isOrgSubcribed;
    NSMutableArray *welvu_specialtyModels;
    int activeSpecilaty;
    
    NSInteger showGuideSpecialtyVU;
    NSInteger showGuideDetailVU;
    NSInteger showGuideEditVU;
    NSInteger showGuideIPxVU;
    NSInteger showGuideCreateVU;
    NSInteger showGuideSettingsVU;
    
    //OAUTH
    NSString *oauth_accessToken;
    NSString *oauth_refreshToken;
    NSString *oauth_timer;
    BOOL *canRequestAccessToken;
    NSURLConnection *loginConnection;
    NSURLConnection *getOrganization;
    NSTimer *oauthRefreshToken;
    NSURLConnection *checkUserLicense;
    NSURLConnection *confirmUser;
    BOOL confirmRegisteredUser;
    welvu_configuration *welvu_configurationModel;
    NSMutableArray *welvu_configurationArray;
    NSString *responseStr;
    BOOL specialtydwnlding;
   welvuOrganizationViewController *orgViewController;
    
    NSInteger downLoadSpecialtyId;
    NSMutableArray *iPxImagesList;
    NSMutableArray *ipxOrgImagesList;
    NSMutableArray *iPxLibImagesList;
    NSMutableArray *iPxLibTopicList;
     NSInteger lastSelectedIpxTopicId;
    
    
}
@property (nonatomic, retain) NSMutableArray *welvu_specialtyModels;
//@property(nonatomic, assign) BOOL confirmRegisteredUser;
@property (nonatomic ,assign) BOOL isOrgSubcribed;
@property (nonatomic ,assign) BOOL orgGoToWelVU;
@property (nonatomic ,retain) NSString *bundleVersionNumber;
@property (nonatomic,assign) BOOL checkOrganizationDetails;
@property (nonatomic,assign) BOOL checkOrganizationUserLicense;
@property (nonatomic,assign) BOOL updateOrg;
@property (nonatomic,assign) BOOL insertOrg;
@property (nonatomic ,retain)  ProcessingSpinnerView *spinner;
//Org
@property (nonatomic ,retain)  NSString *org_Logo;
@property ( nonatomic,retain )  welvu_organization *welvu_userOrganizationModel;
@property (nonatomic,retain)  UILabel *notificationLable;
@property (nonatomic,retain) NSString *boxAccessToken;
@property (nonatomic,retain) NSString *boxRefreshAccessToken;
@property (nonatomic,retain) NSString *boxExpiresIn;
//Property
@property (nonatomic,retain) NSString *accessToken;
@property (nonatomic, retain) welvu_user *welvu_userModel;
@property (nonatomic,assign) BOOL updatedCurrentVersion;
@property (nonatomic,assign) BOOL networkReachable;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UISplitViewController *splitViewController;
@property (strong, nonatomic) welvuMasterViewController *masterViewController;
@property (strong, nonatomic)welvuOrganizationViewController *orgViewController;

@property (nonatomic, readwrite) NSInteger specialtyId;
@property (nonatomic, readwrite) NSInteger imageId;
@property (nonatomic, readwrite) NSInteger recordCounter;
@property (nonatomic, readwrite) BOOL isHelpShown;
@property (nonatomic, readwrite) BOOL ispatientVUContent;
@property (nonatomic, readwrite) BOOL isExportInProcess;
@property (nonatomic, retain) welvu_settings *currentWelvuSettings;
@property (nonatomic,readwrite) NSInteger currentMasterScreen;
@property (nonatomic, retain) NSDictionary *currentPatientInfo;
@property (nonatomic, retain) NSDictionary *currentPatientGraphInfo;
@property (nonatomic, retain) NSDictionary *currentPatientAppointments;
@property (nonatomic, readwrite) BOOL isPatientSelected;
@property (nonatomic,strong)  NSString *appBundleIdentifier;
//To Check if iPX and EMRVU status
@property (nonatomic, readwrite) BOOL isIPXInProgress;
@property (nonatomic, readwrite) BOOL isEMRVUInProgress;
@property (nonatomic,assign) BOOL isSettingsChanged;
//Map
@property (nonatomic, retain) NSMutableArray *mapLinks;

@property (nonatomic, readwrite)NSInteger showGuideSpecialtyVU;
@property (nonatomic, readwrite)NSInteger showGuideDetailVU;
@property (nonatomic, readwrite)NSInteger showGuideEditVU;
@property (nonatomic, readwrite)NSInteger showGuideIPxVU;
@property (nonatomic, readwrite)NSInteger showGuideCreateVU;
@property (nonatomic, readwrite)NSInteger showGuideSettingsVU;

//OAUTH
@property (retain, nonatomic) NSMutableArray *welvu_configurationArray;
@property(nonatomic, assign) BOOL confirmRegisteredUser;
@property(nonatomic, retain) NSTimer *oauthRefreshToken;
@property (nonatomic ,retain) NSString *oauth_accessToken;
@property (nonatomic ,retain) NSString *oauth_refreshToken;
@property (nonatomic ,retain) NSString *oauth_timer;
@property (nonatomic ,assign) BOOL *canRequestAccessToken;

@property (nonatomic ,assign) BOOL specialtydwnlding;
@property (nonatomic,readwrite) NSInteger downLoadSpecialtyId;

@property (nonatomic,retain) NSMutableArray *iPxImagesList;
@property (nonatomic,retain) NSMutableArray *ipxOrgImagesList;
@property (nonatomic,retain) NSMutableArray *iPxLibImagesList;
@property (nonatomic,retain) NSMutableArray *iPxLibTopicList;

@property (nonatomic, readwrite) NSInteger lastSelectedIpxTopicId;

//Methods
-(void)checkForConfirmedUser;
-(void)copyDatabaseIfNeeded;
-(NSString *)getDBPath;
-(void)startSyncProcess;
-(void)updateImagesUrlLastComponentPath:(NSString *)dbPath;
-(void)obtainBundleIdentifier;
-(void)setRefreshTokenInKeychain:(NSString *)refreshToken;
-(BOOL) handleAccessTokenforbox;
-(void)refreshBoxAccessToken;
-(void) emailSentNotificationLabel;
-(void) emailSentNotificationLabel:(NSString *)responseString;
-(void)checkUserLicense;
-(void)addorganizationDetails ;
-(void)addWelvuVersionNumber;
-(void)iRateAppVersion;
-(void)configInsertOrUpdate  :(welvu_configuration *)welvu_configurationModel;
-(void)oauthRefreshAccessToken;
@end
