//
//  GizWifiSDK.h
//  GizWifiSDK
//
//  Created by Tom on 15/7/9.
//  Copyright (c) 2015年 gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GizWifiSDK/GizWifiDefinitions.h>
#import <GizWifiSDK/GizWifiSSID.h>
#import <GizWifiSDK/GizDeviceOTA.h>
#import <GizWifiSDK/GizWifiDevice.h>
#import <GizWifiSDK/GizLiteGWSubDevice.h>
#import <GizWifiSDK/GizUserTerm.h>
#import <GizWifiSDK/GizTool.h>
#import <GizWifiSDK/GizOpenApiUser.h>
#import <GizWifiSDK/OpenApiLoginResult.h>
#import <GizWifiSDK/GizScheduler.h>
#import <GizWifiSDK/GizSchedulerManager.h>

@class GizWifiSDK;
@class GizLiteGWSubDevice;

/**
 GizWifiSDKDelegate 是 GizWifiSDK 类的委托协议，为APP开发者处理设备配置和发现、设备分组、用户登录和注册提供委托函数。
*/
@protocol GizWifiSDKDelegate <NSObject>
@optional

/**
 SDK系统事件通知
 @param wifiSDK 回调的 GizWifiSDK 单例
 @param eventType 事件类型。指明发生了哪一类的事件，详细见 GizEventType 枚举定义
 @param eventSource 事件源，指是谁触发的事件。

 如果eventType是GizEventSDK，eventSource为nil；
 如果是GizEventDevice，eventSource需要强制转换为GizWifiDevice类型再使用；
 如果是GizEventM2Mservice或者GizEventToken，eventSource需要强制转换为NSString类型再使用

 @param eventID 事件ID。代表事件编号，详细见 GizWifiErrorCode 枚举定义。该参数指出 eventSource 发生了什么事
 @param eventMessage 事件ID的消息描述
 @see GizEventType
 @see GizWifiErrorCode
*/
- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didNotifyEvent:(GizEventType)eventType eventSource:(id _Nonnull)eventSource eventID:(GizWifiErrorCode)eventID eventMessage:(NSString* _Nullable)eventMessage;

/**
 设备配置结果的回调接口
 @param wifiSDK 为回调的 GizWifiSDK 单例
 @param result 配置成功或失败。如果配置失败，其他参数为nil
 @param device 配网成功的设备对象
 @note 注意：如果调用getBoundDevices接口时指定了待筛选的 productKey 集合，如果设备被成功配置到路由上了，会返回配置成功，但不会出现在设备列表中
 @see 触发函数：[GizWifiSDK setDeviceOnboardingDeploy:key:configMode:softAPSSIDPrefix:timeout:wifiGAgentType:]
 @see GizWifiErrorCode
*/
- (void)wifiSDK:(GizWifiSDK * _Nonnull)wifiSDK didSetDeviceOnboarding:(GizError * _Nonnull)result device:(GizWifiDevice * _Nullable)device;

/**
持续获取局域网内未绑定设备的回调接口
@param wifiSDK 为回调的 GizWifiSDK 单例
@param result 获取成功或失败，
@param deviceList 设备 mac 地址
@see 触发函数：[GizWifiSDK setDeviceOnboarding:]
@see GizWifiErrorCode
*/
- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didSetDeviceOnboarding:(GizError* _Nonnull)result deviceList:(NSArray <GizWifiDevice*>* _Nullable)deviceList;

/**
 设备列表上报的回调接口
 @param wifiSDK 回调的 GizWifiSDK 单例
 @param result 详细见 GizWifiErrorCode 枚举定义，result.code 为 GIZ_SDK_SUCCESS 表示成功。result.code 为失败的错误码时，deviceList 为非 nil 集合
 @param deviceList GizWifiDevice 实例组成的数组，该参数将只返回根据指定productKey筛选过的设备集合。productKey在 启动接口指定
 @note 该回调接口，在不调用getBoundDevices时也可能会由SDK主动触发，主动触发是由于SDK发现设备列表发生了变化，此时错误码GIZ_SDK_SUCCESS；
 getBoundDevices接口调用时会触发该回调，错误码代表云端请求状态，设备列表是绑定设备与局域网设备合并之后的集合；
 @see 触发函数：[GizWifiSDK getBoundDevices:token:specialProductKeys:]
 @see GizWifiErrorCode
*/
- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didDiscovered:(GizError* _Nonnull)result deviceList:(NSArray <GizWifiDevice*>* _Nullable)deviceList;

/**
 设备安全注册回调接口。注册多个设备时，注册成功和注册失败的设备会分别在回调的两个参数中返回
 @param successDevices 注册成功的设备信息，NSDictionary数组，nil表示无注册成功的设备。格式如下：
 [{mac:"xxx", productKey:"xxx", did:"xxx"},  ...]
 mac 注册成功的设备mac，NSString类型
 productKey 注册成功的设备产品类型标识，NSString类型
 did 注册成功的设备唯一标识，NSString类型
 @param failedDevices 注册失败的设备信息，NSDictionary数组，nil表示无注册失败的设备。格式如下：
 [{mac:"xxx", productKey:"xxx", errorCode:"xxx"},  ...]
 mac 注册失败的设备mac，NSString类型
 productKey 注册失败的设备产品类型标识，NSString类型
 errorCode 失败的错误码，NSNumber类型
 @see 触发函数 [GizWifiSDK deviceSafetyRegister:productKey:devicesInfo:]
 @see 枚举 GizWifiErrorCode
*/
- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didDeviceSafetyRegister:(NSArray* _Nullable)successDevices failedDevices:(NSArray* _Nullable)failedDevices;

/**
 设备安全解绑回调接口。同时解绑多个设备时，若全部解绑成功则回调参数为nil
 @param failedDevices 解绑失败的设备，NSDictionary数组，nil表示全部解绑成功。字典格式如下：
 [{device:xxx, errorCode:xxx},  ...]
 device 解绑失败的设备对象，GizWifiDevice类型
 errorCode 失败的错误码，NSNumber类型，见GizWifiErrorCode枚举定义
 @see 触发函数 [GizWifiSDK deviceSafetyUnbind:]
 @see GizWifiErrorCode
*/
- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didDeviceSafetyUnbind:(NSArray* _Nullable)failedDevices;

/**
 退出登录回调
 @param wifiSDK 为回调的 GizWifiSDK 单例
 @param result 详细见 GizWifiErrorCode 枚举定义。result.code 为 GIZ_SDK_SUCCESS 表示成功，其他为失败。失败时，其他回调参数为 nil
 @see 触发函数 [GizWifiSDK userLogout]
 */
- (void)wifiSDK:(GizWifiSDK * _Nonnull)wifiSDK didUserLogout:(GizError * _Nonnull)result;

/**
 设置uid和token接口回调
 @param wifiSDK 为回调的 GizWifiSDK 单例
 @param result 详细见 GizWifiErrorCode 枚举定义。result.code 为 GIZ_SDK_SUCCESS 表示成功，其他为失败。失败时，其他回调参数为 nil
 @see 触发函数 [GizWifiSDK setUid:token:]
 */
- (void)wifiSDK:(GizWifiSDK * _Nonnull)wifiSDK didSetUid:(GizError * _Nonnull)result;

/**
 禁用/启用小循环的结果
 @param wifiSDK 为回调的 GizWifiSDK 单例
 @param result 详细见 GizWifiErrorCode 枚举定义。result.code 为 GIZ_SDK_SUCCESS 表示成功，其他为失败。失败时，其他回调参数为 nil
 @see 触发函数：[GizWifiSDK disableLAN:]
*/
- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didDisableLAN:(GizError* _Nonnull)result;

/**
 获取可以设置域名的设备列表的回调接口
 @param wifiSDK 回调的 GizWifiSDK 单例
 @param result 获取成功或失败。如果获取失败，其他参数为nil
 @param devices 设备信息字典组成的数组。设备信息的字典格式如下：
 {
 “mac”: “xxx” // 设备mac地址
 “productKey”: “xxx” // 设备的productKey
 “domain”: “xxx” // 设备的域名信息
 }
 @note 该回调接口只返回设备的mac、productKey、domain这三个信息，不返回设备对象
 @see 触发函数：[GizWifiSDK getDevicesToSetServerInfo]
*/
- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didGetDevicesToSetServerInfo:(GizError* _Nonnull)result devices:(NSArray <NSDictionary <NSString*, NSString*>*>* _Nullable)devices;

/**
 给模组设置域名的回调接口
 @param wifiSDK 回调的 GizWifiSDK 单例
 @param result 详细见 GizWifiErrorCode 枚举定义。GIZ_SDK_SUCCESS 表示成功，其他为失败
 @param mac 设置域名的设备 mac
 @see 触发函数：[GizWifiSDK setDeviceServerInfo:mac:]
*/
- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didSetDeviceServerInfo:(GizError* _Nonnull)result mac:(NSString* _Nullable)mac;

/**
 获取设备周围Wi-Fi热点列表的回调接口
 @param wifiSDK 回调的 GizWifiSDK 单例
 @param result 详细见 GizWifiErrorCode 枚举定义。result.code 为 GIZ_SDK_SUCCESS 表示成功，其他为失败。失败时，ssidList为 nil
 @param ssidList 为若干 GizWifiSSID 实例组成的 SSID 信号列表
 @see 触发函数：[GizWifiSDK getSSIDList]
 @see GizWifiErrorCode
*/
- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didGetSSIDList:(GizError* _Nonnull)result ssidList:(NSArray <GizWifiSSID*>* _Nullable)ssidList;

/**
 获取设备日志的回调接口

 @param wifiSDK 为回调的 GizWifiSDK 单例
 @param result 获取设备日志结果，若返回GIZ_SDK_GET_DEVICE_LOG_STOPPED，说明获取设备日志结束；
 @param mac 日志对应的设备mac地址
 @param timestamp 日志产生的时间，可能为0
 @param logSN 日志序号，便于结合时间戳查看日志产生顺序
 @param log 日志内容
 @see 触发函数：[GizWifiSDK getDeviceLog:]
*/
- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didReceiveDeviceLog:(GizError* _Nonnull)result  mac:(NSString* _Nullable)mac timestamp:(NSInteger)timestamp logSN:(NSInteger)logSN log:(NSString* _Nullable)log;


/**
 获取日志映射文件的回调接口

 @param wifiSDK 为回调的 GizWifiSDK 单例
 @param result 详细见 GizWifiErrorCode 枚举定义。result.code 为 GIZ_SDK_SUCCESS 表示成功，其他为失败。
 @see 触发函数：[GizWifiSDK getMapTab]
*/
- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didGetMapTab:(GizError* _Nonnull)result;

/**
 @param result 详细见 GizWifiErrorCode 枚举定义。GIZ_SDK_SUCCESS 表示成功，其他为失败。失败时，deviceList 大小为 0
 @param meshDeviceList mesh设备列表，NSDictionary数组。格式：[{"mac":"xxx", "meshID": "xxx", "advData":"xxx"}]
 @see 触发函数 [GizWifiSDK searchMeshDevice:]
*/
- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didDiscoveredMeshDevices:(GizError* _Nullable)result meshDeviceList:(NSArray* _Nonnull)meshDeviceList;

/**
 @param meshDeviceInfo 切网成功，返回新的设备信息,切网失败，返回原来的设备信息, NSDictionary类型 {"mac":"xxx", "meshID": "xxx"}
 @param result 详细见 GizWifiErrorCode 枚举定义。GIZ_SDK_SUCCESS 表示成功，其他为失败
 @see 触发函数 [GizWifiSDK changeDeviceMesh:newMeshID:]
*/
- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didChangeDeviceMesh:(NSDictionary* _Nonnull)meshDeviceInfo result:(GizError* _Nullable)result;

/**
 @param  mac  返回恢复出厂设置成功的设备mac地址
 @param result 详细见 GizWifiErrorCode 枚举定义。GIZ_SDK_SUCCESS 表示成功，其他为失败
 @see 触发函数 [GizWifiSDK restoreDeviceFactorySetting:]
*/
- (void)wifiSDK:(GizWifiSDK* _Nonnull)wifiSDK didRestoreDeviceFactorySetting:(NSString* _Nullable)mac result:(GizError* _Nullable)result;

@end

/**
 GizWifiSDK类为APP开发者提供设备配置和发现、设备分组、用户登录和注册函数
*/
@interface GizWifiSDK : NSObject

/**
 使用委托获取对应事件。GizWifiSDK 对应的回调接口在 GizWifiSDKDelegate 定义。需要用到哪个接口，回调即可
*/
@property (weak, nonatomic) id <GizWifiSDKDelegate>_Nullable delegate;

/**
 NSArray类型，为 GizWifiDevice 对象数组。设备列表缓存，APP 访问该变量即可得到当前 GizWifiSDK 发现的设备列表
*/
@property (strong, nonatomic, readonly) NSArray <GizWifiDevice*>* _Nullable deviceList;


- (instancetype _Nullable)init NS_UNAVAILABLE;

/**
 获取GizWifiSDK单例的实例
 @return 返回初始化后 SDK 唯一的实例。SDK 不管有没有初始化，都会返回一个有效的值。
*/
+ (instancetype _Nonnull)sharedInstance;

#pragma mark - SDK初始化
/**
 初始化SDK
 该接口执行后，其他接口功能才能正常执行。如果已经设置了delegate，SDK会立即通过didDiscovered上报发现的设备。
 如果App要做域名切换和设备过滤，请在初始化SDK时就指定好域名和产品信息。
 如果需要设置设备连接的云服务域名，可以在该接口调用时开启自动设置功能。SDK会为所有已与AppID关联的设备设置域名，支持域名设置的设备会与App连接到同一个云服务域名上。但该接口默认是不开启此功能的。
 注意：设备域名自动设置开启后会一直生效，但调用setDeviceServerInfo接口时将会终止自动设置
 
 @param appInfo 应用信息，格式：{"appId": "xxx", "appSecret": "xxx"}。此参数不能填nil，appId和appSecret必须为有效值。在机智云开发者中心 dev.gizwits.com 中，每个注册的设备在对应的“应用配置”中，都能够查到对应的 appID和appSecret
 @param productInfo 产品信息数组，格式：[{"productKey": "xxx", "productSecret": "xxx"]，此参数为选填，如果填写了此参数，需保证productKey和productSecret为有效值，无效值会被忽略。SDK会根据此参数过滤设备列表
 @param cloudSeviceInfo 服务器域名信息，格式：{"appApi": "xxx", "push": "xxx"}。如果使用机智云统一部署的云服务域名，此参数填nil，此时将根据用户手机的地理位置信息使用匹配的域名。如果需要独立部署，此参数必须指定域名信息。如果需要指定端口号，可指定Http端口如：xxx.gizwits.com:80，或同时指定Http和Https端口如：xxx.gizwits.com:80&443。不指定端口号时，形如：xxx.gizwits.com
 @see 回调 [GizWifiSDKDelegate wifiSDK:didNotifyEvent:eventSource:eventID:eventMessage:]
*/
+ (void)startWithAppInfo:(NSDictionary <NSString*, NSString*>* _Nonnull)appInfo productInfo:(NSArray <NSDictionary <NSString*, NSString*>*>* _Nullable)productInfo cloudServiceInfo:(NSDictionary <NSString*, NSString*>* _Nullable)cloudSeviceInfo;

/**
 获取 SDK 版本号
 @return 返回当前 SDK 的版本号码
*/
+ (NSString* _Nonnull)getVersion;

/**
获取 手机的唯一标志码
*/
+ (NSString* _Nullable)getPhoneID;

/**
 禁用/启用小循环
 @param disabled YES=禁用小循环，NO=启用小循环
 @see 对应的回调接口：[GizWifiSDKDelegate wifiSDK:didDisableLAN:]
*/
+ (void)disableLAN:(BOOL)disabled;


#pragma mark - 设备配网相关
/**
 设备配网接口。
 配网时可自动完成设备域名部署，此接口对模组固件版本向前兼容。
 设备处于 softap 模式时，模组会产生一个热点名称，手机 wifi 连接此热点后就可以配置了。如果是机智云提供的固件，模组热点名称前缀为"XPG-GAgent-"，密码为"123456789"或无密码。设备处于 airlink 模式时，手机随时都可以开始配置
 配网时，若检测到手机的配网wifi为5G路由，会通过didNotifyEvent回调通知App，回调中的eventID为8319
 @param ssid 待配置的路由SSID名。此参数不能为nil
 @param key 待配置的路由密码。此参数不能为nil
 @param mode 配置模式，详细见GizWifiConfigureMode枚举定义。此参数必须填有效范围内的值
 @param softAPSSIDPrefix 热点模式下设备热点前缀或全名。默认前缀为:XPG-GAgent-，SDK以此判断手机当前是否连上了设备的热点。AirLink模式下可传nil
 @param timeout 配网绑定的超时时间，默认超时时间为30秒。在超时时间内如果无法配置和绑定会回调配网失败
 @param types 待配置的模组类型数组，详细见GizWifiGAgentType枚举。默认类型为GizGAgentESP。如果在模组类型中找不到自己使用的模组，可传GizGAgentOther
 @see 回调函数 [GizWifiSDKDelegate wifiSDK:didSetDeviceOnboarding:device:]
*/
- (void)setDeviceOnboardingDeploy:(NSString* _Nonnull)ssid key:(NSString* _Nullable)key configMode:(GizWifiConfigureMode)mode softAPSSIDPrefix:(NSString* _Nullable)softAPSSIDPrefix timeout:(int)timeout wifiGAgentType:(NSArray <NSNumber*>* _Nullable)types;

/**
持续获取局域网内未绑定的设备， 直到timeout结束， 回调GIZ_SDK_DEVICE_CONFIG_TIMEOUT错误码，表示获取结束
@see 对应的回调接口 [GizWifiSDKDelegate wifiSDK:didSetDeviceOnboarding:deviceList:]
*/
- (void)setDeviceOnboarding:(int)timeout;

/**
 停止配网接口
 停止后回调中返回的错误为GIZ_SDK_ONBOARDING_STOPPED
 @see 回调函数 [GizWifiSDKDelegate wifiSDK:didSetDeviceOnboarding:device:]
 @see 回调函数 [GizWifiSDKDelegate wifiSDK:didSetDeviceOnboarding:deviceList:]
*/
- (void)stopDeviceOnboarding;

/**
  在 Soft-AP 模式时,获得设备的 SSID 列表
  SSID列表通过异步回调方式返回
 @see 对应的回调接口：[GizWifiSDKDelegate wifiSDK:didGetSSIDList:ssidList:]
*/
- (void)getSSIDList;

/**
    不发布（仅智家)
    @param ssid 待配置的路由SSID名。此参数不能为nil
    @param key 待配置的路由密码。此参数不能为nil
    @param softAPSSIDPrefix 热点模式下设备热点前缀或全名。默认前缀为:XPG-GAgent-，SDK以此判断手机当前是否连上了设备的热点。
    @param timeout 配网绑定的超时时间，默认超时时间为30秒。在超时时间内如果无法配置和绑定会回调配网失败
    @param types 待配置的模组类型数组，详细见GizWifiGAgentType枚举。默认类型为GizGAgentESP。如果在模组类型中找不到自己使用的模组，可传GizGAgentOther
    @see 回调函数 [GizWifiSDKDelegate wifiSDK:didSetDeviceOnboarding:mac:did:productKey:]
*/
- (void)deviceOnboardingSoftap:(NSString* _Nonnull)ssid key:(NSString* _Nonnull)key softAPSSIDPrefix:(NSString* _Nullable)softAPSSIDPrefix timeout:(int)timeout wifiGAgentType:(NSArray <NSNumber*>* _Nullable)types;

#pragma mark - 用户相关
/**
 设置用户uid和token
 @param uid 用户登录或注册时得到的 uid
 @param token 用户登录或注册时得到的 token
 @see 回调函数 [GizWifiSDKDelegate wifiSDK:didSetUid:]
*/
- (void)setUid:(NSString* _Nonnull)uid token:(NSString* _Nonnull)token;

/**
 匿名登录。
 匿名方式登录，不需要注册用户账号
 @param callback 登录结果回调
*/
- (void)userLoginAnonymous:(void (^ _Nullable)(OpenApiLoginResult* _Nonnull result))callback;

/**
 用户注册。
 需指定用户类型注册。手机用户的用户名是手机号，邮箱用户的用户名是邮箱、普通用户的用户名可以是普通用户名
@param username 注册用户名（可以是手机号、邮箱或普通用户名）
@param password 注册密码
@param code 手机短信验证码。短信验证码注册后就失效了，不能被再次使用
@param accountType 用户类型，详细见 GizUserAccountType 枚举定义。注册手机号时，此参数指定为手机用户，注册邮箱时，此参数指定为邮箱用户，注册普通用户名时，此参数指定为普通用户
@param callback 注册结果回调
*/
- (void)registerUser:(NSString* _Nonnull)username password:(NSString* _Nonnull)password verifyCode:(NSString* _Nullable)code accountType:(GizUserAccountType)accountType callback:(void (^ _Nullable)(OpenApiLoginResult* _Nonnull result))callback;

/**
 用户登录。
 需使用注册成功的用户名、密码进行登录，可以是手机用户名、邮箱用户名或普通用户名
@param username 登录用户名
@param password 登录密码
@param callback 登录结果回调
*/
- (void)userLogin:(NSString* _Nonnull)username password:(NSString* _Nonnull)password callback:(void (^ _Nullable)(OpenApiLoginResult* _Nonnull result))callback;

/**
 动态验证码登录。
 登录用户名为手机号，以手机收到的登录验证码登录
 @param phone 手机号
 @param code 登录验证码
 @param callback 登录结果回调
*/
- (void)dynamicLogin:(NSString* _Nonnull)phone code:(NSString* _Nonnull)code callback:(void (^ _Nullable)(OpenApiLoginResult* _Nonnull result))callback;

/**
第三方账号登录（第三方接口登录方式）
@param thirdAccountType 第三方账号类型，详细见 GizThirdAccountType 枚举定义
@param uid 通过第三方平台 api 方式登录后得到的 uid
@param token 通过第三方平台api方式 登录后得到的 token
@param tokenSecret twitter登录需要传该值
@param callback 登录结果回调
*/
- (void)userLoginWithThirdAccount:(GizThirdAccountType)thirdAccountType uid:(NSString* _Nonnull)uid token:(NSString* _Nonnull)token tokenSecret:(NSString* _Nullable)tokenSecret callback:(void (^ _Nullable)(OpenApiLoginResult* _Nonnull result))callback;

/**
 注销用户登录
 @see 回调函数 [GizWifiSDKDelegate wifiSDK:didUserLogout:]
 */
- (void)userLogout;

/**
通过手机号请求短信验证码
@param phone 手机号
@param callback 请求结果回调
*/
- (void)requestSendPhoneSMSCode:(NSString* _Nonnull)phone callback:(void (^ _Nullable)(OpenApiResult* _Nonnull result))callback;

/**
重置密码
@param username 待重置密码的手机号或邮箱
@param code 重置手机用户密码时需要使用手机短信验证码（通过 requestSendPhoneSMSCode 方法获取）
@param newPassword 新密码
@param accountType 用户类型，详细见 GizThirdAccountType 枚举定义。待重置密码的用户名是手机号时，此参数指定为手机用户，待重置密码的用户名是邮箱时，此参数指定为邮箱用户
@param callback 重置密码结果回调
*/
- (void)resetPassword:(NSString* _Nonnull)username verifyCode:(NSString* _Nullable)code newPassword:(NSString* _Nonnull)newPassword accountType:(GizUserAccountType)accountType callback:(void (^ _Nullable)(OpenApiResult* _Nonnull result))callback;

/**
 修改用户密码
 @param oldPassword 旧密码
 @param newPassword 新密码
 @param callback 修改密码结果回调
*/
- (void)changeUserPassword:(NSString* _Nonnull)oldPassword newPassword:(NSString* _Nonnull)newPassword callback:(void (^ _Nullable)(OpenApiResult* _Nonnull result))callback;


/**
 匿名用户转换
 可转换为手机用户或者普通用户。注意，待转换的帐号必须是还未注册过的
 @param username 待转换用户的普通账号或手机号
 @param password 待转换用户的密码
 @param code 转换为手机用户时需要使用手机短信验证码
 @param accountType 用户类型，详细见 GizThirdAccountType 枚举定义。待转换的用户名是手机号时，此参数指定为GizUserPhone，待转换用户名是普通账号时，此参数指定为GizUserNormal
 @param callback 转换结果回调
*/
- (void)transAnonymousUser:(NSString* _Nonnull)username password:(NSString* _Nonnull)password verifyCode:(NSString* _Nullable)code accountType:(GizUserAccountType)accountType callback:(void (^ _Nullable)(OpenApiResult* _Nonnull result))callback;

/**
获取用户信息
@param callback  获取用户信息回调
*/
- (void)getUserInfo:(void (^ _Nullable)(OpenApiResult* _Nonnull result, GizOpenApiUser*_Nullable userInfo))callback;

/**
 修改账号，只能支持修改手机号或邮箱
 @param username 待修改的手机号或邮箱
 @param code 修改手机号时要使用的手机短信验证码
 @param accountType 用户类型，详细见 GizThirdAccountType
 */
- (void)changePhoneOrEmail:(NSString * _Nonnull)username code:(NSString * _Nullable)code accountType:(GizUserAccountType)accountType callback:(void (^ _Nullable)(OpenApiResult * _Nonnull result))callback;

/**
修改用户个人信息。
@param additionalInfo 待修改的个人信息，详细见 GizUserInfo 类定义。如果只修改个人信息，需要指定token，username、code填null
@param callback 修改用户个人信息回调
*/
- (void)changeUserInfo:(GizOpenApiUser * _Nonnull)additionalInfo callback:(void (^ _Nullable)(OpenApiResult * _Nonnull result))callback;

#pragma mark - 设备相关
/**
 根据mac绑定设备
 @param mac 待绑定设备的mac
 @param productKey 待绑定设备的productKey
 @param alias 待绑定设备的别名，可传空
 @param callback 绑定设备回调
*/
- (void)bindDevice:(NSString* _Nonnull)mac productKey:(NSString* _Nonnull)productKey alias:(NSString* _Nullable)alias callback:(void (^ _Nullable)(OpenApiResult* _Nonnull result, NSString* _Nullable did))callback;

/**
 根据二维码绑定设备到服务器
 @param QRContent 二维码内容。二维码需联系机智云FAE提供
 @param callback  绑定结果回调
*/
- (void)bindDeviceByQRCode:(NSString* _Nonnull)QRContent callback:(void (^ _Nullable)(OpenApiResult* _Nonnull result))callback;

/**
 从服务器解绑设备
 @param devices 设备对象数组
 @param callback  解绑结果回调
*/
- (void)unbindDevices:(NSArray <GizWifiDevice *>* _Nonnull)devices callback:(void (^ _Nullable)(OpenApiResult* _Nonnull result, NSArray* _Nullable successDids))callback;

/**
 获取绑定设备列表。
 在不同的网络环境下，有不同的处理：
 当手机能访问外网时，该接口会向云端发起获取绑定设备列表请求；
 当手机不能访问外网时，局域网设备是实时发现的，但会保留之前已经获取过的绑定设备；
 手机处于无网模式时，局域网未绑定设备会消失，但会保留之前已经获取过的绑定设备；
 @see 对应的回调接口：[GizWifiSDKDelegate wifiSDK:didDiscovered:deviceList:]
*/
- (void)getBoundDevices;

/**
 设备安全注册接口。
 向云端加密注册设备，注册成功时返回设备did，同时如果用户已登录则会自动绑定已注册成功的设备，绑定成功的设备会主动触发设备列表更新。需注意，安全注册需要productKey和productSecret，这两个信息应在startWithAppInfo接口参数productInfo的指定范围内
 @param gateway 设备的代理网关，此参数选填。若要注册的设备不需要代理网关，此参数可传null
 @param productKey 设备的产品类型识别码，此参数必填。若填入的productKey不在启动接口参数productInfo的指定范围将不会向云端注册
 @param devicesInfo 要注册的设备信息，可同时传多组设备信息，格式如下：
 [{mac:"xxx", meshID:"xxx", alias:"xxx", authCode:"xxx"},  ...]
 mac 设备物理唯一标识，最大32字符长度，字符串类型。必填
 meshID 设备组网ID，最大256字符长度。必填
 alias 设备别名，最大128字符长度，String类型。选填
 authCode 设备注册的授权码，32字符长度，由开发者自定义生成，字符串类型。选填
 @see 回调 [GizWifiSDKDelegate wifiSDK:didDeviceSafetyRegister:failedDevices:]
*/
+ (void)deviceSafetyRegister:(GizWifiDevice* _Nullable)gateway productKey:(NSString* _Nonnull)productKey devicesInfo:(NSArray<NSDictionary*>* _Nonnull)devicesInfo;

/**
 设备安全解绑接口。
 此接口会在云端把设备的所有关联用户都解绑，可同时解绑多个相同产品类型的设备。但如果设备的产品类型（productKey）不一致将不会解绑任何设备
 @param devicesInfo 要解绑的设备信息，格式：[{"device": device, "authCode": "xxx"}]，device为GizWifiDevice对象，authCode为授权码。authCode不是必填参数，若没有授权码则不需要填写此字段
 @see 回调 [GizWifiSDKDelegate wifiSDK:didDeviceSafetyUnbind:]
*/
+ (void)deviceSafetyUnbind:(NSArray<NSDictionary*>* _Nonnull)devicesInfo;

#pragma mark - 消息推送相关接口
/**
 绑定推送的id
 @param channelID 推送ID
 @param alias 别名  该字段在极光推送中使用,
 @param pushType 推送类型，详细见 GizPushType 枚举定义
 @param callback 绑定推送回调
*/
- (void)channelIDBind:(NSString* _Nullable)channelID alias:(NSString* _Nullable)alias pushType:(GizPushType)pushType callback:(void (^ _Nullable)(OpenApiResult* _Nonnull result))callback;

/**
 解绑推送的id
 @param channelID 推送ID
 @param callback 解绑推送回调
*/
- (void)channelIDUnBind:(NSString* _Nonnull)channelID callback:(void (^ _Nullable)(OpenApiResult* _Nonnull result))callback;


#pragma mark - 域名相关接口
/**
 获取当前的服务器
*/
+ (NSDictionary* _Nonnull)getCurrentCloudService;

#pragma mark - 日志相关
/**
 设置日志输出级别。
 该级别指日志在调试终端的输出级别，默认是全部输出的
 @param logPrintLevel 日志输出级别，参考 GizLogPrintLevel 定义
*/
+ (void)setLogLevel:(GizLogPrintLevel)logPrintLevel;

/**
 设置日志加密。
 此接口无回调。App若要设置日志加密，需要在调用sdk启动接口之前调用此接口。加密后，日志将不再输出到调试终端上
*/
+ (void)encryptLog;

/**
 获取设备日志。
 需要先连接上设备的热点才可以调用该接口
 @param softAPSSIDPrefix 设备SoftAP模式下的SSID前缀或全名。当传空的情况，只要手机连接了WiFi，便默认为连接上了设备的热点；传非空的情况，将用来与当前连接的热点前缀匹配，匹配得上才认为连接上了设备热点
 @see 回调 [GizWifiSDKDelegate wifiSDK:didReceiveDeviceLog:mac:timestamp:logSN:log:]
*/
+ (void)getDeviceLog:(NSString* _Nullable)softAPSSIDPrefix;

/**
  获取日志映射文件
 
  @see 回调 [GizWifiSDKDelegate wifiSDK:didGetMapTab:]
*/
+ (void)getMapTab;

#pragma mark - 协议相关接口
/**
 获取用户协议内容
 @param termType 协议类型
 @param callback 请求回调
*/
- (void)getUserTerm:(GizUserTermType)termType callback:(void (^ _Nonnull)(OpenApiResult* _Nonnull result, NSString* _Nullable termUrl))callback;

/**
检查用户协议
 @param callback 请求回调 needToSign:返回是否确认过用户协议， YES: 没确认 NO: 已确认
*/
- (void)checkUserTerm:(void (^ _Nonnull)(OpenApiResult* _Nonnull result, BOOL needToSign, NSArray<GizUserTerm*>* _Nullable terms))callback;

/**
确认用户协议
@param terms 协议类型数组
@param callback 请求回调
*/
- (void)confirmUserTerm:(NSArray<GizUserTerm*>* _Nonnull)terms callback:(void (^ _Nonnull)(OpenApiResult* _Nonnull result))callback;

#pragma mark - 用户反馈
/**
 用户反馈
 此接口无回调。调用后就会上传信息
 @param contactInfo 用户的联系方式。此参数为选填
 @param feedbackInfo 用户反馈的信息。此参数为选填
 @param sendLog 是否发送问题日志。如果前面两个参数都没填，则默认发送问题日志
*/
+ (void)userFeedback:(NSString* _Nullable)contactInfo feedbackInfo:(NSString* _Nullable)feedbackInfo sendLog:(BOOL)sendLog;

@end

