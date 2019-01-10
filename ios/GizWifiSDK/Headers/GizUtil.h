//
//  GizUtil.h
//  GizWifiSDK
//
//  Created by GeHaitong on 15/7/13.
//  Copyright (c) 2015年 gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 一些常用的方法
 */
NSString *gizGetStringFromDict(NSDictionary *dict, NSString *key, NSString *defaultValue);
NSInteger gizGetIntegerFromDict(NSDictionary *dict, NSString *key, NSInteger defaultValue);
BOOL gizGetBoolFromDict(NSDictionary *dict, NSString *key, BOOL defaultValue);
double gizGetDoubleFromDict(NSDictionary *dict, NSString *key, double defaultValue);
NSArray *gizGetArrayFromDict(NSDictionary *dict, NSString *key, NSArray *defaultValue);
NSDictionary *gizGetDictFromDict(NSDictionary *dict, NSString *key, NSDictionary *defaultValue);

/**
 phone id
 */
#define GIZ_PHONEID_COMPATIBLE_SERVICE      @"com.xpg.wifisdk"          //旧版兼容
#define GIZ_PHONEID_SERVICE                 @"com.gizwits.wifisdk"      //新版的

NSString *getPhoneId();

/**
 Connection
 */
int ConnectToDaemon();

/**
 Soft-AP mode
 */
NSString *getCurrentSSID();
NSString *getCurrentBSSID();

/**
 Special SSID（这些热点是收费的）
 */
BOOL isSpecialSSID(const char *ssid);

/**
 Error codes
 */
NSError *makeError(NSInteger errorCode, Class class);
NSError *makeErrorWithErrorMessage(NSInteger errorCode, NSString *errorMessage, Class class);
NSError *OpenAPI_MakeError(NSInteger errorCode, NSString *errorMessage, Class class);
int getCompatibleErrorCode(NSInteger errorCode);
NSString *GizSDKErrorCodeString(NSInteger errorCode);

/**
 Get current language
 */
NSString *getCurrentLanguage();

/**
 Client日志方法
 */
int ClientLogInit(NSString *appID, NSInteger printLevel);
int ClientLogReinit();
int ClientLogProvision(NSString *appID, NSString *uid, NSString *token);

/*
 业务日志打印
 @note 最后的可变参数格式为：key, value, key, value，必须以成对的形式出现，必须是NSObject的基础类，以nil结尾
 */
void ClientLogBIZ(NSString *businessCode, NSString *errorString, ...) NS_REQUIRES_NIL_TERMINATION;

/*
 根据 ProductKey 过滤设备列表
 */
NSArray *filterDeviceList(NSArray *deviceList, NSArray *productKeys);

/**
 网络检测
 */
int pingToIP(const char *ip, double *elapsed);

/**
 Air-link 方式对配置的模组类型做去重和排序
 */
NSArray *arrayWithGagentTypes(NSArray *types);

/**
 分组相关
 @result 子设备从分组缓存匹配，匹配到且子设备的pk和分组pk相等，返回TRUE，否则返回FALSE
 */
BOOL isValidSubDevices(NSArray *subDevices, NSString *groupProductKey);
NSArray *removeDuplicateSubDevices(NSArray *subDevices);

/**
 计时器（非主线程）
 */
static dispatch_queue_t timerQueue = nil;

static inline dispatch_queue_t dispatch_timer_queue() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timerQueue = dispatch_queue_create("Timer", DISPATCH_QUEUE_SERIAL);
    });
    return timerQueue;
}

/**
 计时器立即启动（非主线程）
 @note timeval 必须大于 10ms
 */
static inline dispatch_source_t dispatch_timer_start(NSTimeInterval timerval, dispatch_block_t handler) {
    NSCAssert(timerval >= 0.01, @"timeval must be [0.01, ...)");
    NSCAssert(nil != handler, @"handler could not be null");
    if (timerval < 0.01) {
        timerval = 0.01;
    }
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_timer_queue());
    dispatch_time_t start_time = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_MSEC);//delay 10ms，给延迟的原因是，当没有返回timer时就触发事件时，会出现错误
    dispatch_source_set_timer(timer, start_time, timerval * NSEC_PER_SEC, 1 * NSEC_PER_MSEC);
    dispatch_source_set_event_handler(timer, handler);
    dispatch_resume(timer);
    return timer;
}

/**
 计时器延迟启动（非主线程）
 @note timeval 必须大于 10ms
 */
static inline dispatch_source_t dispatch_timer_start_after(NSTimeInterval timerval, dispatch_block_t handler) {
    NSCAssert(timerval >= 0.01, @"timeval must be [0.01, ...)");
    NSCAssert(nil != handler, @"handler could not be null");
    if (timerval < 0.01) {
        timerval = 0.01;
    }
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_timer_queue());
    dispatch_time_t start_time = dispatch_time(DISPATCH_TIME_NOW, timerval * NSEC_PER_SEC);
    dispatch_source_set_timer(timer, start_time, timerval * NSEC_PER_SEC, 1 * NSEC_PER_MSEC);
    dispatch_source_set_event_handler(timer, handler);
    dispatch_resume(timer);
    return timer;
}

/**
 使用daemon的现成睡眠方法
 */
void GizWifiSDKSelectSleep(int sec, int usec);
