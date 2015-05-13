//
//  CustomPullToRefresh.h
//  PullToRefreshDemo
//
//  Created by John Wu on 3/22/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSPullToRefreshController.h"

@protocol CustomPullToRefreshDelegate;

@interface CustomPullToRefresh : NSObject <MSPullToRefreshDelegate> {
    UIView *_rainbowTop;
    UIImageView *_arrowTop;
    UILabel *_pullToRefreshTopLabel;
    UIView *_rainbowBot;
    UILabel *_pullToRefreshBotLabel;
    UIImageView *_arrowBot;
    MSPullToRefreshController *_ptrc;
    UIScrollView *_scrollView;
    
    id <CustomPullToRefreshDelegate> _delegate;
}
@property (nonatomic, readwrite) BOOL isTopRefresh;
@property (nonatomic, readwrite) BOOL isBottomRefresh;


- (id) initWithScrollView:(UIScrollView *)scrollView delegate:(id <CustomPullToRefreshDelegate>)delegate
                    isTop:(BOOL) isTopToRefresh isBot:(BOOL) isBotToRefresh;
- (void) endRefresh;
- (void) startRefresh;
- (void) relocateBottomPullToRefresh;

@end

@protocol CustomPullToRefreshDelegate <NSObject>

- (void) customPullToRefreshShouldRefresh:(CustomPullToRefresh *)ptr directionEngaged:(MSRefreshDirection)direction;

-(void)setPullToRefreshHide;
@end