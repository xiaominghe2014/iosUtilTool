//
//  WebKitCacheUtil.m
//  iosTest
//
//  Created by Ximena on 2018/9/25.
//  Copyright © 2018年 xiaoming. All rights reserved.
//

#import "WebKitCacheUtil.h"

#import <UIKit/UIKit.h>
#import <UIKit/UIPasteboard.h>

//#import "DPLocalCache.h"

@interface WebKitCacheUtil(){}
@property(nonatomic, strong) NSString *m_cachePath;
@end

@implementation WebKitCacheUtil : NSObject

static WebKitCacheUtil* cacheUtil = nil;

+ (WebKitCacheUtil*) instance
{
    if (nil == cacheUtil) {
        cacheUtil = [[WebKitCacheUtil alloc] init];
        [cacheUtil setCachePath:[cacheUtil defaultCachePath]];
    }
    return cacheUtil;
}


- (NSString* ) defaultCachePath{
    return @"testCache";
}

- (NSString* ) cachePath{
    return [self m_cachePath];
}

- (BOOL) setCachePath:(NSString *)dir{
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    self.m_cachePath = [NSString stringWithFormat:@"%@/%@/%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject],bundleId,dir];
    NSURLCache* cache = [[NSURLCache alloc] initWithMemoryCapacity:20*1024*1024 diskCapacity:200*1024*1024 diskPath:dir];
    [NSURLCache setSharedURLCache:cache];
    return YES;
}

- (NSArray<NSString *> *)cacheFilelist:(NSString * )path{
    NSArray *subPathArr = [[NSFileManager defaultManager] subpathsAtPath:path];
    return subPathArr;
}


- (BOOL)isFileExist:(NSString *)path{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}


- (BOOL)copyFileToCache:(NSString *)file{
    NSFileManager *fm = [NSFileManager defaultManager];
    if(NO==[fm fileExistsAtPath:file]){
        NSLog(@"文件不存在");
        return NO;
    }
    
    NSString* fileName = [fm displayNameAtPath:[NSString stringWithFormat:@"%@",file]];
    NSString* to = [NSString stringWithFormat:@"%@/%@",self.cachePath,fileName];
//    if(YES==[fm fileExistsAtPath:to]){
//        BOOL deleted = [fm removeItemAtPath:to error:nil];
//        NSLog(@"删除:%d",deleted);
//    }
    if(YES == [fm fileExistsAtPath:file isDirectory:nil]){
        file = [file stringByAppendingString:@"/"];
        to = [to stringByAppendingString:@"/"];
        if(NO == [fm fileExistsAtPath:to isDirectory:nil]){
//             BOOL create = [[NSFileManager defaultManager] createDirectoryAtPath:to withIntermediateDirectories:YES attributes:nil error:NULL];
//            if(create){
//                NSLog(@"创建成功");
//            }
        }else{
            BOOL deleted = [fm removeItemAtPath:to error:nil];
            if(deleted){
                NSLog(@"删除%@成功",to);
            }
        }
    }

    NSError *copyError = nil;
    if(NO==[fm copyItemAtPath:file toPath:to error:&copyError]){
        NSLog(@"复制失败:%@",[copyError localizedDescription]);
        NSArray *cachelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self cachePath] error:nil];
        NSArray *pathlist = [[NSFileManager defaultManager] subpathsAtPath:[self cachePath]];
        NSLog(@"%@",cachelist);
        for(NSString* temp in cachelist){
            NSLog(@"%@",temp);
        }
        NSLog(@"_m_cachePath = %@",self.m_cachePath);
        return NO;
    }
    NSArray *cachelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self cachePath] error:nil];
    
    NSLog(@"%@",cachelist);
    for(NSString* temp in cachelist){
        NSLog(@"%@",temp);
    }
    NSArray *pathlist = [[NSFileManager defaultManager] subpathsAtPath:[self cachePath]];
    return YES;
}

- (NSString*) getCacheSizeWithFilePath:(NSString *)path{
    NSArray *subPathArr = [[NSFileManager defaultManager] subpathsAtPath:path];
    NSString *filePath  = nil;
    NSInteger totleSize = 0;
    for (NSString *subPath in subPathArr){
        if (![subPath containsString:@"Snapshots"]) {
            filePath =[path stringByAppendingPathComponent:subPath];
        }
        BOOL isDirectory = NO;
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        if (!isExist || isDirectory || [filePath containsString:@".DS"]){
            continue;
        }
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        /**
         attributesOfItemAtPath: 文件夹路径
         该方法只能获取文件的属性, 无法获取文件夹属性, 所以也是需要遍历文件夹的每一个文件的原因
         */
        NSInteger size = [dict[@"NSFileSize"] integerValue];
        totleSize += size;
    }
    
    //将文件夹大小转换为 M/KB/B
    NSString *totleStr = nil;
    if (totleSize > 1000 * 1000){
        totleStr = [NSString stringWithFormat:@"%.2fM",totleSize / 1000.00f /1000.00f];
    }else if (totleSize > 1000){
        totleStr = [NSString stringWithFormat:@"%.2fKB",totleSize / 1000.00f ];
    }else{
        totleStr = [NSString stringWithFormat:@"%.2fB",totleSize / 1.00f];
    }
    return totleStr;
}

- (BOOL)saveCache:(NSString *)file AtUrl:(NSString *)url{
   
    BOOL isDirectory = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDirectory];
    //判断文件是否存在，略过文件夹
    if(YES==isExist&&NO==isDirectory){
        NSURL* fileUrl = [NSURL fileURLWithPath:file];
        NSMutableURLRequest* fileReq = [NSMutableURLRequest requestWithURL:fileUrl];
        NSHTTPURLResponse* fileResp = nil;
        [NSURLConnection sendSynchronousRequest:fileReq returningResponse:&fileResp error:nil];
        NSString* type = fileResp.MIMEType;
        NSString* encode = fileResp.textEncodingName;
        NSInteger len = fileResp.expectedContentLength;
        NSData *fileData = [NSData dataWithContentsOfFile:file];
        
        NSURLCache * cache = [NSURLCache sharedURLCache];
        NSURL* caceUrl = [NSURL URLWithString:url];
        NSURLRequest *cacheReq = [NSURLRequest requestWithURL:caceUrl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:3];
        NSURLResponse *cacheResp = [[NSURLResponse alloc] initWithURL:caceUrl MIMEType:type expectedContentLength:len textEncodingName:encode];
        NSCachedURLResponse *cacheRespone = [[NSCachedURLResponse alloc] initWithResponse:cacheResp data:fileData];
        [cache storeCachedResponse:cacheRespone forRequest:cacheReq];
        return YES;
    }
    NSLog(@"无效的文件:file=%@",file);
    return NO;
}

+(void)copyDirectory:(NSString *)from To:(NSString *)to
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(NO == [fileManager fileExistsAtPath:to]){
        BOOL create = [[NSFileManager defaultManager] createDirectoryAtPath:to withIntermediateDirectories:YES attributes:nil error:NULL];
        if(create){
            NSLog(@"创建%@",to);
        }
    }
    NSArray* array = [fileManager contentsOfDirectoryAtPath:from error:nil];
    for(int i = 0; i<[array count]; i++)
    {
        NSString *fullPath = [from stringByAppendingPathComponent:[array objectAtIndex:i]];
        NSString *fullToPath = [to stringByAppendingPathComponent:[array objectAtIndex:i]];
        NSLog(@"%@",fullPath);
        NSLog(@"%@",fullToPath);
        BOOL isFolder = NO;
        BOOL isExist = [fileManager fileExistsAtPath:fullPath isDirectory:&isFolder];
        if (isExist)
        {
            NSError *err = nil;
            [[NSFileManager defaultManager] copyItemAtPath:fullPath toPath:fullToPath error:&err];
            if (isFolder)
            {
                [WebKitCacheUtil copyDirectory:fullPath To:fullToPath];
            }
            else if(err){
                NSLog(@"复制失败:%@",err);
            }
        }
    }
}

@end
