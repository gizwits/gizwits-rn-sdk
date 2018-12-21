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
  //set call back
  [self.callBackManager addResult:result type:GizWifiRnResultTypeSetSubscribe];
  
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    [self.callBackManager callbackParamInvalidWityType:GizWifiRnResultTypeSetSubscribe];
    return;
  }
  
  NSDictionary *deviceDict = [dict dictValueForKey:@"device" defaultValue:dict];
  NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
  NSString *did = [deviceDict stringValueForKey:@"did" defaultValue:@""];
  GizWifiDevice *device = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
  NSString *productSecret = [dict stringValueForKey:@"productSecret" defaultValue:nil];
  BOOL subscribed = [dict boolValueForKey:@"subscribed" defaultValue:NO];
  
  if (device) {
    [device setSubscribe:productSecret subscribed:subscribed];
  } else {
    NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
    [self.callBackManager callBackWithType:GizWifiRnResultTypeSetSubscribe result:@[errDict]];
  }
}

//getDeviceStatus
RCT_EXPORT_METHOD(getDeviceStatus:(id)info result:(RCTResponseSenderBlock)result) {
  //set call back
  [self.callBackManager addResult:result type:GizWifiRnResultTypeGetDeviceStatus];
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    [self.callBackManager callbackParamInvalidWityType:GizWifiRnResultTypeGetDeviceStatus];
    return;
  }
  
  NSDictionary *deviceDict = [dict dictValueForKey:@"device" defaultValue:dict];
  NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
  NSString *did = [deviceDict stringValueForKey:@"did" defaultValue:@""];
  GizWifiDevice *device = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
  NSArray *attrs = [dict arrayValueForKey:@"attrs" defaultValue:nil];
  
  if (device) {
    [device getDeviceStatus:attrs];
  } else {
    NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
    [self.callBackManager callBackWithType:GizWifiRnResultTypeGetDeviceStatus result:@[errDict]];
  }
}

RCT_EXPORT_METHOD(write:(id)info result:(RCTResponseSenderBlock)result) {
  //set call back
  [self.callBackManager addResult:result type:GizWifiRnResultTypeWrite];
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    [self.callBackManager callbackParamInvalidWityType:GizWifiRnResultTypeWrite];
    return;
  }
  NSDictionary *deviceDict = [dict dictValueForKey:@"device" defaultValue:dict];
  NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
  NSString *did = [deviceDict stringValueForKey:@"did" defaultValue:@""];
  NSDictionary *data = [dict dictValueForKey:@"data" defaultValue:@{}];
  data = [data mi_replaceByteArrayWithData];
  NSInteger sn = [dict integerValueForKey:@"sn" defaultValue:-1];
  GizWifiDevice *device = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
  
  if (device) {
    if (sn != -1) {
      [device write:data withSN:(int)sn];
    } else {
      [device write:data];
    }
  } else {
    NSDictionary *errDict = [NSDictionary makeErrorDictFromResultCode:GizWifiError_DEVICE_IS_INVALID];
    [self.callBackManager callBackWithType:GizWifiRnResultTypeWrite result:@[errDict]];
  }
}

#pragma mark - noti
- (NSArray<NSString *> *)supportedEvents{
  return @[GizDeviceStatusNotifications];
}

- (void)notiWithType:(GizWifiRnResultType)type result:(NSDictionary *)result{
  
  switch (type) {
    case GizWifiRnResultTypeDeviceStatusNoti:{
      [self sendEventWithName:GizDeviceStatusNotifications body:result];
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
  NSDictionary *deviceDict = [NSDictionary makeDictFromDeviceWithProperties:device];
  if (result.code == GIZ_SDK_SUCCESS) {
    [dataDict setValue:deviceDict forKey:@"device"];
    [dataDict setValue:@(isSubscribed) forKey:@"isSubscribed"];
    
  } else {
    errDict = [NSDictionary makeErrorCodeFromError:result device:deviceDict];
  }
  [self.callBackManager callBackWithType:GizWifiRnResultTypeSetSubscribe resultDict:dataDict errorDict:errDict];
}

- (void)device:(GizWifiDevice *)device didReceiveData:(NSError *)result data:(NSDictionary *)dataMap withSN:(NSNumber *)sn {
  
  NSMutableDictionary *dataDict = nil;
  NSDictionary *errDict = nil;
  NSDictionary *deviceDict = [NSDictionary makeDictFromDeviceWithProperties:device];
  
  if (result.code == GIZ_SDK_SUCCESS) {
    [self.callBackManager callBackWithType:GizWifiRnResultTypeWrite result:@[[NSNull null], [NSDictionary makeErrorDictFromResultCode:result.code]]];
  } else {
    [self.callBackManager callBackWithType:GizWifiRnResultTypeWrite result:@[[NSDictionary makeErrorDictFromResultCode:result.code]]];
  }
  
  
  if (result.code == GIZ_SDK_SUCCESS) {
    if (!dataMap) { return; }
    NSMutableDictionary *tmpDataDict = [[dataMap dictValueForKey:@"data" defaultValue:nil] mutableCopy];
    NSDictionary *alerts = [dataMap dictValueForKey:@"alerts" defaultValue:nil];
    NSDictionary *faults = [dataMap dictValueForKey:@"faults" defaultValue:nil];
    NSData *binary = [dataMap valueForKey:@"binary"];
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
  } else {
    errDict = [NSDictionary makeErrorCodeFromError:result device:deviceDict];
  }
  
  [self.callBackManager callBackWithType:GizWifiRnResultTypeGetDeviceStatus resultDict:dataDict errorDict:errDict];
  
  // 只有通知才需要 netStatus 字段
  NSInteger netStatus = getDeviceNetStatus(device.netStatus);
  [dataDict setValue:@(netStatus) forKey:@"netStatus"];
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

@end
