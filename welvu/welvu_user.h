//
//  welvu_user.h
//  welvu
//
//  Created by Logesh Kumaraguru on 25/01/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
/*
 * Class name: welvu_topics
 * Description: Data model for user
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_user : NSObject {
    NSInteger welvu_user_id;
    NSString *firstname;
    NSString *middlename;
    NSString *lastname;
    NSString *username;
    NSString *email;
    NSString *specialty;
    NSString *access_token;
    NSInteger org_id;
    NSInteger user_primary_key;
    NSDate *access_token_obtained_on;
    BOOL current_logged_user;
    //BOX
    NSString *box_access_token;
    NSString *box_refresh_access_token;
    NSString *box_expires_in;
    NSString *user_Org_Role;
    NSString * user_org_status;
    NSString *isConfirmedUser;
    //oauth
    
    
    NSDate *oauth_expires_in;
    NSString *oauth_refresh_token;
    NSString *oauth_scope;
    NSString *oauth_token_type;
    NSDate *oauth_currentDate;
}

@property (nonatomic ,retain)  NSString * user_org_status;
@property (nonatomic ,retain) NSString *user_Org_Role;
//Box Property
@property (nonatomic ,retain)   NSString *box_expires_in;
@property (nonatomic, retain)   NSString *box_access_token;
@property (nonatomic, retain)   NSString *box_refresh_access_token;
//Property
@property (nonatomic, readwrite) NSInteger welvu_user_id;
@property (nonatomic, retain) NSString *firstname;
@property (nonatomic, retain) NSString *middlename;
@property (nonatomic, retain) NSString *lastname;
@property (nonatomic, retain)  NSString *username;
@property (nonatomic, retain)  NSString *email;
@property (nonatomic, retain) NSString *specialty;
@property (nonatomic, retain)  NSString *access_token;
@property (nonatomic, readwrite) NSInteger org_id;
@property (nonatomic, readwrite) NSInteger user_primary_key;
@property (nonatomic, retain) NSDate *access_token_obtained_on;
@property (nonatomic, readwrite) BOOL current_logged_user;

//oauth
@property (nonatomic, retain) NSDate *oauth_currentDate;
@property (nonatomic, retain)  NSDate *oauth_expires_in;
@property (nonatomic, retain)   NSString *oauth_refresh_token;
@property (nonatomic, retain)   NSString *oauth_token_type;
@property (nonatomic, retain)   NSString *oauth_scope;
@property (nonatomic ,retain) NSString *isConfirmedUser;


//Methods
- (id)initWithUserId:(NSInteger)userId;
+ (welvu_user *) copy:(welvu_user *) welvuUserModel;
+ (NSInteger)addWelvuUser:(NSString *)dbPath:(welvu_user *)welvu_userModel;
+ (NSInteger)getLastInsertRowId:(NSString *)dbPath:(NSInteger)topic_id;
+ (welvu_user *)getCurrentLoggedUser:(NSString *)dbPath;
+ (welvu_user *)getUserByEmailId:(NSString *)dbPath emailId:(NSString *) emailId;
+ (welvu_user *)getUserByEmailIdAndOrgId:(NSString *)dbPath emailId:(NSString *) emailId
                                   orgId:(NSInteger) orgId;
+ (welvu_user *)getUserByAccessToken:(NSString *)dbPath token:(NSString *) accessToken;
+ (NSMutableArray *) getAllOrgIdOfUser:(NSString *)dbPath userId:(NSInteger) user_id;
+ (NSInteger)updateLoggedUserAccessToken:(NSString *)dbPath:(welvu_user *)welvu_userModel;
+ (NSInteger)updateLoggedorgUserAccessToken:(NSString *)dbPath:(welvu_user *)welvu_userModel;
+ (NSInteger)updateLoggedUserByOrgId:(NSString *)dbPath userId:(NSInteger) user_id
                               orgId:(NSInteger) orgId isPrimary:(BOOL) isPrimary;
+ (NSInteger)addWelvuUserWithAccessToken:(NSString *)dbPath:(welvu_user *)welvu_userModel;
//santhosh-20-march-2013
+ (NSString *)getWelvuUserAccessToken:(NSString *)dbPath;
+ (NSInteger)updateConfirmedLoggedUserAccessToken:(NSString *)dbPath:(welvu_user *)welvu_userModel;
+ (BOOL) logoutUser:(NSString *)dbPath :(welvu_user *)welvu_userModel;

+ (BOOL)updateBoxAccessToken:(NSString *)dbPath:(welvu_user *)welvu_userModel;
//organization
+ (NSInteger)addUserWithOrganizationDetails:(NSString *)dbPath:(welvu_user *)welvu_userModel;
+ (NSInteger )prymaryId:(NSString *)dbPath :(NSInteger)orgID :(NSInteger)UserPId;
+ (welvu_user *) getUserIdByOrgId:(NSString *)dbPath:(NSInteger )org_Id;
+ (BOOL) switchAccount:(NSString *)dbPath ;
+ (NSInteger)getUserCount:(NSString *)dbPath :(NSInteger)user_id;
+ (BOOL) logoutUserInSettings:(NSString *)dbPath :(welvu_user *)welvu_userModel;
+ (NSMutableArray *) getAllOrgStatusOfUser:(NSString *)dbPath userId:(NSInteger) user_id;
+(NSInteger)getOrgIdByWelvuUserId:(NSString *)dbPath :(NSInteger)userId;
+ (NSInteger)getOrgUserCount:(NSString *)dbPath :(NSInteger)user_id;
+ (BOOL) clearAccessandRefreshToken:(NSString *)dbPath ;
+ (NSInteger)updateUserOrgStatus:(NSString *)dbPath :(welvu_user *)welvu_userModel;
+ (NSInteger)getPrimaryIdByUserId:(NSString *)dbPath :(NSInteger)user_id;
+ (NSInteger)addUserWithoauthDetails:(NSString *)dbPath:(welvu_user *)welvu_userModel;
+ (NSInteger)updateOauthLoggedUserAccessToken:(NSString *)dbPath:(welvu_user *)welvu_userModel;
+ (NSInteger)getOrganizationCountByUserId:(NSString *)dbPath currentLogedUserId:(NSInteger)currentLogedUserID ;

@end

