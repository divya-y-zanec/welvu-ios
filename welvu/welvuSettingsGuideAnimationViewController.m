//
//  welvuSettingsGuideAnimationViewController.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 26/04/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "welvuSettingsGuideAnimationViewController.h"

@interface welvuSettingsGuideAnimationViewController ()

@end

@implementation welvuSettingsGuideAnimationViewController
@synthesize backgroundSwitch,isAnimated;
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
        // Custom initialization
    }
    return self;
}
//initlizing with guide animation
- (id)initWithGuideAnimatiom:(welvu_settings *) welvu_settings
{
    
    self = [super initWithNibName:@"welvuSettingsGuideAnimationViewController" bundle:nil];
    if (self) {
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil)
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(doneBtnClicked:)];
        self.navigationItem.rightBarButtonItem = doneBtn;
        
        currentWelvuSettings = welvu_settings;
        headers = [[NSMutableArray alloc] initWithCapacity:1];
        
        [headers addObject:NSLocalizedString(@"CONTENT_GUIDE_ANIMATION", nil)];
        
    }
    return self;
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];

    //Declaring Page View Analytics
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Animated Assistance Settings - ASS"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];

    
    /* if(backgroundSwitch.isOn)
     {
     NSLog(@"animation on load");
     }
     else
     {
     NSLog(@"animation Off load"); }*/
    
    
    headerLabel.text = NSLocalizedString(@"SETTINGS_SPECIALTY_HEADER", nil);
    
    // Do any additional setup after loading the view from its nib.
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
                UISwitch *backgroundSwitch = [[UISwitch alloc] init];
                [backgroundSwitch addTarget:self action:@selector(debugGridBackgroundSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            
                [backgroundSwitch setOn:currentWelvuSettings.isAnimationOn animated:YES];
                [backgroundSwitch sizeToFit];
                [backgroundSwitch setOnTintColor:[UIColor colorWithRed:0/255.0 green:71/255.0 blue:109/255.0 alpha:1.0]];
                cell.accessoryView = backgroundSwitch;
            }
                break;
                
                
        }
    }
    
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [headers objectAtIndex:row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
     cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
	return cell;
}


- (void)debugGridBackgroundSwitchChanged:(UISwitch *)control
{
    appDelegate.isSettingsChanged = TRUE;

    if(control.isOn) {
     currentWelvuSettings.isAnimationOn = TRUE;
           [backgroundSwitch setOnTintColor:[UIColor colorWithRed:0/255.0 green:71/255.0 blue:109/255.0 alpha:1.0]];
    } else {
     currentWelvuSettings.isAnimationOn = FALSE;
    }
}

//Done button clicked 
-(IBAction)doneBtnClicked:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Animated Assistance Settings - ASS"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Animated Assistance Settings - ASS"
                    
                                                          action:@"Done Button- ASS"
                                                           label:@"Save"
                                                           value:nil] build]];
    
    @try {
       
   
    
        if(appDelegate.isSettingsChanged == TRUE){
            
            [self.delegate welvuSettingsGuideAnimationDidFinish];
        }
        appDelegate.isSettingsChanged = FALSE;
        [self.delegate welvuSettingsGuideAnimationDidClose];

    } @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Animated Assistance Settings - ASS_Save:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }

    }

//Naviagate to previous view
-(IBAction)backBtnClicked:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Animated Assistance Settings - ASS"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Animated Assistance Settings - ASS"
                    
                                                          action:@"Go Back - ASS"
                                                           label:@"Back"
                                                           value:nil] build]];
    
    @try {
        
        
        if(appDelegate.isSettingsChanged == TRUE){
            
            [self.delegate welvuSettingsGuideAnimationDidFinish];
        }
        appDelegate.isSettingsChanged = FALSE;
        [self.navigationController popViewControllerAnimated:YES];
    } @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"Animated Assistance Settings - ASS_Back:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
