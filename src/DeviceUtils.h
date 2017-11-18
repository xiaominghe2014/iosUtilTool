//
//  NSObject+DeviceUtils.h
//  Created by xiaoming on 2017/11/16.
//  Copyright © 2017年 xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface DeviceUtils:NSObject

+ (DeviceUtils*) instance;

/**
 获取系统名称
 */
- (NSString*) getSysName;

/**
 获取系统版本号
 */
- (NSString*) getSysVersion;


/**
 获取设备Identifier
 */

-(NSString*) getDeviceIdentifier;


/**
  获取设备类型 此处只枚举了iphone目前所有型号
 @des ios设备内部型号---你可以从https://www.theiphonewiki.com/wiki/Models获取最新型号
 */
- (NSString*) getDeviceGeneration;

/**
 获取uuid
 */
- (NSString*) getUUID;

/**
 获取电量
 */
- (float) getBatterQuantity;

/**
 获取电池状态
 */
- (UIDeviceBatteryState) getBatteryState;

/**
 获取网络状态
 @return nil(未知),2G,3G,4G,wifi
 */
- (NSString*) getNetWorkType;

/**
 获取wifi强度
 */
- (int) getWifiStrength;

/**
 获取手机信号强度
 */
- (int) getSignalStrength;

@end


