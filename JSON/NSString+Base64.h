//
//   NSString+Base64.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 06/12/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Base64)

+ (NSString *) base64StringFromData:(NSData *)data length:(int)length;
+ (NSString*) encode:(const uint8_t*) input length:(NSInteger) length;
@end
