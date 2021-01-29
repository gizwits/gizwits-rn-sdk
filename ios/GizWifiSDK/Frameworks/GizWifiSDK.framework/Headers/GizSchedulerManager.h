//
//  GizSchedulerManager.h
//  GizWifiSDK
//
//  Created by danlypro on 2020/7/30.
//  Copyright © 2020 gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GizWifiSDK/GizScheduler.h>
#import <GizWifiSDK/OpenApiResult.h>

NS_ASSUME_NONNULL_BEGIN

@interface GizSchedulerManager : NSObject

/**
 获取指定设备定时任务列表
 @param did 设备did
 */
+ (void)getSchedulerList:(NSString * _Nonnull)did callback:(void (^ _Nullable)(OpenApiResult * _Nonnull result, NSArray <GizScheduler *> *schedulerList))callback;

/**
 创建定时任务
 @param schduler 定时任务对象
 */
+ (void)createScheduler:(GizScheduler * _Nonnull)schduler callback:(void (^ _Nullable)(OpenApiResult * _Nonnull result, NSString *schdulerId))callback;

/**
 删除指定定时任务
 @param schedulerId 定时任务id
 */
+ (void)deleteScheduler:(NSString * _Nonnull)schedulerId callback:(void (^ _Nullable)(OpenApiResult * _Nonnull result))callback;

/**
 编辑定时任务
 @param schduler 定时任务对象
 */
+ (void)editScheduler:(GizScheduler * _Nonnull)schduler callback:(void (^ _Nullable)(OpenApiResult * _Nonnull result, NSString *schdulerId))callback;

@end

NS_ASSUME_NONNULL_END
