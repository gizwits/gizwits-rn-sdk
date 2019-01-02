//
//  GizWifiRnCallBackManager.m
//

#import "GizWifiRnCallBackManager.h"
#import "NSDictionary+Giz.h"
#import "NSObject+Giz.h"
#import "GizWifiDef.h"

@implementation GizWifiRnCallBackManager
#pragma mark - set callbacks
- (void)callBackWithType:(GizWifiRnResultType)type result:(NSArray *)result{
  for (GizWifiRnResult *r in self.callbacks) {
    if (r.type == type) {
      r.result(result);
      [self.callbacks removeObject:r];
      break;
    }
  }
}

- (void)callBackWithType:(GizWifiRnResultType)type resultDict:(NSDictionary *)resultDict errorDict:(NSDictionary *)errorDict{
  [self callBackWithType:type result: (errorDict && errorDict.count) ? @[errorDict] : @[[NSNull null], resultDict]];
}

- (void)callbackParamInvalidWityType:(GizWifiRnResultType)type{
  NSDictionary *errorDict = [NSDictionary makeErrorDictFromResultCode:GIZ_SDK_PARAM_INVALID];
  [self callBackWithType:type result:@[errorDict]];
}

- (NSArray *)getEmptySuccessResult{
  return @[[NSNull null], [NSDictionary makeErrorDictFromResultCode:GIZ_SDK_SUCCESS]];
}

#pragma mark -
- (BOOL)containType:(GizWifiRnResultType)type{
  for (GizWifiRnResult *item in self.callbacks) {
    if (item.type == type) {
      return YES;
    }
  }
  return NO;
}

- (void)addResult:(RCTResponseSenderBlock)result type:(GizWifiRnResultType)type{
  if (result) {
    //remove old
    [self removeCallbackWithType:type];
    //add new
    GizWifiRnResult *r = [[GizWifiRnResult alloc] init];
    r.type = type;
    r.result = result;
    [self.callbacks addObject:r];
  }
}

- (void)removeCallbackWithType:(GizWifiRnResultType)type{
  for (GizWifiRnResult *item in self.callbacks) {
    if (item.type == type) {
      [self.callbacks removeObject:item];
      break;
    }
  }
}

- (void)removeCallback:(GizWifiRnResult *)result{
  if ([self.callbacks containsObject:result]) {
    [self.callbacks removeObject:result];
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
- (BOOL)isEqual:(id)object{
  if (self == object) {
    return YES;
  }
  
  if (![object isKindOfClass:[GizWifiRnResult class]]) {
    return NO;
  }
  
  return [self isEqualToGizWifiRnResult:(GizWifiRnResult *)object];
}

- (BOOL)isEqualToGizWifiRnResult:(GizWifiRnResult *)result{
  if (!result) {
    return NO;
  }
  
  return result.type == self.type;
}
@end
