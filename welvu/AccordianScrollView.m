//
//  AccordianScrollView.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 11/01/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "AccordianScrollView.h"

@implementation AccordianScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self setScrollEnabled:YES];
    [super touchesBegan:touches withEvent:event];
    [self.nextResponder touchesBegan:touches withEvent:event];
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
