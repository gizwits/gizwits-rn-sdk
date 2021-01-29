//
//  GizBaseModel.h
//  GizWifiSDK
//
//  Created by william Zhang on 2020/7/7.
//  Copyright © 2020 gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GizJSONMode.h"

NS_ASSUME_NONNULL_BEGIN

@interface GizBaseModel : NSObject<GizJSONModel>

/**
 *  通过字典来构造对象
 */
+(instancetype)modelByDictionary:(NSDictionary*)dictionary;


/**
 按“属性名称:属性值”为key-value的字典给对象赋值
*/
-(void)setModelValueByDictionary:(NSDictionary*)dictionary;


/**
 按“属性名称:属性值”为key-value返回字典
*/
-(NSMutableDictionary*)modelDictionary;

@end

NS_ASSUME_NONNULL_END
