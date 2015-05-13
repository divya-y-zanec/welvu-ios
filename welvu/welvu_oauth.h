//
//  welvu_oauth.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 08/08/14.
//  Copyright (c) 2014 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
/*
 * Class name: welvu_oauth
 * Description: Data model for content of a oAuth  and performs persistance logic
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_oauth : NSObject {
    //oAuth
    NSInteger welvu_user_id;
    NSString *expires_in;
    NSString *refresh_token;
    NSString *scope;
    NSString *token_type;
    NSString *access_token;
    NSString *email_id;
    NSString *current_date;
}
//Properties of the object
@property (nonatomic, retain) NSString *current_date;
@property (nonatomic, retain) NSString *email_id;
@property (nonatomic, readwrite) NSInteger welvu_user_id;
@property (nonatomic, retain) NSString *expires_in;
@property (nonatomic, retain) NSString *refresh_token;
@property (nonatomic, retain) NSString *scope;
@property (nonatomic, retain)  NSString *token_type;
@property (nonatomic, retain)  NSString *access_token;

- (id)initWithUserId:(NSInteger) userId ;
+ (NSInteger)addWelvuOauthUser:(NSString *)dbPath:(welvu_oauth *)welvu_oauthModel;
-(BOOL)updateuseroauthtoken:(NSString *)dbPath:(welvu_oauth *)welvu_oauthModel;
+ (welvu_oauth *)getOauthDetailsByEmailId:(NSString *)dbPath emailId:(NSString *) emailId ;

+ (BOOL)deleteoauthValueFromDB:(NSString *)dbPath:(NSString *) email_id;
@end
