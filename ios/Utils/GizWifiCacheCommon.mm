#import "GizWifiCacheCommon.h"

@implementation GizWifiCacheCommon

+ (void)addDelegate:(id)delegate mutableArray:(NSMutableArray *)mDelegates {
    if ([mDelegates indexOfObject:delegate] >= mDelegates.count) {
        [mDelegates addObject:delegate];
    }
}

+ (void)removeDelegate:(id)delegate mutableArray:(NSMutableArray *)mDelegates {
    if ([mDelegates indexOfObject:delegate] < mDelegates.count) {
        [mDelegates removeObject:delegate];
    }
}

@end