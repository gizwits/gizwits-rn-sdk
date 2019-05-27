#import "GizWifiDef.h"

GizWifiConfigureMode getConfigModeFromInteger(NSInteger integerValue) {
    /**
     GizWifiSoftAP      = 0
     GizWifiAirLink     = 1
     */
    switch (integerValue) {
        case 0:
            return GizWifiSoftAP;
        case 1:
            return GizWifiAirLink;
        case 2:
            return GizWifiAirLinkMulti;
        default:
            break;
    }
    return -1;
}

GizMeshVerdor getMeshVerdorFromInteger(NSInteger integerValue) {
    /**
     GizMeshMayi      = 0
     GizMeshTelink     = 1
     */
    switch (integerValue) {
        case 0:
            return GizMeshMayi;
        case 1:
            return GizMeshTelink;
        default:
            break;
    }
    return -1;
}

XPGConfigureMode getCompatibleConfigModeFromInteger(NSInteger integerValue) {
    switch (integerValue) {
        case 1:
            return XPGWifiSDKSoftAPMode;
        case 2:
            return XPGWifiSDKAirLinkMode;
       
        default:
            break;
    }
    return -1;
}

GizLogPrintLevel getLogLevelFromInteger(NSInteger integerValue) {
    /**
     GizLogPrintNone    = 0
     GizLogPrintI       = 1
     GizLogPrintII      = 2
     GizLogPrintAll     = 3
     */
    switch (integerValue) {
        case 0:
            return GizLogPrintNone;
        case 1:
            return GizLogPrintI;
        case 2:
            return GizLogPrintII;
        case 3:
            return GizLogPrintAll;
        default:
            break;
    }
    return -1;
}

NSInteger getDeviceTypeFromEnum(GizWifiDeviceType enumValue) {
    /**
     GizDeviceNormal        = 0
     GizDeviceCenterControl = 1
     */
    switch (enumValue) {
        case GizDeviceNormal:
            return 0;
        case GizDeviceCenterControl:
            return 1;
        default:
            break;
    }
    return -1;
}

NSInteger getEventTypeFromEnum(GizEventType enumValue) {
    /**
     GizEventSDK        = 0
     GizEventDevice     = 1
     GizEventM2MService = 2
     GizEventToken      = 5
     */
    switch (enumValue) {
        case GizEventSDK:
            return 0;
        case GizEventDevice:
            return 1;
        case GizEventM2MService:
            return 2;
        case GizEventToken:
            return 5;
        default:
            break;
    }
    return -1;
}

GizThirdAccountType getThirdAccountTypeFromInteger(NSInteger integerValue) {
    /**
     GizThirdBAIDU      = 0
     GizThirdSINA       = 1
     GizThirdQQ         = 2
     */
    switch (integerValue) {
        case 0:
            return GizThirdBAIDU;
        case 1:
            return GizThirdSINA;
        case 2:
            return GizThirdQQ;
        case 3:
            return GizThirdWeChat;
        default:
            break;
    }
    return -1;
}

GizUserGenderType getUserGenderTypeFromInteger(NSInteger integerValue) {
    /**
     GizUserGenderMale      = 0
     GizUserGenderFemale    = 1
     GizUserGenderUnknow    = 2
     */
    switch (integerValue) {
        case 0:
            return GizUserGenderMale;
        case 1:
            return GizUserGenderFemale;
        case 2:
            return GizUserGenderUnknown;
        default:
            break;
    }
    return -1;
}

GizUserAccountType getUserAccountTypeFromInteger(NSInteger integerValue) {
    /**
     GizUserNormal  = 0
     GizUserPhone   = 1
     GizUserEmail   = 2
     */
    switch (integerValue) {
        case 0:
            return GizUserNormal;
        case 1:
            return GizUserPhone;
        case 2:
            return GizUserEmail;
        default:
            break;
    }
    return -1;
}

GizPushType getPushTypeFromInteger(NSInteger integerValue)
{
    switch (integerValue) {
        case 0:
            return GizPushBaiDu;
        case 1:
            return GizPushJiGuang;
        case 2:
            return GizPushAWS;
        case 3:
            return GizPushXinGe
        default:
            break;
    }
    return -1;
}

GizWifiDeviceNetStatus getDeviceNetStatus(NSInteger integerValue) {
    /**
     GizDeviceOffline       = 0
     GizDeviceOnline        = 1
     GizDeviceControlled    = 2
     */
    switch (integerValue) {
        case 0:
            return GizDeviceOffline;
        case 1:
            return GizDeviceOnline;
        case 2:
            return GizDeviceControlled;
        default:
            break;
    }
    return -1;
}
