//
//  AlbumPickerController.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "ELCAssetTablePicker.h"
#import "welvuContants.h"

@implementation ELCAlbumPickerController

@synthesize parent, assetGroups;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:20.0];
    titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleView.textColor = [UIColor whiteColor]; // Change to desired color
    //titleView.backgroundColor=[UIColor blackColor];
    titleView.text = @"Loading...";
    titleView.textAlignment=UITextAlignmentCenter;
    [self.navigationItem setTitleView:titleView];
	//[self.navigationItem setTitle:@"Loading..."];
    
    
//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AlbumVU.png"]];
    
    //For non caching -santhosh
    
  self.tableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:ALBUM_IMAGE_PNG]];
    
    

        /*UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.parent action:@selector(cancelImagePicker)];
	[self.navigationItem setRightBarButtonItem:cancelButton];
	[cancelButton release];*/

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.assetGroups = tempArray;
    [tempArray release];
    
    library = [[ALAssetsLibrary alloc] init];      

    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        // Group enumerator Block
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
        {
            if (group == nil) 
            {
                return;
            }
            
            [self.assetGroups addObject:group];

            // Reload albums
            [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
        };
        
        // Group Enumerator Failure Block
        void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
           // NSLog(@"%@", [error localizedDescription]);
            if([[error localizedDescription] isEqualToString:@"User denied access"]) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_ALBUM_PROVIDE_ACCESS_HEADER", nil)
                                                                 message:NSLocalizedString(@"ALERT_ALBUM_PROVIDE_ACCESS_MESSAGE", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
                [alert release];
            } else {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
            
           // NSLog(@"A problem occured %@", [error description]);
        };	
                
        // Enumerate Albums
        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                               usingBlock:assetGroupEnumerator 
                             failureBlock:assetGroupEnumberatorFailure];
        
        [pool release];
    });    
}

-(void)reloadTableView {
    [self.tableView reloadData];
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    NSInteger myInt = [currSysVer integerValue];
    
    if (myInt >= 7.0 && myInt < 8.0) {
        self.title = NSLocalizedString(@"Select an Album", @"");
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.text = self.title;
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        [titleLabel sizeToFit];
        self.navigationItem.titleView = titleLabel;
        [titleLabel release];
        
    }else if (myInt >= 8.0 ) {
        self.title = NSLocalizedString(@"Select an Album", @"");
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.text = self.title;
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:137.0f/255.0f blue:225.0f/255.0f alpha:1.0];
        [titleLabel sizeToFit];
        self.navigationItem.titleView = titleLabel;
        [titleLabel release];
        
    }else {
        [self.navigationItem setTitle:@"Select an Album"];
   /* NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if (currSysVer >= @"7.0") {
        self.title = NSLocalizedString(@"Select an Album", @"");
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.text = self.title;
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        [titleLabel sizeToFit];
        self.navigationItem.titleView = titleLabel;
        [titleLabel release];
    } else {
        [self.navigationItem setTitle:@"Select an Album"];
        
    }*/
}

}
-(void)selectedAssets:(NSArray*)_assets {
	
	[(ELCImagePickerController*)parent selectedAssets:_assets];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [assetGroups count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Get count
    ALAssetsGroup *g = (ALAssetsGroup*)[assetGroups objectAtIndex:indexPath.row];
   // [g setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSInteger gCount = [g numberOfAssets];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",[g valueForProperty:ALAssetsGroupPropertyName], gCount];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup*)[assetGroups objectAtIndex:indexPath.row] posterImage]]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    //ios 7
	cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ELCAssetTablePicker *picker = [[ELCAssetTablePicker alloc] initWithNibName:@"ELCAssetTablePicker" bundle:[NSBundle mainBundle]];
	picker.parent = self;

    // Move me    
    picker.assetGroup = [assetGroups objectAtIndex:indexPath.row];
    //[picker.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    
	[self.navigationController pushViewController:picker animated:YES];
	[picker release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 57;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc 
{	
    [assetGroups release];
    [library release];
    [super dealloc];
}

@end

