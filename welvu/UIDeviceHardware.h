//
//  UIDeviceHardware.h
//
//  Used to determine EXACT version of device software is running on.

#import <Foundation/Foundation.h>
/*
 * Class name: UIDeviceHardware
 * Description: Has functionality about the hardware of device
 * Extends: NSObject
 * Delegate :nil
 */
@interface UIDeviceHardware : NSObject

- (NSString *) platform;
- (NSString *) platformString;

@end