//
//  IOSPay.h
//
//  Created by xiaoming on 2017/9/8.
//  Copyright © 2017年 redbird. All rights reserved.
//

#ifndef IOSPay_h
#define IOSPay_h

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <StoreKit/SKPaymentTransaction.h>
#import <UIKit/UIKit.h>

@interface StroeObserver : NSObject<SKPaymentTransactionObserver,SKProductsRequestDelegate>

+(StroeObserver *) instance;
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
-(void)PurchasedTransaction: (SKPaymentTransaction *)transaction;
-(void)completeTransaction: (SKPaymentTransaction *)transaction;
-(void)failedTransaction: (SKPaymentTransaction *)transaction;
-(void)paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction;
-(void)paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error;

-(bool)CanMakePay;
-(void)restoreTransaction: (SKPaymentTransaction *)transaction;

-(void) getProductInfo:(NSString*)pid;
-(void)payProduct:(SKProduct*)product;
-(void)startObserver;
-(void)stopObserver;


@property bool isOb;

@end

#endif /* IOSPay_h */
