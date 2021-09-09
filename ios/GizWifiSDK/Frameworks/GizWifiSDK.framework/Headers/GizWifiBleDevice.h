//
//  GizWifiBleDevice.h
//  GizWifiSDK
//
//  Created by danlypro on 2020/12/2.
//  Copyright © 2020 gizwits. All rights reserved.
//

#import <GizWifiSDK/GizWifiSDK.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^bleCallback)(GizWifiErrorCode errorCode);
@interface GizWifiBleDevice : GizWifiDevice

/**
 标志设备当前的状态；true: 表示当前使用的是蓝牙通道
 */
@property (nonatomic, assign, readonly) BOOL isBlueLocal;

/**
 建立连接
 */
- (void)connectBle: (bleCallback)callback;

/**
 断开连接
 */
- (void)disconnectBle: (bleCallback)callback;

/**
 升级固件
 @param firmwateType 选择固件类型是mcu还是模组
 */
- (void)startUpgrade:(GizOTAFirmwareType)firmwareType listener:(void (^)(GizOTAEventType type, NSError *result))listener;

/**
 检查设备更新
 @param firmwateType 选择固件类型是mcu还是模组
 @param lastVersion 云端最新的固件版本号
 @param currentVersion 当前固件版本号
 */
- (void)checkUpdate:(GizOTAFirmwareType)firmwareType completion:(void(^)(NSError * _Nonnull result , NSString *lastVersion, NSString *currentVersion))completion;

@end

NS_ASSUME_NONNULL_END
