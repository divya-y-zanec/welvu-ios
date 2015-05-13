//
//  welvuArchiveImageController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 22/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import "welvuContants.h"


@class welvuArchiveImageController;

//Delegate function for returning unarchived image
@protocol welvuArchiveImageDelegate 
-(void)welvuArchiveImageDidFinish:(BOOL) isModified;
@end

@interface welvuArchiveImageController : UIViewController {
     //Assigning delegate for this controller
    id<welvuArchiveImageDelegate> delegate;
    
    //Application delegate
    welvuAppDelegate *appDelegate;
    
    //Current topic id
    NSInteger topicsId;
    
    //Defining topic images array object
    NSMutableArray *archivedVUImages;
    
    NSInteger counter;

    
    //Grid View
    GMGridView *archivedVUGridView;
    
    //Title Label
    IBOutlet UILabel *contentArchive;
    
    //Outlet image object for no image available
    IBOutlet UIImageView *noimage;
    
    
    
    //Outlet tableview object
    IBOutlet UIScrollView *archivedVuScrollView;
    int update;
}
@property(nonatomic,assign) int update;

@property (retain) id<welvuArchiveImageDelegate> delegate;
@property (nonatomic) NSInteger counter;


- (id)initWithTopicId:(NSInteger)topic_Id;
@end
