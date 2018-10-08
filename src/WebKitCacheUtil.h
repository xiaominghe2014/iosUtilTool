//
//  WebKitCacheUtil.h
//  iosTest
//
//  Created by Ximena on 2018/9/25.
//  Copyright © 2018年 xiaoming. All rights reserved.
//  Note: use for UIWebView, not for WKWebView

#ifndef WebKitCacheUtil_h
#define WebKitCacheUtil_h

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
@interface WebKitCacheUtil:NSObject

+ (WebKitCacheUtil*) instance;

/**
 默认缓存目录
 */
-(NSString* __nonnull) defaultCachePath;
/**
 缓存目录
 */
-(NSString* __nonnull) cachePath;

/**
 设置缓存目录
 */
-(BOOL) setCachePath:(NSString* __nonnull)dir;

/**
 获取缓存目录文件集合
 */
- (NSArray<NSString *> *) cacheFilelist:(NSString* __nonnull)path;


/**
 获取缓存文件是否存在
 */
- (BOOL) isFileExist:(NSString* __nonnull)path;

/**
 拷贝文件到缓存
 */
- (BOOL) copyFileToCache:(NSString* __nonnull)file;

/**
 获取指定目录文件大小
 */
- (NSString*) getCacheSizeWithFilePath:(NSString *)path;


/**
 缓存指定文件
 */
- (BOOL) saveCache:(NSString*) file AtUrl:(NSString*) url;

/**
 复制文件夹
 */
+(void)copyDirectory:(NSString *)from To:(NSString *)to;

@end

#endif /* WebKitCacheUtil_h */
