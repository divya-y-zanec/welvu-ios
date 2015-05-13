//
//  ELCAlbumPickerViewController.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 29/05/14.
//  Copyright (c) 2014 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface ELCAlbumPickerViewController : UIViewController <UITableViewDelegate> {

NSMutableArray *assetGroups;
NSOperationQueue *queue;
id parent;

ALAssetsLibrary *library;
    IBOutlet UITableView *albumTableView;
}
@property (nonatomic ,retain) IBOutlet UITableView *albumTableView;

@property (nonatomic, retain) id parent;
@property (nonatomic, retain) NSMutableArray *assetGroups;

-(void)selectedAssets:(NSArray*)_assets;

@end




