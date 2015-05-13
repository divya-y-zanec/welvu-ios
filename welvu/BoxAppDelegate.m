//
//  BoxAppDelegate.m
//  BoxSDKSampleApp
//
//  Created on 2/19/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxAppDelegate.h"
#import "KeychainItemWrapper.h"

#define REFRESH_TOKEN_KEY   (@"box_api_refresh_token")

@interface BoxAppDelegate ()

@property (nonatomic, readwrite, strong) KeychainItemWrapper *keychain;
- (void)boxAPITokensDidRefresh:(NSNotification *)notification;

@end

@implementation BoxAppDelegate

@synthesize keychain = _keychain;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup BoxSDK
//#error Set your client ID and client secret in the BoxSDK
    ////[BoxSDK sharedSDK].OAuth2Session.clientID = @"tmwbzyzc6mjucfwqm484zueojk0rjd8d";
    //[BoxSDK sharedSDK].OAuth2Session.clientSecret = @"I0giwNg1UNZmmEgSiMqCsrL6kj1cX26s";

    //[BoxSDK sharedSDK].OAuth2Session.clientID = @"w0otsypregrxkc01zje4ybprw1ul0atb";
    //[BoxSDK sharedSDK].OAuth2Session.clientSecret = @"RksQo4PPj3ajRUzcwNtlrbvllFu69W9b";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPITokensDidRefresh:)
                                                 name:BoxOAuth2SessionDidBecomeAuthenticatedNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPITokensDidRefresh:)
                                                 name:BoxOAuth2SessionDidRefreshTokensNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];

    // set up stored OAuth2 refresh token
    self.keychain = [[KeychainItemWrapper alloc] initWithIdentifier:REFRESH_TOKEN_KEY accessGroup:nil];
 
    id storedRefreshToken = [self.keychain objectForKey:(__bridge id)kSecValueData];
    if (storedRefreshToken)
    {
        [BoxSDK sharedSDK].OAuth2Session.refreshToken = storedRefreshToken;
    }

    return YES;
}

- (void)boxAPITokensDidRefresh:(NSNotification *)notification
{
    BoxOAuth2Session *OAuth2Session = (BoxOAuth2Session *) notification.object;
    [self setRefreshTokenInKeychain:OAuth2Session.refreshToken];
}

- (void)setRefreshTokenInKeychain:(NSString *)refreshToken
{
    [self.keychain setObject:@"BoxSDKSampleApp" forKey: (__bridge id)kSecAttrService];
    [self.keychain setObject:refreshToken forKey:(__bridge id)kSecValueData];
}

@end
