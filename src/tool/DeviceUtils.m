//
//  NSObject+DeviceUtils.m
//  Created by xiaoming on 2017/11/16.
//  Copyright © 2017年 xiaoming. All rights reserved.
//
#import <sys/utsname.h>
#import "DeviceUtils.h"
#import "ios_device_des.h"
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
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSASCIIStringEncoding];
}

- (NSString*) getDeviceGeneration
{
    NSString *platform = [self getDeviceIdentifier];
    NSData* data = [IOS_DES dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if ([[dic allKeys] containsObject:platform]) {
        NSArray* list =  [dic allKeys];
        for(NSString* key in list){
            if([key containsString:platform]){
                return [dic objectForKey:key];
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

+ (void)systemShareWithController:(UIViewController *)controller title:(NSString *)title url:(NSString *)url image:(NSString *)path{
    NSString* shareTitle = title;
    UIImage *shareImage = [UIImage imageWithContentsOfFile:path];
    NSURL *shareUrl = [NSURL URLWithString:url];
    NSArray *shareItems = @[shareTitle,shareImage,shareUrl];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    [controller presentViewController:activityVC animated:YES completion:nil];
}
@end
