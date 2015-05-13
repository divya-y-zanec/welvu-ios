//
//  VideoSettingsViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 25/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "welvuVideoSettingsViewController.h"
#import "welvuContants.h"
#import "GAI.h"
@interface welvuVideoSettingsViewController ()

@end

@implementation welvuVideoSettingsViewController

@synthesize delegate, tableGroup, headers;
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
        self.title = NSLocalizedString(@"SETTINGS_VIDEO_HEADER", nil);
    }
    return self;
}
/*
 * Method name: initWithVideoSettings
 * Description: initlizing with video settings
 * Parameters: welvu_settings_model
 * return self
 */
-(id) initWithVideoSettings:(welvu_settings *) welvu_settings_model {
    self = [super initWithNibName:@"welvuVideoSettingsViewController" bundle:nil];
    if (self) {
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil)
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(doneBtnClicked:)];
        self.navigationItem.rightBarButtonItem = doneBtn;
        
        currentWelvuSettings = welvu_settings_model;
        
        headers = [[NSMutableArray alloc] init];
        [headers addObject:SETTINGS_AV_HEADER];
        [headers addObject:SETTINGS_FPS_HEADER];
        
        NSMutableArray *audio_video = [NSMutableArray arrayWithObjects:SETTINGS_AV_TEXT, SETTINGS_VIDEO_ONLY_TEXT, nil];
        
        NSMutableArray *fpsControl = [NSMutableArray arrayWithObjects:SETTINGS_FPS_10_TEXT, /*SETTINGS_FPS_20_TEXT, SETTINGS_FPS_30_TEXT,*/ nil];
        tableGroup = [[NSMutableArray alloc] init];
        [tableGroup addObject:audio_video];
        [tableGroup addObject:fpsControl];
        
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
    
    [tracker set:kGAIScreenName value:@"Video Settings VU - VS"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Settings VU - VS"
                                                          action:@"Save Settings  - VS"
                                                           label:@"Save"
                                                           value:nil] build]];
    

    @try {
        
        if( appDelegate.isSettingsChanged == TRUE){
            [self.delegate videoSettingsViewControllerDidFinish];
        }
        appDelegate.isSettingsChanged = FALSE;
        [self.delegate videoSettingsViewControllerDidClose];

    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"VideoSettingsVU-VS_Save:%@",exception];
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
    
    [tracker set:kGAIScreenName value:@"Video Settings VU - VS"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Settings VU - VS"
                                                          action:@"Go Back - VS"
                                                           label:@"Back"
                                                           value:nil] build]];
    
    

    @try {
        if( appDelegate.isSettingsChanged == TRUE){
            [self.delegate videoSettingsViewControllerDidFinish];
        }
        appDelegate.isSettingsChanged = FALSE;
        [self.navigationController popViewControllerAnimated:YES];    }
    @catch (NSException *exception) {
      
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"VideoSettingsVU-VS_Back:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        

        
    }
}

-(NSInteger) selectedFPSChoice:(NSInteger) fps_choice {
    NSInteger choice = 0;
    if(fps_choice == 10.0f) {
        choice = 0;
    } else if(fps_choice == 20.0f) {
        choice = 1;
    } else if(fps_choice == 30.0f) {
        choice = 2;
    }
    return  choice;
}

-(float) selectedFPSValue:(NSInteger) fps_choice {
    NSInteger choiceValue = 0;
    
    switch (fps_choice) {
        case 0:
            choiceValue = 10.0f;
            break;
        case 1:
            choiceValue = 24.0f;
            break;
        case 2:
            choiceValue = 24.0f;
            break;
        default:
            break;
    }
    return choiceValue;
}

-(void) sortFPSSegmentedControlChanged:(UISegmentedControl *)control {
    appDelegate.isSettingsChanged = TRUE;
    switch (control.selectedSegmentIndex)
    {
        case 0:
            currentWelvuSettings.fps = 10.0f;
            control.tintColor =[UIColor colorWithRed:0/255.0 green:71/255.0 blue:109/255.0 alpha:1.0];
            
            //segmentedControl.tintColor = [UIColor colorWithRed:30.0 / 256.0 green:52.0 / 256.0 blue:162.0 / 256.0 alpha:1.0];
            break;
        case 1:
            currentWelvuSettings.fps = 20.0f;
            control.tintColor =[UIColor colorWithRed:0/255.0 green:71/255.0 blue:109/255.0 alpha:1.0];
            
            break;
        case 2:
            currentWelvuSettings.fps = 30.0f;
            control.tintColor =[UIColor colorWithRed:0/255.0 green:71/255.0 blue:109/255.0 alpha:1.0];
            break;
        default:
            break;
    }
}

#pragma mark Table Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(headers != nil) {
        return [headers count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(headers != nil && [headers objectAtIndex:section] != nil) {
        return SectionHeaderHeight;
    }
    else {
        // If no section header title, no section header needed
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(self.headers != nil) {
        // Create label with section title
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
      //  NSLog(@"current version %@",currSysVer);
        
        
        
        
        
        NSArray *arr = [currSysVer componentsSeparatedByString:@"."];
        NSString *versionValue = [arr objectAtIndex:0];
      //  NSLog(@"Version Value %@",versionValue);
        UILabel *label = [[UILabel alloc] init];
        if([versionValue isEqualToString: @"7"]) {
            
            
            label.frame = CGRectMake(0, 6, SectionHeaderWidth, SectionHeaderHeight);
        } else {
            label.frame = CGRectMake(20, 6, SectionHeaderWidth, SectionHeaderHeight);
            
        }
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.numberOfLines = 2;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:16];
        label.text = (NSString *)[headers objectAtIndex:section];
        
        
        // Create header view and add label as a subview
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SectionHeaderWidth, SectionHeaderHeight)];
        [view addSubview:label];
        return view;
        
        
        
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)table
 numberOfRowsInSection:(NSInteger)section {
    if(tableGroup != nil) {
        NSMutableArray *listData =[tableGroup objectAtIndex:section];
        return [listData count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *tableIdentifier = nil;
    
    switch (indexPath.section) {
        case 0:
            //[videoSettingsTableView setSeparatorStyle:UITableViewCellSelectionStyleDefault];
            tableIdentifier = SETTINGS_AV_HEADER;
            break;
        case 1:
            
            tableIdentifier = SETTINGS_FPS_HEADER;
            break;
        default:
            break;
    }
    
    
	NSMutableArray *listData =[tableGroup objectAtIndex:indexPath.section];
    
	UITableViewCell * cell = [tableView
                              dequeueReusableCellWithIdentifier: tableIdentifier];
    
	if(cell == nil) {
        
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:tableIdentifier];
        
        switch (indexPath.section) {
            case 0: {
                if(indexPath.row == currentWelvuSettings.audio_video) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
                break;
            case 1: {
                
                NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
               // NSLog(@"current version %@",currSysVer);
                
                NSArray *arr = [currSysVer componentsSeparatedByString:@"."];
                NSString *versionValue = [arr objectAtIndex:0];
               // NSLog(@"Version Value %@",versionValue);
                
                if([versionValue isEqualToString: @"7"]) {
                    
                    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc]
                                                            initWithItems:[NSArray arrayWithObjects:
                                                                           [UIImage imageWithContentsOfFile:SEGMENT_LOW_IMAGE_PNG],[UIImage imageWithContentsOfFile:SEGMENT_MEDIUM_IMAGE_PNG],[UIImage imageWithContentsOfFile:SEGMENT_HIGH_IMAGE_PNG], nil]];
                    //segmentedControl.frame = CGRectMake(60, 0, 440, 40);
                    CGRect segFrame=segmentedControl.frame;
                    segFrame.size.height=40;
                    segFrame.size.width=430;
                    segmentedControl.frame=segFrame;
                    
                    
                    
                    [segmentedControl addTarget:self action:@selector(sortFPSSegmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
                    segmentedControl.selectedSegmentIndex = [self selectedFPSChoice:currentWelvuSettings.fps];
                    segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
                    // segmentedControl.tintColor = [UIColor colorWithRed:30.0 / 256.0 green:52.0 / 256.0 blue:162.0 / 256.0 alpha:1.0];
                    segmentedControl.tintColor =[UIColor colorWithRed:0/255.0 green:71/255.0 blue:109/255.0 alpha:1.0];
                    
                    cell.accessoryView = segmentedControl;
                    cell.backgroundColor=[UIColor clearColor];
                    
                   // NSLog(@"higher ios 7");
                    
                }else {
                  //  NSLog(@"ios 7 low");
                    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:@"Low.png"], [UIImage imageNamed:@"Medium.png"],[UIImage imageNamed:@"High.png"], nil]];
                    segmentedControl.frame = CGRectMake(0, 0, 385, 40);
                    segmentedControl.frame = CGRectMake(0, 0, 385, 40);
                    [segmentedControl addTarget:self action:@selector(sortFPSSegmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
                    segmentedControl.selectedSegmentIndex = [self selectedFPSChoice:currentWelvuSettings.fps];
                    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
                    
                    segmentedControl.tintColor =[UIColor colorWithRed:0/255.0 green:71/255.0 blue:109/255.0 alpha:1.0];
                    //                    segmentedControl.tintColor = [UIColor colorWithRed:49.0 / 256.0 green:148.0 / 256.0 blue:208.0 / 256.0 alpha:1];
                    
                    cell.accessoryView = segmentedControl;
                    cell.backgroundColor=[UIColor clearColor];
                    
                }
            }
                break;
            default:
                break;
        }
	}
    if (!indexPath.section == 1) {
        cell.textLabel.text = [listData objectAtIndex:indexPath.row];
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
	return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    appDelegate.isSettingsChanged = TRUE;
    switch (indexPath.section) {
        case 0: {
            currentWelvuSettings.audio_video = indexPath.row;
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
            break;
        case 1: {
            currentWelvuSettings.fps = [self selectedFPSValue:indexPath.row];
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        }
            break;
        default:
            break;
    }
    if(indexPath.section == 0 || indexPath.section == 1) {
        for(int i = 0; i < [[self.tableGroup objectAtIndex:indexPath.section] count];i++) {
            if(i != indexPath.row) {
                UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark view
- (void)viewDidLoad
{
    [super viewDidLoad];
    //Declaring Page View Analytics
       appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Video Settings VU - VS"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    

    
    headerLabel.text = NSLocalizedString(@"SETTINGS_VIDEO_HEADER", nil);
    videoSettingsTableView.layer.cornerRadius = 10;
    // Do any additional setup after loading the view from its nib.
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
