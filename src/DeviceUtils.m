//
//  NSObject+DeviceUtils.m
//  Created by xiaoming on 2017/11/16.
//  Copyright © 2017年 xiaoming. All rights reserved.
//
#import <sys/utsname.h>
#import "DeviceUtils.h"

@interface DeviceUtils(){}
    - (NSArray*) getDeviceSubViews;
@end

@implementation DeviceUtils : NSObject 

- (NSArray*) getDeviceSubViews
{
    BOOL iphoneX = [[self getDeviceGeneration] isEqualToString:@"iPhone X"];
    UIApplication* app = [UIApplication sharedApplication];
    NSArray* children = NULL;
    if(YES == iphoneX){
        children = [[[[[app valueForKeyPath:@"statusBar"]
                            valueForKeyPath:@"statusBar"]
                            valueForKeyPath:@"foregroundView"]
                            subviews][2] subviews];
    }else{
        children = [[[app valueForKeyPath:@"statusBar"]
                          valueForKeyPath:@"foregroundView"]
                          subviews];
    }
    return children;
}



+ (instancetype) instance
{
    static DeviceUtils* deviceUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        deviceUtil = [[DeviceUtils alloc] init];
    });
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
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
    //下面型号由 ios_type_spider.py 从https://www.theiphonewiki.com/wiki/Models 抓取
    NSDictionary<NSString*,NSString*> *map = @{
												@"iPhone1,1":@"iPhone",
												@"iPhone1,2":@"iPhone 3G",
												@"iPhone2,1":@"iPhone 3GS",
												@"iPhone3,1, iPhone3,2, iPhone3,3":@"iPhone 4",
												@"iPhone4,1":@"iPhone 4S",
												@"iPhone5,1, iPhone5,2":@"iPhone 5",
												@"iPhone5,3, iPhone5,4":@"iPhone 5c",
												@"iPhone6,1, iPhone6,2":@"iPhone 5s",
												@"iPhone7,2":@"iPhone 6",
												@"iPhone7,1":@"iPhone 6 Plus",
												@"iPhone8,1":@"iPhone 6s",
												@"iPhone8,2":@"iPhone 6s Plus",
												@"iPhone8,4":@"iPhone SE",
												@"iPhone9,1, iPhone9,3":@"iPhone 7",
												@"iPhone9,2, iPhone9,4":@"iPhone 7 Plus",
												@"iPhone10,1, iPhone10,4":@"iPhone 8",
												@"iPhone10,2, iPhone10,5":@"iPhone 8 Plus",
												@"iPhone10,3, iPhone10,6":@"iPhone X",
												@"iPhone11,8":@"iPhone XR",
												@"iPhone11,2":@"iPhone XS",
												@"iPhone11,4, iPhone11,6":@"iPhone XS Max",
												};
    
    NSString *platform = [self getDeviceIdentifier];
    if ([[map allKeys] containsObject:platform]) {
        NSArray* list =  [map allKeys];
        for(NSString* key in list){
            if([key containsString:platform]){
                return [map objectForKey:key];
            }
        }
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
    BOOL iphoneX = [[self getDeviceGeneration] isEqualToString:@"iPhone X"];
    NSArray* children = [self getDeviceSubViews];
    NSString* type = @"";
    if(YES == iphoneX){
        for (id child in children) {
            if ([child isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                type = @"wifi";
            }else if ([child isKindOfClass:NSClassFromString(@"_UIStatusBarStringView")]) {
                type = [child valueForKeyPath:@"originalText"];
            }
        }
        if([type isEqualToString:@""]){
            type = @"nil";
        }
        return type;
    }
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
    BOOL iphoneX = [[self getDeviceGeneration] isEqualToString:@"iPhone X"];
    NSArray* children = [self getDeviceSubViews];
    NSString* type = @"";
    int nType = 0;
    if(YES == iphoneX){
        for(id child in children){
            if([child isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]){
                nType = [[child valueForKey:@"_numberOfActiveBars"] intValue];
            }
        }
        return nType;
    }
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
    NSArray* children = [self getDeviceSubViews];
    NSString* type = @"";
    int nType = 0;
    BOOL iphoneX = [[self getDeviceGeneration] isEqualToString:@"iPhone X"];
    if(YES == iphoneX){
        for(id child in children){
            if([child isKindOfClass:NSClassFromString(@"_UIStatusBarSignalView")]){
                nType = [[child valueForKey:@"_numberOfActiveBars"] intValue];
            }
        }
        return nType;
    }
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
