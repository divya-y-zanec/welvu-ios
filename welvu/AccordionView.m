/*
 AccordionView.m
 
 Created by Wojtek Siudzinski on 19.12.2011.
 Copyright (c) 2011 Appsome. All rights reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "AccordionView.h"


@implementation AccordionView

@synthesize selectedIndex, isHorizontal, animationDuration, animationCurve;
@synthesize allowsMultipleSelection, selectionIndexes, delegate;
@synthesize scrollView;
@synthesize headers, views;
@synthesize  accordianSelectedFlag;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setScrollViewEnabled:) name:@"scrolViewEnabled" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setScrollViewDisabled:) name:@"scrolViewDisabled" object:nil];
        views = [NSMutableArray new];
        headers = [NSMutableArray new];
        originalSizes = [NSMutableArray new];
        
        self.backgroundColor = [UIColor clearColor];
        
        scrollView = [[AccordianScrollView alloc] initWithFrame:CGRectMake(0, 0, [self frame].size.width, [self frame].size.height)];
        scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:scrollView];
        
        self.userInteractionEnabled = YES;
        scrollView.userInteractionEnabled = YES;
        
        animationDuration = 0.3;
        animationCurve = UIViewAnimationCurveEaseIn;
        
        
        self.autoresizesSubviews = NO;
        scrollView.autoresizesSubviews = NO;
        scrollView.scrollsToTop = YES;
        scrollView.delegate = self;
        scrollView.alwaysBounceVertical= YES;
        self.allowsMultipleSelection = NO;
        accordianSelectedFlag = false;
    }
    
    return self;
}

-(void)removeObserverFromAccordion {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                             name:@"scrolViewEnabled" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                            name:@"scrolViewDisabled" object:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [scrollView setScrollEnabled:TRUE];
}
- (void)setScrollViewEnabled:(NSNotification *)note {
    [scrollView setScrollEnabled:TRUE];
}

- (void)setScrollViewDisabled:(NSNotification *)note {
    [scrollView setScrollEnabled:FALSE];
}
//Sets fadeColor to be 10% alpha of baseColor


- (void)addHeader:(id)aHeader withView:(id)aView:(BOOL) isLocked{
    if ((aHeader != nil) && (aView != nil)) {
        [headers addObject:aHeader];
        [views addObject:aView];
        [originalSizes addObject:[NSValue valueWithCGSize:[aView frame].size]];
        
        [aView setAutoresizingMask:UIViewAutoresizingNone];
        [aView setClipsToBounds:YES];
        
        CGRect frame = [aHeader frame];
        
        if (self.isHorizontal) {
            // TODO
        } else {
            frame.origin.x = 0;
            frame.size.width = [self frame].size.width;
            [aHeader setFrame:frame];
            
            frame = [aView frame];
            frame.origin.x = 0;
            frame.size.width = [self frame].size.width;
            [aView setFrame:frame];
        }
        
        [scrollView addSubview:aView];
        [scrollView addSubview:aHeader];
        
        if ([aHeader respondsToSelector:@selector(addTarget:action:forControlEvents:)]) {
            [aHeader setTag:[headers count] - 1];
            if(!isLocked) {
                [aHeader addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchUpInside];
            } else {
                [aHeader addTarget:self action:@selector(accordionWasLocked:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        /* if ([selectionIndexes count] == 0) {
         //[self setSelectedIndex:0];
         }*/
    }
}

- (void)accordionWasLocked:(id)sender {
    [self.delegate accordionLocked];
}

- (void)setSelectionIndexes:(NSIndexSet *)aSelectionIndexes {
    if ([headers count] == 0) return;
    
    if ([aSelectionIndexes count] > 1) {
        aSelectionIndexes = [NSIndexSet indexSetWithIndex:[aSelectionIndexes firstIndex]];
    }
    
    NSMutableIndexSet *cleanIndexes = [NSMutableIndexSet new];
    [aSelectionIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (idx > [headers count] - 1) return;
        
        [cleanIndexes addIndex:idx];
    }];
    
    selectionIndexes = cleanIndexes;
    [self setNeedsLayout];
    [self.delegate accordion:self selectedAccordianView:(UIView *)
     [views objectAtIndex:currentSelectedIndex]:currentSelectedIndex];
    if ([delegate respondsToSelector:@selector(accordion:didChangeSelection:)]) {
        [delegate accordion:self didChangeSelection:self.selectionIndexes];
    }
}

- (void)setSelectedIndex:(NSInteger)aSelectedIndex {
    [self setSelectionIndexes:[NSIndexSet indexSetWithIndex:aSelectedIndex]];
}

- (NSInteger)selectedIndex {
    return [selectionIndexes firstIndex];
}

- (void)setOriginalSize:(CGSize)size forIndex:(NSUInteger)index {
    if (index >= [views count]) return;
    
    [originalSizes replaceObjectAtIndex:index withObject:[NSValue valueWithCGSize:size]];
    
    if ([selectionIndexes containsIndex:index]) [self setNeedsLayout];
}

- (void)touchDown:(id)sender {
    currentSelectedIndex = [sender tag];
    //currentSelectedIndex.frame = CGRectMake(scrollView.frame.size.height+views.frame.size.height) + 40.0);
    //scrollView.frame=CGRectMake(0, 0, [self frame].size.width, [self frame].size.height);
    
    scrollView.scrollsToTop = YES;
    NSMutableIndexSet *mis = [selectionIndexes mutableCopy];
    if ([selectionIndexes containsIndex:[sender tag]]) {
        [((UIButton *)[headers objectAtIndex:[sender tag]]) setSelected:false];
        [mis removeIndex:[sender tag]];
        [self setSelectionIndexes:mis];
    } else {
        [((UIButton *)[headers objectAtIndex:[sender tag]]) setSelected:true];
        [mis addIndex:[sender tag]];
        [scrollView setScrollsToTop:FALSE];
        
        // scrollView.frame.size.y = views.frame.origin.y - scrollView.frame.size.height;
        [self setSelectedIndex:[sender tag]];
    }
   
    if(currentSelectedIndex != previousSelectedIndex) {
        [((UIButton *)[headers objectAtIndex:previousSelectedIndex]) setSelected:false];
    }
    previousSelectedIndex = currentSelectedIndex;
    if([selectionIndexes count] == 0) {
        accordianSelectedFlag = false;
    } else {
        accordianSelectedFlag = true;
    }
    if((((UIButton *)[headers objectAtIndex:currentSelectedIndex]).frame.origin.y +  ((UIButton *)[headers objectAtIndex:currentSelectedIndex]).frame.size.height + 445) > scrollView.bounds.size.height && accordianSelectedFlag) {
        [self performSelector:@selector(scrollViewToBottomOffset:) withObject:nil afterDelay:0.3];
    }
    if((((UIButton *)[headers objectAtIndex:currentSelectedIndex]).frame.origin.y -
        scrollView.contentOffset.y) < 0 && scrollView.contentOffset.y < 130)
    {
       /* NSLog(@"Top offset");
        CGPoint topOffset = CGPointMake(0, - scrollView.contentOffset.y);
        [scrollView setContentOffset:topOffset animated:YES];
        [self performSelector:@selector(scrollViewToTopOffset:) withObject:nil afterDelay:0.3];*/
    }
}

//[self scrollViewDidScroll:scrollView];
/*if(allowsMultipleSelection)
 {
 scrollView.frame=CGRectMake(0, -100, 262, 640);
 }
 scrollView.scrollsToTop = YES;
 
 [self setSelectedIndex:[sender tag]];
 }*/
//

//
/*if (allowsMultipleSelection) {
 
 } else {
 [self setSelectedIndex:[sender tag]];
 }*/
//}
-(IBAction)scrollViewToBottomOffset:(id)sender {
    if((((UIButton *)[headers objectAtIndex:currentSelectedIndex]).frame.origin.y +  ((UIButton *)[headers objectAtIndex:currentSelectedIndex]).frame.size.height + 445) > scrollView.bounds.size.height) {
    
        CGPoint bottomOffset = CGPointMake(0, (((UIButton *)[headers objectAtIndex:currentSelectedIndex]).frame.origin.y + 44 + 500) - scrollView.bounds.size.height);
        [scrollView setContentOffset:bottomOffset animated:YES];
    }
}
-(IBAction)scrollViewToTopOffset:(id)sender {
  
    if((((UIButton *)[headers objectAtIndex:currentSelectedIndex]).frame.origin.y -
     scrollView.contentOffset.y) < 0 && scrollView.contentOffset.y < 130)
     {
        /* NSLog(@"Top offset 2");
         CGPoint topOffset = CGPointMake(0, - (((UIButton *)[headers objectAtIndex:currentSelectedIndex]).frame.origin.y +  scrollView.contentOffset.y + 44));
         [scrollView setContentOffset:topOffset animated:YES];
         [self performSelector:@selector(scrollViewToTopOffset:) withObject:nil afterDelay:0.3];*/
     }
}
- (void)animationDone {
    for (int i=0; i<[views count]; i++) {
        if (![selectionIndexes containsIndex:i]) [[views objectAtIndex:i] setHidden:YES];
    }
}

- (void)layoutSubviews {
    
    if (self.isHorizontal) {
        // TODO
    } else {
        int height = 0;
        for (int i=0; i<[views count]; i++) {
            id aHeader = [headers objectAtIndex:i];
            id aView = [views objectAtIndex:i];
            
            CGSize originalSize = [[originalSizes objectAtIndex:i] CGSizeValue];
            CGRect viewFrame = [aView frame];
            CGRect headerFrame = [aHeader frame];
            headerFrame.origin.y = height;
            height += headerFrame.size.height;
            
            viewFrame.origin.y = height;
            
            if ([selectionIndexes containsIndex:i]) {
                viewFrame.size.height = originalSize.height;
                [aView setFrame:CGRectMake(0, viewFrame.origin.y, [self frame].size.width, 0)];
                [aView setHidden:NO];
            } else {
                viewFrame.size.height = 0;
            }
            
            height += viewFrame.size.height;
            
            if (!CGRectEqualToRect([aHeader frame], headerFrame) || !CGRectEqualToRect([aView frame], viewFrame)) {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(animationDone)];
                [UIView setAnimationDuration:self.animationDuration];
                [UIView setAnimationCurve:self.animationCurve];
                [UIView setAnimationBeginsFromCurrentState:YES];
                [aHeader setFrame:headerFrame];
                [aView setFrame:viewFrame];
                [UIView commitAnimations];
            }
        }
        
        CGPoint offset = scrollView.contentOffset;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:self.animationDuration];
        [UIView setAnimationCurve:self.animationCurve];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [scrollView setContentSize:CGSizeMake([self frame].size.width, height)];
        [UIView commitAnimations];
        
        
        if (offset.y + scrollView.frame.size.height > height) {
            offset.y = height - scrollView.frame.size.height;
            if (offset.y < 0) {
                offset.y = 0;
            }
        }
        [scrollView setContentOffset:offset animated:YES];
        
        
        
        [self scrollViewDidScroll:scrollView];
    }
}

#pragma mark UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    [self.delegate accordionScrollViewDidScroll:aScrollView];
    
    int i = 0;
    for (UIView *view in views) {
        if (self.isHorizontal) {
            // TODO
        } else {
            if (view.frame.size.height > 0) {
                [aScrollView setScrollEnabled:TRUE];
                
                UIView *header = [headers objectAtIndex:i];
                CGRect content = view.frame;
                content.origin.y -= header.frame.size.height;
                content.size.height += header.frame.size.height;
                
                CGRect frame = header.frame;
                
                if (CGRectContainsPoint(content, aScrollView.contentOffset)) {
                    if (aScrollView.contentOffset.y < content.origin.y + content.size.height - frame.size.height) {
                        frame.origin.y = aScrollView.contentOffset.y;
                        [aScrollView setScrollsToTop:TRUE];
                    } else {
                        frame.origin.y = content.origin.y + content.size.height - frame.size.height;
                    }
                    
                } else {
                    frame.origin.y = view.frame.origin.y - frame.size.height;
                    
                    [aScrollView setScrollsToTop:TRUE];
                    
                }
                header.frame = frame;
            }
        }
        i++;
    }
    
    
}
@end
