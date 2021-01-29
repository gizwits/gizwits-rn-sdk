//
//  GizUserTerm.h
//  GizWifiSDK
//
//  Created by danlypro on 2020/7/14.
//  Copyright © 2020 gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GizWifiDefinitions.h"
#import "GizBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
用户协议类型
*/
typedef NS_ENUM(NSInteger, GizUserTermType) {

    /**未知协议*/
    GizUserTermUnKnow = 0,

    /**用户协议*/
    GizUserTermAgreement = 1,

    /**隐私协议*/
    GizUserTermPrivate = 2,
};


@interface GizUserTerm : GizBaseModel

/**
 协议类型
 */
@property (nonatomic, assign) GizUserTermType termType;


@end


NS_ASSUME_NONNULL_END
