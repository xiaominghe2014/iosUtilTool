//
//  NSObject+IOSPay.m
//  LibHNLobby
//
//  Created by xiaoming on 2017/9/8.
//  Copyright © 2017年 redbird. All rights reserved.
//

#import "IOSPay.h"

@implementation StroeObserver

static StroeObserver * _storeOb=nil;

+ (StroeObserver *)instance
{
    if(_storeOb ==nil){
        _storeOb=[[StroeObserver alloc]init];
        _storeOb.isOb = false;
    }
    
    return _storeOb;
}


-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"-----PurchasedTransaction----");
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
}

-(bool)CanMakePay
{
    //2
    return [SKPaymentQueue canMakePayments];
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    NSLog(@"-----------收到产品反馈信息--------------");
    
    NSArray *myProduct = response.products;
    
    NSLog(@"无效产品Product ID:%@",response.invalidProductIdentifiers);
    
    // NSLog(@"产品付费数量: %lu", (unsigned long)[myProduct count]);
    if (myProduct.count==0) {
        NSLog(@"无法获取产品信息，购买失败");
//        [[NSNotificationCenter defaultCenter] postNotificationName:kProductsLoadedFallNotification object:nil];
//        HttpUtils::removeLoading();
        return;
    }
    // populate UI
    for(SKProduct *product in myProduct){
        // NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
        //发送通知
        // [[NSNotificationCenter defaultCenter] postNotificationName:kProductsLoadedNotification object:product];
    }
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:kProductsLoadedNotification object:myProduct];
    
    NSLog(@"-----------收到产品反馈信息--------------");  
}


-(void)payProduct:(SKProduct *)product
{
    SKPayment* payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//弹出错误信息
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@",error.localizedDescription);
    NSLog(@"-------弹出错误信息----------");
}


//如果没有设置监听购买结果将直接跳至反馈结束；
-(void) requestDidFinish:(SKRequest *)request
{
    NSLog(@"----------反馈信息结束--------------");
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions//交易结果
{
    NSLog(@"-----paymentQueue  updatedTransactions,购买结果--------");
//    HttpUtils::removeLoading();
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
                
            case SKPaymentTransactionStatePurchasing:      //点击购买按钮添加支付队列，商品添加进列表
                //Update your UI to reflect the in-progress status, and wait to be called again.
                NSLog(@"-----商品添加进列表 --------");
//                [[NSNotificationCenter defaultCenter] postNotificationName:kProducts1Notification object:nil];
                break;
            case SKPaymentTransactionStateDeferred:
                //Update your UI to reflect the deferred status, and wait to be called again.
//                [[NSNotificationCenter defaultCenter] postNotificationName:kProducts2Notification object:nil];
                NSLog(@"-----交易延期—－－－－");
                break;
            case SKPaymentTransactionStatePurchased://交易完成
                [self completeTransaction:transaction];
                NSLog(@"-----交易完成 --------");
                break;
            case SKPaymentTransactionStateFailed://交易失败
                [self failedTransaction:transaction];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kProducts3Notification object:nil];
                NSLog(@"-----交易失败 --------");
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kProducts4Notification object:nil];
                NSLog(@"-----已经购买过该商品 --------");
            default:
                break;
        }
    }
}
- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    
    NSString * str=[[NSString alloc]initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    NSData* data64 = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString* str64 = [data64 base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//    std::string data = [str64 UTF8String];
 //   NSString *environment=[self environmentForReceipt:str];
 //   NSLog(@"----- 完成交易调用的方法completeTransaction 1--------%@",environment);
    
    // 接受到的App Store验证字符串，这里需要经过JSON编码
    //   //收据编码方法一；
    //    NSString* jsonObjectString = [self encode:(uint8_t *)transaction.transactionReceipt.bytes length:transaction.transactionReceipt.length];
    //
    //    NSLog(@"接受到64编码后的App Store验证字符串,将收据进行编码，传入收据的二进制数据，和收据的长度，这里需要经过JSON编码%@",str);
    //
    //    // 以下为测试POST到itunes上验证，正常来说，装jsonObjectString发给服务器，由服务器来完成验证
    //
    //    NSString* sendString = [[NSString alloc] initWithFormat:@"{\"receipt-data\":\"%@\"}",jsonObjectString];
    //
    //收据编码方法二；
    // 验证凭据，获取到苹果返回的交易凭据
    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
 //   NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    // 从沙盒中获取到购买凭据
  //  NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    /**
     20      BASE64 常用的编码方案，通常用于数据传输，以及加密算法的基础算法，传输过程中能够保证数据传输的稳定性
     21      BASE64是可以编码和解码的
     22      */
//    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//    
//    NSString *sendString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", encodeStr];
//    NSLog(@"_____%@",sendString);
//    NSURL *StoreURL=nil;
//    if ([environment isEqualToString:@"environment=Sandbox"]) {
//        
//        StoreURL= [[NSURL alloc] initWithString: @"https://sandbox.itunes.apple.com/verifyReceipt"];
//    }
//    else{
//        
//        StoreURL= [[NSURL alloc] initWithString: @"https://buy.itunes.apple.com/verifyReceipt"];
//    }
//    
//        
//    [[NSNotificationCenter defaultCenter] postNotificationName:kProductsNotificationComplete object:nil];
    
    
    //这个二进制数据由服务器进行验证；zl
  //  NSData *postData = [NSData dataWithBytes:[sendString UTF8String] length:[sendString length]];
    
    
  //  NSLog(@"++++++%@",postData);
    
    
    
  //  NSMutableURLRequest *connectionRequest = [NSMutableURLRequest requestWithURL:StoreURL];
    
//    [connectionRequest setHTTPMethod:@"POST"];
//    [connectionRequest setTimeoutInterval:50.0];//120.0---50.0zl
//    [connectionRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
//    [connectionRequest setHTTPBody:postData];
    //
    //	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
  //  NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:connectionRequest delegate:self];
    //[connection release];
    
    
    // Your application should implement these two methods.
    
    NSString *product = transaction.payment.productIdentifier;
    
    NSLog(@"transaction.payment.productIdentifier++++%@",product);
    
    if ([product length] > 0)
    {
        NSArray *tt = [product componentsSeparatedByString:@"."];
        
        NSString *bookid = [tt lastObject];
        
        if([bookid length] > 0)
        {
            
            NSLog(@"打印bookid%@",bookid);
        }
    }
    //在此做交易记录
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    
    NSLog(@"交易失败2");
    if (transaction.error.code == SKErrorPaymentCancelled)
    {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"提 示" message:@"你已取消购买"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
    else if(transaction.error.code==SKErrorPaymentInvalid)
    {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"提 示" message:@"支付无效"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        
    }
    else if(transaction.error.code==SKErrorPaymentNotAllowed)
    {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"提 示" message:@"不允许支付"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        
    }
    else if(transaction.error.code==SKErrorStoreProductNotAvailable)
    {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"提 示" message:@"产品无效"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        
    }
    else if(transaction.error.code==SKErrorClientInvalid)
    {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"提 示" message:@"客服端无效"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        
    }
    
    
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    // [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchasedButtonOpenNotification object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"openButton" object:nil];
    
    
}
-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction
{
    NSLog(@"paymentQueueRestoreCompletedTransactionFinishied方法");
    
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"已经购买过该商品 --- 交易恢复处理");    
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"-------paymentQueue，restoreCompletedTransactionsFailedWithError----");
}

-(NSString * )environmentForReceipt:(NSString * )str
{
    str= [str stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    str = [str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    
    str=[str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    str=[str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    NSArray * arr=[str componentsSeparatedByString:@";"];
    
    //存储收据环境的变量
    NSString * environment=arr[2];
    return environment;
}

-(void) getProductInfo:(NSString*)pid
{
//    HttpUtils::addLoading();
    NSArray *product = [[NSArray alloc] initWithObjects:pid, nil];
    NSSet *set = [NSSet setWithArray:product];
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
}

-(void)startObserver
{
    if(!self.isOb)
    {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        self.isOb = true;
    }
}

-(void)stopObserver
{
    if(self.isOb)
    {
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
        self.isOb = false;
    }
}

@end
