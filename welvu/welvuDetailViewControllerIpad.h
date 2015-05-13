//
//  welvuDetailViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 15/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <BoxSDK/BoxSDK.h>
#import "GMGridView.h"
#import "welvu_images.h"
#import "welvuVideoMakerViewController.h"
#import "ELCImagePickerController.h"
#import "JSTokenField.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SyncDataToCloud.h"

//EMR
#import <ShinobiCharts/ShinobiChart.h>
#import "WeightsHeights.h"
#import "Datasource.h"
#import <OpenGLES/EAGLDrawable.h>

#import "welvu_patient_Doc.h"
#import "ShinobiChart+LineChart.h"
#import "ShinobiChart+Screenshot.h"
#import "SChartGLView+Screenshot.h"
#import <QuartzCore/QuartzCore.h>
#import <ShinobiCharts/SChartCanvas.h>
#import "ShinobiGetValue.h"
#import "Reachability.h"

#import "BoxNavigationController.h"
#import "BoxAuthorizationNavigationController.h"
#import "KeychainItemWrapper.h"

@class welvuMasterViewController;
/*
 * Class name: welvuDetailViewControllerIpad
 * Description: to show prevu image and video content
 * Extends: UIViewController
 *Delegate : UIScrollViewDelegate,UIImagePickerControllerDelegate,     UISplitViewControllerDelegate, UIAlertViewDelegate
 */
@interface welvuDetailViewControllerIpad : UIViewController <UISplitViewControllerDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate,
UIPopoverControllerDelegate, UIAlertViewDelegate, MKMapViewDelegate,CLLocationManagerDelegate,
welvuVideoMakerViewControllerDelegate, ELCImagePickerControllerDelegate, UIScrollViewDelegate,JSTokenFieldDelegate,
syncContentToPlatformHelperDelegate,SChartData,SChartDatasource,SChartDelegate,
BoxFolderPickerDelegate > {
    
    welvuAppDelegate *appDelegate;
    
    //Dataobtained from parent view
    BOOL retainPatientVU;
    
    NSMutableArray *patientVUImages;
    IBOutlet UIImageView *themeLogo;
    
   IBOutlet UILabel *notificationLable;
    //GMGridView
    GMGridView *patientVuGMGridView;
    
    //Locally generated variable
    UIImageView *previewVUContent;
    MPMoviePlayerController *moviePlayerController;
    IBOutlet UIView *previewVUContents;
    
    //Camera & Album
    UIImagePickerController *picker;
    UIPopoverController *popover;
    IBOutlet UIButton *patientVU;
    IBOutlet UIButton *blackcolor;
    
    //Label for help message
    IBOutlet UILabel *helpMessageLabel;
    
    //View history view
    IBOutlet UIView *historyView;
    IBOutlet UILabel *historyLabel;
    
    //Bar button
    IBOutlet UIButton *deleteVUBtn;
    IBOutlet UIButton *clearAll;
    IBOutlet UIButton *selectAllBtn;
    IBOutlet UIButton *photoBtn;
    IBOutlet UIButton *cameraBtn;
    IBOutlet UIButton *saveBtn;
    IBOutlet UIButton *boxBtn;
    //Information view
    UIView *overlay;
    
    //Fade effect
    IBOutlet UIView*  _topFadingView;
    IBOutlet UIView*  _bottomFadingView;
    
    //token
    NSMutableString *getContentValue;
    
	NSMutableArray *_toGetTagName;
    IBOutlet UILabel *tagLabel;
	IBOutlet UIScrollView *scrol;
	JSTokenField *_toTokenfield;
    NSInteger albumAddedCount;
    BOOL createtag;
    
    CGPoint fromPoint;
    CGPoint toPoint;
    
    //Hold cg points for annotate text view
    CGPoint startpoint;
    CGPoint newPoint;
    
    //Current Topic ID
    NSInteger currentOpenedTopicId;
    
    CGContextRef *theContext;
    BOOL animationDone;
    IBOutlet UIImageView *imageToMove;
    IBOutlet UIImageView *imageToMove2;
    IBOutlet UIView *myView;
    
    IBOutlet UIImageView *animatedButton;
    BOOL isAnimationStarted;
    
    //EMR
       UIView *patientInfoView;
        UIImage *PinfoSnapshot;
    ShinobiChart *lineChart;
    NSInteger userCreatedTopicID;
    
    //Shinobi Charts
   
    Datasource *datasource;
    WeightsHeights *mobileBrowserUsageStats;
    
    UIImageView *snapShot;
     UIView *patientgraphView;
    IBOutlet UIButton *snapBtn;
    IBOutlet UIButton *bpsBtn;
    IBOutlet UIButton *bpdBtn;
    
    IBOutlet UIButton *btnSelect;
    IBOutlet UIView *graphTitle;
    IBOutlet UIView *graphLegends;
    UITableView *emrVitalstable;
    IBOutlet UIButton *graphSeriesList;
    IBOutlet UIView *seriesListView;
    //DropDown
    
    //shinobi charts
    NSString *weightMaxValue;
    NSString *weightMinValue;
    NSMutableArray *weightArray;
    
    //vital selector
    IBOutlet UIImageView *image_Wealth;
    IBOutlet UIImageView *image_Health;
    IBOutlet UIImageView *image_Temperature;
    IBOutlet UIImageView *image_Bps;
    IBOutlet UIImageView *image_Bpd;
    IBOutlet UIImageView *image_Bmi;
    
    IBOutlet UIButton *weight_button;
    IBOutlet UIButton *height_button;
    
    IBOutlet UILabel *dynamicChartView;
    IBOutlet UIButton *ipxBtn;
    
    //vital settings
    IBOutlet UILabel *weightText;
    IBOutlet UILabel *temperatureText;
    IBOutlet UILabel *heightText;
    
    //Reachability
    BOOL isAlreadyCalled;
    BOOL networkReachable;
    Reachability *internetReach;
    Reachability *hostReach;
    ProcessingSpinnerView *spinner;
    
    //Map Integration
    MKMapView *mapView;
    IBOutlet UISearchBar *ibSearchBar;
    IBOutlet UIButton *mapVUBtn;
    CLLocationManager *locationManager;
    BOOL isLocationEnabled;

}
@property (nonatomic ,readwrite)     NSInteger userCreatedTopicID;
@property (nonatomic, retain) Reachability *internetReach;
@property (nonatomic, retain) Reachability *hostReach;

@property(nonatomic,assign)  BOOL createtag;

@property (strong, nonatomic) welvuMasterViewController *masterViewController;

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) IBOutlet UIImageView *themeLogo;
@property (nonatomic, retain)  UILabel *notificationLable;
@property (nonatomic, readwrite) BOOL retainPatientVU;

@property (nonatomic, retain) NSMutableArray *patientVUImages;
@property (nonatomic, retain) GMGridView *patientVuGMGridView;


//Fade effect
@property (nonatomic, retain) UIView* topFadingView;
@property (nonatomic, retain) UIView* bottomFadingView;
//EMR
@property (nonatomic, retain) UIImage *PinfoSnapshot;

@property (nonatomic, retain) ProcessingSpinnerView *spinner;



-(void) intializeSettings;
-(void) clearPatientVuSelections;
-(void) orientationChanged:(NSNotification *)notification;
-(void) addVUContentToPatientVU:(welvu_images *) welvu_imgesModel:(CGPoint)droppedPosition;
-(void) addAllTopicVUContentToPatientVU:(NSMutableArray *) welvu_imgesModels;
-(void) removeVUContentFromPatientVU:(welvu_images *) welvu_imgesModel;
-(void) loadPatientVuFromHistory:(NSInteger) historyNumber;
-(void) unselectPreviousSelectedImage ;
-(UIImage *) getThumbnail:(welvu_images *) welvu_imagesModel;
-(void) setPreviewImageInView:(welvu_images *) welvu_imagesModel;
-(UIImage *) generateImageFromVideo:(NSString *) pathString:(NSString *)pathType;

//STM
-(void)setCurrentTopicId:(NSInteger) topicId;

//Action Methods
-(IBAction) deleteSelectedBtnOnClicked:(id)sender;
-(IBAction) clearAllBtnOnClicked:(id)sender;
-(IBAction) albumButtonClicked:(id)sender;
-(IBAction) camButtonClicked:(id)sender;
-(IBAction) saveAsTopicBtnClicked:(id)sender;
-(IBAction) createVUBtnClicked:(id)sender;
-(IBAction) informationBtnClicked:(id)sender;
-(IBAction) closeOverlay:(id)sender;
-(IBAction) boxBtnClicked:(id)sender;
-(IBAction) selectAllBtnClicked:(id)sender;
-(IBAction) mapScreenShotBtnClicked:(id)sender;
-(IBAction) showMapView:(id)sender;
-(IBAction) blankEditBtnClicked:(id)sender;
//EMR
- (void)themeSettingsViewControllerDidFinish;
- (void) intializePatientInfoContent;
- (void) removePatientInfoContent;
- (void) showGraphView;
-(IBAction) buttonPressed:(id)sender;
-(IBAction) graphOpenGLSnapshot:(id)sender;

//IPX
-(IBAction)GetIpxBtnClicked:(id)sender;
-(void)welvuIPXDidFinish:(BOOL)completed;
- (void)setPreviewImageInViewinnstimer:(welvu_images *)welvu_imagesModel;


#pragma mark - Box api
@property (nonatomic, readwrite, strong) BoxFolderPickerViewController *folderPicker;
@property (nonatomic, readwrite, weak) BoxSDK *sdk;
@property (nonatomic, readwrite, strong) KeychainItemWrapper *keychain;

- (void)presentBoxFolderPicker;
- (void)boxError:(NSError*)error;
@end
