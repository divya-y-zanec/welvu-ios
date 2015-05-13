//
//  AccordianButton.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 11/01/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "AccordianButton.h"

@implementation AccordianButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.nextResponder touchesBegan:touches withEvent:event];
    [[NSNotificationCenter defaultCenter]
                    postNotificationName:@"scrolViewEnabled" object:self];
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
