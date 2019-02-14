//
//  GizWifiRnCallBackManager.h
//

#import <Foundation/Foundation.h>
@class GizWifiRnResult;
#define GizDeviceListNotifications @"GizDeviceListNotifications"
#define GizDeviceStatusNotifications @"GizDeviceStatusNotifications"

typedef void (^RCTResponseSenderBlock)(NSArray *response);

typedef NS_ENUM(NSInteger, GizWifiRnResultType) {
    GizWifiRnResultTypeAppStart = 1,
    GizWifiRnResultTypeDeviceListNoti,
    GizWifiRnResultTypeGetBoundDevices,
    GizWifiRnResultTypeGetCurrentCloudService,
    GizWifiRnResultTypeGetVersione,
    GizWifiRnResultTypeSetDeviceOnboardingDeploy,
    GizWifiRnResultTypeBindRemoteDevice,
    //device
    GizWifiRnResultTypeSetSubscribe,
    GizWifiRnResultTypeDeviceStatusNoti,
    GizWifiRnResultTypeGetDeviceStatus,
    GizWifiRnResultTypeWrite,
};

@interface GizWifiRnCallBackManager : NSObject
@property (nonatomic, strong) NSMutableArray *callbacks;
//call backs
- (void)callBackWithType:(GizWifiRnResultType)type result:(NSArray *)result;
- (void)callBackWithType:(GizWifiRnResultType)type resultDict:(NSDictionary *)resultDict errorDict:(NSDictionary *)errorDict;
- (void)callbackParamInvalidWityType:(GizWifiRnResultType)type;
- (NSArray *)getEmptySuccessResult;

- (BOOL)containType:(GizWifiRnResultType)type;

- (void)addResult:(RCTResponseSenderBlock)result type:(GizWifiRnResultType)type;
@end



@interface GizWifiRnResult : NSObject
@property (nonatomic, strong) RCTResponseSenderBlock result;
@property (nonatomic) GizWifiRnResultType type;
@end


