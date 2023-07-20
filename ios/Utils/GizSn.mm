#import "GizSn.h"

@implementation GizSn

static NSInteger sn = 1000;

+ (NSInteger)getSn {
    sn=sn+1;
    return sn;
}

@end
