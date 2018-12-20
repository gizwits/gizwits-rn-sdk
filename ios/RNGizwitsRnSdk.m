//
//  RNGizwitsRnSdk.m
//

#import "RNGizwitsRnSdk.h"
#import <GizWifiSDK/GizWifiSDK.h>
#import "GizWifiSDKCache.h"
#import "NSObject+Giz.h"
#import "NSDictionary+Giz.h"
#import "GizWifiRnCallBackManager.h"
#import "GizWifiDef.h"

#define SDK_MODULE_VERSION      @"1.3.1"

@interface RNGizwitsRnSdk()<GizWifiSDKDelegate>
@property (nonatomic, strong) GizWifiRnCallBackManager *callBackManager;
@end

@implementation RNGizwitsRnSdk
RCT_EXPORT_MODULE();

#pragma mark - export methods
RCT_EXPORT_METHOD(startWithAppID:(id)configInfo result:(RCTResponseSenderBlock)result){
  //set call back
  [self.callBackManager addResult:result type:GizWifiRnResultTypeAppStart];
  
  NSDictionary *dict = [configInfo dictionaryObject];
  if (!dict) {
    [self.callBackManager callbackParamInvalidWityType:GizWifiRnResultTypeAppStart];
    return;
  }
  
  NSString *appid = [dict stringValueForKey:@"appID" defaultValue:@""];
  NSString *appSecret = [dict stringValueForKey:@"appSecret" defaultValue:@""];
  NSDictionary *cloudServiceInfo = [dict dictValueForKey:@"cloudServiceInfo" defaultValue:nil];
  NSArray *specialProductKeys = [dict arrayValueForKey:@"specialProductKeys" defaultValue:nil];
  NSArray *specialProductKeySecrets = [dict arrayValueForKey:@"specialProductKeySecrets" defaultValue:nil];
  BOOL autoSetDeviceDomain = [dict boolValueForKey:@"autoSetDeviceDomain" defaultValue:NO];
  
  if (specialProductKeySecrets.count > 0) {
    if (specialProductKeys.count == specialProductKeySecrets.count) {
      NSMutableArray *productInfoArray = [[NSMutableArray alloc] init];
      [specialProductKeys enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *tmpDic = @{@"productKey":obj,@"productSecret":specialProductKeySecrets[idx]};
        [productInfoArray addObject:tmpDic];
      }];
      [GizWifiSDK startWithAppInfo:@{@"appId":appid,@"appSecret":appSecret} productInfo:productInfoArray cloudServiceInfo:cloudServiceInfo autoSetDeviceDomain:autoSetDeviceDomain];
    }else{
      [self.callBackManager callbackParamInvalidWityType:GizWifiRnResultTypeAppStart];
    }
  } else{
    if (appSecret.length > 0) {
      [GizWifiSDK startWithAppID:appid appSecret:appSecret specialProductKeys:specialProductKeys cloudServiceInfo:cloudServiceInfo autoSetDeviceDomain:autoSetDeviceDomain];
    } else if (dict[@"autoSetDeviceDomain"]) {
      [GizWifiSDK startWithAppID:appid specialProductKeys:specialProductKeys cloudServiceInfo:cloudServiceInfo autoSetDeviceDomain:autoSetDeviceDomain];
    } else {
      [GizWifiSDK startWithAppID:appid specialProductKeys:specialProductKeys cloudServiceInfo:cloudServiceInfo];
    }
  }
}

RCT_EXPORT_METHOD(getBoundDevices:(id)info result:(RCTResponseSenderBlock)result){
  //set call back
  [self.callBackManager addResult:result type:GizWifiRnResultTypeGetBoundDevices];
  
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    [self.callBackManager callbackParamInvalidWityType:GizWifiRnResultTypeGetBoundDevices];
    return;
  }
  
  NSString *uid = [dict stringValueForKey:@"uid" defaultValue:nil];
  NSString *token = [dict stringValueForKey:@"token" defaultValue:nil];
  NSArray *specialProductKeys = [dict arrayValueForKey:@"specialProductKeys" defaultValue:@[]];
  
  [[GizWifiSDK sharedInstance] getBoundDevices:uid token:token specialProductKeys:specialProductKeys];
}

RCT_EXPORT_METHOD(getCurrentCloudService:(RCTResponseSenderBlock)result){
  //set call back
  [self.callBackManager addResult:result type:GizWifiRnResultTypeGetCurrentCloudService];
  [GizWifiSDK getCurrentCloudService];
}

RCT_EXPORT_METHOD(getVersion:(RCTResponseSenderBlock)result){
  //set call back
  [self.callBackManager addResult:result type:GizWifiRnResultTypeGetVersione];
  NSString *version = [NSString stringWithFormat:@"%@-%@", [GizWifiSDK getVersion], SDK_MODULE_VERSION];
  [self.callBackManager callBackWithType:GizWifiRnResultTypeGetVersione result:@[[NSNull null], version]];
}

RCT_EXPORT_METHOD(setDeviceOnboardingDeploy:(id)info result:(RCTResponseSenderBlock)result){
  //set call back
  [self.callBackManager addResult:result type:GizWifiRnResultTypeSetDeviceOnboardingDeploy];
  
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    [self.callBackManager callbackParamInvalidWityType:GizWifiRnResultTypeSetDeviceOnboardingDeploy];
    return;
  }
  
  NSString *ssid = [dict stringValueForKey:@"ssid" defaultValue:@""];
  NSString *key = [dict stringValueForKey:@"key" defaultValue:@""];
  GizWifiConfigureMode configMode = getConfigModeFromInteger([dict integerValueForKey:@"mode" defaultValue:-1]);
  NSString *softAPSSIDPrefix = [dict stringValueForKey:@"softAPSSIDPrefix" defaultValue:@""];
  NSInteger timeout = [dict integerValueForKey:@"timeout" defaultValue:0];
  BOOL isbind = [dict boolValueForKey:@"bind" defaultValue:YES];
  NSArray *gagentTypes = [dict arrayValueForKey:@"gagentTypes" defaultValue:nil];
  
  if (ssid.length == 0 || (NSInteger)configMode == -1) {
    [self.callBackManager callbackParamInvalidWityType:GizWifiRnResultTypeSetDeviceOnboardingDeploy];
  } else {
    [[GizWifiSDK sharedInstance] setDeviceOnboardingDeploy:ssid key:key configMode:configMode softAPSSIDPrefix:softAPSSIDPrefix timeout:(int)timeout wifiGAgentType:gagentTypes bind:isbind];
  }
}

RCT_EXPORT_METHOD(bindRemoteDevice:(id)info result:(RCTResponseSenderBlock)result){
  //set call back
  [self.callBackManager addResult:result type:GizWifiRnResultTypeBindRemoteDevice];
  
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    [self.callBackManager callbackParamInvalidWityType:GizWifiRnResultTypeBindRemoteDevice];
    return;
  }
  
  NSString *uid = [dict stringValueForKey:@"uid" defaultValue:@""];
  NSString *token = [dict stringValueForKey:@"token" defaultValue:@""];
  NSString *mac = [dict stringValueForKey:@"mac" defaultValue:@""];
  NSString *productKey = [dict stringValueForKey:@"productKey" defaultValue:@""];
  NSString *productSecret = [dict stringValueForKey:@"productSecret" defaultValue:@""];
  
  if (uid.length == 0 || token.length == 0 || mac.length == 0 || productKey.length == 0 ||
      productSecret.length == 0) {
    [self.callBackManager callbackParamInvalidWityType:GizWifiRnResultTypeBindRemoteDevice];
  } else {
    [[GizWifiSDK sharedInstance] bindRemoteDevice:uid token:token mac:mac productKey:productKey productSecret:productSecret];
  }
}

RCT_EXPORT_METHOD(stopDeviceOnboarding){
  [[GizWifiSDK sharedInstance] stopDeviceOnboarding];
}

RCT_EXPORT_METHOD(userFeedback:(id)info){
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    return;
  }
  
  NSString *contactInfo = [dict stringValueForKey:@"contactInfo" defaultValue:@""];
  NSString *feedbackInfo = [dict stringValueForKey:@"feedbackInfo" defaultValue:@""];
  BOOL sendLog = [dict boolValueForKey:@"sendLog" defaultValue:YES];
  
  [GizWifiSDK userFeedback:contactInfo feedbackInfo:feedbackInfo sendLog:sendLog];
}


RCT_EXPORT_METHOD(disableLan:(id)info){
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    return;
  }
  BOOL isbind = [dict boolValueForKey:@"isDisableLan" defaultValue:NO];
  [GizWifiSDK disableLAN:isbind];
}

#pragma mark - noti
- (NSArray<NSString *> *)supportedEvents{
  return @[GizDeviceListNotifications];
}

- (void)notiWithType:(GizWifiRnResultType)type result:(NSDictionary *)result{
  
  switch (type) {
    case GizWifiRnResultTypeDeviceListNoti:{
      [self sendEventWithName:GizDeviceListNotifications body:result];
    }
      break;
      
    default:
      break;
  }
}

#pragma mark - GizWifiSDKDelegate
- (void)wifiSDK:(GizWifiSDK *)wifiSDK didNotifyEvent:(GizEventType)eventType eventSource:(id)eventSource eventID:(GizWifiErrorCode)eventID eventMessage:(NSString *)eventMessage{
  //只有这些类型可以回调，其它不回调
  NSString *strEventType = nil;
  switch (eventType) {
    case GizEventSDK:
      strEventType = @"GizEventSDK";
      break;
    case GizEventDevice:
      strEventType = @"GizEventDevice";
      break;
    case GizEventM2MService:
      strEventType = @"GizEventM2MService";
      break;
    case GizEventToken:
      strEventType = @"GizEventToken";
      break;
      
    default:
      return;
  }
  
  NSDictionary *errorDict = [NSDictionary makeErrorDictFromResultCode:eventID];
  
  //noti
  if (![self.callBackManager containType:GizWifiRnResultTypeAppStart]) {
    [self notiWithType:GizWifiRnResultTypeDeviceListNoti result:@{strEventType: errorDict}];
  }
  
  if (eventID == GIZ_SDK_START_SUCCESS) {
    [self.callBackManager callBackWithType:GizWifiRnResultTypeAppStart result:@[[NSNull null], errorDict]];
  } else {
    [self.callBackManager callBackWithType:GizWifiRnResultTypeAppStart result:@[errorDict]];
  }
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDiscovered:(NSError *)result deviceList:(NSArray<GizWifiDevice *> *)deviceList{
  NSLog(@">>> %@", deviceList);
  NSDictionary *dataDict = nil;
  NSDictionary *errDict = nil;
  
  if (result.code == GIZ_SDK_SUCCESS) {
    NSMutableArray *arrDevice = [NSMutableArray array];
    for (GizWifiDevice *device in deviceList) {
      NSDictionary *dictDevice = [NSDictionary makeDictFromDeviceWithProperties:device];
      [arrDevice addObject:dictDevice];
    }
    dataDict = @{@"devices": arrDevice};
  } else {
    errDict = [NSDictionary makeErrorDictFromError:result];
  }
  
  //callback get bound devices
  [self.callBackManager callBackWithType:GizWifiRnResultTypeGetBoundDevices resultDict:dataDict errorDict:errDict];
  
  //noti
  [self notiWithType:GizWifiRnResultTypeDeviceListNoti result:errDict ? : dataDict];
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didGetCurrentCloudService:(NSError *)result cloudServiceInfo:(NSDictionary<NSString *,NSString *> *)cloudServiceInfo{
  
  NSDictionary *dataDict = nil;
  NSDictionary *errDict = nil;
  
  if (result.code == GIZ_SDK_SUCCESS) {
    dataDict = [NSMutableDictionary dictionaryWithDictionary:cloudServiceInfo];
  } else{
    errDict = [NSDictionary makeErrorDictFromError:result];
  }
  
  [self.callBackManager callBackWithType:GizWifiRnResultTypeGetCurrentCloudService resultDict:dataDict errorDict:errDict];
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didSetDeviceOnboarding:(NSError *)result mac:(NSString *)mac did:(NSString *)did productKey:(NSString *)productKey{
  NSDictionary *dataDict = nil;
  NSDictionary *errDict = nil;
  
  if (result.code == GIZ_SDK_SUCCESS) {
    NSMutableDictionary *mDevice = [NSMutableDictionary dictionary];
    [mDevice setValue:mac forKey:@"mac"];
    [mDevice setValue:did forKey:@"did"];
    [mDevice setValue:productKey forKey:@"productKey"];
    dataDict = [NSMutableDictionary dictionary];
    [dataDict setValue:mDevice forKey:@"device"];
  } else{
    errDict = [NSDictionary makeErrorDictFromError:result];
  }
  
  [self.callBackManager callBackWithType:GizWifiRnResultTypeSetDeviceOnboardingDeploy resultDict:dataDict errorDict:errDict];
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didBindDevice:(NSError *)result did:(NSString *)did{
  
  NSDictionary *dataDict = nil;
  NSDictionary *errDict = nil;
  
  if (result.code == GIZ_SDK_SUCCESS) {
    dataDict = [NSMutableDictionary dictionary];
    [dataDict setValue:did forKey:@"did"];
  } else {
    errDict = [NSDictionary makeErrorDictFromError:result];
  }
  
  [self.callBackManager callBackWithType:GizWifiRnResultTypeBindRemoteDevice resultDict:dataDict errorDict:errDict];
}

#pragma mark - lazy load
- (GizWifiRnCallBackManager *)callBackManager{
  if (_callBackManager == nil) {
    self.callBackManager = [[GizWifiRnCallBackManager alloc] init];
    //set delegate
    [GizWifiSDKCache addDelegate:self];
  }
  return _callBackManager;
}
@end

