//
//  OpenApiResult.h
//  GizWifiSDK
//
//  Created by william Zhang on 2020/6/24.
//  Copyright © 2020 gizwits. All rights reserved.
//

#import "BaseResult.h"
#import "GizError.h"

NS_ASSUME_NONNULL_BEGIN

@interface OpenApiResult : BaseResult

/**
 结果是否成功
 */
@property (nonatomic, assign) BOOL success;

/**
请求成功后解析出来的数据
*/
@property (nonatomic, strong) NSDictionary* data;

/**
 根据请求结果(data,response,error)直接转化为OpenApiResult
 */
+(instancetype)resultWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error;

/**
 根据GizError生成OpenApiResult
*/
+(instancetype)resultWithError:(GizError *)error;

@end

NS_ASSUME_NONNULL_END
