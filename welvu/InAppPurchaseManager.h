
//
//  InAppPurchaseManager.h
//  welvu
//
//  Created by Santhosh Raj Sundaram on 05/12/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

#define kInAppPurchaseCreditsProductId @"com.zanec.welvuinapp.4"

#define kProductsLoadedNotification         @"ProductsLoaded"
#define kProductPurchasedNotification       @"ProductPurchased"
#define kProductPurchaseFailedNotification  @"ProductPurchaseFailed"

#define kProductPurchasedNotificationRegister       @"ProductPurchasedRegister"
#define kProductPurchaseFailedNotificationRegister  @"ProductPurchaseFailedRegister"

#define kProductPurchasedNotificationSignIn       @"ProductPurchasedSignIn"
#define kProductPurchaseFailedNotificationSignIn  @"ProductPurchaseFailedSignIn"

#define kProductPurchasedNotificationUpgrade       @"ProductPurchasedUpgrade"
#define kProductPurchaseFailedNotificationUpgrade  @"ProductPurchaseFailedUpgrade"
@protocol InAppPurchaseManagerDelegate
-(void)InAppPurchaseManagerDidFinish:(BOOL)purchasedSuccessfully receipt:(NSString *)transactionRecipt;
@end
/*
 * Class name: InAppPurchaseManager
 * Description: Holds the list of subscribed and non-Subcribed Specialty
 * Extends: NSObject
 * Delegate : SKProductsRequestDelegate, SKPaymentTransactionObserver */
@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    //assigning the Delegate to object
    id<InAppPurchaseManagerDelegate> delegate;
    NSSet * _productIdentifiers;    
    NSArray * _products;
    NSMutableSet * _purchasedProducts;
    SKProductsRequest * _request;
    NSString  *notificationIdentStr;
    
    SKProduct *product ;
    NSInteger productId;
}
//Assigning the property for delegate
@property (retain) id<InAppPurchaseManagerDelegate> delegate;
@property (nonatomic,retain)SKProduct *product ;
@property (retain) NSSet *productIdentifiers;
@property (retain) NSArray * products;
@property (retain) NSMutableSet *purchasedProducts;
@property (retain) SKProductsRequest *request;

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)buyProductIdentifier:(NSString *)productIdentifier NotficationIdent:(NSString *)_notificationIdent specialtyId:(NSInteger)prodId;
@end
