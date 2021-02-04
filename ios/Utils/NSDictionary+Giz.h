//
//  NSDictionary+Giz.h
//

#import <Foundation/Foundation.h>
@class GizWifiDevice;
@class GizOpenApiUser;

@interface NSDictionary (Giz)
- (NSInteger)integerValueForKey:(NSString*)key defaultValue:(NSInteger)defaultValue;
- (BOOL)boolValueForKey:(NSString*)key defaultValue:(BOOL)defaultValue;
- (NSString*)stringValueForKey:(NSString*)key defaultValue:(NSString*)defaultValue;
- (NSArray *)arrayValueForKey:(NSString *)key defaultValue:(NSArray *)defaultValue;
- (NSDictionary *)dictValueForKey:(NSString *)key defaultValue:(NSDictionary *)defaultValue;
- (NSDictionary *)mi_replaceByteArrayWithData;
- (NSDictionary *)replaceNSDataValue;
- (NSArray *)byteArrayForData:(NSData *)data;

+ (NSMutableDictionary *)makeMutableDictFromDevice:(GizWifiDevice *)device;
+ (NSDictionary *)makeDictFromDeviceWithProperties:(GizWifiDevice *)device;
+ (NSDictionary *)makeDictFromLiteDeviceWithProperties:(GizWifiDevice *)device;
+ (NSDictionary *)makeUserWithProperties:(GizOpenApiUser *)userInfo;

+ (NSDictionary *)makeErrorDictFromError:(NSError *)error;
+ (NSDictionary *)makeErrorDictFromResultCode:(NSInteger)resultCode;
+ (NSDictionary *)makeErrorDictFromResultCode:(NSInteger)resultCode device:(NSDictionary *)device;
+ (NSDictionary *)makeErrorCodeFromError:(NSError *)error device:(NSDictionary *)device;
+ (NSDictionary *)makeWaitForTheLastRequestError;
+ (NSMutableDictionary *)makeOpenApiLoginResultDic:(OpenApiLoginResult *)loginResult;
+ (NSMutableDictionary *)makeOpenApiResultDic:(OpenApiResult *)result;
@end
