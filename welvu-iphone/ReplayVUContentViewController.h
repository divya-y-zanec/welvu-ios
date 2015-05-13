//
//  ReplayVUContentViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 28/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class ReplayVUContentViewController;

@protocol replayVUContentDelegate
-(void) replayVUContentDidFinish;
@end

@interface ReplayVUContentViewController : UIViewController {
    id<replayVUContentDelegate> delegate;
    MPMoviePlayerController *moviePlayer;
    NSString *VUPath;
}
@property (retain) id<replayVUContentDelegate> delegate;

-initWithMoviePath:(NSString *)VU_Path;
@end
