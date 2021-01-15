#import "GizWifiSDKCache.h"
#import "GizWifiCacheCommon.h"
#import "GizSDKClientLog.h"

static GizWifiSDKCache *sharedInstance = nil;

@interface GizWifiSDKCache()<GizWifiSDKDelegate>

@property (nonatomic, strong) NSMutableArray *mDelegates;

@end

@implementation GizWifiSDKCache

+ (instancetype)sharedInstance
{
  if (nil == sharedInstance) {
    sharedInstance = [[GizWifiSDKCache alloc] init];
    [GizWifiSDK sharedInstance].delegate = sharedInstance;
  }
  return sharedInstance;
}

+ (NSMutableArray *)sharedDelegates
{
  GizWifiSDKCache *sdkCache = [self sharedInstance];
  if (nil == sdkCache.mDelegates) {
    sdkCache.mDelegates = [NSMutableArray array];
  }
  return sdkCache.mDelegates;
}

+ (void)addDelegate:(id <GizWifiSDKDelegate>)delegate
{
  [GizWifiCacheCommon addDelegate:delegate mutableArray:[self sharedDelegates]];
}

+ (void)removeDelegate:(id <GizWifiSDKDelegate>)delegate
{
  [GizWifiCacheCommon removeDelegate:delegate mutableArray:[self sharedDelegates]];
}

#pragma mark - XPGWifiSDK delegate

#define GIZ_SDK_DELEGATE_CALLBACK_BEGIN(sel) \
for (id <GizWifiSDKDelegate>delegate in self.mDelegates) { \
    if ([delegate respondsToSelector:sel]) { \

#define GIZ_SDK_DELEGATE_CALLBACK_END() \
    } \
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didNotifyEvent:(GizEventType)eventType eventSource:(id)eventSource eventID:(GizWifiErrorCode)eventID eventMessage:(NSString *)eventMessage {
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didNotifyEvent:eventSource:eventID:eventMessage:))
    [delegate wifiSDK:wifiSDK didNotifyEvent:eventType eventSource:eventSource eventID:eventID eventMessage:eventMessage];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didUserLogin:(NSError *)result uid:(NSString *)uid token:(NSString *)token {
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didUserLogin:uid:token:))
    [delegate wifiSDK:wifiSDK didUserLogin:result uid:uid token:token];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didRequestSendPhoneSMSCode:(NSError *)result token:(NSString *)token {
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didRequestSendPhoneSMSCode:token:))
    [delegate wifiSDK:wifiSDK didRequestSendPhoneSMSCode:result token:nil];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didRegisterUser:(NSError *)result uid:(NSString *)uid token:(NSString *)token {
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didRegisterUser:uid:token:))
    [delegate wifiSDK:wifiSDK didRegisterUser:result uid:uid token:token];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didChangeUserPassword:(NSError *)result {
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didChangeUserPassword:))
    [delegate wifiSDK:wifiSDK didChangeUserPassword:result];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didGetUserInfo:(NSError *)result userInfo:(GizUserInfo *)userInfo {
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didGetUserInfo:userInfo:))
    [delegate wifiSDK:wifiSDK didGetUserInfo:result userInfo:userInfo];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didChangeUserInfo:(NSError *)result {
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didChangeUserInfo:))
    [delegate wifiSDK:wifiSDK didChangeUserInfo:result];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didSetDeviceOnboarding:(NSError *)result mac:(NSString *)mac did:(NSString *)did productKey:(NSString *)productKey {
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didSetDeviceOnboarding:mac:did:productKey:))
    [delegate wifiSDK:wifiSDK didSetDeviceOnboarding:result mac:mac did:did productKey:productKey];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didSetDeviceOnboarding:(NSError *)result device:(GizWifiDevice *)device {
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didSetDeviceOnboarding:device:))
    [delegate wifiSDK:wifiSDK didSetDeviceOnboarding:result device:device];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDiscovered:(NSError *)result deviceList:(NSArray *)deviceList {
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didDiscovered:deviceList:))
    [delegate wifiSDK:wifiSDK didDiscovered:result deviceList:deviceList];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

//- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDiscoveredMeshDevices:(NSError * _Nullable)result meshDeviceList:(NSArray * _Nonnull)meshDeviceList{
//  GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didDiscoveredMeshDevices:meshDeviceList:))
//  [delegate wifiSDK:wifiSDK didDiscoveredMeshDevices:result meshDeviceList:meshDeviceList];
//  GIZ_SDK_DELEGATE_CALLBACK_END()
//}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDeviceSafetyRegister:(NSArray *)successDevices failedDevices:(NSArray *)failedDevices{
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didDeviceSafetyRegister:failedDevices:))
    [delegate wifiSDK:wifiSDK didDeviceSafetyRegister:successDevices failedDevices:failedDevices];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

//- (void)wifiSDK:(GizWifiSDK *)wifiSDK didRestoreDeviceFactorySetting:(NSString *)mac result:(NSError *)result{
//  GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didChangeDeviceMesh:result:))
//  [delegate wifiSDK:wifiSDK didRestoreDeviceFactorySetting:mac result:result];
//  GIZ_SDK_DELEGATE_CALLBACK_END()
//}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDeviceSafetyUnbind:(NSArray *)failedDevices{
  GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didDeviceSafetyUnbind:))
  [delegate wifiSDK:wifiSDK didDeviceSafetyUnbind:failedDevices];
  GIZ_SDK_DELEGATE_CALLBACK_END()
}
//
//- (void)wifiSDK:(GizWifiSDK * _Nonnull)wifiSDK didChangeDeviceMesh:(NSDictionary * _Nonnull)meshDeviceInfo result:(NSError * _Nullable)result {
//  GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didChangeDeviceMesh:result:))
//  [delegate wifiSDK:wifiSDK didChangeDeviceMesh:meshDeviceInfo result:result];
//  GIZ_SDK_DELEGATE_CALLBACK_END()
//}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didBindDevice:(NSError *)result did:(NSString *)did {
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didBindDevice:did:))
    [delegate wifiSDK:wifiSDK didBindDevice:result did:did];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didUnbindDevice:(NSError *)result did:(NSString *)did {
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didUnbindDevice:did:))
    [delegate wifiSDK:wifiSDK didUnbindDevice:result did:did];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didGetCurrentCloudService:(NSError *)result cloudServiceInfo:(NSDictionary *)cloudServiceInfo {
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didGetCurrentCloudService:cloudServiceInfo:))
    [delegate wifiSDK:wifiSDK didGetCurrentCloudService:result cloudServiceInfo:cloudServiceInfo];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didChannelIDUnBind:(NSError *)result
{
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didChannelIDUnBind:))
    [delegate wifiSDK:wifiSDK didChannelIDUnBind:result];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didChannelIDBind:(NSError *)result
{
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didChannelIDBind:))
    [delegate wifiSDK:wifiSDK didChannelIDBind:result];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didRegisterBleDevice:(NSError *)result mac:(NSString *)mac productKey:(NSString *)productKey {
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didRegisterBleDevice:mac:productKey:))
    [delegate wifiSDK:wifiSDK didRegisterBleDevice:result mac:mac productKey:productKey];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDiscoverBleDevice:(NSError *)result deviceList:(NSArray<NSDictionary *> *)deviceList {
    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didDiscoverBleDevice:deviceList:))
    [delegate wifiSDK:wifiSDK didDiscoverBleDevice:result deviceList:deviceList];
    GIZ_SDK_DELEGATE_CALLBACK_END()
}

//- (void)wifiSDK:(GizWifiSDK *)wifiSDK didAddDevicesToGroup:(NSArray<GizWifiDevice *> *)successMeshDevice result:(NSError *)result{
//    GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didAddDevicesToGroup:result:))
//    [delegate wifiSDK:wifiSDK didAddDevicesToGroup:successMeshDevice result:result];
//    GIZ_SDK_DELEGATE_CALLBACK_END()
//}
//
//- (void)wifiSDK:(GizWifiSDK *)wifiSDK didReceiveDeviceLog:(NSError *)result mac:(NSString *)mac timestamp:(NSInteger)timestamp logSN:(NSInteger)logSN log:(NSString *)log{
//  GIZ_SDK_DELEGATE_CALLBACK_BEGIN(@selector(wifiSDK:didReceiveDeviceLog:mac:timestamp:logSN:log:))
//  [delegate wifiSDK:wifiSDK didReceiveDeviceLog:result mac:mac timestamp:timestamp logSN:logSN log:log];
//  GIZ_SDK_DELEGATE_CALLBACK_END()
//}

@end
