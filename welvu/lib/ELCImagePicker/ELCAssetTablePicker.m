//
//  AssetTablePicker.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"


@implementation ELCAssetTablePicker

@synthesize parent;
@synthesize selectedAssetsLabel;
@synthesize assetGroup, elcAssets;

-(void)viewDidLoad {
        
	[self.tableView setSeparatorColor:[UIColor clearColor]];
	[self.tableView setAllowsSelection:NO];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AlbumVU.png"]];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
    [tempArray release];
	
	/*UIBarButtonItem *doneButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackIcon.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self action:@selector(doneAction:)] autorelease];
	[self.navigationItem setLeftBarButtonItem:doneButtonItem];*/
    
    UIImage* image = [UIImage imageNamed:@"BackIcon.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton* backBtn = [[UIButton alloc] initWithFrame:frame];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [backBtn setBackgroundImage:image forState:UIControlStateNormal];
    [backBtn setShowsTouchWhenHighlighted:YES];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    backBarButtonItem.imageInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    [backBarButtonItem release];
    [backBtn release];
    
    
	[self.navigationItem setTitle:@"Loading..."];

	[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    
    // Show partial while full list loads
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:.5];
}

-(void)preparePhotos {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	
    [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) 
     {         
         if(result == nil) 
         {
             return;
         }
         
         ELCAsset *elcAsset = [[[ELCAsset alloc] initWithAsset:result] autorelease];
         [elcAsset setParent:self];
         [self.elcAssets addObject:elcAsset];
     }];
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if (currSysVer >= @"7.0") {
        self.title = NSLocalizedString(@"Pick Photos", @"");
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.text = self.title;
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        [titleLabel sizeToFit];
        self.navigationItem.titleView = titleLabel;
        [titleLabel release];
    } else {
        [self.navigationItem setTitle:@"Pick Photos"];
        
    }
	[self.tableView reloadData];
	[self.navigationItem setTitle:@"Pick Photos"];
    
    [pool release];

}

- (void) doneAction:(id)sender {
	
	NSMutableArray *selectedAssetsImages = [[[NSMutableArray alloc] init] autorelease];
	    
	for(ELCAsset *elcAsset in self.elcAssets) 
    {		
		if([elcAsset selected]) {
			
			[selectedAssetsImages addObject:[elcAsset asset]];
		}
	}
        
    [(ELCAlbumPickerController*)self.parent selectedAssets:selectedAssetsImages];
 
}

-(IBAction)backBtnClicked:(id)sender {
       [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ceil([self.assetGroup numberOfAssets] / 4.0);
}

- (NSArray*)assetsForIndexPath:(NSIndexPath*)_indexPath {
    
	int index = (_indexPath.row*4);
	int maxIndex = (_indexPath.row*4+3);
    
	// NSLog(@"Getting assets for %d to %d with array count %d", index, maxIndex, [assets count]);
    
	if(maxIndex < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				[self.elcAssets objectAtIndex:index+2],
				[self.elcAssets objectAtIndex:index+3],
				nil];
	}
    
	else if(maxIndex-1 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				[self.elcAssets objectAtIndex:index+2],
				nil];
	}
    
	else if(maxIndex-2 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				nil];
	}
    
	else if(maxIndex-3 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObject:[self.elcAssets objectAtIndex:index]];
	}
    
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
        
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) 
    {		        
        cell = [[[ELCAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:CellIdentifier] autorelease];
    }	
	else 
    {		
		[cell setAssets:[self assetsForIndexPath:indexPath]];
	}
    //ios 7
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	return 79;
}

- (int)totalSelectedAssets {
    
    int count = 0;
    
    for(ELCAsset *asset in self.elcAssets) 
    {
		if([asset selected]) 
        {            
            count++;	
		}
	}
    
    return count;
}

- (void)dealloc 
{
    [elcAssets release];
    [selectedAssetsLabel release];
    [super dealloc];    
}

@end
