//
//  welvuTopicVUViewController.m
//  welvu
//
//  Created by Logesh Kumaraguru on 19/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "welvuTopicVUSubViewController.h"
#import "welvu_images.h"
#import "UIImage+Resize.h"
#import "welvuContants.h"
#import "GAI.h"

//Controller private method declaration
@interface welvuTopicVUSubViewController ()
-(void)loadTopicImageGallery;
@end

@implementation welvuTopicVUSubViewController

//Synthesizing the object defined in the interface properties
@synthesize delegate,topicVUImages;
@synthesize fadeColor = fadeColor_;
@synthesize baseColor = baseColor_;
@synthesize topFadingView = _topFadingView;
@synthesize bottomFadingView = _bottomFadingView;
@synthesize g1 = g1_;
@synthesize g2 = g2_;
@synthesize fadeOrientation = fadeOrientation_;

int topicVUScrollWidth = 320;

//Default intialization of controller
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Custom intialization of controller with selected topic information
- (id)initWithWelvuTopic:(welvu_topics *) topic_model:(NSMutableArray *)welvu_imagesModel {
    self = [super initWithNibName:@"welvuTopicVUSubViewController" bundle:nil];
    if (self) {
        welvu_topicModel = topic_model;
        welvuImagesModel = welvu_imagesModel;
        self.fadeOrientation = FADE_TOPNBOTTOM;
        self.baseColor = BASE_COLOR;
    }
    return self;
}


//Sets fadeColor to be 10% alpha of baseColor
- (UIColor*)fadeColor {
    if (fadeColor_ == nil) {
        const CGFloat* components = CGColorGetComponents(self.baseColor.CGColor);
        fadeColor_ = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:CGColorGetAlpha(self.baseColor.CGColor)*.1];
    }
    return fadeColor_;
}


- (CAGradientLayer*)g1 {
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

- (CAGradientLayer*)g2 {
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
    
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Add VU-ContentList"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    //Intialize the Application delegate
    appDelegate = (welvuAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.welvu_userModel = [welvu_user getCurrentLoggedUser:appDelegate.getDBPath];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"AddVUBg.png"]];
    
    topicLabel.text = welvu_topicModel.topicName;
    topicVuScrollView.delegate = self;
    
    self.g1.frame = self.topFadingView.frame;
    self.g2.frame = self.topFadingView.frame;
    [self.topFadingView.layer insertSublayer:self.g1 atIndex:0];
    [self.bottomFadingView.layer insertSublayer:self.g2 atIndex:0];
    self.topFadingView.hidden = true;
    self.bottomFadingView.hidden = true;
    
    //Get topics from the database
    topicVUImages= [welvu_images getImagesByTopicId:appDelegate.getDBPath :welvu_topicModel.topicId
                                             userId:appDelegate.welvu_userModel.welvu_user_id];
    [self loadTopicImageGallery];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (topicVuScrollView.contentSize.height > topicVuScrollView.frame.size.height) {
        self.bottomFadingView.hidden = false;
    } else {
        self.bottomFadingView.hidden = true;
    }
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Action Methods
/*
 * Method name: backBtnClicked
 * Description: navigate to previous page
 * Parameters: id
 * return nil
 */
- (IBAction)backBtnClicked:(id)sender {
    //declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Add VU-ContentList"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Add VU-ContentList"
                                                          action:@"Go Back"
                                                           label:@"Back"
                                                           value:nil] build]];
    
    
    @try {
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"AddVU-ContentList_Back: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
        
        
    }
}

//Action will be called, when image is selected
- (IBAction)topicVuImagePressed:(id)sender {
    //declaring Event Tracking Analytics
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Add VU-ContentList"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Add VU-ContentList"
                                                          action:@"TopicVuContent"
                                                           label:@"TopicVU Content"
                                                           value:nil] build]];
    
    
    @try {
        
        //Submit the selected image to delegate method,
        //which will send the selected content to parent controller which called this view controller
        [self.delegate welvuTopicVUViewControllerDidFinish:(welvu_images *)[topicVUImages objectAtIndex:([sender tag] - 1)]];
        [self.navigationController popViewControllerAnimated:NO];
    }
    @catch (NSException *exception) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString * description = [NSString stringWithFormat:@"AddVU-ContentList_TopicvuContent: %@",exception];
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
                        withFatal:NO] build]];
        
    }
}
/*
 * Method name: searchImageGroups
 * Description: search image group with theit id
 * Parameters: imgId,imagesArray
 * return NSInteger
 */
- (NSInteger) searchImageGroups:(NSInteger) imgId:(NSMutableArray *) imagesArray {
    
    for (int i=0; i < imagesArray.count; i++) {
        welvu_images *img = [imagesArray objectAtIndex:i];
        if (img.imageId == imgId) {
            return i;
        }
    }
    return -1;
}

//Loading images of the topic within the scroll view
- (void)loadTopicImageGallery {
    if (topicVUImages != nil) {
        //Hide no images available if topicVUImages is not nil
        noimage.hidden = TRUE;
        int row = 0;
        int column = 0;
        CGRect frame;
        for (int i = 0; i < topicVUImages.count; ++i) {
            welvu_images *welvu_imagesModel = [topicVUImages objectAtIndex:i];
            
            UIImage *thumbnail = nil;
            //Custom size of the button, to represent the image in thumbnail format
            CGSize destinationSize = CGSizeMake(THUMB_HORIZONTAL_IMAGE_WIDTH, THUMB_HORIZONTAL_IMAGE_HEIGHT);
            
            if ([welvu_imagesModel.type isEqualToString:IMAGE_ASSET_TYPE]) {
                NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
                UIImage *originalImage = [UIImage imageWithData:imageData];
                //Getting thumbnail image of the original image
                thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
            } else if ([welvu_imagesModel.type isEqualToString:IMAGE_ALBUM_TYPE]) {
                //Pick the image from the saved Path
                NSData *imageData = [NSData dataWithContentsOfFile:welvu_imagesModel.url];
                UIImage *originalImage = [UIImage imageWithData:imageData];
                //Getting thumbnail image of the original image
                thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
            }else if([welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_TYPE]
                     || [welvu_imagesModel.type isEqualToString:IMAGE_VIDEO_ALBUM_TYPE]) {
                UIImage *originalImage = [self generateImageFromVideo:welvu_imagesModel.url :welvu_imagesModel.type];
                thumbnail = [originalImage resizedImageToFitInSize:destinationSize scaleIfSmaller:YES];
            }
            //Creating button with the generated thumbnail image
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            NSInteger padding = 0 ;
            if(thumbnail.size.width < THUMB_HORIZONTAL_BUTTON_WIDTH) {
                padding = ((THUMB_HORIZONTAL_BUTTON_WIDTH - thumbnail.size.width)/ 2);
            }
            button.frame = CGRectMake(padding + column *(THUMB_HORIZONTAL_BUTTON_WIDTH+10)+5, row*(THUMB_HORIZONTAL_BUTTON_HEIGHT + 10)+10,
                                      thumbnail.size.width, thumbnail.size.height);
            if ([self searchImageGroups:welvu_imagesModel.imageId :welvuImagesModel] > -1) {
                [button.layer setBorderColor: [[UIColor colorWithRed:0.94f green:0.67f blue:0.14f alpha:1.0f] CGColor]];
            } else {
                [button.layer setBorderColor: [[UIColor colorWithRed:0.80f green:0.80f blue:0.80f alpha:1.0f] CGColor]];
            }
            [button.layer setBorderWidth: 2.0];
            button.layer.cornerRadius = 5;
            button.backgroundColor = [UIColor clearColor];
            [button setImage:[thumbnail makeRoundCornerImage:5 :5] forState:UIControlStateNormal];
            
            //Setting target of the button, to handle when image is selected
            [button addTarget:self
                       action:@selector(topicVuImagePressed:)
             forControlEvents:UIControlEventTouchUpInside];
            
            //Adding tag to the button, to identify the selected button from the scroll view
            button.tag = (i+1);
            
            //Adding the buttons to the scroll view
            [topicVuScrollView addSubview:button];
            
            if (column == 1) {
                column = 0;
                row++;
            } else {
                column++;
            }
            frame = button.frame;
        }
        [topicVuScrollView setContentSize:CGSizeMake(topicVUScrollWidth, (frame.origin.y + 120))];
    } else {
        
        noimage.hidden = FALSE;
    }
}

-(UIImage *)generateImageFromVideo:(NSString *) pathString:(NSString *)pathType {
    NSURL *theContentURL;
    if([pathType isEqualToString:IMAGE_VIDEO_TYPE] && ![[NSFileManager defaultManager] fileExistsAtPath:pathString]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSArray *nameAndType = [pathString componentsSeparatedByString: @"."];
        NSString *moviePath = [bundle pathForResource:[nameAndType objectAtIndex:0] ofType:[nameAndType objectAtIndex:1]];
        theContentURL = [NSURL fileURLWithPath:moviePath];
    } else {
        theContentURL = [NSURL fileURLWithPath:pathString];
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:theContentURL options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    CGImageRef thumb = [imageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(1.0, 1.0)
                                              actualTime:NULL
                                                   error:NULL];
    UIImage *thumbImage = [UIImage imageWithCGImage:thumb];
    imageGenerator = nil;
    asset = nil;
    CGImageRelease(thumb);
    return thumbImage;
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
    
    if (aScrollView.contentOffset.y >= 5) {
        self.topFadingView.hidden = false;
        self.bottomFadingView.hidden = false;
    }
    
    float reload_distance = 10;
    if (y > h - reload_distance) {
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
