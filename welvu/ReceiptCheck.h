
//
//   ReceiptCheck.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 07/12/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLReader.h"
//#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "welvuContants.h"
//#import <CoreTelephony/CTCarrier.h>
#import "welvuSpecialtyViewController.h"
#import "welvuAppDelegate.h"
//#define inAppConsumptionLink @"http://54.251.62.202/BTAdmin/web-services/service_insert_purchase_details_consumption.php?"
@protocol ReceiptCheckAppDelegate
-(void)ReceiptCheckAppDelegateDidFinish:(NSInteger) statusCode;
@end

@class ViewController;

/*
 * Class name: ReceiptCheck
 * Description: Holds the list of subscribed and non-Subcribed Specialty
 * Extends: NSObject
 * Delegate : NSURLConnectionDelegate, UINavigationControllerDelegate */
@interface ReceiptCheck : NSObject<NSURLConnectionDelegate,UINavigationControllerDelegate> {
    id<ReceiptCheckAppDelegate> delegate;
    ViewController *controller;
    NSMutableData *receivedData;
    UINavigationController *navigationcontroller;
    NSUserDefaults *defaults;
    NSMutableArray *araay;
    NSDictionary *receipt;
    NSString *receiptBase64Encoded;
    int icre;
    NSInteger specialtyKey;
    NSInteger statusCode;
}

+(ReceiptCheck *)validateReceiptWithData:(NSData *)receiptData completionHandler:(void(^)(BOOL,NSString *))handler;
+(ReceiptCheck *)validateReceiptWithData:(NSString *)receiptBase64 specialtyId:(NSInteger) specId completionHandler:(void(^)(BOOL,NSString *))handler;
-(id)initWithReceiptHandler:(NSString *)receiptBase64 specialtyId:(NSInteger) specId;

@property (nonatomic,retain) void(^completionBlock)(BOOL,NSString *);
@property (retain)  id<ReceiptCheckAppDelegate> delegate;
@property (nonatomic,retain) NSData *receiptData;
@property (nonatomic,retain)  NSString *receiptBase64Encoded;
@property (nonatomic, readwrite) NSInteger specialtyKey;
@property (nonatomic, readwrite) NSInteger statusCode;

-(void)checkReceipt;

@end
