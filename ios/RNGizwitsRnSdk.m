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
#import <objc/runtime.h>


#define SDK_MODULE_VERSION      @"2.1.1"

/**
 @brief GizCompareDeviceProperityType枚举，描述两个设备的属性值是否相同
 */
typedef NS_ENUM(NSInteger, GizCompareDeviceProperityType) {
    /** 所有属性都相等 */
    GizCompareDeviceProperityAllEqual = 0,
    /** 只有netStatus不相等 */
    GizCompareDeviceProperityNetStatusUnEqual = 1,
    /** 有netStatus以外的属性不等 */
    GizCompareDeviceProperityUnEqual = 2,
};

@interface RNGizwitsRnSdk()<GizWifiSDKDelegate>
@property (nonatomic, strong) GizWifiRnCallBackManager *callBackManager;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSDictionary *>* oldDeviceList;
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
RCT_EXPORT_METHOD(startWithAppInfo:(id)configInfo result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [configInfo dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    [self.callBackManager addResult:result type:GizWifiRnResultTypeAppStart identity:nil repeatable:NO];

    NSDictionary *appInfo = [dict dictValueForKey:@"appInfo" defaultValue:nil];
    NSDictionary *productInfo = [dict arrayValueForKey:@"productInfo" defaultValue:nil];
    NSDictionary *cloudSeviceInfo = [dict dictValueForKey:@"cloudSeviceInfo" defaultValue:nil];

    [GizWifiSDK startWithAppInfo:appInfo productInfo:productInfo cloudServiceInfo:cloudSeviceInfo];
}

RCT_EXPORT_METHOD(getVersion:(RCTResponseSenderBlock)result){
    NSString *version = [NSString stringWithFormat:@"%@-%@", [GizWifiSDK getVersion], SDK_MODULE_VERSION];
    if (result) {
        result(@[[NSNull null], version]);
    }
}

RCT_EXPORT_METHOD(disableLAN:(id)info){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        return;
    }
    BOOL isDisableLan = [dict boolValueForKey:@"isDisableLan" defaultValue:NO];
    [GizWifiSDK disableLAN:isDisableLan];
}

RCT_EXPORT_METHOD(setDeviceOnboardingDeploy:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    NSString *ssid = [dict stringValueForKey:@"ssid" defaultValue:@""];
    NSString *key = [dict stringValueForKey:@"key" defaultValue:@""];
    GizWifiConfigureMode mode = getConfigModeFromInteger([dict integerValueForKey:@"mode" defaultValue:-1]);
    NSString *softAPSSIDPrefix = [dict stringValueForKey:@"softAPSSIDPrefix" defaultValue:@""];
    NSInteger timeout = [dict integerValueForKey:@"timeout" defaultValue:0];
    NSArray *gagentTypes = [dict arrayValueForKey:@"gagentTypes" defaultValue:nil];

    if (ssid.length == 0 || (NSInteger)configMode == -1) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    [self.callBackManager addResult:result type:GizWifiRnResultTypeSetDeviceOnboardingDeploy identity:nil repeatable:YES];
    [[GizWifiSDK sharedInstance] setDeviceOnboardingDeploy:ssid key:key configMode:mode softAPSSIDPrefix:softAPSSIDPrefix timeout:timeout wifiGAgentType:gagentTypes];
}

RCT_EXPORT_METHOD(setDeviceOnboarding:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    NSInteger timeout = [dict integerValueForKey:@"timeout" defaultValue:0];
    [self.callBackManager addResult:result type:GizWifiRnResultTypeSetDeviceOnboarding identity:nil repeatable:YES];
    [[GizWifiSDK sharedInstance] setDeviceOnboarding:timeout];
}

RCT_EXPORT_METHOD(stopDeviceOnboarding){
    [[GizWifiSDK sharedInstance] stopDeviceOnboarding];
}

RCT_EXPORT_METHOD(setUidAndToken:(id)info){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        return;
    }
    NSString *uid = [dict stringValueForKey:@"uid" defaultValue:@""];
    NSString *token = [dict stringValueForKey:@"token" defaultValue:@""];
    [[GizWifiSDK sharedInstance] setUid:uid token:token];
}

RCT_EXPORT_METHOD(userLoginAnonymous:(RCTResponseSenderBlock)result){
    [[GizWifiSDK sharedInstance] userLoginAnonymous:^(OpenApiLoginResult * _Nonnull loginResult) {
        NSDictionary *resultDic = [NSDictionary makeOpenApiLoginResultDic:loginResult];
        [GizWifiRnCallBackManager callBackWithResultDict:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(registerUser:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        return;
    }

    NSString *username = [dict stringValueForKey:@"username" defaultValue:@""];
    NSString *password = [dict stringValueForKey:@"password" defaultValue:@""];
    NSString *code = [dict stringValueForKey:@"code" defaultValue:@""];
    NSInteger accountType = [dict integerValueForKey:@"accountType" defaultValue:-1];

    if (accountType == -1) {
        [self.callBackManager callbackParamInvalid:result];
        return ;
    }

    [[GizWifiSDK sharedInstance] registerUser:username password:password verifyCode:code accountType:accountType callback:^(OpenApiLoginResult * _Nonnull loginResult) {
        NSDictionary *resultDic = [NSDictionary makeOpenApiLoginResultDic:loginResult];
        [GizWifiRnCallBackManager callBackWithResultDict:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(userLogin:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        return;
    }

    NSString *username = [dict stringValueForKey:@"username" defaultValue:@""];
    NSString *password = [dict stringValueForKey:@"password" defaultValue:@""];
    [[GizWifiSDK sharedInstance] userLogin:username password:password callback:^(OpenApiLoginResult * _Nonnull loginResult) {
        NSDictionary *resultDic = [NSDictionary makeOpenApiLoginResultDic:loginResult];
        [GizWifiRnCallBackManager callBackWithResultDict:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(dynamicLogin:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        return;
    }

    NSString *phone = [dict stringValueForKey:@"phone" defaultValue:@""];
    NSString *code = [dict stringValueForKey:@"code" defaultValue:@""];
    [[GizWifiSDK sharedInstance] dynamicLogin:phone code:code callback:^(OpenApiLoginResult * _Nonnull loginResult) {
        NSDictionary *resultDic = [NSDictionary makeOpenApiLoginResultDic:loginResult];
        [GizWifiRnCallBackManager callBackWithResultDict:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(userLoginWithThirdAccount:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        return;
    }

    NSInteger thirdAccountType = [dict integerValueForKey:@"thirdAccountType" defaultValue:-1];
    if (thirdAccountType == -1) {
        [self.callBackManager callbackParamInvalid:result];
        return ;
    }

    NSString *uid = [dict stringValueForKey:@"uid" defaultValue:@""];
    NSString *token = [dict stringValueForKey:@"token" defaultValue:@""];
    NSString *tokenSecret = [dict stringValueForKey:@"tokenSecret" defaultValue:@""];
    [[GizWifiSDK sharedInstance] userLoginWithThirdAccount:thirdAccountType uid:uid token:token tokenSecret:tokenSecret callback:^(OpenApiLoginResult * _Nonnull loginResult) {
        NSDictionary *resultDic = [NSDictionary makeOpenApiLoginResultDic:loginResult];
        [GizWifiRnCallBackManager callBackWithResultDict:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(userLogout:(RCTResponseSenderBlock)result){
    [self.callBackManager addResult:result type:GizWifiRnResultTypeAppStart identity:nil repeatable:NO];
#warning 还没写回调
    [[GizWifiSDK sharedInstance] userLogout];
}


//RCT_EXPORT_METHOD(getBoundDevices:(id)info result:(RCTResponseSenderBlock)result){
//    NSDictionary *dict = [info dictionaryObject];
//    if (!dict) {
//        [self.callBackManager callbackParamInvalid:result];
//        return;
//    }
//
//    [self.callBackManager addResult:result type:GizWifiRnResultTypeGetBoundDevices identity:nil repeatable:YES];
//
//    NSString *uid = [dict stringValueForKey:@"uid" defaultValue:nil];
//    NSString *token = [dict stringValueForKey:@"token" defaultValue:nil];
//    NSArray *specialProductKeys = [dict arrayValueForKey:@"specialProductKeys" defaultValue:@[]];
//
//    [[GizWifiSDK sharedInstance] getBoundDevices:uid token:token specialProductKeys:specialProductKeys];
//}
//
//RCT_EXPORT_METHOD(getCurrentCloudService:(RCTResponseSenderBlock)result){
//    [self.callBackManager addResult:result type:GizWifiRnResultTypeGetCurrentCloudService identity:nil repeatable:NO];
//    [GizWifiSDK getCurrentCloudService];
//}
//
//RCT_EXPORT_METHOD(getBoundBleDevice:(RCTResponseSenderBlock)result){
//    NSArray *bleDevices = [[GizWifiSDK sharedInstance] getBoundBleDevice];
//    if (!bleDevices) {
//        bleDevices = [NSArray array];
//    }
//    if (result) {
//        result(@[[NSNull null], bleDevices]);
//    }
//}
//
//RCT_EXPORT_METHOD(bindRemoteDevice:(id)info result:(RCTResponseSenderBlock)result){
//    NSDictionary *dict = [info dictionaryObject];
//    if (!dict) {
//        [self.callBackManager callbackParamInvalid:result];
//        return;
//    }
//
//    NSString *uid = [dict stringValueForKey:@"uid" defaultValue:@""];
//    NSString *token = [dict stringValueForKey:@"token" defaultValue:@""];
//    NSString *mac = [dict stringValueForKey:@"mac" defaultValue:@""];
//    NSString *productKey = [dict stringValueForKey:@"productKey" defaultValue:@""];
//    NSString *productSecret = [dict stringValueForKey:@"productSecret" defaultValue:@""];
//    Boolean beOwner = [dict boolValueForKey:@"beOwner" defaultValue:false];
//
//    if (uid.length == 0 || token.length == 0 || mac.length == 0 || productKey.length == 0 ||
//        productSecret.length == 0) {
//        [self.callBackManager callbackParamInvalid:result];
//        return;
//    }
//    [self.callBackManager addResult:result type:GizWifiRnResultTypeBindRemoteDevice identity:nil repeatable:YES];
//    [[GizWifiSDK sharedInstance] bindRemoteDevice:uid token:token mac:mac productKey:productKey productSecret:productSecret beOwner:beOwner];
//}
//
//RCT_EXPORT_METHOD(unbindDevice:(id)info result:(RCTResponseSenderBlock)result){
//    NSDictionary *dict = [info dictionaryObject];
//    if (!dict) {
//        [self.callBackManager callbackParamInvalid:result];
//        return;
//    }
//    NSString *uid = [dict stringValueForKey:@"uid" defaultValue:@""];
//    NSString *token = [dict stringValueForKey:@"token" defaultValue:@""];
//    NSString *did = [dict stringValueForKey:@"did" defaultValue:@""];
//
//    if (uid.length == 0 || token.length == 0 || did.length == 0) {
//        [self.callBackManager callbackParamInvalid:result];
//        return;
//    } else {
//        [self.callBackManager addResult:result type:GizWifiRnResultTypeUnBindDevice identity:nil repeatable:YES];
//        [[GizWifiSDK sharedInstance] unbindDevice:uid token:token did:did];
//    }
//}
//
//RCT_EXPORT_METHOD(stopDeviceOnboarding){
//    [[GizWifiSDK sharedInstance] stopDeviceOnboarding];
//}
//
//RCT_EXPORT_METHOD(userLoginAnonymous){
//    [[GizWifiSDK sharedInstance] userLoginAnonymous];
//}
//
//RCT_EXPORT_METHOD(userFeedback:(id)info){
//    NSDictionary *dict = [info dictionaryObject];
//    if (!dict) {
//        return;
//    }
//    NSString *contactInfo = [dict stringValueForKey:@"contactInfo" defaultValue:@""];
//    NSString *feedbackInfo = [dict stringValueForKey:@"feedbackInfo" defaultValue:@""];
//    BOOL sendLog = [dict boolValueForKey:@"sendLog" defaultValue:YES];
//    [GizWifiSDK userFeedback:contactInfo feedbackInfo:feedbackInfo sendLog:sendLog];
//}
//
//
//
//- (NSMutableData *)convertHexStrToData:(NSString *)str {
//    if (!str || [str length] == 0) {
//        return nil;
//    }
//    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
//    NSRange range;
//    if ([str length] %2 == 0) {
//        range = NSMakeRange(0,2);
//    } else {
//        range = NSMakeRange(0,1);
//    }
//    for (NSInteger i = range.location; i < [str length]; i += 2) {
//        unsigned int anInt;
//        NSString *hexCharStr = [str substringWithRange:range];
//        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
//        [scanner scanHexInt:&anInt];
//        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
//        [hexData appendData:entity];
//        range.location += range.length;
//        range.length = 2;
//    }
//    return hexData;
//}
//
//RCT_EXPORT_METHOD(setUserMeseName:(id)info result:(RCTResponseSenderBlock)result){
//    //  NSDictionary *dict = [info dictionaryObject];
//    //  if (!dict) {
//    //    return;
//    //  }
//    //  NSString *meshName = [dict stringValueForKey:@"meshName" defaultValue:@""];
//    //  NSString *password = [dict stringValueForKey:@"password" defaultValue:@""];
//    //  NSDictionary *uuidInfo = [dict objectForKey:@"uuidInfo"];
//    //  NSString *meshLTK = [dict stringValueForKey:@"meshLTK" defaultValue:@""];
//    //  GizMeshVerdor meshVerdor = getMeshVerdorFromInteger([dict integerValueForKey:@"meshVerdor" defaultValue:-1]);
//    //  if(meshName==nil||password==nil||uuidInfo==nil||[meshLTK isEqualToString:@""])
//    //  {
//    //    [self.callBackManager callbackParamInvalid:result];
//    //  }else{
//    //    NSData *testData = [self convertHexStrToData:meshLTK];
//    //    [GizWifiSDK setUserMeshName:meshName password:password uuidInfo:uuidInfo meshLTK:testData meshVendor:(GizMeshVerdor)meshVerdor];
//    //    if (result) {
//    //      result(@[[NSNull null]]);
//    //    }
//    //  }
//}
//
//RCT_EXPORT_METHOD(deviceSafetyRegister:(id)info result:(RCTResponseSenderBlock)result){
//    NSDictionary *dict = [info dictionaryObject];
//    if (!dict) {
//        return;
//    }
//    NSString *gateWayMac = [dict stringValueForKey:@"gatewayMac" defaultValue:@""];
//    NSString *gateWayDid = [dict stringValueForKey:@"gatewayDid" defaultValue:@""];
//    NSString *pk = [dict stringValueForKey:@"productKey" defaultValue:@""];
//    NSArray *devicesInfo=[dict arrayValueForKey:@"devicesInfo" defaultValue:@[]];
//
//    GizWifiDevice *giz = [GizWifiDeviceCache cachedDeviceWithMacAddress:gateWayMac did:gateWayDid];
//    //    GizSDKPrintCbId("cbId", _cbDeviceSafeRegister);
//    if (pk.length == 0) {
//        [self.callBackManager callbackParamInvalid:result];
//    } else {
//        [GizWifiSDK deviceSafetyRegister:giz productKey:pk devicesInfo:devicesInfo];
//        [self.callBackManager addResult:result type:GizWifiRnResultTypeDeviceSafetyRegister identity:nil repeatable:NO];
//    }
//}
//
//RCT_EXPORT_METHOD(deviceSafetyUnbind:(id)info result:(RCTResponseSenderBlock)result){
//    NSDictionary *dict = [info dictionaryObject];
//    if (!dict) {
//        return;
//    }
//    NSArray *devicesInfo=[dict arrayValueForKey:@"devicesInfo" defaultValue:@[]];
//    NSMutableArray *devices=[NSMutableArray array];
//    for (NSInteger i=0; i<devicesInfo.count; i++) {
//        NSString *mac = [devicesInfo[i] stringValueForKey:@"mac" defaultValue:@""];
//        NSString *did = [devicesInfo[i] stringValueForKey:@"did" defaultValue:@""];
//        GizWifiDevice *giz = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
//        NSDictionary *device=@{@"device":giz,@"authCode":[devicesInfo[i] stringValueForKey:@"authCode" defaultValue:@""]};
//        [devices addObject:device];
//    }
//    [GizWifiSDK deviceSafetyUnbind:devices];
//    [self.callBackManager addResult:result type:GizWifiRnResultTypeDeviceSafetyUnbind identity:nil repeatable:NO];
//}
//
//RCT_EXPORT_METHOD(registerBleDevice:(id)info result:(RCTResponseSenderBlock)result){
//    NSDictionary *dict = [info dictionaryObject];
//    if (!dict) {
//        return;
//    }
//    NSString *mac = [dict stringValueForKey:@"mac" defaultValue:@""];
//    [[GizWifiSDK sharedInstance] registerBleDevice:mac];
//    [self.callBackManager addResult:result type:GizWifiRnResultTypeRegisterBleDevice identity:nil repeatable:NO];
//}
//
//
//RCT_EXPORT_METHOD(channelIDBind:(id)info result:(RCTResponseSenderBlock)result){
//    NSDictionary *dict = [info dictionaryObject];
//    if (!dict) {
//        return;
//    }
//    NSString *token = [dict stringValueForKey:@"token" defaultValue:@""];
//    NSString *channelID = [dict stringValueForKey:@"channelId" defaultValue:@""];
//    BOOL isBind = [dict boolValueForKey:@"isBind" defaultValue:YES];
//    if(isBind){
//        NSString *alias = [dict stringValueForKey:@"alias" defaultValue:@""];
//        GizPushType pushType = getPushTypeFromInteger([dict integerValueForKey:@"pushType" defaultValue:0]);
//        [[GizWifiSDK sharedInstance] channelIDBind:token channelID:channelID alias:alias pushType:pushType];
//    }else{
//        [[GizWifiSDK sharedInstance] channelIDUnBind:token channelID:channelID];
//    }
//
//    [self.callBackManager addResult:result type:GizWifiRnResultTypeBindChannel identity:nil repeatable:NO];
//
//}
//
//RCT_EXPORT_METHOD(searchMeshDevice:(id)info result:(RCTResponseSenderBlock)result){
//    //  NSDictionary *dict = [info dictionaryObject];
//    //  if (!dict) {
//    //    return;
//    //  }
//    //  NSString *meshName = [dict stringValueForKey:@"meshName" defaultValue:@""];
//    //  if (meshName.length == 0 ) {
//    //    [self.callBackManager callbackParamInvalid:result];
//    //  } else {
//    //    [GizWifiSDK searchMeshDevice:meshName];
//    //    if (result) {
//    //      result(@[[NSNull null]]);
//    //    }
//    //  }
//}
//
//RCT_EXPORT_METHOD(addGroup:(id)info result:(RCTResponseSenderBlock)result){
//    //  NSDictionary *dict = [info dictionaryObject];
//    //  NSUInteger *groupID = [dict integerValueForKey:@"groupID" defaultValue:1];
//    //  NSArray *meshDevices = [dict arrayValueForKey:@"meshDevices" defaultValue: nil];
//    //  NSMutableArray *devices=[NSMutableArray array];
//    //  for (NSDictionary *meshDevice in meshDevices) {
//    //    NSString *mac = [meshDevice stringValueForKey:@"mac" defaultValue:@""];
//    //    NSString *did = [meshDevice stringValueForKey:@"did" defaultValue:@""];
//    //    GizWifiDevice *giz = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
//    //    [devices addObject:giz];
//    //  }
//    //  [GizWifiSDK addGroup:groupID meshDevices:devices];
//    //  [self.callBackManager addResult:result type:GizWifiRnResultTypeaAddMeshGroup identity:nil repeatable:YES];
//}
//
///**
// @param ssid 前缀
// */
////
//RCT_EXPORT_METHOD(getDeviceLog:(id)info){
//    //
//    //  NSDictionary *dict = [info dictionaryObject];
//    //
//    //  NSString *softAPSSIDPrefix = [dict stringValueForKey:@"softAPSSIDPrefix" defaultValue:@"XPG-GAgent-"];
//    //  [GizWifiSDK getDeviceLog:softAPSSIDPrefix];
//}
//
///**
// @param type 0 client 1 deamon
// */
//
//RCT_EXPORT_METHOD(getLog:(id)info result:(RCTResponseSenderBlock)result){
//
//    NSDictionary *dict = [info dictionaryObject];
//
//    NSInteger *type = [dict integerValueForKey:@"type" defaultValue:0];
//    NSString *address = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/GizWifiSDK"];
//    NSString *clientAddress = [NSString stringWithFormat:@"%@%@", address, @"/GizSDKLog/Client/GizSDKClientLogFile.sys" ];
//    NSString *deamonAddress = [NSString stringWithFormat:@"%@%@", address, @"/GizSDKLog/Daemon/GizSDKLogFile.sys" ];
//
//    NSString *logAddress = @"";
//    if (type == 0) {
//        // 获取client日志
//        logAddress =clientAddress;
//    } else {
//        logAddress =deamonAddress;
//    }
//
//    NSString *str=[NSString stringWithContentsOfFile:logAddress encoding:NSASCIIStringEncoding error:nil];
//    NSMutableDictionary *data = [NSMutableDictionary dictionary];
//    [data setValue:str forKey:@"log"];
//
//    result(@[[NSNull null], data]);
//}
//
//
//RCT_EXPORT_METHOD(changeDeviceMesh:(id)info result:(RCTResponseSenderBlock)result){
//    //  NSDictionary *dict = [info dictionaryObject];
//    //  NSDictionary *meshDeviceInfo = [dict dictValueForKey:@"meshDeviceInfo" defaultValue: nil];
//    //  NSDictionary *currentMesh = [dict dictValueForKey:@"currentMesh" defaultValue: nil];
//    //  NSInteger newMeshID = [dict integerValueForKey:@"newMeshID" defaultValue:1];
//    //  [GizWifiSDK changeDeviceMesh:meshDeviceInfo currentMesh: currentMesh newMeshID: newMeshID];
//    //
//    //  [self.callBackManager addResult:result type:GizWifiRnResultTypeChangeDeviceMesh identity:nil repeatable:YES];
//}
//
#pragma mark - noti
- (NSArray<NSString *> *)supportedEvents{
    return @[GizDeviceListNotifications, GizDeviceLogNotifications];
}

- (void)notiWithType:(GizWifiRnResultType)type result:(NSDictionary *)result{
    switch (type) {
        case GizWifiRnResultTypeDeviceListNoti:{
            [self sendEventWithName:GizDeviceListNotifications body:result];
            break;
        }
        case GizWifiRnResultTypeReceiveDeviceLogNoti:{
            [self sendEventWithName:GizDeviceLogNotifications body:result];
            break;
        }
        default:
            break;
    }
}

#pragma mark - GizWifiSDKDelegate
- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didNotifyEvent:(GizEventType)eventType eventSource:(id _Nonnull)eventSource eventID:(GizWifiErrorCode)eventID eventMessage:(NSString* _Nullable)eventMessage {
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
        //noti
        if (![self.callBackManager haveCallBack:GizWifiRnResultTypeAppStart identity:nil]) {
            [self notiWithType:GizWifiRnResultTypeDeviceListNoti result:@{strEventType: errorDict}];
        } else {
            [self.callBackManager callBackWithType:GizWifiRnResultTypeAppStart identity:nil resultDict:@[errorDict]];
        }
    }
}

- (void)wifiSDK:(GizWifiSDK * _Nonnull)wifiSDK didSetDeviceOnboarding:(GizError * _Nonnull)result device:(GizWifiDevice * _Nullable)device {
    NSDictionary *dataDict = nil;
    NSDictionary *errDict = nil;

    if (result.code == GIZ_SDK_SUCCESS) {
        NSMutableDictionary *mDevice = [NSMutableDictionary dictionary];
        [mDevice setValue:device.macAddress forKey:@"mac"];
        [mDevice setValue:device.did forKey:@"did"];
        [mDevice setValue:device.productKey forKey:@"productKey"];
        dataDict = [NSMutableDictionary dictionary];
        [dataDict setValue:mDevice forKey:@"device"];
    } else{
        errDict = [NSDictionary makeErrorDictFromError:result];
    }

    [self.callBackManager callBackWithType:GizWifiRnResultTypeSetDeviceOnboardingDeploy identity:nil resultDict:dataDict errorDict:errDict];
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didSetDeviceOnboarding:(GizError *)result deviceList:(NSArray<GizWifiDevice *> *)deviceList {
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
    [self.callBackManager callBackWithType:GizWifiRnResultTypeSetDeviceOnboarding identity:nil resultDict:dataDict errorDict:errDict];
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDiscovered:(NSError *)result deviceList:(NSArray<GizWifiDevice *> *)deviceList{
    NSLog(@">>> %@", deviceList);
    NSDictionary *dataDict = nil;
    NSDictionary *errDict = nil;

    if (result.code == GIZ_SDK_SUCCESS) {
        if ([self isOnlyNetStatusChangge:deviceList]) {
            // 只有设备状态发生变化
            return;
        }
        NSMutableArray *arrDevice = [NSMutableArray array];
        [self.oldDeviceList removeAllObjects];
        for (GizWifiDevice *device in deviceList) {
            NSDictionary *dictDevice = [NSDictionary makeDictFromDeviceWithProperties:device];
            [arrDevice addObject:dictDevice];
            [self.oldDeviceList setValue:dictDevice forKey:device.macAddress];
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
//
////- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDiscoveredMeshDevices:(NSError *)result meshDeviceList:(NSArray *)meshDeviceList{
////  NSDictionary *dataDict = nil;
////  NSDictionary *errDict = nil;
////
////  if (result.code == GIZ_SDK_SUCCESS) {
////    //｛“devices”: [device1, device2, ...]｝
////    //        NSMutableArray *arrDevice = [NSMutableArray array];
////    //        for (GizWifiDevice *device in meshDeviceList) {
////    //            NSDictionary *dictDevice = [GizWifiCordovaSDK makeDictFromDeviceWithProperties:device];
////    //            [arrDevice addObject:dictDevice];
////    //        }
////    dataDict = @{@"meshDevices": meshDeviceList};
////  } else {
////    errDict = [NSDictionary makeErrorDictFromError:result];
////  }
////  //noti
////  [self notiWithType:GizWifiRnResultTypeMeshDeviceListNoti result:errDict ? : dataDict];
////
////}
//
////- (void)wifiSDK:(GizWifiSDK *)wifiSDK didReceiveDeviceLog:(NSError *)result mac:(NSString *)mac timestamp:(NSInteger)timestamp logSN:(NSInteger)logSN log:(NSString *)log{
////    NSDictionary *dataDict = nil;
////    dataDict = [NSMutableDictionary dictionary];
////    NSDictionary *errDict = nil;
////
////    if (result.code == GIZ_SDK_SUCCESS) {
////      [dataDict setValue:[NSNumber numberWithInt:timestamp] forKey:@"timestamp"];
////      [dataDict setValue:[NSNumber numberWithInt:logSN] forKey:@"logSN"];
////      [dataDict setValue:log forKey:@"log"];
////    } else {
////      errDict = [NSDictionary makeErrorDictFromError:result];
////    }
////    [self notiWithType:GizWifiRnResultTypeReceiveDeviceLogNoti result:errDict ? : dataDict];
////}
//
////- (void)wifiSDK:(GizWifiSDK *)wifiSDK didRestoreDeviceFactorySetting:(NSString *)mac result:(NSError *)result{
////  NSDictionary *dataDict = nil;
////  NSDictionary *errDict = nil;
////
////  if (result.code == GIZ_SDK_SUCCESS) {
////    dataDict = @{@"mac": mac};
////  } else {
////    errDict = [NSDictionary makeErrorDictFromError:result];
////  }
////
////  [self.callBackManager callBackWithType:GizWifiRnResultTypeRestoreDeviceFactorySetting identity:nil resultDict:dataDict errorDict:errDict];
////}
//
////- (void)wifiSDK:(GizWifiSDK *)wifiSDK didAddDevicesToGroup:(NSArray<GizWifiDevice *> *)successMeshDevice result:(NSError *)result{
////  NSArray *dataDict = nil;
////  NSDictionary *errDict = nil;
////
////  if (result.code == GIZ_SDK_SUCCESS) {
////    NSMutableArray *arrDevice = [NSMutableArray array];
////    for (GizWifiDevice *device in successMeshDevice) {
////      NSDictionary *dictDevice = [NSDictionary makeDictFromDeviceWithProperties:device];
////      [arrDevice addObject:dictDevice];
////    }
////    dataDict = arrDevice;
////  } else {
////    errDict = [NSDictionary makeErrorDictFromError:result];
////  }
////
////  [self.callBackManager callBackWithType:GizWifiRnResultTypeaAddMeshGroup identity:nil resultDict:dataDict errorDict:errDict];
////}
//
//
////- (void)wifiSDK:(GizWifiSDK * _Nonnull)wifiSDK didChangeDeviceMesh:(NSDictionary * _Nonnull)meshDeviceInfo result:(NSError * _Nullable)result {
////
////  NSDictionary *dataDict = nil;
////  NSDictionary *errDict = nil;
////
////  if (result.code == GIZ_SDK_SUCCESS) {
////    dataDict = meshDeviceInfo;
////  } else {
////    errDict = [NSDictionary makeErrorDictFromError:result];
////  }
////
////  [self.callBackManager callBackWithType:GizWifiRnResultTypeChangeDeviceMesh identity:nil resultDict:dataDict errorDict:errDict];
////};
//
//- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDeviceSafetyUnbind:(NSArray *)failedDevices{
//    NSDictionary *dataDict = nil;
//    dataDict = [NSMutableDictionary dictionary];
//    [dataDict setValue:failedDevices forKey:@"fail"];
//    [self.callBackManager callBackWithType:GizWifiRnResultTypeDeviceSafetyUnbind identity:nil resultDict:dataDict errorDict:nil];
//
//}
//
//- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDeviceSafetyRegister:(NSArray *)successDevices failedDevices:(NSArray *)failedDevices{
//    NSDictionary *errDict = nil;
//    NSDictionary *dataDict = nil;
//    dataDict = [NSMutableDictionary dictionary];
//    [dataDict setValue:failedDevices forKey:@"fail"];
//    [dataDict setValue:successDevices forKey:@"success"];
//    [self.callBackManager callBackWithType:GizWifiRnResultTypeDeviceSafetyRegister identity:nil resultDict:dataDict errorDict:errDict];
//}
//
//- (void)wifiSDK:(GizWifiSDK * _Nonnull)wifiSDK didRegisterBleDevice:(NSError * _Nullable)result mac:(NSString * _Nullable)mac productKey:(NSString * _Nullable)productKey {
//    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
//    NSDictionary *errDict = nil;
//    if (result.code == GIZ_SDK_SUCCESS) {
//        [dataDict setValue:mac forKey:@"mac"];
//        [dataDict setValue:productKey forKey:@"productKey"];
//    } else{
//        errDict = [NSDictionary makeErrorDictFromError:result];
//    }
//    [self.callBackManager callBackWithType:GizWifiRnResultTypeRegisterBleDevice identity:nil resultDict:dataDict errorDict:errDict];
//}
//
//- (void)wifiSDK:(GizWifiSDK *)wifiSDK didGetCurrentCloudService:(NSError *)result cloudServiceInfo:(NSDictionary<NSString *,NSString *> *)cloudServiceInfo{
//
//    NSDictionary *dataDict = nil;
//    NSDictionary *errDict = nil;
//
//    if (result.code == GIZ_SDK_SUCCESS) {
//        dataDict = [NSMutableDictionary dictionaryWithDictionary:cloudServiceInfo];
//    } else{
//        errDict = [NSDictionary makeErrorDictFromError:result];
//    }
//
//    [self.callBackManager callBackWithType:GizWifiRnResultTypeGetCurrentCloudService identity:nil resultDict:dataDict errorDict:errDict];
//}
//

//
//- (void)wifiSDK:(GizWifiSDK *)wifiSDK didChannelIDBind:(NSError *)result
//{
//    NSDictionary *dataDict = nil;
//    NSDictionary *errDict = nil;
//
//    if (result.code == GIZ_SDK_SUCCESS) {
//        dataDict = [NSMutableDictionary dictionary];
//        [dataDict setValue:0 forKey:@"errorCode"];
//        [dataDict setValue:@"GIZ_SDK_SUCCESS" forKey:@"msg"];
//    } else{
//        errDict = [NSDictionary makeErrorDictFromError:result];
//    }
//
//    [self.callBackManager callBackWithType:GizWifiRnResultTypeBindChannel identity:nil resultDict:dataDict errorDict:errDict];
//
//}
//
//- (void)wifiSDK:(GizWifiSDK *)wifiSDK didChannelIDUnBind:(NSError *)result
//{
//    NSDictionary *dataDict = nil;
//    NSDictionary *errDict = nil;
//
//    if (result.code == GIZ_SDK_SUCCESS) {
//        dataDict = [NSMutableDictionary dictionary];
//        [dataDict setValue:@(0) forKey:@"errorCode"];
//        [dataDict setValue:@"GIZ_SDK_SUCCESS" forKey:@"msg"];
//    } else{
//        errDict = [NSDictionary makeErrorDictFromError:result];
//    }
//
//    [self.callBackManager callBackWithType:GizWifiRnResultTypeBindChannel identity:nil resultDict:dataDict errorDict:errDict];
//
//}
//
//- (void)wifiSDK:(GizWifiSDK *)wifiSDK didBindDevice:(NSError *)result did:(NSString *)did{
//
//    NSDictionary *dataDict = nil;
//    NSDictionary *errDict = nil;
//
//    if (result.code == GIZ_SDK_SUCCESS) {
//        dataDict = [NSMutableDictionary dictionary];
//        [dataDict setValue:did forKey:@"did"];
//    } else {
//        errDict = [NSDictionary makeErrorDictFromError:result];
//    }
//
//    [self.callBackManager callBackWithType:GizWifiRnResultTypeBindRemoteDevice identity:nil resultDict:dataDict errorDict:errDict];
//}
//
//- (void)wifiSDK:(GizWifiSDK *)wifiSDK didUnbindDevice:(NSError *)result did:(NSString *)did{
//    NSDictionary *dataDict = nil;
//    NSDictionary *errDict = nil;
//
//    if (result.code == GIZ_SDK_SUCCESS) {
//        dataDict = [NSMutableDictionary dictionary];
//        [dataDict setValue:did forKey:@"did"];
//    } else {
//        errDict = [NSDictionary makeErrorDictFromError:result];
//    }
//
//    [self.callBackManager callBackWithType:GizWifiRnResultTypeUnBindDevice identity:nil resultDict:dataDict errorDict:errDict];
//}
//
//#pragma mark - tool
///** 判断列表是否只有netStatus发生了变化 */
//- (BOOL)isOnlyNetStatusChangge: (NSArray <GizWifiDevice *>*)newDeviceList {
//    if (newDeviceList.count == 0) {
//        return NO; // 防止第一次没有推送
//    }
//    NSMutableArray *deviceArr = [NSMutableArray array];
//    if (self.oldDeviceList.count == newDeviceList.count) {
//        for (GizWifiDevice *device in newDeviceList) {
//            NSDictionary *deviceDic = self.oldDeviceList[device.macAddress];
//            if (deviceDic == nil) {
//                return NO;
//            }
//            GizCompareDeviceProperityType type = [self device:device allEqualExceptNetStatus:deviceDic];
//            switch (type) {
//                case GizCompareDeviceProperityNetStatusUnEqual: {
//                    [deviceArr addObject:@{@"device": device, @"deviceDic": deviceDic}];
//                    break;
//                }
//                case GizCompareDeviceProperityUnEqual: {
//                    return NO;
//                }
//                default:
//                    break;
//            }
//        }
//
//        for (NSDictionary *dic in deviceArr) {
//            GizWifiDevice *tmpDevice = dic[@"device"];
//            NSMutableDictionary *tmpDeviceDic = [NSMutableDictionary dictionaryWithDictionary:dic[@"deviceDic"]];
//            tmpDeviceDic[@"netStatus"] = @(tmpDevice.netStatus);
//            tmpDeviceDic[@"isOnline"] = @(tmpDevice.isOnline);
//            // 更新缓存的列表状态
//            [self.oldDeviceList setValue:[tmpDeviceDic copy] forKey:tmpDevice.macAddress];
//            // 给所有发生变化的设备推送状态变化
//            [GizWifiDeviceCache device:tmpDevice didUpdateNetStatus:tmpDevice.netStatus];
//        }
//        return YES;
//    }
//    return NO;
//}
//
///** 判断两个设备对象是否只有netStatus不同 */
//- (GizCompareDeviceProperityType)device:(GizWifiDevice *)device allEqualExceptNetStatus: (NSDictionary *)deviceDic {
//    NSMutableArray *numberPros = [NSMutableArray arrayWithArray:@[@{@"type": @"productType"}]];
//    NSMutableArray *strPros = [NSMutableArray arrayWithArray:@[@{@"mac": @"macAddress"}, @{@"did": @"did"}, @{@"productKey": @"productKey"}, @{@"productName": @"productName"}, @{@"ip": @"ipAddress"}, @{@"remark": @"remark"}, @{@"deviceModuleFirmwareVer": @"deviceModuleFirmwareVer"}, @{@"deviceMcuFirmwareVer": @"deviceMcuFirmwareVer"}, @{@"deviceModuleHardVer": @"deviceModuleHardVer"}, @{@"deviceMcuHardVer": @"deviceMcuHardVer"}]];
//    NSMutableArray *boolPros = [NSMutableArray arrayWithArray:@[@{@"isLAN": @"isLAN"}, @{@"isBind": @"isBind"}, @{@"isSubscribed": @"isSubscribed"}]];
//    if ([device isMemberOfClass:[GizLiteGWSubDevice class]]) {
//        [strPros addObject:@{@"meshID": @"meshID"}];
//    } else if ([device isMemberOfClass:[GizWifiBleDevice class]]) {
//        [boolPros addObject:@{@"isBlueLocal": @"isBlueLocal"}];
//    } else if (device .isLowPower) {
//        [boolPros addObject:@{@"isLowPower": @"isLowPower"}];
//        [boolPros addObject:@{@"isDormant": @"isDormant"}];
//        [numberPros addObject:@{@"stateLastTimestamp": @"stateLastTimestamp"}];
//        [numberPros addObject:@{@"sleepDuration": @"sleepDuration"}];
//    }
//
//    for (NSDictionary *numberPro in numberPros) {
//        NSString *dicKey = numberPro.allKeys.firstObject;
//        NSString *deviceKey = [numberPro stringValueForKey:dicKey defaultValue:nil];
//
//        NSInteger dicValue = [deviceDic integerValueForKey:dicKey defaultValue:0];
//        NSNumber *deviceValue = [device valueForKey:deviceKey];
//        if (dicValue != deviceValue.integerValue) {
//            return GizCompareDeviceProperityUnEqual;
//        }
//    }
//
//    for (NSDictionary *strPro in strPros) {
//        NSString *dicKey = strPro.allKeys.firstObject;
//        NSString *deviceKey = [strPro stringValueForKey:dicKey defaultValue:nil];
//        NSString *dicValue = [deviceDic stringValueForKey:dicKey defaultValue:@""];
//        NSString *deviceValue = [device valueForKey:deviceKey];
//        if (!deviceValue) {
//            deviceValue = @"";
//        }
//        if (![dicValue isEqualToString:deviceValue]) {
//            return GizCompareDeviceProperityUnEqual;
//        }
//    }
//
//    for (NSDictionary *boolPro in boolPros) {
//        NSString *dicKey = boolPro.allKeys.firstObject;
//        NSString *deviceKey = [boolPro stringValueForKey:dicKey defaultValue:nil];
//        BOOL dicValue = [deviceDic boolValueForKey:dicKey defaultValue:NO];
//        NSNumber *deviceValue = [device valueForKey:deviceKey];
//        if (dicValue != deviceValue.boolValue) {
//            return GizCompareDeviceProperityUnEqual;
//        }
//    }
//
//    NSString *dicRootDevice = [deviceDic stringValueForKey:@"rootDeviceId" defaultValue: @""];
//    NSString *deviceRootDevice = (device.rootDevice == nil ? @"" : device.rootDevice.did);
//    if (![dicRootDevice isEqualToString:deviceRootDevice]) {
//        return GizCompareDeviceProperityUnEqual;
//    }
//
//    GizWifiDeviceNetStatus dicNetStatus = [deviceDic integerValueForKey:@"netStatus" defaultValue:GizDeviceOffline];
//    if (dicNetStatus == device.netStatus) {
//        return GizCompareDeviceProperityAllEqual;
//    }
//    return GizCompareDeviceProperityNetStatusUnEqual;
//}




#pragma mark - lazy load
- (GizWifiRnCallBackManager *)callBackManager{
    if (_callBackManager == nil) {
        self.callBackManager = [[GizWifiRnCallBackManager alloc] init];
        //set delegate
        [GizWifiSDKCache addDelegate:self];
    }
    return _callBackManager;
}

- (NSMutableDictionary<NSString *,NSDictionary *> *)oldDeviceList {
    if (!_oldDeviceList) {
        _oldDeviceList = [NSMutableDictionary dictionary];
    }
    return _oldDeviceList;
}
@end


