//
//  GizLanguage.h
//  GizWifiSDK
//
//  Created by william Zhang on 2020/7/8.
//  Copyright © 2020 gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 语言枚举
 */
typedef NS_ENUM(NSInteger, GizLanguageType) {
    /** 中文繁体，zh-Hant */
    GIZ_LANGUAGE_ZH_HANT = 1,
    /** 中文，zh */
    GIZ_LANGUAGE_ZH = 2,
    /** 英文，en */
    GIZ_LANGUAGE_EN = 3,
    /** 日文，ja */
    GIZ_LANGUAGE_JA = 4,
    /** 韩语，ko */
    GIZ_LANGUAGE_KO = 5,
    /** 德语，de */
    GIZ_LANGUAGE_DE = 6,
    /** 法语，fr */
    GIZ_LANGUAGE_FR = 7,
    /** 西班牙语，es */
    GIZ_LANGUAGE_ES = 8,
    /** 意大利语，it */
    GIZ_LANGUAGE_IT = 9,
    /** 俄语，ru */
    GIZ_LANGUAGE_RU = 10,
    /** 阿拉伯语，ar */
    GIZ_LANGUAGE_AR = 11,
    /** 保加利亚语，bg */
    GIZ_LANGUAGE_BG = 12,
    /** 克罗地亚语，hr */
    GIZ_LANGUAGE_HR = 13,
    /** 捷克语，cs */
    GIZ_LANGUAGE_CS = 14,
    /** 丹麦语，da */
    GIZ_LANGUAGE_DA = 15,
    /** 荷兰语，nl */
    GIZ_LANGUAGE_NL = 16,
    /** 希腊语，el */
    GIZ_LANGUAGE_EL = 17,
    /** 匈牙利语，hu */
    GIZ_LANGUAGE_HU = 18,
    /** 印度尼西亚语，id */
    GIZ_LANGUAGE_ID = 19,
    /** 哈萨克语，kk */
    GIZ_LANGUAGE_KK = 20,
    /** 老挝语，lo ??? */
    GIZ_LANGUAGE_LO = 21,
    /** 马来语，ms */
    GIZ_LANGUAGE_MS = 22,
    /** 波兰语，pl */
    GIZ_LANGUAGE_PL = 23,
    /** 葡萄牙语，pt */
    GIZ_LANGUAGE_PT = 24,
    /** 罗马尼亚语，ro */
    GIZ_LANGUAGE_RO = 25,
    /** 瑞典语，sv */
    GIZ_LANGUAGE_SV = 26,
    /** 泰语，th */
    GIZ_LANGUAGE_TH = 27,
    /** 越南语，vi */
    GIZ_LANGUAGE_VI = 28,
};


NS_ASSUME_NONNULL_BEGIN

@interface GizLanguage : NSObject

/**
 获取当前手机语言
 */
+(NSString*)gizGetDeviceLanguage;

/**
 根据语言Key返回对应的枚举
 */
+(GizLanguageType)gizGetLanguageEnumByString:(NSString*)langStr;

/**
 根据枚举返回对应的语言Key
*/
+(NSString*)gizGetLanguageStringByEnum:(GizLanguageType)language;

@end

NS_ASSUME_NONNULL_END
