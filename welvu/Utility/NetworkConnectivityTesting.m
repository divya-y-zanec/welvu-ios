//
//  NetworkConnectivityTesting.m
//  ReCATT
//
//  Created by Logesh Kumaraguru on 06/09/11.
//  Copyright 2011 ZANEC Soft Tech. All rights reserved.
//

#import "NetworkConnectivityTesting.h"


@implementation NetworkConnectivityTesting
/*
 * Method name: isDataSourceAvailable
 * Description:Check wheather the network connection is available
 * Parameters: nil
 * return nil
 */
+ (BOOL)isDataSourceAvailable
{
    static BOOL checkNetwork = YES;
	static BOOL _isDataSourceAvailable = NO;
    if (checkNetwork) { // Since checking the reachability of a host can be expensive, cache the result and perform the reachability check once.
        //checkNetwork = NO;
		
        Boolean success;
        const char *host_name = "www.apple.com"; // your data source host name
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
        SCNetworkReachabilityFlags flags;
        success = SCNetworkReachabilityGetFlags(reachability, &flags);
        _isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
        CFRelease(reachability);
    }
    return _isDataSourceAvailable;
}


@end
