//
//  TopicSortSettingsViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 25/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "welvuTopicSortSettingsViewController.h"
#import "welvuContants.h"
#import "GAI.h"

@interface welvuTopicSortSettingsViewController ()

@end

@implementation welvuTopicSortSettingsViewController

@synthesize delegate, headers;
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
        self.title = NSLocalizedString(@"SETTINGS_TOPIC_SORT_HEADER", nil);
    }
    return self;
}
/*
 * Method name: initWithTopicSortSettings
 * Description: initlizing with Topic settings
 * Parameters: welvu_settings
 * return self
 */
- (id)initWithTopicSortSettings:(welvu_settings *) welvu_settings {
    self = [super initWithNibName:@"welvuTopicSortSettingsViewController" bundle:nil];
    if (self) {
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil)
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(doneBtnClicked:)];
        self.navigationItem.rightBarButtonItem = doneBtn;
        
        currentWelvuSettings = welvu_settings;
        headers = [[NSMutableArray alloc] initWithCapacity:2];
        
        [headers addObject:NSLocalizedString(@"CONTENT_ALBHABITICAL_ORDER_TEXT", nil)];
        [headers addObject:NSLocalizedString(@"CONTENT_MOST_POPULAR_ORDER_TEXT", nil)];
        [headers addObject:NSLocalizedString(@"CONTENT_MOST_DEFAULT_ORDER_TEXT", nil)];

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
    
    [tracker set:kGAIScreenName value:@"Topic Sort Settings - TS"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Topic Sort Settings - TS"

                                                          action:@"Done Button - TS"
                                                           label:@"Save"
                                                           value:nil] build]];
    

    
    @try {
        
        if(appdelegate.isSettingsChanged == TRUE){
            [self.delegate topicSettingsViewControllerDidFinish];
        }
        appdelegate.isSettingsChanged = FALSE;        [self.delegate topicSettingsViewControllerDidClose];

    }
    @catch (NSException *exception) {
              
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"TopicSortSettings-TS_Save:%@",exception];
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
    
    [tracker set:kGAIScreenName value:@"Topic Sort Settings - TS"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Topic Sort Settings - TS"
                    
                                                          action:@"Go Back - TS"
                                                           label:@"Back"
                                                           value:nil] build]];
    

    @try {
        if(appdelegate.isSettingsChanged == TRUE){
            [self.delegate topicSettingsViewControllerDidFinish];
        }
        appdelegate.isSettingsChanged = FALSE;
        [self.navigationController popViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
        
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"TopicSortSettings-TS_Back:%@",exception];
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
        if(indexPath.row == currentWelvuSettings.welvu_topic_list_order) {
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
    appdelegate.isSettingsChanged = TRUE;
    currentWelvuSettings.welvu_topic_list_order = indexPath.row;
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    if(indexPath.section == 0) {
        for(int i = 0; i < [headers count]; i++) {
            if(i != indexPath.row) {
                UITableViewCell* cell = [tableView cellForRowAtIndexPath:
                                         [NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
}
#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    //Declaring Page View Analytics
  
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Topic Sort Settings - TS"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    

    appdelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];

    
    headerLabel.text = NSLocalizedString(@"SETTINGS_TOPIC_SORT_HEADER", nil);
    topicSortTableView.layer.cornerRadius = 10;
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
