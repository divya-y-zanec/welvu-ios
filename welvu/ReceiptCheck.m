//
//   ReceiptCheck.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 07/12/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//


#import "ReceiptCheck.h"
#import "NSString+Base64.h"
//#import "SBJSON.h"
//#import "JSONKit.h"

@implementation ReceiptCheck

@synthesize receiptBase64Encoded, receiptData,completionBlock, statusCode, specialtyKey;
//Validate the Receipt with the data
+(ReceiptCheck *)validateReceiptWithData:(NSData *)_receiptData completionHandler:(void(^)(BOOL,NSString *))handler {
    ReceiptCheck *checker = [[ReceiptCheck alloc] init];
    checker.receiptData=_receiptData;
    checker.completionBlock=handler;
    [checker checkReceipt];
    return checker;
    
}

+(ReceiptCheck *)validateReceiptWithData:(NSString *)receiptBase64 specialtyId:(NSInteger)specId completionHandler:(void(^)(BOOL,NSString *))handler {
    ReceiptCheck *checker = [[ReceiptCheck alloc] init];
    checker.receiptBase64Encoded = receiptBase64;
    checker.completionBlock=handler;
    checker.specialtyKey = specId;
    [checker checkReceiptWithParameter: checker.receiptBase64Encoded];
    [[NSUserDefaults standardUserDefaults] setValue:checker.receiptBase64Encoded
                                             forKey:[NSString stringWithFormat:@"Specialty_Receipt_%d",specId]];
    return checker;
}

-(id)initWithReceiptHandler:(NSString *)receiptBase64 specialtyId:(NSInteger) specId {
    self = [super init];
    if(self) {
        receiptBase64Encoded = receiptBase64;
        specialtyKey = specId;
        [self checkReceiptWithParameterSynchronous:receiptBase64Encoded];
    }
    return self;
}
//check the receipt
-(void)checkReceipt {
    // verifies receipt with Apple
    NSError *jsonError = nil;
    NSString *receiptBase64 = [NSString base64StringFromData:receiptData length:[receiptData length]];
    //NSLog(@"Receipt Base64: %@",receiptBase64);
    defaults=[NSUserDefaults standardUserDefaults];
    [defaults setValue:receiptBase64 forKey:@"ReceiptBase64"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                receiptBase64,@"receipt-data",
                                                                SHARED_SECRET,@"password",
                                                                nil]
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonError
                        ];
    //NSLog(@"JSON: %@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    // URL for sandbox receipt validation; replace "sandbox" with "buy" in production or you will receive
    // error codes 21006 or 21007
    NSURL *requestURL = [NSURL URLWithString:HYPERLINK_INAPP_PURCHASE];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:jsonData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if(conn) {
        receivedData = [[NSMutableData alloc] init];
    } else {
        completionBlock(NO,@"Cannot create connection");
    }
}

-(void)checkReceiptWithParameter:(NSString *) receiptBase64 {
    // verifies receipt with Apple
    NSError *jsonError = nil;
    //NSLog(@"Receipt Base64: %@",receiptBase64);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                receiptBase64,@"receipt-data",
                                                                SHARED_SECRET,@"password",
                                                                nil]
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonError
                        ];
    //NSLog(@"JSON: %@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    // URL for sandbox receipt validation; replace "sandbox" with "buy" in production or you will receive
    // error codes 21006 or 21007
    NSURL *requestURL = [NSURL URLWithString:HYPERLINK_INAPP_PURCHASE];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:jsonData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if(conn) {
        receivedData = [[NSMutableData alloc] init];
    } else {
        completionBlock(NO,@"Cannot create connection");
    }
}

-(void)checkReceiptWithParameterSynchronous:(NSString *) receiptBase64 {
    // verifies receipt with Apple
    NSError *jsonError = nil;
    //NSLog(@"Receipt Base64: %@",receiptBase64);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                receiptBase64,@"receipt-data",
                                                                SHARED_SECRET,@"password",
                                                                nil]
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonError
                        ];
    //NSLog(@"JSON: %@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    // URL for sandbox receipt validation; replace "sandbox" with "buy" in production or you will receive
    // error codes 21006 or 21007
    NSURL *requestURL = [NSURL URLWithString:HYPERLINK_INAPP_PURCHASE];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:jsonData];
    // NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    //Capturing server response
    NSURLResponse* response;
    NSError *error;
    NSData* result = [NSURLConnection sendSynchronousRequest:req  returningResponse:&response error:&error];
    if(!error) {
//        NSString *responseStr = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        //NSLog(@"iTunes response: %@",response);
        if(result){
             id convertedCompleteResponse = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:&error];
            
            if ([convertedCompleteResponse isKindOfClass:[NSDictionary class]]) {
                receipt = [[NSDictionary alloc]init];
                receipt = convertedCompleteResponse;
                //NSLog(@"%@",receipt);
                NSLog(@"AutoRenewalCode Code %d",[[receipt objectForKey:@"status"] integerValue]);
                statusCode = [[receipt objectForKey:@"status"] integerValue];
                NSDictionary *receiptDic = [receipt objectForKey:@"receipt"];
                [[NSUserDefaults standardUserDefaults] setValue:[receiptDic objectForKey:@"product_id"]
                                                         forKey:[NSString stringWithFormat:@"Specialty_IDentifier_%d",specialtyKey]];
                if([[receipt objectForKey:@"status"] integerValue] == 21006) {
                    receiptBase64Encoded = [receipt objectForKey:@"latest_receipt"];
                    [[NSUserDefaults standardUserDefaults] setValue:receiptBase64Encoded
                                                             forKey:[NSString stringWithFormat:@"Specialty_Receipt_%d",specialtyKey]];
                }
            }
        }
    } else {
        statusCode = -1;
    }
    /*if(conn) {
     receivedData = [[NSMutableData alloc] init];
     } else {
     completionBlock(NO,@"Cannot create connection");
     }*/
}

#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Cannot transmit receipt data. %@",[error localizedDescription]);
    completionBlock(NO,[error localizedDescription]);
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [receivedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
//    NSString *response = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
   // NSLog(@"iTunes response: %@",response);
    if(receivedData){
        NSError *error;

        id convertedCompleteResponse = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers error:&error];
        if ([convertedCompleteResponse isKindOfClass:[NSDictionary class]]) {
            receipt = [[NSDictionary alloc]init];
            receipt = convertedCompleteResponse;
            //NSLog(@"%@",receipt);
            NSLog(@"Status Code %d",[[receipt objectForKey:@"status"] integerValue]);
            statusCode = [[receipt objectForKey:@"status"] integerValue];
            if([[receipt objectForKey:@"status"] integerValue] == 21006) {
                receiptBase64Encoded = [receipt objectForKey:@"latest_receipt"];
                NSDictionary *receiptDic = [receipt objectForKey:@"receipt"];
                [[NSUserDefaults standardUserDefaults] setValue:[receiptDic objectForKey:@"product_id"]
                                                         forKey:[NSString stringWithFormat:@"Specialty_IDentifier_%d",specialtyKey]];
                [[NSUserDefaults standardUserDefaults] setValue:receiptBase64Encoded
                                                         forKey:[NSString stringWithFormat:@"Specialty_Receipt_%d",specialtyKey]];
            }
        }
    }
  }

@end
