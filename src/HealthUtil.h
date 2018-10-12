
//
// HealthUtil.h
//  Created by xiaoming on 2018/03/16.
//  Copyright © 2018年 xiaoming. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

//授权回调
typedef void(^PermissonCallBack)(BOOL,NSError*);
//写入数据回调
typedef void(^WriteCallBack)(BOOL,NSError*);
//读取步数回调
typedef void(^ReadStepsCallBack)(double);

@interface HealthUtil:NSObject

+ (instancetype) instance;

/**
 健康授权
 */
- (BOOL) authorizePermission:(PermissonCallBack)callBack;

/**
 获取步数
 */
-(void) getTodaySteps:(ReadStepsCallBack)cb;

/**
 写入步数
 */
-(void) saveStepsCount:(double) steps
             startDate:(NSDate*) start
               endDate:(NSDate*)end
                device:(HKDevice*) device
              callBack:(WriteCallBack) cb;

@end
