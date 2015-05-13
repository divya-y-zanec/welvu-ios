//
//  welvuTopicViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 19/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvuTopicViewController.h"
#import "welvu_topics.h"
#import "welvuTopicVUSubViewController.h"
#import "GAI.h"

//Controller private method declaration
@interface welvuTopicViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation welvuTopicViewController

//Synthesizing the object defined in the interface properties
@synthesize delegate, topicTableView, welvu_topicsModels;
@synthesize fadeColor = fadeColor_;
@synthesize baseColor = baseColor_;
@synthesize topFadingView = _topFadingView;
@synthesize bottomFadingView = _bottomFadingView;
@synthesize g1 = g1_;
@synthesize g2 = g2_;
@synthesize fadeOrientation = fadeOrientation_;

//Default controller intialization method
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Topics";
        //ios 8
        self.preferredContentSize = CGSizeMake(320.0, 598.0);
       // self.contentSizeForViewInPopover = CGSizeMake(320.0, 598.0);
        self.fadeOrientation = FADE_TOPNBOTTOM;
        self.baseColor = [UIColor colorWithRed:244 green:172 blue:36 alpha:1.0f];
    }
    return self;
}

//Custom controller intialization method
- (id)initWithExistingImagesModel:(NSMutableArray *)welvu_imagesModels {
    self = [super initWithNibName:@"welvuTopicViewController" bundle:nil];
    if (self) {
        self.title = @"Topics";
         self.preferredContentSize = CGSizeMake(320.0, 598.0);
       // self.contentSizeForViewInPopover = CGSizeMake(320.0, 598.0);
        self.fadeOrientation = FADE_TOPNBOTTOM;
        self.baseColor = BASE_COLOR;
        welvuImagesModels = welvu_imagesModels;
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
#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    //Declaring Page View Analytics
    headerLabel.text = @"Topics";
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Add VU -TopicList"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    //Intialize the Application delegate
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
   // self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"AddVUBg.png"]];
    self.g1.frame = self.topFadingView.frame;
    self.g2.frame = self.topFadingView.frame;
    [self.topFadingView.layer insertSublayer:self.g1 atIndex:0];
    [self.bottomFadingView.layer insertSublayer:self.g2 atIndex:0];
    self.topFadingView.hidden = true;
    self.bottomFadingView.hidden = true;
}

- (void)viewDidUnload  {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Get topics from the database
    welvu_topicsModels = [welvu_topics getAllTopics:appDelegate.getDBPath:appDelegate.specialtyId
                                             userId:appDelegate.welvu_userModel.welvu_user_id];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(topicTableView.contentSize.height > topicTableView.frame.size.height) {
        self.bottomFadingView.hidden = false;
    }
}

#pragma  MARK UITableView DELEGATE METHODS
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //return [[self.fetchedResultsController sections] count];
    return 1;
    
}

//Default method for assigning number of rows for the tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [welvu_topicsModels count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    //ios 7
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

//Push the topic images view controller when a particular topic is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    welvuTopicVUSubViewController *targetController = [[welvuTopicVUSubViewController alloc]
                                                       initWithWelvuTopic:(welvu_topics *)[welvu_topicsModels objectAtIndex:indexPath.row]
                                                       :welvuImagesModels];
    targetController.delegate = self;
	[self.navigationController pushViewController:targetController animated:YES];
    targetController = nil;
}

//TableView cell customization and setting label for the cell
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UIView *selectionView = [[UIView alloc]initWithFrame:cell.bounds];
    if(!((welvu_topics *)[welvu_topicsModels objectAtIndex:indexPath.row]).topic_is_user_created) {
        [selectionView setBackgroundColor:[UIColor colorWithRed:0.94f green:0.67f blue:0.14f alpha:1.0f]];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    } else {
        [selectionView setBackgroundColor:[UIColor colorWithRed:0.94f green:0.67f blue:0.14f alpha:1.0f]];
        cell.textLabel.font = [UIFont italicSystemFontOfSize:16.0f];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white_arrow.png"]];
    cell.selectedBackgroundView = selectionView;
    cell.textLabel.text = ((welvu_topics *)[welvu_topicsModels objectAtIndex:indexPath.row]).topicName;
    cell.textLabel.textColor = [UIColor blackColor];
    
}


//Delegate method called from welvuTopicVUViewController with selected image,
//which will be send to the parent controller which called this view controller
- (void) welvuTopicVUViewControllerDidFinish:(welvu_images *)welvu_imagesModel {
    [self.delegate welvuTopicViewControllerDidFinish:welvu_imagesModel];
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
#pragma  mark UIInterfaceOrientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
