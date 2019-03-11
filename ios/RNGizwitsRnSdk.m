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
#import "GizWifiDeviceCache.h"

#define SDK_MODULE_VERSION      @"1.3.1"

@interface RNGizwitsRnSdk()<GizWifiSDKDelegate>
@property (nonatomic, strong) GizWifiRnCallBackManager *callBackManager;
@end

@implementation RNGizwitsRnSdk
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
RCT_EXPORT_METHOD(startWithAppID:(id)configInfo result:(RCTResponseSenderBlock)result){
  NSDictionary *dict = [configInfo dictionaryObject];
  if (!dict) {
    [self.callBackManager callbackParamInvalid:result];
    return;
  }
  
  [self.callBackManager addResult:result type:GizWifiRnResultTypeAppStart identity:nil repeatable:NO];
  
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
      [self.callBackManager callbackParamInvalid:result];
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
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    [self.callBackManager callbackParamInvalid:result];
    return;
  }
  
  [self.callBackManager addResult:result type:GizWifiRnResultTypeGetBoundDevices identity:nil repeatable:YES];
  
  NSString *uid = [dict stringValueForKey:@"uid" defaultValue:nil];
  NSString *token = [dict stringValueForKey:@"token" defaultValue:nil];
  NSArray *specialProductKeys = [dict arrayValueForKey:@"specialProductKeys" defaultValue:@[]];
  
  [[GizWifiSDK sharedInstance] getBoundDevices:uid token:token specialProductKeys:specialProductKeys];
}

RCT_EXPORT_METHOD(getCurrentCloudService:(RCTResponseSenderBlock)result){
  [self.callBackManager addResult:result type:GizWifiRnResultTypeGetCurrentCloudService identity:nil repeatable:NO];
  [GizWifiSDK getCurrentCloudService];
}

RCT_EXPORT_METHOD(getVersion:(RCTResponseSenderBlock)result){
  NSString *version = [NSString stringWithFormat:@"%@-%@", [GizWifiSDK getVersion], SDK_MODULE_VERSION];
  if (result) {
    result(@[[NSNull null], version]);
  }
}

RCT_EXPORT_METHOD(setDeviceOnboardingDeploy:(id)info result:(RCTResponseSenderBlock)result){
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    [self.callBackManager callbackParamInvalid:result];
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
    [self.callBackManager callbackParamInvalid:result];
    return;
  }
  
  [self.callBackManager addResult:result type:GizWifiRnResultTypeSetDeviceOnboardingDeploy identity:nil repeatable:YES];
  [[GizWifiSDK sharedInstance] setDeviceOnboardingDeploy:ssid key:key configMode:configMode softAPSSIDPrefix:softAPSSIDPrefix timeout:(int)timeout wifiGAgentType:gagentTypes bind:isbind];
}

RCT_EXPORT_METHOD(bindRemoteDevice:(id)info result:(RCTResponseSenderBlock)result){
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    [self.callBackManager callbackParamInvalid:result];
    return;
  }
  
  NSString *uid = [dict stringValueForKey:@"uid" defaultValue:@""];
  NSString *token = [dict stringValueForKey:@"token" defaultValue:@""];
  NSString *mac = [dict stringValueForKey:@"mac" defaultValue:@""];
  NSString *productKey = [dict stringValueForKey:@"productKey" defaultValue:@""];
  NSString *productSecret = [dict stringValueForKey:@"productSecret" defaultValue:@""];
  
  if (uid.length == 0 || token.length == 0 || mac.length == 0 || productKey.length == 0 ||
      productSecret.length == 0) {
    [self.callBackManager callbackParamInvalid:result];
    return;
  }
  [self.callBackManager addResult:result type:GizWifiRnResultTypeBindRemoteDevice identity:nil repeatable:YES];
  [[GizWifiSDK sharedInstance] bindRemoteDevice:uid token:token mac:mac productKey:productKey productSecret:productSecret];
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

- (NSMutableData *)convertHexStrToData:(NSString *)str {
  if (!str || [str length] == 0) {
    return nil;
  }
  NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
  NSRange range;
  if ([str length] %2 == 0) {
    range = NSMakeRange(0,2);
  } else {
    range = NSMakeRange(0,1);
  }
  for (NSInteger i = range.location; i < [str length]; i += 2) {
    unsigned int anInt;
    NSString *hexCharStr = [str substringWithRange:range];
    NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
    [scanner scanHexInt:&anInt];
    NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
    [hexData appendData:entity];
    range.location += range.length;
    range.length = 2;
  }
  return hexData;
}

RCT_EXPORT_METHOD(setUserMeseName:(id)info result:(RCTResponseSenderBlock)result){
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    return;
  }
  NSString *meshName = [dict stringValueForKey:@"meshName" defaultValue:@""];
  NSString *password = [dict stringValueForKey:@"password" defaultValue:@""];
  NSDictionary *uuidInfo = [dict objectForKey:@"uuidInfo"];
  NSString *meshLTK = [dict stringValueForKey:@"meshLTK" defaultValue:@""];
  GizMeshVerdor meshVerdor = getMeshVerdorFromInteger([dict integerValueForKey:@"meshVerdor" defaultValue:-1]);
  if(meshName==nil||password==nil||uuidInfo==nil||[meshLTK isEqualToString:@""])
  {
    [self.callBackManager callbackParamInvalid:result];
  }else{
    NSData *testData = [self convertHexStrToData:meshLTK];
    [GizWifiSDK setUserMeshName:meshName password:password uuidInfo:uuidInfo meshLTK:testData meshVendor:(GizMeshVerdor)meshVerdor];
    if (result) {
      result(@[[NSNull null]]);
    }
  }
}

RCT_EXPORT_METHOD(deviceSafetyRegister:(id)info result:(RCTResponseSenderBlock)result){
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    return;
  }
  NSString *gateWayMac = [dict stringValueForKey:@"gatewayMac" defaultValue:@""];
  NSString *gateWayDid = [dict stringValueForKey:@"gatewayDid" defaultValue:@""];
  NSString *pk = [dict stringValueForKey:@"productKey" defaultValue:@""];
  NSArray *devicesInfo=[dict arrayValueForKey:@"devicesInfo" defaultValue:@[]];
  
  GizWifiDevice *giz = [GizWifiDeviceCache cachedDeviceWithMacAddress:gateWayMac did:gateWayDid];
  //    GizSDKPrintCbId("cbId", _cbDeviceSafeRegister);
  if (pk.length == 0) {
    [self.callBackManager callbackParamInvalid:result];
  } else {
    [GizWifiSDK deviceSafetyRegister:giz productKey:pk devicesInfo:devicesInfo];
    [self.callBackManager addResult:result type:GizWifiRnResultTypeDeviceSafetyRegister identity:nil repeatable:NO];
  }
}

RCT_EXPORT_METHOD(deviceSafetyUnbind:(id)info result:(RCTResponseSenderBlock)result){
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    return;
  }
  NSArray *devicesInfo=[dict arrayValueForKey:@"devicesInfo" defaultValue:@[]];
  NSMutableArray *devices=[NSMutableArray array];
  for (NSInteger i=0; i<devicesInfo.count; i++) {
    NSString *mac = [devicesInfo[i] stringValueForKey:@"mac" defaultValue:@""];
    NSString *did = [devicesInfo[i] stringValueForKey:@"did" defaultValue:@""];
    GizWifiDevice *giz = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
    NSDictionary *device=@{@"device":giz,@"authCode":[devicesInfo[i] stringValueForKey:@"authCode" defaultValue:@""]};
    [devices addObject:device];
  }
  [GizWifiSDK deviceSafetyUnbind:devices];
  [self.callBackManager addResult:result type:GizWifiRnResultTypeDeviceSafetyUnbind identity:nil repeatable:NO];
}

RCT_EXPORT_METHOD(searchMeshDevice:(id)info result:(RCTResponseSenderBlock)result){
  NSDictionary *dict = [info dictionaryObject];
  if (!dict) {
    return;
  }
  NSString *meshName = [dict stringValueForKey:@"meshName" defaultValue:@""];
  if (meshName.length == 0 ) {
    [self.callBackManager callbackParamInvalid:result];
  } else {
    [GizWifiSDK searchMeshDevice:meshName];
    if (result) {
      result(@[[NSNull null]]);
    }
  }
}

RCT_EXPORT_METHOD(addGroup:(id)info result:(RCTResponseSenderBlock)result){
  NSDictionary *dict = [info dictionaryObject];
  NSUInteger *groupID = [dict integerValueForKey:@"groupID" defaultValue:1];
  NSArray *meshDevices = [dict arrayValueForKey:@"meshDevices" defaultValue: nil];
  NSMutableArray *devices=[NSMutableArray array];
  for (NSDictionary *meshDevice in meshDevices) {
    NSString *mac = [meshDevice stringValueForKey:@"mac" defaultValue:@""];
    NSString *did = [meshDevice stringValueForKey:@"did" defaultValue:@""];
    GizWifiDevice *giz = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
    [devices addObject:giz];
  }
  [GizWifiSDK addGroup:groupID meshDevices:devices];
  [self.callBackManager addResult:result type:GizWifiRnResultTypeaAddMeshGroup identity:nil repeatable:YES];
}

/**
 @param type 0 client 1 deamon
 */

RCT_EXPORT_METHOD(getLog:(id)info result:(RCTResponseSenderBlock)result){
  
  NSDictionary *dict = [info dictionaryObject];
  
  NSInteger *type = [dict integerValueForKey:@"type" defaultValue:0];
  NSString *address = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/GizWifiSDK"];
  NSString *clientAddress = [NSString stringWithFormat:@"%@%@", address, @"/GizSDKLog/Client/GizSDKClientLogFile.sys" ];
  NSString *deamonAddress = [NSString stringWithFormat:@"%@%@", address, @"/GizSDKLog/Daemon/GizSDKLogFile.sys" ];
  
  NSString *logAddress = @"";
  if (type == 0) {
    // 获取client日志
    logAddress =clientAddress;
  } else {
    logAddress =deamonAddress;
  }
  
  NSString *str=[NSString stringWithContentsOfFile:logAddress encoding:NSASCIIStringEncoding error:nil];
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  [data setValue:str forKey:@"log"];
  
  result(@[[NSNull null], data]);
}


RCT_EXPORT_METHOD(changeDeviceMesh:(id)info result:(RCTResponseSenderBlock)result){
  NSDictionary *dict = [info dictionaryObject];
  NSDictionary *meshDeviceInfo = [dict dictValueForKey:@"meshDeviceInfo" defaultValue: nil];
  NSDictionary *currentMesh = [dict dictValueForKey:@"currentMesh" defaultValue: nil];
  NSInteger newMeshID = [dict integerValueForKey:@"newMeshID" defaultValue:1];
  [GizWifiSDK changeDeviceMesh:meshDeviceInfo currentMesh: currentMesh newMeshID: newMeshID];
  
  [self.callBackManager addResult:result type:GizWifiRnResultTypeChangeDeviceMesh identity:nil repeatable:YES];
}

#pragma mark - noti
- (NSArray<NSString *> *)supportedEvents{
  return @[GizDeviceListNotifications, GizMeshDeviceListNotifications];
}

- (void)notiWithType:(GizWifiRnResultType)type result:(NSDictionary *)result{
  
  switch (type) {
    case GizWifiRnResultTypeDeviceListNoti:{
      [self sendEventWithName:GizDeviceListNotifications body:result];
    }
      break;
    case GizWifiRnResultTypeMeshDeviceListNoti:{
      [self sendEventWithName:GizMeshDeviceListNotifications body:result];
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
  
  if (eventID == GIZ_SDK_START_SUCCESS) {
    [self.callBackManager callBackWithType:GizWifiRnResultTypeAppStart identity:nil resultDict:@[[NSNull null], errorDict]];
  } else {
    [self.callBackManager callBackWithType:GizWifiRnResultTypeAppStart identity:nil resultDict:@[errorDict]];
    //noti
    if (![self.callBackManager haveCallBack:GizWifiRnResultTypeAppStart identity:nil]) {
      [self notiWithType:GizWifiRnResultTypeDeviceListNoti result:@{strEventType: errorDict}];
    }
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
  [self.callBackManager callBackWithType:GizWifiRnResultTypeGetBoundDevices identity:nil resultDict:dataDict errorDict:errDict];
  
  //noti
  [self notiWithType:GizWifiRnResultTypeDeviceListNoti result:errDict ? : dataDict];
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDiscoveredMeshDevices:(NSError *)result meshDeviceList:(NSArray *)meshDeviceList{
  NSDictionary *dataDict = nil;
  NSDictionary *errDict = nil;
  
  if (result.code == GIZ_SDK_SUCCESS) {
    //｛“devices”: [device1, device2, ...]｝
    //        NSMutableArray *arrDevice = [NSMutableArray array];
    //        for (GizWifiDevice *device in meshDeviceList) {
    //            NSDictionary *dictDevice = [GizWifiCordovaSDK makeDictFromDeviceWithProperties:device];
    //            [arrDevice addObject:dictDevice];
    //        }
    dataDict = @{@"meshDevices": meshDeviceList};
  } else {
    errDict = [NSDictionary makeErrorDictFromError:result];
  }
  //noti
  [self notiWithType:GizWifiRnResultTypeMeshDeviceListNoti result:errDict ? : dataDict];
  
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didRestoreDeviceFactorySetting:(NSString *)mac result:(NSError *)result{
  NSDictionary *dataDict = nil;
  NSDictionary *errDict = nil;
  
  if (result.code == GIZ_SDK_SUCCESS) {
    dataDict = @{@"mac": mac};
  } else {
    errDict = [NSDictionary makeErrorDictFromError:result];
  }
  
  [self.callBackManager callBackWithType:GizWifiRnResultTypeRestoreDeviceFactorySetting identity:nil resultDict:dataDict errorDict:errDict];
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didAddMeshDevicesToGroup:(NSArray<GizWifiDevice *> *)successMeshDevice result:(NSError *)result{
  NSArray *dataDict = nil;
  NSDictionary *errDict = nil;
  
  if (result.code == GIZ_SDK_SUCCESS) {
    NSMutableArray *arrDevice = [NSMutableArray array];
    for (GizWifiDevice *device in successMeshDevice) {
      NSDictionary *dictDevice = [NSDictionary makeDictFromDeviceWithProperties:device];
      [arrDevice addObject:dictDevice];
    }
    dataDict = arrDevice;
  } else {
    errDict = [NSDictionary makeErrorDictFromError:result];
  }
  
  [self.callBackManager callBackWithType:GizWifiRnResultTypeaAddMeshGroup identity:nil resultDict:dataDict errorDict:errDict];
}


- (void)wifiSDK:(GizWifiSDK * _Nonnull)wifiSDK didChangeDeviceMesh:(NSDictionary * _Nonnull)meshDeviceInfo result:(NSError * _Nullable)result {
  
  NSDictionary *dataDict = nil;
  NSDictionary *errDict = nil;
  
  if (result.code == GIZ_SDK_SUCCESS) {
    dataDict = meshDeviceInfo;
  } else {
    errDict = [NSDictionary makeErrorDictFromError:result];
  }
  
  [self.callBackManager callBackWithType:GizWifiRnResultTypeChangeDeviceMesh identity:nil resultDict:dataDict errorDict:errDict];
};

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDeviceSafetyUnbind:(NSArray *)failedDevices{
  NSDictionary *dataDict = nil;
  dataDict = [NSMutableDictionary dictionary];
  [dataDict setValue:failedDevices forKey:@"fail"];
  [self.callBackManager callBackWithType:GizWifiRnResultTypeDeviceSafetyUnbind identity:nil resultDict:dataDict errorDict:nil];
  
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDeviceSafetyRegister:(NSArray *)successDevices failedDevices:(NSArray *)failedDevices{
  NSDictionary *errDict = nil;
  NSDictionary *dataDict = nil;
  dataDict = [NSMutableDictionary dictionary];
  [dataDict setValue:failedDevices forKey:@"fail"];
  [dataDict setValue:successDevices forKey:@"success"];
  [self.callBackManager callBackWithType:GizWifiRnResultTypeDeviceSafetyRegister identity:nil resultDict:dataDict errorDict:errDict];
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didGetCurrentCloudService:(NSError *)result cloudServiceInfo:(NSDictionary<NSString *,NSString *> *)cloudServiceInfo{
  
  NSDictionary *dataDict = nil;
  NSDictionary *errDict = nil;
  
  if (result.code == GIZ_SDK_SUCCESS) {
    dataDict = [NSMutableDictionary dictionaryWithDictionary:cloudServiceInfo];
  } else{
    errDict = [NSDictionary makeErrorDictFromError:result];
  }
  
  [self.callBackManager callBackWithType:GizWifiRnResultTypeGetCurrentCloudService identity:nil resultDict:dataDict errorDict:errDict];
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
  
  [self.callBackManager callBackWithType:GizWifiRnResultTypeSetDeviceOnboardingDeploy identity:nil resultDict:dataDict errorDict:errDict];
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
  
  [self.callBackManager callBackWithType:GizWifiRnResultTypeBindRemoteDevice identity:nil resultDict:dataDict errorDict:errDict];
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


