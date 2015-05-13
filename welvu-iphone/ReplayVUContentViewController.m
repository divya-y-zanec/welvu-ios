//
//  ReplayVUContentViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 28/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "ReplayVUContentViewController.h"

@implementation ReplayVUContentViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-initWithMoviePath:(NSString *)VU_Path {
    
    
    self = [super initWithNibName:@"ReplayVUContentViewController" bundle:nil];
    if (self) {
        VUPath = VU_Path;
    }
    return self;
}

-(IBAction)doneBtnClicked:(id)sender {
    [moviePlayer stop];
    [self.delegate replayVUContentDidFinish];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    self.title=@"Play VU";
    [super viewDidLoad];
    moviePlayer = [[MPMoviePlayerController alloc] init];
    NSURL *theContentURL = [[NSURL fileURLWithPath:VUPath isDirectory:NO] retain];
    [moviePlayer setContentURL:theContentURL];
    [theContentURL release];
    
    [moviePlayer setAllowsAirPlay:NO];
    [moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
    [moviePlayer setEndPlaybackTime:-1];
    [moviePlayer setInitialPlaybackTime:-1];
    [moviePlayer setMovieSourceType:MPMovieSourceTypeUnknown];
    [moviePlayer setRepeatMode:MPMovieRepeatModeNone];
    [moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
    [moviePlayer setShouldAutoplay:YES];
    [moviePlayer.view setFrame:CGRectMake(0, 0, 568, 256)];
    
    [self.view addSubview:moviePlayer.view];
    
    [moviePlayer prepareToPlay];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortrait &&
            interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)dealloc  {
    delegate = nil;
    [moviePlayer release]; moviePlayer = nil;
    [super dealloc];
}

@end
