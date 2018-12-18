//
//  RNGizwitsRnSdk.m
//

#import "RNGizwitsRnSdk.h"
#import <GizWifiSDK/GizWifiSDK.h>
#import "GizWifiSDKCache.h"
#import "NSObject+Giz.h"
#import "NSDictionary+Giz.h"

/////
@interface GizWifiRnResult: NSObject
typedef NS_ENUM(NSInteger, GizWifiRnResultType) {
  GizWifiRnResultTypeAppStart = 1,
};
@property (nonatomic, strong) RCTResponseSenderBlock result;
@property (nonatomic) GizWifiRnResultType type;
@end

@interface RNGizwitsRnSdk()<GizWifiSDKDelegate>
@property (nonatomic, strong) NSMutableArray *results;
@end


@implementation GizWifiRnResult
@end
/////

@implementation RNGizwitsRnSdk

- (instancetype)init{
  self = [super init];
  if (self) {
    [GizWifiSDKCache addDelegate:self];
  }
  return self;
}

- (NSMutableArray *)results{
  if (_results == nil) {
    _results = [NSMutableArray array];
  }
  return _results;
}

- (void)addResult:(RCTResponseSenderBlock)result{
  if (result) {
    for (GizWifiRnResult *item in self.results) {
      if (item.type == GizWifiRnResultTypeAppStart) {
        [self.results removeObject:item];
        break;
      }
    }
    GizWifiRnResult *r = [[GizWifiRnResult alloc] init];
    r.type = GizWifiRnResultTypeAppStart;
    r.result = result;
    [self.results addObject:r];
  }
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(startWithAppID:(id)configInfo result:(RCTResponseSenderBlock)result){
  [self addResult:result];
  NSDictionary *dict = [configInfo dictionaryObject];
  if (!dict) {
    NSDictionary *errorDict = [NSDictionary makeErrorCodeFromResultCode:GIZ_SDK_PARAM_INVALID];
    [self callBackWithType:GizWifiRnResultTypeAppStart result:@[errorDict]];
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
      NSDictionary *errorDict = [NSDictionary makeErrorCodeFromResultCode:GIZ_SDK_PARAM_INVALID];
      [self callBackWithType:GizWifiRnResultTypeAppStart result:@[errorDict]];
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

#pragma mark - noti
- (NSArray<NSString *> *)supportedEvents{
  return @[];
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
  
//  if (_cbNotification != nil) {
//    [self sendResultEventWithCallbackId:_cbNotification dataDict:@{strEventType: errorDict} errDict:nil doDelete:NO];
//  }
  
    NSDictionary *errorDict = [NSDictionary makeErrorCodeFromResultCode:eventID];
    if (eventID == GIZ_SDK_START_SUCCESS) {
      [self callBackWithType:GizWifiRnResultTypeAppStart result:@[[NSNull null], errorDict]];
    } else {
      [self callBackWithType:GizWifiRnResultTypeAppStart result:@[errorDict]];
      [self callBackWithType:GizWifiRnResultTypeAppStart result:@[errorDict]];
    }
}

- (void)callBackWithType:(GizWifiRnResultType)type result:(NSArray *)result{
  for (GizWifiRnResult *r in self.results) {
    if (r.type == type) {
      r.result(result);
      [self.results removeObject:r];
    }
  }
}

@end

