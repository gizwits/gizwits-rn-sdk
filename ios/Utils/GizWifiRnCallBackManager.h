//
//  GizWifiRnCallBackManager.h
//

#import <Foundation/Foundation.h>
@class GizWifiRnResult;
#define GizDeviceListNotifications @"GizDeviceListNotifications"
#define GizDeviceStatusNotifications @"GizDeviceStatusNotifications"
#define GizDeviceLogNotifications @"GizDeviceLogNotifications"
#define GizDeviceAppToDevNotifications @"GizDeviceAppToDevNotifications"

typedef void (^RCTResponseSenderBlock)(NSArray *response);

typedef NS_ENUM(NSInteger, GizWifiRnResultType) {
    GizWifiRnResultTypeAppStart = 1,
    GizWifiRnResultTypeSetDeviceOnboardingDeploy,
    GizWifiRnResultTypeSetDeviceOnboarding,

    GizWifiRnResultTypeUserLogout,
    

  GizWifiRnResultTypeDeviceListNoti,
  GizWifiRnResultTypeGetBoundDevices,
  GizWifiRnResultTypeGetCurrentCloudService,
  GizWifiRnResultTypeDeviceSafetyRegister,
  GizWifiRnResultTypeDeviceSafetyUnbind,
  GizWifiRnResultTypeRegisterBleDevice,
  GizWifiRnResultTypeGetVersione,
  GizWifiRnResultTypeChangeDeviceMesh,
  GizWifiRnResultTypeaAddMeshGroup,
  GizWifiRnResultTypeRestoreDeviceFactorySetting,
  GizWifiRnResultTypeBindRemoteDevice,
  GizWifiRnResultTypeReceiveDeviceLogNoti,
  //device
  GizWifiRnResultTypeSetSubscribe,
  GizWifiRnResultTypeConnectBle,
  GizWifiRnResultTypeDeviceStatusNoti,
  GizWifiRnResultTypeMeshDeviceListNoti,
  GizWifiRnResultTypeGetDeviceStatus,
  GizWifiRnResultTypeWrite,
  GizWifiRnResultTypeAppToDevNoti,

};

@interface GizWifiRnCallBackManager : NSObject
@property (nonatomic, strong) NSMutableArray *callbacks;
//call backs
+ (void)callBackWithResultDict:(NSDictionary *)resultDict result:(RCTResponseSenderBlock)result;

- (void)callBackWithType:(GizWifiRnResultType)type identity:(NSString *)identity resultDict:(NSArray *)resultDict;
- (void)callBackWithType:(GizWifiRnResultType)type identity:(NSString *)identity resultDict:(NSDictionary *)resultDict errorDict:(NSDictionary *)errorDict;
- (void)callbackParamInvalid:(RCTResponseSenderBlock)result;
- (void)callBackError:(NSDictionary *)errorDict result:(RCTResponseSenderBlock)result;
- (NSArray *)getEmptySuccessResult;
- (GizWifiRnResult *)haveCallBack:(GizWifiRnResultType)type identity:(NSString *)identity;
- (void)addResult:(RCTResponseSenderBlock)result type:(GizWifiRnResultType)type identity:(NSString *)identity repeatable:(BOOL)repeatable;
@end



@interface GizWifiRnResult : NSObject
@property (nonatomic, copy) RCTResponseSenderBlock result;
@property (nonatomic) GizWifiRnResultType type;
@property (nonatomic, copy) NSString *identity;
@end


