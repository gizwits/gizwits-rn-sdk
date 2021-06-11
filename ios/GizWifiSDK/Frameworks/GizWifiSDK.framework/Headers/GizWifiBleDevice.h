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

@end

NS_ASSUME_NONNULL_END
