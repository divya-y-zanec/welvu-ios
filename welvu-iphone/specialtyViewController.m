//
//  welvuDetailViewController.h
//  welvu
//
//  Created by Divya yadav on 27/09/12.
//  Copyright (c) 2012 2012 ZANEC Soft Tech. All rights reserved.
//

#import "specialtyViewController.h"
#import "welvu_specialty.h"
#import "welvuViewController.h"
#import "welvuDetailViewController.h"
#import "DDMenuController.h"

@interface specialtyViewController ()
-(NSInteger) searchSpecialtyDefaultId:(NSMutableArray *) specialtyArray;
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation specialtyViewController

//Synthesizing the object defined in the interface properties
@synthesize specialtyTableView, welvu_specialtyModels;

@synthesize fadeColor = fadeColor_;
@synthesize baseColor = baseColor_;

@synthesize topFadingView = _topFadingView;
@synthesize bottomFadingView = _bottomFadingView;
//@synthesize spec

@synthesize g1 = g1_;
@synthesize g2 = g2_;

@synthesize fadeOrientation = fadeOrientation_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.fadeOrientation = FADE_TOPNBOTTOM;
        self.baseColor = [UIColor colorWithRed:244 green:172 blue:36 alpha:1.0f];
        selectedIndexRow = -1;
    }
    return self;
}

//Sets fadeColor to be 10% alpha of baseColor
/*
-(UIColor*)fadeColor {
    if (fadeColor_ == nil) {
        const CGFloat* components = CGColorGetComponents(self.baseColor.CGColor);
        fadeColor_ = [[UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:CGColorGetAlpha(self.baseColor.CGColor)*.1] retain];
    }
    return fadeColor_;
}
*/
/*

-(CAGradientLayer*)g1 {
    if (g1_ == nil) {
        g1_ = [[CAGradientLayer layer] retain];
        
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
        g2_ = [[CAGradientLayer layer] retain];
        
        if (self.fadeOrientation == FADE_LEFTNRIGHT) {
            g2_.startPoint = CGPointMake(0, 0);
            g2_.endPoint = CGPointMake(1.0, 0.5);
        }
        
        g2_.colors = [NSArray arrayWithObjects: (id)[self.fadeColor CGColor],(id)[self.baseColor CGColor], nil];
    }
    return g2_;
}
*/
-(NSInteger) searchSpecialtyDefaultId:(NSMutableArray *) specialtyArray {
    for(int i=0; i < specialtyArray.count; i++) {
        welvu_specialty *specialty = [specialtyArray objectAtIndex:i];
        if(specialty.welvu_specialty_default) {
            return i;
        }
    }
    return -1;
}
/*
-(IBAction)buttonEvent:(id)sender {
    if(((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_specialty_default ||
       ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_specialty_subscribed) {
        specialtyId = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_specialty_id;
        if(appDelegate.specialtyId != specialtyId) {
            appDelegate.specialtyId = specialtyId;
           // DDMenuController
            
            [self.view specialtyViewControllerDidFinish:YES];
        } else {
            [self.view specialtyViewControllerDidFinish:NO];
        }
    } else if(!((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_specialty_subscribed) {
        specialtyId = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_specialty_id;
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"ALERT_PURCHASE_SPECIALTY_TITLE",nil)
                              message: [NSString stringWithFormat:@"%@\"%@\"%@", NSLocalizedString(@"ALERT_PURCHASE_SPECIALTY_MSG1",nil),
                                        ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_specialty_name,
                                        NSLocalizedString(@"ALERT_PURCHASE_SPECIALTY_MSG2",nil)]
                              delegate: self
                              cancelButtonTitle:NSLocalizedString(@"CANCEL",nil)
                              otherButtonTitles:NSLocalizedString(@"PURCHASE",nil),nil];
        alert.tag = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_specialty_id;
        [alert show];
        [alert release];
    }
}
*/
-(IBAction)closeBtnClicked:(id)sender {
    
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if([alertView.title isEqualToString:NSLocalizedString(@"ALERT_PURCHASE_SPECIALTY_TITLE", nil)]) {
        if (buttonIndex == 1) {
            int update = [welvu_specialty updateSubscribedSpecialty:appDelegate.getDBPath:[alertView tag]];
            if(update > 0 && welvu_specialtyModels != nil) {
                [welvu_specialtyModels release], welvu_specialtyModels = nil;
            }
            
            if(update > 0) {
                welvu_specialtyModels = [welvu_specialty getAllSpecialty:appDelegate.getDBPath];
                [specialtyTableView reloadData];
                NSIndexPath *index = [NSIndexPath indexPathForRow:selectedIndexRow inSection:0];
                [specialtyTableView selectRowAtIndexPath:index animated:NO scrollPosition:0];
            }
        }
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
    return [welvu_specialtyModels count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndexRow = indexPath.row;
    if(((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_specialty_default ||
       ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_specialty_subscribed) {
        specialtyId = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_specialty_id;
       if(appDelegate.specialtyId != specialtyId) {
           appDelegate.specialtyId = specialtyId;
          NSLog(@"The value of integer num is %i", specialtyId);
         
          // [self.view specialtyViewControllerDidFinish:YES];
        
        } else {
            //[self.view specialtyViewControllerDidFinish:NO];
        }
   } else
        if(!((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_specialty_subscribed) {
        specialtyId = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_specialty_id;
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"ALERT_PURCHASE_SPECIALTY_TITLE",nil)
                              message: [NSString stringWithFormat:@"%@\"%@\"%@", NSLocalizedString(@"ALERT_PURCHASE_SPECIALTY_MSG1",nil),
                                        ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_specialty_name,
                                        NSLocalizedString(@"ALERT_PURCHASE_SPECIALTY_MSG2",nil)]
                              delegate: self
                              cancelButtonTitle:NSLocalizedString(@"CANCEL",nil)
                              otherButtonTitles:NSLocalizedString(@"PURCHASE",nil),nil];
        alert.tag = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:selectedIndexRow]).welvu_specialty_id;
        [alert show];
        [alert release];
    }

    
     NSLog(@"Selected IndeXPath GOING TO DELEGATE %d", indexPath.row);
    
    
 welvuDetailViewController *mainController = [[welvuDetailViewController alloc] initWithNibName:@"welvuDetailViewController" bundle:nil];
   
    NSLog(@"The value of integer num is %i", specialtyId);


UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
   // navController.sp
    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:navController];
       
   welvuViewController *leftTopicController = [[welvuViewController alloc]
                                                 initWithNibName:@"welvuViewController" bundle:nil];
    leftTopicController.previousSelectedTopicId=specialtyId
    ;       // welvuViewController *leftTopicController=[[welvuViewController alloc]init];
       
    leftTopicController.detailViewController = mainController;
   UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:leftTopicController];
  
    rootController.leftViewController = navController2;
    [self.navigationController pushViewController:rootController animated:YES];
    [rootController showLeftController:NO];
    appDelegate.ddMenuController = rootController;
    
}

//}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */
//Custom methods
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UIView *selectionView = [[UIView alloc]initWithFrame:cell.bounds];
    [selectionView setBackgroundColor:[UIColor colorWithRed:0.94f green:0.67f blue:0.14f alpha:1.0f]];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    cell.selectedBackgroundView = selectionView;
    cell.textLabel.text = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_specialty_name;
    cell.textLabel.textColor = [UIColor whiteColor];
    if(((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_specialty_default ||
       ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_specialty_subscribed) {
        UIImageView  *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        imageView.image = [UIImage imageNamed:@"selectArrowWhite.png"];
        cell.accessoryView = imageView;
    }
    cell.tag = ((welvu_specialty *)[welvu_specialtyModels objectAtIndex:indexPath.row]).welvu_specialty_id;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    if (aScrollView.contentOffset.y <= 0) {
        self.topFadingView.hidden = true;
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
      self.navigationController.navigationBarHidden=YES;
      
    
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    specialtyTableView.layer.cornerRadius = 10;
    /*self.g1.frame = self.topFadingView.frame;
     self.g2.frame = self.topFadingView.frame;
     [self.topFadingView.layer insertSublayer:self.g1 atIndex:0];
     [self.bottomFadingView.layer insertSublayer:self.g2 atIndex:0];
     self.topFadingView.hidden = true;*/
    welvu_specialtyModels = [welvu_specialty getAllSpecialty:appDelegate.getDBPath];
   /* CGRect frame = CGRectMake(300, 220, 150, 35);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    button.frame = frame;
    
    [button setTitle:(NSString *)@"new button" forState:(UIControlState)UIControlStateNormal];
    
    [button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];*/
   //
    //[self.view addSubview:button];
    /*self.g1.frame = self.topFadingView.frame;
     self.g2.frame = self.topFadingView.frame;
     [self.topFadingView.layer insertSublayer:self.g1 atIndex:0];
     [self.bottomFadingView.layer insertSublayer:self.g2 atIndex:0];
     self.topFadingView.hidden = true;*/
    welvu_specialtyModels = [welvu_specialty getAllSpecialty:appDelegate.getDBPath];
    
    // Do any additional setup after loading the view from its nib.
}




- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    NSIndexPath *index = [NSIndexPath indexPathForRow:
                          [self searchSpecialtyDefaultId:welvu_specialtyModels] inSection:0];
    [specialtyTableView selectRowAtIndexPath:index animated:NO scrollPosition:0];
    selectedIndexRow = index.row;
}
-(void)viewDidDisappear:(BOOL)animated {
    
}


-(void)dealloc {
    [super dealloc];
}
@end
