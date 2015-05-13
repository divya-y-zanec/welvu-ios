//
//  welvuSettingsThemeViewController.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 03/09/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "welvuSettingsThemeViewController.h"
#import "welvuContants.h"
#import "GAI.h"

@interface welvuSettingsThemeViewController ()

@end

@implementation welvuSettingsThemeViewController

@synthesize delegate;
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
        self.title = NSLocalizedString(@"SETTINGS_THEME_CHANGE", nil);
    }
    return self;
}
/*
 * Method name: initWithTopicSortSettings
 * Description: initlizing with Topic settings
 * Parameters: welvu_settings
 * return self
 */
- (id)initWithThemeSettings:(welvu_settings *) welvu_settings {
    self = [super initWithNibName:@"welvuSettingsThemeViewController" bundle:nil];
    if (self) {
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil)
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(doneBtnClicked:)];
        self.navigationItem.rightBarButtonItem = doneBtn;
        
        currentWelvuSettings = welvu_settings;
        headers = [[NSMutableArray alloc] initWithCapacity:2];
        
        [headers addObject:NSLocalizedString(@"CONTENT_SHOW_THEME1", nil)];
        [headers addObject:NSLocalizedString(@"CONTENT_SHOW_THEME2", nil)];
        [headers addObject:NSLocalizedString(@"CONTENT_SHOW_THEME3", nil)];
        [headers addObject:NSLocalizedString(@"CONTENT_SHOW_THEME4", nil)];

        
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
    
    [tracker set:kGAIScreenName value:@"Theme View Settings - TVS"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Theme View Settings - TVS"
                    
                                                          action:@"Done Button - TVS"
                                                           label:@"Save"
                                                           value:nil] build]];
    

    
    @try {
        
        [self.delegate themeSettingsViewControllerDidFinish];
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Theme View Settings - TVS_Save:%@",exception];
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
    
    [tracker set:kGAIScreenName value:@"Theme View Settings - TVS"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Theme View Settings - TVS"
                    
                                                          action:@"Go Back - TVS"
                                                           label:@"Back"
                                                           value:nil] build]];

    
    @try {
        [self.delegate themeSettingsViewControllerDidFinish];
        [self.navigationController popViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Theme View Settings - TVS_Back:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];

        
    }
}
#pragma mark UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)table
 numberOfRowsInSection:(NSInteger)section {
    return [headers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SimpleTableIdentifier = nil;
    SimpleTableIdentifier = NSLocalizedString(@"SETTINGS_TOPIC_SORT_HEADER", nil);
    
	UITableViewCell * cell = [tableView
                              dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
    
	if(cell == nil) {
        
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:SimpleTableIdentifier];
        if(indexPath.row == currentWelvuSettings.welvu_themeChange) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [headers objectAtIndex:row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //ios 7
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    cell.backgroundColor = [UIColor whiteColor];
	return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    currentWelvuSettings.welvu_themeChange = indexPath.row;
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectedTextColor = [UIColor greenColor];
      if(indexPath.section == 0) {
        for(int i = 0; i < [headers count]; i++) {
            if(i != indexPath.row) {
                UITableViewCell* cell = [tableView cellForRowAtIndexPath:
                                         [NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                cell.accessoryType = UITableViewCellAccessoryNone;
              
            }
        }
    }
    NSString *tableName =[headers objectAtIndex:indexPath.row];
   // NSLog(@" tabletextname %@",tableName);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:tableName forKey:@"TableFirstName"];
    
//    if([tableName isEqualToString:@"Theme1"]) {
//         cell.backgroundColor = [UIColor purpleColor];
//    } else if([tableName isEqualToString:@"Theme2"]) {
//        cell.backgroundColor = [UIColor redColor];
//    } else {
//        cell.backgroundColor = [UIColor greenColor];
//    }
    
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //Declaring Page View Analytics
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Theme View Settings - TVS"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];


    headerLabel.text = NSLocalizedString(@"SETTINGS_THEME_CHANGE", nil);
    //topicSortTableView.layer.cornerRadius = 10;
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
