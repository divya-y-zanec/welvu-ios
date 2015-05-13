//
//  BoxAppDelegate.h
//  BoxSDKSampleApp
//
//  Created on 2/19/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <BoxSDK/BoxSDK.h>

@interface BoxAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)setRefreshTokenInKeychain:(NSString *)refreshToken;

@end
