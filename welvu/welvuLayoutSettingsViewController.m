//
//  LayoutSettingsViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 25/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "welvuLayoutSettingsViewController.h"
#import "welvuContants.h"
#import "GMGridViewLayoutStrategies.h"
#import "GMGridView.h"
#import "GAI.h"
#import "welvuAppDelegate.h"
@interface welvuLayoutSettingsViewController () <GMGridViewDataSource, GMGridViewSortingDelegate,
GMGridViewActionDelegate> {
    welvuAppDelegate *appDelegate;
}
@end

@implementation welvuLayoutSettingsViewController
@synthesize delegate, headers,topicVuGMGridView, topicVUImages;
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
        self.title = NSLocalizedString(@"SETTINGS_LAYOUT_HEADER", nil);
    }
    return self;
}
/*
 * Method name: initWithLayoutSettings
 * Description: initlizing with Layout settings 
 * Parameters: welvu_settings
 * return self
 */
- (id)initWithLayoutSettings:(welvu_settings *) welvu_settings {
    self = [super initWithNibName:@"welvuLayoutSettingsViewController" bundle:nil];
    if (self) {
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil)
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(doneBtnClicked:)];
        self.navigationItem.rightBarButtonItem = doneBtn;
        
        currentWelvuSettings = welvu_settings;
        headers = [[NSMutableArray alloc] initWithCapacity:3];
        
        [headers addObject:NSLocalizedString(@"CONTENT_LAYOUT_TEXT", nil)];
        [headers addObject:NSLocalizedString(@"CONTENT_GRID_LAYOUT_TEXT", nil)];
        //[headers addObject:NSLocalizedString(@"CONTENT_SORTING_TEXT", nil)];
        //[headers addObject:NSLocalizedString(@"CONTENT_BACKGROUND_TEXT", nil)];
    }
    return self;
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
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Layout Settings VU - LS"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Layout Settings VU - LS"
                                                          action:@"Save Button - LS"
                                                           label:@"Save"
                                                           value:nil] build]];
    


    @try {
        
        
        if( appDelegate.isSettingsChanged == TRUE){
            [self.delegate layoutSettingsViewControllerDidFinish];
        }
        appDelegate.isSettingsChanged = FALSE;
        [self.delegate layoutSettingsViewControllerDidClose];
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"LayoutSettingsVU-LS_Save:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];

    }
}

/*
 * Method name: backBtnClicked
 * Description: navigate to another view
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2012
 */
-(IBAction)backBtnClicked:(id)sender {
    //Declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Layout Settings VU - LS"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Layout Settings VU - LS"
                                                          action:@"Go Back - LS"
                                                           label:@"Back"
                                                           value:nil] build]];
    
    @try {
        if( appDelegate.isSettingsChanged == TRUE){
            [self.delegate layoutSettingsViewControllerDidFinish];
        }
        appDelegate.isSettingsChanged = FALSE;
        [self.navigationController popViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"LayoutSettingsVU-Back :%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        

        
    }
}

- (void)sortStyleSegmentedControlChanged:(UISegmentedControl *)control
{
    appDelegate.isSettingsChanged = TRUE;
    switch (control.selectedSegmentIndex)
    {
        case GMGridViewStylePush:
            currentWelvuSettings.welvu_content_vu_style = GMGridViewStylePush;
            break;
        case GMGridViewStyleSwap:
            currentWelvuSettings.welvu_content_vu_style = GMGridViewStyleSwap;
            break;
        default:
            break;
    }
}

-(void) sortThumbnailSegmentedControlChanged:(UISegmentedControl *)control {
 appDelegate.isSettingsChanged = TRUE;
    switch (control.selectedSegmentIndex)
    {
        case 0:
           control.tintColor =[UIColor colorWithRed:0/255.0 green:71/255.0 blue:109/255.0 alpha:1.0];
            currentWelvuSettings.welvu_content_vu_grid_layout = TRUE;
            
            
            break;
        case 1:
            control.tintColor =[UIColor colorWithRed:0/255.0 green:71/255.0 blue:109/255.0 alpha:1.0];
            currentWelvuSettings.welvu_content_vu_grid_layout = FALSE;
            
            break;
        default:
            break;
    }
    [topicVuGMGridView layoutSubviewsWithAnimation:GMGridViewItemAnimationFade];
    [topicVuGMGridView reloadData];
    
}

- (void)layoutSpacingSliderChanged:(UISlider *)control {
    appDelegate.isSettingsChanged = TRUE;
    
        self.topicVuGMGridView.itemSpacing = control.value;
        [self.topicVuGMGridView layoutSubviewsWithAnimation:GMGridViewItemAnimationFade];

        currentWelvuSettings.welvu_content_vu_spacing = control.value;
        [topicVuGMGridView layoutSubviewsWithAnimation:GMGridViewItemAnimationFade];
    
}



- (void)debugGridLayoutSwitchChanged:(UISwitch *)control {
    if(control.on) {
        currentWelvuSettings.welvu_content_vu_grid_layout = TRUE;
    } else {
        currentWelvuSettings.welvu_content_vu_grid_layout = FALSE;
    }
}

- (void)debugGridBackgroundSwitchChanged:(UISwitch *)control {
    if(control.on) {
        currentWelvuSettings.welvu_content_vu_grid_bg = TRUE;
    } else {
        currentWelvuSettings.welvu_content_vu_grid_bg = FALSE;
    }
}

#pragma mark UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)table
 numberOfRowsInSection:(NSInteger)section {
    return [headers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SimpleTableIdentifier = nil;
    SimpleTableIdentifier = NSLocalizedString(@"SETTINGS_LAYOUT_HEADER", nil);
    
	UITableViewCell * cell = [tableView
                              dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
    
	if(cell == nil) {
        
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:SimpleTableIdentifier];
        
        
        
		/*cell = [[[UITableViewCell alloc]
         initWithStyle:UITableViewCellStyleSubtitle
         reuseIdentifier:SimpleTableIdentifier] autorelease];
         */
        
        switch (indexPath.row) {
            case 0: {
               
                
                
                UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
                [slider setMinimumValue:SETTINGS_LAYOUT_SPACING_MINIMUM];
                [slider setMaximumValue:SETTINGS_LAYOUT_SPACING_MAXIMUM];
                [slider setContinuous:NO];
                
                
                [slider setValue:currentWelvuSettings.welvu_content_vu_spacing];
                [slider addTarget:self action:@selector(layoutSpacingSliderChanged:)
                 forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = slider;
                
                
          
            }
                break;
            case 1: {
                UISwitch *gridSwitch = [[UISwitch alloc] init];
                [gridSwitch addTarget:self action:@selector(debugGridLayoutSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                gridSwitch.on = currentWelvuSettings.welvu_content_vu_grid_layout;
                [gridSwitch sizeToFit];
                
                cell.accessoryView = gridSwitch;
                UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"SMALL", nil), NSLocalizedString(@"LARGE", nil), nil]];
                segmentedControl.frame = CGRectMake(0, 0, 150, 33);
                segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
                
                UIColor *newTintColor = [UIColor colorWithRed:0.07 green:0.45 blue:0.69  alpha:0.5];
                segmentedControl.tintColor = newTintColor;
                [segmentedControl addTarget:self action:@selector(sortThumbnailSegmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
                if(currentWelvuSettings.welvu_content_vu_grid_layout) {
                    segmentedControl.selectedSegmentIndex = 0;
                     segmentedControl.tintColor =[UIColor colorWithRed:0/255.0 green:71/255.0 blue:109/255.0 alpha:1.0];
                } else {
                    segmentedControl.selectedSegmentIndex = 1;
                    segmentedControl.tintColor =[UIColor colorWithRed:0/255.0 green:71/255.0 blue:109/255.0 alpha:1.0];

                }
                cell.accessoryView = segmentedControl;
            }
                break;
            case 2: {
                UISwitch *backgroundSwitch = [[UISwitch alloc] init];
                [backgroundSwitch addTarget:self action:@selector(debugGridBackgroundSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                backgroundSwitch.on = currentWelvuSettings.welvu_content_vu_grid_bg;
                [backgroundSwitch sizeToFit];
                
                cell.accessoryView = backgroundSwitch;
            }
                break;
            case 3: {
                UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"PUSH", nil), NSLocalizedString(@"SWAP", nil), nil]];
                segmentedControl.frame = CGRectMake(0, 0, 150, 30);
                [segmentedControl addTarget:self action:@selector(sortStyleSegmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
                segmentedControl.selectedSegmentIndex=currentWelvuSettings.welvu_content_vu_style;
                cell.accessoryView = segmentedControl;
            }
                break;
            
            default:
                break;
        }
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [headers objectAtIndex:row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
	return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//Intializing GridViews
//////////////////////////////////////////////////////////
-(void)intializeGMGridViews {
   appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    GMGridView *topicVuGMGrid = [[GMGridView alloc] initWithFrame:CGRectMake(140, 240, 268, 320)];
    
    //self.topicVuGMGridView.autoresizesSubviews = NO;
    topicVuGMGrid.clipsToBounds = YES;
    //topicVuGMGrid.backgroundColor = [UIColor redColor];
    [self.view addSubview:topicVuGMGrid];
    self.topicVuGMGridView = topicVuGMGrid;
   // self.topicVuGMGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
   // self.topicVuGMGridView.style = GMGridViewStylePush;
    self.topicVuGMGridView.itemSpacing =((welvu_settings *)appDelegate.currentWelvuSettings).welvu_content_vu_spacing;
    
    self.topicVuGMGridView.minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    self.topicVuGMGridView.centerGrid = NO;
    self.topicVuGMGridView.enableEditOnLongPress = NO;
    self.topicVuGMGridView.disableEditOnEmptySpaceTap = YES;
    self.topicVuGMGridView.delegate = self;
    self.topicVuGMGridView.actionDelegate = self;
   // self.topicVuGMGridView.sortingDelegate = self;
    self.topicVuGMGridView.dataSource = self;
    self.topicVuGMGridView.mainSuperView = appDelegate.splitViewController.view;
}



/*Required*/
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [topicVUImages count];
}

/*Required*/
- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    
    if (!INTERFACE_IS_PHONE)
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            if(currentWelvuSettings.welvu_content_vu_grid_layout == TRUE) {
                
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
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:55.0f/255.0f blue:89.0f/255.0f alpha:1.0];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 8;
        
        cell.contentView = view;
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImage *thumbnail = nil;
    cell.isSelected = TRUE;
    welvu_images *welvu_imagesModel = [topicVUImages objectAtIndex:index];
   // thumbnail = [thumbnail makeRoundCornerImage:5 :5 ];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = thumbnail;
    [cell.contentView addSubview:imageView];
    cell.indexTag = 1;
    return cell;
    
}

- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    
    return NO;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {
    
  }

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewSortingDelegate
//////////////////////////////////////////////////////////////
/*Required*/
- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    }


/*Required*/
- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return NO;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
     //layoutTableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
    //Declaring Page View Analytics

    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];

    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Layout Settings VU - LS"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    

    headerLabel.text = NSLocalizedString(@"SETTINGS_LAYOUT_HEADER", nil);
    layoutTableView.layer.cornerRadius = 10;
    topicVUImages = [[NSMutableArray alloc] init];
    topicVUImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"ColorBlackTool.png"],[UIImage imageNamed:@"ColorBlackTool.png"],[UIImage imageNamed:@"ColorBlackTool.png"],[UIImage imageNamed:@"ColorBlackTool.png"], nil];

    [self intializeGMGridViews];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma Mark UIInterfaceOrientation
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
