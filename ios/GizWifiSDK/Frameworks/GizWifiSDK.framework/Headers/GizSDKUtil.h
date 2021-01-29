//
//  GizSDKUtil.h
//  GizWifiSDK
//
//  Created by danlypro on 2020/7/23.
//  Copyright © 2020 gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 日志相关 */
#define GizSDKClient_LOG_API_FUNC(fmt, args...)  GizSDKClientPrint(GIZ_SDK_CLIENT_LOG_TYPE_API, "[SYS][DEBUG][%s][%s:%d %s][" fmt"]", GizSDKClientTimeStr(), result->filename, result->line, result->function, ##args)

#define GizSDK_LOG_METHOD_START() \
GizSDKClient_LOG_API("Start => ")

#define GizSDK_LOG_METHOD_BEGIN_DEPRECATED(fmt, args...) \
GizSDKClient_LOG_API("Start => <deprecated>" fmt"", ##args)

#define GizSDK_LOG_METHOD_END_DEPRECATED() \
GizSDKClient_LOG_API("End <= <deprecated>")

#define GizSDK_LOG_METHOD_BEGIN(fmt, args...) \
GizSDKClient_LOG_API("Start => " fmt"", ##args)

#define GizSDK_LOG_METHOD_END() \
GizSDKClient_LOG_API("End <=")

#define GizSDK_LOG_CALLBACK_BEGIN(x) \
GizSDKClient_LOG_API_FUNC("Callback begin => delegate: %s<%p>", NSStringFromClass([x class]).UTF8String, x)

#define GizSDK_LOG_CALLBACK_START() \
GizSDKClient_LOG_API_FUNC("Callback begin")

#define GizSDK_LOG_CALLBACK_END() \
GizSDKClient_LOG_API_FUNC("Callback end")

#define GizSDK_LOG_DELEGATE(x) \
GizSDKClient_LOG_API_FUNC("Ready to callback, delegate is %s<%p>", NSStringFromClass([x class]).UTF8String, x)

#define GizSDK_LOG_CALLBACK_PARAMS(fmt, args...) \
GizSDKClient_LOG_API(fmt, ##args)

#define GizSDK_LOG_BLOCK_BEGIN(fmt, args...) \
GizSDKClient_LOG_API("Block Start =>%s: " fmt"", NSStringFromSelector(_cmd).UTF8String,##args)

#define GizSDK_LOG_BLOCK_END() \
GizSDKClient_LOG_API("Block End => %s:", NSStringFromSelector(_cmd).UTF8String)


/** 一些常用的方法，用于安全处理字典中的数据 */
NSString *gizGetStringFromDict(NSDictionary *dict, NSString *key, NSString *defaultValue);
NSInteger gizGetIntegerFromDict(NSDictionary *dict, NSString *key, NSInteger defaultValue);
BOOL gizGetBoolFromDict(NSDictionary *dict, NSString *key, BOOL defaultValue);
double gizGetDoubleFromDict(NSDictionary *dict, NSString *key, double defaultValue);
NSArray *gizGetArrayFromDict(NSDictionary *dict, NSString *key, NSArray *defaultValue);
NSDictionary *gizGetDictFromDict(NSDictionary *dict, NSString *key, NSDictionary *defaultValue);

#pragma mark - Tool
/** 判断是否为手机号 */
BOOL gizPhonePredicate(NSString* phone);

/** 判断是否为邮箱 */
BOOL gizEmailPredicate(NSString* email);

#pragma mark - cache
/**获取当前用户uid*/
NSString *gizGetTheUid(void);
/**获取当前用户token*/
NSString *gizGetTheToken(void);
/**获取初始化传入的appId*/
NSString *gizGetTheAppID(void);
/**获取OpenApi域名*/
NSString *gizGetTheOpenApi(void);
/**获取AepApi域名*/
NSString *gizGetTheAepApi(void);
/**获取UploadApi域名*/
NSString *gizGetTheUploadApi(void);
/** 判断对象长度是否为空 */
BOOL gizIsEmpty(id obj);
