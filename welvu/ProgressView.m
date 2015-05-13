//
//  ProgressView.m
//  welvu
//
//  Created by Logesh Kumaraguru on 08/02/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import "ProgressView.h"

@implementation ProgressView
@synthesize progressView, progressStatus;
/*
 * Method name: initWithFrame
 * Description:initlizing the frame for progress view
 * Parameters: frame
 * return nil
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
        [progressView setProgress: 0.];
        [progressView setProgressViewStyle:UIProgressViewStyleBar];
        [self addSubview:progressView];
        progressStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 250, 40)];
        progressStatus.backgroundColor = [UIColor clearColor];
        progressStatus.textAlignment = UITextAlignmentCenter;
        progressStatus.textColor = [UIColor whiteColor];
        NSString *percent=@"%";
        NSString *getPercent= [NSString stringWithFormat:@"%d",0];
        
        NSString *getTotalPercent=[getPercent stringByAppendingFormat:@"%@",percent];
        
         progressStatus.text=getTotalPercent;
        [self addSubview:progressStatus];
        progressLevel = 0;
    }
    return self;
}

-(void) progressStatus:(double) progLevel {

}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

/*
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
@end
