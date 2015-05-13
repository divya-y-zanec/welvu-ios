//
//  DrawingToolView.h
//  welvu
//
//  Created by Divya yadav on 26/09/12.
//  Copyright (c) 2012 Zanec Soft Tech. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@protocol DrawingToolViewDelegate <NSObject>
@end
/*
 * Class name: DrawingToolView
 * Description: Has functionality to perform free handwriting annotation, arrow, swaure and circle
 * Extends: UIView
 * Delegate : UIGestureRecognizerDelegate, UITextViewDelegate
 */
@interface DrawingToolView : UIView <UIGestureRecognizerDelegate, UITextViewDelegate>
{
    //Defining the delegate for this controller
    id<DrawingToolViewDelegate> delegate;
    
    CGPoint fromPoint;
    CGPoint toPoint;
    
    //Hold cg points for annotate text view
    CGPoint startpoint;
    CGPoint newPoint;
    CGRect newFrame;
    
    //Holds the details about the annotation and its color
    NSMutableArray *pathArray;
    
    //Holds the details about the annotation and its color for redo functionality
    NSMutableArray *bufferArray;
    
    //Holds button after annotate text view is created in it
    NSMutableArray  *buttonArray;
    
    //Hosld annotete text view
    UITextView *annotateTextView;
    
    //Holds the details about the annotation path
    UIBezierPath *myPath;
    
    //Touch and gesture recognizers for annotate text view
    UITouch *touch;
    UILongPressGestureRecognizer *longPressGR;
    UIPanGestureRecognizer *panGesture;
    
    //Storke color
    UIColor *strokeColor;
    
    //Enable line drawing
    BOOL isEnabled;
    
    // annotate text view
    int itag;
    int tagid;
    int count;
    
    NSInteger counter;
    NSInteger toolOption;
    
    //Check if Annotation started
    BOOL isAnnotationStarted;
    
     //CGMutablePathRef myPath1;
    //CGPoint currentPoint;
    //CGPoint previousPoint;
   // CGPoint previousPreviousPoint;
   
    
    
    
}
//Assigning the property for the delegate object
@property (nonatomic) id<DrawingToolViewDelegate> delegate;

//annotate drawing
@property (nonatomic,readwrite)  BOOL isAnnotationStarted;
@property (nonatomic,readwrite)  NSInteger toolOption;

//annotate text view
@property (nonatomic, readonly) IBOutlet UITextView *annotateTextView;
@property (nonatomic, retain) UILongPressGestureRecognizer *longPressGR;
@property (nonatomic, retain) UIPanGestureRecognizer *panGesture;
@property (nonatomic, retain) UITouch *touch;
@property (nonatomic, retain) NSMutableArray *pathArray;
@property (nonatomic, retain) NSMutableArray *bufferArray;
@property (nonatomic, retain) NSMutableArray  *buttonArray;

//@property (nonatomic,assign) CGPoint currentPoint;
//@property (nonatomic,assign) CGPoint previousPoint;
//@property (nonatomic,assign) CGPoint previousPreviousPoint;

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) BOOL empty;



-(void)clear;

//action methods
- (void)undoButtonClicked;
- (void)redoButtonClicked;
- (void)clearScreen;
- (void)setStrokeColor:(UIColor *)strColor;
- (void)isLineDrawingEnabled:(BOOL)enabled;
- (void)removeTextViewIfExist;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)annotationTextViewConditions;

@end
