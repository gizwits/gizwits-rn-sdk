#import <Foundation/Foundation.h>

@interface GizWifiCacheCommon : NSObject

+ (void)addDelegate:(id)delegate mutableArray:(NSMutableArray *)mDelegates;
+ (void)removeDelegate:(id)delegate mutableArray:(NSMutableArray *)mDelegates;

@end
