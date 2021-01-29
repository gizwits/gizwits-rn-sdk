//
//  OpenApiLoginResult.h
//  GizWifiSDK
//
//  Created by danlypro on 2020/7/29.
//  Copyright © 2020 gizwits. All rights reserved.
//

#import "OpenApiResult.h"

@interface OpenApiLoginResult : OpenApiResult

/**
 机智云用户uid
 */
@property (nonatomic, strong) NSString* uid;

/**
用户token
*/
@property (nonatomic, strong) NSString* token;

/**
token过期时间的时间戳
*/
@property (nonatomic, assign) NSUInteger expiredAt;

@end

