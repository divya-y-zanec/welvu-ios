//
//  CustomPullToRefresh.m
//  PullToRefreshDemo
//
//  Created by John Wu on 3/22/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import "CustomPullToRefresh.h"

@implementation CustomPullToRefresh

- (id) initWithScrollView:(UIScrollView *)scrollView delegate:(id <CustomPullToRefreshDelegate>)delegate
                    isTop:(BOOL) isTopToRefresh isBot:(BOOL) isBotToRefresh {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _scrollView = [scrollView retain];
        _isTopRefresh = isTopToRefresh;
        _isBottomRefresh = isBotToRefresh;
        [_scrollView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
        
        _ptrc = [[MSPullToRefreshController alloc] initWithScrollView:_scrollView delegate:self];
        
        
        _rainbowTop = [[UIView alloc] initWithFrame:CGRectMake(0, -_scrollView.frame.size.height, _scrollView.frame.size.width, scrollView.frame.size.height)];
        _rainbowTop.backgroundColor = [UIColor clearColor];
        //_rainbowTop.animationImages = animationImages;
        //_rainbowTop.animationDuration = 2;
        if(_isTopRefresh) {
            [scrollView addSubview:_rainbowTop];
        }
        
        _rainbowBot = [[UIView alloc] initWithFrame:CGRectMake(0, _scrollView.frame.size.height, _scrollView.frame.size.width, _scrollView.frame.size.height)];
        _rainbowBot.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _rainbowBot.backgroundColor = [UIColor clearColor];
        //_rainbowBot.animationImages = animationImages;
        //_rainbowBot.animationDuration = 2;
        if(_isBottomRefresh) {
            [scrollView addSubview:_rainbowBot];
        }
        
        _arrowTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_ptr_flip.png"]];
        _arrowTop.frame = CGRectMake(10, _rainbowTop.frame.size.height - _arrowTop.frame.size.height - 10 , _arrowTop.frame.size.width, _arrowTop.frame.size.height);
        [_rainbowTop addSubview:_arrowTop];
        
        _pullToRefreshTopLabel = [[UILabel alloc]
                                  initWithFrame:CGRectMake(25, _rainbowTop.frame.size.height - _arrowTop.frame.size.height - 10, (_rainbowTop.frame.size.width - 25), 40)];
        _pullToRefreshTopLabel.backgroundColor = [UIColor clearColor];
        _pullToRefreshTopLabel.textAlignment = NSTextAlignmentCenter;
        _pullToRefreshTopLabel.text = NSLocalizedString(@"PULL_TO_REFRESH", nil);
        [_rainbowTop addSubview:_pullToRefreshTopLabel];
        
        _arrowBot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_ptr_flip.png"]];
        _arrowBot.frame = CGRectMake(10, 5 , 18, 40);
        _arrowBot.transform  = CGAffineTransformMakeRotation(M_PI);
        [_rainbowBot addSubview:_arrowBot];
        
        _pullToRefreshBotLabel = [[UILabel alloc]
                                  initWithFrame:CGRectMake(25, 0, (_rainbowBot.frame.size.width - 25), 40)];
        _pullToRefreshBotLabel.backgroundColor = [UIColor clearColor];
        _pullToRefreshBotLabel.textAlignment = NSTextAlignmentCenter;
        _pullToRefreshBotLabel.text = NSLocalizedString(@"PULL_TO_REFRESH", nil);
        [_rainbowBot addSubview:_pullToRefreshBotLabel];
    }
    return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    CGFloat contentSizeArea = _scrollView.contentSize.width * _scrollView.contentSize.height;
    CGFloat frameArea = _scrollView.frame.size.width*_scrollView.frame.size.height;
    CGSize adjustedContentSize = contentSizeArea < frameArea ? _scrollView.frame.size : _scrollView.contentSize;
    _rainbowBot.frame = CGRectMake(0, adjustedContentSize.height, _scrollView.frame.size.width, _scrollView.frame.size.height);
}

- (void)relocateBottomPullToRefresh {
    if(_rainbowBot != nil) {
        CGFloat contentSizeArea = _scrollView.contentSize.width * _scrollView.contentSize.height;
        CGFloat frameArea = _scrollView.frame.size.width*_scrollView.frame.size.height;
        CGSize adjustedContentSize = contentSizeArea < frameArea ? _scrollView.frame.size : _scrollView.contentSize;
        _rainbowBot.frame = CGRectMake(0, adjustedContentSize.height, _scrollView.frame.size.width, _scrollView.frame.size.height);
    }
}
- (void) dealloc {
    [_scrollView removeObserver:self forKeyPath:@"contentSize"];
    [_scrollView release];
    [_ptrc release];
    [_arrowTop release];
    [_rainbowTop release];
    [_rainbowBot release];
    [_arrowBot release];
    [super dealloc];
}

- (void) endRefresh {
    _arrowTop.hidden = NO;
    _arrowTop.transform = CGAffineTransformIdentity;
    [_ptrc finishRefreshingDirection:MSRefreshDirectionTop animated:YES];
    _pullToRefreshTopLabel.text = NSLocalizedString(@"PULL_TO_REFRESH", nil);
    
    [_ptrc finishRefreshingDirection:MSRefreshDirectionBottom animated:YES];
    _arrowBot.hidden = NO;
    _arrowBot.transform  = CGAffineTransformMakeRotation(M_PI);
    _pullToRefreshBotLabel.hidden = NO;
    _pullToRefreshBotLabel.text = NSLocalizedString(@"PULL_TO_REFRESH", nil);
    
}

- (void) startRefresh {
    [_ptrc startRefreshingDirection:MSRefreshDirectionBottom];
    
}

#pragma mark - MSPullToRefreshDelegate Methods

- (BOOL) pullToRefreshController:(MSPullToRefreshController *)controller canRefreshInDirection:(MSRefreshDirection)direction {
    
    if(_isTopRefresh && _isBottomRefresh) {
        return direction == MSRefreshDirectionTop || direction == MSRefreshDirectionBottom;
    }
    
    if(_isTopRefresh) {
        return direction == MSRefreshDirectionTop;
    }
    
    if(_isBottomRefresh) {
        return direction == MSRefreshDirectionBottom;
    }
    return false;
}

- (CGFloat) pullToRefreshController:(MSPullToRefreshController *)controller refreshingInsetForDirection:(MSRefreshDirection)direction {
    return 50;
}

- (CGFloat) pullToRefreshController:(MSPullToRefreshController *)controller refreshableInsetForDirection:(MSRefreshDirection)direction {
    return 50;
}

- (void) pullToRefreshController:(MSPullToRefreshController *)controller canEngageRefreshDirection:(MSRefreshDirection)direction {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    _arrowTop.transform = CGAffineTransformMakeRotation(M_PI);
    _pullToRefreshTopLabel.text = NSLocalizedString(@"RELEASE_TO_REFRESH", nil);
    
    _arrowBot.transform = CGAffineTransformIdentity;
    _pullToRefreshBotLabel.text =  NSLocalizedString(@"RELEASE_TO_REFRESH", nil);
    
    
    
    [UIView commitAnimations];
}

- (void) pullToRefreshController:(MSPullToRefreshController *)controller didDisengageRefreshDirection:(MSRefreshDirection)direction {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    _arrowTop.transform = CGAffineTransformIdentity;
    _pullToRefreshTopLabel.text = NSLocalizedString(@"PULL_TO_REFRESH", nil);
    
    _arrowBot.transform  = CGAffineTransformMakeRotation(M_PI);
    _pullToRefreshBotLabel.text = NSLocalizedString(@"PULL_TO_REFRESH", nil);
    [UIView commitAnimations];
}

- (void) pullToRefreshController:(MSPullToRefreshController *)controller didEngageRefreshDirection:(MSRefreshDirection)direction {
    _arrowTop.hidden = YES;
    _pullToRefreshTopLabel.text = NSLocalizedString(@"LOADING", nil);
    
    _arrowBot.hidden = YES;
    _pullToRefreshBotLabel.text = NSLocalizedString(@"LOADING", nil);
    [_delegate customPullToRefreshShouldRefresh:self directionEngaged:direction];
}
-(void)setPullToRefreshHide {
    
    _scrollView.hidden = YES;
}
@end
