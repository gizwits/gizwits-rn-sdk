//
//  GizOpenApiUser.h
//  GizWifiSDK
//
//  Created by william Zhang on 2020/6/28.
//  Copyright © 2020 gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GizWifiDefinitions.h"
#import "GizBaseModel.h"
#import "GizLanguage.h"


NS_ASSUME_NONNULL_BEGIN

@interface GizOpenApiUser : GizBaseModel

/**
 用户唯一id
 */
@property (nonatomic, copy, readonly) NSString* uid;

/**
 用户名,用户名密码注册的请求参数
 */
@property (nonatomic, copy, readonly) NSString* username;

/**
 邮件地址,邮箱注册的请求参数
 */
@property (nonatomic, copy, readonly) NSString* email;

/**
 手机号码,手机号码，手机注册的请求参数
 */
@property (nonatomic, copy, readonly) NSString* phone;

/**
 语言:en，zh-cn
 */
@property (nonatomic, assign) GizLanguageType language;

/**
 姓名
 */
@property (nonatomic, copy) NSString* name;

/**
生日 格式:yyyy-MM-dd
*/
@property (nonatomic, copy) NSString *birthday;

/**
 性别
 */
@property (nonatomic, assign) GizUserGenderType userGender;

/**
 地址
 */
@property (nonatomic, copy) NSString* address;

/**
 备注
 */
@property (nonatomic, copy) NSString* remark;

/**
是否匿名账户
*/
@property (nonatomic, assign) BOOL isAnonymous;


@end

NS_ASSUME_NONNULL_END
