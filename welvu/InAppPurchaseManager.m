//
//  InAppPurchaseManager.m
//  welvu
//
//  Created by Santhosh Raj Sundaram on 05/12/12.
//  Copyright (c) 2012 ZANEC Soft Tech. All rights reserved.
//

#import "InAppPurchaseManager.h"
#import "ReceiptCheck.h"
#import "NSString+Base64.h"
#import "NSFileManagerDoNotBackup.h"

@implementation InAppPurchaseManager
@synthesize productIdentifiers = _productIdentifiers;
@synthesize products = _products;
@synthesize purchasedProducts = _purchasedProducts;
@synthesize request = _request;
@synthesize product;
@synthesize delegate;
/*
 * Method name: name
 * Description: to store product identifier
 * Parameters: productIdentifiers
 * return product identifier
 * Created On: 05-12-2012
 */
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        NSMutableSet * purchasedProducts = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [purchasedProducts addObject:productIdentifier];
            }
        }
        self.purchasedProducts = purchasedProducts;
        
    }
    return self;
}

/*
 * Method name: requestProductData
 * Description: to request the product the product data
 * Parameters: product identifier
 * return product identifier
 * Created On: 5-12-2012
 */
- (void)requestProductData:(NSString *)productIdentifier
{
    //Create a list of product identifiers
    NSSet *productSet = [NSSet setWithObjects:productIdentifier,
                         nil];

    //Create and initialize a products request object with the above list
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers: productSet];
    
    //Attach the request to your delegate
    request.delegate = self;
    
    //Send the request to the App Store
    [request start];
}

/*
 * Method name: productsRequest
 * Description: getting response from store kit
 * Parameters: request,response
 * return name,price,product identifier,and product description
 * Created On: 5-12-2012
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    self.products = response.products;
    self.request = nil;
    //NSLog(@"Product count: %u", [_products count]);
    for(int i=0;i<[_products count];i++)
    {
  product = [_products objectAtIndex:i];
       // NSLog(@"Name: %@ - Price: %f",[product localizedTitle],[[product price] doubleValue]);
       // NSLog(@"Product identifier: %@", [product productIdentifier]);
       // NSLog(@"Product Description: %@", product.localizedDescription);
        
        
    }
       [[NSNotificationCenter defaultCenter] postNotificationName:kProductsLoadedNotification object:_products];  
}

/*
 * Method name: recordTransaction
 * Description: to record transaction 
 * Parameters: transaction
 * return transaction
 * Created On: 04-12-2012
 */

- (void)recordTransaction:(SKPaymentTransaction *)transaction {
    // TODO: Record the transaction on the server side...    
   // NSLog(@"Record Transaction %@ ",transaction);
}
/*
 * Method name: provideContent
 * Description: to provide content for purchased product
 * Parameters: productIdentifier
 * return productIdentifier
 * Created On: 04-12-2012
 */
- (void)provideContent:(NSString *)productIdentifier trancsactionRec:(NSString *)transactionRecipt {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_purchasedProducts addObject:productIdentifier];
    
    if([notificationIdentStr isEqualToString:@"Register"])
        [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchasedNotificationRegister object:productIdentifier];
    if([notificationIdentStr isEqualToString:@"SignIn"])
        [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchasedNotificationSignIn object:productIdentifier];
    if([notificationIdentStr isEqualToString:@"Upgrade"])
        //[[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchasedNotificationUpgrade object:productIdentifier];
        [self.delegate InAppPurchaseManagerDidFinish:YES receipt:transactionRecipt];
    
}

/*
 * Method name: completeTransaction
 * Description: to complete the transaction
 * Parameters: transaction
 * return transaction
 * Created On: 04-12-2012
 */
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSString *receiptBase64 = [NSString base64StringFromData:transaction.transactionReceipt
                                                      length:[transaction.transactionReceipt length]];
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier trancsactionRec:receiptBase64];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self checkReceipt:transaction.transactionReceipt];
}
/*
 * Method name: checkReceipt
 * Description: to check the receipt
 * Parameters: receipt
 * return receipt
 * Created On: 06-12-2012
 */
-(void)checkReceipt:(NSData *)receipt {
    // save receipt
    NSArray *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *receiptStorageFile = [[dir objectAtIndex:0] stringByAppendingPathComponent:@"receipts.plist"];
    NSMutableArray *receiptStorage = [[NSMutableArray alloc] initWithContentsOfFile:receiptStorageFile];
    if(!receiptStorage) {
        receiptStorage = [[NSMutableArray alloc] init];
    }
    [receiptStorage addObject:receipt];
    //STM
    //[receiptStorage writeToFile:receiptStorageFile atomically:YES];
    NSURL *outputURL = [NSURL fileURLWithPath:receiptStorageFile];
    int success = [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:outputURL];
    NSString *receiptBase64 = [NSString base64StringFromData:receipt length:[receipt length]];
    ReceiptCheck *reciptChecker = [ReceiptCheck validateReceiptWithData:receiptBase64 specialtyId:productId
                                                      completionHandler:^(BOOL success,NSString *answer){
        NSLog(@"receipt status code %d", reciptChecker.statusCode);
        if(success==YES) {
            NSLog(@"Receipt has been validated: %@",answer);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank You!" message:@"Your purchase was successfull!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            NSLog(@"Receipt not validated! Error: %@",answer);

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Error" message:@"Cannot validate receipt" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [alert show];
        };
    }];
}

/*
 * Method name: restoreTransaction
 * Description: to restore transaction
 * Parameters: transaction
 * return transaction
 * Created On: 07-12-2012
 */
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [self recordTransaction: transaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier trancsactionRec:nil];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
}
/*
 * Method name: failedTransaction
 * Description: when transaction fails
 * Parameters: transaction
 * return transaction
 * Created On: 07-12-2012
 */
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSString *errStr=@"";
        errStr= transaction.error.localizedDescription;
        
        NSLog(@"Transaction error: %@ and %@", errStr, notificationIdentStr);
    }
    if([notificationIdentStr isEqualToString:@"Register"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseFailedNotificationRegister object:transaction];
    }
    if([notificationIdentStr isEqualToString:@"SignIn"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseFailedNotificationSignIn object:transaction];
    }
    if([notificationIdentStr isEqualToString:@"Upgrade"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseFailedNotificationUpgrade object:transaction];
    }
    
}
/*
 * Method name: paymentQueue
 * Description: here payment queue is processed
 * Parameters: transactions,queue
 * return transactions
 * Created On: 07-12-2012
 */

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
                break;
            default:
                break;
        }
    }
}

/*
 * Method name: buyProductIdentifier
 * Description: to buy the product identifer
 * Parameters: productIdentifier,_notificationIdent
 * return notification
 * Created On: 06-12-2012
 */
- (void)buyProductIdentifier:(NSString *)productIdentifier NotficationIdent:(NSString *)_notificationIdent specialtyId:(NSInteger)prodId{
    productId = prodId;
    notificationIdentStr=_notificationIdent;
   
  
  SKPayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    [self requestProductData:productIdentifier];
}
@end
