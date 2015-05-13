//
//  welvuIPXViewController.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 19/10/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <BoxSDK/BoxSDK.h>
#import "GMGridView.h"
#import "welvuDetailViewControllerIpad.h"

#import "ProcessingSpinnerView.h"

#import "welvuAppDelegate.h"
#import "welvu_ipx_images.h"
#import "welvuSaveIpxViewController.h"
#import "Reachability.h"
#import "CustomPullToRefresh.h"
#import "EGORefreshTableHeaderView.h"
#import "welvu_ipx_topics.h"

/*
 * Protocol name: welvuIPXViewControllerDelegate
 * Description: Delegate function for returning welvu iPx
 */

@protocol welvuIPXViewControllerDelegate
-(void)welvuIPXDidFinish:(BOOL)isModified;
-(void)welvuLoginCompletedWithAccessToken;
-(void)userLoggedOutFromIpxViewController;


@end

/*
 * Class name: welvuIPXViewController
 * Description: Has functionality to list iPx videos
 * Extends: UIViewController
 * Delegate :UIAlertViewDelegate,
 UIPopoverControllerDelegate, syncContentToPlatformHelperDelegate,
 welvuShareViewDelegate
 */

@interface welvuIPXViewController : UIViewController <welvuShareViewDelegate ,syncContentToPlatformHelperDelegate ,welvuSaveIpxViewControllerDelegate   ,UIGestureRecognizerDelegate ,UITextFieldDelegate ,UIGestureRecognizerDelegate ,CustomPullToRefreshDelegate ,EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource> {
    MPMoviePlayerController * moviePlayerController11;
    CustomPullToRefresh *_ptr;
    CustomPullToRefresh *_ptrMyVideos;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    //Defining the delegate for this controller
    id<welvuIPXViewControllerDelegate> delegate;
    IBOutlet UIView *previewVUContents;
    IBOutlet UIView *previewVUContentParent;
    welvuAppDelegate *appDelegate;
    //GMGridView
    __gm_weak GMGridView *rightIPXGMGridView;
    __gm_weak  GMGridView *myVideosGMGridView;
    __gm_weak GMGridView *sharedVideoGMGridView;
    __gm_weak GMGridView *libraryVideoGMGridView;
    IBOutlet UIView *ipxvideoview;
    NSMutableArray *_rightcurrentData ;
    NSString *titleipx;
    NSString *descriptionipx;
    NSString *ipx_id;
    NSInteger offset;
    welvuDetailViewControllerIpad *detailViewController;
    //Downloading text
    ProcessingSpinnerView *spinner;
    GMGridView *patientVuGMGrid;
    GMGridView *patientVuGMGrid1;
    MPMoviePlayerController *moviePlayerController;
    BOOL isSelected;
    IBOutlet UIButton *shareBtn;
    IBOutlet UILabel *displayLabelXib;
    IBOutlet UILabel *displayDescriptionXib;
    NSMutableArray *title;
    NSMutableArray *description;
    NSMutableArray *videoid;
    NSString *bundlePath;
    NSData *imageData;
    IBOutlet UIView *PatientIpxView;
    UITableView *libTopicTbl;
    UIView *libTaleView;
    int update;
    IBOutlet UIImageView *ipxRightBanner;
    UILabel * notificationLable;
    IBOutlet UIImageView *themeLogo;
    IBOutlet UIButton *teamBtn;
    GMGridView *sharedVideoView;
    IBOutlet UIButton *myVideosBtn;
    IBOutlet UIButton *sharedVideosBtn;
    IBOutlet UIButton *videoLibraryBtn;
    IBOutlet UILabel *noContentAvailable;
    IBOutlet UIImageView *noVideoContent;
    int mediaTab;
    UIRefreshControl *refreshControl;
    
    // CustomPullToRefresh *_ptr;
    UIView *overlay;
    NSMutableArray *org_VideoDetails;
    NSTimer *searchTimer;
    NSString *searchTextField;
    UITextField *searchText;
    UIImageView *searchImage;
    IBOutlet UIButton *deleteBtn;
    
    //Reachability
    BOOL isAlreadyCalled;
    BOOL networkReachable;
    Reachability *internetReach;
    Reachability *hostReach;
    UIImage *thumbnail ;
    NSString *imageThumbnailPath ;
    NSString *filePaths;
    
    //Fade effect
    IBOutlet UIView*  _topFadingView;
    IBOutlet UIView*  _bottomFadingView;
    IBOutlet UIView *right_LeftFadingView;
    IBOutlet UIView *right_RightFadingView;
    IBOutlet UIButton *deleteAll;
    IBOutlet UIButton *playAll;
    IBOutlet UIButton *removePreVUcontents;
    NSString *videoidipx;
    
    //oauth
    NSURLConnection *deleteIpx;
    NSURLConnection *addOrganizationIpx;
     NSURLConnection *getOrganizationIpx;
    NSURLConnection *getLibraryIpx;
    NSURLConnection *getLibraryIpxTopicList;
    

     UIBackgroundTaskIdentifier *bti;
     NSString *responseStr;
    NSString *responseStrIpxTps;
    NSUserDefaults * defaultsTopics;

      NSUserDefaults * defaults;
  NSURLConnection *deleteOrganizationIpx;
    NSMutableArray *libcurrentTopicIpx;
   
}
@property (nonatomic ,retain) UITableView *libTopicTbl;
@property (nonatomic ,retain) UIView *libTaleView;
@property (retain) NSString *responseStr;
@property (retain) NSString *responseStrIpxTps;
@property (nonatomic ,retain)  NSString *videoidipx;
@property (nonatomic ,retain) IBOutlet UIButton *deleteAll;
@property (nonatomic ,retain) CustomPullToRefresh *_ptrMyVideos;
//Property for the delegate objects
@property (nonatomic,readonly)  NSInteger offset;
@property (nonatomic ,retain) IBOutlet UIView *right_LeftFadingView;
@property (nonatomic ,retain) IBOutlet UIView *right_RightFadingView;
//Fade effect
@property (nonatomic, retain) UIView* topFadingView;
@property (nonatomic, retain) UIView* bottomFadingView;
@property (nonatomic, retain) Reachability *internetReach;
@property (nonatomic, retain) Reachability *hostReach;
@property (nonatomic ,retain)  IBOutlet UIButton *deleteBtn;
@property (nonatomic,retain) UIImageView *searchImage;
@property (nonatomic,retain)  UITextField *searchText;
@property (nonatomic ,retain) NSString *searchTextField;
@property (nonatomic ,retain) NSTimer *searchTimer;
@property (nonatomic ,retain) UIRefreshControl *refreshControl;
@property (nonatomic ,retain) IBOutlet UIButton *myVideosBtn;
@property (nonatomic ,retain) IBOutlet UIButton *sharedVideosBtn;
@property (nonatomic ,retain) IBOutlet UIButton *videoLibraryBtn;

@property (nonatomic ,retain) IBOutlet UISearchBar *searchSelectedVideo;
@property (nonatomic ,retain) IBOutlet UIButton *teamBtn;
@property (nonatomic,retain) IBOutlet UIImageView *themeLogo;
@property (nonatomic ,retain) IBOutlet UIImageView *ipxRightBanner;

@property (nonatomic ,retain) NSData *imageData;
@property (nonatomic ,retain) NSString *bundlePath;
@property (nonatomic,retain) NSMutableArray *title;
@property (nonatomic,retain) NSMutableArray *description;
@property (nonatomic,retain) NSMutableArray *videoid;
//ipx
@property (nonatomic ,retain)IBOutlet UILabel *displayLabelXib;
@property (nonatomic ,retain)  IBOutlet UILabel *displayDescriptionXib;
@property (nonatomic,assign) int update;
@property (nonatomic ,retain) NSString *titleipx;
@property (nonatomic ,retain)  NSString *descriptionipx;
@property (nonatomic ,retain)   NSString *ipx_id;
@property (nonatomic,readwrite)  BOOL isSelected;
@property (nonatomic ,retain)   NSMutableArray *_rightcurrentData ;
@property (nonatomic ,retain)  MPMoviePlayerController *moviePlayerController;
@property (nonatomic ,retain) IBOutlet UIView *ipxvideoview;
@property (nonatomic ,retain) IBOutlet UILabel *noContentAvailable;
@property (nonatomic ,retain) IBOutlet UIImageView *noVideoContent;
@property (nonatomic ,retain) IBOutlet UIButton *removePreVUcontents;
//Assigining property for delegate methods
@property (nonatomic ,retain)  id<welvuIPXViewControllerDelegate> delegate;
@property (nonatomic, weak) GMGridView *rightIPXGMGridView;
@property (nonatomic, weak)  GMGridView *myVideosGMGridView;
@property (nonatomic, weak)  GMGridView *sharedVideoGMGridView;
@property (nonatomic, weak)  GMGridView *libraryVideoGMGridView;
@property (nonatomic ,retain) NSMutableArray *libcurrentTopicIpx ;

//Action methods
-(IBAction)backBtnClicked:(id)sender;
-(void)intializeGMGridViews;
- (void)intializeVideoPreviewContent ;
-(void)startPlatformData;
- (void)setPreviewImageInView:(NSInteger )position;
-(IBAction)shareBtnClicked:(id)sender;
- (void) unselectPreviousSelectedImage;
-(NSInteger) searchImageGroups:(NSInteger) imgId:(NSMutableArray *) imagesArray;
-(IBAction)cancelBtnClicked:(id)sender;
-(void)shareiPxData ;
- (void)themeSettingsViewControllerDidFinish;
-(IBAction)syncBtnClicked:(id)sender;
-(IBAction)myVideosBtnClicked:(id)sender;
-(IBAction)sharedVideosBtnClicked:(id)sender;
-(IBAction)videoLibraryBtnClicked:(id)sender;
-(IBAction)teamShareBtnClicked:(id)sender;
-(IBAction)informationBtnClicked:(id)sender;
//pulltorefresh
- (void) endSearch;
-(IBAction)deleteBtnClciked:(id)sender;
-(IBAction)clearAllBtnClicked:(id)sender;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
-(void)getSharedVideosFromPlatform:(NSInteger)offsetVideo :(NSString *)lastVideoId :(NSString *)searchTextField;
-(IBAction)playiPxBtnClicked:(id)sender;
-(IBAction)playalliPxBtnClicked:(id)sender;
- (NSMutableURLRequest *) POSTRequestWithURL:(NSURL *)url andDataDictionary:(NSDictionary *) message_data
                              attachmentData:(NSData *) attachment_data attachmentType:(NSString *) attachment_type
                          attachmentFileName:(NSString *) attachment_fileName;
@end
