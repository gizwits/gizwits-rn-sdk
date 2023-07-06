//
//  RNGizwitsRnDevice.m
//

#import "RNGizwitsRnDevice.h"

#import <GizWifiSDK/GizWifiDevice.h>
#import "NSObject+Giz.h"
#import "GizSn.h"
#import "NSDictionary+Giz.h"
#import "GizWifiRnCallBackManager.h"
#import "GizWifiDef.h"
#import "GizWifiDeviceCache.h"

#define GizWifiError_DEVICE_IS_INVALID  GIZ_SDK_DEVICE_DID_INVALID

@interface RNGizwitsRnDevice()<GizWifiDeviceDelegate>
@property (nonatomic, strong) GizWifiRnCallBackManager *callBackManager;
@end

@implementation RNGizwitsRnDevice
RCT_EXPORT_MODULE();
- (dispatch_queue_t)methodQueue{
    return dispatch_get_main_queue();
}

static id _instace;
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [super allocWithZone:zone];
    });
    return _instace;
}

#pragma mark - export methods
RCT_EXPORT_METHOD(setSubscribe:(id)info result:(RCTResponseSenderBlock)result) {
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }
    NSDictionary *deviceDict = [dict dictValueForKey:@"device" defaultValue:dict];
    NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
    NSString *did = [deviceDict stringValueForKey:@"did" defaultValue:@""];
    GizWifiDevice *device = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
    NSString *productSecret = [dict stringValueForKey:@"productSecret" defaultValue:nil];
    BOOL subscribed = [dict boolValueForKey:@"subscribed" defaultValue:NO];
    if (!device) {
        NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
        [self.callBackManager callBackError:errDict result:result];
        return;
    }
    [self.callBackManager addResult:result type:GizWifiRnResultTypeSetSubscribe identity:device.did repeatable:YES];
    [device setSubscribe:productSecret subscribed:subscribed];
}

RCT_EXPORT_METHOD(setSubscribeNotGetDeviceStatus:(id)info result:(RCTResponseSenderBlock)result) {
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }
    NSDictionary *deviceDict = [dict dictValueForKey:@"device" defaultValue:dict];
    NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
    NSString *did = [deviceDict stringValueForKey:@"did" defaultValue:@""];
    GizWifiDevice *device = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
    BOOL subscribed = [dict boolValueForKey:@"subscribed" defaultValue:NO];
    if (!device) {
        NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
        [self.callBackManager callBackError:errDict result:result];
        return;
    }
    [self.callBackManager addResult:result type:GizWifiRnResultTypeSetSubscribe identity:device.did repeatable:YES];
    [device setSubscribe:subscribed autoGetDeviceStatus:FALSE];
}

//getDeviceStatus
RCT_EXPORT_METHOD(getDeviceStatus:(id)info result:(RCTResponseSenderBlock)result) {
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }
    NSDictionary *deviceDict = [dict dictValueForKey:@"device" defaultValue:dict];
    NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
    NSString *productKey = [deviceDict stringValueForKey:@"productKey" defaultValue:@""];
    GizWifiDevice *device = [GizWifiDeviceCache cachedBleDeviceWithMacAddress:mac productKey:productKey];
    if (!device || device.netStatus != GizDeviceControlled) { // 若存在可控的蓝牙设备，选择蓝牙控制
        NSString *did = [deviceDict stringValueForKey:@"did" defaultValue:@""];
        device = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
        if (!device) {
            NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
            [self.callBackManager callBackError:errDict result:result];
            return;
        }
    }
    NSArray *attrs = [dict arrayValueForKey:@"attrs" defaultValue:nil];
    NSInteger sn = [GizSn getSn];
    [self.callBackManager addResult:result type:GizWifiRnResultTypeGetDeviceStatus identity:[NSString stringWithFormat:@"%@+%ld", device.did, sn] repeatable:YES];
    [device getDeviceStatus:attrs withSN:(int)sn];
}

RCT_EXPORT_METHOD(deleteMeshDeviceFromGroup:(id)info result:(RCTResponseSenderBlock)result) {
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }
    NSDictionary *deviceDict = [dict dictValueForKey:@"device" defaultValue:dict];
    NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
    NSInteger *groupID = [dict integerValueForKey:@"groupID" defaultValue:0];
    NSString *productKey = [deviceDict stringValueForKey:@"productKey" defaultValue:@""];
    NSArray *macs = [dict arrayValueForKey:@"macs" defaultValue:nil];
    GizWifiBleDevice *device = [GizWifiDeviceCache cachedBleDeviceWithMacAddress:mac productKey:productKey];
    
    // 找不到蓝牙设备
    if (!device || device.netStatus != GizDeviceControlled) {
        NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
        [self.callBackManager callBackError:errDict result:result];
        return;
    }
    [device deleteMeshDeviceFromGroup:macs groupID:groupID callback:^(GizWifiErrorCode errorCode) {
        if (errorCode == GIZ_SDK_SUCCESS) {
            result([self.callBackManager getEmptySuccessResult]);
        } else {
            NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:errorCode];
            [self.callBackManager callBackError:errDict result:result];
        }
    }];
}
RCT_EXPORT_METHOD(addMeshDeviceToGroup:(id)info result:(RCTResponseSenderBlock)result) {
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }
    NSDictionary *deviceDict = [dict dictValueForKey:@"device" defaultValue:dict];
    NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
    NSInteger *groupID = [dict integerValueForKey:@"groupID" defaultValue:0];
    NSString *productKey = [deviceDict stringValueForKey:@"productKey" defaultValue:@""];
    NSArray *macs = [dict arrayValueForKey:@"macs" defaultValue:nil];
    GizWifiBleDevice *device = [GizWifiDeviceCache cachedBleDeviceWithMacAddress:mac productKey:productKey];
    
    // 找不到蓝牙设备
    if (!device || device.netStatus != GizDeviceControlled) {
        NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
        [self.callBackManager callBackError:errDict result:result];
        return;
    }
    [device addMeshDeviceToGroup:macs withGroup:groupID callback:^(GizWifiErrorCode errorCode) {
        if (errorCode == GIZ_SDK_SUCCESS) {
            result([self.callBackManager getEmptySuccessResult]);
        } else {
            NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:errorCode];
            [self.callBackManager callBackError:errDict result:result];
        }
    }];
}

RCT_EXPORT_METHOD(write:(id)info result:(RCTResponseSenderBlock)result) {
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }
    NSDictionary *deviceDict = [dict dictValueForKey:@"device" defaultValue:dict];
    NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
    NSString *productKey = [deviceDict stringValueForKey:@"productKey" defaultValue:@""];
    NSDictionary *data = [dict dictValueForKey:@"data" defaultValue:@{}];
    data = [data mi_replaceByteArrayWithData];
    NSInteger sn = [dict integerValueForKey:@"sn" defaultValue:-1];
    GizWifiDevice *device = [GizWifiDeviceCache cachedBleDeviceWithMacAddress:mac productKey:productKey];
    if (!device || device.netStatus != GizDeviceControlled) { // 若存在可控的蓝牙设备，选择蓝牙控制
        NSString *did = [deviceDict stringValueForKey:@"did" defaultValue:@""];
        device = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
        if (!device) {
            NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
            [self.callBackManager callBackError:errDict result:result];
            return;
        }
    }
    [self.callBackManager addResult:result type:GizWifiRnResultTypeWrite identity:[NSString stringWithFormat:@"%@+%ld", device.did, sn] repeatable:YES];
    if (sn != -1) {
        [device write:data withSN:(int)sn];
    } else {
        [device write:data];
    }
}

RCT_EXPORT_METHOD(connectBle:(id)info result:(RCTResponseSenderBlock)result) {
    [self connectOrDisconnectToBle:YES info:info result:result];
}

RCT_EXPORT_METHOD(disconnectBle:(id)info result:(RCTResponseSenderBlock)result) {
    [self connectOrDisconnectToBle:NO info:info result:result];
}

- (void)connectOrDisconnectToBle:(BOOL)isConnect info:(id)info result:(RCTResponseSenderBlock)result {
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }
    NSDictionary *deviceDict = [dict dictValueForKey:@"device" defaultValue:dict];
    NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
    NSString *productKey = [deviceDict stringValueForKey:@"productKey" defaultValue:@""];

    __block GizWifiBleDevice *device = (GizWifiBleDevice *)[GizWifiDeviceCache cachedBleDeviceWithMacAddress:mac productKey:productKey];
    if (!device) {
        NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
        [self.callBackManager callBackError:errDict result:result];
        return;
    }

    NSInteger sn = [GizSn getSn];
    NSString *snString = [NSString stringWithFormat:@"%ld", (long)sn];
    NSString *identity = [device.did stringByAppendingString:snString];
    if (isConnect) {
        [self.callBackManager addResult:result type:GizWifiRnResultTypeConnectBle identity:identity repeatable:YES];
        [device connectBle:^(GizWifiErrorCode errorCode) {
            [self connectOrDisconnectCallback:YES errorCode:errorCode device:device sn: sn];
        }];
    } else {
        [self.callBackManager addResult:result type:GizWifiRnResultTypeDisconnectBle identity:identity repeatable:YES];
        [device disconnectBle:^(GizWifiErrorCode errorCode) {
            [self connectOrDisconnectCallback:NO errorCode:errorCode device:device sn: sn];
        }];
    }
}

- (void)connectOrDisconnectCallback:(BOOL)isConnect errorCode:(GizWifiErrorCode)errorCode device:(GizWifiDevice *)device sn:(NSInteger)sn {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    NSDictionary *errDict = nil;
    NSDictionary *deviceDict = [NSDictionary makeDictFromLiteDeviceWithProperties:device];
    if (errorCode == GIZ_SDK_SUCCESS) {
        [dataDict setValue:deviceDict forKey:@"device"];
    } else {
        errDict = [NSDictionary makeErrorDictFromResultCode:errorCode device:deviceDict];
    }
    NSString *snString = [NSString stringWithFormat:@"%ld", (long)sn];
    NSString *identity = [device.did stringByAppendingString:snString];
    if (isConnect) {
        [self.callBackManager callBackWithType:GizWifiRnResultTypeConnectBle identity:identity resultDict:dataDict errorDict:errDict];
    } else {
        [self.callBackManager callBackWithType:GizWifiRnResultTypeDisconnectBle identity:identity resultDict:dataDict errorDict:errDict];
    }
}

RCT_EXPORT_METHOD(checkUpdate:(id)info result:(RCTResponseSenderBlock)result) {
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }
    NSDictionary *deviceDict = [dict dictValueForKey:@"device" defaultValue:dict];
    NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
    NSString *productKey = [deviceDict stringValueForKey:@"productKey" defaultValue:@""];

    __block GizWifiBleDevice *device = (GizWifiBleDevice *)[GizWifiDeviceCache cachedBleDeviceWithMacAddress:mac productKey:productKey];
    if (!device) {
        NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
        [self.callBackManager callBackError:errDict result:result];
        return;
    }
    NSInteger type = [dict integerValueForKey:@"type" defaultValue:0];
    GizOTAFirmwareType enumType = getOTAFirmareTypeFromInteger(type);
    [self.callBackManager addResult:result type:GizWifiRnResultTypeCheckUpdate identity:device.did repeatable:YES];
    [device checkUpdate:enumType completion:^(NSError * _Nonnull result, NSString * _Nonnull lastVersion, NSString * _Nonnull currentVersion) {
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
        NSDictionary *errDict = nil;
        NSDictionary *deviceDict = [NSDictionary makeDictFromLiteDeviceWithProperties:device];
        [dataDict setValue:deviceDict forKey:@"device"];
        [dataDict setValue:lastVersion forKey:@"lastVersion"];
        [dataDict setValue:currentVersion forKey:@"currentVersion"];
        if (result.code != GIZ_SDK_SUCCESS) {
            errDict = [NSDictionary makeErrorDictFromResultCode:result.code device:deviceDict];
        }
        [self.callBackManager callBackWithType:GizWifiRnResultTypeCheckUpdate identity:device.did resultDict:dataDict errorDict:errDict];
    }];
}

RCT_EXPORT_METHOD(startUpgrade:(id)info result:(RCTResponseSenderBlock)result) {
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }
    NSDictionary *deviceDict = [dict dictValueForKey:@"device" defaultValue:dict];
    NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
    NSString *productKey = [deviceDict stringValueForKey:@"productKey" defaultValue:@""];

    __block GizWifiBleDevice *device = (GizWifiBleDevice *)[GizWifiDeviceCache cachedBleDeviceWithMacAddress:mac productKey:productKey];
    if (!device) {
        NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
        [self.callBackManager callBackError:errDict result:result];
        return;
    }
    NSInteger type = [dict integerValueForKey:@"type" defaultValue:0];
    GizOTAFirmwareType enumType = getOTAFirmareTypeFromInteger(type);
    [device startUpgrade:enumType listener:^(GizOTAEventType type, NSError * _Nonnull result) {
        NSString* typeString = getOTAEventTypeFromEnum(type);
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
        NSDictionary *deviceDict = [NSDictionary makeDictFromLiteDeviceWithProperties:device];
        [dataDict setValue:deviceDict forKey:@"device"];
        [dataDict setValue:@(result.code) forKey:@"errorCode"];
        [dataDict setValue:typeString forKey:@"type"];
        [self notiWithType:GizWifiRnResultTypeOTAStatusNoti result:dataDict];
    } progressListener:^(NSInteger firmwareSize, NSInteger packageMaxLen, int currentNumber){
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
        
        [dataDict setValue:@(firmwareSize) forKey:@"firmwareSize"];
        [dataDict setValue:@(packageMaxLen) forKey:@"packageMaxLen"];
        [dataDict setValue:@(currentNumber) forKey:@"currentNumber"];
        [self notiWithType:GizWifiRnResultTypeOTAProgressNoti result:dataDict];
    }];
}


#pragma mark - noti
- (NSArray<NSString *> *)supportedEvents{
    return @[GizDeviceStatusNotifications,GizDeviceAppToDevNotifications,GizDeviceBleOTAStatus, GizDeviceBleOTAProgress];
}

- (void)notiWithType:(GizWifiRnResultType)type result:(NSDictionary *)result{
    switch (type) {
        case GizWifiRnResultTypeDeviceStatusNoti:{
            [self sendEventWithName:GizDeviceStatusNotifications body:result];
            break;
        }
        case GizWifiRnResultTypeAppToDevNoti:{
            [self sendEventWithName:GizDeviceAppToDevNotifications body:result];
            break;
        }
        case GizWifiRnResultTypeOTAStatusNoti: {
            [self sendEventWithName:GizDeviceBleOTAStatus body:result];
            break;
        }
        case GizWifiRnResultTypeOTAProgressNoti: {
            [self sendEventWithName:GizDeviceBleOTAProgress body:result];
            break;
        }
        default:
            break;
    }
}

#pragma mark - GizWifiDeviceDelegate
- (void)device:(GizWifiDevice *)device didSetSubscribe:(NSError *)result isSubscribed:(BOOL)isSubscribed {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    NSDictionary *errDict = nil;
    NSDictionary *deviceDict = [NSDictionary makeDictFromLiteDeviceWithProperties:device];
    if (result.code == GIZ_SDK_SUCCESS) {
        [dataDict setValue:deviceDict forKey:@"device"];
        [dataDict setValue:@(isSubscribed) forKey:@"isSubscribed"];
    } else {
        errDict = [NSDictionary makeErrorCodeFromError:result device:deviceDict];
    }
    [self.callBackManager callBackWithType:GizWifiRnResultTypeSetSubscribe identity:device.did resultDict:dataDict errorDict:errDict];
}

- (void)device:(GizWifiDevice * _Nonnull)device didReceiveAppToDevAttrStatus:(NSError * _Nonnull)result attrStatus:(NSDictionary * _Nullable)attrStatus adapterAttrStatus:(NSDictionary * _Nullable)adapterAttrStatus withSN:(NSNumber * _Nullable)sn{
    NSMutableDictionary *dataDict = nil;
    NSDictionary *errDict = nil;
    NSDictionary *deviceDict = [NSDictionary makeDictFromLiteDeviceWithProperties:device];
    if (result.code == GIZ_SDK_SUCCESS) {
        dataDict = [self dataFromDevice:deviceDict attrStatus:attrStatus withSN:sn];
        if (!dataDict) { return; }
    } else {
        errDict = [NSDictionary makeErrorCodeFromError:result device:deviceDict];
    }
    [self notiWithType:GizWifiRnResultTypeAppToDevNoti result:errDict ? : dataDict];
}

- (void)device:(GizWifiDevice *)device didUpdateNetStatus:(GizWifiDeviceNetStatus)netStatus{
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    
    NSDictionary *deviceDict = [NSDictionary makeDictFromLiteDeviceWithProperties:device];
    [dataDict setValue:deviceDict forKey:@"device"];
    [dataDict setValue:@(netStatus) forKey:@"netStatus"];
    if ([device isMemberOfClass:[GizWifiBleDevice class]]) {
        GizWifiBleDevice *bleDevice = (GizWifiBleDevice *)device;
        // 子设备其他属性
        [dataDict setValue:@(bleDevice.isBlueLocal) forKey:@"isBlueLocal"];
    }
    
    [self notiWithType:GizWifiRnResultTypeDeviceStatusNoti result:dataDict];
}

- (void)device:(GizWifiDevice *)device didReceiveData:(NSError *)result data:(NSDictionary *)dataMap withSN:(NSNumber *)sn {
    if (result.code == GIZ_SDK_SUCCESS) {
        [self.callBackManager callBackWithType:GizWifiRnResultTypeWrite identity:[NSString stringWithFormat:@"%@+%ld", device.did, [sn integerValue]] resultDict:@[[NSNull null], [NSDictionary makeErrorDictFromResultCode:result.code]]];
    } else {
        [self.callBackManager callBackWithType:GizWifiRnResultTypeWrite identity:[NSString stringWithFormat:@"%@+%ld", device.did, [sn integerValue]] resultDict:@[[NSDictionary makeErrorDictFromResultCode:result.code]]];
    }

    NSMutableDictionary *dataDict = nil;
    NSDictionary *errDict = nil;
    NSDictionary *deviceDict = [NSDictionary makeDictFromLiteDeviceWithProperties:device];
    if (result.code == GIZ_SDK_SUCCESS) {
        dataDict = [self dataFromDevice:deviceDict attrStatus:dataMap withSN:sn];
        if (!dataDict) { return; }
    } else {
        errDict = [NSDictionary makeErrorCodeFromError:result device:deviceDict];
    }
    [self.callBackManager callBackWithType:GizWifiRnResultTypeGetDeviceStatus identity:[NSString stringWithFormat:@"%@+%ld", device.did, [sn integerValue]] resultDict:dataDict errorDict:errDict];

    // 只有通知才需要 netStatus 字段
    NSInteger netStatus = getDeviceNetStatus(device.netStatus);
    [dataDict setValue:@(netStatus) forKey:@"netStatus"];
    if ([device isMemberOfClass:[GizWifiBleDevice class]]) {
        GizWifiBleDevice *bleDevice = (GizWifiBleDevice *)device;
        // 子设备其他属性
        [dataDict setValue:@(bleDevice.isBlueLocal) forKey:@"isBlueLocal"];
    }
    [self notiWithType:GizWifiRnResultTypeDeviceStatusNoti result:errDict ? : dataDict];
}

#pragma mark - lazy load
- (GizWifiRnCallBackManager *)callBackManager{
    if (_callBackManager == nil) {
        self.callBackManager = [[GizWifiRnCallBackManager alloc] init];
        [GizWifiDeviceCache addDelegate:self];
    }
    return _callBackManager;
}

#pragma mark - private
-(NSMutableDictionary*)dataFromDevice:(NSDictionary*)deviceDict attrStatus:(NSDictionary*)attrStatus withSN:(NSNumber * _Nullable)sn{
    NSMutableDictionary *dataDict = nil;
    if (attrStatus) {
        NSMutableDictionary *tmpDataDict = [[attrStatus dictValueForKey:@"data" defaultValue:nil] mutableCopy];
        NSDictionary *alerts = [attrStatus dictValueForKey:@"alerts" defaultValue:nil];
        NSDictionary *faults = [attrStatus dictValueForKey:@"faults" defaultValue:nil];
        NSData *binary = [attrStatus valueForKey:@"binary"];
        NSArray *binaryArr = nil;
        if (binary) {
            binaryArr = [tmpDataDict byteArrayForData:binary];
        }

        // 转换tmpDataDict的二进制
        for (NSString *key in tmpDataDict.allKeys) {
            id value = tmpDataDict[key];
            if ([value isKindOfClass:[NSData class]]) {
                NSArray* arr = [tmpDataDict byteArrayForData: value];
                [tmpDataDict setValue:arr forKey:key];
            }
        }

        dataDict = [NSMutableDictionary dictionary];
        [dataDict setValue:deviceDict forKey:@"device"];
        [dataDict setValue:sn forKey:@"sn"];
        [dataDict setValue:tmpDataDict forKey:@"data"];
        [dataDict setValue:alerts forKey:@"alerts"];
        [dataDict setValue:faults forKey:@"faults"];
        [dataDict setValue:binaryArr forKey:@"binary"];

        NSMutableDictionary *statusDict = [NSMutableDictionary dictionary];
        NSMutableArray *alertsArray = [NSMutableArray array];
        NSMutableArray *faultsArray = [NSMutableArray array];
        for (NSString *key in alerts.allKeys) {
            [alertsArray addObject:@{key: alerts[key]}];
        }
        for (NSString *key in faults.allKeys) {
            [faultsArray addObject:@{key: faults[key]}];
        }
        [statusDict setValue:@{@"cmd": @4, @"entity0": tmpDataDict, @"version": @4} forKey:@"data"];
        [statusDict setValue:alertsArray forKey:@"alerts"];
        [statusDict setValue:faultsArray forKey:@"faults"];
        [statusDict setValue:binaryArr forKey:@"binary"];

        [dataDict setValue:statusDict forKey:@"status"];
    }
    return dataDict;
}

@end
