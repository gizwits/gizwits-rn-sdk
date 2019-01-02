#import "GizWifiDeviceCache.h"
#import "GizWifiCacheCommon.h"
#import "GizSDKClientLog.h"

static GizWifiDeviceCache *sharedInstance = nil;

@interface GizWifiDeviceCache()

@property (nonatomic, strong) NSMutableArray *mDelegates;
@property (nonatomic, strong) NSMutableArray *mCentrolDelegates;

@end

@implementation GizWifiDeviceCache

+ (instancetype)sharedInstance {
    if (nil == sharedInstance) {
        sharedInstance = [[GizWifiDeviceCache alloc] init];
    }
    return sharedInstance;
}

+ (NSMutableArray *)sharedDelegates {
    GizWifiDeviceCache *deviceCache = [self sharedInstance];
    if (nil == deviceCache.mDelegates) {
        deviceCache.mDelegates = [NSMutableArray array];
    }
    return deviceCache.mDelegates;
}

+ (NSMutableArray *)sharedCentrolDelegates {
    GizWifiDeviceCache *deviceCache = [self sharedInstance];
    if (nil == deviceCache.mCentrolDelegates) {
        deviceCache.mCentrolDelegates = [NSMutableArray array];
    }
    return deviceCache.mCentrolDelegates;
}

+ (void)addDelegate:(id<GizWifiDeviceDelegate>)delegate {
    [GizWifiCacheCommon addDelegate:delegate mutableArray:[self sharedDelegates]];
}

+ (void)removeDelegate:(id<GizWifiDeviceDelegate>)delegate {
    [GizWifiCacheCommon removeDelegate:delegate mutableArray:[self sharedDelegates]];
}

+ (void)addCentralDelegate:(id <GizWifiCentralControlDeviceDelegate>)delegate {
    [GizWifiCacheCommon addDelegate:delegate mutableArray:[self sharedCentrolDelegates]];
}

+ (void)removeCentralDelegate:(id <GizWifiCentralControlDeviceDelegate>)delegate {
    [GizWifiCacheCommon removeDelegate:delegate mutableArray:[self sharedCentrolDelegates]];
}

+ (GizWifiDevice *)cachedDeviceWithMacAddress:(NSString *)macAddress did:(NSString *)did
{
    if (nil == macAddress) {
      macAddress = @"";
    }
    
    if (nil == did) {
      did = @"did";
    }
    
    NSArray *deviceList = [[GizWifiSDK sharedInstance].deviceList copy];
    for (GizWifiDevice *device in deviceList) {
      if (device.delegate == nil) {
        device.delegate = [self sharedInstance];
      }
      if ([device.macAddress isEqualToString:macAddress]) {
        // 没有 did 的情况
        if (device.did.length == 0 && did.length == 0) return device;
        
        // did 匹配的情况
        if (device.did.length > 0 && [device.did isEqualToString:did]) return device;
      }
    }
    return nil;
}

#pragma mark - device delegate

- (void)device:(GizWifiDevice *)device didSetSubscribe:(NSError *)result isSubscribed:(BOOL)isSubscribed {
    for (id <GizWifiDeviceDelegate>delegate in self.mDelegates) {
        if ([delegate respondsToSelector:@selector(device:didSetSubscribe:isSubscribed:)]) {
            [delegate device:device didSetSubscribe:result isSubscribed:isSubscribed];
        }
    }
}

- (void)XPGWifiDevice:(GizWifiDevice *)device didReceiveData:(NSDictionary *)data result:(int)result {
    for (id <GizWifiDeviceDelegate>delegate in self.mDelegates) {
        if ([delegate respondsToSelector:@selector(XPGWifiDevice:didReceiveData:result:)]) {
            [delegate XPGWifiDevice:device didReceiveData:data result:result];
        }
    }
}

- (void)device:(GizWifiDevice *)device didReceiveData:(NSError *)result data:(NSDictionary *)dataMap withSN:(NSNumber *)sn {
    for (id <GizWifiDeviceDelegate>delegate in self.mDelegates) {
        if ([delegate respondsToSelector:@selector(device:didReceiveData:data:withSN:)]) {
            [delegate device:device didReceiveData:result data:dataMap withSN:sn];
        }
    }
}

- (void)device:(GizWifiDevice *)device didSetCustomInfo:(NSError *)result {
    for (id <GizWifiDeviceDelegate>delegate in self.mDelegates) {
        if ([delegate respondsToSelector:@selector(device:didSetCustomInfo:)]) {
            [delegate device:device didSetCustomInfo:result];
        }
    }
}

- (void)device:(GizWifiDevice *)device didUpdateNetStatus:(GizWifiDeviceNetStatus)netStatus {
    for (id <GizWifiCentralControlDeviceDelegate>delegate in self.mDelegates) {
        if ([delegate respondsToSelector:@selector(device:didUpdateNetStatus:)]) {
            [delegate device:device didUpdateNetStatus:netStatus];
        }
    }
}

@end
