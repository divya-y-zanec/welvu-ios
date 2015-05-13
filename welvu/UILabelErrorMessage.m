//
//  UILabelErrorMessage.m
//  welvu
//
//  Created by Logesh Kumaraguru on 19/02/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "UILabelErrorMessage.h"

@implementation UILabelErrorMessage

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
        // Initialization code
	}
	return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIEdgeInsets insets = {0,43,0,0};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}


@end
