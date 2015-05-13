//
//  ProcessingSpinnerView.m
//  Welvu
//
//  Created by Logesh Kumaraguru on 30/07/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "ProcessingSpinnerView.h"

@implementation ProcessingSpinnerView
@synthesize isSpinner;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isSpinner = false;
    }
    return self;
}

- (id)initWithFrameAndProcessingText:(CGRect)frame:(NSString *)procText
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isSpinner = false;
    }
    return self;
}
/*
 * Method name: loadSpinnerIntoView
 * Description:To load the spinner in the view
 * Parameters: superView
 * return procSpinnerView
 */
+(ProcessingSpinnerView *)loadSpinnerIntoView:(UIView *)superView {
    // Create a new view with the same frame size as the superView
	ProcessingSpinnerView *procSpinnerView = [[ProcessingSpinnerView alloc] initWithFrame:superView.bounds];
	// If something's gone wrong, abort!
	if(!procSpinnerView){ return nil; }
	// Create a new image view, from the image made by our gradient method
    UIImageView *background = [[UIImageView alloc] initWithImage:[procSpinnerView addBackground]];
	// Make a little bit of the superView show through
    background.alpha = 0.4;
    [procSpinnerView addSubview:background];
    
	UIActivityIndicatorView *indicator =
    [[UIActivityIndicatorView alloc]
     initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
	// Set the resizing mask so it's not stretched
    indicator.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin;
	// Place it in the middle of the view
    indicator.center = CGPointMake(superView.bounds.size.width / 2.0,
                                   superView.bounds.size.height  / 2.0);
    UILabel *procLabel = [[UILabel alloc] initWithFrame:CGRectMake((background.frame.size.width - 500)/2,
                                                                   (indicator.frame.origin.y + 50), 500, 40)];
    procLabel.text = NSLocalizedString(@"PROCESSING_SPINNER_MSG", nil);
    
    procLabel.textColor = [UIColor whiteColor];
    procLabel.textAlignment = UITextAlignmentCenter;
    procLabel.backgroundColor = [UIColor clearColor];
    [indicator addSubview:procLabel];
    
	// Add it into the spinnerView
    [procSpinnerView addSubview:indicator];
    [procSpinnerView addSubview:procLabel];
	// Start it spinning! Don't miss this step
	[indicator startAnimating];
    
    
    // Add the spinner view to the superView. Boom.
	[superView addSubview:procSpinnerView];
    
	return procSpinnerView;
}
/*
 * Method name: loadSpinnerIntoView
 * Description:To load the spinner in the view
 * Parameters: superView,procText
 * return procSpinnerView
 */
+(ProcessingSpinnerView *)loadSpinnerIntoView:(UIView *)superView:(NSString *) procText {
    // Create a new view with the same frame size as the superView
	ProcessingSpinnerView *procSpinnerView = [[ProcessingSpinnerView alloc] initWithFrame:superView.bounds];
	// If something's gone wrong, abort!
	if(!procSpinnerView){ return nil; }
	// Create a new image view, from the image made by our gradient method
    UIImageView *background = [[UIImageView alloc] initWithImage:[procSpinnerView addBackground]];
	// Make a little bit of the superView show through
    background.alpha = 0.7;
    [procSpinnerView addSubview:background];
    
	UIActivityIndicatorView *indicator =
    [[UIActivityIndicatorView alloc]
     initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
	// Set the resizing mask so it's not stretched
    indicator.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin;
	// Place it in the middle of the view
    indicator.center = CGPointMake(superView.bounds.size.width / 2.0,
                                   superView.bounds.size.height  / 2.0);
    UILabel *procLabel = [[UILabel alloc] initWithFrame:CGRectMake((background.frame.size.width - 500)/2,
                                                                   (indicator.frame.origin.y + 50), 500, 40)];
    procLabel.text = procText;
    
    procLabel.textColor = [UIColor whiteColor];
    procLabel.textAlignment = UITextAlignmentCenter;
    procLabel.backgroundColor = [UIColor clearColor];
    [indicator addSubview:procLabel];
    
	// Add it into the spinnerView
    [procSpinnerView addSubview:indicator];
    [procSpinnerView addSubview:procLabel];
	// Start it spinning! Don't miss this step
	[indicator startAnimating];
    
    // Add the spinner view to the superView. Boom.
	[superView addSubview:procSpinnerView];
    
	return procSpinnerView;
}
/*
 * Method name: removeSpinner
 * Description:To remove the spinner in the view
 * Parameters: nil
 * return nil
 */
-(void)removeSpinner{
	[super removeFromSuperview];
    isSpinner = false;
}
/*
 * Method name: addBackground
 * Description:To add background image to spinner
 * Parameters: nil
 * return nil
 */
- (UIImage *)addBackground{
    isSpinner = true;
	// Create an image context (think of this as a canvas for our masterpiece) the same size as the view
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 1);
	// Our gradient only has two locations - start and finish. More complex gradients might have more colours
    size_t num_locations = 2;
	// The location of the colors is at the start and end
    CGFloat locations[2] = { 0.0, 1.0 };
	// These are the colors! That's two RBGA values
    CGFloat components[8] = {
        0.4,0.4,0.4, 0.8,
        0.1,0.1,0.1, 0.5 };
	// Create a color space
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
	// Create a gradient with the values we've set up
    CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
	// Set the radius to a nice size, 80% of the width. You can adjust this
    float myRadius = (self.bounds.size.width*.8)/2;
	// Now we draw the gradient into the context. Think painting onto the canvas
    CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, self.center, 0, self.center, myRadius, kCGGradientDrawsAfterEndLocation);
	// Rip the 'canvas' into a UIImage object
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	// And release memory
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    UIGraphicsEndImageContext();
	// … obvious.
    return image;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
