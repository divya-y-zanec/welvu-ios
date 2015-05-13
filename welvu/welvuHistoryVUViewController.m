//
//  HistoryVUViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 24/10/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvuHistoryVUViewController.h"
#import "welvu_history.h"
#import "GAI.h"

@interface welvuHistoryVUViewController ()
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation welvuHistoryVUViewController

@synthesize delegate;

@synthesize welvuHistoryModels, historyTableView, previousSelectedHistoryId;

@synthesize fadeColor = fadeColor_;
@synthesize baseColor = baseColor_;

@synthesize topFadingView = _topFadingView;
@synthesize bottomFadingView = _bottomFadingView;

@synthesize g1 = g1_;
@synthesize g2 = g2_;

@synthesize fadeOrientation = fadeOrientation_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.fadeOrientation = FADE_TOPNBOTTOM;
        //r: 244 g: 172 b:36
        self.baseColor = [UIColor colorWithRed:244 green:172 blue:36 alpha:1.0f];
        previousSelectedHistoryId = 0;
        self.navigationItem.hidesBackButton = YES;
        UIToolbar* toolbarLeft = [[UIToolbar alloc]
                                  initWithFrame:CGRectMake(0, 0, 50, 44)];
        
        // create an array for the buttons
        NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:1];
        
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(backBtnClicked:)];
        [buttons addObject:back];
        
        [toolbarLeft setItems:buttons animated:NO];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithCustomView:toolbarLeft];
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

/*
 * Method name: backBtnClicked
 * Description: navigate to another view
 * Parameters: id
 * return
 
 * Created On: 19-dec-2012
 */
-(IBAction)backBtnClicked:(id)sender {
    //declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"welvuTopicVUviewController"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"welvuTopicVUviewController"
                                                          action:@"backBtnClicked"
                                                           label:@"back"
                                                           value:nil] build]];
    

    
    
    @try {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
               
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"welvuHistoryVUViewController_backBtnClicked: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];

        
    }
}


// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return [[self.fetchedResultsController sections] count];
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [welvuHistoryModels count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate historyVUSelectedNumber:((welvu_history *)[welvuHistoryModels objectAtIndex:indexPath.row]).history_number];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: YEAR_MONTHFULL_DATE_TIME_FORAMAT];
    UIView *selectionView = [[UIView alloc]initWithFrame:cell.bounds];
    [selectionView setBackgroundColor:[UIColor colorWithRed:0.94f green:0.67f blue:0.14f alpha:1.0f]];
    cell.selectedBackgroundView = selectionView;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    cell.textLabel.text = [dateFormatter stringFromDate:((welvu_history *)
                                                         [welvuHistoryModels objectAtIndex:indexPath.row]).createdDate];
    //cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.numberOfLines = 2;
    
    cell.tag = ((welvu_history *)[welvuHistoryModels objectAtIndex:indexPath.row]).history_number;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
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

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //Declaring Page View Analytics
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"welvuHistoryVUViewController"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];

    
       // Do any additional setup after loading the view from its nib.
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger maxHistoryNumber = [welvu_history getMaxHistoryNumber:appDelegate.getDBPath:appDelegate.specialtyId];
    welvuHistoryModels = [[NSMutableArray alloc] initWithCapacity:maxHistoryNumber];
    for(int i = 1; i <= maxHistoryNumber; i++) {
        if([welvu_history isHistoryNumberExist:appDelegate.getDBPath:appDelegate.specialtyId :i]) {
            [welvuHistoryModels addObject:[welvu_history getFirstHistoryByHistoryNumber:appDelegate.getDBPath:appDelegate.specialtyId:i]];
        }
    }
    
    self.g1.frame = self.topFadingView.frame;
    self.g2.frame = self.topFadingView.frame;
    [self.topFadingView.layer insertSublayer:self.g1 atIndex:0];
    [self.bottomFadingView.layer insertSublayer:self.g2 atIndex:0];
    self.topFadingView.hidden = true;
    self.bottomFadingView.hidden = true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
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
}
@end
