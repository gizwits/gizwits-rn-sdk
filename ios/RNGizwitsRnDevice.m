//
//  RNGizwitsRnDevice.m
//

#import "RNGizwitsRnDevice.h"

#import <GizWifiSDK/GizWifiDevice.h>
#import "NSObject+Giz.h"
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
  BOOL subscribed = [dict boolValueForKey:@"subscribed" defaultValue:NO];
  BOOL autoGetDeviceStatus = [dict boolValueForKey:@"autoGetDeviceStatus" defaultValue:NO];
  if (!device) {
    NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
    [self.callBackManager callBackError:errDict result:result];
    return;
  }
  [self.callBackManager addResult:result type:GizWifiRnResultTypeSetSubscribe identity:device.did repeatable:YES];
  [device setSubscribe:subscribed autoGetDeviceStatus:autoGetDeviceStatus];
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
  NSString *did = [deviceDict stringValueForKey:@"did" defaultValue:@""];
  GizWifiDevice *device = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
  NSArray *attrs = [dict arrayValueForKey:@"attrs" defaultValue:nil];
  if (!device) {
    NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
    [self.callBackManager callBackError:errDict result:result];
    return;
  }
  [self.callBackManager addResult:result type:GizWifiRnResultTypeGetDeviceStatus identity:device.did repeatable:YES];
  [device getDeviceStatus:attrs];
}

RCT_EXPORT_METHOD(write:(id)info result:(RCTResponseSenderBlock)result) {
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    [self.callBackManager callbackParamInvalid:result];
    return;
  }
  NSDictionary *deviceDict = [dict dictValueForKey:@"device" defaultValue:dict];
  NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
  NSString *did = [deviceDict stringValueForKey:@"did" defaultValue:@""];
  NSDictionary *data = [dict dictValueForKey:@"data" defaultValue:@{}];
  data = [data mi_replaceByteArrayWithData];
  NSInteger sn = [dict integerValueForKey:@"sn" defaultValue:0];
  GizWifiDevice *device = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
  if (!device) {
    NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
    [self.callBackManager callBackError:errDict result:result];
    return;
  }
  [self.callBackManager addResult:result type:GizWifiRnResultTypeWrite identity:[NSString stringWithFormat:@"%@+%ld", device.did, sn] repeatable:YES];
    [device write:data withSN:(int)sn];
}

RCT_EXPORT_METHOD(getHardwareInfo:(id)info result:(RCTResponseSenderBlock)result) {
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
      [self.callBackManager callbackParamInvalid:result];
      return;
    }
    NSDictionary *deviceDict = [dict dictValueForKey:@"device" defaultValue:dict];
    NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
    NSString *did = [deviceDict stringValueForKey:@"did" defaultValue:@""];
    GizWifiDevice *device = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
    if (!device) {
      NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
      [self.callBackManager callBackError:errDict result:result];
      return;
    }
    [self.callBackManager addResult:result type:GizWifiRnResultTypeGetHardwareInfo identity:device.did repeatable:YES];
    [device getHardwareInfo];
}

RCT_EXPORT_METHOD(setCustomInfo:(id)info result:(RCTResponseSenderBlock)result) {
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
      [self.callBackManager callbackParamInvalid:result];
      return;
    }
    NSDictionary *deviceDict = [dict dictValueForKey:@"device" defaultValue:dict];
    NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
    NSString *did = [deviceDict stringValueForKey:@"did" defaultValue:@""];
    NSString *remark = [dict stringValueForKey:@"remark" defaultValue:@""];
    NSString *alias = [dict stringValueForKey:@"alias" defaultValue:@""];
    GizWifiDevice *device = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
    if (!device) {
      NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
      [self.callBackManager callBackError:errDict result:result];
      return;
    }
    [self.callBackManager addResult:result type:GizWifiRnResultTypeSetCustomInfo identity:device.did repeatable:YES];
    [device setCustomInfo:remark alias:alias];
}

#pragma mark - noti
- (NSArray<NSString *> *)supportedEvents{
  return @[GizDeviceStatusNotifications,GizDeviceAppToDevNotifications];
}

- (void)notiWithType:(GizWifiRnResultType)type result:(NSDictionary *)result{
  switch (type) {
    case GizWifiRnResultTypeDeviceStatusNoti:{
      [self sendEventWithName:GizDeviceStatusNotifications body:result];
    }
      break;
    case GizWifiRnResultTypeAppToDevNoti:{
      [self sendEventWithName:GizDeviceAppToDevNotifications body:result];
    }
      break;
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
  [self.callBackManager callBackWithType:GizWifiRnResultTypeGetDeviceStatus identity:device.did resultDict:dataDict errorDict:errDict];
  
  // 只有通知才需要 netStatus 字段
  NSInteger netStatus = getDeviceNetStatus(device.netStatus);
  [dataDict setValue:@(netStatus) forKey:@"netStatus"];
  [self notiWithType:GizWifiRnResultTypeDeviceStatusNoti result:errDict ? : dataDict];
}

- (void)device:(GizWifiDevice * _Nonnull)device didGetHardwareInfo:(GizError * _Nonnull)result hardwareInfo:(NSDictionary <NSString *, NSString *>* _Nullable)hardwareInfo {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    NSDictionary *errDict = nil;
    NSDictionary *deviceDict = [NSDictionary makeDictFromLiteDeviceWithProperties:device];
    if (result.code == GIZ_SDK_SUCCESS) {
      [dataDict setValue:deviceDict forKey:@"device"];
      [dataDict setValue:hardwareInfo forKey:@"hardwareInfo"];
    } else {
      errDict = [NSDictionary makeErrorCodeFromError:result device:deviceDict];
    }
    [self.callBackManager callBackWithType:GizWifiRnResultTypeGetHardwareInfo identity:device.did resultDict:dataDict errorDict:errDict];
}

- (void)device:(GizWifiDevice * _Nonnull)device didSetCustomInfo:(GizError * _Nonnull)result {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    NSDictionary *errDict = nil;
    NSDictionary *deviceDict = [NSDictionary makeDictFromLiteDeviceWithProperties:device];
    if (result.code == GIZ_SDK_SUCCESS) {
      [dataDict setValue:deviceDict forKey:@"device"];
    } else {
      errDict = [NSDictionary makeErrorCodeFromError:result device:deviceDict];
    }
    [self.callBackManager callBackWithType:GizWifiRnResultTypeSetCustomInfo identity:device.did resultDict:dataDict errorDict:errDict];
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
