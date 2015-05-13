//
//  XMLReader.h
//  RestfulClient
//
//  Created by Logesh Kumaraguru on 27/09/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLReader : NSObject <NSXMLParserDelegate>
{
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
    NSError * __autoreleasing *errorPointer;
}

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;

@end 
