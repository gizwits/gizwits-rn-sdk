#import <Foundation/Foundation.h>
#import <GizWifiSDK/GizWifiSDK.h>

@interface GizWifiSDKCache : NSObject

+ (void)addDelegate:(id <GizWifiSDKDelegate>)delegate;
+ (void)removeDelegate:(id <GizWifiSDKDelegate>)delegate;

@end
