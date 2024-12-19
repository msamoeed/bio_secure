// SecureStoragePlugin.h
#import <Flutter/Flutter.h>

@interface SecureStoragePlugin : NSObject<FlutterPlugin>
@end

// SecureStoragePlugin.m
#import "SecureStoragePlugin.h"
#if __has_include(<secure_storage/secure_storage-Swift.h>)
#import <secure_storage/secure_storage-Swift.h>
#else
#import "secure_storage-Swift.h"
#endif

@implementation SecureStoragePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftSecureStoragePlugin registerWithRegistrar:registrar];
}
@end
