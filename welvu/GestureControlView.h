//
//  GestureControlView.h
//  welvu
//
//  Created by Logesh Kumaraguru on 30/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

//Delegate method to return selected content
@protocol GestureControlViewrDelegate
- (void)gestureControlViewDidStarted;
- (void)gestureControlViewDidFinish;
@end

/*
 * Class name: GestureControlView
 * Description: Gesture controls for pinch to zoom, rotating and panning a image
 * Extends: UIView
 * Delegate: UIGestureRecognizerDelegate
 */
@interface GestureControlView : UIView <UIGestureRecognizerDelegate> {
    
    //Defining the delegate for this controller
    id<GestureControlViewrDelegate> delegate;
    
    UIView *masterView;
    
    UITapGestureRecognizer *enable_disableAnnotation;
    UISwipeGestureRecognizer *swipeRight;
    UISwipeGestureRecognizer *swipeLeft;
    UIPinchGestureRecognizer *pinchToZoom;
    UIPanGestureRecognizer *panRecognizer;
    UIRotationGestureRecognizer *rotationRecognizer;
}
@property (nonatomic, retain) UIView *masterView;

//Assigning the property for delegate object
@property (retain) id<GestureControlViewrDelegate> delegate;

- (void)initializeGestureWithMasterView:(UIView *)master_View;
- (void)setZoomToNormal;
- (void)viewModificationGestureEnable:(BOOL)enable;
@end
