//
//  GizJSONMode.h
//  GizWifiSDK
//
//  Created by william Zhang on 2020/7/7.
//  Copyright © 2020 gizwits. All rights reserved.
//

#ifndef GizJSONMode_h
#define GizJSONMode_h

#import <Foundation/Foundation.h>

#if __has_include(<GizJsonModel/GizJSONModel.h>)
#import <GizJsonModel/NSObject+GizJSONModel.h>
#import <GizJsonModel/GizClassInfo.h>
#else
#import "NSObject+GizJSONModel.h"
#import "GizClassInfo.h"
#endif

#endif /* GizJSONMode_h */
