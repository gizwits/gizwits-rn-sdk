//
//  BaseResult.h
//  GizWifiSDK
//
//  Created by william Zhang on 2020/6/24.
//  Copyright © 2020 gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GizError.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseResult : NSObject

/**
 请求结果data
 */
@property (nonatomic, strong, nullable) NSData * responseData;

/**
请求响应response
*/
@property (nonatomic, strong, nullable) NSURLResponse * response;

/**
请求发生的错误error
*/
@property (nonatomic, strong, nullable) GizError * error;


/**
 根据BaseRequest结果(data,response,error)直接转化为BaseResult
 */
-(instancetype)initWithData:(NSData*)data response:(NSURLResponse*)response error:(NSError*)error;

@end

NS_ASSUME_NONNULL_END
