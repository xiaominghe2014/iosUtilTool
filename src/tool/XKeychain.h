//
//  NSObject+XKeychain.h
//  iosTest
//
//  Created by Ximena on 2019/1/19.
//  Copyright © 2019 xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface  XKeychain:NSObject
+(NSString*) getValue:(NSString*)key fromService:(NSString*)service;
+(void) saveValue:(NSString*)value ByKey:(NSString*)key toService:(NSString*)service;
+(void) deleteService:(NSString*)service;
@end

NS_ASSUME_NONNULL_END
