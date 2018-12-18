/**
 *   GizSDK Client log module
 *
 * Copyright (c) 2015 GizWits. *
 * @file
 * @brief GizSDK Client log module.
 * @author Trevor <trevortao@gizwits.com>
 * @date 2015/11/26
 *
 *   Change Logs:
 * Date          Author      Notes
 * 2016-04-23    Trevor      the first version
 */
#ifndef __GizSDKClientLog_h__
#define __GizSDKClientLog_h__

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <string.h>

#ifdef __ANDROID__
#define LOG_TAG                 "GizSDKClientLog"
#include <android/log.h>
#endif

#define LOG_MAX_RENAME_GAGENT_TIME  (60)
#define LOG_MAX_RENAME_BIZ_TIME     (10 * 60)
#define LOG_MAX_GAGENT_FILE_SIZE    (10 * 1024)
#define LOG_MAX_SYS_FILE_SIZE       (10 * 1024 * 1024)
#define LOG_MAX_BIZ_FILE_SIZE       (1000 * 1024) //云端最大接收字节数是1048359,故预留24K富余空间
#define LOG_MAX_PATH_LEN            (256)
#define LOG_MAX_LEN                 (10 * 1024)
#define LOG_COLUMN_PER_LINE         (16)
#define LOG_FILE_NAME               "GizSDKClientLogFile"

#define LOG_HTTP_TIMEOUT            (60)
#define LOG_IP_BUF_LENGTH           (128)
#define LOG_READ_BUF_LENGTH         (4096)
#define LOG_SEND_BUF_LENGTH         (4096)
#define LOG_HTTP_STATUS_OK          (200)
#define LOG_HTTP_BOUNDARY           "----GizSDKClientLogBoundaryGizWits"

#define LOG_SYSTEM_INFO_JSON_LEN    (1024)
#define LOG_DOMAIN_BUF_LEN          (128)
#define LOG_APPID_BUF_LEN           (32)
#define LOG_UID_BUF_LEN             (32)
#define LOG_TOKEN_BUF_LEN           (32)
#define LOG_PHONE_ID_LENGTH         (64)
#define LOG_PHONE_MODEL_LENGTH      (32)
#define LOG_PHONE_OS_LENGTH         (32)
#define LOG_PHONE_OS_VERSION_LENGTH (8)
#define LOG_SDK_VERSION_LENGTH      (64)

#ifdef _WIN32
#define __FILENAME__    ((strrchr(__FILE__, '\\') ? strrchr(__FILE__, '\\') : __FILE__ - 1) + 1)
#define GizSDKClient_LOG_BIZ(businessCode, result, fmt, ...)  GizSDKClientPrintBiz(businessCode, result, "[" fmt"]", __VA_ARGS__)
#define GizSDKClient_LOG_CRASH(fmt, ...)  GizSDKClientPrintError("[SYS][CRASH][%s][%s:%d %s][" fmt"]", GizSDKClientTimeStr(), __FILENAME__, __LINE__, __FUNCTION__, __VA_ARGS__)
#define GizSDKClient_LOG_ERROR(fmt, ...)  GizSDKClientPrintError("[SYS][ERROR][%s][%s:%d %s][" fmt"]", GizSDKClientTimeStr(), __FILENAME__, __LINE__, __FUNCTION__, __VA_ARGS__)
#define GizSDKClient_LOG_API(fmt, ...)  GizSDKClientPrintAPI("[SYS][DEBUG][%s][%s:%d %s][" fmt"]", GizSDKClientTimeStr(), __FILENAME__, __LINE__, __FUNCTION__, __VA_ARGS__)
#define GizSDKClient_LOG_DEBUG(fmt, ...)  GizSDKClientPrintDebug("[SYS][DEBUG][%s][%s:%d %s][" fmt"]", GizSDKClientTimeStr(), __FILENAME__, __LINE__, __FUNCTION__, __VA_ARGS__)
#else
#define __FILENAME__    ((strrchr(__FILE__, '/') ?: __FILE__ - 1) + 1)  //如果__FILE__编译为绝对路径（如xCode上），则只截取文件名
#define GizSDKClient_LOG_BIZ(businessCode, result, fmt, args...)  GizSDKClientPrintBiz(businessCode, result, "[" fmt"]", ##args)
#define GizSDKClient_LOG_CRASH(fmt, args...)  GizSDKClientPrintError("[SYS][CRASH][%s][%s:%d %s][" fmt"]", GizSDKClientTimeStr(), __FILENAME__, __LINE__, __FUNCTION__, ##args)
#define GizSDKClient_LOG_ERROR(fmt, args...)  GizSDKClientPrintError("[SYS][ERROR][%s][%s:%d %s][" fmt"]", GizSDKClientTimeStr(), __FILENAME__, __LINE__, __FUNCTION__, ##args)
#define GizSDKClient_LOG_API(fmt, args...)  GizSDKClientPrintAPI("[SYS][DEBUG][%s][%s:%d %s][" fmt"]", GizSDKClientTimeStr(), __FILENAME__, __LINE__, __FUNCTION__, ##args)
#define GizSDKClient_LOG_DEBUG(fmt, args...)  GizSDKClientPrintDebug("[SYS][DEBUG][%s][%s:%d %s][" fmt"]", GizSDKClientTimeStr(), __FILENAME__, __LINE__, __FUNCTION__, ##args)
#endif
    
#define GizSDKClient_CLOSE(fd)    GizSDKClientClose(fd, __FILENAME__, __LINE__, __FUNCTION__)

/*
 * 日志信息结构体
 */
typedef struct _GizSDKClientLog_t {
    int printLevel; //日志打印到屏幕的级别(0:不打印屏幕,1:打印error+busi,2:打印error+api+busi,3:打印error+api+debug+busi+data,默认3)
    int port; //日志服务器端口
    int uploadSystemLog; //是否上传系统日志
    int uploadBusinessLog; //是否上传业务日志
    time_t latestCreatSysLogTimestamp; //最新创建系统日志文件的时间戳
    time_t latestCreatBizLogTimestamp; //最新创建业务日志文件的时间戳
    char dir[LOG_MAX_PATH_LEN + 1]; //日志文件存储目录
    char domain[LOG_DOMAIN_BUF_LEN + 1]; //日志服务器域名
    char uid[LOG_UID_BUF_LEN + 1]; //用户标识
    char token[LOG_TOKEN_BUF_LEN + 1]; //用户令牌
    char appID[LOG_APPID_BUF_LEN + 1]; //应用标识
    char phoneID[LOG_PHONE_ID_LENGTH + 1]; //应用标识
    char phoneModel[LOG_PHONE_MODEL_LENGTH + 1]; //手机型号
    char phoneOS[LOG_PHONE_OS_LENGTH + 1]; //手机操作系统
    char phoneOSVer[LOG_PHONE_OS_VERSION_LENGTH + 1]; //手机操作系统版本号
    char versionSDK[LOG_SDK_VERSION_LENGTH + 1]; //SDK版本号
    FILE *fileBiz; //业务日志文件句柄
    FILE *fileSys; //系统日志文件句柄
} GizSDKClientLog_t;

/**
 * @brief 日志初始化.
 * @param[in] openAPIDomain- OpenAPI服务器域名.
 * @param[in] openAPIPort- OpenAPI服务器端口.
 * @param[in] appID- 应用标识地址.
 * @param[in] phoneID- 手机唯一标识码(例:"QWERTGFYDUJFYIDHYCJ").
 * @param[in] phoneOS- 手机操作系统(例:"Android").
 * @param[in] phoneOSVer- 手机操作系统版本号(例:"6.0").
 * @param[in] logDir- 存储日志目录的路径(推荐采用程序私有目录,例:/data/data/com.wanhe.www/files/GizSDK/").
 * @param[in] printLevel- 日志打印到屏幕的级别(0:不打印屏幕,1:打印error+busi,2:打印error+api+busi,3:打印error+api+debug+busi+data,默认3).
 * @param[in] verSDK- SDK的版本号(例:"2.01.01").
 * @return 返回日志初始化结果,0:成功,1:domain非法,2:port非法,3:appID非法,4:phoneID非法,5:phoneModel非法,6:phoneOS非法
 * 7:phoneOSVersion非法,8:verSDK非法,9:logDir指定错误(目录为空、不存在或无法创建文件等),10:printLevel非法,11:创建日志上传线程失败.
 *
 */
int GizSDKClientLogInit(const char *openAPIDomain, int openAPIPort,
                        const char *appID, const char *phoneID,
                        const char *phoneModel, const char *phoneOS,
                        const char *phoneOSVer, const char *verSDK,
                        const char *logDir, int printLevel);

/**
 * @brief 日志上传检测,如要上传则新建线程上传日志.
 * @param[in] domain- 日志待上传的服务器域名地址.
 * @param[in] port- 日志待上传的服务器端口.
 * @param[in] appID- 指定应用标识地址.
 * @param[in] uid- 指定用户标识码地址.
 * @param[in] token- 指定远程用户令牌地址.
 * @return 日志上传检测结果,0:成功,1:失败.
 *
 */
int GizSDKClientLogProvision(const char *domain, int port, const char *appID, const char *uid, const char *token);

/**
 * @brief 打印来至上层的业务日志.
 * @param[in] content- 业务日志内容.
 * @see content内容格式为[BIZ][时间][业务码][执行结果][描述]
 * @see 例:[BIZ][2015-11-24 11:20:49.309][usr_login_req][SUCCESS][用户登录请求]
 *
 */
void GizSDKClientPrintBizFromUp(const char *content);

/**
 * @brief 打印来至上层的错误日志.
 * @param[in] content- 错误日志内容.
 * @see content内容格式为[SYS][ERROR][时间][文件名:行号 函数名][日志体]
 * @see 例:[SYS][ERROR][2015-11-24 11:20:49.309][tool.c:937 connect] [conect 192.168.1.108:12906 failed, connection refused]
 *
 */
void GizSDKClientPrintErrorFromUp(const char *content);

/**
 * @brief 打印来至上层的接口日志.
 * @param[in] content- 接口日志内容.
 * @see content内容格式为[SYS][DEBUG][时间][文件名:行号 函数名][日志体]
 * @see 例:[SYS][DEBUG][2015-11-24 11:20:49.309][SDKEventManager.java:623  startWithAPPID] [Start call startWithAPPID]
 *
 */
void GizSDKClientPrintAPIFromUp(const char *content);

/**
 * @brief 打印来至上层的调试日志.
 * @param[in] content- 调试日志内容.
 * @see content内容格式为[SYS][DEBUG][时间][文件名:行号 函数名][日志体]
 * @see 例:[SYS][DEBUG][2015-11-24 11:20:49.309][tool.c:937 connect] [conect 192.168.1.108:12906 success, fd 127]
 *
 */
void GizSDKClientPrintDebugFromUp(const char *content);

//内部使用
char *GizSDKClientTimeStr(void);
void GizSDKClientClose(int fd, const char *file, int line, const char *function);
void GizSDKClientPrintBiz(const char *businessCode, const char *result, const char *format, ...);
void GizSDKClientPrintError(const char *format, ...);
void GizSDKClientPrintAPI(const char *format, ...);
void GizSDKClientPrintDebug(const char *format, ...);

#ifdef __cplusplus
}
#endif
#endif
