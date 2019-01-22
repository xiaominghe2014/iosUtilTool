//
//  NSObject+XKeychain.m
//  iosTest
//
//  Created by Ximena on 2019/1/19.
//  Copyright © 2019 xiaoming. All rights reserved.
//

#import "XKeychain.h"
#import <Security/Security.h>

@implementation  XKeychain:NSObject
+(NSString*) getValue:(NSString*)key fromService:(NSString*)service{
    NSMutableDictionary *keychain = (NSMutableDictionary *)[XKeychain load:service];
    return [keychain objectForKey:key];
}
+(void) saveValue:(NSString*)value ByKey:(NSString*)key toService:(NSString*)service;{
    NSMutableDictionary *keychain = [NSMutableDictionary dictionary];
    [keychain setObject:value forKey:key];
    [XKeychain save:service data:keychain];
}
+(void) deleteService:(NSString*)service{
    NSMutableDictionary *keychainQuery = [XKeychain getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)(keyData)];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

@end
