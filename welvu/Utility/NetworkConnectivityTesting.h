//
//  NetworkConnectivityTesting.h
//  ReCATT
//
//  Created by Logesh Kumaraguru on 06/09/11.
//  Copyright 2011 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>
/*
 * Class name: NetworkConnectivityTesting
 * Description: To test the network connectivity of the device
 * Extends: NSObject
 * Delegate :nil
 */
@interface NetworkConnectivityTesting : NSObject {
    
}
+ (BOOL)isDataSourceAvailable;
@end
