//
//  GizWifiRnCallBackManager.h
//

#import <Foundation/Foundation.h>
@class GizWifiRnResult;
#define GizDeviceListNotifications @"GizDeviceListNotifications"
#define GizDeviceStatusNotifications @"GizDeviceStatusNotifications"
#define GizMeshDeviceListNotifications @"GizMeshDeviceListNotifications"
#define GizDeviceLogNotifications @"GizDeviceLogNotifications"
#define GizDeviceAppToDevNotifications @"GizDeviceAppToDevNotifications"

typedef void (^RCTResponseSenderBlock)(NSArray *response);

typedef NS_ENUM(NSInteger, GizWifiRnResultType) {
  GizWifiRnResultTypeAppStart = 1,
  GizWifiRnResultTypeDeviceListNoti,
  GizWifiRnResultTypeGetBoundDevices,
  GizWifiRnResultTypeGetCurrentCloudService,
  GizWifiRnResultTypeDeviceSafetyRegister,
  GizWifiRnResultTypeDeviceSafetyUnbind,
  GizWifiRnResultTypeGetVersione,
  GizWifiRnResultTypeChangeDeviceMesh,
  GizWifiRnResultTypeaAddMeshGroup,
  GizWifiRnResultTypeRestoreDeviceFactorySetting,
  GizWifiRnResultTypeSetDeviceOnboardingDeploy,
  GizWifiRnResultTypeBindRemoteDevice,
  GizWifiRnResultTypeReceiveDeviceLogNoti,
  GizWifiRnResultTypeUnBindDevice,
  GizWifiRnResultTypeBindChannel,
  //device
  GizWifiRnResultTypeSetSubscribe,
  GizWifiRnResultTypeDeviceStatusNoti,
  GizWifiRnResultTypeMeshDeviceListNoti,
  GizWifiRnResultTypeGetDeviceStatus,
  GizWifiRnResultTypeWrite,
  GizWifiRnResultTypeAppToDevNoti,

};

@interface GizWifiRnCallBackManager : NSObject
@property (nonatomic, strong) NSMutableArray *callbacks;
//call backs
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


