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
#define LOG_MAX_RENAME_BIZ_TIME     (60 * 60 )//10 *60
#define LOG_MAX_RENAME_SYS_TIME     (60 * 60)//60
#define LOG_MAX_GAGENT_FILE_SIZE    (10 * 1024)//10*1024
#define LOG_MAX_SYS_FILE_SIZE       (10 * 1024 * 1024)
#define LOG_MAX_BIZ_FILE_SIZE       (1000 * 1024) //云端最大接收字节数是1048359,故预留24K富余空间
#define LOG_MAX_UPLOADED_FILE_SIZE  (10 * 1024 * 1024)//10*1024*1024
#define LOG_MAX_PATH_LEN            (256)
#define LOG_MAX_PACKAGE_NAME_LEN    (16)
#define LOG_MAX_LEN                 (10 * 1024)
#define LOG_FILE_NAME               "GizSDKClientLogFile"
#define LOG_DAE_FILE_NAME			"GizSDKLogFile"

#define LOG_HTTP_TIMEOUT            (60)
#define LOG_IP_BUF_LENGTH           (128)
#define LOG_READ_BUF_LENGTH         (4096)
#define LOG_SEND_BUF_LENGTH         (4096)
#define LOG_HTTP_STATUS_OK          (200)
#define LOG_HTTP_BOUNDARY           "----GizSDKClientLogBoundaryGizWits"

#define LOG_DOMAIN_BUF_LEN          (128)
#define LOG_APPID_BUF_LEN           (32)
#define LOG_UID_BUF_LEN             (32)
#define LOG_TOKEN_BUF_LEN           (32)
#define LOG_PHONE_ID_LENGTH         (64)
#define LOG_PHONE_MODEL_LENGTH      (32)
#define LOG_PHONE_OS_LENGTH         (32)
#define LOG_PHONE_OS_VERSION_LENGTH (8)
#define LOG_SDK_VERSION_LENGTH      (64)
#define LOG_MD5_BUF_LENGTH          (32)
#define LOG_MAX_CONTACT_LENGTH      (60)
#define LOG_MAX_FEEDBACK_LENGTH     (6000)

//#define LOG_UPLOAD_PORT             (7081)
//#define LOG_UPLOAD_DOMAIN           "ter.gizwits.com"
#define LOG_FEEDBACK_PORT           (80)
#define LOG_FEEDBACK_DOMAIN         "api.gizwits.com"
#define AUTO_PARSER_DOMAIN_INTERVAL (60)

#define APPID_BUF_LENGTH            (32)
#define TOKEN_BUF_LENGTH            (32)
#define TO_FORMAT_BUF_LENGTH        (32)
#define OPENAPI_HEAD_APPID          "X-Gizwits-Application-Id"
#define OPENAPI_HEAD_TOKEN1         "X-Gizwits-User-token"
#define OPENAPI_HEAD_TOKEN2         "X-Gizwits-Application-Token"
#define OPENAPI_HEAD_TOKEN3         "X-Gizwits-User-Token"
#define OPENAPI_HEAD_COMMON         "X-Gizwits-"
#define OPENAPI_HEAD_SPLIT1         ": "
#define OPENAPI_HEAD_SPLIT2         "\n\r"

#define FEEDBACK_TYPE	(1)   //函数的调用类型为日志反馈
#define UPLOAD_API_TYPE	(2)   //函数的调用类型为上传类型

typedef enum {
    GIZ_SDK_CLIENT_LOG_TYPE_DEBUG = 0,
    GIZ_SDK_CLIENT_LOG_TYPE_NOTIC      = 1,
    GIZ_SDK_CLIENT_LOG_TYPE_WARN       = 2,
    GIZ_SDK_CLIENT_LOG_TYPE_ERROR = 3,
    GIZ_SDK_CLIENT_LOG_TYPE_API = 4,
    GIZ_SDK_CLIENT_LOG_TYPE_BIZ = 5,
} GIZ_SDK_CLIENT_LOG_TYPE;

typedef enum {
	GIZ_UPLOAD_INIT_CLOSR = 0,
	GIZ_UPLOAD_INIT_FIRST = 1,
	GIZ_UPLOAD_INIT_END = 2
} GIZ_UPLOAD_FILE;

#define __FILENAME__    ((strrchr(__FILE__, '/') ?: __FILE__ - 1) + 1)  //如果__FILE__编译为绝对路径（如xCode上），则只截取文件名
#define GizSDKClient_LOG_BIZ(businessCode, result, fmt, args...)  GizSDKClientPrint(GIZ_SDK_CLIENT_LOG_TYPE_BIZ, "[BIZ][%s][%s][%s][" fmt"]", GizSDKClientTimeStr(), businessCode, result, ##args)
#define GizSDKClient_LOG_CRASH(fmt, args...)  GizSDKClientPrint(GIZ_SDK_CLIENT_LOG_TYPE_ERROR, "[SYS][CRASH][%s][%s:%d %s][" fmt"]", GizSDKClientTimeStr(), __FILENAME__, __LINE__, __FUNCTION__, ##args)
#define GizSDKClient_LOG_ERROR(fmt, args...)  GizSDKClientPrint(GIZ_SDK_CLIENT_LOG_TYPE_ERROR, "[SYS][ERROR][%s][%s:%d %s][" fmt"]", GizSDKClientTimeStr(), __FILENAME__, __LINE__, __FUNCTION__, ##args)
#define GizSDKClient_LOG_WARN(fmt, args...)  GizSDKClientPrint(GIZ_SDK_CLIENT_LOG_TYPE_WARN, "[SYS][WARN][%s][%s:%d %s][" fmt"]", GizSDKClientTimeStr(), __FILENAME__, __LINE__, __FUNCTION__, ##args)
#define GizSDKClient_LOG_NOTIC(fmt, args...)  GizSDKClientPrint(GIZ_SDK_CLIENT_LOG_TYPE_NOTIC, "[SYS][NOTIC][%s][%s:%d %s][" fmt"]", GizSDKClientTimeStr(), __FILENAME__, __LINE__, __FUNCTION__, ##args)
#define GizSDKClient_LOG_API(fmt, args...)  GizSDKClientPrint(GIZ_SDK_CLIENT_LOG_TYPE_API, "[SYS][DEBUG][%s][%s:%d %s][" fmt"]", GizSDKClientTimeStr(), __FILENAME__, __LINE__, __FUNCTION__, ##args)
#define GizSDKClient_LOG_DEBUG(fmt, args...)  GizSDKClientPrint(GIZ_SDK_CLIENT_LOG_TYPE_DEBUG, "[SYS][DEBUG][%s][%s:%d %s][" fmt"]", GizSDKClientTimeStr(), __FILENAME__, __LINE__, __FUNCTION__, ##args)

#define GizSDKClient_CLOSE(fd)    GizSDKClientClose(fd, __FILENAME__, __LINE__, __FUNCTION__)

/**
 * @brief 日志初始化.
 * @param[in] encryptLog- 是否加密日志.
 *
 */
void GizSDKClientSetEncryptLog(char encryptLog);

/**
 * @brief 日志是否加密.
 * @return 返回日志是否加密.
 *
 */
char GizSDKClientGetEncryptLog(void);

/**
 * @brief 日志是否已初始化. 给客户端使用，日志初始化后再输出日志
 * @return 返回日志是否初始化.
 *
 */
char GizSDKClientGetLogIsInit(void);

/**
 * @brief 日志初始化.
 * @param[in] openAPIDomain- OpenAPI服务器域名.
 * @param[in] openAPISSLPort OpenAPI服务器SSL端口.
 * @param[in] openAPIPort    OpenAPI服务器端口
 * @param[in] appID- 应用标识地址.
 * @param[in] phoneID- 手机唯一标识码(例:"QWERTGFYDUJFYIDHYCJ").
 * @param[in] phoneOS- 手机操作系统(例:"Android").
 * @param[in] phoneOSVer- 手机操作系统版本号(例:"6.0").
 * @param[in] logDir- 存储日志目录的路径(推荐采用程序私有目录,例:/data/data/com.wanhe.www/files/GizSDK/").
 * @param[in] printLevel- 日志打印到屏幕的级别(0:不打印屏幕,1:打印error+busi,2:打印error+api+busi,3:打印error+api+busi+warn,4:打印error+api+busi+warn+notic, 5:打印error+api+busi+warn+notic+debug+data,默认5).
 * @param[in] verSDK- SDK的版本号(例:"2.01.01").
 * @return 返回日志初始化结果,0:成功,1:domain非法,2:openAPISSLPort非法,3:appID非法,4:phoneID非法,5:phoneModel非法,6:phoneOS非法
 * 7:phoneOSVersion非法,8:verSDK非法,9:logDir指定错误(目录为空、不存在或无法创建文件等),10:printLevel非法,11:创建日志上传线程失败.
 * 12:port非法
 *
 */
int GizSDKClientLogInit(const char *openAPIDomain, int openAPISSLPort,int port,
                        const char *appID, const char *phoneID,
                        const char *phoneModel, const char *phoneOS,
                        const char *phoneOSVer, const char *verSDK,
                        const char *logDir, int printLevel);

/**
 * @brief 日志上传检测,如要上传则新建线程上传日志.
 * @param[in] token- 指定远程用户令牌地址.
 * @return 日志上传检测结果,0:成功,1:失败.
 *
 */
int GizSDKClientLogProvision(  const char *token);

/**
 * @brief 设置上传日志开关.
 * @param[in] sysUpload- 是否上传sys日志.
 * @param[in] bizUpload- 是否上传biz日志.
 *
 */
void GizSDKClientSetUploadLogSwitch(char sysUpload, char bizUpload );

/**
 * @brief 打印来自上层的业务日志.
 * @param[in] content- 业务日志内容.
 * @see content内容格式为[BIZ][时间][业务码][执行结果][描述]
 * @see 例:[BIZ][2015-11-24 11:20:49.309][usr_login_req][SUCCESS][用户登录请求]
 *
 */
void GizSDKClientPrintBizFromUp(const char *content);

/**
 * @brief 打印来自上层的错误日志.
 * @param[in] content- 错误日志内容.
 * @see content内容格式为[SYS][ERROR][时间][文件名:行号 函数名][日志体]
 * @see 例:[SYS][ERROR][2015-11-24 11:20:49.309][tool.c:937 connect] [conect 192.168.1.108:12906 failed, connection refused]
 *
 */
void GizSDKClientPrintErrorFromUp(const char *content);

/**
 * @brief 打印来自上层的接口日志.
 * @param[in] content- 接口日志内容.
 * @see content内容格式为[SYS][DEBUG][时间][文件名:行号 函数名][日志体]
 * @see 例:[SYS][DEBUG][2015-11-24 11:20:49.309][SDKEventManager.java:623  startWithAPPID] [Start call startWithAPPID]
 *
 */
void GizSDKClientPrintAPIFromUp(const char *content);

/**
 * @brief 打印来自上层的调试日志.
 * @param[in] content- 调试日志内容.
 * @see content内容格式为[SYS][DEBUG][时间][文件名:行号 函数名][日志体]
 * @see 例:[SYS][DEBUG][2015-11-24 11:20:49.309][tool.c:937 connect] [conect 192.168.1.108:12906 success, fd 127]
 *
 */
void GizSDKClientPrintDebugFromUp(const char *content);

/**
 * @brief 用户信息反馈.
 * @param[in] contactInfo- 联系信息.
 * @param[in] feedbackInfo- 反馈信息.
 * @param[in] sendLog- 是否附带SDK日志一起反馈(0表示不附带,非0表示附带).
 *
 */
void GizSDKClientUserFeedback(const char *contactInfo, const char *feedbackInfo, char sendLog);

//内部使用
char *GizSDKClientTimeStr(void);
void GizSDKClientClose(int fd, const char *file, int line, const char *function);
void GizSDKClientPrint(GIZ_SDK_CLIENT_LOG_TYPE logType, const char *format, ...);

#ifdef __cplusplus
}
#endif
#endif
