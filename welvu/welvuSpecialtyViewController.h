//
//  welvuDetailViewController.h
//  welvu
//
//  Created by Divya yadav on 27/09/12.
//  Copyright (c) 2012 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <StoreKit/StoreKit.h>
#import "welvuContants.h"
#import "welvu_specialty.h"
#import "welvuSettingsMasterViewController.h"
#import "welvu_alerts.h"
#import "InAppPurchaseManager.h"
#import "HTTPRequestHandler.h"
#import "HTTPDownloadFileHandler.h"
#import "ProcessingSpinnerView.h"
#import "ProgressView.h"
#import "ZipArchive.h"
#import "Reachability.h"
#import <MediaPlayer/MediaPlayer.h>
#import <sqlite3.h>
#import <BoxSDK/BoxSDK.h>
#import "welvuOrganizationViewController.h"
#import "welvu_download.h"
#import "M13ProgressViewRing.h"
@class M13ProgressViewRing;
@class M13ProgressView;
/*
 * Protocol name: specialtyViewControllerDelegate
 * Description: Delegate function for returning unarchived image/topic
 */
@protocol specialtyViewControllerDelegate
-(void)specialtyViewControllerDidFinish:(BOOL)isChanged;
-(void)userLoggedOutFromSpecialtyViewController;
-(void)userSwitchFromSpecialtyViewController;
@end

/*
 * Class name: welvuSpecialtyViewController
 * Description: Holds the list of subscribed and non-Subcribed Specialty
 * Extends: UIViewController
 * Delegate : UINavigationControllerDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate
 */
@interface welvuSpecialtyViewController : UIViewController <UINavigationControllerDelegate,
UIPopoverControllerDelegate, UIAlertViewDelegate, SettingsMasterViewControllerDelegate,SKRequestDelegate,
HTTPRequestHandlerDelegate, HTTPDownloadHandlerDelegate, ZipArchiveDelegate, InAppPurchaseManagerDelegate,MPMediaPickerControllerDelegate,UITableViewDelegate ,NSURLConnectionDelegate,syncContentToPlatformHelperDelegate  > {
    
    id<specialtyViewControllerDelegate> delegate;
    InAppPurchaseManager *inApp;
    //Selected Specialty ID
    NSInteger specialtyId;
    
    NSInteger selectedIndexRow;
    //Application delegate
    welvuAppDelegate *appDelegate;
    MPMoviePlayerController *moviePlayer;
    //Outlet tableview object
    IBOutlet UITableView *specialtyTableView;
    //Topics array object
    NSMutableArray *welvu_specialtyModels;
    int specialty_id;
    IBOutlet UIView*  helpView;
    IBOutlet UIButton *syncSpecialty;
    //Topics header and footer fading view object
    //Fade effect
    IBOutlet UIView*  _topFadingView;
    IBOutlet UIView*  _bottomFadingView;
    UIColor* fadeColor_;
    UIColor* baseColor_;
    CAGradientLayer *g1_;
    CAGradientLayer *g2_;
    CAGradientLayer *g3_;
    CAGradientLayer *g4_;
    CAGradientLayer *g9_;
    fade_orientation fadeOrientation_;
    //For orientation
    BOOL isLandScapeMode;
    //inapp purchase
    NSSet * _productIdentifiers;
    NSArray * _products;
    NSMutableSet * _purchasedProducts;
    SKProductsRequest * _request;
    NSString  *notificationIdentStr;
    UIAlertView * askToPurchase ;
    NSUserDefaults * defaults;
    NSMutableDictionary * RegisterDict;
    NSURLConnection *  RegisterConnection ;
    UIView*  loadingView;
    UIView *replayOverlay;
    UIView *selectionView;
    UIActivityIndicatorView *getPimagesSpinner;
    IBOutlet UIActivityIndicatorView *spinnerEMR;
    IBOutlet UIImageView *themeLogo;
    UILabel *notificationLable;
    int update;
    int orgCount;
    //Downloading text
    ProcessingSpinnerView *spinner;
    ProgressView *progressView;
    //SpecialtyDatas dictionary
    NSDictionary *responseTopicsDictionary;
    BOOL isAlreadyCalled;
    BOOL networkReachable;
    Reachability *internetReach;
    Reachability *hostReach;
    //OEMR
    NSString *selectedPatient;
    IBOutlet UIImageView *imageView;
    IBOutlet UIButton *imagethumbnail;
    NSDictionary *patientImages;
    NSDictionary *PatientAppointments;
    NSDictionary *patientdemographics;
    IBOutlet UITableView *patientTableView;
    NSMutableArray *objects;
    NSMutableArray *objectsID;
    NSMutableArray *PatientimageArray;
    NSString *patientID;
    NSString *oemrToken;
    NSString *patientImageUrl;
    NSDictionary *responseDictionary;
    NSDictionary *patientResponseDictionary;
    NSURLConnection *patientListConn;
    NSURLConnection *PatientDocConn;
    NSURLConnection *appointmentsConn;
    NSString *uniquePath;
    NSInteger *date;
    NSMutableArray *middleName;
    NSMutableArray *lastName;
    NSMutableArray *title;
    NSMutableArray *startTime;
    NSMutableArray *endTime;
    NSMutableArray *duration;
    NSMutableArray *description;
    NSString* responseStr;
    
    IBOutlet  UILabel *AlertNameLHS;
    IBOutlet UILabel *AlertNameRHS;
    IBOutlet UILabel *displayDate;
    IBOutlet UILabel *displayName;
    IBOutlet UILabel *displayComment;
    IBOutlet UILabel *loading;
    IBOutlet UIView *patientTopFaddingView;
    IBOutlet UIView *patientBottomFaddingView;
    IBOutlet UIImageView *TableHeader;
    IBOutlet UIImageView *overVUImage;
    IBOutlet UIButton *proceed;
    IBOutlet UIView *hidePatientView;
    IBOutlet UIButton *goBtn;
    BOOL isReloaded;
    NSIndexPath *selectedIndexPath;
    NSUserDefaults *patientIndexPathSelectDefault;
    NSInteger savedIndexPath;
    IBOutlet UIButton *backBtn;
    IBOutlet UIButton *guideBtn;
    BOOL hasPresentedModalMenuView;
    UIAlertView *dismissAlert;
    
    //OAUTH
    NSURLConnection *getTopics;
    NSURLConnection *getSpecialty;
    NSURLConnection *oauthPatientListConn;
    NSURLConnection *oauthPatientDocumentConn;
    IBOutlet UILabel *patientAppointmentLabel;
    
    welvu_download *welvuDownloadModel;
    NSFileHandle *receivedData;
    NSInteger downloadBytes;
    float downloadPercentage;
    
    
    UIActivityIndicatorView *activityIndicator;
    NSInteger totalSpcltySze;
    float totalDownldPercent;
    IBOutlet M13ProgressViewRing *ringprogressView;
}
//Property
@property (nonatomic,assign)  BOOL hasPresentedModalMenuView;
@property (nonatomic,readwrite)NSInteger savedIndexPath;
@property (nonatomic,retain)  NSUserDefaults *patientIndexPathSelectDefault;
@property (strong,nonatomic) IBOutlet UIImageView *themeLogo;
@property (strong,nonatomic) UILabel *notificationLable;
@property (nonatomic,retain)  NSIndexPath *selectedIndexPath;
@property (nonatomic, readwrite)BOOL isReloaded;
@property (nonatomic ,retain) IBOutlet UIButton *proceed;
@property (nonatomic ,readwrite) NSInteger selectedIndexRow;
@property (nonatomic,retain) IBOutlet UIImageView *TableHeader;
@property (nonatomic ,retain)  IBOutlet UIImageView *overVUImage;
@property (nonatomic ,retain) IBOutlet UILabel *displayDate;
@property (nonatomic ,retain)  IBOutlet UILabel *displayName;
@property (nonatomic ,retain) IBOutlet UILabel *displayComment;
@property (nonatomic ,retain)  IBOutlet UIView *patientTopFaddingView;
@property (nonatomic ,retain)  IBOutlet UIView *patientBottomFaddingView;
@property (retain) NSString *responseStr;
@property(nonatomic,retain)  NSMutableArray *objectsID;
@property(nonatomic,retain)  NSMutableArray *PatientimageArray;
@property (nonatomic, retain) Reachability *internetReach;
@property (nonatomic, retain) Reachability *hostReach;
//Defining the delegate for this controller
@property (retain) id<specialtyViewControllerDelegate> delegate;
//Assigning the property for the outlet tableview object
@property (nonatomic, retain) IBOutlet UITableView *specialtyTableView;
//Assinging the property for the Topic array object
@property (nonatomic, retain) NSMutableArray *welvu_specialtyModels;
//Topics header and footer fading view object
//Fade effect
@property (nonatomic, retain) UIColor* fadeColor;
@property (nonatomic, retain) UIColor* baseColor;
@property (nonatomic, retain) UIView* topFadingView;
@property (nonatomic, retain) UIView* bottomFadingView;
@property (nonatomic, retain) UIView *selectionView;
@property (nonatomic, retain) IBOutlet UILabel *loading;
@property (nonatomic, retain) CAGradientLayer *g1;
@property (nonatomic, retain) CAGradientLayer *g2;
@property (nonatomic, retain) CAGradientLayer *g3;
@property (nonatomic, retain) CAGradientLayer *g4;
@property (nonatomic, retain) CAGradientLayer *g9;
@property(nonatomic,assign)int update;
@property(nonatomic,assign)int orgCount;
@property (nonatomic, assign) fade_orientation fadeOrientation;
@property (retain) NSSet *productIdentifiers;
@property (retain) NSArray * products;
@property (retain) NSMutableSet *purchasedProducts;
@property (retain) SKProductsRequest *request;
@property (retain) NSString *oemrToken;
@property (nonatomic, retain) ProcessingSpinnerView *spinner;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinnerEMR;

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@property (nonatomic ,readwrite) NSInteger totalSpcltySze;
@property (nonatomic ,readwrite) float totalDownldPercent;
@property (nonatomic, retain)  IBOutlet M13ProgressViewRing *ringprogressView;
//Methods
- (void)orientationChanged:(NSNotification *)notification;

//Action methods
-(IBAction)settingBtnClicked:(id)sender;
-(IBAction)dontShowAgainBtnClicked:(id)sender;
-(IBAction)helpContinueBtnClicked:(id)sender;
-(IBAction)helpBtnClicked:(id)sender;
-(IBAction)syncSpecialty:(id)sender;
//inapppurchase
-(IBAction)rateNow:(id)sender;
-(IBAction)goToSpecialty:(id)sender;
//oemr
- (void) cacheImage: (NSString *) ImageURLString;
- (UIImage *) getCachedImage: (NSString *) ImageURLString;
-(IBAction)backBtnClicked:(id)sender;
-(NSDate *)dateWithOutTime:(NSDate *)datDate;
-(void)checkAlertForOrgUser;
-(void)loadPatientVU;
@end
