//
//  GestureControlView.m
//  welvu
//
//  Created by Logesh Kumaraguru on 30/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "GestureControlView.h"
#import "welvuContants.h"

#pragma mark - intialization
/*
 * Class name: GestureControlView
 * Description: Private class method declaration
 * Extends: nil
 * Delegate: nil
 */
@interface GestureControlView() {
    float mCurrentScale;
    float mLastScale;
    CGFloat lastScale;
	CGFloat lastRotation;
	CGFloat firstX;
	CGFloat firstY;
}
@end

@implementation GestureControlView
@synthesize masterView, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //Initialization code
    }
    return self;
}

/*
 * Method name: initializeGestureWithMasterView
 * Description: Intializes all the required gesture controls
 * Parameters: master_View - View on which the gesture controls will be applied
 * Return Type: nil
 */
- (void)initializeGestureWithMasterView:(UIView *)master_View {
    masterView = master_View;
    
    //
	// Pinch to zoom gesture
	//
    pinchToZoom = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchToZoom:)];
    [pinchToZoom setDelegate:self];
    [self addGestureRecognizer:pinchToZoom];
    
    //
	// Image rotation gesture
	//
    rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    [rotationRecognizer setDelegate:self];
    [self addGestureRecognizer:rotationRecognizer];
    
    //
	// Move image gesture
	//
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    [self addGestureRecognizer:panRecognizer];
}

#pragma mark - Handling different gesture

/*
 * Method name: handlePinchToZoom
 * Description: Scales up the view inside the master view, when user performs the pinch to zoom gesture
 * Parameters: sender
 * Return Type: nil
 */
- (void)handlePinchToZoom:(UIPinchGestureRecognizer*)sender {
    
    if ([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        [self.delegate gestureControlViewDidStarted];
        // Reset the last scale, necessary if there are multiple objects with different scales
        lastScale = [(UIPinchGestureRecognizer*)sender scale];
    }
    
    if ([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan ||
        [(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[[(UIPinchGestureRecognizer*)sender view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 2.0;
        const CGFloat kMinScale = 1.0;
        
        CGFloat newScale = 1 -  (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[(UIPinchGestureRecognizer*)sender view] transform], newScale, newScale);
        [(UIPinchGestureRecognizer*)sender view].transform = transform;
        
        lastScale = [(UIPinchGestureRecognizer*)sender scale];  // Store the previous scale factor for the next pinch gesture call
    }
    
    if ([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        [self.delegate gestureControlViewDidFinish];
    }
    
}

/*
 * Method name: rotate
 * Description: Rotates the views inside the master view, when user performs the rotate gesture
 * Parameters: sender
 * Return Type: nil
 */
- (void)rotate:(id)sender {
    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        [self.delegate gestureControlViewDidStarted];
        [pinchToZoom setEnabled:false];
    }
    
    if ([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        [self.delegate gestureControlViewDidFinish];
        [pinchToZoom setEnabled:true];
        lastRotation = 0.0;
        return;
    }
    
    CGFloat rotation = 0.0 - (lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
    CGAffineTransform currentTransform = [(UIPinchGestureRecognizer*)sender view].transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    
    [[(UIPinchGestureRecognizer*)sender view] setTransform:newTransform];
    
    lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
}

/*
 * Method name: move
 * Description: Moves the view inside the master contrainer, when user performs panning gesture over the view
 * Parameters: sender
 * Return Type: nil
 */
- (void)move:(id)sender {
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:masterView];
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
		[self.delegate gestureControlViewDidStarted];
		firstX = [[(UIPanGestureRecognizer*)sender view] center].x;
		firstY = [[(UIPanGestureRecognizer*)sender view] center].y;
	}
	if ([(UIPanGestureRecognizer*)sender view].frame.size.width > CANVAS_WIDTH
        || [(UIPanGestureRecognizer*)sender view].frame.size.height > CANVAS_HEIGHT) {
        translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
        
        /* NSLog(@"Center %f, %f And Tranformed to %f, %f", firstX,  firstY, (firstX + translatedPoint.x),
         (firstY + translatedPoint.y));*/
        
        [[(UIPanGestureRecognizer*)sender view] setCenter:translatedPoint];
    }
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        [self.delegate gestureControlViewDidFinish];
    }
}


#pragma mark - Gesture status
/*
 * Method name: setZoomToNormal
 * Description: Restores the image to normal/default size and scale
 * Parameters: nil
 * Return Type: nil
 */
- (void)setZoomToNormal {
    lastScale = 1.0;
    CGAffineTransform currentTransform = CGAffineTransformIdentity;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, lastScale, lastScale);
    self.transform = newTransform;
    self.frame = CGRectMake(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
}

/*
 * Method name: viewModificationGestureEnable
 * Description: To enable/disable gesture controls
 * Parameters: enable
 * Return Type: nil
 */
- (void)viewModificationGestureEnable:(BOOL)enable {
    [pinchToZoom setEnabled:enable];
    [rotationRecognizer setEnabled:enable];
    [panRecognizer setEnabled:enable];
}

#pragma mark UIGestureRegognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognize {
    return ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ![gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && ![gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
}
@end
