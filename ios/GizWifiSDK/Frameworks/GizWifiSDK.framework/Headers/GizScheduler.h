//
//  GizScheduler.h
//  GizWifiSDK
//
//  Created by danlypro on 2020/7/30.
//  Copyright © 2020 gizwits. All rights reserved.
//

#import <GizWifiSDK/GizBaseModel.h>

/**
 @brief 定时任务类型
 */
typedef NS_ENUM(NSInteger, GizSchedulerType) {
    /** 一次性定时任务 */
    GizSchedulerOneTime = 0,
    /** 按周重复定时任务 */
    GizSchedulerWeekRepeat = 1,
    /** 按天重复定时任务 */
    GizSchedulerDayRepeat = 2,
};

/**
 @brief 定时按周重复
 */
typedef NS_ENUM(NSInteger, GizScheduleWeekday) {
    /** 星期日 */
    GizScheduleSunday = 0,
    /** 星期一 */
    GizScheduleMonday = 1,
    /** 星期二 */
    GizScheduleTuesday = 2,
    /** 星期三 */
    GizScheduleWednesday = 3,
    /** 星期四 */
    GizScheduleThursday = 4,
    /** 星期五 */
    GizScheduleFriday = 5,
    /** 星期六 */
    GizScheduleSaturday = 6
};


NS_ASSUME_NONNULL_BEGIN

@interface GizScheduler : GizBaseModel

/**
 定时任务id
 */
@property (nonatomic, copy, readonly) NSString *schedulerId;

/**
产品的PK
*/
@property (nonatomic, copy, readonly) NSString *productKey;

/**
定时任务创建时间
*/
@property (nonatomic, copy, readonly) NSDate *createdTime;

/**
定时任务所属设备id
*/
@property (nonatomic, copy) NSString *did;

/**
 标识定时任务的类型
 */
@property (nonatomic, assign) GizSchedulerType type;

/**
 定时任务要执行的控制指令，格式：{数据点名称: 数据点值}，请注意不支持透传数据。此参数不能填nil或空字典
 */
@property (nonatomic, strong) NSDictionary <NSString *, NSObject *>*attrs;

/**
 定时任务执行日期，格式为: xxxx-xx-xx  例如:1990-01-03, 只对一次性定时任务产生作用，即type = GizSchedulerOneTime
 */
@property (nonatomic, strong) NSString *date;

/**
定时任务执行时间, 24小时制，格式为: xx:xx 例如：02:00，此参数不能填nil或空串，必须符合约定格式，否则无法在云端创建定时任务
 */
@property (nonatomic, copy) NSString *time;

/**
 GizScheduleWeekday数组, 按周重复的定时任务此字段才产生作用，即type = GizSchedulerWeekRepeat。用于表示每周的某几天执行此任务
 */
@property (nonatomic, strong) NSArray <NSNumber *> *weekDays;

/**
 按天重复，表示每月的某几天执行此任务。 type = GizSchedulerDayRepeat时该字段才产生作用
 */
@property (nonatomic, strong) NSArray <NSNumber *> *monthDays;

/**
 定时任务有效期的开始日期，该天0点开始，格式xxxx-xx-xx，如1990-01-03
 */
@property (nonatomic, strong) NSString *startDate;

/**
 定时任务有效期的结束日期，该天24点结束，格式xxxx-xx-xx，如1990-01-03
 */
@property (nonatomic, strong) NSString *endDate;

/**
表示定时任务是否启用，若设为false，到了任务执行时间也不会触发任务的执行
 */
@property (nonatomic, assign) BOOL enabled;

/**
 定时任务备注信息
 */
@property (nonatomic, copy) NSString *remark;

/**
GizScheduler构造函数，用于创建一次性定时任务
@param did 设备did
@param attrs 定时任务要执行的控制指令，格式：{数据点名称: 数据点值}。此参数不能填nil或空字典
@param date 定时任务的预设日期，格式形如：1990-10-03。定时任务将在预设日期这一天到达时执行。此参数不能填nil或空串，如果填写了过去日期或者不符合约定格式，无法在云端创建定时任务
@param time 定时任务的预设时间，24小时制，格式形如：07:08。定时任务将在预设时间到达时执行。此参数不能填nil或空串，必须符合约定格式，否则无法在云端创建定时任务
@param enabled 定时任务是否开启。true表示开启，false表示不开启
@param remark 定时任务备注信息。此参数可选填，可填nil
*/
+ (instancetype _Nullable)schedulerOneTime:(NSString * _Nonnull)did attrs:(NSDictionary <NSString *, NSObject *>* _Nonnull)attrs date:(NSString * _Nonnull)date time:(NSString * _Nonnull)time enabled:(BOOL)enabled remark:(NSString * _Nullable)remark;

/**
GizScheduler构造函数，用于创建按周重复定时任务
@param did 设备did
@param attrs 定时任务要执行的控制指令，格式：{数据点名称: 数据点值}，请注意不支持透传数据。此参数不能为nil或空字典
@param time 定时任务的预设时间，24小时制，格式形如：07:08。此参数不能填nil或空串，必须符合约定格式，否则无法在云端创建定时任务。定时任务将在预设时间到达时执行
@param weekDays 按周重复，GizScheduleWeekday数组。定时任务可以预设为每周的某几天重复执行。此参数不能填nil或空数组，数组中重复的值会被合并，无效值会被滤除，如果滤除后数组大小为0按空数组处理
@param enabled 定时任务是否开启。true表示开启，false表示不开启
@param remark 定时任务备注信息。此参数可选填，可填nil
*/
+ (instancetype _Nullable)schedulerWeekRepeat:(NSString * _Nonnull)did attrs:(NSDictionary <NSString *, NSObject *>* _Nonnull)attrs time:(NSString * _Nonnull)time weekDays:(NSArray <NSNumber *>* _Nonnull)weekDays enabled:(BOOL)enabled remark:(NSString * _Nullable)remark;

/**
GizScheduler构造函数，用于创建按天重复定时任务
@param did 设备did
@param attrs 定时任务要执行的控制指令，格式：{数据点名称: 数据点值}，请注意不支持透传数据。此参数不能为nil或空字典
@param time 定时任务的预设时间，24小时制，格式形如：07:08。此参数不能填nil或空串，必须符合约定格式，否则无法创建定时任务。定时任务将在预设时间到达时执行
@param monthDays 按天重复，GizScheduleWeekday数组。定时任务可以预设为每周的某几天重复执行。此参数不能填nil或空数组，数组中重复的值会被合并，无效值会被滤除，如果滤除后数组大小为0按空数组处理
@param enabled 定时任务是否开启。true表示开启，false表示不开启
@param remark 定时任务备注信息。此参数可选填，可传nil
*/
+ (instancetype _Nullable)schedulerDayRepeat:(NSString * _Nonnull)did attrs:(NSDictionary <NSString *, NSObject *>* _Nonnull)attrs time:(NSString * _Nonnull)time monthDays:(NSArray <NSNumber *>* _Nonnull)monthDays enabled:(BOOL)enabled remark:(NSString * _Nullable)remark;

@end

NS_ASSUME_NONNULL_END
