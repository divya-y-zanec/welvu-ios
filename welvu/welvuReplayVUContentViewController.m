//
//  ReplayVUContentViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 28/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "welvuReplayVUContentViewController.h"
#import "welvuContants.h"
#import "GAI.h"

@implementation welvuReplayVUContentViewController
@synthesize delegate;
@synthesize playerLayer;
@synthesize playerView;
@synthesize player;
@synthesize viewPlayLogo ,viewPlayBanner, notificationLable;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        
    }
    return self;
}

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *bundleIdentifier = [defaults objectForKey:@"appBundleIdentifier"];
    
    if([bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_WELVU]|| [bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_EBOLAVU]||[bundleIdentifier isEqualToString:BUNDLE_IDENTIFER_HEV]) {
        [viewPlayLogo setImage:[UIImage imageNamed:@"WelvuLogoBanner.png"]];
        [viewPlayBanner setImage:[UIImage imageNamed:@"Banner.png"]];
        //for applying theme logo in all the welvu apps
        [self themeSettingsViewControllerDidFinish];
        
    } else {
        [self themeSettingsViewControllerDidFinish];
        
    }
    
    //Declaring Page View Analytics
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Play VU - MV"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    moviePlayer = [[MPMoviePlayerController alloc] init];
    NSURL *theContentURL =[NSURL fileURLWithPath:VUPath isDirectory:NO];
    [moviePlayer setContentURL:theContentURL];
    
    [moviePlayer setAllowsAirPlay:NO];
    [moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
    [moviePlayer setEndPlaybackTime:-1];
    [moviePlayer setInitialPlaybackTime:-1];
    [moviePlayer setMovieSourceType:MPMovieSourceTypeUnknown];
    [moviePlayer setRepeatMode:MPMovieRepeatModeNone];
    [moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
    [moviePlayer setShouldAutoplay:YES];
    [moviePlayer.view setFrame:CGRectMake(20, 75, 982, 640)];
    
    [self.view addSubview:moviePlayer.view];
    
    [moviePlayer prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    /* NSURL *theContentURL = [[NSURL fileURLWithPath:VUPath isDirectory:NO] retain];
     AVPlayerItem *movieItem = [AVPlayerItem playerItemWithURL:theContentURL];
     self.player = [AVPlayer playerWithPlayerItem:movieItem];
     self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
     [self.playerView.layer addSublayer:self.playerLayer];
     playerLayer.frame = playerView.bounds;
     [player play];*/
}

-(void)viewWillAppear:(BOOL)animated {
    if(appDelegate.networkReachable) {
        //NSLog(@"network is there");
        appDelegate.checkOrganizationUserLicense = false;
        [appDelegate checkUserLicense];


        
    } else {
        //  NSLog(@"network is not there");
    }
}
- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

#pragma mark Action Methods

/*
 * Method name: initWithMoviePath
 * Description: Get the path of the video
 * Parameters: VU_Path
 * return VU_Path
 */
-initWithMoviePath:(NSString *)VU_Path {
    self = [super initWithNibName:@"welvuReplayVUContentViewController" bundle:nil];
    if (self) {
        VUPath = VU_Path;
    }
    return self;
}

//state of the movie player controller
- (void) playbackStateChanged {
    switch (moviePlayer.playbackState) {
        case MPMoviePlaybackStatePaused:{
            replayOverlay = [[UIView alloc] initWithFrame:CGRectMake(20, 75, 982, 640)];
            replayOverlay.alpha = 1;
            replayOverlay.backgroundColor = [UIColor clearColor];
            
            
            UIImageView *replayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 982, 640)];
            UIButton *replayCustomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [replayCustomBtn addTarget:self action:@selector(closeOverlay:) forControlEvents:UIControlEventTouchUpInside];
            [replayCustomBtn setFrame:CGRectMake(0, 0, 982, 640)];
            replayImageView.image = [UIImage imageNamed:@"StopIconBig.png"];
            
            [replayOverlay addSubview:replayImageView];
            [replayOverlay addSubview:replayCustomBtn];
            
            //[self.view addSubview:replayOverlay];
            
        }
            break;
        case MPMoviePlaybackStatePlaying:{
            if(replayOverlay !=nil) {
                replayOverlay.hidden=TRUE;
            }
        }
            break;
        case MPMoviePlaybackStateStopped:{
        }
            break;
            
            
        default:
            break;
    }
    
}


/*
 * Method name: doneBtnClicked
 * Description: to save the description
 * Parameters: id
 * return IBAction
 * Created On: 19-dec-2012
 */
-(IBAction)doneBtnClicked:(id)sender {
    //declaring Event Tracking Analytics
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Play VU - MV"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Play VU - MV"
                                                          action:@"DoneButton - MV"
                                                           label:@"Save"
                                                           value:nil] build]];
        @try {
        [moviePlayer stop];
        [moviePlayer.view removeFromSuperview];
        moviePlayer = nil;
        [self.delegate replayVUContentDidFinish];
    }
    @catch (NSException *exception) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"PlayVU-MV_Save: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
    }
}

- (void)themeSettingsViewControllerDidFinish {

        
        
        appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:[appDelegate getDBPath]];
        if(appDelegate.welvu_userModel.org_id > 0) {
            NSString *logoName = [welvu_organization getOrganizationLogoNameById:[appDelegate getDBPath] :appDelegate.welvu_userModel.org_id];
            
            if([logoName isEqualToString:@""]) {
                viewPlayLogo.image = [UIImage imageNamed:@"WelvuLogoBanner.png"];
                
            } else {
                
                appDelegate.org_Logo = ([welvu_organization getOrganizationDetailsById
                                         :[appDelegate getDBPath]
                                         orgId:appDelegate.welvu_userModel.org_id]).orgLogoName;
                
                
                
                [viewPlayLogo setImage:[UIImage imageWithContentsOfFile:appDelegate.org_Logo]];
                
                
                
            }
        } else {
            viewPlayLogo.image = [UIImage imageNamed:@"WelvuLogoBanner.png"];
        }
        
        
        [self.view bringSubviewToFront:viewPlayLogo];
        
    
}

//close the overlay
-(IBAction)closeOverlay:(id)sender {
    if(replayOverlay !=nil) {
        replayOverlay.hidden=TRUE;
        [moviePlayer prepareToPlay];
        [moviePlayer play];
        
    }
    
}
#pragma mark UIInterfaceOrientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortrait &&
            interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
