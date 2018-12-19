//
//  GizWifiRnCallBackManager.h
//

#import <Foundation/Foundation.h>
@class GizWifiRnResult;

typedef void (^RCTResponseSenderBlock)(NSArray *response);
typedef NS_ENUM(NSInteger, GizWifiRnResultType) {
  GizWifiRnResultTypeAppStart = 1,
};

@interface GizWifiRnCallBackManager : NSObject
@property (nonatomic, strong) NSMutableArray *callbacks;
- (void)callBackWithType:(GizWifiRnResultType)type result:(NSArray *)result;
- (void)addResult:(RCTResponseSenderBlock)result type:(GizWifiRnResultType)type;
- (void)removeCallback:(GizWifiRnResult *)result;
- (void)removeCallbackWithType:(GizWifiRnResultType)type;
@end

@interface GizWifiRnResult : NSObject
@property (nonatomic, strong) RCTResponseSenderBlock result;
@property (nonatomic) GizWifiRnResultType type;
@end

