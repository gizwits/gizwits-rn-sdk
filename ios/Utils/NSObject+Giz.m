//
//  NSObject+Giz.m
//  MyR
//
//  Created by Pp on 12/18/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "NSObject+Giz.h"

@implementation NSObject (Giz)

- (NSDictionary *)dictionaryObject {
  if ([self isKindOfClass:[NSDictionary class]]) {
    return (NSDictionary *)self;
  }
  return nil;
}

@end
