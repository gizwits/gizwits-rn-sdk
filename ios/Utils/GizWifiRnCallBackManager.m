//
//  GizWifiRnCallBackManager.m
//

#import "GizWifiRnCallBackManager.h"
#import "NSDictionary+Giz.h"
#import "NSObject+Giz.h"
#import "GizWifiDef.h"

@implementation GizWifiRnCallBackManager
#pragma mark - set callbacks

+ (void)callBackWithResultDict:(NSDictionary *)resultDict result:(RCTResponseSenderBlock)result {
    if (result) {
        result(@[[NSNull null], resultDict]);
    }
}

- (void)callBackWithType:(GizWifiRnResultType)type identity:(NSString *)identity resultDict:(NSArray *)resultDict{
  dispatch_async(dispatch_get_main_queue(), ^{
    GizWifiRnResult *r = [self haveCallBack:type identity:identity];
    if (r) {
      if (r.result) {
        r.result(resultDict);
      }
      [self.callbacks removeObject:r];
    }
  });
}

- (void)callBackWithType:(GizWifiRnResultType)type identity:(NSString *)identity resultDict:(NSDictionary *)resultDict errorDict:(NSDictionary *)errorDict{
  [self callBackWithType:type
                identity:identity
              resultDict:(errorDict && errorDict.count) ? @[errorDict] : @[[NSNull null], resultDict]];
}

- (void)callbackParamInvalid:(RCTResponseSenderBlock)result{
  NSDictionary *errorDict = [NSDictionary makeErrorDictFromResultCode:GIZ_SDK_PARAM_INVALID];
  if (result) {
    result(@[errorDict]);
  }
}

- (void)callBackError:(NSDictionary *)errorDict result:(RCTResponseSenderBlock)result{
  if (result) {
    result(@[errorDict]);
  }
}

- (NSArray *)getEmptySuccessResult{
  return @[[NSNull null], [NSDictionary makeErrorDictFromResultCode:GIZ_SDK_SUCCESS]];
}

#pragma mark -
- (GizWifiRnResult *)haveCallBack:(GizWifiRnResultType)type identity:(NSString *)identity{
  //只回调第一个匹配到的结果
  for (GizWifiRnResult *r in self.callbacks) {
    if (r.type == type && r.identity == identity) {
      return r;
    }
  }
  return nil;
}

- (void)addResult:(RCTResponseSenderBlock)result type:(GizWifiRnResultType)type identity:(NSString *)identity repeatable:(BOOL)repeatable{
  if (result) {//需要回调
    dispatch_async(dispatch_get_main_queue(), ^{
      if (!repeatable && [self haveCallBack:type identity:identity]) {
        //这里注释掉效果：重复调、只将sdk第一次回调回复给js的第一次调用
        //      result(@[[NSDictionary makeWaitForTheLastRequestError]]);
        return;
      }
      GizWifiRnResult *r = [[GizWifiRnResult alloc] init];
      r.type = type;
      r.result = result;
      r.identity = identity;
      [self.callbacks addObject:r];
    });
  }
}

- (NSMutableArray *)callbacks{
  if (_callbacks == nil) {
    _callbacks = [NSMutableArray array];
  }
  return _callbacks;
}

@end

@implementation GizWifiRnResult
//- (BOOL)isEqual:(id)object{
//    if (self == object) {
//        return YES;
//    }
//
//    if (![object isKindOfClass:[GizWifiRnResult class]]) {
//        return NO;
//    }
//
//    return [self isEqualToGizWifiRnResult:(GizWifiRnResult *)object];
//}
//
//- (BOOL)isEqualToGizWifiRnResult:(GizWifiRnResult *)result{
//    if (!result) {
//        return NO;
//    }
//
//    return result.type == self.type && result.identity == self.identity;
//}
@end

