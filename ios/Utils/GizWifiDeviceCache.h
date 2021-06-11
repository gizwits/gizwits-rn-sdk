#import <Foundation/Foundation.h>
#import <GizWifiSDK/GizWifiSDK.h>

/**
 * warning: 这些方法只能在主线程使用
 */
@interface GizWifiDeviceCache : NSObject<GizWifiDeviceDelegate, GizWifiCentralControlDeviceDelegate>

// 回调
+ (void)addDelegate:(id<GizWifiDeviceDelegate>)delegate;
+ (void)removeDelegate:(id<GizWifiDeviceDelegate>)delegate;
+ (void)addCentralDelegate:(id <GizWifiCentralControlDeviceDelegate>)delegate;
+ (void)removeCentralDelegate:(id <GizWifiCentralControlDeviceDelegate>)delegate;

// 缓存取出
+ (GizWifiDevice *)cachedDeviceWithMacAddress:(NSString *)macAddress did:(NSString *)did;
+ (GizWifiDevice *)cachedBleDeviceWithMacAddress:(NSString *)macAddress productKey:(NSString *)productKey;
+ (GizWifiCentralControlDevice *)cachedCentralControlDeviceWithMacAddress:(NSString *)macAddress did:(NSString *)did;
+ (void)device:(GizWifiDevice *)device didUpdateNetStatus:(GizWifiDeviceNetStatus)netStatus;
//+ (GizWifiSubDevice *)cachedSubDeviceWithMacAddress:(NSString *)macAddress did:(NSString *)did subDid:(NSString *)subDid;
//+ (GizWifiSubDevice *)cachedSubDeviceWithDid:(NSString *)did subDid:(NSString *)subDid;

@end
