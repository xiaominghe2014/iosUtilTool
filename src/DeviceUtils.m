//
//  NSObject+DeviceUtils.m
//  Created by xiaoming on 2017/11/16.
//  Copyright © 2017年 xiaoming. All rights reserved.
//
#import <sys/utsname.h>
#import "DeviceUtils.h"

@implementation DeviceUtils : NSObject 

static DeviceUtils* deviceUtil = nil;

+ (DeviceUtils*) instance
{
    if (nil == deviceUtil) {
        deviceUtil = [[DeviceUtils alloc] init];
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    }
    return deviceUtil;
}


- (NSString*) getSysName
{
    return [[UIDevice currentDevice] systemName];
}

- (NSString*) getSysVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString*) getDeviceIdentifier
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];;
}

- (NSString*) getDeviceGeneration
{
    NSDictionary<NSString*,NSString*> *map = @{
                                               @"iPhone1,1":@"iPhone 2G",
                                               @"iPhone1,2":@"iPhone 3G",
                                               @"iPhone2,1":@"iPhone 3GS",
                                               @"iPhone3,1":@"iPhone 4",
                                               @"iPhone3,2":@"iPhone 4",
                                               @"iPhone3,3":@"iPhone 4",
                                               @"iPhone4,1":@"iPhone 4S",
                                               @"iPhone5,1":@"iPhone 5",
                                               @"iPhone5,2":@"iPhone 5",
                                               @"iPhone5,3":@"iPhone 5c",
                                               @"iPhone5,4":@"iPhone 5c",
                                               @"iPhone6,1":@"iPhone 5s",
                                               @"iPhone6,2":@"iPhone 5s",
                                               @"iPhone7,1":@"iPhone 6 Plus",
                                               @"iPhone7,2":@"iPhone 6",
                                               @"iPhone8,1":@"iPhone 6s",
                                               @"iPhone8,2":@"iPhone 6s Plus",
                                               @"iPhone8,4":@"iPhone SE",
                                               @"iPhone9,1":@"iPhone 7",
                                               @"iPhone9,2":@"iPhone 7 Plus",
                                               @"iPhone9,3":@"iPhone 7",
                                               @"iPhone9,4":@"iPhone 7 Plus",
                                               @"iPhone10,1":@"iPhone 8",
                                               @"iPhone10,2":@"iPhone 8 Plus",
                                               @"iPhone10,3":@"iPhone X",
                                               @"iPhone10,4":@"iPhone 8",
                                               @"iPhone10,5":@"iPhone 8 Plus",
                                               @"iPhone10,6":@"iPhone X"};

    NSString *platform = [self getDeviceIdentifier];
    if ([[map allKeys] containsObject:platform]) {
        return [map objectForKey:platform];
    }
    return platform;
}

- (NSString*) getUUID
{
    return  [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}


- (float) getBatterQuantity
{
    return [[UIDevice currentDevice] batteryLevel];
}

- (UIDeviceBatteryState) getBatteryState
{
    return [[UIDevice currentDevice] batteryState];
}

- (NSString*) getNetWorkType
{
    UIApplication* app = [UIApplication sharedApplication];
    NSArray* children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    NSString* type = @"";
    int nType = 0;
    for (id child in children) {
        if([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")])
        {
            nType = [[child valueForKeyPath:@"dataNetworkType"] intValue];
            switch (nType) {
                case 0:
                    type = @"nil";
                    break;
                case 1:
                    type = @"2G";
                    break;
                case 2:
                    type = @"3G";
                    break;
                case 3:
                    type = @"4G";
                    break;
                case 5:
                    type = @"wifi";
                    break;
                default:
                    break;
            }
        }
    }
    return type;
}

- (int) getWifiStrength
{
    UIApplication* app = [UIApplication sharedApplication];
    NSArray* children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    NSString* type = @"";
    int nType = 0;
    for (id child in children) {
        if([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")])
        {
            type = child;
            break;
        }
    }
    if([type isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")])
    {
         nType = [[type valueForKey:@"_wifiStrengthBars"] intValue];
    }
   
    return nType;
}

- (int) getSignalStrength
{
    UIApplication* app = [UIApplication sharedApplication];
    NSArray* children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    NSString* type = @"";
    int nType = 0;
    for (id child in children) {
        if([child isKindOfClass:NSClassFromString(@"UIStatusBarSignalStrengthItemView")])
        {
            type = child;
            break;
        }
    }
    if([type isKindOfClass:NSClassFromString(@"UIStatusBarSignalStrengthItemView")])
    {
        nType = [[type valueForKey:@"_signalStrengthBars"] intValue];
    }
    
    return nType;
}


@end
