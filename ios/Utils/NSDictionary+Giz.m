//
//  NSDictionary+Giz.m
//

#import "NSDictionary+Giz.h"
#import <GizWifiSDK/GizWifiDefinitions.h>
#import <GizWifiSDK/GizWifiDevice.h>
#import "GizWifiDef.h"

@implementation NSDictionary (Giz)
- (NSInteger)integerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue
{
  if ([self objectForKey:key] != nil) {
    return [[self valueForKey:key] integerValue];
  }
  return defaultValue;
}

- (BOOL)boolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue
{
  if ([self objectForKey:key] != nil) {
    return [[self valueForKey:key] boolValue];
  }
  return defaultValue;
}

- (NSString *)stringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue
{
  NSString *ret = (NSString *)[self valueForKey:key];
  if (ret == nil) {
    ret = defaultValue;
  }
  return ret;
}

- (NSArray *)arrayValueForKey:(NSString *)key defaultValue:(NSArray *)defaultValue
{
  if ([self objectForKey:key] != nil) {
    return (NSArray *)[self valueForKey:key];
  }
  return defaultValue;
}

- (NSDictionary *)dictValueForKey:(NSString *)key defaultValue:(NSDictionary *)defaultValue
{
  NSDictionary *ret = (NSDictionary *)[self valueForKey:key];
  if (ret == nil) {
    ret = defaultValue;
  }
  return ret;
}

- (NSArray *)byteArrayForData:(NSData *)data {
  NSMutableArray<NSNumber *> *numberArray = [NSMutableArray new];
  
  const unsigned char *bytes = data.bytes;
  
  for (NSUInteger i = 0; i < data.length; i++) {
    NSUInteger byte = bytes[i];
    
    [numberArray addObject:@(byte)];
  }
  
  return numberArray;
}

- (NSDictionary *)mi_replaceByteArrayWithData {
  
  NSMutableDictionary *mdict = [self mutableCopy];
  
  for (NSString *key in mdict.allKeys)
  {
    id value = self[key];
    
    if ([value isKindOfClass:[NSArray class]])
    {
      [mdict setObject:[self dataForByteArray:(NSArray *)value] forKey:key];
    }
    else if ([value isKindOfClass:[NSDictionary class]])
    {
      value = [(NSDictionary *)value mi_replaceByteArrayWithData];
      [mdict setObject:value forKey:key];
    }
  }
  
  return mdict;
}

- (NSData *)dataForByteArray:(NSArray<NSNumber *> *)byteArray {
  
  NSMutableData *data = [NSMutableData dataWithCapacity:byteArray.count];
  
  for (NSNumber *number in byteArray) {
    unsigned char byte[] = {number.unsignedIntegerValue};
    [data appendBytes:byte length:sizeof(byte)];
  }
  
  return data;
}

- (NSDictionary *)replaceNSDataValue
{
  NSMutableDictionary *mdict = [self mutableCopy];
  
  for (NSString *key in mdict.allKeys)
  {
    id value = self[key];
    
    if ([value isKindOfClass:[NSData class]])
    {
      [mdict setObject:[self byteArrayForData:(NSData *)value] forKey:key];
    }
    else if ([value isKindOfClass:[NSDictionary class]])
    {
      value = [(NSDictionary *)value replaceNSDataValue];
      [mdict setObject:value forKey:key];
    }
  }
  
  return mdict;
}

#pragma mark - bussines
+ (NSMutableDictionary *)makeMutableDictFromDevice:(GizWifiDevice *)device {
  NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
  
  //设备唯一标识
  [mdict setValue:device.macAddress forKey:@"mac"];
  [mdict setValue:device.did forKey:@"did"];
  
  //    if ([device isMemberOfClass:[GizWifiSubDevice class]]) {
  //        GizWifiSubDevice *subDevice = (GizWifiSubDevice *)device;
  //
  //        //设备唯一标识
  //        [mdict setValue:subDevice.subDid forKey:@"subDid"];
  //    }
  return mdict;
}

+ (NSDictionary *)makeDictFromDeviceWithProperties:(GizWifiDevice *)device {
  NSMutableDictionary *mdict = [self makeMutableDictFromDevice:device];
  NSInteger netStatus = getDeviceNetStatus(device.netStatus);
  //    if ([device isMemberOfClass:[GizWifiSubDevice class]]) {
  //        GizWifiSubDevice *subDevice = (GizWifiSubDevice *)device;
  //
  //        // 子设备其他属性
  //        [mdict setValue:subDevice.subProductKey forKey:@"subProductKey"];
  //        [mdict setValue:subDevice.subProductName forKey:@"subProductName"];
  //        [mdict setValue:@(subDevice.isConnected) forKey:@"isConnected"];
  //        [mdict setValue:@(netStatus) forKey:@"netStatus"];
  //        [mdict setValue:@(subDevice.isOnline) forKey:@"isOnline"];
  //        [mdict setValue:@0 forKey:@"type"];
  //        [mdict setValue:subDevice.productKey forKey:@"productKey"];
  //        [mdict setValue:subDevice.productName forKey:@"productName"];
  //    } else {
  // 普通设备其他属性
  NSInteger productType = getDeviceTypeFromEnum(device.productType);
  [mdict setValue:device.macAddress forKey:@"mac"];
  [mdict setValue:device.did forKey:@"did"];
  [mdict setValue:device.passcode forKey:@"passcode"];
  [mdict setValue:device.productKey forKey:@"productKey"];
  [mdict setValue:device.productName forKey:@"productName"];
  [mdict setValue:device.ipAddress forKey:@"ip"];
  [mdict setValue:@(productType) forKey:@"type"];
  [mdict setValue:@(device.isConnected) forKey:@"isConnected"];
  [mdict setValue:@(device.isOnline) forKey:@"isOnline"];
  [mdict setValue:device.remark forKey:@"remark"];
  [mdict setValue:device.alias forKey:@"alias"];
  [mdict setValue:@(netStatus) forKey:@"netStatus"];
  [mdict setValue:@(device.isLAN) forKey:@"isLAN"];
  [mdict setValue:@(device.isBind) forKey:@"isBind"];
  [mdict setValue:@(device.isDisabled) forKey:@"isDisabled"];
  [mdict setValue:@(device.isProductDefined) forKey:@"isProductDefined"];
  [mdict setValue:@(device.isSubscribed) forKey:@"isSubscribed"];
  //    }
  return [mdict copy];
}

+ (NSDictionary *)makeErrorDictFromError:(NSError *)error {
  NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
  [mdict setValue:@(error.code) forKey:@"errorCode"];
  [mdict setValue:error.localizedDescription forKey:@"msg"];
  return [mdict copy];
}

+ (NSDictionary *)makeErrorDictFromResultCode:(NSInteger)resultCode{
  NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
  [mdict setValue:@(resultCode) forKey:@"errorCode"];
  [mdict setValue:[self defaultErrorMessage:resultCode] forKey:@"msg"];
  return [mdict copy];
}

+ (NSDictionary *)makeErrorCodeFromError:(NSError *)error device:(NSDictionary *)device {
  NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
  [mdict setValue:@(error.code) forKey:@"errorCode"];
  [mdict setValue:error.localizedDescription forKey:@"msg"];
  [mdict setValue:device forKey:@"device"];
  return [mdict copy];
}

+ (NSDictionary *)makeWaitForTheLastRequestError{
  return @{@"msg": @"Please wait for the last request!"};
}

+ (NSString *)defaultErrorMessage:(NSInteger)errorCode {
  switch (errorCode) {
    case GIZ_SDK_SUCCESS:
      return @"GIZ_SDK_SUCCESS";
    case GIZ_PUSHAPI_BODY_JSON_INVALID:
      return @"GIZ_PUSHAPI_BODY_JSON_INVALID";
    case GIZ_PUSHAPI_DATA_NOT_EXIST:
      return @"GIZ_PUSHAPI_DATA_NOT_EXIST";
    case GIZ_PUSHAPI_NO_CLIENT_CONFIG:
      return @"GIZ_PUSHAPI_NO_CLIENT_CONFIG";
    case GIZ_PUSHAPI_NO_SERVER_DATA:
      return @"GIZ_PUSHAPI_NO_SERVER_DATA";
    case GIZ_PUSHAPI_GIZWITS_APPID_EXIST:
      return @"GIZ_PUSHAPI_GIZWITS_APPID_EXIST";
    case GIZ_PUSHAPI_PARAM_ERROR:
      return @"GIZ_PUSHAPI_PARAM_ERROR";
    case GIZ_PUSHAPI_AUTH_KEY_INVALID:
      return @"GIZ_PUSHAPI_AUTH_KEY_INVALID";
    case GIZ_PUSHAPI_APPID_OR_TOKEN_ERROR:
      return @"GIZ_PUSHAPI_APPID_OR_TOKEN_ERROR";
    case GIZ_PUSHAPI_TYPE_PARAM_ERROR:
      return @"GIZ_PUSHAPI_TYPE_PARAM_ERROR";
    case GIZ_PUSHAPI_ID_PARAM_ERROR:
      return @"GIZ_PUSHAPI_ID_PARAM_ERROR";
    case GIZ_PUSHAPI_APPKEY_SECRETKEY_INVALID:
      return @"GIZ_PUSHAPI_APPKEY_SECRETKEY_INVALID";
    case GIZ_PUSHAPI_CHANNELID_ERROR_INVALID:
      return @"GIZ_PUSHAPI_CHANNELID_ERROR_INVALID";
    case GIZ_PUSHAPI_PUSH_ERROR:
      return @"GIZ_PUSHAPI_PUSH_ERROR";
    case GIZ_SDK_PARAM_FORM_INVALID:
      return @"GIZ_SDK_PARAM_FORM_INVALID";
    case GIZ_SDK_CLIENT_NOT_AUTHEN:
      return @"GIZ_SDK_CLIENT_NOT_AUTHEN";
    case GIZ_SDK_CLIENT_VERSION_INVALID:
      return @"GIZ_SDK_CLIENT_VERSION_INVALID";
    case GIZ_SDK_UDP_PORT_BIND_FAILED:
      return @"GIZ_SDK_UDP_PORT_BIND_FAILED";
    case GIZ_SDK_DAEMON_EXCEPTION:
      return @"GIZ_SDK_DAEMON_EXCEPTION";
    case GIZ_SDK_PARAM_INVALID:
      return @"GIZ_SDK_PARAM_INVALID";
    case GIZ_SDK_APPID_LENGTH_ERROR:
      return @"GIZ_SDK_APPID_LENGTH_ERROR";
    case GIZ_SDK_LOG_PATH_INVALID:
      return @"GIZ_SDK_LOG_PATH_INVALID";
    case GIZ_SDK_LOG_LEVEL_INVALID:
      return @"GIZ_SDK_LOG_LEVEL_INVALID";
    case GIZ_SDK_APPID_INVALID:
      return @"GIZ_SDK_APPID_INVALID";
    case GIZ_SDK_DEVICE_CONFIG_SEND_FAILED:
      return @"GIZ_SDK_DEVICE_CONFIG_SEND_FAILED";
    case GIZ_SDK_DEVICE_CONFIG_IS_RUNNING:
      return @"GIZ_SDK_DEVICE_CONFIG_IS_RUNNING";
    case GIZ_SDK_DEVICE_CONFIG_TIMEOUT:
      return @"GIZ_SDK_DEVICE_CONFIG_TIMEOUT";
    case GIZ_SDK_DEVICE_DID_INVALID:
      return @"GIZ_SDK_DEVICE_DID_INVALID";
    case GIZ_SDK_DEVICE_MAC_INVALID:
      return @"GIZ_SDK_DEVICE_MAC_INVALID";
    case GIZ_SDK_SUBDEVICE_DID_INVALID:
      return @"GIZ_SDK_SUBDEVICE_DID_INVALID";
    case GIZ_SDK_DEVICE_PASSCODE_INVALID:
      return @"GIZ_SDK_DEVICE_PASSCODE_INVALID";
    case GIZ_SDK_DEVICE_NOT_CENTERCONTROL:
      return @"GIZ_SDK_DEVICE_NOT_CENTERCONTROL";
    case GIZ_SDK_DEVICE_NOT_SUBSCRIBED:
      return @"GIZ_SDK_DEVICE_NOT_SUBSCRIBED";
    case GIZ_SDK_DEVICE_NO_RESPONSE:
      return @"GIZ_SDK_DEVICE_NO_RESPONSE";
    case GIZ_SDK_DEVICE_NOT_READY:
      return @"GIZ_SDK_DEVICE_NOT_READY";
    case GIZ_SDK_DEVICE_NOT_BINDED:
      return @"GIZ_SDK_DEVICE_NOT_BINDED";
    case GIZ_SDK_DEVICE_CONTROL_WITH_INVALID_COMMAND:
      return @"GIZ_SDK_DEVICE_CONTROL_WITH_INVALID_COMMAND";
    case GIZ_SDK_DEVICE_CONTROL_FAILED:
      return @"GIZ_SDK_DEVICE_CONTROL_FAILED";
    case GIZ_SDK_DEVICE_GET_STATUS_FAILED:
      return @"GIZ_SDK_DEVICE_GET_STATUS_FAILED";
    case GIZ_SDK_DEVICE_CONTROL_VALUE_TYPE_ERROR:
      return @"GIZ_SDK_DEVICE_CONTROL_VALUE_TYPE_ERROR";
    case GIZ_SDK_DEVICE_CONTROL_VALUE_OUT_OF_RANGE:
      return @"GIZ_SDK_DEVICE_CONTROL_VALUE_OUT_OF_RANGE";
    case GIZ_SDK_DEVICE_CONTROL_NOT_WRITABLE_COMMAND:
      return @"GIZ_SDK_DEVICE_CONTROL_NOT_WRITABLE_COMMAND";
    case GIZ_SDK_BIND_DEVICE_FAILED:
      return @"GIZ_SDK_BIND_DEVICE_FAILED";
    case GIZ_SDK_UNBIND_DEVICE_FAILED:
      return @"GIZ_SDK_UNBIND_DEVICE_FAILED";
    case GIZ_SDK_DNS_FAILED:
      return @"GIZ_SDK_DNS_FAILED";
    case GIZ_SDK_M2M_CONNECTION_SUCCESS:
      return @"GIZ_SDK_M2M_CONNECTION_SUCCESS";
    case GIZ_SDK_SET_SOCKET_NON_BLOCK_FAILED:
      return @"GIZ_SDK_SET_SOCKET_NON_BLOCK_FAILED";
    case GIZ_SDK_CONNECTION_TIMEOUT:
      return @"GIZ_SDK_CONNECTION_TIMEOUT";
    case GIZ_SDK_CONNECTION_REFUSED:
      return @"GIZ_SDK_CONNECTION_REFUSED";
    case GIZ_SDK_CONNECTION_ERROR:
      return @"GIZ_SDK_CONNECTION_ERROR";
    case GIZ_SDK_CONNECTION_CLOSED:
      return @"GIZ_SDK_CONNECTION_CLOSED";
    case GIZ_SDK_SSL_HANDSHAKE_FAILED:
      return @"GIZ_SDK_SSL_HANDSHAKE_FAILED";
    case GIZ_SDK_DEVICE_LOGIN_VERIFY_FAILED:
      return @"GIZ_SDK_DEVICE_LOGIN_VERIFY_FAILED";
    case GIZ_SDK_INTERNET_NOT_REACHABLE:
      return @"GIZ_SDK_INTERNET_NOT_REACHABLE";
    case GIZ_SDK_HTTP_ANSWER_FORMAT_ERROR:
      return @"GIZ_SDK_HTTP_ANSWER_FORMAT_ERROR";
    case GIZ_SDK_HTTP_ANSWER_PARAM_ERROR:
      return @"GIZ_SDK_HTTP_ANSWER_PARAM_ERROR";
    case GIZ_SDK_HTTP_SERVER_NO_ANSWER:
      return @"GIZ_SDK_HTTP_SERVER_NO_ANSWER";
    case GIZ_SDK_HTTP_REQUEST_FAILED:
      return @"GIZ_SDK_HTTP_REQUEST_FAILED";
    case GIZ_SDK_OTHERWISE:
      return @"GIZ_SDK_OTHERWISE";
    case GIZ_SDK_MEMORY_MALLOC_FAILED:
      return @"GIZ_SDK_MEMORY_MALLOC_FAILED";
    case GIZ_SDK_THREAD_CREATE_FAILED:
      return @"GIZ_SDK_THREAD_CREATE_FAILED";
      // case GIZ_SDK_USER_ID_INVALID:
      // return @"GIZ_SDK_USER_ID_INVALID";
      // case GIZ_SDK_TOKEN_INVALID:
      // return @"GIZ_SDK_TOKEN_INVALID";
    case GIZ_SDK_GROUP_ID_INVALID:
      return @"GIZ_SDK_GROUP_ID_INVALID";
      // case GIZ_SDK_GROUPNAME_INVALID:
      // return @"GIZ_SDK_GROUPNAME_INVALID";
    case GIZ_SDK_GROUP_PRODUCTKEY_INVALID:
      return @"GIZ_SDK_GROUP_PRODUCTKEY_INVALID";
    case GIZ_SDK_GROUP_FAILED_DELETE_DEVICE:
      return @"GIZ_SDK_GROUP_FAILED_DELETE_DEVICE";
    case GIZ_SDK_GROUP_FAILED_ADD_DEVICE:
      return @"GIZ_SDK_GROUP_FAILED_ADD_DEVICE";
    case GIZ_SDK_GROUP_GET_DEVICE_FAILED:
      return @"GIZ_SDK_GROUP_GET_DEVICE_FAILED";
    case GIZ_SDK_DATAPOINT_NOT_DOWNLOAD:
      return @"GIZ_SDK_DATAPOINT_NOT_DOWNLOAD";
    case GIZ_SDK_DATAPOINT_SERVICE_UNAVAILABLE:
      return @"GIZ_SDK_DATAPOINT_SERVICE_UNAVAILABLE";
    case GIZ_SDK_DATAPOINT_PARSE_FAILED:
      return @"GIZ_SDK_DATAPOINT_PARSE_FAILED";
    case GIZ_SDK_NOT_INITIALIZED:
      return @"GIZ_SDK_NOT_INITIALIZED";
    case GIZ_SDK_EXEC_DAEMON_FAILED:
      return @"GIZ_SDK_EXEC_DAEMON_FAILED";
    case GIZ_SDK_EXEC_CATCH_EXCEPTION:
      return @"GIZ_SDK_EXEC_CATCH_EXCEPTION";
    case GIZ_SDK_APPID_IS_EMPTY:
      return @"GIZ_SDK_APPID_IS_EMPTY";
    case GIZ_SDK_UNSUPPORTED_API:
      return @"GIZ_SDK_UNSUPPORTED_API";
    case GIZ_SDK_REQUEST_TIMEOUT:
      return @"GIZ_SDK_REQUEST_TIMEOUT";
    case GIZ_SDK_DAEMON_VERSION_INVALID:
      return @"GIZ_SDK_DAEMON_VERSION_INVALID";
    case GIZ_SDK_PHONE_NOT_CONNECT_TO_SOFTAP_SSID:
      return @"GIZ_SDK_PHONE_NOT_CONNECT_TO_SOFTAP_SSID";
    case GIZ_SDK_DEVICE_CONFIG_SSID_NOT_MATCHED:
      return @"GIZ_SDK_DEVICE_CONFIG_SSID_NOT_MATCHED";
    case GIZ_SDK_NOT_IN_SOFTAPMODE:
      return @"GIZ_SDK_NOT_IN_SOFTAPMODE";
    case GIZ_SDK_PHONE_WIFI_IS_UNAVAILABLE:
      return @"GIZ_SDK_PHONE_WIFI_IS_UNAVAILABLE";
    case GIZ_SDK_RAW_DATA_TRANSMIT:
      return @"GIZ_SDK_RAW_DATA_TRANSMIT";
    case GIZ_SDK_PRODUCT_IS_DOWNLOADING:
      return @"GIZ_SDK_PRODUCT_IS_DOWNLOADING";
    case GIZ_SDK_START_SUCCESS:
      return @"GIZ_SDK_START_SUCCESS";
      
      //OPEN-API
    case GIZ_OPENAPI_MAC_ALREADY_REGISTERED:
      return @"GIZ_OPENAPI_MAC_ALREADY_REGISTERED";
    case GIZ_OPENAPI_PRODUCT_KEY_INVALID:
      return @"GIZ_OPENAPI_PRODUCT_KEY_INVALID";
    case GIZ_OPENAPI_APPID_INVALID:
      return @"GIZ_OPENAPI_APPID_INVALID";
    case GIZ_OPENAPI_TOKEN_INVALID:
      return @"GIZ_OPENAPI_TOKEN_INVALID";
    case GIZ_OPENAPI_USER_NOT_EXIST:
      return @"GIZ_OPENAPI_USER_NOT_EXIST";
    case GIZ_OPENAPI_TOKEN_EXPIRED:
      return @"GIZ_OPENAPI_TOKEN_EXPIRED";
    case GIZ_OPENAPI_M2M_ID_INVALID:
      return @"GIZ_OPENAPI_M2M_ID_INVALID";
    case GIZ_OPENAPI_SERVER_ERROR:
      return @"GIZ_OPENAPI_SERVER_ERROR";
    case GIZ_OPENAPI_CODE_EXPIRED:
      return @"GIZ_OPENAPI_CODE_EXPIRED";
    case GIZ_OPENAPI_CODE_INVALID:
      return @"GIZ_OPENAPI_CODE_INVALID";
    case GIZ_OPENAPI_SANDBOX_SCALE_QUOTA_EXHAUSTED:
      return @"GIZ_OPENAPI_SANDBOX_SCALE_QUOTA_EXHAUSTED";
    case GIZ_OPENAPI_PRODUCTION_SCALE_QUOTA_EXHAUSTED:
      return @"GIZ_OPENAPI_PRODUCTION_SCALE_QUOTA_EXHAUSTED";
    case GIZ_OPENAPI_PRODUCT_HAS_NO_REQUEST_SCALE:
      return @"GIZ_OPENAPI_PRODUCT_HAS_NO_REQUEST_SCALE";
    case GIZ_OPENAPI_DEVICE_NOT_FOUND:
      return @"GIZ_OPENAPI_DEVICE_NOT_FOUND";
    case GIZ_OPENAPI_FORM_INVALID:
      return @"GIZ_OPENAPI_FORM_INVALID";
    case GIZ_OPENAPI_DID_PASSCODE_INVALID:
      return @"GIZ_OPENAPI_DID_PASSCODE_INVALID";
    case GIZ_OPENAPI_DEVICE_NOT_BOUND:
      return @"GIZ_OPENAPI_DEVICE_NOT_BOUND";
    case GIZ_OPENAPI_PHONE_UNAVALIABLE:
      return @"GIZ_OPENAPI_PHONE_UNAVALIABLE";
    case GIZ_OPENAPI_USERNAME_UNAVALIABLE:
      return @"GIZ_OPENAPI_USERNAME_UNAVALIABLE";
    case GIZ_OPENAPI_USERNAME_PASSWORD_ERROR:
      return @"GIZ_OPENAPI_USERNAME_PASSWORD_ERROR";
    case GIZ_OPENAPI_SEND_COMMAND_FAILED:
      return @"GIZ_OPENAPI_SEND_COMMAND_FAILED";
    case GIZ_OPENAPI_EMAIL_UNAVALIABLE:
      return @"GIZ_OPENAPI_EMAIL_UNAVALIABLE";
    case GIZ_OPENAPI_DEVICE_DISABLED:
      return @"GIZ_OPENAPI_DEVICE_DISABLED";
    case GIZ_OPENAPI_FAILED_NOTIFY_M2M:
      return @"GIZ_OPENAPI_FAILED_NOTIFY_M2M";
    case GIZ_OPENAPI_ATTR_INVALID:
      return @"GIZ_OPENAPI_ATTR_INVALID";
    case GIZ_OPENAPI_USER_INVALID:
      return @"GIZ_OPENAPI_USER_INVALID";
    case GIZ_OPENAPI_FIRMWARE_NOT_FOUND:
      return @"GIZ_OPENAPI_FIRMWARE_NOT_FOUND";
    case GIZ_OPENAPI_JD_PRODUCT_NOT_FOUND:
      return @"GIZ_OPENAPI_JD_PRODUCT_NOT_FOUND";
    case GIZ_OPENAPI_DATAPOINT_DATA_NOT_FOUND:
      return @"GIZ_OPENAPI_DATAPOINT_DATA_NOT_FOUND";
    case GIZ_OPENAPI_SCHEDULER_NOT_FOUND:
      return @"GIZ_OPENAPI_SCHEDULER_NOT_FOUND";
    case GIZ_OPENAPI_QQ_OAUTH_KEY_INVALID:
      return @"GIZ_OPENAPI_QQ_OAUTH_KEY_INVALID";
    case GIZ_OPENAPI_OTA_SERVICE_OK_BUT_IN_IDLE:
      return @"GIZ_OPENAPI_OTA_SERVICE_OK_BUT_IN_IDLE";
    case GIZ_OPENAPI_BT_FIRMWARE_UNVERIFIED:
      return @"GIZ_OPENAPI_BT_FIRMWARE_UNVERIFIED";
    case GIZ_OPENAPI_BT_FIRMWARE_NOTHING_TO_UPGRADE:
      return @"GIZ_OPENAPI_BT_FIRMWARE_NOTHING_TO_UPGRADE";
    case GIZ_OPENAPI_SAVE_KAIROSDB_ERROR:
      return @"GIZ_OPENAPI_SAVE_KAIROSDB_ERROR";
    case GIZ_OPENAPI_EVENT_NOT_DEFINED:
      return @"GIZ_OPENAPI_EVENT_NOT_DEFINED";
    case GIZ_OPENAPI_SEND_SMS_FAILED:
      return @"GIZ_OPENAPI_SEND_SMS_FAILED";
    case GIZ_OPENAPI_APPLICATION_AUTH_INVALID:
      return @"GIZ_OPENAPI_APPLICATION_AUTH_INVALID";
    case GIZ_OPENAPI_NOT_ALLOWED_CALL_API:
      return @"GIZ_OPENAPI_NOT_ALLOWED_CALL_API";
    case GIZ_OPENAPI_BAD_QRCODE_CONTENT:
      return @"GIZ_OPENAPI_BAD_QRCODE_CONTENT";
    case GIZ_OPENAPI_REQUEST_THROTTLED:
      return @"GIZ_OPENAPI_REQUEST_THROTTLED";
    case GIZ_OPENAPI_DEVICE_OFFLINE:
      return @"GIZ_OPENAPI_DEVICE_OFFLINE";
    case GIZ_OPENAPI_TIMESTAMP_INVALID:
      return @"GIZ_OPENAPI_DEVICE_OFFLINE";
    case GIZ_OPENAPI_SIGNATURE_INVALID:
      return @"GIZ_OPENAPI_SIGNATURE_INVALID";
    case GIZ_OPENAPI_DEPRECATED_API:
      return @"GIZ_OPENAPI_DEPRECATED_API";
    case GIZ_OPENAPI_RESERVED:
      return @"GIZ_OPENAPI_RESERVED";
      
      //10000+
    case GIZ_SITE_PRODUCTKEY_INVALID:
      return @"GIZ_SITE_PRODUCTKEY_INVALID";
    case GIZ_SITE_DATAPOINTS_NOT_DEFINED:
      return @"GIZ_SITE_DATAPOINTS_NOT_DEFINED";
    case GIZ_SITE_DATAPOINTS_NOT_MALFORME:
      return @"GIZ_SITE_DATAPOINTS_NOT_MALFORME";
      
    default:
      break;
  }
  return @"Unknown error";
}

@end
