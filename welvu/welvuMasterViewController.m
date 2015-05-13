
//
//  welvuMasterViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 15/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvuMasterViewController.h"
#import "welvuTopicVUviewController.h"
#import "welvuDetailViewControllerIpad.h"
#import "welvuRegistrationViewController.h"
#import "welvuTopicVUCell.h"
#import "GMGridView.h"
#import "welvu_topics.h"
#import "welvu_images.h"
#import "welvu_history.h"
#import "welvu_alerts.h"
#import "welvu_organization.h"
#import "welvuSettingsMasterViewController.h"
#import "GAI.h"
#import "welvuTopicVUviewController.h"
#import "welvuTopicbutton.h"
#import "ProcessingSpinnerView.h"
#import "NSFileManagerDoNotBackup.h"
#import "SyncDataToCloud.h"
#import "Guid.h"
#import "welvu_sync.h"
//EMR
#import "GMGridViewLayoutStrategies.h"
#import "welvu_patient_Doc.h"
#import "UIImage+Resize.h"
#import "BoxNavigationController.h"
#import "PathHandler.h"
#import "welvuOrganizationViewController.h"


@interface welvuMasterViewController ()
-(NSInteger) searchTopicById:(NSInteger) topic_id:(NSMutableArray *) topcicArray;
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)configureCellSelectedCountBackgroud:(NSIndexPath *)indexPath;
-(void)intializeGMGridViews;

@end
NSInteger _lastDeleteItemIndexAsked;
CGPoint droppedPositon;
@implementation welvuMasterViewController
@synthesize topicTableView, detailViewController, previousSelectedTopicId;
@synthesize welvu_topicsModels;
@synthesize fadeColor = fadeColor_;
@synthesize baseColor = baseColor_;
@synthesize myScroll;
@synthesize topFadingView = _topFadingView;
@synthesize bottomFadingView = _bottomFadingView;
@synthesize scrolViewGenerated,update;
@synthesize g1 = g1_;
@synthesize g2 = g2_;
@synthesize delegate;
@synthesize fadeOrientation = fadeOrientation_;
@synthesize accordion;
@synthesize spinner;
//EMR
@synthesize eMRContainer ,specialtyContainer ,backButton ,patientInfo ,gridViewGenerated;
BOOL firstCalled = true;

@synthesize getTopicCount,tetTopicCount ,welvuSpecialty;

/*
 * Method name: initWithNibName
 * Description: initlizing the nib file and tool bar
 * Parameters: bundle
 * return self
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Topics", @"Topics");
        //self.tableView.clearsSelectionOnViewWillAppear = NO;
        [self.navigationController setNavigationBarHidden:YES];
        //self.contentSizeForViewInPopover = CGSizeMake(293.0, 768.0);
        self.fadeOrientation = FADE_TOPNBOTTOM;
        //r: 244 g: 172 b:36
        self.baseColor = BASE_COLOR;
        previousSelectedTopicId = 0;
        
        UIToolbar* toolbar = [[UIToolbar alloc]
                              initWithFrame:CGRectMake(0, 0, 50, 44)];
        
        // create an array for the buttons
        NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:1];
        
        UIBarButtonItem *specialtyVU = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(specialtyBtnClicked:)];
        [buttons addObject:specialtyVU];
        
        
        [toolbar setItems:buttons animated:NO];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithCustomView:toolbar];
        
        UIToolbar* toolbarRight = [[UIToolbar alloc]
                                   initWithFrame:CGRectMake(0, 0, 130, 44)];
        
        
        // create an array for the buttons
        NSMutableArray* buttonsRight = [[NSMutableArray alloc] initWithCapacity:3];
        
        reviewBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"archieveout.png"]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(reviewTopicBtnClicked:)];
        
        [buttonsRight addObject:reviewBtn];
        
        
        historyVUBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hxIcon.png"]
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(historyBtnClicked:)];
        [buttonsRight addObject:historyVUBtn];
        
        UIBarButtonItem *settingsBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(settingBtnClicked:)];
        [buttonsRight addObject:settingsBtn];
        
        [toolbarRight setItems:buttonsRight animated:NO];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithCustomView:toolbarRight];
        
        
    }
    return self;
}


//Sets fadeColor to be 10% alpha of baseColor
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
//intialize the settings for the master view controller
-(void) intializeWithSettings {
    //patient gmview reload data.
    

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_OPENEMR]||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_INTERSYSTEM]) {
        [self.oemrPatientGMGridView reloadData];
    }
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    [self.detailViewController themeSettingsViewControllerDidFinish];
    //Order settings
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    switch (((welvu_settings *)appDelegate.currentWelvuSettings).welvu_topic_list_order) {
        case SETTINGS_ALBHABITICAL_ORDER: {
            welvu_topicsModels = [welvu_topics getAllTopicsByAlphabeticalOrder:appDelegate.getDBPath:appDelegate.specialtyId
                                                                        userId:appDelegate.welvu_userModel.welvu_user_id];
            
      /*  int orgCount = [welvu_user getOrgUserCount:[appDelegate getDBPath] :appDelegate.welvu_userModel.welvu_user_id];
            
            NSLog(@"org count %d",orgCount);
            NSLog(@"useri d %d" ,appDelegate.welvu_userModel.welvu_user_id);
            
            if(orgCount > 0) {
                welvu_topicsModels = [welvu_topics getAllTopicsByAlphabeticalOrder:appDelegate.getDBPath:appDelegate.specialtyId
                                                                            userId:appDelegate.welvu_userModel.welvu_user_id];
                
            } else {
                welvu_topicsModels = [welvu_topics getAllTopicsByAlphabeticalOrderWithOutOrg:appDelegate.getDBPath :appDelegate.specialtyId userId:appDelegate.welvu_userModel.welvu_user_id];
            }*/
           
            
        }
            break;
        case SETTINGS_MOST_POPULAR_ORDER: {
            welvu_topicsModels = [welvu_topics getAllTopicsByMostPopularOrder:appDelegate.getDBPath:appDelegate.specialtyId
                                   userId:appDelegate.welvu_userModel.welvu_user_id];
        }
            
            break;
        case SETTINGS_MOST_DEFAULT_ORDER: {
            welvu_topicsModels = [welvu_topics getAllTopicsByDefaultOrder:appDelegate.getDBPath :appDelegate.specialtyId userId:appDelegate.welvu_userModel.welvu_user_id];
        }
        default:
            break;
    }
}
//Search topics by topics id
-(NSInteger) searchTopicById:(NSInteger) topic_id:(NSMutableArray *) topcicArray {
    
    for(int i=0; i < topcicArray.count; i++) {
        welvu_topics *topics = [topcicArray objectAtIndex:i];
        if(topics.topicId == topic_id) {
            return i;
        }
    }
    return -1;
}
// get image count for the selected topic id
-(NSInteger) getSelectedContentCount:(NSInteger) topic_id:(NSMutableArray *) vuContentArray {
    NSInteger contentSelectedCount = 0;
    for(int i=0; i < vuContentArray.count; i++) {
        welvu_images *welvu_imagesModel = [vuContentArray objectAtIndex:i];
        if(welvu_imagesModel.topicId == topic_id) {
            contentSelectedCount++;
        }
    }
    return contentSelectedCount;
}

#pragma mark -view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    topicListGenerated = false;
    //declaring Page View Analytics
        [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Master VU - MV"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [self startUpViewController];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LeftPanelWithBanner.png"]];
    
    /*[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];*/
    
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    /*self.g1.frame = self.topFadingView.frame;
     self.g2.frame = self.topFadingView.frame;lock
     [self.topFadingView.layer insertSublayer:self.g1 atIndex:0];
     [self.bottomFadingView.layer insertSublayer:self.g2 atIndex:0];*/
    self.topFadingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TopArrowWithBg.png"]];
    self.bottomFadingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"DownArrowWithBg.png"]];
    self.topFadingView.hidden = true;
    self.bottomFadingView.hidden = true;
    
    
    
    reviewBtn.enabled = FALSE;
    historyVUBtn.enabled = FALSE;
    
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    NSInteger specialtyCount = [welvu_specialty getSpecialtyCount:[appDelegate getDBPath]
                                                           userId:appDelegate.welvu_userModel.welvu_user_id];
    
    if(appDelegate.welvu_userModel
       && ( appDelegate.welvu_userModel.access_token != nil  ||  [[NSUserDefaults standardUserDefaults] objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY] != nil)
       && specialtyCount > 0 ) {
        
        
        [self performSelector:@selector(showSpecialtyView:) withObject:nil];
    } else {
        [self performSelector:@selector(showRegistrationView:) withObject:nil];
    }
    [self addObserverToMaster];
    
    [self intializeGMGridViews];
    
    //EMR
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_BOX]) {
        syncTopicBtn.hidden = true;
    }
    [self removepatchinIos8];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    [self intializeWithSettings];
    
    if(!topicListGenerated && appDelegate.specialtyId > 0) {
        [self showAccordian];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [self removeObserverFromMaster];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewDidAppear:(BOOL)animated
{
    //Need refining still not the good solution
    [super viewDidAppear:animated];
    appDelegate.currentMasterScreen = INFORMATION_TOPIC_VU;
    
    
    
    if(topicTableView.contentSize.height > topicTableView.frame.size.height) {
        self.bottomFadingView.hidden = false;
    } else {
        self.bottomFadingView.hidden = true;
    }
    
    if([welvu_history getMaxHistoryNumber:appDelegate.getDBPath:appDelegate.specialtyId] > 0) {
        historyVUBtn.enabled = TRUE;
    } else {
        historyVUBtn.enabled = FALSE;
    }
    
    
}

#pragma mark Action Methods
/*
 
 * Method name: registrationBtnClicked
 * Description: navigate to registration view
 * Parameters: id
 * return nil
 */
-(IBAction)registrationBtnClicked:(id)sender {
    welvuRegistrationViewController *registrationViewCont = [[welvuRegistrationViewController alloc]initWithNibName:@"welvuRegistrationViewController" bundle:nil];
    registrationViewCont.modalPresentationStyle = UIModalPresentationFullScreen;
    //registrationViewCont.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    registrationViewCont.delegate = self;
    [self presentModalViewController:registrationViewCont animated:NO];
}
//get access token after login completed
-(void)welvuLoginCompletedWithAccessToken {
    
        
    
    [self dismissModalViewControllerAnimated:NO];
    

    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    
    [self performSelector:@selector(specialtyBtnClicked:)  withObject:nil];
   
  
}

/*
 * Created by Divya yadav on 27/09/12.
 */
/*
 * Method name: specialtyBtnClicked
 * Description: view the list of specialty in the table view
 * Parameters: id
 * return nil
 * Created On: 27/09/12.
 */
-(IBAction)specialtyBtnClicked:(id)sender {
    //declaring Event Tracking Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Master VU - MV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Master VU - MV"
                                                          action:@"Specialty Button - MV"
                                                           label:@"Specialty"
                                                           value:nil] build]];
    

    
    
    @try {
        
        self.detailViewController.notificationLable.hidden = YES;
               welvuSpecialtyViewController *specialtyViewCont = [[welvuSpecialtyViewController alloc]
                                                           initWithNibName:@"welvuSpecialtyViewController" bundle:nil];
        specialtyViewCont.modalPresentationStyle = UIModalPresentationFullScreen;
//specialtyViewCont.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        //specialtyViewCont.modalTransitionStyle = UIModalPresentationFullScreen;
        specialtyViewCont.delegate = self;
        [self presentModalViewController:specialtyViewCont animated:NO];
       
    }
    @catch (NSException *exception) {
       
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"MasterVU-MV_Specialty: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
    }
}

/*
 * Created by Divya yadav on 27/09/12.
 */
/*
 -(void)specialtyViewControllerDidFinish:(BOOL)isChanged {
 if(isChanged) {
 previousSelectedTopicId = 0;
 specialtyLabel.text =  [NSString stringWithFormat:@"%@VU",
 [welvu_specialty getSpecialtyNameById:appDelegate.getDBPath :appDelegate.specialtyId]];
 
 [self.detailViewController clearPatientVuSelections];
 topicListGenerated = false;
 //[self reloadTableData];
 }
 [self dismissModalViewControllerAnimated:YES];
 }
 */
//EMR
-(void)specialtyViewControllerDidFinish:(BOOL)isChanged {
    
    /* NSUserDefaults *standaradUserDefault = [NSUserDefaults standardUserDefaults];
     
     NSInteger row = [standaradUserDefault integerForKey:@"SelectedIndexRowValue"];
     
     
     NSLog(@"row %d" ,row);
     
     if(row =1) {
     
     [self loadVU];
     
     } else
     {
     
     }*/
    
    
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    NSString *patientID=[appDelegate.currentPatientInfo objectForKey:@"pid"];
   // NSLog(@"patient id %@",patientID);
    
    
    if(patientID == NULL) {
        
      //  NSLog(@"patient id null");
    } else {
      //  NSLog(@"patient id not null");
    }
    
    if (patientID == nil) {
        [specialtyContainer setFrame:CGRectMake(15, 59, 272, 700)];
        
        backButton.hidden = FALSE;
        eMRContainer.hidden = TRUE;
    } else {
        
        
        [self loadVU];
        
    }
    if(isChanged) {
        previousSelectedTopicId = 0;
        specialtyLabel.text =  [NSString stringWithFormat:@"%@VU",
                                [welvu_specialty getSpecialtyNameById:appDelegate.getDBPath
                                                                     :appDelegate.specialtyId
                                                               userId:appDelegate.welvu_userModel.welvu_user_id]];
        
        [self.detailViewController clearPatientVuSelections];
        patientInfo.enabled = YES;
        topicListGenerated = false;
        [self reloadTableData];
    }
    [self removepatchinIos8];
    [self.detailViewController themeSettingsViewControllerDidFinish];
    [self dismissModalViewControllerAnimated:YES];
}

-(void) topicDownloadFromBoxFinished:(BOOL)isChanged {
    
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    NSString *patientID=[appDelegate.currentPatientInfo objectForKey:@"pid"];
   // NSLog(@"patient id %@",patientID);
    
    
    if(patientID == NULL) {
        
       // NSLog(@"patient id null");
    } else {
       // NSLog(@"patient id not null");
    }
    
    if (patientID == nil) {
        [specialtyContainer setFrame:CGRectMake(15, 59, 272, 700)];
        
        backButton.hidden = FALSE;
        eMRContainer.hidden = TRUE;
    } else {
        
        
        [self loadVU];
        
    }
    if(isChanged) {
        previousSelectedTopicId = 0;
        specialtyLabel.text =  [NSString stringWithFormat:@"%@VU",
                                [welvu_specialty getSpecialtyNameById:appDelegate.getDBPath
                                                                     :appDelegate.specialtyId
                                                               userId:appDelegate.welvu_userModel.welvu_user_id]];
        
        [self.detailViewController clearPatientVuSelections];
        patientInfo.enabled = YES;
        topicListGenerated = false;
        [self reloadTableData];
        [self.detailViewController themeSettingsViewControllerDidFinish];
        [self dismissModalViewControllerAnimated:YES];
    }
    
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
}
-(void) topicDownloadFromBoxDidFinished:(BOOL)isChanged {
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
}
-(void)userLoggedOutFromSpecialtyViewController {
   
    [self dismissModalViewControllerAnimated:NO];
    [self logoutUser];
}
-(void)welvuOrganizationViewController {
    [self dismissModalViewControllerAnimated:NO];
    [self logoutUser];
}

-(void)userLoggedOutFromOrganizationViewController {
    
    [self dismissModalViewControllerAnimated:NO];
    [self logoutUser];
}
-(void)userSwitchFromSpecialtyViewController  {
    [self dismissModalViewControllerAnimated:NO];
    [self switchToWelvuUSer];
}
-(void)userLogOutFromRegistrationViewController {
    
    [self dismissModalViewControllerAnimated:NO];
    [self logoutUser];
}

//EMR

-(void)loadVU {
    eMRContainer.hidden = FALSE;
    
    [specialtyContainer setFrame:CGRectMake(15, 265, 272, 493)];
    backButton.hidden = TRUE;
    gridViewGenerated = TRUE;
    if(oEMRPatientImages == nil) {
        oEMRPatientImages = [[NSMutableArray alloc]init];
    }
    
    oEMRPatientImages = [welvu_patient_Doc getPatientImages:appDelegate.getDBPath];
    
   // NSLog(@"patient images %@",oEMRPatientImages);
    compPatientVUImages = [self.detailViewController patientVUImages];
    for (welvu_images *welvu_imagesModel in oEMRPatientImages ) {
        {
            
            if([self searchImageGroups:welvu_imagesModel.patientImageID :compPatientVUImages] > -1)
                
            {
                welvu_imagesModel.selected = TRUE;
            } else  {
                welvu_imagesModel.selected = FALSE;
            }
        }
        
        
        [self.oemrPatientGMGridView reloadData];
        
        
    }
   // NSLog(@"pimages %@", oEMRPatientImages);
}

-(IBAction)historyBtnClicked:(id)sender {
    //declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Master VU - MV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Master VU - MV"
                                                          action:@"historyBtnClicked"
                                                           label:@"historyviewed"
                                                           value:nil] build]];

    @try {
        
        welvuHistoryVUViewController *historyVUViewController = [[welvuHistoryVUViewController alloc]
                                                                 initWithNibName:@"welvuHistoryVUViewController" bundle:nil];
        historyVUViewController.delegate = self;
        [self.navigationController pushViewController:historyVUViewController animated:NO];
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"MasterVU_historyBtnClicked: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
-(void)historyVUSelectedNumber:(NSInteger)historyNumber {
    
    [self.detailViewController loadPatientVuFromHistory:historyNumber];
    [self refreshTableData];
}
-(void)reloadAccordianView {
    [self showAccordian];
}

#pragma  mark - Settings Controller
//Show the settings view
-(IBAction)settingBtnClicked:(id)sender {
    //declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Master VU - MV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Master VU - MV"
                                                          action:@"Settings Button - MV"
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
        NSString * description = [NSString stringWithFormat:@"MasterVU-MV_Settings: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];

        
    }
}
//After settings view did finish
-(void)settingsMasterViewControllerDidFinish {
    [self.detailViewController intializeSettings];
    [self.detailViewController themeSettingsViewControllerDidFinish];
    [self showAccordian];
    [self settingsUpdate];
    //[self dismissModalViewControllerAnimated:YES];
}
//Settings view did cancel and navigate here
-(void)settingsMasterViewControllerDidCancel {
    [self dismissModalViewControllerAnimated:YES];
}
//To logout user
- (void) logoutUser {
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
     appDelegate.welvu_userModel = nil;
    
    NSInteger specialtyCount = [welvu_specialty getSpecialtyCount:[appDelegate getDBPath]
                                                           userId:appDelegate.welvu_userModel.welvu_user_id];
    
    [self dismissModalViewControllerAnimated:NO];
    
    if(appDelegate.welvu_userModel
       && ( appDelegate.welvu_userModel.access_token != nil  ||  [[NSUserDefaults standardUserDefaults] objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY] != nil)
       && specialtyCount > 0 ) {
        [self performSelector:@selector(specialtyBtnClicked:) withObject:nil];
    } else {
        [self performSelector:@selector(registrationBtnClicked:) withObject:nil];
    }
  

    [self.detailViewController intializeSettings];
    [self.detailViewController themeSettingsViewControllerDidFinish];
    [self showAccordian];
    [self settingsUpdate];
}

//Here settings can be updated
-(void)settingsUpdate {
    [self reloadTableData];
    [self.videomaker assitanceguidence];
}


#pragma mark - Button actions
-(IBAction)reviewTopicBtnClicked:(id)sender {
    //declaring Event Tracking Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Master VU - MV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Master VU - MV"
                                                          action:@"Archive VU clicked"
                                                           label:@"archievein"
                                                           value:nil] build]];
    @try {
        
        welvuArchiveTopicController *welvuArchiveTopic = [[welvuArchiveTopicController alloc]
                                                          initWithNibName:@"welvuArchiveTopicController" bundle:nil];
        welvuArchiveTopic.delegate = self;
        [self.navigationController pushViewController:welvuArchiveTopic animated:NO];
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"MasterVU_reviewTopicBtnClicked: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];

        
        
    }
}

-(void)welvuArchiveForTopicDidFinish:(BOOL) isModified {
    if(isModified) {
        [self reloadTableData];
    }
}
/*
 * Method name: feedBackBtnClicked
 * Description: To  view the feedback page about the app
 * Parameters: id
 * return <#value#>
 */
-(IBAction)feedBackBtnClicked:(id)sender {
    //declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Master VU - MV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Master VU - MV"
                                                          action:@"Feedback Button - MV"
                                                           label:@"Feedback"
                                                           value:nil] build]];
    @try {
        
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:URL_FEEDBACK_FORM]];
        /* if ([MFMailComposeViewController canSendMail]) {
         MFMailComposeViewController *pickerMFMailComposer = [[[MFMailComposeViewController alloc] init] autorelease];
         pickerMFMailComposer.mailComposeDelegate = self;
         [pickerMFMailComposer setToRecipients:[NSArray arrayWithObject: MAIL_ID]];
         [self presentModalViewController:pickerMFMailComposer animated:YES];
         }else {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:"
         message:@"Your phone is not currently configured to send mail."
         delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
         
         [alert show];
         [alert release];
         }*/
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"MasterVU-MV_Feedback: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}/*
  * Method name: startSyncBtnClicked
  * Description: sync and get the topics from the platform
  * Parameters: id
  * return <#value#>
  */

-(IBAction)startSyncBtnClicked:(id)sender {
    
    //declaring Event Tracking Analytics
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];

    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Master VU - MV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Master VU - MV"
                                                          action:@"Sync - MV"
                                                           label:@"Sync"
                                                           value:nil] build]];
    @try {
        [appDelegate startSyncProcess];

        
      if(appDelegate.networkReachable) {
            //welvuSpecialty =[[welvuSpecialtyViewController alloc]init];
            //[welvuSpecialty syncSpecialty:nil];
           
            if(spinner == nil) {
                spinner = [ProcessingSpinnerView loadSpinnerIntoView:appDelegate.splitViewController.view :NSLocalizedString(@"SYNC_CONTENT_PROSESSING_TEXT", nil)];
            }
            
           [appDelegate startSyncProcess];
            
            
        } else {
            /// Create an alert if connection doesn't work
            UIAlertView *networkAlert = [[UIAlertView alloc]
                                         initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                         message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                         delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                         otherButtonTitles:nil];
            [networkAlert show];
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"MasterVU-MV_Sync: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];

        
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult
                             :(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissModalViewControllerAnimated:YES];
}
//Reload the table view data i:e topics
-(void) reloadTableData {
    welvu_topicsModels = nil;
    [self intializeWithSettings];
    //[self refreshTableData];
    
       [self showAccordian];
   // [self refreshTableData];
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
    
}

//Reload the table view data i:e topics
-(void) reloadAccordianTableData {
    welvu_topicsModels = nil;
    [self intializeWithSettings];
    [self showAccordian];

    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }

}

-(void) refreshTableData {
    
    [topicTableView reloadData];
    if([welvu_topicsModels count] > 0 && [self searchTopicById:previousSelectedTopicId
                                                              :welvu_topicsModels] > -1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow
                                  :[self searchTopicById:previousSelectedTopicId
                                                        :welvu_topicsModels] inSection:0];
        [self.topicTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    }
    
    if([welvu_topics getArchivedTopicsCount:appDelegate.getDBPath :appDelegate.specialtyId] > 0) {
        [reviewBtn setEnabled:TRUE];
    } else {
        [reviewBtn setEnabled:FALSE];
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(UIGestureRecognizerStateBegan == gestureRecognizer.state) {
       // NSLog(@"gesture begun");
        
        NSInteger myTag = [gestureRecognizer view].tag;
       // NSLog(@"mytag %d" ,myTag);
        NSString *gettopicName = ((welvu_topics *)[welvu_topicsModels objectAtIndex:myTag]).topicName;
       // NSLog(@"mytag %@" ,gettopicName);
        
        
        if(((welvu_topics *)[welvu_topicsModels objectAtIndex:myTag]).topic_is_user_created) {
            
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"ALERT_ARCHIVE_TOPIC_SPECIALTY_VU_TITLE", nil)
                                  message: [NSString stringWithFormat:NSLocalizedString(@"ALERT_DELETE_TOPIC_SPECIALTY_VU_MSG", nil),
                                            ((welvu_topics *)[welvu_topicsModels objectAtIndex:myTag]).topicName]
                                  delegate: self
                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                  otherButtonTitles:NSLocalizedString(@"DELETE", nil),nil];
            alert.tag = myTag;
            alert.delegate = self;
            [alert show];
            
         //   NSLog(@"user Created topic");
        } else {
         //   NSLog(@"inbuilt topic");
        }
        
        
        
        
        // Called on start of gesture, do work here
    }
    
    if(UIGestureRecognizerStateChanged == gestureRecognizer.state) {
       // NSLog(@"gesture changes");
        NSInteger myTag = [gestureRecognizer view].tag;
        //NSLog(@"mytag %d" ,myTag);
        NSString *gettopicName = ((welvu_topics *)[welvu_topicsModels objectAtIndex:myTag]).topicName;
        //NSLog(@"mytag %@" ,gettopicName);
        
        
        
        if(appDelegate.networkReachable) {
            if(((welvu_topics *)[welvu_topicsModels objectAtIndex:myTag]).topic_is_user_created) {
                
                
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: NSLocalizedString(@"ALERT_ARCHIVE_TOPIC_SPECIALTY_VU_TITLE", nil)
                                      message: [NSString stringWithFormat:NSLocalizedString(@"ALERT_DELETE_TOPIC_SPECIALTY_VU_MSG", nil),
                                                ((welvu_topics *)[welvu_topicsModels objectAtIndex:myTag]).topicName]
                                      delegate: self
                                      cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                      otherButtonTitles:NSLocalizedString(@"DELETE", nil),nil];
                alert.tag = myTag;
                alert.delegate = self;
                [alert show];
                
              //  NSLog(@"user Created topic");
            } else {
              //  NSLog(@"inbuilt topic");
            }
            
        }else {
            UIAlertView *myAlert = [[UIAlertView alloc]
                                    initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                    message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                    delegate:self
                                    cancelButtonTitle:@"Ok"
                                    otherButtonTitles:nil];
            [myAlert show];
        }
        
        
        // Called on start of gesture, do work here
    }
    
    if(UIGestureRecognizerStateEnded == gestureRecognizer.state) {
      //  NSLog(@"gesture ended");
        NSInteger myTag = [gestureRecognizer view].tag;
      //  NSLog(@"mytag %d" ,myTag);
        NSString *gettopicName = ((welvu_topics *)[welvu_topicsModels objectAtIndex:myTag]).topicName;
      //  NSLog(@"mytag %@" ,gettopicName);
        
        
        
        if(appDelegate.networkReachable) {
            if(((welvu_topics *)[welvu_topicsModels objectAtIndex:myTag]).topic_is_user_created) {
                
                
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: NSLocalizedString(@"ALERT_ARCHIVE_TOPIC_SPECIALTY_VU_TITLE", nil)
                                      message: [NSString stringWithFormat:NSLocalizedString(@"ALERT_DELETE_TOPIC_SPECIALTY_VU_MSG", nil),
                                                ((welvu_topics *)[welvu_topicsModels objectAtIndex:myTag]).topicName]
                                      delegate: self
                                      cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                      otherButtonTitles:NSLocalizedString(@"DELETE", nil),nil];
                alert.tag = myTag;
                alert.delegate = self;
                [alert show];
                
              //  NSLog(@"user Created topic");
            } else {
             //   NSLog(@"inbuilt topic");
            }
            
        }else {
            UIAlertView *myAlert = [[UIAlertView alloc]
                                    initWithTitle:NSLocalizedString(@"ALERT_STATUS_HEADER", nil)
                                    message:NSLocalizedString(@"ALERT_NO_INTERNET_CONNECTIVITY_NORMAL_MSG", nil)
                                    delegate:self
                                    cancelButtonTitle:@"Ok"
                                    otherButtonTitles:nil];
            [myAlert show];
        }
        
        
        // Called on start of gesture, do work here
    }
    
}




-(void)showPresentViewController:(UIViewController *)viewController{
    
    [self presentModalViewController:viewController animated:YES];
}

//Delegate method for topicvuview controller
-(void)topicVUViewControllerImageSelected:(welvu_images *)welvu_imagesModel {
    
    //[self.detailViewController addVUContentToPatientVU:welvu_imagesModel:CGPointZero];
    [self.detailViewController addVUContentToPatientVU:welvu_imagesModel :CGPointZero];
}

-(void)topicVUViewControllerImageSelectedWithPosition:(welvu_images *)welvu_imagesModel :(CGPoint)droppedPositon {
    [self.detailViewController addVUContentToPatientVU:welvu_imagesModel:droppedPositon];
}

-(void)topicVUViewControllerImageSelectedAll:(NSMutableArray *)welvu_imagesModels {
    [self.detailViewController addAllTopicVUContentToPatientVU:welvu_imagesModels];
}

-(void)topicVUViewControllerRemoveImageSelected:(welvu_images *)welvu_imagesModel {
    
    
    [self.detailViewController removeVUContentFromPatientVU:welvu_imagesModel];
}
-(void)refreshTopicContentCount1:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *topicId=[userInfo objectForKey:@"currentTopicId"];
    NSInteger headerIndex = [self searchTopicById:[topicId integerValue] :welvu_topicsModels];
    UIButton *topicHeaderBtn =  (UIButton *)[accordion.headers objectAtIndex:headerIndex];
    NSString *topicCount = [NSString stringWithFormat:@"%d",
                            [welvu_images getImageCount:appDelegate.getDBPath:
                             ((welvu_topics *)[welvu_topicsModels objectAtIndex:headerIndex]).topicId
                                                 userId:appDelegate.welvu_userModel.welvu_user_id]];
    for(UIView *view in [topicHeaderBtn subviews]) {
        if([view isKindOfClass:[UILabel class]] && view.tag == 2) {
            
            ((UILabel *)view).text = topicCount;
        }
        
    }
}
-(void)refreshTopicContentCount:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *topicId=[userInfo objectForKey:@"currentTopicId"];
    NSInteger headerIndex = [self searchTopicById:[topicId integerValue] :welvu_topicsModels];
    UIButton *topicHeaderBtn =  (UIButton *)[accordion.headers objectAtIndex:headerIndex];
    NSString *topicCount = [NSString stringWithFormat:@"%d",
                            [welvu_images getImageCount:appDelegate.getDBPath:
                             ((welvu_topics *)[welvu_topicsModels objectAtIndex:headerIndex]).topicId
                                                 userId:appDelegate.welvu_userModel.welvu_user_id]];
    for(UIView *view in [topicHeaderBtn subviews]) {
        if([view isKindOfClass:[UILabel class]] && view.tag == 2) {
            
            ((UILabel *)view).text = topicCount;
        }
        
    }
}

-(void)topicVuViewControllerRefreshTableData {
    [self refreshTableData];
}
//EMR Start
//remove image selection, wen images is removed from PreVU
//EMR End



-(void)clearedAllTopicSelected:(NSNotification *)notification {
    
    patientInfo.enabled = TRUE;
    for(welvu_topics *welvu_topicsModel in welvu_topicsModels) {
        welvu_topicsModel.total_selected_image_count = 0;
    }
    [topicTableView reloadData];
    if(previousSelectedTopicId  > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self searchTopicById:previousSelectedTopicId
                                                                                   :welvu_topicsModels] inSection:0];
        [self.topicTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
        [self configureCellSelectedCountBackgroud:indexPath];
    }
}

//Clear all images as border with images unselected in topic vu
-(void)clearedAllPatientVU:(NSNotification *)notification {
    patientInfo.enabled = YES;
    if([oEMRPatientImages count] > 0) {
        for(welvu_images *welvu_imagesModel in oEMRPatientImages) {
            if(welvu_imagesModel.selected) {
                NSInteger index = [self searchPatientImageGroups:welvu_imagesModel.imageId :oEMRPatientImages ];
                welvu_imagesModel.selected = NO;
                GMGridViewCell *cell = (GMGridViewCell *)[self.oemrPatientGMGridView cellForItemAtIndex:index];
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


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    welvuTopicVUCell *topicVUcell = (welvuTopicVUCell *)cell;
    
    UIView *selectionView = [[UIView alloc]initWithFrame:cell.bounds];
    [selectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SpecialityBg.png"]]];
    if(!((welvu_topics *)[welvu_topicsModels objectAtIndex:indexPath.row]).topic_is_user_created) {
        topicVUcell.topicLabel.font = [UIFont systemFontOfSize:14.0f];
    } else {
        topicVUcell.topicLabel.font = [UIFont italicSystemFontOfSize:14.0f];
    }
    topicVUcell.backgroundView = selectionView;
    //topicVUcell.selectedBackgroundView = selectionView;
    topicVUcell.topicLabel.text = ((welvu_topics *)[welvu_topicsModels objectAtIndex:indexPath.row]).topicName;
    topicVUcell.topicLabel.numberOfLines = 2;
    
    topicVUcell.tag = ((welvu_topics *)[welvu_topicsModels objectAtIndex:indexPath.row]).topicId;
    
    topicVUcell.topicImagesSelectedLabel.text = [NSString stringWithFormat:@"%d",
                                                 [welvu_images getImageCount:appDelegate.getDBPath:
                                                  ((welvu_topics *)[welvu_topicsModels objectAtIndex:indexPath.row]).topicId
                                                  userId:appDelegate.welvu_userModel.welvu_user_id]];
    topicVUcell.topicImagesSelectedLabel.backgroundColor = SELECTED_COLOR;
    


    
    ((welvu_topics *)[welvu_topicsModels
                      objectAtIndex:indexPath.row]).total_selected_image_count = [self getSelectedContentCount:
                                                                                  ((welvu_topics *)[welvu_topicsModels
                                                                                                    objectAtIndex:indexPath.row]).topicId:
                                                                                  self.detailViewController.patientVUImages];
    
    if( ((welvu_topics *)[welvu_topicsModels objectAtIndex:indexPath.row]).total_selected_image_count > 0) {
        //topicVUcell.topicImagesLabel.hidden = false;
        topicVUcell.topicImagesLabel.text = [NSString stringWithFormat:@"%d selected",
                                             ((welvu_topics *)[welvu_topicsModels objectAtIndex:indexPath.row]).total_selected_image_count];
        //topicVUcell.topicImagesSelectedLabel.backgroundColor = [UIColor lightGrayColor];
    } else {
        topicVUcell.topicImagesLabel.hidden = true;
        topicVUcell.topicImagesLabel.text = @"";
    }
}

-(void) configureCellSelectedCountBackgroud:(NSIndexPath *)indexPath {
    welvuTopicVUCell *topicVUcell = (welvuTopicVUCell *)[topicTableView cellForRowAtIndexPath:indexPath];
    UIView *selectionView = [[UIView alloc]initWithFrame:topicVUcell.bounds];
    //[selectionView setBackgroundColor:[UIColor colorWithRed:0.94f green:0.67f blue:0.14f alpha:1.0f]];
    [selectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SpecialityBg.png"]]];
    topicVUcell.backgroundView = selectionView;
    
        
    if( ((welvu_topics *)[welvu_topicsModels objectAtIndex:indexPath.row]).total_selected_image_count > 0) {
        topicVUcell.topicImagesLabel.text = [NSString stringWithFormat:@"%d selected",
                                             ((welvu_topics *)[welvu_topicsModels objectAtIndex:indexPath.row]).total_selected_image_count];
    } else {
        topicVUcell.topicImagesLabel.hidden = true;
        topicVUcell.topicImagesLabel.text = @"";
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [accordion.scrollView setScrollEnabled:TRUE];
}

- (void)accordionScrollViewDidScroll:(UIScrollView *)aScrollView {
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
}
#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_LOAD_TOPICVU_TO_PATIENTVU_TITLE", nil)]) {
        if (buttonIndex == 0) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self searchTopicById:previousSelectedTopicId
                                                                                       :welvu_topicsModels] inSection:0];
            [self.topicTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
        } else if (buttonIndex == 1 || buttonIndex == 2){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[alertView tag] inSection:0];
            [self.topicTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            welvu_topics *welvu_topicsModel = [welvu_topicsModels objectAtIndex:[alertView tag]];
            update = [welvu_topics updateTopicHitCounter:appDelegate.getDBPath
                                                        :welvu_topicsModel.topicId
                                                  userId:appDelegate.welvu_userModel.welvu_user_id];
            previousSelectedTopicId = welvu_topicsModel.topicId;
            if(buttonIndex == 1) {
                update = [welvu_alerts updateAlertConfirmation:appDelegate.getDBPath:ALERT_LOAD_TOPICVU_TO_PATIENTVU_TITLE];
            }
        }
    } else if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_ARCHIVE_TOPIC_SPECIALTY_VU_TITLE", nil)]) {
        if (buttonIndex == 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self searchTopicById:previousSelectedTopicId
                                                                                       :welvu_topicsModels] inSection:0];
            [self.topicTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        } else {
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
            
            
            if(((welvu_topics *)[welvu_topicsModels objectAtIndex:alertView.tag]).topicId > 0) {
                BOOL deleted = [welvu_images deleteImagesFromTopic:[appDelegate getDBPath]
                                                                  :((welvu_topics *)[welvu_topicsModels objectAtIndex:alertView.tag]).topicId
                                                            userId:appDelegate.welvu_userModel.welvu_user_id];
            }
            update = [welvu_topics deleteTopicWithTopicGUID:[appDelegate getDBPath]
                                                           :((welvu_topics *)[welvu_topicsModels objectAtIndex:alertView.tag]).topics_guid];
            
            
            BOOL inserted = [welvu_sync addSyncDetail:[appDelegate getDBPath]
                                                 guid:((welvu_topics *)[welvu_topicsModels objectAtIndex:alertView.tag]).topics_guid
                                             objectId:((welvu_topics *)[welvu_topicsModels objectAtIndex:alertView.tag]).topicId
                                             syncType:SYNC_TYPE_TOPIC_CONSTANT
                                           actionType:ACTION_TYPE_DELETE_CONSTANT];
            
            SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
            dataToCloud.delegate = self;
            [dataToCloud startSyncDeletedDataToCloud:SYNC_TYPE_TOPIC_CONSTANT
                                                guid:((welvu_topics *)[welvu_topicsModels objectAtIndex:alertView.tag]).topics_guid
                                          actionType:HTTP_REQUEST_ACTION_TYPE_DELETE actionURL:PLATFORM_SYNC_TOPICS];

            [self reloadAccordianTableData];
        }
        
    } else if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_LOAD_TOPIC_WHEN_IMAGE_FULLSCREEN_TITLE", nil)]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self searchTopicById:previousSelectedTopicId
                                                                                   :welvu_topicsModels] inSection:0];
        [self.topicTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    } else if(alertView.tag == 123){
        
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:URL_UPGRADE]];
            
        }
        
        
        
    }

    
   /* else if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_PURCHASE_SPECIALTY_TITLE", nil)]) {
        welvu_specialty *currentSpecialty = [welvu_specialty getSpecialtyById:[appDelegate getDBPath]
                                                                  specialtyId:appDelegate.specialtyId
                                                                       userId:appDelegate.welvu_userModel.welvu_user_id];
        if(buttonIndex==1)  {
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
                yearlySubscription = false;
                isAlreadyCalled = false;
                [self buyCredits];
            }
            
        } else if(buttonIndex == 2)  {
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
                yearlySubscription = true;
                isAlreadyCalled = false;
                [self buyCredits];
            }
            
        }
    } */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}




- (void)camButtonClickedVU:(NSNotification *)note {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && picker == nil)
    {
        picker = [[UIImagePickerController alloc] init];
        picker.title = @"camera";
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        picker.delegate = self;
        [self presentModalViewController:picker animated:YES];
    }
    // topicVuGMGridView.editing = NO;
    // preAnnotation.selected = FALSE;
}
- (void)imagePickerController:(UIImagePickerController *) Picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    int topicsId = ((welvu_topics *)[welvu_topicsModels objectAtIndex:accordion.selectedIndex]).topicId;
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTH_DATE_TIME_FILENAME_FORMAT];
    if ([mediaType isEqualToString:IMAGE_FILE_TYPE_CONST]){
        UIImage *anImage = [info valueForKey:UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImageJPEGRepresentation(anImage, 1.0);
        NSString *imageName = [dateFormatter stringFromDate:[NSDate date]];
        NSString  *pickedImagePath = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@.%@", DOCUMENT_DIRECTORY,imageName,
                                                                       HTTP_ATTACHMENT_IMAGE_EXT_KEY]];
        if([imageData writeToFile:pickedImagePath atomically:YES]){
            NSURL *outputURL = [NSURL fileURLWithPath:pickedImagePath];
            int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:outputURL];
            
            welvu_images *welvu_imagesModel = [[welvu_images alloc] init];
            welvu_imagesModel.topicId = topicsId;
            welvu_imagesModel.image_guid =  [[Guid randomGuid] description];
            welvu_imagesModel.imageDisplayName = imageName;
            welvu_imagesModel.orderNumber = ([welvu_images getMaxOrderNumber:appDelegate.getDBPath :topicsId
                                                                      userId:appDelegate.welvu_userModel.welvu_user_id] + 1);
            welvu_imagesModel.type = IMAGE_ALBUM_TYPE;
            welvu_imagesModel.url = [NSString stringWithFormat:@"%@.%@", imageName,
                                     HTTP_ATTACHMENT_IMAGE_EXT_KEY];
            welvu_imagesModel.image_guid =  [[Guid randomGuid] description];
            NSInteger imageId = [welvu_images addNewImageToTopic:appDelegate.getDBPath :welvu_imagesModel:topicsId];
            if(imageId > 0) {
                BOOL inserted = [welvu_sync addSyncDetail:[appDelegate getDBPath] guid:welvu_imagesModel.image_guid
                                                 objectId:imageId
                                                 syncType:SYNC_TYPE_CONTENT_CONSTANT
                                               actionType:ACTION_TYPE_CREATE_CONSTANT];
                [self welvuTopicVUAnnotationDidFinished:topicsId :imageId];
                SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
                [dataToCloud startSyncDataToCloud:SYNC_TYPE_CONTENT_CONSTANT objectId:imageId
                                       actionType:HTTP_REQUEST_ACTION_TYPE_CREATE
                                        actionURL:PLATFORM_SYNC_CONTENTS];
                [((welvuTopicVUviewController *)[accordion.views objectAtIndex:accordion.selectedIndex]) updateTopicContents:imageId];
            }
        }
    } else if ([mediaType isEqualToString:VIDEO_FILE_TYPE_CONST]){
        NSString *imageName = [dateFormatter stringFromDate:[NSDate date]];
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString  *pickedImagePath = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@.%@",
                                                                       DOCUMENT_DIRECTORY,imageName,
                                                                       HTTP_ATTACHMENT_VIDEO_EXT_KEY]];
        NSError *error;
        NSData *contentData = [[NSData alloc] initWithContentsOfURL:videoURL];
        int copied = [contentData writeToFile:pickedImagePath atomically:YES];
        int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:pickedImagePath]];
        welvu_images *welvu_imagesModel = [[welvu_images alloc] init];
        welvu_imagesModel.topicId = topicsId;
        welvu_imagesModel.image_guid =  [[Guid randomGuid] description];
        welvu_imagesModel.imageDisplayName = imageName;
        welvu_imagesModel.type = IMAGE_VIDEO_ALBUM_TYPE;
        welvu_imagesModel.url = [NSString stringWithFormat:@"%@.%@",
                                 imageName, HTTP_ATTACHMENT_VIDEO_EXT_KEY];
        welvu_imagesModel.orderNumber = ([welvu_images getMaxOrderNumber:appDelegate.getDBPath :topicsId
                                                                  userId:appDelegate.welvu_userModel.welvu_user_id] + 1);
        welvu_imagesModel.pickedToView = YES;
        
        NSInteger imageId = [welvu_images addNewImageToTopic:appDelegate.getDBPath :welvu_imagesModel:topicsId];
        if(imageId > 0) {
            BOOL inserted = [welvu_sync addSyncDetail:[appDelegate getDBPath] guid:welvu_imagesModel.image_guid
                                             objectId:imageId
                                             syncType:SYNC_TYPE_CONTENT_CONSTANT
                                           actionType:ACTION_TYPE_CREATE_CONSTANT];
            [((welvuTopicVUviewController *)[accordion.views objectAtIndex:accordion.selectedIndex]) updateTopicContents:imageId];
            SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
            [dataToCloud startSyncDataToCloud:SYNC_TYPE_CONTENT_CONSTANT objectId:imageId
                                   actionType:HTTP_REQUEST_ACTION_TYPE_CREATE actionURL:PLATFORM_SYNC_CONTENTS];
        }
    }
    [picker dismissModalViewControllerAnimated:YES];
    picker = nil;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    [picker dismissModalViewControllerAnimated:YES];
    picker = nil;
}

- (void)dismissVUFinishAnnotation:(NSNotification *)note {
    
    [self dismissModalViewControllerAnimated:YES];
}
//annotation  finish and image saved
-(void)welvuTopicVUAnnotationDidFinished:(NSInteger) topic_id:(NSInteger) image_id {
    //if(isModified) {
    NSInteger headerIndex = [self searchTopicById:topic_id :welvu_topicsModels];
    UIButton *topicHeaderBtn =  (UIButton *)[accordion.headers objectAtIndex:headerIndex];
    NSString *topicCount = [NSString stringWithFormat:@"%d",
                            [welvu_images getImageCount:appDelegate.getDBPath:
                             ((welvu_topics *)[welvu_topicsModels objectAtIndex:headerIndex]).topicId
                             userId:appDelegate.welvu_userModel.welvu_user_id]];
    for(UIView *view in [topicHeaderBtn subviews]) {
        if([view isKindOfClass:[UILabel class]] && view.tag == 2) {
            
            ((UILabel *)view).text = topicCount;
        }
        
    }
    // [((welvuTopicVUviewController *)[accordion.views objectAtIndex:[self searchTopicById:topic_id :welvu_topicsModels]]) editVUFinished:image_id];
    
    // }
    [self dismissModalViewControllerAnimated:YES];
    
}

-(void)userLoggedOutFromTopicVUAnnotation {
    [self dismissModalViewControllerAnimated:NO];
    [self logoutUser];
}


- (void)editVU:(NSNotification *)note {
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    NSDictionary *theData = [note userInfo];
    NSNumber *currentTopicId=[theData objectForKey:@"currentTopicId"];
    NSInteger imageId=[[theData objectForKey:@"imageId"] integerValue];
    welvu_images *welvu_imagesModel = [welvu_images  getImageById:[appDelegate getDBPath] :imageId
                                                           userId:appDelegate.welvu_userModel.welvu_user_id];
    
    if(welvu_imagesModel != nil && (![welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE]
       && ![welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_TYPE])) {
        
        welvuTopicVUAnnotationViewController *welvuTopicVUAnnotation =
        [[welvuTopicVUAnnotationViewController alloc]
         initWithSelectedImage:@"welvuTopicVUAnnotationViewController"
         bundle:nil
         currentTopicId:[currentTopicId integerValue]
         imagesId:imageId];
        
        welvuTopicVUAnnotation.delegate = self;
        welvuTopicVUAnnotation.modalPresentationStyle = UIModalPresentationFullScreen;
        welvuTopicVUAnnotation.modalTransitionStyle = UIModalTransitionStyleCoverVertical; //transition shouldn't matter
        
        [self presentModalViewController:welvuTopicVUAnnotation animated:YES];
    }
    welvu_imagesModel = nil;
}

-(void)welvuTopicVUAnnotationDidFinish:(NSInteger) topic_id:(NSInteger) image_id:(BOOL) isModified {
    if(isModified) {
        NSInteger headerIndex = [self searchTopicById:topic_id :welvu_topicsModels];
        UIButton *topicHeaderBtn =  (UIButton *)[accordion.headers objectAtIndex:headerIndex];
        NSString *topicCount = [NSString stringWithFormat:@"%d",
                                [welvu_images getImageCount:appDelegate.getDBPath:
                                 ((welvu_topics *)[welvu_topicsModels objectAtIndex:headerIndex]).topicId
                                 userId:appDelegate.welvu_userModel.welvu_user_id]];
        for(UIView *view in [topicHeaderBtn subviews]) {
            if([view isKindOfClass:[UILabel class]] && view.tag == 2) {
                
                ((UILabel *)view).text = topicCount;
            }
            
        }
        [((welvuTopicVUviewController *)[accordion.views objectAtIndex:[self searchTopicById:topic_id :welvu_topicsModels]]) editVUFinished:image_id];
        
    }
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)imageSelectedWithPositionFromVU:(NSNotification *)note {
    NSDictionary *theData = [note userInfo];
    [self.detailViewController addVUContentToPatientVU:(welvu_images *)[theData objectForKey:@"welvu_imagesModel"]
                                                      :CGPointMake([[theData objectForKey:@"positionX"] floatValue],
                                                                   [[theData objectForKey:@"positionY"] floatValue])];
}
- (void)removeSelectedImageFromVU:(NSNotification *)note {
    NSDictionary *theData = [note userInfo];
    [self topicVUViewControllerRemoveImageSelected:theData];
}

- (void)imageSelectedFromVU:(NSNotification *)note {
    NSDictionary *theData = [note userInfo];
    
    
    [self topicVUViewControllerImageSelected:(welvu_images *)[theData objectForKey:@"welvu_imagesModel"]];
    
    
}

- (void)ImageSelectAllFromVU:(NSNotification *)note {
    NSDictionary *theData = [note userInfo];
    
    [self topicVUViewControllerImageSelectedAll:theData];
    
}

- (void)ImageRemovedFromVU:(NSNotification *)note {
    NSDictionary *theData = [note userInfo];
    
    [self topicVUViewControllerRemoveImageSelected:(welvu_images *)[theData objectForKey:@"welvu_ImageRemoved"]];
}
- (void)hidePatientBtnClicked {
    
    patientInfo.enabled = NO;
}
-(void)reloadSpecialty:(NSNotification *)notify {
    [self showAccordian];

}

-(void) addObserverToMaster {
    //EMR
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSpecialty:)
                                                 name:@"AppDidBecomeActive" object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hidePatientBtnClicked)
                                                 name:NOTIFY_HIDE_PATIENT_INFO_BUTTON
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removedContentFromPatientVU:) name:NOTIFY_REMOVED_FROM_PATIENTVU object:nil];
    //EMR
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageSelectedFromVU:)
                                                 name:NOTIFY_IMAGE_SELECTED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ImageRemovedFromVU:)
                                                 name:NOTIFY_IMAGE_REMOVED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ImageSelectAllFromVU:)
                                                 name:NOTIFY_IMAGE_SELECTEDALL
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeSelectedImageFromVU:)
                                                 name:NOTIFY_REMOVE_SELECTED_IMAGE
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageSelectedWithPositionFromVU:)
                                                 name:@"imageSelectedWithPosition"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editVU:)
                                                 name:@"annotationVU"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissVUFinishAnnotation:)
                                                 name:@"dismissVUFinish"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(camButtonClickedVU:)
                                                 name:@"camButtonClicked"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTopicContentCount:)
                                                 name:@"deleteImageFromTopic"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTopicContentCount1:)
                                                 name:@"albumButtonSelected"
                                               object:nil];
    
    //EMR
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearedAllPatientVU:)
                                                 name:NOTIFY_CLEARALL_PATIENTVU object:nil];
    //EMR
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsUpdate)
                                                 name:NOTIFY_SETTINGS_UPDATED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:NOTIFY_RELOAD_TABLE_DATA object:nil];
}
-(void) removeObserverFromMaster {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"AppDidBecomeActive" object:nil];
    

    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_IMAGE_SELECTED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_IMAGE_REMOVED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_IMAGE_SELECTEDALL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_REMOVE_SELECTED_IMAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageSelectedWithPosition" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageSelectedWithPosition" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"annotationVU" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dismissVUFinish" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"camButtonClicked" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteImageFromTopic" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_CLEARALL_PATIENTVU object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_SETTINGS_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_RELOAD_TABLE_DATA object:nil];
}
-(void) refreshObserver {
    [self removeObserverFromMaster];
    [self addObserverToMaster];
}
#pragma  mark UIInterfaceOrientation
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


- (void)startUpViewController
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self shouldAutorotate];
    /*UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
     if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
     !isLandScapeMode)
     {
     isLandScapeMode = YES;
     [self framesinlandscape];
     }
     else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isLandScapeMode)
     {
     isLandScapeMode = NO;
     [self framesinlandscape];
     }*/
    
}

#pragma mark show Accordian
//Display accordian
-(void)showAccordian
{
    
    [self intializeWithSettings];
    if(accordion != nil) {
        [accordion removeObserverFromAccordion];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeTopicVUObserver" object:nil];
        [accordion removeFromSuperview];
        accordion = nil;
    }
    //EMR
    NSString *patientID=[appDelegate.currentPatientInfo objectForKey:@"pid"];
    if (patientID == nil) {
        accordion = [[AccordionView alloc] initWithFrame:CGRectMake(0, 0, 272, 643)];
    }
    else{
        accordion = [[AccordionView alloc] initWithFrame:CGRectMake(0, 0, 272, 440)];
    }
    //EMR
    accordion.delegate = self;
    [self.view addSubview:specialtyContainer];
    [specialtyContainer addSubview:accordionContainer];
    [accordionContainer addSubview:accordion];
    [accordion clipsToBounds];
    [accordionContainer bringSubviewToFront:_bottomFadingView];
    [accordionContainer bringSubviewToFront:_topFadingView];
    
    for(int i = 0; i < welvu_topicsModels.count; i++) {
        tetTopicCount = [NSString stringWithFormat:@"%d",
                         [welvu_images getImageCount:appDelegate.getDBPath:
                          ((welvu_topics *)[welvu_topicsModels objectAtIndex:i]).topicId
                          userId:appDelegate.welvu_userModel.welvu_user_id]];
        NSString *gettopicName = ((welvu_topics *)[welvu_topicsModels objectAtIndex:i]).topicName;
        
        
        AccordianButton *topicHeaderBtn = [AccordianButton buttonWithType:UIButtonTypeCustom];
        topicHeaderBtn.frame=CGRectMake(25, 0+(i*35), 276, 55);
        
        // [header2 setTitle:gettopicName forState: (UIControlState)UIControlStateNormal];
        
        topicHeaderBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [topicHeaderBtn setBackgroundColor:[UIColor clearColor]];
        [topicHeaderBtn setTag:i];
        
        //setting the backgroung image for button
        [topicHeaderBtn setBackgroundImage:[UIImage imageNamed:@"TopicListButton.png"] forState:UIControlStateNormal];
        [self.view addSubview:topicHeaderBtn];
        
        [topicHeaderBtn setBackgroundImage:[UIImage imageNamed:@"TopicListButtonDownArrow.png"] forState:UIControlStateSelected];
        [self.view addSubview:topicHeaderBtn];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(35, 0, 200, 55)];
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.numberOfLines = 2;
        titleLabel.tag = 1;
        [titleLabel setFont:[UIFont fontWithName:@"System" size:14]];
        
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        titleLabel.text = gettopicName;
        
        [self.view addSubview:titleLabel];
        [topicHeaderBtn addSubview:titleLabel];
        
        
        //delete user created topics gesture recogniser
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
        
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 0.5; //seconds
        
        lpgr.numberOfTouchesRequired = 1;
        lpgr.delegate = self;
        [[lpgr view] setTag:i];
        
        
        //Disabled
        [topicHeaderBtn addGestureRecognizer:lpgr];
        //END
        
        
        
        
        if(!((welvu_topics *)[welvu_topicsModels objectAtIndex:i]).topic_is_user_created) {
            titleLabel.font = [UIFont systemFontOfSize:14.0f];
            
        } else {
            titleLabel.font = [UIFont italicSystemFontOfSize:14.0f];
            
        }
        
        if(!((welvu_topics *)[welvu_topicsModels objectAtIndex:i]).is_locked){
            
            UILabel *imageCount = [[UILabel alloc]initWithFrame:CGRectMake(235,12, 30, 30)];
            imageCount.font = [UIFont boldSystemFontOfSize:14];
            [imageCount setBackgroundColor:[UIColor clearColor]];
            imageCount.text = tetTopicCount;
            imageCount.tag = 2;
            imageCount.textColor = [UIColor whiteColor];
            imageCount.layer.backgroundColor = [UIColor colorWithRed:1 green:0.67 blue:0.03 alpha:1].CGColor;
            
            imageCount.layer.cornerRadius = 8;
            imageCount.layer.borderColor = [UIColor clearColor].CGColor;
            imageCount.layer.borderWidth = 1;
            imageCount.textAlignment=UITextAlignmentCenter;
            
            [self.view addSubview:imageCount];
            [topicHeaderBtn addSubview:imageCount];
        }
        
        else if(((welvu_topics *)[welvu_topicsModels objectAtIndex:i]).is_locked){
            UIImage *imageTopicLock = [UIImage imageNamed:@"LockIcon.png"];
            UIImageView *topicLockView = [[UIImageView alloc] initWithImage:imageTopicLock];
            [topicLockView setFrame:CGRectMake(235,12, 30, 30)];
            [topicHeaderBtn addSubview:topicLockView];
            // topicHeaderBtn.enabled = NO;
            
            
            
        }
        
        titleLabel.clipsToBounds = YES;
        titleLabel.layer.masksToBounds = YES;
        
        // [header2 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        welvuTopicVUviewController * welvuTopicVUViewController   = [[welvuTopicVUviewController alloc] initWithFrame:CGRectMake(0, 0, 273, 493)];
        
        NSArray *nibFile = [[NSBundle mainBundle] loadNibNamed:@"welvuTopicVUviewController" owner:self options:nil];
        
        welvuTopicVUViewController.delegate=self;
        welvuTopicVUViewController = [nibFile objectAtIndex:0];
        
        
        [accordion addHeader:topicHeaderBtn withView:welvuTopicVUViewController:((welvu_topics *)[welvu_topicsModels objectAtIndex:i]).is_locked];
        
        [accordion setNeedsLayout];
        
        [accordion setAllowsMultipleSelection:NO];
        topicListGenerated = true;
    }
    [self refreshObserver];
    
    //STM
    [self.detailViewController setCurrentTopicId:0];
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
}

NSInteger previousIndex = -1;
- (void)accordion:(AccordionView *)accordion selectedAccordianView:(UIView *)view:(NSInteger)currentSelectedIndex {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Master VU - MV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Master VU - MV"
                                                          action:@"Select Topic - MV"
                                                           label:@"Topic"
                                                           value:nil] build]];
    @try {
        
    

    int update = [welvu_topics updateTopicHitCounter:appDelegate.getDBPath
                                                    :((welvu_topics *)[welvu_topicsModels objectAtIndex:currentSelectedIndex]).topicId
                                              userId:appDelegate.welvu_userModel.welvu_user_id];
    NSInteger getTopicId=((welvu_topics *)[welvu_topicsModels objectAtIndex:currentSelectedIndex]).topicId;
    //STM
    [self.detailViewController setCurrentTopicId:getTopicId];
    if(previousIndex > -1) {
        if([accordion.views count] > previousIndex && [accordion.views objectAtIndex:previousIndex] != nil) {
            welvuTopicVUviewController *accordianView =   (welvuTopicVUviewController *)[accordion.views objectAtIndex:previousIndex];
            if(accordianView.gridViewGenerated) {
                [accordianView.topicVuGMGridView removeFromSuperview];
                accordianView.topicVuGMGridView = nil;
                accordianView.gridViewGenerated = false;
            }
        }
    }
    
    
    if((!((welvuTopicVUviewController *)view).gridViewGenerated)){
        
        
        previousIndex = currentSelectedIndex;
        
        /* welvuTopicVUviewController * welvuTopicVUView   = [[welvuTopicVUviewController alloc] initwithTopic:getTopicId :getImageContent];*/
        
        
        // [self.detailViewController patientVUImages];
        
        //[self.detailViewController addAllTopicVUContentToPatientVU:getImageContent];
        
        
        
        NSMutableArray *getImageContent= [welvu_images getImagesByTopicId:appDelegate.getDBPath :getTopicId
                                                                   userId:appDelegate.welvu_userModel.welvu_user_id];
        [(welvuTopicVUviewController *)view initwithTopic:getTopicId :[self.detailViewController patientVUImages]];
        [(welvuTopicVUviewController *)view loadMainVU:getTopicId :getImageContent];
        
        //scrolViewGenerated=FALSE;
    } else  {
        //scrolViewGenerated=TRUE;
    }
    
    
    }@catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"MasterVU-MV_Topic: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];

    }
}
- (void)accordion:(AccordionView *)accordion didChangeSelection:(NSIndexSet *)selection {
    //  NSLog(@"Accordian Changed %@", );
    
    //selection.lastIndex
}

-(void)accordionLocked {
    UIAlertView *myAlert = [[UIAlertView alloc]
                            initWithTitle:NSLocalizedString(@"UPGRADE_TITLE", nil)
                            message:nil
                            delegate:self
                            cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                            otherButtonTitles:NSLocalizedString(@"UPGRADE", nil),nil];
    myAlert.tag = 123;
    [myAlert show];

   /* UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"ALERT_PURCHASE_SPECIALTY_TITLE",nil)
                              message: [NSString stringWithFormat:@"%@\"%@\"%@", NSLocalizedString(@"ALERT_PURCHASE_SPECIALTY_MSG1",nil),
                                        [welvu_specialty getSpecialtyNameById:[appDelegate getDBPath]
                                                                             :appDelegate.specialtyId
                                                                       userId:appDelegate.welvu_userModel.welvu_user_id],
                                        NSLocalizedString(@"ALERT_PURCHASE_SPECIALTY_MSG2",nil)]
                              delegate: self
                              cancelButtonTitle:NSLocalizedString(@"NOT_YET",nil)
                              otherButtonTitles:NSLocalizedString(@"PURCHASE_MONTHLY",nil),                                NSLocalizedString(@"PURCHASE_YEARLY",nil),nil];
    [alertView show]; */
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
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    NSString *accessToken = nil;
    if(appDelegate.welvu_userModel.access_token == nil) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        accessToken = [prefs stringForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY];
    } else {
        accessToken = appDelegate.welvu_userModel.access_token;
    }
    
   // NSLog( @"access token %@",accessToken);
    if(purchasedSuccessfully && !isAlreadyCalled) {
        isAlreadyCalled = true;
        
        NSDate *subscriptionStartDate = [NSDate date];
        NSDate *subscriptionEndDate;
        NSString *productIdentifier;
        welvu_specialty *currentSpecialty = [welvu_specialty getSpecialtyById:[appDelegate getDBPath]
                                                                  specialtyId:appDelegate.specialtyId
                                                                       userId:appDelegate.welvu_userModel.welvu_user_id];
        if(!yearlySubscription) {
            productIdentifier = currentSpecialty.product_identifier;
            subscriptionEndDate = [subscriptionStartDate dateByAddingTimeInterval:3600*24*30];
        } else {
            productIdentifier = currentSpecialty.yearly_product_identifier;
            subscriptionEndDate = [subscriptionStartDate dateByAddingTimeInterval:3600*24*365];
        }
        BOOL insert = [welvu_topics updateLock:[appDelegate getDBPath]
                                     specialty:appDelegate.specialtyId setLock:false userId:appDelegate.welvu_userModel.welvu_user_id];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"Specialty_%d", appDelegate.specialtyId]];
        [[NSUserDefaults standardUserDefaults] setValue:transactionRecipt
                                                 forKey:[NSString stringWithFormat:@"Specialty_Receipt_%d",appDelegate.specialtyId]];
        if(insert) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: SERVER_DATE_FORMAT];
            NSString *validFrom = [dateFormatter stringFromDate:subscriptionStartDate];
            NSString *validTill = [dateFormatter stringFromDate:subscriptionEndDate];
            appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
            NSDictionary *requestData =  [NSDictionary dictionaryWithObjectsAndKeys:
                                          accessToken, HTTP_RESPONSE_ACCESSTOKEN_KEY,
                                          productIdentifier, HTTP_RESPONSE_PRODUCT_IDENTIFIER,
                                          [NSNumber numberWithInteger:appDelegate.specialtyId], HTTP_SPECIALTY_ID,
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
            //requestHandler.delegate = self;
            [requestHandler makeHTTPRequest];
            
            update =[welvu_specialty updateSubscribedSpecialty:appDelegate.getDBPath specialtyId:appDelegate.specialtyId
                                         subscriptionStartDate:subscriptionStartDate subscriptionEndDate:subscriptionEndDate
                                                        userId:appDelegate.welvu_userModel.welvu_user_id];
            [self reloadTableData];
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
    
  //  NSLog(@"Purchase Failed !");
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
-(void)buyCredits
{
    welvu_specialty *currentSpecialty = [welvu_specialty getSpecialtyById:[appDelegate getDBPath]
                                                              specialtyId:appDelegate.specialtyId
                                                                   userId:appDelegate.welvu_userModel.welvu_user_id];
    if (!inApp) {
        inApp = [[InAppPurchaseManager alloc] init];
        inApp.delegate = self;
    }
    if(!yearlySubscription) {
        [inApp buyProductIdentifier:currentSpecialty.product_identifier
                   NotficationIdent:@"Upgrade" specialtyId:appDelegate.specialtyId];
    } else {
        [inApp buyProductIdentifier:currentSpecialty.yearly_product_identifier
                   NotficationIdent:@"Upgrade" specialtyId:appDelegate.specialtyId];
    }
    
}
*/
-(IBAction)backBtnClicked:(id)sender {
    
}

-(IBAction)userInfoBtnClicked:(id)sender
{
    [self.detailViewController intializePatientInfoContent];
}
-(IBAction)graphBTnClicked:(id)sender
{
    [self.detailViewController showGraphView ];
    [self.detailViewController removePatientInfoContent];
}

//EMR
-(NSInteger) searchImageGroups:(NSInteger) imgId:(NSMutableArray *) imagesArray {
    
    for(int i=0; i < imagesArray.count; i++) {
        welvu_images *img = [imagesArray objectAtIndex:i];
        if(img.imageId == imgId) {
            return i;
        }
    }
    return -1;
}

//Grid View For EMR
//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//Intializing GridViews
//////////////////////////////////////////////////////////
-(void)intializeGMGridViews {
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    GMGridView * patientGrid= [[GMGridView alloc] initWithFrame:CGRectMake(0, 0, 272, 159)];
    
    //self.topicVuGMGridView.autoresizesSubviews = NO;
    patientGrid.clipsToBounds = YES;
    patientGrid.backgroundColor = [UIColor whiteColor];
    //topicVuGMGrid.backgroundColor = [UIColor redColor];
    [patientImageContainer addSubview:patientGrid];
    self.oemrPatientGMGridView = patientGrid;
    
    self.oemrPatientGMGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    self.oemrPatientGMGridView.style = GMGridViewStylePush;
    self.oemrPatientGMGridView.itemSpacing =((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_spacing;
    
    
    self.oemrPatientGMGridView.minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    self.oemrPatientGMGridView.centerGrid = NO;
    self.oemrPatientGMGridView.enableEditOnLongPress = NO;
    self.oemrPatientGMGridView.disableEditOnEmptySpaceTap = YES;
    self.oemrPatientGMGridView.delegate = self;
    self.oemrPatientGMGridView.actionDelegate = self;
    self.oemrPatientGMGridView.sortingDelegate = self;
    self.oemrPatientGMGridView.dataSource = self;
    self.oemrPatientGMGridView.mainSuperView = appDelegate.splitViewController.view;
}

/*Required*/
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [oEMRPatientImages count];
}

/*Required*/
- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    
    if (!INTERFACE_IS_PHONE)
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            if(((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_grid_layout) {
                
                return CGSizeMake(THUMB_BUTTON_GRID_WIDTH, THUMB_BUTTON_GRID_HEIGHT);
                
            } else {
                
                return CGSizeMake(THUMB_BUTTON_WIDTH, THUMB_BUTTON_HEIGHT);
                
            }
        }
        else
        {
            if(((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_grid_layout) {
                
                return CGSizeMake(THUMB_BUTTON_GRID_WIDTH, THUMB_BUTTON_GRID_HEIGHT);
                
            } else {
                
                return CGSizeMake(THUMB_BUTTON_WIDTH, THUMB_BUTTON_HEIGHT);
                
            }
        }
    }
    return CGSizeMake(THUMB_BUTTON_WIDTH, THUMB_BUTTON_HEIGHT);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:
                   [[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    CGSize destinationSize;
    
    if(((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_grid_layout) {
        destinationSize = CGSizeMake(THUMB_IMAGE_GRID_WIDTH, THUMB_IMAGE_GRID_HEIGHT);
    } else {
        destinationSize = CGSizeMake(THUMB_IMAGE_WIDTH, THUMB_IMAGE_HEIGHT);
    }
    
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        /* cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
         cell.deleteButtonOffset = CGPointMake(-15, -15);*/
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 8;
        view.contentMode = UIViewContentModeCenter;
        cell.contentView = view;
        
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImage *thumbnail = nil;
    
    welvu_images *welvu_imagesModel = [oEMRPatientImages objectAtIndex:index];
    
    if([welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE]
       || [welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_TYPE]||  [welvu_imagesModel.type isEqualToString:IMAGE_PATIENT_TYPE]) {
        cell.deleteButtonOffset = CGPointMake(-500, -500);
    } else {
        cell.deleteButtonIcon = [UIImage imageNamed:@"ContCloseButton.png"];
        cell.deleteButtonOffset = CGPointMake(-1.0, 0.0);
    }
    
    if([welvu_imagesModel.type isEqualToString:IMAGE_PATIENT_TYPE]) {
        NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
        UIImage *originalImage = [UIImage imageWithData:imageData];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
    } else if([welvu_imagesModel.type isEqualToString:VIDEO_PATIENT_TYPE]) {
        UIImage *originalImage = [self generateImageFromVideo:welvu_imagesModel.url :welvu_imagesModel.type];
        thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
    }
    
    if(welvu_imagesModel.selected) {
        cell.isSelected = TRUE;
        thumbnail  = [thumbnail imageWithBorderForSelected:THUMB_IMAGE_BORDER];
        //cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"imageBackground1.png"]];
    } else {
        cell.isSelected = FALSE;
        thumbnail  = [thumbnail imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
        
        
        //  cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"imageBackground3.png"]];
    }
    thumbnail = [thumbnail makeRoundCornerImage:5 :5 ];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = thumbnail;
    [cell.contentView addSubview:imageView];
    cell.indexTag = welvu_imagesModel.imageId;
    return cell;
}

- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    
    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    GMGridViewCell *cell = (GMGridViewCell *)[gridView cellForItemAtIndex:position];
    
    if(!cell.isSelected ) {
        
        for(UIView *subview in [cell.contentView subviews]) {
            if([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)subview;
                imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                
            }
        }
        cell.isSelected = TRUE;
        welvu_images *welvu_imagesModel = [oEMRPatientImages objectAtIndex:position];
        
        
        welvu_imagesModel.selected = YES;
        
        
        // [self.delegate topicVUViewControllerImageSelected:welvu_imagesModel];
        //YetToDo Drag and drop
        /*  NSData *imageData = UIImagePNGRepresentation(welvu_imagesModel.imageData);
         NSDictionary *jsonObject=[NSJSONSerialization
         JSONObjectWithData:imageData
         options:NSJSONReadingMutableLeaves
         error:nil];*/
        
        /*NSDictionary *imageDetailsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
         welvu_imagesModel, @"welvu_imagesModel", nil];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"patientContentSelected" object:self userInfo:imageDetailsDictionary];*/
        [self.detailViewController addVUContentToPatientVU:welvu_imagesModel :droppedPositon];
        
        appDelegate.ispatientVUContent = TRUE;
        
    } else if(cell.isSelected){
        
        for(UIView *subview in [cell.contentView subviews]) {
            if([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)subview;
                imageView.image = [imageView.image imageWithBorderForUnselected:THUMB_IMAGE_BORDER];
                imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                
                
            }
            
            cell.isSelected = FALSE;
            welvu_images *welvu_imagesModel = [oEMRPatientImages objectAtIndex:position];
            welvu_imagesModel.selected = NO;
            patientImgTobeRemoved = welvu_imagesModel.patientImageID;
            NSDictionary *imageDetailsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                    welvu_imagesModel, @"welvu_ImageRemoved", nil];
            
            [self topicVUViewControllerRemoveImageSelected:welvu_imagesModel];
            
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"imageRemoved" object:self userInfo:imageDetailsDictionary];
            
        }
    }/* else if (edit) {
      //Image annotation part
      welvuTopicVUAnnotationViewController *welvuTopicVUAnnotation = [[welvuTopicVUAnnotationViewController alloc]
      initWithImageGroup:@"welvuTopicVUAnnotationViewController" bundle:nil
      currentTopicId:topicsId
      images:topicVUImages currentSelectedImage:position annotateBlankCanvas:false];
      welvuTopicVUAnnotation.delegate = self;
      welvuTopicVUAnnotation.modalPresentationStyle = UIModalPresentationFullScreen;
      welvuTopicVUAnnotation.modalTransitionStyle = UIModalTransitionStyleCoverVertical; //transition shouldn't matter
      [self presentModalViewController:welvuTopicVUAnnotation animated:YES];
      [welvuTopicVUAnnotation release];
      }*/
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    
    if(gridView == self.oemrPatientGMGridView) {
        //self.topicVuGMGridView.editing = NO;
    }
}

- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    _lastDeleteItemIndexAsked = index;
    if([((welvu_images *)[oEMRPatientImages objectAtIndex:_lastDeleteItemIndexAsked]).type isEqualToString:IMAGE_ASSET_TYPE]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"ALERT_TOPIC_VU_TITLE", nil)
                              message: NSLocalizedString(@"ALERT_TOPIC_VU_ARCHIVE_MSG", nil)
                              delegate: self
                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                              otherButtonTitles:NSLocalizedString(@"ARCHIVE", nil),nil];
        [alert show];
    } else {
        
        if([welvu_alerts canAlertShowAgain:appDelegate.getDBPath :ALERT_TOPIC_VU_TITLE]){
            
            
            // [self.delegate topicVUViewControllerRemoveImageSelected:(welvu_images *)[topicVUImages objectAtIndex
            // :_lastDeleteItemIndexAsked]];
            /* NSDictionary *imageDetailsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
             (welvu_images *)[topicVUImages objectAtIndex
             :_lastDeleteItemIndexAsked], @"welvu_RemoveSelectImage", nil];*/
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"removeSelectedImage" object:self userInfo:(welvu_images *)[oEMRPatientImages objectAtIndex:_lastDeleteItemIndexAsked]];
            
            
            [welvu_history deleteHistoryWithImageId:appDelegate.getDBPath:((welvu_images *)[oEMRPatientImages objectAtIndex
                                                                                            :_lastDeleteItemIndexAsked]).imageId];
            BOOL inserted = [welvu_sync addSyncDetail:[appDelegate getDBPath] guid:((welvu_images *)[oEMRPatientImages objectAtIndex
                                                                                                     :_lastDeleteItemIndexAsked]).image_guid
                                             objectId:((welvu_images *)[oEMRPatientImages objectAtIndex
                                                                        :_lastDeleteItemIndexAsked]).imageId
                                             syncType:SYNC_TYPE_CONTENT_CONSTANT
                                           actionType:ACTION_TYPE_DELETE_CONSTANT];
            BOOL deleted = [welvu_images deleteImageFromTopic:appDelegate.getDBPath
                                                             :((welvu_images *)[oEMRPatientImages objectAtIndex
                                                                                :_lastDeleteItemIndexAsked]).imageId
                                                       userId:appDelegate.welvu_userModel.welvu_user_id];
            if(deleted) {
                SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
                [dataToCloud startSyncDeletedDataToCloud:SYNC_TYPE_CONTENT_CONSTANT guid:((welvu_images *)
                                                                                          [oEMRPatientImages objectAtIndex
                                                                                           :_lastDeleteItemIndexAsked]).image_guid
                                              actionType:HTTP_REQUEST_ACTION_TYPE_DELETE actionURL:PLATFORM_SYNC_CONTENTS];
                if ([[NSFileManager defaultManager] fileExistsAtPath:((welvu_images *)[oEMRPatientImages objectAtIndex
                                                                                       :_lastDeleteItemIndexAsked]).url]) {
                    [[NSFileManager defaultManager] removeItemAtPath: ((welvu_images *)[oEMRPatientImages objectAtIndex
                                                                                        :_lastDeleteItemIndexAsked]).url error:NULL];
                   // NSLog(@"Deleted Content from %@", ((welvu_images *)[oEMRPatientImages objectAtIndex:_lastDeleteItemIndexAsked]).url);
                }
                [oEMRPatientImages removeObjectAtIndex:_lastDeleteItemIndexAsked];
                [self.oemrPatientGMGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"ALERT_TOPIC_VU_TITLE", nil)
                                  message: NSLocalizedString(@"ALERT_TOPIC_VU_ARCHIVE_DELETE_MSG", nil)
                                  delegate: self
                                  cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                  otherButtonTitles:NSLocalizedString(@"DONT_SHOW_AGAIN", nil),
                                  NSLocalizedString(@"DELETE", nil),nil];
            
            [alert show];
        }
        
    }
    
    
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewSortingDelegate
//////////////////////////////////////////////////////////////
/*Required*/
- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor colorWithRed:0.94f green:0.67f blue:0.14f alpha:1.0f];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     }
                     completion:nil
     ];
}



-(void)GMGridView:(GMGridView *)gridView didMovingCell:(GMGridViewCell *)cell {
    
    droppedPositon = CGPointMake(cell.frame.origin.x, cell.frame.origin.y);
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil
     ];
    if(gridView == self.oemrPatientGMGridView) {
        // [self updateOrderTopicVUImages];
    }
    
    if(droppedPositon.x > 300) {
        if(!cell.isSelected ) {
            for(UIView *subview in [cell.contentView subviews]) {
                if([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)subview;
                    imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                    imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                    
                }
            }
            cell.isSelected = TRUE;
            welvu_images *welvu_imagesModel = [oEMRPatientImages objectAtIndex:[self searchImageGroups:cell.indexTag :oEMRPatientImages]];
            welvu_imagesModel.selected = YES;
            //[self.delegate topicVUViewControllerImageSelectedWithPosition:welvu_imagesModel:droppedPositon];
            NSNumber *positionX = [NSNumber numberWithFloat:droppedPositon.x];
            NSNumber *positionY = [NSNumber numberWithFloat:droppedPositon.y];
            NSDictionary *imageDetailsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                    welvu_imagesModel, @"welvu_imagesModel", positionX,
                                                    @"positionX",positionY, @"positionY", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"imageSelectedWithPosition" object:self userInfo:imageDetailsDictionary];
            
            
            appDelegate.ispatientVUContent = TRUE;
            
            
        }
        
        
    }
    droppedPositon = CGPointZero;
    
}
- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    welvu_images *object = [oEMRPatientImages objectAtIndex:oldIndex];
    [oEMRPatientImages removeObject:object];
    [oEMRPatientImages insertObject:object atIndex:newIndex];
    
    
    
    
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    [oEMRPatientImages exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}


/*Required*/
- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return YES;
}
-(UIImage *)generateImageFromVideo:(NSString *) pathString:(NSString *)pathType {
    NSURL *theContentURL;
    if([pathType isEqualToString:VIDEO_PATIENT_TYPE] && ![[NSFileManager defaultManager] fileExistsAtPath:pathString]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSArray *nameAndType = [pathString componentsSeparatedByString: @"."];
        NSString *moviePath = [bundle pathForResource:[nameAndType objectAtIndex:0] ofType:[nameAndType objectAtIndex:1]];
        theContentURL = [NSURL fileURLWithPath:moviePath];
    } else {
        theContentURL = [NSURL fileURLWithPath:pathString];
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:theContentURL options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    CGImageRef thumb = [imageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(1.0, 1.0)
                                              actualTime:NULL
                                                   error:NULL];
    
    UIImage *thumbImage = [UIImage imageWithCGImage:thumb];
imageGenerator = nil;
asset = nil;
CGImageRelease(thumb);
return thumbImage;
    
}
//EMR
- (void) removedContentFromPatientVU:(NSNotification *)notification {
    
    NSDictionary *theData = [notification userInfo];
    welvu_images *welvu_imagesModel=[theData objectForKey:TABLE_WELVU_IMAGES];
    
    
    
    if([welvu_imagesModel.type isEqualToString:IMAGE_PATIENTINFO_TYPE])
    {
        patientInfo.enabled = YES;
    }
    
    
    NSInteger index = [self searchImageGroups:((welvu_images *)[notification.userInfo objectForKey:TABLE_WELVU_IMAGES]).patientImageID :oEMRPatientImages];
   // NSLog(@"index value %d",index);
    if(index > -1) {
        welvu_images *welvu_imagesModel = [oEMRPatientImages objectAtIndex:index];
        
        if(welvu_imagesModel.selected) {
            
            NSInteger index = [self searchImageGroups:welvu_imagesModel.imageId :oEMRPatientImages];
            welvu_imagesModel.selected = NO;
            GMGridViewCell *cell = (GMGridViewCell *)[self.oemrPatientGMGridView cellForItemAtIndex:index];
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

    
}
-(IBAction)selectAllPatientInfo:(id)sender {
    
    if([oEMRPatientImages count] > 0) {
        for(welvu_images *welvu_imagesModel in oEMRPatientImages) {
            if(!welvu_imagesModel.selected) {
                NSInteger index = [self searchPatientImageGroups:welvu_imagesModel.imageId:oEMRPatientImages];
                welvu_imagesModel.selected = YES;
                GMGridViewCell *cell = (GMGridViewCell *)[self.oemrPatientGMGridView cellForItemAtIndex:index];
                if(!cell.isSelected) {
                    for(UIView *subview in [cell.contentView subviews]) {
                        if([subview isKindOfClass:[UIImageView class]]) {
                            UIImageView *imageView = (UIImageView *)subview;
                            imageView.image = [imageView.image imageWithBorderForSelected:THUMB_IMAGE_BORDER];
                            imageView.image = [imageView.image makeRoundCornerImage:IMAGE_ROUNDED_CORNER_RADIUS : IMAGE_ROUNDED_CORNER_RADIUS];
                        }
                    }
                    cell.isSelected = TRUE;
                }
            }
        }
        // [self.delegate topicVUViewControllerImageSelectedAll:[topicVUImages mutableCopy]];
        [self.detailViewController addAllTopicVUContentToPatientVU:oEMRPatientImages];
        
        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"imageSelectedAll" object:self userInfo:[oEMRPatientImages mutableCopy]];
    }
}
-(NSInteger) searchPatientImageGroups:(NSInteger) imgId:(NSMutableArray *) imagesArray {
    
    for(int i=0; i < imagesArray.count; i++) {
        welvu_images *img = [imagesArray objectAtIndex:i];
        if(img.patientImageID == imgId) {
            return i;
        }
    }
    return -1;
}

#pragma mark - NSConnection delegates
-(void) platformDidResponseReceived:(BOOL)success:(NSString *)actionAPI {
  //  NSLog(@"Response received for get USER CONFIRMATION");
}
-(void) platformDidReceivedData:(BOOL)success :(NSDictionary *)responseDictionary
                               :(NSString *)actionAPI {
    
    
  //  NSLog(@"Response received for get USER CONFIRMATION");
    
}

- (void)syncContentToPlatformSendResponse:(BOOL)success {
    
}
//santhosh sep 25
- (void)syncContentToPlatformDidReceivedData:(BOOL)success :(NSDictionary *)responseDictionary {
    if(success) {
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
        NSString *topic_guid = [responseDictionary objectForKey:HTTP_REQUEST_TOPIC_GUID];
        NSInteger topicId = [welvu_topics getTopicIdByGUID:[appDelegate getDBPath] :topic_guid];
        NSMutableArray *welvuImagesModel = [welvu_images getImagesIdByTopicId:[appDelegate getDBPath] :topicId
                                            userId:appDelegate.welvu_userModel.welvu_user_id];
        for(welvu_images *welvuImageModel in welvuImagesModel) {
            SyncDataToCloud *dataToCloud = [[SyncDataToCloud alloc] init];
            [dataToCloud startSyncDataToCloud:SYNC_TYPE_TOPIC_CHANGES_CONSTANT objectId:welvuImageModel.imageId
                                   actionType:HTTP_REQUEST_ACTION_TYPE_DELETE actionURL:PLATFORM_SYNC_TOPICS];
        }
        
    }
}


//content sync failed
- (void)syncContentFailedWithErrorDetails:(NSError *)error {
   // NSLog(@"Sync Content Failed: %@", error);
}
- (void)syncResponseDicFromPlatform:(BOOL) success:(NSDictionary *) responseDictionary  {
    
}
-(void)switchToWelvuUSer {
    
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
    NSInteger specialtyCount = [welvu_specialty getSpecialtyCount:[appDelegate getDBPath]
                                                           userId:appDelegate.welvu_userModel.welvu_user_id];
    
    [self dismissModalViewControllerAnimated:NO];
    [self performSelector:@selector(organazationBtnClicked:) withObject:nil];
    
    if(appDelegate.welvu_userModel
       && ( appDelegate.welvu_userModel.access_token != nil  ||  [[NSUserDefaults standardUserDefaults] objectForKey:HTTP_RESPONSE_ACCESSTOKEN_KEY] != nil)
       && specialtyCount > 0 ) {
        [self performSelector:@selector(organazationBtnClicked:) withObject:nil];
    }
    
    [self.detailViewController intializeSettings];
    [self.detailViewController themeSettingsViewControllerDidFinish];
    [self showAccordian];
    [self settingsUpdate];
}

-(IBAction)organazationBtnClicked:(id)sender {
   
    //declaring Event Tracking Analytics
    
        self.detailViewController.notificationLable.hidden = YES;
        welvuOrganizationViewController *specialtyViewCont = [[welvuOrganizationViewController alloc]
                                                           initWithNibName:@"welvuOrganizationViewController" bundle:nil];
        specialtyViewCont.modalPresentationStyle = UIModalPresentationFullScreen;
        //specialtyViewCont.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        specialtyViewCont.delegate = self;
        [self presentModalViewController:specialtyViewCont animated:NO];
        
    }
-(void)welvuOrganizationViewControllerDidFinish {
    [self dismissModalViewControllerAnimated:NO];
    
    [self performSelector:@selector(specialtyBtnClicked:) withObject:nil];
    
}

-(void)userSwitchAccountFromTopicVUAnnotation {
    [self dismissModalViewControllerAnimated:NO];
    [self switchToWelvuUSer];
}

-(IBAction)showRegistrationView:(id)sender{
   
    dispatch_after(0, dispatch_get_main_queue(), ^{
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:appDelegate.splitViewController.view :NSLocalizedString(@"LOADING", nil)];
        }
        
        
        welvuRegistrationViewController *registrationViewCont = [[welvuRegistrationViewController alloc]initWithNibName:@"welvuRegistrationViewController" bundle:nil];
        registrationViewCont.modalPresentationStyle = UIModalPresentationFullScreen;
        //registrationViewCont.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        registrationViewCont.delegate = self;
        //[self presentModalViewController:registrationViewCont animated:NO];
        [self presentViewController:registrationViewCont animated:NO completion:NULL];
       
    });
    
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
    [self removepatchinIos8];

}
-(IBAction)showSpecialtyView:(id)sender{
   
    dispatch_after(0, dispatch_get_main_queue(), ^{
        if(spinner == nil) {
            spinner = [ProcessingSpinnerView loadSpinnerIntoView:appDelegate.splitViewController.view :NSLocalizedString(@"LOADING", nil)];
        }
        
       
        welvuSpecialtyViewController *SpecialtyViewCont = [[welvuSpecialtyViewController alloc]initWithNibName:@"welvuSpecialtyViewController" bundle:nil];
        SpecialtyViewCont.modalPresentationStyle = UIModalPresentationFullScreen;
        //registrationViewCont.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        SpecialtyViewCont.delegate = self;
        //[self presentModalViewController:registrationViewCont animated:NO];
        [self presentViewController:SpecialtyViewCont animated:NO completion:NULL];
       
    });
    
    if(spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
    [self removepatchinIos8];
    
}
-(void)closePatchForIos8 {
closePatchoverlay= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    closePatchoverlay.alpha = 1;
    closePatchoverlay.backgroundColor = [UIColor clearColor];
    
    
    UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    UIButton *overlayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];

    [overlayCustomBtn setFrame:CGRectMake(0, 0, 1024, 768)];
    overlayImageView.image = [UIImage imageNamed:@"Overvu.png"];
    
    [closePatchoverlay addSubview:overlayImageView];
    [closePatchoverlay addSubview:overlayCustomBtn];
    
    //[self.view addSubview:closePatchoverlay];
      [appDelegate.splitViewController.view addSubview:closePatchoverlay];
}

-(void)removepatchinIos8 {
    if (closePatchoverlay !=nil) {
        [closePatchoverlay removeFromSuperview];
        closePatchoverlay = nil;
    }

}
@end
