//
//  welvu_registration.h
//  welvu
//
//  Created by Logesh Kumaraguru on 23/01/13.
//  Copyright (c) 2013 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 * Class name: welvu_registration
 * Description: model for welvu registration
 * Extends: NSObject
 * Delegate: nil
 */
@interface welvu_registration : NSObject {
    NSInteger registration_id;
    NSString *name;
    NSString *username;
    NSString *email;
    NSString *password;
    NSString *specialtyType;
    NSString *organization_Name;
    NSString *phoneNumber;
}
//Property
@property (nonatomic, readwrite) NSInteger registration_id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain)  NSString *username;
@property (nonatomic, retain)  NSString *email;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *specialtyType;
@property (nonatomic, retain) NSString *organization_Name;
@property (nonatomic, retain) NSString *phoneNumber;

@end
