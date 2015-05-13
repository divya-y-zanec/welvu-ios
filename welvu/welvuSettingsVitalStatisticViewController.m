//
//  welvuSettingsVitalStatisticViewController.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 06/11/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "welvuSettingsVitalStatisticViewController.h"
#import "welvuContants.h"

@interface welvuSettingsVitalStatisticViewController ()
@end

@implementation welvuSettingsVitalStatisticViewController
@synthesize delegate ,headers ,tableGroup;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"SETTINGS_VITAL_STATISTICS_CHANGE", nil);
        
        // Custom initialization
    }
    return self;
}
/*
 - (id)initWithTopicSortSettings:(welvu_settings *) welvu_settings {
 self = [super initWithNibName:@"welvuSettingsVitalStatisticViewController" bundle:nil];
 if (self) {
 UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil)
 style:UIBarButtonItemStyleBordered
 target:self
 action:@selector(doneBtnClicked:)];
 self.navigationItem.rightBarButtonItem = doneBtn;
 
 currentWelvuSettings = welvu_settings;
 headers = [[NSMutableArray alloc] init];
 [headers addObject:SETTINGS_VITAL_WEALTH_HEADER];
 [headers addObject:SETTINGS_VITAL_HEALTH_HEADER];
 [headers addObject:SETTINGS_VITAL_TEMPERATURE_HEADER];
 [headers addObject:SETTINGS_VITAL_BPDANDBPD_HEADER];
 [headers addObject:SETTINGS_VITAL_BMI_HEADER];
 
 
 NSMutableArray *audio_video = [NSMutableArray arrayWithObjects:SETTINGS_VITALS_WEIGHT_LBS, SETTINGS_VITALS_WEIGHT_KG, nil];
 
 NSMutableArray *fpsControl = [NSMutableArray arrayWithObjects:SETTINGS_VITALS_HEIGHT_CM,SETTINGS_VITALS_HEIGHT_INCHES, /*SETTINGS_FPS_20_TEXT, SETTINGS_FPS_30_TEXT,*/ //nil];

/* NSMutableArray *vital_Temperature = [NSMutableArray arrayWithObjects:SETTINGS_VITALS_TEMPERATURE_FAHRENHEIT, SETTINGS_VITALS_TEMPERATURE_CELSIUS, nil];
 
 NSMutableArray *vital_bpsandBpd = [NSMutableArray arrayWithObjects:SETTINGS_VITAL_BPDANDBPD_HEADER, nil];
 
 NSMutableArray *vital_bmi = [NSMutableArray arrayWithObjects:SETTINGS_VITAL_BMI_HEADER, nil];
 
 tableGroup = [[NSMutableArray alloc] init];
 [tableGroup addObject:audio_video];
 [tableGroup addObject:fpsControl];
 [tableGroup addObject:vital_Temperature];
 [tableGroup addObject:vital_bpsandBpd];
 [tableGroup addObject:vital_bmi];
 
 
 }
 return self;
 }
 */

-(id)initwithVitalSettings:(welvu_settings *)welvu_settings_model {
  //  self = [super initWithNibName:@"welvuSettingsVitalStatisticViewController" bundle:nil];
    
    
    if (self) {
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil)
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(doneBtnClicked:)];
        self.navigationItem.rightBarButtonItem = doneBtn;
        
        currentWelvuSettings = welvu_settings_model;
        headers = [[NSMutableArray alloc] init];
        [headers addObject:SETTINGS_VITAL_WEALTH_HEADER];
        [headers addObject:SETTINGS_VITAL_HEALTH_HEADER];
        [headers addObject:SETTINGS_VITAL_TEMPERATURE_HEADER];
        [headers addObject:SETTINGS_VITAL_BPDANDBPD_HEADER];
        [headers addObject:SETTINGS_VITAL_BMI_HEADER];
        
        
        NSMutableArray *audio_video = [NSMutableArray arrayWithObjects:SETTINGS_VITALS_WEIGHT_LBS, SETTINGS_VITALS_WEIGHT_KG, nil];
        
        NSMutableArray *fpsControl = [NSMutableArray arrayWithObjects:SETTINGS_VITALS_HEIGHT_CM,SETTINGS_VITALS_HEIGHT_INCHES, /*SETTINGS_FPS_20_TEXT, SETTINGS_FPS_30_TEXT,*/ nil];
        
        NSMutableArray *vital_Temperature = [NSMutableArray arrayWithObjects:SETTINGS_VITALS_TEMPERATURE_FAHRENHEIT, SETTINGS_VITALS_TEMPERATURE_CELSIUS, nil];
        
        NSMutableArray *vital_bpsandBpd = [NSMutableArray arrayWithObjects:SETTINGS_VITAL_BPDANDBPD_HEADER, nil];
        
        NSMutableArray *vital_bmi = [NSMutableArray arrayWithObjects:SETTINGS_VITAL_BMI_HEADER, nil];
        
        tableGroup = [[NSMutableArray alloc] init];
        [tableGroup addObject:audio_video];
        [tableGroup addObject:fpsControl];
        [tableGroup addObject:vital_Temperature];
        [tableGroup addObject:vital_bpsandBpd];
        [tableGroup addObject:vital_bmi];
        
        
    }
    return self;
    
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Vital Statistics - VS"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];

    
    //appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark UITableView Delegate




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
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(20, 6, SectionHeaderWidth, SectionHeaderHeight);
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
            tableIdentifier = SETTINGS_VITAL_WEALTH_HEADER;
            break;
        case 1:
            
            tableIdentifier = SETTINGS_VITAL_HEALTH_HEADER;
            break;
        case 2:
            
            tableIdentifier = SETTINGS_VITAL_TEMPERATURE_HEADER;
            break;
        case 3:
            
            tableIdentifier = SETTINGS_VITAL_BPDANDBPD_HEADER;
            break;
            
        case 4:
            
            tableIdentifier = SETTINGS_VITAL_BMI_HEADER;
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
                cell.textLabel.text = [listData objectAtIndex:indexPath.row];
                
                if(indexPath.row == currentWelvuSettings.weight) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
                break;
            case 1: {
                /*
                 UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:@"Low.png"], [UIImage imageNamed:@"Medium.png"],[UIImage imageNamed:@"High.png"], nil]];
                 segmentedControl.frame = CGRectMake(0, 0, 428, 40);
                 segmentedControl.frame = CGRectMake(0, 0, 428, 40);
                 [segmentedControl addTarget:self action:@selector(sortFPSSegmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
                 segmentedControl.selectedSegmentIndex = [self selectedFPSChoice:currentWelvuSettings.fps];
                 segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
                 
                 UIColor *newTintColor = [UIColor colorWithRed:0.07 green:0.45 blue:0.69  alpha:0.5];
                 segmentedControl.tintColor = newTintColor;
                 
                 cell.accessoryView = segmentedControl;
                 cell.backgroundColor=[UIColor clearColor];
                 */
                
                cell.textLabel.text = [listData objectAtIndex:indexPath.row];
                if(indexPath.row == currentWelvuSettings.height) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
                
                
            }
                break;
            case 2: {
                if(indexPath.row == currentWelvuSettings.temperature) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                cell.textLabel.text = [listData objectAtIndex:indexPath.row];
            }
                break;
                
            case 3: {
                if(indexPath.row == currentWelvuSettings.bpsandbpd) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                cell.textLabel.text = [listData objectAtIndex:indexPath.row];
            }
                break;
                
            case 4: {
                if(indexPath.row == currentWelvuSettings.bmi) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                cell.textLabel.text = [listData objectAtIndex:indexPath.row];
            }
                break;
            default:
                break;
        }
	}
    
    
	return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    appDelegate.isSettingsChanged = TRUE;
    switch (indexPath.section) {
        case 0: {
            currentWelvuSettings.weight = indexPath.row;
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
            break;
        case 1: {
            currentWelvuSettings.height =  indexPath.row;
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        }
            break;
        case 2: {
            currentWelvuSettings.temperature =  indexPath.row;
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        }
            break;
            
        case 3: {
            currentWelvuSettings.bpsandbpd =  indexPath.row;
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        }
            break;
        case 4: {
            currentWelvuSettings.bmi =  indexPath.row;
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        }
            break;
        default:
            break;
    }
    if(indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2) {
        for(int i = 0; i < [[self.tableGroup objectAtIndex:indexPath.section] count];i++) {
            if(i != indexPath.row) {
                UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(IBAction)backBtnClicked:(id)sender {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Vital Statistics - VS"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Vital Statistics - VS"
                                                          action:@"Go Back - VS"
                                                           label:@"Back"
                                                           value:nil] build]];
    
    @try {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Vital Statistics - VS-Back :%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
        
    }
}
-(IBAction)doneBtnClicked:(id)sender {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Vital Statistics - VS"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Vital Statistics - VS"
                                                          action:@"Save Button - VS"
                                                           label:@"Save"
                                                           value:nil] build]];
    
    
    
    @try {
        
        
        [self.delegate VitalStatisticViewControllerDidFinish];
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Vital Statistics - VS_Save:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
