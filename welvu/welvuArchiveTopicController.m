//
//  welvuArchiveTopicController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 22/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvuArchiveTopicController.h"
#import "welvuTopicArchiveTableCell.h"
#import "welvuContants.h"
#import "welvu_topics.h"
#import "GAI.h"

//Controller private method declaration
@interface welvuArchiveTopicController () {
    BOOL isModified;
}
- (void)configureCell:(welvuTopicArchiveTableCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation welvuArchiveTopicController
//Synthesizing the object defined in the interface properties
@synthesize delegate, topicTableView, welvu_topicsModels;
@synthesize counter,update;
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
        isModified = false;
        self.fadeOrientation = FADE_TOPNBOTTOM;
        self.baseColor = [UIColor colorWithRed:244 green:172 blue:36 alpha:1.0f];
        
        
        UIToolbar* toolbarLeft = [[UIToolbar alloc]
                                  initWithFrame:CGRectMake(0, 0, 40, 44)];
        
        // create an array for the buttons
        NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:8];
        
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(backBtnClicked:)];
        [buttons addObject:back];
        
        [toolbarLeft setItems:buttons animated:NO];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithCustomView:toolbarLeft];
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                      target:self
                                      action:@selector(doneBtnClicked:)];
        addButton.style = UIBarButtonItemStyleBordered;
        self.navigationItem.rightBarButtonItem = addButton;
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
 * Method name: topicSelected
 * Description: selecting topic
 * Parameters: analytics
 * return topic
 * Created On: 19-dec-2012
 */
-(IBAction)topicSelected:(id)sender {
    //Declaring EventTrackiing Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder  createEventWithCategory:@"welvuArchieveTopicController"
                                             action:@"topicSelected"
                                              label:@"topicselectingtopic"
                                              value:nil] build];

    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];

    
 

    
    @try {
        
        
        isModified = true;
        UIButton *btn = (UIButton *) sender;
        if(btn.selected) {
            counter= counter+1;
            btn.selected = false;
            ((welvu_topics *)[welvu_topicsModels objectAtIndex:[btn tag]]).topic_active = false;

            
        } else {
            counter= counter - 1;
            btn.selected = true;
            ((welvu_topics *)[welvu_topicsModels objectAtIndex:[btn tag]]).topic_active = true;

        }
        
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
                NSString * description = [NSString stringWithFormat:@"welvuArchiveTopicController_topicSelected:%@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        

        
        
    }
}
/*
 * Method name: doneBtnClicked
 * Description: clickdonebuttontoshowalertview
 * Parameters: analytics
 * return self
 * Created On: 19-dec-2012
 */
-(IBAction)doneBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"welvuArchieveTopicController"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"welvuArchieveTopicController"
                                                          action:@"doneBtnClicked"
                                                           label:@"save"
                                                           value:nil] build]];


    
    @try {
        
        
        if (counter== 0) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: NSLocalizedString(@"ALERT_NO_CONTENT_SELECTED_TITLE",nil)
                                  message: NSLocalizedString(@"ALERT_NO_TOPIC_SELECTED_MSG",nil)
                                  delegate: nil
                                  cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                  otherButtonTitles:nil];
            alert.tag = 1;
            [alert show];
        }
        else{
            for(welvu_topics *welvu_topicModel in welvu_topicsModels) {
                if(welvu_topicModel.topic_active) {
                   update = [welvu_topics unarchiveTopic:appDelegate.getDBPath :welvu_topicModel.topicId];
                }
            }
            [self.delegate welvuArchiveForTopicDidFinish:isModified];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
               NSString * description = [NSString stringWithFormat:@"welvuArchiveTopicController_doneBtnClicked:%@",exception];

        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];

        
        
    }
}
/*
 * Method name: backBtnClicked
 * Description: navigateanotherview
 * Parameters: analytics
 * return self
 * Created On: 19-dec-2012
 */
-(IBAction)backBtnClicked:(id)sender {
    //Declaring EventTrackiing Analytics
    

    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"welvuArchieveTopicController"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"welvuArchieveTopicController"
                                                          action:@"backBtnClicked"
                                                           label:@"back"
                                                           value:nil] build]];

    
    @try {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
                NSString * description = [NSString stringWithFormat:@"welvuArchiveTopicController_backBtnClicked:%@",exception];

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

//Default method for assigning number of rows for the tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [welvu_topicsModels count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"welvuTopicArchiveTableCell";
    
    welvuTopicArchiveTableCell * cell = (welvuTopicArchiveTableCell *)[tableView
                                                                       dequeueReusableCellWithIdentifier: CellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"welvuTopicArchiveTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

//Push the topic images view controller when a particular topic is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //welvuTopicArchiveTableCell *cell = (welvuTopicArchiveTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    
}

//TableView cell customization and setting label for the cell
- (void)configureCell:(welvuTopicArchiveTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if(!((welvu_topics *)[welvu_topicsModels objectAtIndex:indexPath.row]).topic_is_user_created) {
        cell.topicLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    } else {
        cell.topicLabel.font = [UIFont italicSystemFontOfSize:17.0f];
    }
    cell.topicLabel.text = ((welvu_topics *)[welvu_topicsModels objectAtIndex:indexPath.row]).topicName;
    [cell.checkBox addTarget:self action:@selector(topicSelected:) forControlEvents:UIControlEventTouchUpInside];
    cell.checkBox.tag = indexPath.row;
    if(((welvu_topics *)[welvu_topicsModels objectAtIndex:indexPath.row]).topic_active) {
        cell.checkBox.selected = true;
    } else {
        cell.checkBox.selected = false;
    }
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Declaring Page View Analytics

    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"welvuArchiveTopicController"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];

    // Do any additional setup after loading the view from its nib.
    //Intialize the Application delegate
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.g1.frame = self.topFadingView.frame;
    self.g2.frame = self.topFadingView.frame;
    [self.topFadingView.layer insertSublayer:self.g1 atIndex:0];
    [self.bottomFadingView.layer insertSublayer:self.g2 atIndex:0];
    self.topFadingView.hidden = true;
    self.bottomFadingView.hidden = true;
    topicArchive.text = TOPIC_ARCHIVE;
    //Get topics from the database
    welvu_topicsModels = [welvu_topics getArchivedTopics:appDelegate.getDBPath:appDelegate.specialtyId];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(topicTableView.contentSize.height > topicTableView.frame.size.height) {
        self.bottomFadingView.hidden = false;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation != UIInterfaceOrientationPortrait &&
            interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    
}


- (BOOL)shouldAutorotate {
    return YES;
}
@end
