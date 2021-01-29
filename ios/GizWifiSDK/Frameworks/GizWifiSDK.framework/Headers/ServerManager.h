//
//  ServerManager.h
//  GizWifiSDK
//
//  Created by william Zhang on 2020/6/24.
//  Copyright © 2020 gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenApiResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface ServerManager : NSObject


+ (instancetype)manager;

/**
@param url 请求url
@param method 请求方法名称，支持POST，GET，DELETE，PUT等
@param header 请求头部参数
@param body 请求体数据
@param timeoutInterval 请求超时时间，传小于等于0的数值则按默认60s
@param callback 请求结果回调，请求结果data，请求响应response，请求发生的错误error
*/
-(void)request:(NSString*)url method:(NSString*)method header:(NSDictionary*)header body:(NSData*)body timeoutInterval:(NSTimeInterval)timeoutInterval callback:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))callback;

/**
@param url openApi请求url，不需要前缀，例如 'user/login'
@param method 请求方法名称，支持POST，GET，DELETE，PUT等
@param withToken 是否要带上token，放在头部参数
@param params 请求参数
@param timeoutInterval 超时时间
@param callback 请求结果回调，请求结果OpenApiResult
*/
-(void)openApiRequest:(NSString*)url method:(NSString*)method withToken:(BOOL)withToken header:(NSDictionary* _Nullable)header params:(NSDictionary * _Nullable)params timeoutInterval:(NSTimeInterval)timeoutInterval callback:(void (^)(OpenApiResult * _Nullable result))callback;

/**
@param url openApi请求url，不需要前缀，例如 'user/login'
@param method 请求方法名称，支持POST，GET，DELETE，PUT等
@param withToken 是否要带上token，放在头部参数
@param params 请求参数
@param callback 请求结果回调，请求结果OpenApiResult
*/
-(void)openApiRequest:(NSString*)url method:(NSString*)method withToken:(BOOL)withToken header:(NSDictionary* _Nullable)header params:(NSDictionary * _Nullable)params callback:(void (^)(OpenApiResult * _Nullable result))callback;

/**
@param url pushApi请求url，不需要前缀，例如 'user/login'
@param method 请求方法名称，支持POST，GET，DELETE，PUT等
@param params 请求参数
@param callback 请求结果回调，请求结果OpenApiResult
*/
-(void)pushApiRequest:(NSString*)url method:(NSString*)method header:(NSDictionary* _Nullable)header params:(NSDictionary * _Nullable)params callback:(void (^)(OpenApiResult * _Nullable result))callback;

@end

NS_ASSUME_NONNULL_END
