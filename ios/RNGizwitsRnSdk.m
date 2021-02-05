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
    NSArray *productInfo = [dict arrayValueForKey:@"productInfo" defaultValue:nil];
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
        [self.callBackManager callbackParamInvalid:result];
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
        [self.callBackManager callbackParamInvalid:result];
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
        [self.callBackManager callbackParamInvalid:result];
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
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    NSInteger thirdAccountType = [dict integerValueForKey:@"thirdAccountType" defaultValue:-1];
    if (thirdAccountType == -1) {
        [self.callBackManager callbackParamInvalid:result];
        return;
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
    [self.callBackManager addResult:result type:GizWifiRnResultTypeUserLogout identity:nil repeatable:NO];
    [[GizWifiSDK sharedInstance] userLogout];
}

RCT_EXPORT_METHOD(requestSendPhoneSMSCode:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    NSString *phone = [dict stringValueForKey:@"phone" defaultValue:@""];
    [[GizWifiSDK sharedInstance] requestSendPhoneSMSCode:phone callback:^(OpenApiResult * _Nonnull apiResult) {
        NSDictionary *resultDic = [NSDictionary makeOpenApiResultDic:apiResult];
        [GizWifiRnCallBackManager callBackWithResultDict:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(resetPassword:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    NSString *username = [dict stringValueForKey:@"username" defaultValue:@""];
    NSString *code = [dict stringValueForKey:@"code" defaultValue:@""];
    NSString *newPassword = [dict stringValueForKey:@"newPassword" defaultValue:@""];
    NSInteger accountType = [dict integerValueForKey:@"accountType" defaultValue:-1];
    if (accountType == -1) {
        [self.callBackManager callbackParamInvalid:result];
        return ;
    }
    [[GizWifiSDK sharedInstance] resetPassword:username verifyCode:code newPassword:newPassword accountType:accountType callback:^(OpenApiResult * _Nonnull apiResult) {
        NSDictionary *resultDic = [NSDictionary makeOpenApiResultDic:apiResult];
        [GizWifiRnCallBackManager callBackWithResultDict:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(changeUserPassword:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    NSString *oldPassword = [dict stringValueForKey:@"oldPassword" defaultValue:@""];
    NSString *newPassword = [dict stringValueForKey:@"newPassword" defaultValue:@""];
    [[GizWifiSDK sharedInstance] changeUserPassword:oldPassword newPassword:newPassword callback:^(OpenApiResult * _Nonnull apiResult) {
        NSDictionary *resultDic = [NSDictionary makeOpenApiResultDic:apiResult];
        [GizWifiRnCallBackManager callBackWithResultDict:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(transAnonymousUser:(id)info result:(RCTResponseSenderBlock)result){
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

    [[GizWifiSDK sharedInstance] transAnonymousUser:username password:password verifyCode:code accountType:accountType callback:^(OpenApiResult * _Nonnull apiResult) {
        NSDictionary *resultDic = [NSDictionary makeOpenApiResultDic:apiResult];
        [GizWifiRnCallBackManager callBackWithResultDict:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(getUserInfo:(RCTResponseSenderBlock)result){
    [[GizWifiSDK sharedInstance] getUserInfo:^(OpenApiResult * _Nonnull apiResult, GizOpenApiUser * _Nullable userInfo) {
        NSDictionary *errorDic = [NSDictionary makeOpenApiResultDic:apiResult];
        NSDictionary *resultDic = nil;
        if (userInfo) {
            resultDic = @{@"user": [NSDictionary makeUserWithProperties:userInfo]};
        }
        [GizWifiRnCallBackManager callBackWithResultDict:errorDic?:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(changePhoneOrEmail:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    NSString *username = [dict stringValueForKey:@"username" defaultValue:@""];
    NSString *code = [dict stringValueForKey:@"code" defaultValue:@""];
    NSInteger accountType = [dict integerValueForKey:@"accountType" defaultValue:-1];
    if (accountType == -1) {
        [self.callBackManager callbackParamInvalid:result];
        return ;
    }

    [[GizWifiSDK sharedInstance] changePhoneOrEmail:username code:code accountType:accountType callback:^(OpenApiResult * _Nonnull apiResult) {
        NSDictionary *resultDic = [NSDictionary makeOpenApiResultDic:apiResult];
        [GizWifiRnCallBackManager callBackWithResultDict:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(changeUserInfo:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    NSInteger language = [dict integerValueForKey:@"language" defaultValue:-1];
    NSInteger userGender = [dict integerValueForKey:@"userGender" defaultValue:-1];
    if (language == -1 || userGender == -1) {
        [self.callBackManager callbackParamInvalid:result];
        return ;
    }
    NSString *username = [dict stringValueForKey:@"username" defaultValue:@""];
    NSString *birthday = [dict stringValueForKey:@"birthday" defaultValue:@""];
    NSString *address = [dict stringValueForKey:@"address" defaultValue:@""];
    NSString *remark = [dict stringValueForKey:@"remark" defaultValue:@""];
    GizOpenApiUser *user = [[GizOpenApiUser alloc] init];
    user.username = username;
    user.birthday = birthday;
    user.address = address;
    user.remark = remark;
    user.language = language;
    user.userGender = userGender;

    [[GizWifiSDK sharedInstance] changeUserInfo:user callback:^(OpenApiResult * _Nonnull apiResult) {
        NSDictionary *resultDic = [NSDictionary makeOpenApiResultDic:apiResult];
        [GizWifiRnCallBackManager callBackWithResultDict:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(bindDevice:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    NSString *mac = [dict stringValueForKey:@"mac" defaultValue:@""];
    NSString *productKey = [dict stringValueForKey:@"productKey" defaultValue:@""];
    NSString *alias = [dict stringValueForKey:@"alias" defaultValue:@""];

    [[GizWifiSDK sharedInstance] bindDevice:mac productKey:productKey alias:alias callback:^(OpenApiResult *apiResult, NSString *did) {
        NSDictionary *errorDic = [NSDictionary makeOpenApiResultDic:apiResult];
        NSDictionary *resultDic = nil;
        if (did) {
            resultDic = @{@"did": did};
        }
        [GizWifiRnCallBackManager callBackWithResultDict:errorDic?:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(bindDeviceByQRCode:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    NSString *QRContent = [dict stringValueForKey:@"QRContent" defaultValue:@""];
    [[GizWifiSDK sharedInstance] bindDeviceByQRCode:QRContent callback:^(OpenApiResult * _Nonnull apiResult) {
        NSDictionary *resultDic = [NSDictionary makeOpenApiResultDic:apiResult];
        [GizWifiRnCallBackManager callBackWithResultDict:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(unbindDevices:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    NSArray *devices = [dict arrayValueForKey:@"devices" defaultValue:nil];
    if (!devices) {
        [self.callBackManager callbackParamInvalid:result];
        return ;
    }
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *deviceDic in devices) {
        NSString *mac =  [deviceDic stringValueForKey:@"mac" defaultValue:@""];
        NSString *did =  [deviceDic stringValueForKey:@"did" defaultValue:@""];
        GizWifiDevice *device = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
        if (device) {
            [arr addObject:device];
        }
    }

    [[GizWifiSDK sharedInstance] unbindDevices:arr callback:^(OpenApiResult * _Nonnull apiResult, NSArray * _Nullable successDids) {
        NSDictionary *errorDic = [NSDictionary makeOpenApiResultDic:apiResult];
        NSDictionary *resultDic = nil;
        if (successDids.count > 0) {
            resultDic = @{@"successDids": successDids};
        }
        [GizWifiRnCallBackManager callBackWithResultDict:errorDic?:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(getBoundDevices:(RCTResponseSenderBlock)result){
    [self.callBackManager addResult:result type:GizWifiRnResultTypeGetBoundDevices identity:nil repeatable:YES];
    [[GizWifiSDK sharedInstance] getBoundDevices];
}

RCT_EXPORT_METHOD(deviceSafetyRegister:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    NSString *gatewayMac = [dict stringValueForKey:@"gatewayMac" defaultValue:@""];
    NSString *gatewayDid = [dict stringValueForKey:@"gatewayDid" defaultValue:@""];
    NSString *productKey = [dict stringValueForKey:@"productKey" defaultValue:@""];
    NSArray *devicesInfo = [dict arrayValueForKey:@"devicesInfo" defaultValue:@[]];

    GizWifiDevice *giz = [GizWifiDeviceCache cachedDeviceWithMacAddress:gatewayMac did:gatewayDid];
    if (productKey.length == 0) {
        [self.callBackManager callbackParamInvalid:result];
    } else {
        [GizWifiSDK deviceSafetyRegister:giz productKey:productKey devicesInfo:devicesInfo];
        [self.callBackManager addResult:result type:GizWifiRnResultTypeDeviceSafetyRegister identity:nil repeatable:NO];
    }
}

RCT_EXPORT_METHOD(deviceSafetyUnbind:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }
    NSArray *devicesInfo=[dict arrayValueForKey:@"devicesInfo" defaultValue:@[]];
    NSMutableArray *devices=[NSMutableArray array];
    for (NSDictionary *deviceDict in devicesInfo) {
        NSString *mac = [deviceDict stringValueForKey:@"mac" defaultValue:@""];
        NSString *did = [deviceDict stringValueForKey:@"did" defaultValue:@""];
        GizWifiDevice *device = [GizWifiDeviceCache cachedDeviceWithMacAddress:mac did:did];
        NSString *authCode = [deviceDict stringValueForKey:@"authCode" defaultValue:@""];
        NSDictionary *newDevice =@{@"device":device,@"authCode":authCode};
        [devices addObject:newDevice];
    }
    [GizWifiSDK deviceSafetyUnbind:devices];
    [self.callBackManager addResult:result type:GizWifiRnResultTypeDeviceSafetyUnbind identity:nil repeatable:NO];
}

RCT_EXPORT_METHOD(channelIDBind:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }
    NSString *channelID = [dict stringValueForKey:@"channelID" defaultValue:@""];
    NSString *alias = [dict stringValueForKey:@"alias" defaultValue:nil];
    NSInteger pushType = [dict integerValueForKey:@"pushType" defaultValue:-1];

    if (pushType == -1) {
        [self.callBackManager callbackParamInvalid:result];
        return ;
    }

    [[GizWifiSDK sharedInstance] channelIDBind:channelID alias:alias pushType:pushType callback:^(OpenApiResult * _Nonnull apiResult) {
        NSDictionary *resultDic = [NSDictionary makeOpenApiResultDic:apiResult];
        [GizWifiRnCallBackManager callBackWithResultDict:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(channelIDUnBind:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }
    NSString *channelID = [dict stringValueForKey:@"channelID" defaultValue:@""];
    [[GizWifiSDK sharedInstance] channelIDUnBind:channelID callback:^(OpenApiResult * _Nonnull apiResult) {
        NSDictionary *resultDic = [NSDictionary makeOpenApiResultDic:apiResult];
        [GizWifiRnCallBackManager callBackWithResultDict:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(getCurrentCloudService:(RCTResponseSenderBlock)result){
    NSDictionary *service = [GizWifiSDK getCurrentCloudService];
    if (result) {
        result(@[[NSNull null], service]);
    }
}

RCT_EXPORT_METHOD(setLogLevel:(id)info){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        return;
    }
    NSInteger logPrintLevel = [dict integerValueForKey:@"logPrintLevel" defaultValue:-1];
    if (logPrintLevel >= 0) {
        [GizWifiSDK setLogLevel:logPrintLevel];
    }
}

RCT_EXPORT_METHOD(getUserTerm:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    NSInteger termType = [dict integerValueForKey:@"termType" defaultValue:-1];
    if (termType == -1) {
        [self.callBackManager callbackParamInvalid:result];
        return ;
    }
    [[GizWifiSDK sharedInstance] getUserTerm:termType callback:^(OpenApiResult * _Nonnull apiResult, NSString * _Nonnull termUrl) {
        NSDictionary *errorDic = [NSDictionary makeOpenApiResultDic:apiResult];
        NSDictionary *resultDic = nil;
        if (termUrl) {
            resultDic = @{@"termUrl": termUrl};
        }
        [GizWifiRnCallBackManager callBackWithResultDict:errorDic?:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(checkUserTerm:(RCTResponseSenderBlock)result){
    [[GizWifiSDK sharedInstance] checkUserTerm:^(OpenApiResult * _Nonnull apiResult, BOOL needToSign, NSArray<GizUserTerm *> * _Nonnull terms) {
        NSDictionary *errorDic = [NSDictionary makeOpenApiResultDic:apiResult];
        NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
        [resultDic setValue:@(needToSign) forKey:@"needToSign"];
        NSMutableArray *termDicArr = [NSMutableArray array];
        for (GizUserTerm *userTerm in terms) {
            [termDicArr addObject:@{@"termType": @(userTerm.termType)}]
        }
        [resultDic setValue:termDicArr forKey:@"terms"];
        [GizWifiRnCallBackManager callBackWithResultDict:errorDic?:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(confirmUserTerm:(id)info result:(RCTResponseSenderBlock)result){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        [self.callBackManager callbackParamInvalid:result];
        return;
    }

    NSArray *terms = [dict arrayValueForKey:@"terms" defaultValue:nil];
    NSMutableArray *termObjs = [NSMutableArray array];
    for (NSDictionary *termDic in terms) {
        NSInteger termType = [termDic integerValueForKey:@"termType" defaultValue:-1];
        if (termType >= 0) {
            GizUserTerm *userTerm = [[GizUserTerm alloc] init];
            userTerm.termType = termType;
            [termObjs addObject:userTerm];
        }
    }

    [[GizWifiSDK sharedInstance] confirmUserTerm:termObjs callback:^(OpenApiResult * _Nonnull apiResult) {
        NSDictionary *resultDic = [NSDictionary makeOpenApiResultDic:apiResult];
        [GizWifiRnCallBackManager callBackWithResultDict:resultDic result:result];
    }];
}

RCT_EXPORT_METHOD(userFeedback:(id)info){
    NSDictionary *dict = [info dictionaryObject];
    if (!dict) {
        return;
    }

    NSString *contactInfo = [dict stringValueForKey:@"contactInfo" defaultValue:@""];
    NSString *feedbackInfo = [dict stringValueForKey:@"feedbackInfo" defaultValue:@""];
    BOOL sendLog = [dict boolValueForKey:@"sendLog" defaultValue:NO];
    [GizWifiSDK userFeedback:contactInfo feedbackInfo:feedbackInfo sendLog:sendLog];
}


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
- (void)wifiSDK:(GizWifiSDK * _Nonnull)wifiSDK didNotifyEvent:(GizEventType)eventType eventSource:(id _Nonnull)eventSource eventID:(GizWifiErrorCode)eventID eventMessage:(NSString* _Nullable)eventMessage {
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
        errDict = [NSDictionary makeErrorDictFromGizError:result];
    }

    [self.callBackManager callBackWithType:GizWifiRnResultTypeSetDeviceOnboardingDeploy identity:nil resultDict:dataDict errorDict:errDict];
}

- (void)wifiSDK:(GizWifiSDK * _Nonnull)wifiSDK didSetDeviceOnboarding:(GizError* _Nonnull)result deviceList:(NSArray <GizWifiDevice*>* _Nullable)deviceList {
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
        errDict = [NSDictionary makeErrorDictFromGizError:result];
    }

    //callback get bound devices
    [self.callBackManager callBackWithType:GizWifiRnResultTypeSetDeviceOnboarding identity:nil resultDict:dataDict errorDict:errDict];
}

- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didDiscovered:(GizError* _Nonnull)result deviceList:(NSArray <GizWifiDevice*>* _Nullable)deviceList {
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
        errDict = [NSDictionary makeErrorDictFromGizError:error];
    }

    //callback get bound devices
    [self.callBackManager callBackWithType:GizWifiRnResultTypeGetBoundDevices identity:nil resultDict:dataDict errorDict:errDict];

    //noti
    [self notiWithType:GizWifiRnResultTypeDeviceListNoti result:errDict ? : dataDict];
}

- (void)wifiSDK:(GizWifiSDK * _Nonnull)wifiSDK didUserLogout:(GizError * _Nonnull)result {
    NSDictionary *errDict = nil;
    if (result.code != GIZ_SDK_SUCCESS) {
        errDict = [NSDictionary makeErrorDictFromGizError:result];
    }

    [self.callBackManager callBackWithType:GizWifiRnResultTypeUserLogout identity:nil resultDict:nil errorDict:errDict];
}

- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didDeviceSafetyRegister:(NSArray* _Nullable)successDevices failedDevices:(NSArray* _Nullable)failedDevices {
    NSDictionary *errDict = nil;
    NSDictionary *dataDict = nil;
    dataDict = [NSMutableDictionary dictionary];
    [dataDict setValue:failedDevices forKey:@"failedDevices"];
    [dataDict setValue:successDevices forKey:@"successDevices"];
    [self.callBackManager callBackWithType:GizWifiRnResultTypeDeviceSafetyRegister identity:nil resultDict:dataDict errorDict:errDict];
}

- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didDeviceSafetyUnbind:(NSArray* _Nullable)failedDevices {
    NSMutableDictionary *resultDic = nil;
    NSMutableArray *devices = [NSMutableArray array];
    for (NSDictionary *failDevice in failedDevices) {
        NSMutableDictionary *deviceDic = [NSMutableDictionary dictionary];
        GizWifiDevice *device = [failDevice valueForKey:@"device"];
        if (device) {
            deviceDic = [NSDictionary makeMutableDictFromDevice:device];
        }
        NSInteger errorCode = [failDevice integerValueForKey:@"errorCode" defaultValue:GIZ_SDK_SUCCESS];
        [deviceDic setValue:@(errorCode) forKey:@"errorCode"];
        [devices addObject:deviceDic];
    }
    resultDic = @{@"failedDevices": devices};
    [self.callBackManager callBackWithType:GizWifiRnResultTypeDeviceSafetyUnbind identity:nil resultDict:resultDic errorDict:nil];

}

#pragma mark - tool
/** 判断列表是否只有netStatus发生了变化 */
- (BOOL)isOnlyNetStatusChangge: (NSArray <GizWifiDevice *>*)newDeviceList {
    if (newDeviceList.count == 0) {
        return NO; // 防止第一次没有推送
    }
    NSMutableArray *deviceArr = [NSMutableArray array];
    if (self.oldDeviceList.count == newDeviceList.count) {
        for (GizWifiDevice *device in newDeviceList) {
            NSDictionary *deviceDic = self.oldDeviceList[device.macAddress];
            if (deviceDic == nil) {
                return NO;
            }
            GizCompareDeviceProperityType type = [self device:device allEqualExceptNetStatus:deviceDic];
            switch (type) {
                case GizCompareDeviceProperityNetStatusUnEqual: {
                    [deviceArr addObject:@{@"device": device, @"deviceDic": deviceDic}];
                    break;
                }
                case GizCompareDeviceProperityUnEqual: {
                    return NO;
                }
                default:
                    break;
            }
        }

        for (NSDictionary *dic in deviceArr) {
            GizWifiDevice *tmpDevice = dic[@"device"];
            NSMutableDictionary *tmpDeviceDic = [NSMutableDictionary dictionaryWithDictionary:dic[@"deviceDic"]];
            tmpDeviceDic[@"netStatus"] = @(tmpDevice.netStatus);
            tmpDeviceDic[@"isOnline"] = @(tmpDevice.isOnline);
            // 更新缓存的列表状态
            [self.oldDeviceList setValue:[tmpDeviceDic copy] forKey:tmpDevice.macAddress];
            // 给所有发生变化的设备推送状态变化
            [GizWifiDeviceCache device:tmpDevice didUpdateNetStatus:tmpDevice.netStatus];
        }
        return YES;
    }
    return NO;
}

/** 判断两个设备对象是否只有netStatus不同 */
- (GizCompareDeviceProperityType)device:(GizWifiDevice *)device allEqualExceptNetStatus: (NSDictionary *)deviceDic {
    NSMutableArray *numberPros = [NSMutableArray arrayWithArray:@[@{@"type": @"productType"}]];
    NSMutableArray *strPros = [NSMutableArray arrayWithArray:@[@{@"mac": @"macAddress"}, @{@"did": @"did"}, @{@"productKey": @"productKey"}, @{@"productName": @"productName"}, @{@"ip": @"ipAddress"}, @{@"remark": @"remark"}, @{@"deviceModuleFirmwareVer": @"deviceModuleFirmwareVer"}, @{@"deviceMcuFirmwareVer": @"deviceMcuFirmwareVer"}, @{@"deviceModuleHardVer": @"deviceModuleHardVer"}, @{@"deviceMcuHardVer": @"deviceMcuHardVer"}]];
    NSMutableArray *boolPros = [NSMutableArray arrayWithArray:@[@{@"isLAN": @"isLAN"}, @{@"isBind": @"isBind"}, @{@"isSubscribed": @"isSubscribed"}]];
    if ([device isMemberOfClass:[GizLiteGWSubDevice class]]) {
        [strPros addObject:@{@"meshID": @"meshID"}];
    } else if ([device isMemberOfClass:[GizWifiBleDevice class]]) {
        [boolPros addObject:@{@"isBlueLocal": @"isBlueLocal"}];
    } else if (device .isLowPower) {
        [boolPros addObject:@{@"isLowPower": @"isLowPower"}];
        [boolPros addObject:@{@"isDormant": @"isDormant"}];
        [numberPros addObject:@{@"stateLastTimestamp": @"stateLastTimestamp"}];
        [numberPros addObject:@{@"sleepDuration": @"sleepDuration"}];
    }

    for (NSDictionary *numberPro in numberPros) {
        NSString *dicKey = numberPro.allKeys.firstObject;
        NSString *deviceKey = [numberPro stringValueForKey:dicKey defaultValue:nil];

        NSInteger dicValue = [deviceDic integerValueForKey:dicKey defaultValue:0];
        NSNumber *deviceValue = [device valueForKey:deviceKey];
        if (dicValue != deviceValue.integerValue) {
            return GizCompareDeviceProperityUnEqual;
        }
    }

    for (NSDictionary *strPro in strPros) {
        NSString *dicKey = strPro.allKeys.firstObject;
        NSString *deviceKey = [strPro stringValueForKey:dicKey defaultValue:nil];
        NSString *dicValue = [deviceDic stringValueForKey:dicKey defaultValue:@""];
        NSString *deviceValue = [device valueForKey:deviceKey];
        if (!deviceValue) {
            deviceValue = @"";
        }
        if (![dicValue isEqualToString:deviceValue]) {
            return GizCompareDeviceProperityUnEqual;
        }
    }

    for (NSDictionary *boolPro in boolPros) {
        NSString *dicKey = boolPro.allKeys.firstObject;
        NSString *deviceKey = [boolPro stringValueForKey:dicKey defaultValue:nil];
        BOOL dicValue = [deviceDic boolValueForKey:dicKey defaultValue:NO];
        NSNumber *deviceValue = [device valueForKey:deviceKey];
        if (dicValue != deviceValue.boolValue) {
            return GizCompareDeviceProperityUnEqual;
        }
    }

    NSString *dicRootDevice = [deviceDic stringValueForKey:@"rootDeviceId" defaultValue: @""];
    NSString *deviceRootDevice = (device.rootDevice == nil ? @"" : device.rootDevice.did);
    if (![dicRootDevice isEqualToString:deviceRootDevice]) {
        return GizCompareDeviceProperityUnEqual;
    }

    GizWifiDeviceNetStatus dicNetStatus = [deviceDic integerValueForKey:@"netStatus" defaultValue:GizDeviceOffline];
    if (dicNetStatus == device.netStatus) {
        return GizCompareDeviceProperityAllEqual;
    }
    return GizCompareDeviceProperityNetStatusUnEqual;
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

- (NSMutableDictionary<NSString *,NSDictionary *> *)oldDeviceList {
    if (!_oldDeviceList) {
        _oldDeviceList = [NSMutableDictionary dictionary];
    }
    return _oldDeviceList;
}


//RCT_EXPORT_METHOD(getBoundBleDevice:(RCTResponseSenderBlock)result){
//    NSArray *bleDevices = [[GizWifiSDK sharedInstance] getBoundBleDevice];
//    if (!bleDevices) {
//        bleDevices = [NSArray array];
//    }
//    if (result) {
//        result(@[[NSNull null], bleDevices]);
//    }
//}

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

@end


