//
//  NSDictionary+Giz.h
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Giz)
- (NSInteger)integerValueForKey:(NSString*)key defaultValue:(NSInteger)defaultValue;
- (BOOL)boolValueForKey:(NSString*)key defaultValue:(BOOL)defaultValue;
- (NSString*)stringValueForKey:(NSString*)key defaultValue:(NSString*)defaultValue;
- (NSArray *)arrayValueForKey:(NSString *)key defaultValue:(NSArray *)defaultValue;
- (NSDictionary *)dictValueForKey:(NSString *)key defaultValue:(NSDictionary *)defaultValue;
- (NSDictionary *)mi_replaceByteArrayWithData;
- (NSDictionary *)replaceNSDataValue;
- (NSArray *)byteArrayForData:(NSData *)data;

+ (NSDictionary *)makeErrorCodeFromResultCode:(int)resultCode;
@end
