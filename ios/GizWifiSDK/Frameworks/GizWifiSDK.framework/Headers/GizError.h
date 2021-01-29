//
//  GizError.h
//  GizWifiSDK
//
//  Created by william Zhang on 2020/6/24.
//  Copyright © 2020 gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GizError : NSObject

/**
错误码
*/
@property (nonatomic, assign) NSInteger code;

/**
错误描述
*/
@property (nonatomic, strong) NSString* message;

/**
错误信息
*/
@property (nonatomic, strong) NSDictionary* info;


+(GizError*)errorWithCode:(NSInteger)code message:(NSString* _Nullable)message;


+(GizError*)errorWithCode:(NSInteger)code message:(NSString* _Nullable)message info:(NSDictionary*)info;

/**
 根据NSError生成GizError
 */
+(GizError*)errorWithError:(NSError*)error;


@end

NS_ASSUME_NONNULL_END
