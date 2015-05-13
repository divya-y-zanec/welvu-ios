//
//  welvuBlankCanvasColorSettingsViewController.m
//  welvu
//
//  Created by Divya Yadav. on 06/11/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "welvuBlankCanvasColorSettingsViewController.h"
#import "welvuContants.h"
#import "GMGridViewLayoutStrategies.h"
#import "GMGridView.h"
#import "GAI.h"

@interface welvuBlankCanvasColorSettingsViewController ()

@end

@implementation welvuBlankCanvasColorSettingsViewController
@synthesize headers;
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
        self.title = NSLocalizedString(@"SETTINGS_BLANK_CANVAS_COLOR_HEADER", nil);
        
        
    }
    return self;
}
/*
 * Method name: initWithBlankCanvasColorSettings
 * Description: initlizing with blank canvas color 
 * Parameters: welvu_settings
 * return self
 */
- (id)initWithBlankCanvasColorSettings:(welvu_settings *) welvu_settings {
    self = [super initWithNibName:@"welvuBlankCanvasColorSettingsViewController" bundle:nil];
    if (self) {
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil)
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(doneBtnClicked:)];
        self.navigationItem.rightBarButtonItem = doneBtn;
        currentWelvuSettings = welvu_settings;
        headers = [[NSMutableArray alloc] initWithCapacity:3];
        [headers addObject:NSLocalizedString(@"CANVAS_COLOR_WHITE", nil)];
        [headers addObject:NSLocalizedString(@"CANVAS_COLOR_BLACK", nil)];
        [headers addObject:NSLocalizedString(@"CANVAS_COLOR_GREEN", nil)];
        
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
    
    [tracker set:kGAIScreenName value:@"Blank Canvas Settings VU - BCS"];
[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Blank Canvas Settings VU - BCS"
                    
                                                          action:@"Settings Confirmed - BCS"

                                                           label:@"Save"
                                                           value:nil] build]];


    @try {
        
        if(appDelegate.isSettingsChanged == TRUE){
            
            [self.delegate blankSettingsViewControllerDidFinish];
        }
        appDelegate.isSettingsChanged = FALSE;        [self.delegate blankSettingsViewControllerDidClose];
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"BlankCanvasSettings-BCS_Save:%@",exception];
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
    
    [tracker set:kGAIScreenName value:@"Blank Canvas Settings VU - BCS"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Blank Canvas Settings VU - BCS"
                    
                                                          action:@"Go Back - BCS"
                                                           label:@"Back"
                                                           value:nil] build]];

    @try {
        if(appDelegate.isSettingsChanged == TRUE){
            
            [self.delegate blankSettingsViewControllerDidFinish];
        }
        appDelegate.isSettingsChanged = FALSE;
        [self.navigationController popViewControllerAnimated:YES];
    
    }
    @catch (NSException *exception) {
        
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"BlankCanvasSettings-BCS_Back:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];

        
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
    SimpleTableIdentifier = NSLocalizedString(@"SETTINGS_BLANK_CANVAS_COLOR_HEADER", nil);
    
	UITableViewCell * cell = [tableView
                              dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
    
	if(cell == nil) {
        
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:SimpleTableIdentifier];
        
        if(indexPath.row == currentWelvuSettings.welvu_blank_canvas_color) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [headers objectAtIndex:row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
     cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
	return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    appDelegate.isSettingsChanged = TRUE;
    currentWelvuSettings.welvu_blank_canvas_color = indexPath.row;
    
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

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //Declaring Page View Analytics

    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Blank Canvas Settings VU - BCS"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];

    headerLabel.text = NSLocalizedString(@"SETTINGS_BLANK_CANVAS_COLOR_HEADER", nil);
    blankTableView.layer.cornerRadius = 10;
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

