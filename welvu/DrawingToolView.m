//
//  DrawingToolView.m
//  welvu
//
//  Created by Divya yadav on 26/09/12.
//  Copyright (c) 2012 Zanec Soft Tech. All rights reserved.
//

#import "DrawingToolView.h"
#import "DrawingInfo.h"
#import "welvuContants.h"

@implementation DrawingToolView

@synthesize isAnnotationStarted, toolOption;
@synthesize annotateTextView, longPressGR, panGesture, touch;
@synthesize pathArray, bufferArray, buttonArray,delegate;

/*
 * Method name: initWithCoder
 * Description: Overidden method to intialize, called when view is mapped via xib.
 * Parameters: NSCoder
 * Return Type: id
 */
- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
    if(self) {
        isAnnotationStarted = FALSE;
        pathArray = [[NSMutableArray alloc]init];
        bufferArray= [[NSMutableArray alloc]init];
        buttonArray = [[NSMutableArray alloc] init];
        strokeColor = [UIColor blueColor];
        counter = 0;
    }
	return self;
}

/*
 * Method name: initWithFrame
 * Description: Array for CGRect values
 * Parameters: CGRect
 * Return Type: self
 */
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        isAnnotationStarted = FALSE;
        pathArray=[[NSMutableArray alloc]init];
        bufferArray=[[NSMutableArray alloc]init];
        buttonArray = [[NSMutableArray alloc] init];
        strokeColor = [UIColor blueColor];
        counter = 0;
    }
    return self;
}
/*
 * Method name: setToolOption
 * Description: Option for setting gesture recognizers
 * Parameters: NSInteger
 * Return Type: nil
 */

- (void)setToolOption:(NSInteger)sToolOption {
    toolOption = sToolOption;
    if (toolOption!=DRAWING_TOOL_TEXTVIEW) {
        [panGesture setEnabled:NO];
        [longPressGR setEnabled:NO];
    } else {
        [panGesture setEnabled:YES];
        [longPressGR setEnabled:YES];
    }
    [self removeTextViewIfExist];
}

/*
 * Method name: setStrokeColor
 * Description: Setting color for Drawing and annotation
 * Parameters: UIColor
 * Return Type: nil
 */

- (void)setStrokeColor:(UIColor *)strColor{
    strokeColor = strColor;
}

/*
 * Method name: drawRect
 * Description: Overriden drawRect: to perform custom drawing.
 * Parameters: CGRect
 * Return Type: nil
 */
- (void)drawRect:(CGRect)rect{
    for (DrawingInfo *drawingInfo in pathArray) {
        [drawingInfo.color setStroke];
        [drawingInfo.path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    }
}

#pragma mark - Touch Methods(arrow, square, circle, TextView)

/*
 * Method name: touchesBegan
 * Description: Drawing tool when touches begin
 * Parameters: NSSet - User touch details ,UIEvent - event object
 * Return Type: nil
 */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if (isEnabled) {
        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
        int touchCount = [touches count];
        switch (toolOption) {
            {
            case DRAWING_TOOL_LINE:
                myPath=[[UIBezierPath alloc]init];
                myPath.lineCapStyle=kCGLineCapRound;
                myPath.lineWidth=5;
                myPath.miterLimit=0;
                
                DrawingInfo *drawingInfo = [[DrawingInfo alloc] init];
                [myPath moveToPoint:[mytouch locationInView:self]];
                drawingInfo.path = myPath;
                drawingInfo.color = strokeColor;
                [pathArray addObject:drawingInfo];
                break;
            } {
                // Draw arrow/square/text view
            case DRAWING_TOOL_ARROW: {
                
                fromPoint = [mytouch locationInView:self];
                
            }
                break;
            } {
            case DRAWING_TOOL_SQUARE: {
                
                fromPoint=[mytouch locationInView:self];
                
                
            }
                break;
            } {
            case DRAWING_TOOL_CIRCLE: {
                
                fromPoint = [mytouch locationInView:self];
                
            }
                break;
            } {
            case DRAWING_TOOL_TEXTVIEW: {
                
                isAnnotationStarted = TRUE;
                if (annotateTextView==nil && touchCount < 2){
                    [self endEditing:YES];
                    [super touchesBegan:touches withEvent:event];
                    touch = [touches anyObject];
                    startpoint = [touch locationInView:self];
                    annotateTextView = [[UITextView alloc] initWithFrame:CGRectMake(startpoint.x, startpoint.y, 240, 75)];
                    annotateTextView.delegate = self;
                    annotateTextView.layer.cornerRadius = 5;
                    annotateTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
                    annotateTextView.layer.borderWidth = 2.3;
                    annotateTextView.clipsToBounds = YES;
                    annotateTextView.userInteractionEnabled = YES;
                    annotateTextView.backgroundColor = [UIColor clearColor];
                    annotateTextView.textColor=[UIColor blackColor];
                    annotateTextView.Font=[UIFont systemFontOfSize:17.0f];
                    
                    [annotateTextView becomeFirstResponder];
                    
                    [self.annotateTextView becomeFirstResponder];
                    annotateTextView.userInteractionEnabled = true;
                    [annotateTextView setContentOffset:CGPointMake(0, 0) animated:YES];
                    annotateTextView.autocapitalizationType = UITextAutocapitalizationTypeWords;
                    
                    [self addSubview:annotateTextView];
                    annotateTextView.delegate = self;
                } else{
                    
                    [self annotationTextViewConditions];
                }
            }
                break;
            }
            default:
                break;
        }
    }
}
#pragma mark - touches moved

/**
 * Method name: touchesMoved
 * Description: Drawing tool when touches moved
 * Parameters: NSSet - User touch details ,UIEvent - event object
 * Return Type: nil
 */

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    if (isEnabled) {
        isAnnotationStarted = TRUE;
        switch (toolOption) {
            case DRAWING_TOOL_LINE:
                [myPath addLineToPoint:[mytouch locationInView:self]];
                break;
            case DRAWING_TOOL_ARROW: {
                double slopy,cosy,siny;
                double length = 8.0;
                double width = 8.0;
                
                //arrow line
                toPoint =[mytouch locationInView:self];
                myPath=[[UIBezierPath alloc]init];
                myPath.lineCapStyle=kCGLineCapRound;
                myPath.lineWidth=5;
                myPath.miterLimit=9;
                DrawingInfo *drawingInfo = [[DrawingInfo alloc] init];
                
                drawingInfo.path = myPath;
                drawingInfo.color = strokeColor;
                
                slopy = atan2((fromPoint.y - toPoint.y), (fromPoint.x - toPoint.x));
                cosy = cos(slopy);
                siny = sin(slopy);
                
                [myPath moveToPoint:CGPointMake( fromPoint.x - length * cosy, fromPoint.y - length * siny )];
                [myPath addLineToPoint:CGPointMake( toPoint.x + length * cosy, toPoint.y + length * siny)];
                //[myPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
                
                [myPath closePath];
                //[myPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
                
                
                [myPath moveToPoint:toPoint];
                //arrow head
                [myPath addLineToPoint:CGPointMake(toPoint.x +( length * cosy - ( width / 2.0 * siny )),                                      toPoint.y + ( length * siny + ( width / 2.0 * cosy )))];
                [myPath addLineToPoint:CGPointMake(
                                                   toPoint.x  + ( length * cosy + ( width / 2.0 * siny )),
                                                   toPoint.y - (width / 2.0 * cosy - length * siny ) )];
                [myPath closePath];
                //[myPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
                
                if([pathArray count] > counter) {
                    [pathArray removeLastObject];
                }
                [pathArray addObject:drawingInfo];
            }
                break;
            case DRAWING_TOOL_CIRCLE:
            {
                toPoint=[mytouch locationInView:self];
                double distance = 0;
                distance = sqrt(pow((toPoint.x - fromPoint.x),2)
                                + pow((toPoint.y - fromPoint.y),2));
                
                if(fromPoint.x > toPoint.x && fromPoint.y > toPoint.y) {
                    myPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(fromPoint.x, fromPoint.y, -distance, -distance)];
                }else if((fromPoint.x > toPoint.x || fromPoint.x == toPoint.x)
                         && (fromPoint.y < toPoint.y || fromPoint.y == toPoint.y)) {
                    myPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(fromPoint.x, fromPoint.y, -distance, distance)];
                } else if((fromPoint.x < toPoint.x || fromPoint.x == toPoint.x)
                          && (fromPoint.y > toPoint.y                                                        || fromPoint.y == toPoint.y)) {
                    myPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(fromPoint.x, fromPoint.y, distance, -distance)];
                } else if(fromPoint.x < toPoint.x && fromPoint.y < toPoint.y) {
                    myPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(fromPoint.x, fromPoint.y, distance, distance)];
                }
                myPath.lineCapStyle=kCGBlendModeDestinationIn;
                myPath.lineWidth=5;
                myPath.miterLimit=0;
                DrawingInfo *drawinginfo=[[DrawingInfo alloc]init];
                drawinginfo.path=myPath;
                drawinginfo.color=strokeColor;
                
                if([pathArray count] > counter) {
                    [pathArray removeLastObject];
                }
                [pathArray addObject:drawinginfo];
            }
                break;
                
            case DRAWING_TOOL_SQUARE:
            {
                myPath=[[UIBezierPath alloc]init];
                myPath.lineCapStyle=kCGLineCapRound;
                myPath.lineWidth=5;
                myPath.miterLimit=0;
                
                
                [myPath moveToPoint:fromPoint];
                
                DrawingInfo *drawingInfo = [[DrawingInfo alloc] init];
                drawingInfo.path = myPath;
                drawingInfo.color = strokeColor;
                //[pathArray addObject:drawingInfo];
                
                toPoint =[mytouch locationInView:self];
                
                [myPath addLineToPoint:CGPointMake(toPoint.x, fromPoint.y)];
                [myPath addLineToPoint:CGPointMake(toPoint.x, toPoint.y)];
                [myPath addLineToPoint:CGPointMake(fromPoint.x, toPoint.y)];
                [myPath addLineToPoint:CGPointMake(fromPoint.x, fromPoint.y)];
                if([pathArray count] > counter) {
                    [pathArray removeLastObject];
                }
                [pathArray addObject:drawingInfo];
                
            }
                break;
            default:
                break;
        }
        [self setNeedsDisplay];
    }
    
}

/*
 * Method name: touchesEnded
 * Description: Drawing tool when touches moved
 * Parameters: NSSet - User touch details ,UIEvent - event object
 * Return Type: nil
 */

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    fromPoint = CGPointZero;
    toPoint = CGPointZero;
    [super touchesEnded:touches withEvent:event];
    if (isEnabled) {
        
        switch (toolOption) {
            case DRAWING_TOOL_LINE:
                counter = [pathArray count];
                break;
            case DRAWING_TOOL_ARROW: {
                counter = [pathArray count];
            }
                break;
            case DRAWING_TOOL_SQUARE: {
                counter = [pathArray count];
            }
                break;
            case DRAWING_TOOL_CIRCLE: {
                counter = [pathArray count];
            }
                break;
            default:
                break;
        }
    }
}

/*
 * Method name: annotationTextViewConditions
 * Description: about textfield in the view
 * Parameters: nil
 * Return Type: IBAction
 */


- (void)annotationTextViewConditions{
    if (annotateTextView!=nil && [annotateTextView.text length]==0) {
        [annotateTextView resignFirstResponder];
        annotateTextView.backgroundColor = [UIColor clearColor];
        [annotateTextView removeFromSuperview];
        annotateTextView=nil;
    } else if (annotateTextView != nil && [annotateTextView.text length] > 0) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        CGSize annotateTextContentSize = annotateTextView.contentSize;
        
        
        [btn setFrame:CGRectMake(startpoint.x,startpoint.y,
                                 (annotateTextContentSize.width + 10), (annotateTextContentSize.height + 10))];
        
        
        UITextView *annotatedTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, annotateTextContentSize.width, annotateTextContentSize.height)];
        
        annotatedTextView.text = annotateTextView.text;
        annotateTextView.textColor=strokeColor;
        
        annotatedTextView.backgroundColor = [UIColor clearColor];
        annotatedTextView.textColor=strokeColor;
        annotatedTextView.Font=[UIFont systemFontOfSize:17.0f];
        
        annotatedTextView.clipsToBounds = NO;
        annotatedTextView.userInteractionEnabled = NO;
        [btn addSubview:annotatedTextView];
        
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        btn.backgroundColor = [UIColor clearColor];
        
        btn.tag = [buttonArray count] + 1;
        
        [buttonArray addObject:btn];
        [self addSubview:btn];
        
        UILongPressGestureRecognizer *longpressGesture =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longpressGesture.minimumPressDuration = 1.0;
        [longpressGesture setDelegate:self];
        [btn addGestureRecognizer:longpressGesture];
        
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [panRecognizer setDelegate:self];
        [btn addGestureRecognizer:panRecognizer];
        
        [annotateTextView removeFromSuperview];
        annotateTextView = nil;
    }
    
    
}
/*
 * Method name: move
 * Description: To move the annotated text view(button)...
 * Parameters: UIPanGestureRecognizer
 * Return Type: IBAction
 */


- (IBAction)move:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
    
}


/*
 * Method name: handleLongPress
 * Description: To remove button with text view from annotate text view
 * Parameters: UILongPressGestureRecognizer
 * Return Type: IBAction
 */


- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender  {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
            [buttonArray removeObjectAtIndex:([sender.view tag] - 1)];
            [sender.view removeFromSuperview];
        }
    }
}


/*
 * Method name: undoButtonClicked
 * Description: remove the last done move
 * Parameters: nil
 * Return Type: nil
 */

- (void)undoButtonClicked{
    if ([pathArray count] > 0){
        [bufferArray addObject:[pathArray lastObject]];
        [pathArray removeLastObject];
        counter = [pathArray count];
        [self setNeedsDisplay];
    }
    
}

/*
 * Method name: redoButtonClicked
 * Description: redo the last undone thing
 * Parameters: nil
 * Return Type: nil
 */

- (void)redoButtonClicked{
    
    if ([bufferArray count] > 0){
        [pathArray addObject:[bufferArray lastObject]];
        [bufferArray removeLastObject];
        counter = [pathArray count];
        [self setNeedsDisplay];
    }
    
    
}

/*
 * Method name: clearScreen
 * Description: clear all the annotation on the screen
 * Parameters: nil
 * Return Type: nil
 */

- (void)clearScreen {
    isAnnotationStarted = FALSE;
    if ([pathArray count] > 0){
        counter = 0;
        [pathArray removeAllObjects];
        [bufferArray removeAllObjects];
        [self setNeedsDisplay];
    }
    
    if ([buttonArray count] > 0) {
        for (UIView *subview in buttonArray) {
            [subview removeFromSuperview];
        }
        [buttonArray removeAllObjects];
        
    }
    pathArray = [[NSMutableArray alloc] init];
    bufferArray = [[NSMutableArray alloc] init];                 
    [self removeTextViewIfExist];
}

/*
 * Method name: isLineDrawingEnabled
 * Description: to enable line drawing
 * Parameters: nill
 * Return Type: nil
 */

- (void)isLineDrawingEnabled:(BOOL) enabled {
    isEnabled = enabled;
    [self removeTextViewIfExist];
}

BOOL isTextViewMoved = false;
float textViewMovedDistance;

/*
 * Method name: textViewDidBeginEditing
 * Description: start the editing
 * Parameters: UITextView
 * Return Type: nil
 */
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if (textView.frame.origin.y > 180) {
        isTextViewMoved = true;
        textViewMovedDistance =  (textView.frame.origin.y - 180) + textView.frame.size.height;
        textView.frame = CGRectMake(textView.frame.origin.x,
                                    (textView.frame.origin.y - textViewMovedDistance),
                                    textView.frame.size.width, textView.frame.size.height);
    }
    [UIView commitAnimations];
}

/*
 * Method name: textViewDidEndEditing
 * Description: when text view editing is done
 * Parameters: UITextView
 * Return Type: nil
 */

- (void)textViewDidEndEditing:(UITextView *)textView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if (isTextViewMoved) {
        isTextViewMoved = false;
        textView.frame = CGRectMake(textView.frame.origin.x,
                                    (textView.frame.origin.y + textViewMovedDistance),
                                    textView.frame.size.width, textView.frame.size.height);
    }
    [UIView commitAnimations];
}

/*
 * Method name: removeTextViewIfExist
 * Description: removing the text view on exiting
 * Parameters: nil
 * Return Type: nil
 */

- (void)removeTextViewIfExist {
    /*if(annotateTextView != nil) {
     [annotateTextView removeFromSuperview];
     [annotateTextView release], annotateTextView = nil;
     }*/
}
@end
