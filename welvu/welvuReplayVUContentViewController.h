//
//  ReplayVUContentViewController.h
//  welvu
//
//  Created by Logesh Kumaraguru on 28/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@class welvuReplayVUContentViewController;

@protocol replayVUContentDelegate
-(void) replayVUContentDidFinish;
@end
/*
 * Class name: welvuReplayVUContentViewController
 * Description: To Play video
 * Extends: UIViewController
 *Delegate :nil
 */
@interface welvuReplayVUContentViewController : UIViewController {
    //Assigning the delegate for view controller
    id<replayVUContentDelegate> delegate;
    welvuAppDelegate *appDelegate;
    MPMoviePlayerController *moviePlayer;
    NSString *VUPath;
    UIView *replayOverlay;
    IBOutlet UIImageView *viewPlayLogo;
    UILabel *notificationLable;
    IBOutlet UIImageView *viewPlayBanner;
}
//Assigning property for the delegate
@property (retain) id<replayVUContentDelegate> delegate;
@property (nonatomic ,retain) IBOutlet UIImageView *viewPlayBanner;
@property (nonatomic ,retain)  IBOutlet UIImageView *viewPlayLogo;
@property (strong ,retain) UILabel *notificationLable;
@property (nonatomic, retain) AVPlayerLayer *playerLayer;
@property (nonatomic, retain) AVPlayer *player;
@property (nonatomic, retain) IBOutlet UIView *playerView;
//Methods
-initWithMoviePath:(NSString *)VU_Path;
@end
